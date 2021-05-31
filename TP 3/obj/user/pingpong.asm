
obj/user/pingpong.debug:     formato del fichero elf32-i386


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
  80002c:	e8 93 00 00 00       	call   8000c4 <libmain>
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
  80003d:	83 ec 1c             	sub    $0x1c,%esp
	envid_t who;

	if ((who = fork()) != 0) {
  800040:	e8 59 10 00 00       	call   80109e <fork>
  800045:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800048:	85 c0                	test   %eax,%eax
  80004a:	75 4f                	jne    80009b <umain+0x68>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		uint32_t i = ipc_recv(&who, 0, 0);
  80004c:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  80004f:	83 ec 04             	sub    $0x4,%esp
  800052:	6a 00                	push   $0x0
  800054:	6a 00                	push   $0x0
  800056:	56                   	push   %esi
  800057:	e8 e3 11 00 00       	call   80123f <ipc_recv>
  80005c:	89 c3                	mov    %eax,%ebx
		cprintf("%x got %d from %x\n", sys_getenvid(), i, who);
  80005e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800061:	e8 06 0b 00 00       	call   800b6c <sys_getenvid>
  800066:	57                   	push   %edi
  800067:	53                   	push   %ebx
  800068:	50                   	push   %eax
  800069:	68 36 24 80 00       	push   $0x802436
  80006e:	e8 5a 01 00 00       	call   8001cd <cprintf>
		if (i == 10)
  800073:	83 c4 20             	add    $0x20,%esp
  800076:	83 fb 0a             	cmp    $0xa,%ebx
  800079:	74 18                	je     800093 <umain+0x60>
			return;
		i++;
  80007b:	83 c3 01             	add    $0x1,%ebx
		ipc_send(who, i, 0, 0);
  80007e:	6a 00                	push   $0x0
  800080:	6a 00                	push   $0x0
  800082:	53                   	push   %ebx
  800083:	ff 75 e4             	pushl  -0x1c(%ebp)
  800086:	e8 22 12 00 00       	call   8012ad <ipc_send>
		if (i == 10)
  80008b:	83 c4 10             	add    $0x10,%esp
  80008e:	83 fb 0a             	cmp    $0xa,%ebx
  800091:	75 bc                	jne    80004f <umain+0x1c>
			return;
	}

}
  800093:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800096:	5b                   	pop    %ebx
  800097:	5e                   	pop    %esi
  800098:	5f                   	pop    %edi
  800099:	5d                   	pop    %ebp
  80009a:	c3                   	ret    
  80009b:	89 c3                	mov    %eax,%ebx
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  80009d:	e8 ca 0a 00 00       	call   800b6c <sys_getenvid>
  8000a2:	83 ec 04             	sub    $0x4,%esp
  8000a5:	53                   	push   %ebx
  8000a6:	50                   	push   %eax
  8000a7:	68 20 24 80 00       	push   $0x802420
  8000ac:	e8 1c 01 00 00       	call   8001cd <cprintf>
		ipc_send(who, 0, 0, 0);
  8000b1:	6a 00                	push   $0x0
  8000b3:	6a 00                	push   $0x0
  8000b5:	6a 00                	push   $0x0
  8000b7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000ba:	e8 ee 11 00 00       	call   8012ad <ipc_send>
  8000bf:	83 c4 20             	add    $0x20,%esp
  8000c2:	eb 88                	jmp    80004c <umain+0x19>

008000c4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000c4:	f3 0f 1e fb          	endbr32 
  8000c8:	55                   	push   %ebp
  8000c9:	89 e5                	mov    %esp,%ebp
  8000cb:	56                   	push   %esi
  8000cc:	53                   	push   %ebx
  8000cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000d0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8000d3:	e8 94 0a 00 00       	call   800b6c <sys_getenvid>
	if (id >= 0)
  8000d8:	85 c0                	test   %eax,%eax
  8000da:	78 12                	js     8000ee <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8000dc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000e1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000e4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e9:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000ee:	85 db                	test   %ebx,%ebx
  8000f0:	7e 07                	jle    8000f9 <libmain+0x35>
		binaryname = argv[0];
  8000f2:	8b 06                	mov    (%esi),%eax
  8000f4:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f9:	83 ec 08             	sub    $0x8,%esp
  8000fc:	56                   	push   %esi
  8000fd:	53                   	push   %ebx
  8000fe:	e8 30 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800103:	e8 0a 00 00 00       	call   800112 <exit>
}
  800108:	83 c4 10             	add    $0x10,%esp
  80010b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80010e:	5b                   	pop    %ebx
  80010f:	5e                   	pop    %esi
  800110:	5d                   	pop    %ebp
  800111:	c3                   	ret    

00800112 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800112:	f3 0f 1e fb          	endbr32 
  800116:	55                   	push   %ebp
  800117:	89 e5                	mov    %esp,%ebp
  800119:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80011c:	e8 21 14 00 00       	call   801542 <close_all>
	sys_env_destroy(0);
  800121:	83 ec 0c             	sub    $0xc,%esp
  800124:	6a 00                	push   $0x0
  800126:	e8 1b 0a 00 00       	call   800b46 <sys_env_destroy>
}
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	c9                   	leave  
  80012f:	c3                   	ret    

00800130 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800130:	f3 0f 1e fb          	endbr32 
  800134:	55                   	push   %ebp
  800135:	89 e5                	mov    %esp,%ebp
  800137:	53                   	push   %ebx
  800138:	83 ec 04             	sub    $0x4,%esp
  80013b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80013e:	8b 13                	mov    (%ebx),%edx
  800140:	8d 42 01             	lea    0x1(%edx),%eax
  800143:	89 03                	mov    %eax,(%ebx)
  800145:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800148:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80014c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800151:	74 09                	je     80015c <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800153:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800157:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80015a:	c9                   	leave  
  80015b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80015c:	83 ec 08             	sub    $0x8,%esp
  80015f:	68 ff 00 00 00       	push   $0xff
  800164:	8d 43 08             	lea    0x8(%ebx),%eax
  800167:	50                   	push   %eax
  800168:	e8 87 09 00 00       	call   800af4 <sys_cputs>
		b->idx = 0;
  80016d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800173:	83 c4 10             	add    $0x10,%esp
  800176:	eb db                	jmp    800153 <putch+0x23>

00800178 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800178:	f3 0f 1e fb          	endbr32 
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800185:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80018c:	00 00 00 
	b.cnt = 0;
  80018f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800196:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800199:	ff 75 0c             	pushl  0xc(%ebp)
  80019c:	ff 75 08             	pushl  0x8(%ebp)
  80019f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001a5:	50                   	push   %eax
  8001a6:	68 30 01 80 00       	push   $0x800130
  8001ab:	e8 80 01 00 00       	call   800330 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001b0:	83 c4 08             	add    $0x8,%esp
  8001b3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001b9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8001bf:	50                   	push   %eax
  8001c0:	e8 2f 09 00 00       	call   800af4 <sys_cputs>

	return b.cnt;
}
  8001c5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8001cb:	c9                   	leave  
  8001cc:	c3                   	ret    

008001cd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8001cd:	f3 0f 1e fb          	endbr32 
  8001d1:	55                   	push   %ebp
  8001d2:	89 e5                	mov    %esp,%ebp
  8001d4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8001d7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8001da:	50                   	push   %eax
  8001db:	ff 75 08             	pushl  0x8(%ebp)
  8001de:	e8 95 ff ff ff       	call   800178 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001e3:	c9                   	leave  
  8001e4:	c3                   	ret    

008001e5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001e5:	55                   	push   %ebp
  8001e6:	89 e5                	mov    %esp,%ebp
  8001e8:	57                   	push   %edi
  8001e9:	56                   	push   %esi
  8001ea:	53                   	push   %ebx
  8001eb:	83 ec 1c             	sub    $0x1c,%esp
  8001ee:	89 c7                	mov    %eax,%edi
  8001f0:	89 d6                	mov    %edx,%esi
  8001f2:	8b 45 08             	mov    0x8(%ebp),%eax
  8001f5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001f8:	89 d1                	mov    %edx,%ecx
  8001fa:	89 c2                	mov    %eax,%edx
  8001fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001ff:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800202:	8b 45 10             	mov    0x10(%ebp),%eax
  800205:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800208:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80020b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800212:	39 c2                	cmp    %eax,%edx
  800214:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800217:	72 3e                	jb     800257 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800219:	83 ec 0c             	sub    $0xc,%esp
  80021c:	ff 75 18             	pushl  0x18(%ebp)
  80021f:	83 eb 01             	sub    $0x1,%ebx
  800222:	53                   	push   %ebx
  800223:	50                   	push   %eax
  800224:	83 ec 08             	sub    $0x8,%esp
  800227:	ff 75 e4             	pushl  -0x1c(%ebp)
  80022a:	ff 75 e0             	pushl  -0x20(%ebp)
  80022d:	ff 75 dc             	pushl  -0x24(%ebp)
  800230:	ff 75 d8             	pushl  -0x28(%ebp)
  800233:	e8 78 1f 00 00       	call   8021b0 <__udivdi3>
  800238:	83 c4 18             	add    $0x18,%esp
  80023b:	52                   	push   %edx
  80023c:	50                   	push   %eax
  80023d:	89 f2                	mov    %esi,%edx
  80023f:	89 f8                	mov    %edi,%eax
  800241:	e8 9f ff ff ff       	call   8001e5 <printnum>
  800246:	83 c4 20             	add    $0x20,%esp
  800249:	eb 13                	jmp    80025e <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80024b:	83 ec 08             	sub    $0x8,%esp
  80024e:	56                   	push   %esi
  80024f:	ff 75 18             	pushl  0x18(%ebp)
  800252:	ff d7                	call   *%edi
  800254:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800257:	83 eb 01             	sub    $0x1,%ebx
  80025a:	85 db                	test   %ebx,%ebx
  80025c:	7f ed                	jg     80024b <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80025e:	83 ec 08             	sub    $0x8,%esp
  800261:	56                   	push   %esi
  800262:	83 ec 04             	sub    $0x4,%esp
  800265:	ff 75 e4             	pushl  -0x1c(%ebp)
  800268:	ff 75 e0             	pushl  -0x20(%ebp)
  80026b:	ff 75 dc             	pushl  -0x24(%ebp)
  80026e:	ff 75 d8             	pushl  -0x28(%ebp)
  800271:	e8 4a 20 00 00       	call   8022c0 <__umoddi3>
  800276:	83 c4 14             	add    $0x14,%esp
  800279:	0f be 80 53 24 80 00 	movsbl 0x802453(%eax),%eax
  800280:	50                   	push   %eax
  800281:	ff d7                	call   *%edi
}
  800283:	83 c4 10             	add    $0x10,%esp
  800286:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800289:	5b                   	pop    %ebx
  80028a:	5e                   	pop    %esi
  80028b:	5f                   	pop    %edi
  80028c:	5d                   	pop    %ebp
  80028d:	c3                   	ret    

0080028e <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80028e:	83 fa 01             	cmp    $0x1,%edx
  800291:	7f 13                	jg     8002a6 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800293:	85 d2                	test   %edx,%edx
  800295:	74 1c                	je     8002b3 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800297:	8b 10                	mov    (%eax),%edx
  800299:	8d 4a 04             	lea    0x4(%edx),%ecx
  80029c:	89 08                	mov    %ecx,(%eax)
  80029e:	8b 02                	mov    (%edx),%eax
  8002a0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002a5:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8002a6:	8b 10                	mov    (%eax),%edx
  8002a8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ab:	89 08                	mov    %ecx,(%eax)
  8002ad:	8b 02                	mov    (%edx),%eax
  8002af:	8b 52 04             	mov    0x4(%edx),%edx
  8002b2:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8002b3:	8b 10                	mov    (%eax),%edx
  8002b5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002b8:	89 08                	mov    %ecx,(%eax)
  8002ba:	8b 02                	mov    (%edx),%eax
  8002bc:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8002c1:	c3                   	ret    

008002c2 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002c2:	83 fa 01             	cmp    $0x1,%edx
  8002c5:	7f 0f                	jg     8002d6 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8002c7:	85 d2                	test   %edx,%edx
  8002c9:	74 18                	je     8002e3 <getint+0x21>
		return va_arg(*ap, long);
  8002cb:	8b 10                	mov    (%eax),%edx
  8002cd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002d0:	89 08                	mov    %ecx,(%eax)
  8002d2:	8b 02                	mov    (%edx),%eax
  8002d4:	99                   	cltd   
  8002d5:	c3                   	ret    
		return va_arg(*ap, long long);
  8002d6:	8b 10                	mov    (%eax),%edx
  8002d8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002db:	89 08                	mov    %ecx,(%eax)
  8002dd:	8b 02                	mov    (%edx),%eax
  8002df:	8b 52 04             	mov    0x4(%edx),%edx
  8002e2:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8002e3:	8b 10                	mov    (%eax),%edx
  8002e5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002e8:	89 08                	mov    %ecx,(%eax)
  8002ea:	8b 02                	mov    (%edx),%eax
  8002ec:	99                   	cltd   
}
  8002ed:	c3                   	ret    

008002ee <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002ee:	f3 0f 1e fb          	endbr32 
  8002f2:	55                   	push   %ebp
  8002f3:	89 e5                	mov    %esp,%ebp
  8002f5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002f8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002fc:	8b 10                	mov    (%eax),%edx
  8002fe:	3b 50 04             	cmp    0x4(%eax),%edx
  800301:	73 0a                	jae    80030d <sprintputch+0x1f>
		*b->buf++ = ch;
  800303:	8d 4a 01             	lea    0x1(%edx),%ecx
  800306:	89 08                	mov    %ecx,(%eax)
  800308:	8b 45 08             	mov    0x8(%ebp),%eax
  80030b:	88 02                	mov    %al,(%edx)
}
  80030d:	5d                   	pop    %ebp
  80030e:	c3                   	ret    

0080030f <printfmt>:
{
  80030f:	f3 0f 1e fb          	endbr32 
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800319:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80031c:	50                   	push   %eax
  80031d:	ff 75 10             	pushl  0x10(%ebp)
  800320:	ff 75 0c             	pushl  0xc(%ebp)
  800323:	ff 75 08             	pushl  0x8(%ebp)
  800326:	e8 05 00 00 00       	call   800330 <vprintfmt>
}
  80032b:	83 c4 10             	add    $0x10,%esp
  80032e:	c9                   	leave  
  80032f:	c3                   	ret    

00800330 <vprintfmt>:
{
  800330:	f3 0f 1e fb          	endbr32 
  800334:	55                   	push   %ebp
  800335:	89 e5                	mov    %esp,%ebp
  800337:	57                   	push   %edi
  800338:	56                   	push   %esi
  800339:	53                   	push   %ebx
  80033a:	83 ec 2c             	sub    $0x2c,%esp
  80033d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800340:	8b 75 0c             	mov    0xc(%ebp),%esi
  800343:	8b 7d 10             	mov    0x10(%ebp),%edi
  800346:	e9 86 02 00 00       	jmp    8005d1 <vprintfmt+0x2a1>
		padc = ' ';
  80034b:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80034f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800356:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80035d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800364:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800369:	8d 47 01             	lea    0x1(%edi),%eax
  80036c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80036f:	0f b6 17             	movzbl (%edi),%edx
  800372:	8d 42 dd             	lea    -0x23(%edx),%eax
  800375:	3c 55                	cmp    $0x55,%al
  800377:	0f 87 df 02 00 00    	ja     80065c <vprintfmt+0x32c>
  80037d:	0f b6 c0             	movzbl %al,%eax
  800380:	3e ff 24 85 a0 25 80 	notrack jmp *0x8025a0(,%eax,4)
  800387:	00 
  800388:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80038b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80038f:	eb d8                	jmp    800369 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800391:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800394:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800398:	eb cf                	jmp    800369 <vprintfmt+0x39>
  80039a:	0f b6 d2             	movzbl %dl,%edx
  80039d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a5:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003a8:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ab:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003af:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003b2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003b5:	83 f9 09             	cmp    $0x9,%ecx
  8003b8:	77 52                	ja     80040c <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  8003ba:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8003bd:	eb e9                	jmp    8003a8 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8003bf:	8b 45 14             	mov    0x14(%ebp),%eax
  8003c2:	8d 50 04             	lea    0x4(%eax),%edx
  8003c5:	89 55 14             	mov    %edx,0x14(%ebp)
  8003c8:	8b 00                	mov    (%eax),%eax
  8003ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003cd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8003d0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8003d4:	79 93                	jns    800369 <vprintfmt+0x39>
				width = precision, precision = -1;
  8003d6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8003d9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003dc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003e3:	eb 84                	jmp    800369 <vprintfmt+0x39>
  8003e5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003e8:	85 c0                	test   %eax,%eax
  8003ea:	ba 00 00 00 00       	mov    $0x0,%edx
  8003ef:	0f 49 d0             	cmovns %eax,%edx
  8003f2:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003f8:	e9 6c ff ff ff       	jmp    800369 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003fd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800400:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800407:	e9 5d ff ff ff       	jmp    800369 <vprintfmt+0x39>
  80040c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80040f:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800412:	eb bc                	jmp    8003d0 <vprintfmt+0xa0>
			lflag++;
  800414:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800417:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80041a:	e9 4a ff ff ff       	jmp    800369 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80041f:	8b 45 14             	mov    0x14(%ebp),%eax
  800422:	8d 50 04             	lea    0x4(%eax),%edx
  800425:	89 55 14             	mov    %edx,0x14(%ebp)
  800428:	83 ec 08             	sub    $0x8,%esp
  80042b:	56                   	push   %esi
  80042c:	ff 30                	pushl  (%eax)
  80042e:	ff d3                	call   *%ebx
			break;
  800430:	83 c4 10             	add    $0x10,%esp
  800433:	e9 96 01 00 00       	jmp    8005ce <vprintfmt+0x29e>
			err = va_arg(ap, int);
  800438:	8b 45 14             	mov    0x14(%ebp),%eax
  80043b:	8d 50 04             	lea    0x4(%eax),%edx
  80043e:	89 55 14             	mov    %edx,0x14(%ebp)
  800441:	8b 00                	mov    (%eax),%eax
  800443:	99                   	cltd   
  800444:	31 d0                	xor    %edx,%eax
  800446:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800448:	83 f8 0f             	cmp    $0xf,%eax
  80044b:	7f 20                	jg     80046d <vprintfmt+0x13d>
  80044d:	8b 14 85 00 27 80 00 	mov    0x802700(,%eax,4),%edx
  800454:	85 d2                	test   %edx,%edx
  800456:	74 15                	je     80046d <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  800458:	52                   	push   %edx
  800459:	68 29 2a 80 00       	push   $0x802a29
  80045e:	56                   	push   %esi
  80045f:	53                   	push   %ebx
  800460:	e8 aa fe ff ff       	call   80030f <printfmt>
  800465:	83 c4 10             	add    $0x10,%esp
  800468:	e9 61 01 00 00       	jmp    8005ce <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  80046d:	50                   	push   %eax
  80046e:	68 6b 24 80 00       	push   $0x80246b
  800473:	56                   	push   %esi
  800474:	53                   	push   %ebx
  800475:	e8 95 fe ff ff       	call   80030f <printfmt>
  80047a:	83 c4 10             	add    $0x10,%esp
  80047d:	e9 4c 01 00 00       	jmp    8005ce <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  800482:	8b 45 14             	mov    0x14(%ebp),%eax
  800485:	8d 50 04             	lea    0x4(%eax),%edx
  800488:	89 55 14             	mov    %edx,0x14(%ebp)
  80048b:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  80048d:	85 c9                	test   %ecx,%ecx
  80048f:	b8 64 24 80 00       	mov    $0x802464,%eax
  800494:	0f 45 c1             	cmovne %ecx,%eax
  800497:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80049a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80049e:	7e 06                	jle    8004a6 <vprintfmt+0x176>
  8004a0:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004a4:	75 0d                	jne    8004b3 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a6:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004a9:	89 c7                	mov    %eax,%edi
  8004ab:	03 45 e0             	add    -0x20(%ebp),%eax
  8004ae:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004b1:	eb 57                	jmp    80050a <vprintfmt+0x1da>
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	ff 75 d8             	pushl  -0x28(%ebp)
  8004b9:	ff 75 cc             	pushl  -0x34(%ebp)
  8004bc:	e8 4f 02 00 00       	call   800710 <strnlen>
  8004c1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004c4:	29 c2                	sub    %eax,%edx
  8004c6:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004c9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8004cc:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8004d0:	89 5d 08             	mov    %ebx,0x8(%ebp)
  8004d3:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8004d5:	85 db                	test   %ebx,%ebx
  8004d7:	7e 10                	jle    8004e9 <vprintfmt+0x1b9>
					putch(padc, putdat);
  8004d9:	83 ec 08             	sub    $0x8,%esp
  8004dc:	56                   	push   %esi
  8004dd:	57                   	push   %edi
  8004de:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e1:	83 eb 01             	sub    $0x1,%ebx
  8004e4:	83 c4 10             	add    $0x10,%esp
  8004e7:	eb ec                	jmp    8004d5 <vprintfmt+0x1a5>
  8004e9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004ec:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004ef:	85 d2                	test   %edx,%edx
  8004f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8004f6:	0f 49 c2             	cmovns %edx,%eax
  8004f9:	29 c2                	sub    %eax,%edx
  8004fb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004fe:	eb a6                	jmp    8004a6 <vprintfmt+0x176>
					putch(ch, putdat);
  800500:	83 ec 08             	sub    $0x8,%esp
  800503:	56                   	push   %esi
  800504:	52                   	push   %edx
  800505:	ff d3                	call   *%ebx
  800507:	83 c4 10             	add    $0x10,%esp
  80050a:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80050d:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80050f:	83 c7 01             	add    $0x1,%edi
  800512:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800516:	0f be d0             	movsbl %al,%edx
  800519:	85 d2                	test   %edx,%edx
  80051b:	74 42                	je     80055f <vprintfmt+0x22f>
  80051d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800521:	78 06                	js     800529 <vprintfmt+0x1f9>
  800523:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800527:	78 1e                	js     800547 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  800529:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80052d:	74 d1                	je     800500 <vprintfmt+0x1d0>
  80052f:	0f be c0             	movsbl %al,%eax
  800532:	83 e8 20             	sub    $0x20,%eax
  800535:	83 f8 5e             	cmp    $0x5e,%eax
  800538:	76 c6                	jbe    800500 <vprintfmt+0x1d0>
					putch('?', putdat);
  80053a:	83 ec 08             	sub    $0x8,%esp
  80053d:	56                   	push   %esi
  80053e:	6a 3f                	push   $0x3f
  800540:	ff d3                	call   *%ebx
  800542:	83 c4 10             	add    $0x10,%esp
  800545:	eb c3                	jmp    80050a <vprintfmt+0x1da>
  800547:	89 cf                	mov    %ecx,%edi
  800549:	eb 0e                	jmp    800559 <vprintfmt+0x229>
				putch(' ', putdat);
  80054b:	83 ec 08             	sub    $0x8,%esp
  80054e:	56                   	push   %esi
  80054f:	6a 20                	push   $0x20
  800551:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800553:	83 ef 01             	sub    $0x1,%edi
  800556:	83 c4 10             	add    $0x10,%esp
  800559:	85 ff                	test   %edi,%edi
  80055b:	7f ee                	jg     80054b <vprintfmt+0x21b>
  80055d:	eb 6f                	jmp    8005ce <vprintfmt+0x29e>
  80055f:	89 cf                	mov    %ecx,%edi
  800561:	eb f6                	jmp    800559 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  800563:	89 ca                	mov    %ecx,%edx
  800565:	8d 45 14             	lea    0x14(%ebp),%eax
  800568:	e8 55 fd ff ff       	call   8002c2 <getint>
  80056d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800570:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800573:	85 d2                	test   %edx,%edx
  800575:	78 0b                	js     800582 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  800577:	89 d1                	mov    %edx,%ecx
  800579:	89 c2                	mov    %eax,%edx
			base = 10;
  80057b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800580:	eb 32                	jmp    8005b4 <vprintfmt+0x284>
				putch('-', putdat);
  800582:	83 ec 08             	sub    $0x8,%esp
  800585:	56                   	push   %esi
  800586:	6a 2d                	push   $0x2d
  800588:	ff d3                	call   *%ebx
				num = -(long long) num;
  80058a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80058d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800590:	f7 da                	neg    %edx
  800592:	83 d1 00             	adc    $0x0,%ecx
  800595:	f7 d9                	neg    %ecx
  800597:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80059a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80059f:	eb 13                	jmp    8005b4 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8005a1:	89 ca                	mov    %ecx,%edx
  8005a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8005a6:	e8 e3 fc ff ff       	call   80028e <getuint>
  8005ab:	89 d1                	mov    %edx,%ecx
  8005ad:	89 c2                	mov    %eax,%edx
			base = 10;
  8005af:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005b4:	83 ec 0c             	sub    $0xc,%esp
  8005b7:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005bb:	57                   	push   %edi
  8005bc:	ff 75 e0             	pushl  -0x20(%ebp)
  8005bf:	50                   	push   %eax
  8005c0:	51                   	push   %ecx
  8005c1:	52                   	push   %edx
  8005c2:	89 f2                	mov    %esi,%edx
  8005c4:	89 d8                	mov    %ebx,%eax
  8005c6:	e8 1a fc ff ff       	call   8001e5 <printnum>
			break;
  8005cb:	83 c4 20             	add    $0x20,%esp
{
  8005ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8005d1:	83 c7 01             	add    $0x1,%edi
  8005d4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005d8:	83 f8 25             	cmp    $0x25,%eax
  8005db:	0f 84 6a fd ff ff    	je     80034b <vprintfmt+0x1b>
			if (ch == '\0')
  8005e1:	85 c0                	test   %eax,%eax
  8005e3:	0f 84 93 00 00 00    	je     80067c <vprintfmt+0x34c>
			putch(ch, putdat);
  8005e9:	83 ec 08             	sub    $0x8,%esp
  8005ec:	56                   	push   %esi
  8005ed:	50                   	push   %eax
  8005ee:	ff d3                	call   *%ebx
  8005f0:	83 c4 10             	add    $0x10,%esp
  8005f3:	eb dc                	jmp    8005d1 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  8005f5:	89 ca                	mov    %ecx,%edx
  8005f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fa:	e8 8f fc ff ff       	call   80028e <getuint>
  8005ff:	89 d1                	mov    %edx,%ecx
  800601:	89 c2                	mov    %eax,%edx
			base = 8;
  800603:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800608:	eb aa                	jmp    8005b4 <vprintfmt+0x284>
			putch('0', putdat);
  80060a:	83 ec 08             	sub    $0x8,%esp
  80060d:	56                   	push   %esi
  80060e:	6a 30                	push   $0x30
  800610:	ff d3                	call   *%ebx
			putch('x', putdat);
  800612:	83 c4 08             	add    $0x8,%esp
  800615:	56                   	push   %esi
  800616:	6a 78                	push   $0x78
  800618:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  80061a:	8b 45 14             	mov    0x14(%ebp),%eax
  80061d:	8d 50 04             	lea    0x4(%eax),%edx
  800620:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800623:	8b 10                	mov    (%eax),%edx
  800625:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80062a:	83 c4 10             	add    $0x10,%esp
			base = 16;
  80062d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800632:	eb 80                	jmp    8005b4 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800634:	89 ca                	mov    %ecx,%edx
  800636:	8d 45 14             	lea    0x14(%ebp),%eax
  800639:	e8 50 fc ff ff       	call   80028e <getuint>
  80063e:	89 d1                	mov    %edx,%ecx
  800640:	89 c2                	mov    %eax,%edx
			base = 16;
  800642:	b8 10 00 00 00       	mov    $0x10,%eax
  800647:	e9 68 ff ff ff       	jmp    8005b4 <vprintfmt+0x284>
			putch(ch, putdat);
  80064c:	83 ec 08             	sub    $0x8,%esp
  80064f:	56                   	push   %esi
  800650:	6a 25                	push   $0x25
  800652:	ff d3                	call   *%ebx
			break;
  800654:	83 c4 10             	add    $0x10,%esp
  800657:	e9 72 ff ff ff       	jmp    8005ce <vprintfmt+0x29e>
			putch('%', putdat);
  80065c:	83 ec 08             	sub    $0x8,%esp
  80065f:	56                   	push   %esi
  800660:	6a 25                	push   $0x25
  800662:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800664:	83 c4 10             	add    $0x10,%esp
  800667:	89 f8                	mov    %edi,%eax
  800669:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80066d:	74 05                	je     800674 <vprintfmt+0x344>
  80066f:	83 e8 01             	sub    $0x1,%eax
  800672:	eb f5                	jmp    800669 <vprintfmt+0x339>
  800674:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800677:	e9 52 ff ff ff       	jmp    8005ce <vprintfmt+0x29e>
}
  80067c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80067f:	5b                   	pop    %ebx
  800680:	5e                   	pop    %esi
  800681:	5f                   	pop    %edi
  800682:	5d                   	pop    %ebp
  800683:	c3                   	ret    

00800684 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800684:	f3 0f 1e fb          	endbr32 
  800688:	55                   	push   %ebp
  800689:	89 e5                	mov    %esp,%ebp
  80068b:	83 ec 18             	sub    $0x18,%esp
  80068e:	8b 45 08             	mov    0x8(%ebp),%eax
  800691:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800694:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800697:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80069b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80069e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006a5:	85 c0                	test   %eax,%eax
  8006a7:	74 26                	je     8006cf <vsnprintf+0x4b>
  8006a9:	85 d2                	test   %edx,%edx
  8006ab:	7e 22                	jle    8006cf <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006ad:	ff 75 14             	pushl  0x14(%ebp)
  8006b0:	ff 75 10             	pushl  0x10(%ebp)
  8006b3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006b6:	50                   	push   %eax
  8006b7:	68 ee 02 80 00       	push   $0x8002ee
  8006bc:	e8 6f fc ff ff       	call   800330 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8006c1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8006c4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8006c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006ca:	83 c4 10             	add    $0x10,%esp
}
  8006cd:	c9                   	leave  
  8006ce:	c3                   	ret    
		return -E_INVAL;
  8006cf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006d4:	eb f7                	jmp    8006cd <vsnprintf+0x49>

008006d6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8006d6:	f3 0f 1e fb          	endbr32 
  8006da:	55                   	push   %ebp
  8006db:	89 e5                	mov    %esp,%ebp
  8006dd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006e0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006e3:	50                   	push   %eax
  8006e4:	ff 75 10             	pushl  0x10(%ebp)
  8006e7:	ff 75 0c             	pushl  0xc(%ebp)
  8006ea:	ff 75 08             	pushl  0x8(%ebp)
  8006ed:	e8 92 ff ff ff       	call   800684 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006f2:	c9                   	leave  
  8006f3:	c3                   	ret    

008006f4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006f4:	f3 0f 1e fb          	endbr32 
  8006f8:	55                   	push   %ebp
  8006f9:	89 e5                	mov    %esp,%ebp
  8006fb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006fe:	b8 00 00 00 00       	mov    $0x0,%eax
  800703:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800707:	74 05                	je     80070e <strlen+0x1a>
		n++;
  800709:	83 c0 01             	add    $0x1,%eax
  80070c:	eb f5                	jmp    800703 <strlen+0xf>
	return n;
}
  80070e:	5d                   	pop    %ebp
  80070f:	c3                   	ret    

00800710 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800710:	f3 0f 1e fb          	endbr32 
  800714:	55                   	push   %ebp
  800715:	89 e5                	mov    %esp,%ebp
  800717:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80071a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80071d:	b8 00 00 00 00       	mov    $0x0,%eax
  800722:	39 d0                	cmp    %edx,%eax
  800724:	74 0d                	je     800733 <strnlen+0x23>
  800726:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80072a:	74 05                	je     800731 <strnlen+0x21>
		n++;
  80072c:	83 c0 01             	add    $0x1,%eax
  80072f:	eb f1                	jmp    800722 <strnlen+0x12>
  800731:	89 c2                	mov    %eax,%edx
	return n;
}
  800733:	89 d0                	mov    %edx,%eax
  800735:	5d                   	pop    %ebp
  800736:	c3                   	ret    

00800737 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800737:	f3 0f 1e fb          	endbr32 
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	53                   	push   %ebx
  80073f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800742:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800745:	b8 00 00 00 00       	mov    $0x0,%eax
  80074a:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80074e:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800751:	83 c0 01             	add    $0x1,%eax
  800754:	84 d2                	test   %dl,%dl
  800756:	75 f2                	jne    80074a <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800758:	89 c8                	mov    %ecx,%eax
  80075a:	5b                   	pop    %ebx
  80075b:	5d                   	pop    %ebp
  80075c:	c3                   	ret    

0080075d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80075d:	f3 0f 1e fb          	endbr32 
  800761:	55                   	push   %ebp
  800762:	89 e5                	mov    %esp,%ebp
  800764:	53                   	push   %ebx
  800765:	83 ec 10             	sub    $0x10,%esp
  800768:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80076b:	53                   	push   %ebx
  80076c:	e8 83 ff ff ff       	call   8006f4 <strlen>
  800771:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800774:	ff 75 0c             	pushl  0xc(%ebp)
  800777:	01 d8                	add    %ebx,%eax
  800779:	50                   	push   %eax
  80077a:	e8 b8 ff ff ff       	call   800737 <strcpy>
	return dst;
}
  80077f:	89 d8                	mov    %ebx,%eax
  800781:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800784:	c9                   	leave  
  800785:	c3                   	ret    

00800786 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800786:	f3 0f 1e fb          	endbr32 
  80078a:	55                   	push   %ebp
  80078b:	89 e5                	mov    %esp,%ebp
  80078d:	56                   	push   %esi
  80078e:	53                   	push   %ebx
  80078f:	8b 75 08             	mov    0x8(%ebp),%esi
  800792:	8b 55 0c             	mov    0xc(%ebp),%edx
  800795:	89 f3                	mov    %esi,%ebx
  800797:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80079a:	89 f0                	mov    %esi,%eax
  80079c:	39 d8                	cmp    %ebx,%eax
  80079e:	74 11                	je     8007b1 <strncpy+0x2b>
		*dst++ = *src;
  8007a0:	83 c0 01             	add    $0x1,%eax
  8007a3:	0f b6 0a             	movzbl (%edx),%ecx
  8007a6:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007a9:	80 f9 01             	cmp    $0x1,%cl
  8007ac:	83 da ff             	sbb    $0xffffffff,%edx
  8007af:	eb eb                	jmp    80079c <strncpy+0x16>
	}
	return ret;
}
  8007b1:	89 f0                	mov    %esi,%eax
  8007b3:	5b                   	pop    %ebx
  8007b4:	5e                   	pop    %esi
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007b7:	f3 0f 1e fb          	endbr32 
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	56                   	push   %esi
  8007bf:	53                   	push   %ebx
  8007c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8007c3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8007c6:	8b 55 10             	mov    0x10(%ebp),%edx
  8007c9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8007cb:	85 d2                	test   %edx,%edx
  8007cd:	74 21                	je     8007f0 <strlcpy+0x39>
  8007cf:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8007d3:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8007d5:	39 c2                	cmp    %eax,%edx
  8007d7:	74 14                	je     8007ed <strlcpy+0x36>
  8007d9:	0f b6 19             	movzbl (%ecx),%ebx
  8007dc:	84 db                	test   %bl,%bl
  8007de:	74 0b                	je     8007eb <strlcpy+0x34>
			*dst++ = *src++;
  8007e0:	83 c1 01             	add    $0x1,%ecx
  8007e3:	83 c2 01             	add    $0x1,%edx
  8007e6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007e9:	eb ea                	jmp    8007d5 <strlcpy+0x1e>
  8007eb:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007ed:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007f0:	29 f0                	sub    %esi,%eax
}
  8007f2:	5b                   	pop    %ebx
  8007f3:	5e                   	pop    %esi
  8007f4:	5d                   	pop    %ebp
  8007f5:	c3                   	ret    

008007f6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007f6:	f3 0f 1e fb          	endbr32 
  8007fa:	55                   	push   %ebp
  8007fb:	89 e5                	mov    %esp,%ebp
  8007fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800800:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800803:	0f b6 01             	movzbl (%ecx),%eax
  800806:	84 c0                	test   %al,%al
  800808:	74 0c                	je     800816 <strcmp+0x20>
  80080a:	3a 02                	cmp    (%edx),%al
  80080c:	75 08                	jne    800816 <strcmp+0x20>
		p++, q++;
  80080e:	83 c1 01             	add    $0x1,%ecx
  800811:	83 c2 01             	add    $0x1,%edx
  800814:	eb ed                	jmp    800803 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800816:	0f b6 c0             	movzbl %al,%eax
  800819:	0f b6 12             	movzbl (%edx),%edx
  80081c:	29 d0                	sub    %edx,%eax
}
  80081e:	5d                   	pop    %ebp
  80081f:	c3                   	ret    

00800820 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800820:	f3 0f 1e fb          	endbr32 
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	53                   	push   %ebx
  800828:	8b 45 08             	mov    0x8(%ebp),%eax
  80082b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80082e:	89 c3                	mov    %eax,%ebx
  800830:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800833:	eb 06                	jmp    80083b <strncmp+0x1b>
		n--, p++, q++;
  800835:	83 c0 01             	add    $0x1,%eax
  800838:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80083b:	39 d8                	cmp    %ebx,%eax
  80083d:	74 16                	je     800855 <strncmp+0x35>
  80083f:	0f b6 08             	movzbl (%eax),%ecx
  800842:	84 c9                	test   %cl,%cl
  800844:	74 04                	je     80084a <strncmp+0x2a>
  800846:	3a 0a                	cmp    (%edx),%cl
  800848:	74 eb                	je     800835 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80084a:	0f b6 00             	movzbl (%eax),%eax
  80084d:	0f b6 12             	movzbl (%edx),%edx
  800850:	29 d0                	sub    %edx,%eax
}
  800852:	5b                   	pop    %ebx
  800853:	5d                   	pop    %ebp
  800854:	c3                   	ret    
		return 0;
  800855:	b8 00 00 00 00       	mov    $0x0,%eax
  80085a:	eb f6                	jmp    800852 <strncmp+0x32>

0080085c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80085c:	f3 0f 1e fb          	endbr32 
  800860:	55                   	push   %ebp
  800861:	89 e5                	mov    %esp,%ebp
  800863:	8b 45 08             	mov    0x8(%ebp),%eax
  800866:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80086a:	0f b6 10             	movzbl (%eax),%edx
  80086d:	84 d2                	test   %dl,%dl
  80086f:	74 09                	je     80087a <strchr+0x1e>
		if (*s == c)
  800871:	38 ca                	cmp    %cl,%dl
  800873:	74 0a                	je     80087f <strchr+0x23>
	for (; *s; s++)
  800875:	83 c0 01             	add    $0x1,%eax
  800878:	eb f0                	jmp    80086a <strchr+0xe>
			return (char *) s;
	return 0;
  80087a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80087f:	5d                   	pop    %ebp
  800880:	c3                   	ret    

00800881 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800881:	f3 0f 1e fb          	endbr32 
  800885:	55                   	push   %ebp
  800886:	89 e5                	mov    %esp,%ebp
  800888:	8b 45 08             	mov    0x8(%ebp),%eax
  80088b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80088f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800892:	38 ca                	cmp    %cl,%dl
  800894:	74 09                	je     80089f <strfind+0x1e>
  800896:	84 d2                	test   %dl,%dl
  800898:	74 05                	je     80089f <strfind+0x1e>
	for (; *s; s++)
  80089a:	83 c0 01             	add    $0x1,%eax
  80089d:	eb f0                	jmp    80088f <strfind+0xe>
			break;
	return (char *) s;
}
  80089f:	5d                   	pop    %ebp
  8008a0:	c3                   	ret    

008008a1 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008a1:	f3 0f 1e fb          	endbr32 
  8008a5:	55                   	push   %ebp
  8008a6:	89 e5                	mov    %esp,%ebp
  8008a8:	57                   	push   %edi
  8008a9:	56                   	push   %esi
  8008aa:	53                   	push   %ebx
  8008ab:	8b 55 08             	mov    0x8(%ebp),%edx
  8008ae:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8008b1:	85 c9                	test   %ecx,%ecx
  8008b3:	74 33                	je     8008e8 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008b5:	89 d0                	mov    %edx,%eax
  8008b7:	09 c8                	or     %ecx,%eax
  8008b9:	a8 03                	test   $0x3,%al
  8008bb:	75 23                	jne    8008e0 <memset+0x3f>
		c &= 0xFF;
  8008bd:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008c1:	89 d8                	mov    %ebx,%eax
  8008c3:	c1 e0 08             	shl    $0x8,%eax
  8008c6:	89 df                	mov    %ebx,%edi
  8008c8:	c1 e7 18             	shl    $0x18,%edi
  8008cb:	89 de                	mov    %ebx,%esi
  8008cd:	c1 e6 10             	shl    $0x10,%esi
  8008d0:	09 f7                	or     %esi,%edi
  8008d2:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  8008d4:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8008d7:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  8008d9:	89 d7                	mov    %edx,%edi
  8008db:	fc                   	cld    
  8008dc:	f3 ab                	rep stos %eax,%es:(%edi)
  8008de:	eb 08                	jmp    8008e8 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008e0:	89 d7                	mov    %edx,%edi
  8008e2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008e5:	fc                   	cld    
  8008e6:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  8008e8:	89 d0                	mov    %edx,%eax
  8008ea:	5b                   	pop    %ebx
  8008eb:	5e                   	pop    %esi
  8008ec:	5f                   	pop    %edi
  8008ed:	5d                   	pop    %ebp
  8008ee:	c3                   	ret    

008008ef <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008ef:	f3 0f 1e fb          	endbr32 
  8008f3:	55                   	push   %ebp
  8008f4:	89 e5                	mov    %esp,%ebp
  8008f6:	57                   	push   %edi
  8008f7:	56                   	push   %esi
  8008f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8008fb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008fe:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800901:	39 c6                	cmp    %eax,%esi
  800903:	73 32                	jae    800937 <memmove+0x48>
  800905:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800908:	39 c2                	cmp    %eax,%edx
  80090a:	76 2b                	jbe    800937 <memmove+0x48>
		s += n;
		d += n;
  80090c:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80090f:	89 fe                	mov    %edi,%esi
  800911:	09 ce                	or     %ecx,%esi
  800913:	09 d6                	or     %edx,%esi
  800915:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80091b:	75 0e                	jne    80092b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80091d:	83 ef 04             	sub    $0x4,%edi
  800920:	8d 72 fc             	lea    -0x4(%edx),%esi
  800923:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800926:	fd                   	std    
  800927:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800929:	eb 09                	jmp    800934 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80092b:	83 ef 01             	sub    $0x1,%edi
  80092e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800931:	fd                   	std    
  800932:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800934:	fc                   	cld    
  800935:	eb 1a                	jmp    800951 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800937:	89 c2                	mov    %eax,%edx
  800939:	09 ca                	or     %ecx,%edx
  80093b:	09 f2                	or     %esi,%edx
  80093d:	f6 c2 03             	test   $0x3,%dl
  800940:	75 0a                	jne    80094c <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800942:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800945:	89 c7                	mov    %eax,%edi
  800947:	fc                   	cld    
  800948:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80094a:	eb 05                	jmp    800951 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  80094c:	89 c7                	mov    %eax,%edi
  80094e:	fc                   	cld    
  80094f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800951:	5e                   	pop    %esi
  800952:	5f                   	pop    %edi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800955:	f3 0f 1e fb          	endbr32 
  800959:	55                   	push   %ebp
  80095a:	89 e5                	mov    %esp,%ebp
  80095c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  80095f:	ff 75 10             	pushl  0x10(%ebp)
  800962:	ff 75 0c             	pushl  0xc(%ebp)
  800965:	ff 75 08             	pushl  0x8(%ebp)
  800968:	e8 82 ff ff ff       	call   8008ef <memmove>
}
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80096f:	f3 0f 1e fb          	endbr32 
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	56                   	push   %esi
  800977:	53                   	push   %ebx
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80097e:	89 c6                	mov    %eax,%esi
  800980:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800983:	39 f0                	cmp    %esi,%eax
  800985:	74 1c                	je     8009a3 <memcmp+0x34>
		if (*s1 != *s2)
  800987:	0f b6 08             	movzbl (%eax),%ecx
  80098a:	0f b6 1a             	movzbl (%edx),%ebx
  80098d:	38 d9                	cmp    %bl,%cl
  80098f:	75 08                	jne    800999 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800991:	83 c0 01             	add    $0x1,%eax
  800994:	83 c2 01             	add    $0x1,%edx
  800997:	eb ea                	jmp    800983 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800999:	0f b6 c1             	movzbl %cl,%eax
  80099c:	0f b6 db             	movzbl %bl,%ebx
  80099f:	29 d8                	sub    %ebx,%eax
  8009a1:	eb 05                	jmp    8009a8 <memcmp+0x39>
	}

	return 0;
  8009a3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009a8:	5b                   	pop    %ebx
  8009a9:	5e                   	pop    %esi
  8009aa:	5d                   	pop    %ebp
  8009ab:	c3                   	ret    

008009ac <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ac:	f3 0f 1e fb          	endbr32 
  8009b0:	55                   	push   %ebp
  8009b1:	89 e5                	mov    %esp,%ebp
  8009b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009b9:	89 c2                	mov    %eax,%edx
  8009bb:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  8009be:	39 d0                	cmp    %edx,%eax
  8009c0:	73 09                	jae    8009cb <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  8009c2:	38 08                	cmp    %cl,(%eax)
  8009c4:	74 05                	je     8009cb <memfind+0x1f>
	for (; s < ends; s++)
  8009c6:	83 c0 01             	add    $0x1,%eax
  8009c9:	eb f3                	jmp    8009be <memfind+0x12>
			break;
	return (void *) s;
}
  8009cb:	5d                   	pop    %ebp
  8009cc:	c3                   	ret    

008009cd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  8009cd:	f3 0f 1e fb          	endbr32 
  8009d1:	55                   	push   %ebp
  8009d2:	89 e5                	mov    %esp,%ebp
  8009d4:	57                   	push   %edi
  8009d5:	56                   	push   %esi
  8009d6:	53                   	push   %ebx
  8009d7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009da:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  8009dd:	eb 03                	jmp    8009e2 <strtol+0x15>
		s++;
  8009df:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8009e2:	0f b6 01             	movzbl (%ecx),%eax
  8009e5:	3c 20                	cmp    $0x20,%al
  8009e7:	74 f6                	je     8009df <strtol+0x12>
  8009e9:	3c 09                	cmp    $0x9,%al
  8009eb:	74 f2                	je     8009df <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  8009ed:	3c 2b                	cmp    $0x2b,%al
  8009ef:	74 2a                	je     800a1b <strtol+0x4e>
	int neg = 0;
  8009f1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009f6:	3c 2d                	cmp    $0x2d,%al
  8009f8:	74 2b                	je     800a25 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009fa:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a00:	75 0f                	jne    800a11 <strtol+0x44>
  800a02:	80 39 30             	cmpb   $0x30,(%ecx)
  800a05:	74 28                	je     800a2f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a07:	85 db                	test   %ebx,%ebx
  800a09:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a0e:	0f 44 d8             	cmove  %eax,%ebx
  800a11:	b8 00 00 00 00       	mov    $0x0,%eax
  800a16:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a19:	eb 46                	jmp    800a61 <strtol+0x94>
		s++;
  800a1b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a1e:	bf 00 00 00 00       	mov    $0x0,%edi
  800a23:	eb d5                	jmp    8009fa <strtol+0x2d>
		s++, neg = 1;
  800a25:	83 c1 01             	add    $0x1,%ecx
  800a28:	bf 01 00 00 00       	mov    $0x1,%edi
  800a2d:	eb cb                	jmp    8009fa <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a2f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a33:	74 0e                	je     800a43 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a35:	85 db                	test   %ebx,%ebx
  800a37:	75 d8                	jne    800a11 <strtol+0x44>
		s++, base = 8;
  800a39:	83 c1 01             	add    $0x1,%ecx
  800a3c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a41:	eb ce                	jmp    800a11 <strtol+0x44>
		s += 2, base = 16;
  800a43:	83 c1 02             	add    $0x2,%ecx
  800a46:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a4b:	eb c4                	jmp    800a11 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a4d:	0f be d2             	movsbl %dl,%edx
  800a50:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a53:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a56:	7d 3a                	jge    800a92 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a58:	83 c1 01             	add    $0x1,%ecx
  800a5b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a5f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a61:	0f b6 11             	movzbl (%ecx),%edx
  800a64:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a67:	89 f3                	mov    %esi,%ebx
  800a69:	80 fb 09             	cmp    $0x9,%bl
  800a6c:	76 df                	jbe    800a4d <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800a6e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a71:	89 f3                	mov    %esi,%ebx
  800a73:	80 fb 19             	cmp    $0x19,%bl
  800a76:	77 08                	ja     800a80 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a78:	0f be d2             	movsbl %dl,%edx
  800a7b:	83 ea 57             	sub    $0x57,%edx
  800a7e:	eb d3                	jmp    800a53 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800a80:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a83:	89 f3                	mov    %esi,%ebx
  800a85:	80 fb 19             	cmp    $0x19,%bl
  800a88:	77 08                	ja     800a92 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a8a:	0f be d2             	movsbl %dl,%edx
  800a8d:	83 ea 37             	sub    $0x37,%edx
  800a90:	eb c1                	jmp    800a53 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a92:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a96:	74 05                	je     800a9d <strtol+0xd0>
		*endptr = (char *) s;
  800a98:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a9b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a9d:	89 c2                	mov    %eax,%edx
  800a9f:	f7 da                	neg    %edx
  800aa1:	85 ff                	test   %edi,%edi
  800aa3:	0f 45 c2             	cmovne %edx,%eax
}
  800aa6:	5b                   	pop    %ebx
  800aa7:	5e                   	pop    %esi
  800aa8:	5f                   	pop    %edi
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	57                   	push   %edi
  800aaf:	56                   	push   %esi
  800ab0:	53                   	push   %ebx
  800ab1:	83 ec 1c             	sub    $0x1c,%esp
  800ab4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ab7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800aba:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800abc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800abf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800ac2:	8b 7d 10             	mov    0x10(%ebp),%edi
  800ac5:	8b 75 14             	mov    0x14(%ebp),%esi
  800ac8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800aca:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800ace:	74 04                	je     800ad4 <syscall+0x29>
  800ad0:	85 c0                	test   %eax,%eax
  800ad2:	7f 08                	jg     800adc <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800ad4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ad7:	5b                   	pop    %ebx
  800ad8:	5e                   	pop    %esi
  800ad9:	5f                   	pop    %edi
  800ada:	5d                   	pop    %ebp
  800adb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800adc:	83 ec 0c             	sub    $0xc,%esp
  800adf:	50                   	push   %eax
  800ae0:	ff 75 e0             	pushl  -0x20(%ebp)
  800ae3:	68 5f 27 80 00       	push   $0x80275f
  800ae8:	6a 23                	push   $0x23
  800aea:	68 7c 27 80 00       	push   $0x80277c
  800aef:	e8 a4 15 00 00       	call   802098 <_panic>

00800af4 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800af4:	f3 0f 1e fb          	endbr32 
  800af8:	55                   	push   %ebp
  800af9:	89 e5                	mov    %esp,%ebp
  800afb:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800afe:	6a 00                	push   $0x0
  800b00:	6a 00                	push   $0x0
  800b02:	6a 00                	push   $0x0
  800b04:	ff 75 0c             	pushl  0xc(%ebp)
  800b07:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b0a:	ba 00 00 00 00       	mov    $0x0,%edx
  800b0f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b14:	e8 92 ff ff ff       	call   800aab <syscall>
}
  800b19:	83 c4 10             	add    $0x10,%esp
  800b1c:	c9                   	leave  
  800b1d:	c3                   	ret    

00800b1e <sys_cgetc>:

int
sys_cgetc(void)
{
  800b1e:	f3 0f 1e fb          	endbr32 
  800b22:	55                   	push   %ebp
  800b23:	89 e5                	mov    %esp,%ebp
  800b25:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b28:	6a 00                	push   $0x0
  800b2a:	6a 00                	push   $0x0
  800b2c:	6a 00                	push   $0x0
  800b2e:	6a 00                	push   $0x0
  800b30:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b35:	ba 00 00 00 00       	mov    $0x0,%edx
  800b3a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b3f:	e8 67 ff ff ff       	call   800aab <syscall>
}
  800b44:	c9                   	leave  
  800b45:	c3                   	ret    

00800b46 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b46:	f3 0f 1e fb          	endbr32 
  800b4a:	55                   	push   %ebp
  800b4b:	89 e5                	mov    %esp,%ebp
  800b4d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b50:	6a 00                	push   $0x0
  800b52:	6a 00                	push   $0x0
  800b54:	6a 00                	push   $0x0
  800b56:	6a 00                	push   $0x0
  800b58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b5b:	ba 01 00 00 00       	mov    $0x1,%edx
  800b60:	b8 03 00 00 00       	mov    $0x3,%eax
  800b65:	e8 41 ff ff ff       	call   800aab <syscall>
}
  800b6a:	c9                   	leave  
  800b6b:	c3                   	ret    

00800b6c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b6c:	f3 0f 1e fb          	endbr32 
  800b70:	55                   	push   %ebp
  800b71:	89 e5                	mov    %esp,%ebp
  800b73:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b76:	6a 00                	push   $0x0
  800b78:	6a 00                	push   $0x0
  800b7a:	6a 00                	push   $0x0
  800b7c:	6a 00                	push   $0x0
  800b7e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b83:	ba 00 00 00 00       	mov    $0x0,%edx
  800b88:	b8 02 00 00 00       	mov    $0x2,%eax
  800b8d:	e8 19 ff ff ff       	call   800aab <syscall>
}
  800b92:	c9                   	leave  
  800b93:	c3                   	ret    

00800b94 <sys_yield>:

void
sys_yield(void)
{
  800b94:	f3 0f 1e fb          	endbr32 
  800b98:	55                   	push   %ebp
  800b99:	89 e5                	mov    %esp,%ebp
  800b9b:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b9e:	6a 00                	push   $0x0
  800ba0:	6a 00                	push   $0x0
  800ba2:	6a 00                	push   $0x0
  800ba4:	6a 00                	push   $0x0
  800ba6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bab:	ba 00 00 00 00       	mov    $0x0,%edx
  800bb0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bb5:	e8 f1 fe ff ff       	call   800aab <syscall>
}
  800bba:	83 c4 10             	add    $0x10,%esp
  800bbd:	c9                   	leave  
  800bbe:	c3                   	ret    

00800bbf <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800bbf:	f3 0f 1e fb          	endbr32 
  800bc3:	55                   	push   %ebp
  800bc4:	89 e5                	mov    %esp,%ebp
  800bc6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800bc9:	6a 00                	push   $0x0
  800bcb:	6a 00                	push   $0x0
  800bcd:	ff 75 10             	pushl  0x10(%ebp)
  800bd0:	ff 75 0c             	pushl  0xc(%ebp)
  800bd3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bd6:	ba 01 00 00 00       	mov    $0x1,%edx
  800bdb:	b8 04 00 00 00       	mov    $0x4,%eax
  800be0:	e8 c6 fe ff ff       	call   800aab <syscall>
}
  800be5:	c9                   	leave  
  800be6:	c3                   	ret    

00800be7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800be7:	f3 0f 1e fb          	endbr32 
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800bf1:	ff 75 18             	pushl  0x18(%ebp)
  800bf4:	ff 75 14             	pushl  0x14(%ebp)
  800bf7:	ff 75 10             	pushl  0x10(%ebp)
  800bfa:	ff 75 0c             	pushl  0xc(%ebp)
  800bfd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c00:	ba 01 00 00 00       	mov    $0x1,%edx
  800c05:	b8 05 00 00 00       	mov    $0x5,%eax
  800c0a:	e8 9c fe ff ff       	call   800aab <syscall>
}
  800c0f:	c9                   	leave  
  800c10:	c3                   	ret    

00800c11 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c11:	f3 0f 1e fb          	endbr32 
  800c15:	55                   	push   %ebp
  800c16:	89 e5                	mov    %esp,%ebp
  800c18:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c1b:	6a 00                	push   $0x0
  800c1d:	6a 00                	push   $0x0
  800c1f:	6a 00                	push   $0x0
  800c21:	ff 75 0c             	pushl  0xc(%ebp)
  800c24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c27:	ba 01 00 00 00       	mov    $0x1,%edx
  800c2c:	b8 06 00 00 00       	mov    $0x6,%eax
  800c31:	e8 75 fe ff ff       	call   800aab <syscall>
}
  800c36:	c9                   	leave  
  800c37:	c3                   	ret    

00800c38 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c38:	f3 0f 1e fb          	endbr32 
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c42:	6a 00                	push   $0x0
  800c44:	6a 00                	push   $0x0
  800c46:	6a 00                	push   $0x0
  800c48:	ff 75 0c             	pushl  0xc(%ebp)
  800c4b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c4e:	ba 01 00 00 00       	mov    $0x1,%edx
  800c53:	b8 08 00 00 00       	mov    $0x8,%eax
  800c58:	e8 4e fe ff ff       	call   800aab <syscall>
}
  800c5d:	c9                   	leave  
  800c5e:	c3                   	ret    

00800c5f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c5f:	f3 0f 1e fb          	endbr32 
  800c63:	55                   	push   %ebp
  800c64:	89 e5                	mov    %esp,%ebp
  800c66:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c69:	6a 00                	push   $0x0
  800c6b:	6a 00                	push   $0x0
  800c6d:	6a 00                	push   $0x0
  800c6f:	ff 75 0c             	pushl  0xc(%ebp)
  800c72:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c75:	ba 01 00 00 00       	mov    $0x1,%edx
  800c7a:	b8 09 00 00 00       	mov    $0x9,%eax
  800c7f:	e8 27 fe ff ff       	call   800aab <syscall>
}
  800c84:	c9                   	leave  
  800c85:	c3                   	ret    

00800c86 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c86:	f3 0f 1e fb          	endbr32 
  800c8a:	55                   	push   %ebp
  800c8b:	89 e5                	mov    %esp,%ebp
  800c8d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c90:	6a 00                	push   $0x0
  800c92:	6a 00                	push   $0x0
  800c94:	6a 00                	push   $0x0
  800c96:	ff 75 0c             	pushl  0xc(%ebp)
  800c99:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c9c:	ba 01 00 00 00       	mov    $0x1,%edx
  800ca1:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ca6:	e8 00 fe ff ff       	call   800aab <syscall>
}
  800cab:	c9                   	leave  
  800cac:	c3                   	ret    

00800cad <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cad:	f3 0f 1e fb          	endbr32 
  800cb1:	55                   	push   %ebp
  800cb2:	89 e5                	mov    %esp,%ebp
  800cb4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800cb7:	6a 00                	push   $0x0
  800cb9:	ff 75 14             	pushl  0x14(%ebp)
  800cbc:	ff 75 10             	pushl  0x10(%ebp)
  800cbf:	ff 75 0c             	pushl  0xc(%ebp)
  800cc2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800cca:	b8 0c 00 00 00       	mov    $0xc,%eax
  800ccf:	e8 d7 fd ff ff       	call   800aab <syscall>
}
  800cd4:	c9                   	leave  
  800cd5:	c3                   	ret    

00800cd6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800cd6:	f3 0f 1e fb          	endbr32 
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800ce0:	6a 00                	push   $0x0
  800ce2:	6a 00                	push   $0x0
  800ce4:	6a 00                	push   $0x0
  800ce6:	6a 00                	push   $0x0
  800ce8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ceb:	ba 01 00 00 00       	mov    $0x1,%edx
  800cf0:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cf5:	e8 b1 fd ff ff       	call   800aab <syscall>
}
  800cfa:	c9                   	leave  
  800cfb:	c3                   	ret    

00800cfc <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800cfc:	55                   	push   %ebp
  800cfd:	89 e5                	mov    %esp,%ebp
  800cff:	53                   	push   %ebx
  800d00:	83 ec 04             	sub    $0x4,%esp
  800d03:	89 d3                	mov    %edx,%ebx
	int r;

	// LAB 4: Your code here.

	// Page Table Entry
	pte_t pt_e = uvpt[pn];
  800d05:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Obtenemos la virtual address
	void *v_add = (void *) (pn << PTXSHIFT);
  800d0c:	c1 e3 0c             	shl    $0xc,%ebx

	if (pt_e & PTE_SHARE) {
  800d0f:	f6 c6 04             	test   $0x4,%dh
  800d12:	75 54                	jne    800d68 <duppage+0x6c>
		// Permisos compartidos
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
		if (r < 0)
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	} else if ((pt_e & PTE_W) || (pt_e & PTE_COW)) {
  800d14:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800d1a:	0f 84 8d 00 00 00    	je     800dad <duppage+0xb1>
		// Copy on write
		r = sys_page_map(0, v_add, envid, v_add, PTE_COW | PTE_U | PTE_P);
  800d20:	83 ec 0c             	sub    $0xc,%esp
  800d23:	68 05 08 00 00       	push   $0x805
  800d28:	53                   	push   %ebx
  800d29:	50                   	push   %eax
  800d2a:	53                   	push   %ebx
  800d2b:	6a 00                	push   $0x0
  800d2d:	e8 b5 fe ff ff       	call   800be7 <sys_page_map>
		if (r < 0)
  800d32:	83 c4 20             	add    $0x20,%esp
  800d35:	85 c0                	test   %eax,%eax
  800d37:	78 5f                	js     800d98 <duppage+0x9c>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);

		r = sys_page_map(0, v_add, 0, v_add, PTE_COW | PTE_U | PTE_P);
  800d39:	83 ec 0c             	sub    $0xc,%esp
  800d3c:	68 05 08 00 00       	push   $0x805
  800d41:	53                   	push   %ebx
  800d42:	6a 00                	push   $0x0
  800d44:	53                   	push   %ebx
  800d45:	6a 00                	push   $0x0
  800d47:	e8 9b fe ff ff       	call   800be7 <sys_page_map>
		if (r < 0)
  800d4c:	83 c4 20             	add    $0x20,%esp
  800d4f:	85 c0                	test   %eax,%eax
  800d51:	79 70                	jns    800dc3 <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800d53:	50                   	push   %eax
  800d54:	68 8c 27 80 00       	push   $0x80278c
  800d59:	68 9b 00 00 00       	push   $0x9b
  800d5e:	68 fa 28 80 00       	push   $0x8028fa
  800d63:	e8 30 13 00 00       	call   802098 <_panic>
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
  800d68:	83 ec 0c             	sub    $0xc,%esp
  800d6b:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800d71:	52                   	push   %edx
  800d72:	53                   	push   %ebx
  800d73:	50                   	push   %eax
  800d74:	53                   	push   %ebx
  800d75:	6a 00                	push   $0x0
  800d77:	e8 6b fe ff ff       	call   800be7 <sys_page_map>
		if (r < 0)
  800d7c:	83 c4 20             	add    $0x20,%esp
  800d7f:	85 c0                	test   %eax,%eax
  800d81:	79 40                	jns    800dc3 <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800d83:	50                   	push   %eax
  800d84:	68 8c 27 80 00       	push   $0x80278c
  800d89:	68 92 00 00 00       	push   $0x92
  800d8e:	68 fa 28 80 00       	push   $0x8028fa
  800d93:	e8 00 13 00 00       	call   802098 <_panic>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800d98:	50                   	push   %eax
  800d99:	68 8c 27 80 00       	push   $0x80278c
  800d9e:	68 97 00 00 00       	push   $0x97
  800da3:	68 fa 28 80 00       	push   $0x8028fa
  800da8:	e8 eb 12 00 00       	call   802098 <_panic>
	} else {
		// En caso de lectura, compartir.
		r = sys_page_map(0, v_add, envid, v_add, PTE_U | PTE_P);
  800dad:	83 ec 0c             	sub    $0xc,%esp
  800db0:	6a 05                	push   $0x5
  800db2:	53                   	push   %ebx
  800db3:	50                   	push   %eax
  800db4:	53                   	push   %ebx
  800db5:	6a 00                	push   $0x0
  800db7:	e8 2b fe ff ff       	call   800be7 <sys_page_map>
		if (r < 0)
  800dbc:	83 c4 20             	add    $0x20,%esp
  800dbf:	85 c0                	test   %eax,%eax
  800dc1:	78 0a                	js     800dcd <duppage+0xd1>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	}
	return 0;
}
  800dc3:	b8 00 00 00 00       	mov    $0x0,%eax
  800dc8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800dcb:	c9                   	leave  
  800dcc:	c3                   	ret    
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800dcd:	50                   	push   %eax
  800dce:	68 8c 27 80 00       	push   $0x80278c
  800dd3:	68 a0 00 00 00       	push   $0xa0
  800dd8:	68 fa 28 80 00       	push   $0x8028fa
  800ddd:	e8 b6 12 00 00       	call   802098 <_panic>

00800de2 <dup_or_share>:
{
  800de2:	55                   	push   %ebp
  800de3:	89 e5                	mov    %esp,%ebp
  800de5:	57                   	push   %edi
  800de6:	56                   	push   %esi
  800de7:	53                   	push   %ebx
  800de8:	83 ec 0c             	sub    $0xc,%esp
  800deb:	89 c7                	mov    %eax,%edi
  800ded:	89 d6                	mov    %edx,%esi
  800def:	89 cb                	mov    %ecx,%ebx
	if (perm & PTE_W) {
  800df1:	f6 c1 02             	test   $0x2,%cl
  800df4:	0f 84 90 00 00 00    	je     800e8a <dup_or_share+0xa8>
		if ((r = sys_page_alloc(dstenv, va, perm)) < 0)
  800dfa:	83 ec 04             	sub    $0x4,%esp
  800dfd:	51                   	push   %ecx
  800dfe:	52                   	push   %edx
  800dff:	50                   	push   %eax
  800e00:	e8 ba fd ff ff       	call   800bbf <sys_page_alloc>
  800e05:	83 c4 10             	add    $0x10,%esp
  800e08:	85 c0                	test   %eax,%eax
  800e0a:	78 56                	js     800e62 <dup_or_share+0x80>
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, perm)) < 0)
  800e0c:	83 ec 0c             	sub    $0xc,%esp
  800e0f:	53                   	push   %ebx
  800e10:	68 00 00 40 00       	push   $0x400000
  800e15:	6a 00                	push   $0x0
  800e17:	56                   	push   %esi
  800e18:	57                   	push   %edi
  800e19:	e8 c9 fd ff ff       	call   800be7 <sys_page_map>
  800e1e:	83 c4 20             	add    $0x20,%esp
  800e21:	85 c0                	test   %eax,%eax
  800e23:	78 51                	js     800e76 <dup_or_share+0x94>
		memmove(UTEMP, va, PGSIZE);
  800e25:	83 ec 04             	sub    $0x4,%esp
  800e28:	68 00 10 00 00       	push   $0x1000
  800e2d:	56                   	push   %esi
  800e2e:	68 00 00 40 00       	push   $0x400000
  800e33:	e8 b7 fa ff ff       	call   8008ef <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800e38:	83 c4 08             	add    $0x8,%esp
  800e3b:	68 00 00 40 00       	push   $0x400000
  800e40:	6a 00                	push   $0x0
  800e42:	e8 ca fd ff ff       	call   800c11 <sys_page_unmap>
  800e47:	83 c4 10             	add    $0x10,%esp
  800e4a:	85 c0                	test   %eax,%eax
  800e4c:	79 51                	jns    800e9f <dup_or_share+0xbd>
			panic("sys_page_unmap failed at dup_or_share");
  800e4e:	83 ec 04             	sub    $0x4,%esp
  800e51:	68 fc 27 80 00       	push   $0x8027fc
  800e56:	6a 18                	push   $0x18
  800e58:	68 fa 28 80 00       	push   $0x8028fa
  800e5d:	e8 36 12 00 00       	call   802098 <_panic>
			panic("sys_page_alloc failed at dup_or_share");
  800e62:	83 ec 04             	sub    $0x4,%esp
  800e65:	68 b0 27 80 00       	push   $0x8027b0
  800e6a:	6a 13                	push   $0x13
  800e6c:	68 fa 28 80 00       	push   $0x8028fa
  800e71:	e8 22 12 00 00       	call   802098 <_panic>
			panic("sys_page_map failed at dup_or_share");
  800e76:	83 ec 04             	sub    $0x4,%esp
  800e79:	68 d8 27 80 00       	push   $0x8027d8
  800e7e:	6a 15                	push   $0x15
  800e80:	68 fa 28 80 00       	push   $0x8028fa
  800e85:	e8 0e 12 00 00       	call   802098 <_panic>
		if ((r = sys_page_map(0, va, dstenv, va, perm)) < 0)
  800e8a:	83 ec 0c             	sub    $0xc,%esp
  800e8d:	51                   	push   %ecx
  800e8e:	52                   	push   %edx
  800e8f:	50                   	push   %eax
  800e90:	52                   	push   %edx
  800e91:	6a 00                	push   $0x0
  800e93:	e8 4f fd ff ff       	call   800be7 <sys_page_map>
  800e98:	83 c4 20             	add    $0x20,%esp
  800e9b:	85 c0                	test   %eax,%eax
  800e9d:	78 08                	js     800ea7 <dup_or_share+0xc5>
}
  800e9f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ea2:	5b                   	pop    %ebx
  800ea3:	5e                   	pop    %esi
  800ea4:	5f                   	pop    %edi
  800ea5:	5d                   	pop    %ebp
  800ea6:	c3                   	ret    
			panic("sys_page_map failed at dup_or_share");
  800ea7:	83 ec 04             	sub    $0x4,%esp
  800eaa:	68 d8 27 80 00       	push   $0x8027d8
  800eaf:	6a 1c                	push   $0x1c
  800eb1:	68 fa 28 80 00       	push   $0x8028fa
  800eb6:	e8 dd 11 00 00       	call   802098 <_panic>

00800ebb <pgfault>:
{
  800ebb:	f3 0f 1e fb          	endbr32 
  800ebf:	55                   	push   %ebp
  800ec0:	89 e5                	mov    %esp,%ebp
  800ec2:	53                   	push   %ebx
  800ec3:	83 ec 04             	sub    $0x4,%esp
  800ec6:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800ec9:	8b 18                	mov    (%eax),%ebx
	pte_t pt_e = uvpt[PGNUM(addr)];
  800ecb:	89 da                	mov    %ebx,%edx
  800ecd:	c1 ea 0c             	shr    $0xc,%edx
  800ed0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if ((err & FEC_WR) == 0)
  800ed7:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800edb:	74 6e                	je     800f4b <pgfault+0x90>
	if ((pt_e & PTE_COW) == 0)
  800edd:	f6 c6 08             	test   $0x8,%dh
  800ee0:	74 7d                	je     800f5f <pgfault+0xa4>
	if ((r = sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  800ee2:	83 ec 04             	sub    $0x4,%esp
  800ee5:	6a 07                	push   $0x7
  800ee7:	68 00 f0 7f 00       	push   $0x7ff000
  800eec:	6a 00                	push   $0x0
  800eee:	e8 cc fc ff ff       	call   800bbf <sys_page_alloc>
  800ef3:	83 c4 10             	add    $0x10,%esp
  800ef6:	85 c0                	test   %eax,%eax
  800ef8:	78 79                	js     800f73 <pgfault+0xb8>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800efa:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800f00:	83 ec 04             	sub    $0x4,%esp
  800f03:	68 00 10 00 00       	push   $0x1000
  800f08:	53                   	push   %ebx
  800f09:	68 00 f0 7f 00       	push   $0x7ff000
  800f0e:	e8 dc f9 ff ff       	call   8008ef <memmove>
	if ((r = sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U)) <
  800f13:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f1a:	53                   	push   %ebx
  800f1b:	6a 00                	push   $0x0
  800f1d:	68 00 f0 7f 00       	push   $0x7ff000
  800f22:	6a 00                	push   $0x0
  800f24:	e8 be fc ff ff       	call   800be7 <sys_page_map>
  800f29:	83 c4 20             	add    $0x20,%esp
  800f2c:	85 c0                	test   %eax,%eax
  800f2e:	78 57                	js     800f87 <pgfault+0xcc>
	if ((r = sys_page_unmap(0, (void *) PFTEMP)) < 0)
  800f30:	83 ec 08             	sub    $0x8,%esp
  800f33:	68 00 f0 7f 00       	push   $0x7ff000
  800f38:	6a 00                	push   $0x0
  800f3a:	e8 d2 fc ff ff       	call   800c11 <sys_page_unmap>
  800f3f:	83 c4 10             	add    $0x10,%esp
  800f42:	85 c0                	test   %eax,%eax
  800f44:	78 55                	js     800f9b <pgfault+0xe0>
}
  800f46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f49:	c9                   	leave  
  800f4a:	c3                   	ret    
		panic("ERROR EN PGFAULT: WRITE");
  800f4b:	83 ec 04             	sub    $0x4,%esp
  800f4e:	68 05 29 80 00       	push   $0x802905
  800f53:	6a 5e                	push   $0x5e
  800f55:	68 fa 28 80 00       	push   $0x8028fa
  800f5a:	e8 39 11 00 00       	call   802098 <_panic>
		panic("ERROR EN PGFAULT: COPY-ON-WRITE");
  800f5f:	83 ec 04             	sub    $0x4,%esp
  800f62:	68 24 28 80 00       	push   $0x802824
  800f67:	6a 62                	push   $0x62
  800f69:	68 fa 28 80 00       	push   $0x8028fa
  800f6e:	e8 25 11 00 00       	call   802098 <_panic>
		panic("pgfault failed");
  800f73:	83 ec 04             	sub    $0x4,%esp
  800f76:	68 1d 29 80 00       	push   $0x80291d
  800f7b:	6a 6d                	push   $0x6d
  800f7d:	68 fa 28 80 00       	push   $0x8028fa
  800f82:	e8 11 11 00 00       	call   802098 <_panic>
		panic("pgfault failed");
  800f87:	83 ec 04             	sub    $0x4,%esp
  800f8a:	68 1d 29 80 00       	push   $0x80291d
  800f8f:	6a 72                	push   $0x72
  800f91:	68 fa 28 80 00       	push   $0x8028fa
  800f96:	e8 fd 10 00 00       	call   802098 <_panic>
		panic("pgfault failed");
  800f9b:	83 ec 04             	sub    $0x4,%esp
  800f9e:	68 1d 29 80 00       	push   $0x80291d
  800fa3:	6a 74                	push   $0x74
  800fa5:	68 fa 28 80 00       	push   $0x8028fa
  800faa:	e8 e9 10 00 00       	call   802098 <_panic>

00800faf <fork_v0>:
{
  800faf:	f3 0f 1e fb          	endbr32 
  800fb3:	55                   	push   %ebp
  800fb4:	89 e5                	mov    %esp,%ebp
  800fb6:	57                   	push   %edi
  800fb7:	56                   	push   %esi
  800fb8:	53                   	push   %ebx
  800fb9:	83 ec 1c             	sub    $0x1c,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fbc:	b8 07 00 00 00       	mov    $0x7,%eax
  800fc1:	cd 30                	int    $0x30
  800fc3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800fc6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (envid < 0)
  800fc9:	85 c0                	test   %eax,%eax
  800fcb:	78 1d                	js     800fea <fork_v0+0x3b>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  800fcd:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  800fd2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800fd6:	74 26                	je     800ffe <fork_v0+0x4f>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  800fd8:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  800fdd:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
			        (pte_t *) (PGADDR(PDX(uvpt),
  800fe3:	bf 00 00 40 ef       	mov    $0xef400000,%edi
  800fe8:	eb 4b                	jmp    801035 <fork_v0+0x86>
		panic("sys_exofork failed");
  800fea:	83 ec 04             	sub    $0x4,%esp
  800fed:	68 2c 29 80 00       	push   $0x80292c
  800ff2:	6a 2b                	push   $0x2b
  800ff4:	68 fa 28 80 00       	push   $0x8028fa
  800ff9:	e8 9a 10 00 00       	call   802098 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
  800ffe:	e8 69 fb ff ff       	call   800b6c <sys_getenvid>
  801003:	25 ff 03 00 00       	and    $0x3ff,%eax
  801008:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80100b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801010:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801015:	eb 68                	jmp    80107f <fork_v0+0xd0>
				dup_or_share(envid,
  801017:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  80101d:	89 da                	mov    %ebx,%edx
  80101f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801022:	e8 bb fd ff ff       	call   800de2 <dup_or_share>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  801027:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80102d:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801033:	74 36                	je     80106b <fork_v0+0xbc>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  801035:	89 d8                	mov    %ebx,%eax
  801037:	c1 e8 16             	shr    $0x16,%eax
  80103a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801041:	09 f2                	or     %esi,%edx
		if ((*pgdirentry) & PTE_P) {
  801043:	f6 02 01             	testb  $0x1,(%edx)
  801046:	74 df                	je     801027 <fork_v0+0x78>
			        (pte_t *) (PGADDR(PDX(uvpt),
  801048:	89 da                	mov    %ebx,%edx
  80104a:	c1 ea 0a             	shr    $0xa,%edx
  80104d:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  801053:	c1 e0 0c             	shl    $0xc,%eax
  801056:	89 f9                	mov    %edi,%ecx
  801058:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
  80105e:	09 c8                	or     %ecx,%eax
  801060:	09 d0                	or     %edx,%eax
			if ((*pgtablentry) & PTE_P)
  801062:	8b 08                	mov    (%eax),%ecx
  801064:	f6 c1 01             	test   $0x1,%cl
  801067:	74 be                	je     801027 <fork_v0+0x78>
  801069:	eb ac                	jmp    801017 <fork_v0+0x68>
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80106b:	83 ec 08             	sub    $0x8,%esp
  80106e:	6a 02                	push   $0x2
  801070:	ff 75 e0             	pushl  -0x20(%ebp)
  801073:	e8 c0 fb ff ff       	call   800c38 <sys_env_set_status>
  801078:	83 c4 10             	add    $0x10,%esp
  80107b:	85 c0                	test   %eax,%eax
  80107d:	78 0b                	js     80108a <fork_v0+0xdb>
}
  80107f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801082:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801085:	5b                   	pop    %ebx
  801086:	5e                   	pop    %esi
  801087:	5f                   	pop    %edi
  801088:	5d                   	pop    %ebp
  801089:	c3                   	ret    
		panic("sys_env_set_status failed at fork_v0");
  80108a:	83 ec 04             	sub    $0x4,%esp
  80108d:	68 44 28 80 00       	push   $0x802844
  801092:	6a 43                	push   $0x43
  801094:	68 fa 28 80 00       	push   $0x8028fa
  801099:	e8 fa 0f 00 00       	call   802098 <_panic>

0080109e <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  80109e:	f3 0f 1e fb          	endbr32 
  8010a2:	55                   	push   %ebp
  8010a3:	89 e5                	mov    %esp,%ebp
  8010a5:	57                   	push   %edi
  8010a6:	56                   	push   %esi
  8010a7:	53                   	push   %ebx
  8010a8:	83 ec 28             	sub    $0x28,%esp
	int err;

	// handle padre
	set_pgfault_handler(pgfault);
  8010ab:	68 bb 0e 80 00       	push   $0x800ebb
  8010b0:	e8 2d 10 00 00       	call   8020e2 <set_pgfault_handler>
  8010b5:	b8 07 00 00 00       	mov    $0x7,%eax
  8010ba:	cd 30                	int    $0x30
  8010bc:	89 45 e0             	mov    %eax,-0x20(%ebp)

	// Proceso hijo
	envid_t e_id = sys_exofork();

	if (e_id < 0)
  8010bf:	83 c4 10             	add    $0x10,%esp
  8010c2:	85 c0                	test   %eax,%eax
  8010c4:	78 2f                	js     8010f5 <fork+0x57>
  8010c6:	89 c7                	mov    %eax,%edi
  8010c8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		panic("ERROR EN FORK: sys_exofork: %e", e_id);

	if (e_id == 0) {
  8010cf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8010d3:	0f 85 9e 00 00 00    	jne    801177 <fork+0xd9>
		// Si es hijo
		thisenv = &envs[ENVX(sys_getenvid())];
  8010d9:	e8 8e fa ff ff       	call   800b6c <sys_getenvid>
  8010de:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010e3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010e6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8010eb:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8010f0:	e9 de 00 00 00       	jmp    8011d3 <fork+0x135>
		panic("ERROR EN FORK: sys_exofork: %e", e_id);
  8010f5:	50                   	push   %eax
  8010f6:	68 6c 28 80 00       	push   $0x80286c
  8010fb:	68 c2 00 00 00       	push   $0xc2
  801100:	68 fa 28 80 00       	push   $0x8028fa
  801105:	e8 8e 0f 00 00       	call   802098 <_panic>
		// LOOP PTEs
		while (pt_x < NPTENTRIES) {
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
			pte_t pt_e = uvpt[PGNUM(dir)];
			if (dir == (UXSTACKTOP - PGSIZE)) {
				err = sys_page_alloc(e_id,
  80110a:	83 ec 04             	sub    $0x4,%esp
  80110d:	6a 07                	push   $0x7
  80110f:	68 00 f0 bf ee       	push   $0xeebff000
  801114:	57                   	push   %edi
  801115:	e8 a5 fa ff ff       	call   800bbf <sys_page_alloc>
				                     (void *) dir,
				                     PTE_W | PTE_U | PTE_P);
				if (err)
  80111a:	83 c4 10             	add    $0x10,%esp
  80111d:	85 c0                	test   %eax,%eax
  80111f:	75 33                	jne    801154 <fork+0xb6>
  801121:	83 c3 01             	add    $0x1,%ebx
		while (pt_x < NPTENTRIES) {
  801124:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  80112a:	74 3d                	je     801169 <fork+0xcb>
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
  80112c:	89 d8                	mov    %ebx,%eax
  80112e:	c1 e0 0c             	shl    $0xc,%eax
  801131:	09 f0                	or     %esi,%eax
			pte_t pt_e = uvpt[PGNUM(dir)];
  801133:	89 c2                	mov    %eax,%edx
  801135:	c1 ea 0c             	shr    $0xc,%edx
  801138:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
			if (dir == (UXSTACKTOP - PGSIZE)) {
  80113f:	3d 00 f0 bf ee       	cmp    $0xeebff000,%eax
  801144:	74 c4                	je     80110a <fork+0x6c>
					      "%e",
					      err);
				pt_x++;
				continue;
			}
			if ((pt_e & PTE_P) == 0) {
  801146:	f6 c1 01             	test   $0x1,%cl
  801149:	74 d6                	je     801121 <fork+0x83>
				pt_x++;
				continue;
			}
			duppage(e_id, PGNUM(dir));
  80114b:	89 f8                	mov    %edi,%eax
  80114d:	e8 aa fb ff ff       	call   800cfc <duppage>
  801152:	eb cd                	jmp    801121 <fork+0x83>
					panic("ERROR EN FORK: sys_page_alloc: "
  801154:	50                   	push   %eax
  801155:	68 8c 28 80 00       	push   $0x80288c
  80115a:	68 e1 00 00 00       	push   $0xe1
  80115f:	68 fa 28 80 00       	push   $0x8028fa
  801164:	e8 2f 0f 00 00       	call   802098 <_panic>
  801169:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  80116d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
	while (pd_x < PDX(UTOP)) {
  801170:	3d bb 03 00 00       	cmp    $0x3bb,%eax
  801175:	74 18                	je     80118f <fork+0xf1>
		pde_t pd_e = uvpd[pd_x];
  801177:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80117a:	8b 04 b5 00 d0 7b ef 	mov    -0x10843000(,%esi,4),%eax
		if ((pd_e & PTE_P) == 0) {
  801181:	a8 01                	test   $0x1,%al
  801183:	74 e4                	je     801169 <fork+0xcb>
  801185:	c1 e6 16             	shl    $0x16,%esi
  801188:	bb 00 00 00 00       	mov    $0x0,%ebx
  80118d:	eb 9d                	jmp    80112c <fork+0x8e>
			pt_x++;
		}
		pd_x++;
	}

	if ((err = sys_page_alloc(e_id,
  80118f:	83 ec 04             	sub    $0x4,%esp
  801192:	6a 07                	push   $0x7
  801194:	68 00 f0 bf ee       	push   $0xeebff000
  801199:	ff 75 e0             	pushl  -0x20(%ebp)
  80119c:	e8 1e fa ff ff       	call   800bbf <sys_page_alloc>
  8011a1:	83 c4 10             	add    $0x10,%esp
  8011a4:	85 c0                	test   %eax,%eax
  8011a6:	78 36                	js     8011de <fork+0x140>
	                          (void *) (UXSTACKTOP - PGSIZE),
	                          PTE_P | PTE_U | PTE_W) < 0))
		panic("Error en sys_page_alloc");


	if ((sys_env_set_pgfault_upcall(e_id, _pgfault_upcall) < 0))
  8011a8:	83 ec 08             	sub    $0x8,%esp
  8011ab:	68 3d 21 80 00       	push   $0x80213d
  8011b0:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b3:	e8 ce fa ff ff       	call   800c86 <sys_env_set_pgfault_upcall>
  8011b8:	83 c4 10             	add    $0x10,%esp
  8011bb:	85 c0                	test   %eax,%eax
  8011bd:	78 36                	js     8011f5 <fork+0x157>
		panic("sys_env_set_pgfault_upcall failed");

	// HIJO RUNNABLE
	if ((err = sys_env_set_status(e_id, ENV_RUNNABLE)) < 0)
  8011bf:	83 ec 08             	sub    $0x8,%esp
  8011c2:	6a 02                	push   $0x2
  8011c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8011c7:	e8 6c fa ff ff       	call   800c38 <sys_env_set_status>
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	78 39                	js     80120c <fork+0x16e>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);

	return e_id;
}
  8011d3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d9:	5b                   	pop    %ebx
  8011da:	5e                   	pop    %esi
  8011db:	5f                   	pop    %edi
  8011dc:	5d                   	pop    %ebp
  8011dd:	c3                   	ret    
		panic("Error en sys_page_alloc");
  8011de:	83 ec 04             	sub    $0x4,%esp
  8011e1:	68 3f 29 80 00       	push   $0x80293f
  8011e6:	68 f4 00 00 00       	push   $0xf4
  8011eb:	68 fa 28 80 00       	push   $0x8028fa
  8011f0:	e8 a3 0e 00 00       	call   802098 <_panic>
		panic("sys_env_set_pgfault_upcall failed");
  8011f5:	83 ec 04             	sub    $0x4,%esp
  8011f8:	68 b0 28 80 00       	push   $0x8028b0
  8011fd:	68 f8 00 00 00       	push   $0xf8
  801202:	68 fa 28 80 00       	push   $0x8028fa
  801207:	e8 8c 0e 00 00       	call   802098 <_panic>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);
  80120c:	50                   	push   %eax
  80120d:	68 d4 28 80 00       	push   $0x8028d4
  801212:	68 fc 00 00 00       	push   $0xfc
  801217:	68 fa 28 80 00       	push   $0x8028fa
  80121c:	e8 77 0e 00 00       	call   802098 <_panic>

00801221 <sfork>:

// Challenge!
int
sfork(void)
{
  801221:	f3 0f 1e fb          	endbr32 
  801225:	55                   	push   %ebp
  801226:	89 e5                	mov    %esp,%ebp
  801228:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80122b:	68 57 29 80 00       	push   $0x802957
  801230:	68 05 01 00 00       	push   $0x105
  801235:	68 fa 28 80 00       	push   $0x8028fa
  80123a:	e8 59 0e 00 00       	call   802098 <_panic>

0080123f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80123f:	f3 0f 1e fb          	endbr32 
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	56                   	push   %esi
  801247:	53                   	push   %ebx
  801248:	8b 75 08             	mov    0x8(%ebp),%esi
  80124b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80124e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  801251:	85 c0                	test   %eax,%eax
  801253:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801258:	0f 44 c2             	cmove  %edx,%eax
  80125b:	83 ec 0c             	sub    $0xc,%esp
  80125e:	50                   	push   %eax
  80125f:	e8 72 fa ff ff       	call   800cd6 <sys_ipc_recv>

	if (from_env_store != NULL)
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	85 f6                	test   %esi,%esi
  801269:	74 15                	je     801280 <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  80126b:	ba 00 00 00 00       	mov    $0x0,%edx
  801270:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801273:	74 09                	je     80127e <ipc_recv+0x3f>
  801275:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80127b:	8b 52 74             	mov    0x74(%edx),%edx
  80127e:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  801280:	85 db                	test   %ebx,%ebx
  801282:	74 15                	je     801299 <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  801284:	ba 00 00 00 00       	mov    $0x0,%edx
  801289:	83 f8 fd             	cmp    $0xfffffffd,%eax
  80128c:	74 09                	je     801297 <ipc_recv+0x58>
  80128e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801294:	8b 52 78             	mov    0x78(%edx),%edx
  801297:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  801299:	83 f8 fd             	cmp    $0xfffffffd,%eax
  80129c:	74 08                	je     8012a6 <ipc_recv+0x67>
  80129e:	a1 04 40 80 00       	mov    0x804004,%eax
  8012a3:	8b 40 70             	mov    0x70(%eax),%eax
}
  8012a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012a9:	5b                   	pop    %ebx
  8012aa:	5e                   	pop    %esi
  8012ab:	5d                   	pop    %ebp
  8012ac:	c3                   	ret    

008012ad <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012ad:	f3 0f 1e fb          	endbr32 
  8012b1:	55                   	push   %ebp
  8012b2:	89 e5                	mov    %esp,%ebp
  8012b4:	57                   	push   %edi
  8012b5:	56                   	push   %esi
  8012b6:	53                   	push   %ebx
  8012b7:	83 ec 0c             	sub    $0xc,%esp
  8012ba:	8b 7d 08             	mov    0x8(%ebp),%edi
  8012bd:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012c0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8012c3:	eb 1f                	jmp    8012e4 <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  8012c5:	6a 00                	push   $0x0
  8012c7:	68 00 00 c0 ee       	push   $0xeec00000
  8012cc:	56                   	push   %esi
  8012cd:	57                   	push   %edi
  8012ce:	e8 da f9 ff ff       	call   800cad <sys_ipc_try_send>
  8012d3:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  8012d6:	85 c0                	test   %eax,%eax
  8012d8:	74 30                	je     80130a <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  8012da:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8012dd:	75 19                	jne    8012f8 <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  8012df:	e8 b0 f8 ff ff       	call   800b94 <sys_yield>
		if (pg != NULL) {
  8012e4:	85 db                	test   %ebx,%ebx
  8012e6:	74 dd                	je     8012c5 <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  8012e8:	ff 75 14             	pushl  0x14(%ebp)
  8012eb:	53                   	push   %ebx
  8012ec:	56                   	push   %esi
  8012ed:	57                   	push   %edi
  8012ee:	e8 ba f9 ff ff       	call   800cad <sys_ipc_try_send>
  8012f3:	83 c4 10             	add    $0x10,%esp
  8012f6:	eb de                	jmp    8012d6 <ipc_send+0x29>
			panic("ipc_send: %d", res);
  8012f8:	50                   	push   %eax
  8012f9:	68 6d 29 80 00       	push   $0x80296d
  8012fe:	6a 3e                	push   $0x3e
  801300:	68 7a 29 80 00       	push   $0x80297a
  801305:	e8 8e 0d 00 00       	call   802098 <_panic>
	}
}
  80130a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80130d:	5b                   	pop    %ebx
  80130e:	5e                   	pop    %esi
  80130f:	5f                   	pop    %edi
  801310:	5d                   	pop    %ebp
  801311:	c3                   	ret    

00801312 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801312:	f3 0f 1e fb          	endbr32 
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
  801319:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80131c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801321:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801324:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80132a:	8b 52 50             	mov    0x50(%edx),%edx
  80132d:	39 ca                	cmp    %ecx,%edx
  80132f:	74 11                	je     801342 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801331:	83 c0 01             	add    $0x1,%eax
  801334:	3d 00 04 00 00       	cmp    $0x400,%eax
  801339:	75 e6                	jne    801321 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  80133b:	b8 00 00 00 00       	mov    $0x0,%eax
  801340:	eb 0b                	jmp    80134d <ipc_find_env+0x3b>
			return envs[i].env_id;
  801342:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801345:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80134a:	8b 40 48             	mov    0x48(%eax),%eax
}
  80134d:	5d                   	pop    %ebp
  80134e:	c3                   	ret    

0080134f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80134f:	f3 0f 1e fb          	endbr32 
  801353:	55                   	push   %ebp
  801354:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801356:	8b 45 08             	mov    0x8(%ebp),%eax
  801359:	05 00 00 00 30       	add    $0x30000000,%eax
  80135e:	c1 e8 0c             	shr    $0xc,%eax
}
  801361:	5d                   	pop    %ebp
  801362:	c3                   	ret    

00801363 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801363:	f3 0f 1e fb          	endbr32 
  801367:	55                   	push   %ebp
  801368:	89 e5                	mov    %esp,%ebp
  80136a:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  80136d:	ff 75 08             	pushl  0x8(%ebp)
  801370:	e8 da ff ff ff       	call   80134f <fd2num>
  801375:	83 c4 10             	add    $0x10,%esp
  801378:	c1 e0 0c             	shl    $0xc,%eax
  80137b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801380:	c9                   	leave  
  801381:	c3                   	ret    

00801382 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801382:	f3 0f 1e fb          	endbr32 
  801386:	55                   	push   %ebp
  801387:	89 e5                	mov    %esp,%ebp
  801389:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80138e:	89 c2                	mov    %eax,%edx
  801390:	c1 ea 16             	shr    $0x16,%edx
  801393:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80139a:	f6 c2 01             	test   $0x1,%dl
  80139d:	74 2d                	je     8013cc <fd_alloc+0x4a>
  80139f:	89 c2                	mov    %eax,%edx
  8013a1:	c1 ea 0c             	shr    $0xc,%edx
  8013a4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013ab:	f6 c2 01             	test   $0x1,%dl
  8013ae:	74 1c                	je     8013cc <fd_alloc+0x4a>
  8013b0:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8013b5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013ba:	75 d2                	jne    80138e <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8013bf:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8013c5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8013ca:	eb 0a                	jmp    8013d6 <fd_alloc+0x54>
			*fd_store = fd;
  8013cc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8013cf:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8013d6:	5d                   	pop    %ebp
  8013d7:	c3                   	ret    

008013d8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8013d8:	f3 0f 1e fb          	endbr32 
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8013e2:	83 f8 1f             	cmp    $0x1f,%eax
  8013e5:	77 30                	ja     801417 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8013e7:	c1 e0 0c             	shl    $0xc,%eax
  8013ea:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8013ef:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8013f5:	f6 c2 01             	test   $0x1,%dl
  8013f8:	74 24                	je     80141e <fd_lookup+0x46>
  8013fa:	89 c2                	mov    %eax,%edx
  8013fc:	c1 ea 0c             	shr    $0xc,%edx
  8013ff:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801406:	f6 c2 01             	test   $0x1,%dl
  801409:	74 1a                	je     801425 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80140b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80140e:	89 02                	mov    %eax,(%edx)
	return 0;
  801410:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801415:	5d                   	pop    %ebp
  801416:	c3                   	ret    
		return -E_INVAL;
  801417:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80141c:	eb f7                	jmp    801415 <fd_lookup+0x3d>
		return -E_INVAL;
  80141e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801423:	eb f0                	jmp    801415 <fd_lookup+0x3d>
  801425:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80142a:	eb e9                	jmp    801415 <fd_lookup+0x3d>

0080142c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80142c:	f3 0f 1e fb          	endbr32 
  801430:	55                   	push   %ebp
  801431:	89 e5                	mov    %esp,%ebp
  801433:	83 ec 08             	sub    $0x8,%esp
  801436:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801439:	ba 00 2a 80 00       	mov    $0x802a00,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80143e:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  801443:	39 08                	cmp    %ecx,(%eax)
  801445:	74 33                	je     80147a <dev_lookup+0x4e>
  801447:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80144a:	8b 02                	mov    (%edx),%eax
  80144c:	85 c0                	test   %eax,%eax
  80144e:	75 f3                	jne    801443 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801450:	a1 04 40 80 00       	mov    0x804004,%eax
  801455:	8b 40 48             	mov    0x48(%eax),%eax
  801458:	83 ec 04             	sub    $0x4,%esp
  80145b:	51                   	push   %ecx
  80145c:	50                   	push   %eax
  80145d:	68 84 29 80 00       	push   $0x802984
  801462:	e8 66 ed ff ff       	call   8001cd <cprintf>
	*dev = 0;
  801467:	8b 45 0c             	mov    0xc(%ebp),%eax
  80146a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801470:	83 c4 10             	add    $0x10,%esp
  801473:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801478:	c9                   	leave  
  801479:	c3                   	ret    
			*dev = devtab[i];
  80147a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80147d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80147f:	b8 00 00 00 00       	mov    $0x0,%eax
  801484:	eb f2                	jmp    801478 <dev_lookup+0x4c>

00801486 <fd_close>:
{
  801486:	f3 0f 1e fb          	endbr32 
  80148a:	55                   	push   %ebp
  80148b:	89 e5                	mov    %esp,%ebp
  80148d:	57                   	push   %edi
  80148e:	56                   	push   %esi
  80148f:	53                   	push   %ebx
  801490:	83 ec 28             	sub    $0x28,%esp
  801493:	8b 75 08             	mov    0x8(%ebp),%esi
  801496:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801499:	56                   	push   %esi
  80149a:	e8 b0 fe ff ff       	call   80134f <fd2num>
  80149f:	83 c4 08             	add    $0x8,%esp
  8014a2:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8014a5:	52                   	push   %edx
  8014a6:	50                   	push   %eax
  8014a7:	e8 2c ff ff ff       	call   8013d8 <fd_lookup>
  8014ac:	89 c3                	mov    %eax,%ebx
  8014ae:	83 c4 10             	add    $0x10,%esp
  8014b1:	85 c0                	test   %eax,%eax
  8014b3:	78 05                	js     8014ba <fd_close+0x34>
	    || fd != fd2)
  8014b5:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8014b8:	74 16                	je     8014d0 <fd_close+0x4a>
		return (must_exist ? r : 0);
  8014ba:	89 f8                	mov    %edi,%eax
  8014bc:	84 c0                	test   %al,%al
  8014be:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c3:	0f 44 d8             	cmove  %eax,%ebx
}
  8014c6:	89 d8                	mov    %ebx,%eax
  8014c8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014cb:	5b                   	pop    %ebx
  8014cc:	5e                   	pop    %esi
  8014cd:	5f                   	pop    %edi
  8014ce:	5d                   	pop    %ebp
  8014cf:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8014d0:	83 ec 08             	sub    $0x8,%esp
  8014d3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8014d6:	50                   	push   %eax
  8014d7:	ff 36                	pushl  (%esi)
  8014d9:	e8 4e ff ff ff       	call   80142c <dev_lookup>
  8014de:	89 c3                	mov    %eax,%ebx
  8014e0:	83 c4 10             	add    $0x10,%esp
  8014e3:	85 c0                	test   %eax,%eax
  8014e5:	78 1a                	js     801501 <fd_close+0x7b>
		if (dev->dev_close)
  8014e7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014ea:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8014ed:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	74 0b                	je     801501 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8014f6:	83 ec 0c             	sub    $0xc,%esp
  8014f9:	56                   	push   %esi
  8014fa:	ff d0                	call   *%eax
  8014fc:	89 c3                	mov    %eax,%ebx
  8014fe:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801501:	83 ec 08             	sub    $0x8,%esp
  801504:	56                   	push   %esi
  801505:	6a 00                	push   $0x0
  801507:	e8 05 f7 ff ff       	call   800c11 <sys_page_unmap>
	return r;
  80150c:	83 c4 10             	add    $0x10,%esp
  80150f:	eb b5                	jmp    8014c6 <fd_close+0x40>

00801511 <close>:

int
close(int fdnum)
{
  801511:	f3 0f 1e fb          	endbr32 
  801515:	55                   	push   %ebp
  801516:	89 e5                	mov    %esp,%ebp
  801518:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80151b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80151e:	50                   	push   %eax
  80151f:	ff 75 08             	pushl  0x8(%ebp)
  801522:	e8 b1 fe ff ff       	call   8013d8 <fd_lookup>
  801527:	83 c4 10             	add    $0x10,%esp
  80152a:	85 c0                	test   %eax,%eax
  80152c:	79 02                	jns    801530 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  80152e:	c9                   	leave  
  80152f:	c3                   	ret    
		return fd_close(fd, 1);
  801530:	83 ec 08             	sub    $0x8,%esp
  801533:	6a 01                	push   $0x1
  801535:	ff 75 f4             	pushl  -0xc(%ebp)
  801538:	e8 49 ff ff ff       	call   801486 <fd_close>
  80153d:	83 c4 10             	add    $0x10,%esp
  801540:	eb ec                	jmp    80152e <close+0x1d>

00801542 <close_all>:

void
close_all(void)
{
  801542:	f3 0f 1e fb          	endbr32 
  801546:	55                   	push   %ebp
  801547:	89 e5                	mov    %esp,%ebp
  801549:	53                   	push   %ebx
  80154a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80154d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801552:	83 ec 0c             	sub    $0xc,%esp
  801555:	53                   	push   %ebx
  801556:	e8 b6 ff ff ff       	call   801511 <close>
	for (i = 0; i < MAXFD; i++)
  80155b:	83 c3 01             	add    $0x1,%ebx
  80155e:	83 c4 10             	add    $0x10,%esp
  801561:	83 fb 20             	cmp    $0x20,%ebx
  801564:	75 ec                	jne    801552 <close_all+0x10>
}
  801566:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801569:	c9                   	leave  
  80156a:	c3                   	ret    

0080156b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80156b:	f3 0f 1e fb          	endbr32 
  80156f:	55                   	push   %ebp
  801570:	89 e5                	mov    %esp,%ebp
  801572:	57                   	push   %edi
  801573:	56                   	push   %esi
  801574:	53                   	push   %ebx
  801575:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801578:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80157b:	50                   	push   %eax
  80157c:	ff 75 08             	pushl  0x8(%ebp)
  80157f:	e8 54 fe ff ff       	call   8013d8 <fd_lookup>
  801584:	89 c3                	mov    %eax,%ebx
  801586:	83 c4 10             	add    $0x10,%esp
  801589:	85 c0                	test   %eax,%eax
  80158b:	0f 88 81 00 00 00    	js     801612 <dup+0xa7>
		return r;
	close(newfdnum);
  801591:	83 ec 0c             	sub    $0xc,%esp
  801594:	ff 75 0c             	pushl  0xc(%ebp)
  801597:	e8 75 ff ff ff       	call   801511 <close>

	newfd = INDEX2FD(newfdnum);
  80159c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80159f:	c1 e6 0c             	shl    $0xc,%esi
  8015a2:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8015a8:	83 c4 04             	add    $0x4,%esp
  8015ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015ae:	e8 b0 fd ff ff       	call   801363 <fd2data>
  8015b3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015b5:	89 34 24             	mov    %esi,(%esp)
  8015b8:	e8 a6 fd ff ff       	call   801363 <fd2data>
  8015bd:	83 c4 10             	add    $0x10,%esp
  8015c0:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8015c2:	89 d8                	mov    %ebx,%eax
  8015c4:	c1 e8 16             	shr    $0x16,%eax
  8015c7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8015ce:	a8 01                	test   $0x1,%al
  8015d0:	74 11                	je     8015e3 <dup+0x78>
  8015d2:	89 d8                	mov    %ebx,%eax
  8015d4:	c1 e8 0c             	shr    $0xc,%eax
  8015d7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8015de:	f6 c2 01             	test   $0x1,%dl
  8015e1:	75 39                	jne    80161c <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8015e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8015e6:	89 d0                	mov    %edx,%eax
  8015e8:	c1 e8 0c             	shr    $0xc,%eax
  8015eb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8015f2:	83 ec 0c             	sub    $0xc,%esp
  8015f5:	25 07 0e 00 00       	and    $0xe07,%eax
  8015fa:	50                   	push   %eax
  8015fb:	56                   	push   %esi
  8015fc:	6a 00                	push   $0x0
  8015fe:	52                   	push   %edx
  8015ff:	6a 00                	push   $0x0
  801601:	e8 e1 f5 ff ff       	call   800be7 <sys_page_map>
  801606:	89 c3                	mov    %eax,%ebx
  801608:	83 c4 20             	add    $0x20,%esp
  80160b:	85 c0                	test   %eax,%eax
  80160d:	78 31                	js     801640 <dup+0xd5>
		goto err;

	return newfdnum;
  80160f:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801612:	89 d8                	mov    %ebx,%eax
  801614:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801617:	5b                   	pop    %ebx
  801618:	5e                   	pop    %esi
  801619:	5f                   	pop    %edi
  80161a:	5d                   	pop    %ebp
  80161b:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80161c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801623:	83 ec 0c             	sub    $0xc,%esp
  801626:	25 07 0e 00 00       	and    $0xe07,%eax
  80162b:	50                   	push   %eax
  80162c:	57                   	push   %edi
  80162d:	6a 00                	push   $0x0
  80162f:	53                   	push   %ebx
  801630:	6a 00                	push   $0x0
  801632:	e8 b0 f5 ff ff       	call   800be7 <sys_page_map>
  801637:	89 c3                	mov    %eax,%ebx
  801639:	83 c4 20             	add    $0x20,%esp
  80163c:	85 c0                	test   %eax,%eax
  80163e:	79 a3                	jns    8015e3 <dup+0x78>
	sys_page_unmap(0, newfd);
  801640:	83 ec 08             	sub    $0x8,%esp
  801643:	56                   	push   %esi
  801644:	6a 00                	push   $0x0
  801646:	e8 c6 f5 ff ff       	call   800c11 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80164b:	83 c4 08             	add    $0x8,%esp
  80164e:	57                   	push   %edi
  80164f:	6a 00                	push   $0x0
  801651:	e8 bb f5 ff ff       	call   800c11 <sys_page_unmap>
	return r;
  801656:	83 c4 10             	add    $0x10,%esp
  801659:	eb b7                	jmp    801612 <dup+0xa7>

0080165b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80165b:	f3 0f 1e fb          	endbr32 
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
  801662:	53                   	push   %ebx
  801663:	83 ec 1c             	sub    $0x1c,%esp
  801666:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801669:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80166c:	50                   	push   %eax
  80166d:	53                   	push   %ebx
  80166e:	e8 65 fd ff ff       	call   8013d8 <fd_lookup>
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	85 c0                	test   %eax,%eax
  801678:	78 3f                	js     8016b9 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80167a:	83 ec 08             	sub    $0x8,%esp
  80167d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801680:	50                   	push   %eax
  801681:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801684:	ff 30                	pushl  (%eax)
  801686:	e8 a1 fd ff ff       	call   80142c <dev_lookup>
  80168b:	83 c4 10             	add    $0x10,%esp
  80168e:	85 c0                	test   %eax,%eax
  801690:	78 27                	js     8016b9 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801692:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801695:	8b 42 08             	mov    0x8(%edx),%eax
  801698:	83 e0 03             	and    $0x3,%eax
  80169b:	83 f8 01             	cmp    $0x1,%eax
  80169e:	74 1e                	je     8016be <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8016a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016a3:	8b 40 08             	mov    0x8(%eax),%eax
  8016a6:	85 c0                	test   %eax,%eax
  8016a8:	74 35                	je     8016df <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016aa:	83 ec 04             	sub    $0x4,%esp
  8016ad:	ff 75 10             	pushl  0x10(%ebp)
  8016b0:	ff 75 0c             	pushl  0xc(%ebp)
  8016b3:	52                   	push   %edx
  8016b4:	ff d0                	call   *%eax
  8016b6:	83 c4 10             	add    $0x10,%esp
}
  8016b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016bc:	c9                   	leave  
  8016bd:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8016be:	a1 04 40 80 00       	mov    0x804004,%eax
  8016c3:	8b 40 48             	mov    0x48(%eax),%eax
  8016c6:	83 ec 04             	sub    $0x4,%esp
  8016c9:	53                   	push   %ebx
  8016ca:	50                   	push   %eax
  8016cb:	68 c5 29 80 00       	push   $0x8029c5
  8016d0:	e8 f8 ea ff ff       	call   8001cd <cprintf>
		return -E_INVAL;
  8016d5:	83 c4 10             	add    $0x10,%esp
  8016d8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8016dd:	eb da                	jmp    8016b9 <read+0x5e>
		return -E_NOT_SUPP;
  8016df:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8016e4:	eb d3                	jmp    8016b9 <read+0x5e>

008016e6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8016e6:	f3 0f 1e fb          	endbr32 
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	57                   	push   %edi
  8016ee:	56                   	push   %esi
  8016ef:	53                   	push   %ebx
  8016f0:	83 ec 0c             	sub    $0xc,%esp
  8016f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8016f6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8016f9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8016fe:	eb 02                	jmp    801702 <readn+0x1c>
  801700:	01 c3                	add    %eax,%ebx
  801702:	39 f3                	cmp    %esi,%ebx
  801704:	73 21                	jae    801727 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801706:	83 ec 04             	sub    $0x4,%esp
  801709:	89 f0                	mov    %esi,%eax
  80170b:	29 d8                	sub    %ebx,%eax
  80170d:	50                   	push   %eax
  80170e:	89 d8                	mov    %ebx,%eax
  801710:	03 45 0c             	add    0xc(%ebp),%eax
  801713:	50                   	push   %eax
  801714:	57                   	push   %edi
  801715:	e8 41 ff ff ff       	call   80165b <read>
		if (m < 0)
  80171a:	83 c4 10             	add    $0x10,%esp
  80171d:	85 c0                	test   %eax,%eax
  80171f:	78 04                	js     801725 <readn+0x3f>
			return m;
		if (m == 0)
  801721:	75 dd                	jne    801700 <readn+0x1a>
  801723:	eb 02                	jmp    801727 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801725:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801727:	89 d8                	mov    %ebx,%eax
  801729:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80172c:	5b                   	pop    %ebx
  80172d:	5e                   	pop    %esi
  80172e:	5f                   	pop    %edi
  80172f:	5d                   	pop    %ebp
  801730:	c3                   	ret    

00801731 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801731:	f3 0f 1e fb          	endbr32 
  801735:	55                   	push   %ebp
  801736:	89 e5                	mov    %esp,%ebp
  801738:	53                   	push   %ebx
  801739:	83 ec 1c             	sub    $0x1c,%esp
  80173c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80173f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801742:	50                   	push   %eax
  801743:	53                   	push   %ebx
  801744:	e8 8f fc ff ff       	call   8013d8 <fd_lookup>
  801749:	83 c4 10             	add    $0x10,%esp
  80174c:	85 c0                	test   %eax,%eax
  80174e:	78 3a                	js     80178a <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801750:	83 ec 08             	sub    $0x8,%esp
  801753:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801756:	50                   	push   %eax
  801757:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80175a:	ff 30                	pushl  (%eax)
  80175c:	e8 cb fc ff ff       	call   80142c <dev_lookup>
  801761:	83 c4 10             	add    $0x10,%esp
  801764:	85 c0                	test   %eax,%eax
  801766:	78 22                	js     80178a <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801768:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80176f:	74 1e                	je     80178f <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801771:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801774:	8b 52 0c             	mov    0xc(%edx),%edx
  801777:	85 d2                	test   %edx,%edx
  801779:	74 35                	je     8017b0 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80177b:	83 ec 04             	sub    $0x4,%esp
  80177e:	ff 75 10             	pushl  0x10(%ebp)
  801781:	ff 75 0c             	pushl  0xc(%ebp)
  801784:	50                   	push   %eax
  801785:	ff d2                	call   *%edx
  801787:	83 c4 10             	add    $0x10,%esp
}
  80178a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80178d:	c9                   	leave  
  80178e:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80178f:	a1 04 40 80 00       	mov    0x804004,%eax
  801794:	8b 40 48             	mov    0x48(%eax),%eax
  801797:	83 ec 04             	sub    $0x4,%esp
  80179a:	53                   	push   %ebx
  80179b:	50                   	push   %eax
  80179c:	68 e1 29 80 00       	push   $0x8029e1
  8017a1:	e8 27 ea ff ff       	call   8001cd <cprintf>
		return -E_INVAL;
  8017a6:	83 c4 10             	add    $0x10,%esp
  8017a9:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017ae:	eb da                	jmp    80178a <write+0x59>
		return -E_NOT_SUPP;
  8017b0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017b5:	eb d3                	jmp    80178a <write+0x59>

008017b7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8017b7:	f3 0f 1e fb          	endbr32 
  8017bb:	55                   	push   %ebp
  8017bc:	89 e5                	mov    %esp,%ebp
  8017be:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8017c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017c4:	50                   	push   %eax
  8017c5:	ff 75 08             	pushl  0x8(%ebp)
  8017c8:	e8 0b fc ff ff       	call   8013d8 <fd_lookup>
  8017cd:	83 c4 10             	add    $0x10,%esp
  8017d0:	85 c0                	test   %eax,%eax
  8017d2:	78 0e                	js     8017e2 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8017d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017da:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8017dd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e2:	c9                   	leave  
  8017e3:	c3                   	ret    

008017e4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8017e4:	f3 0f 1e fb          	endbr32 
  8017e8:	55                   	push   %ebp
  8017e9:	89 e5                	mov    %esp,%ebp
  8017eb:	53                   	push   %ebx
  8017ec:	83 ec 1c             	sub    $0x1c,%esp
  8017ef:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017f2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017f5:	50                   	push   %eax
  8017f6:	53                   	push   %ebx
  8017f7:	e8 dc fb ff ff       	call   8013d8 <fd_lookup>
  8017fc:	83 c4 10             	add    $0x10,%esp
  8017ff:	85 c0                	test   %eax,%eax
  801801:	78 37                	js     80183a <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801803:	83 ec 08             	sub    $0x8,%esp
  801806:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801809:	50                   	push   %eax
  80180a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80180d:	ff 30                	pushl  (%eax)
  80180f:	e8 18 fc ff ff       	call   80142c <dev_lookup>
  801814:	83 c4 10             	add    $0x10,%esp
  801817:	85 c0                	test   %eax,%eax
  801819:	78 1f                	js     80183a <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80181b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801822:	74 1b                	je     80183f <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801824:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801827:	8b 52 18             	mov    0x18(%edx),%edx
  80182a:	85 d2                	test   %edx,%edx
  80182c:	74 32                	je     801860 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80182e:	83 ec 08             	sub    $0x8,%esp
  801831:	ff 75 0c             	pushl  0xc(%ebp)
  801834:	50                   	push   %eax
  801835:	ff d2                	call   *%edx
  801837:	83 c4 10             	add    $0x10,%esp
}
  80183a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183d:	c9                   	leave  
  80183e:	c3                   	ret    
			thisenv->env_id, fdnum);
  80183f:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801844:	8b 40 48             	mov    0x48(%eax),%eax
  801847:	83 ec 04             	sub    $0x4,%esp
  80184a:	53                   	push   %ebx
  80184b:	50                   	push   %eax
  80184c:	68 a4 29 80 00       	push   $0x8029a4
  801851:	e8 77 e9 ff ff       	call   8001cd <cprintf>
		return -E_INVAL;
  801856:	83 c4 10             	add    $0x10,%esp
  801859:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80185e:	eb da                	jmp    80183a <ftruncate+0x56>
		return -E_NOT_SUPP;
  801860:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801865:	eb d3                	jmp    80183a <ftruncate+0x56>

00801867 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801867:	f3 0f 1e fb          	endbr32 
  80186b:	55                   	push   %ebp
  80186c:	89 e5                	mov    %esp,%ebp
  80186e:	53                   	push   %ebx
  80186f:	83 ec 1c             	sub    $0x1c,%esp
  801872:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801875:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801878:	50                   	push   %eax
  801879:	ff 75 08             	pushl  0x8(%ebp)
  80187c:	e8 57 fb ff ff       	call   8013d8 <fd_lookup>
  801881:	83 c4 10             	add    $0x10,%esp
  801884:	85 c0                	test   %eax,%eax
  801886:	78 4b                	js     8018d3 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801888:	83 ec 08             	sub    $0x8,%esp
  80188b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80188e:	50                   	push   %eax
  80188f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801892:	ff 30                	pushl  (%eax)
  801894:	e8 93 fb ff ff       	call   80142c <dev_lookup>
  801899:	83 c4 10             	add    $0x10,%esp
  80189c:	85 c0                	test   %eax,%eax
  80189e:	78 33                	js     8018d3 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8018a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a3:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018a7:	74 2f                	je     8018d8 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018a9:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018ac:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018b3:	00 00 00 
	stat->st_isdir = 0;
  8018b6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8018bd:	00 00 00 
	stat->st_dev = dev;
  8018c0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8018c6:	83 ec 08             	sub    $0x8,%esp
  8018c9:	53                   	push   %ebx
  8018ca:	ff 75 f0             	pushl  -0x10(%ebp)
  8018cd:	ff 50 14             	call   *0x14(%eax)
  8018d0:	83 c4 10             	add    $0x10,%esp
}
  8018d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d6:	c9                   	leave  
  8018d7:	c3                   	ret    
		return -E_NOT_SUPP;
  8018d8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018dd:	eb f4                	jmp    8018d3 <fstat+0x6c>

008018df <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8018df:	f3 0f 1e fb          	endbr32 
  8018e3:	55                   	push   %ebp
  8018e4:	89 e5                	mov    %esp,%ebp
  8018e6:	56                   	push   %esi
  8018e7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8018e8:	83 ec 08             	sub    $0x8,%esp
  8018eb:	6a 00                	push   $0x0
  8018ed:	ff 75 08             	pushl  0x8(%ebp)
  8018f0:	e8 fb 01 00 00       	call   801af0 <open>
  8018f5:	89 c3                	mov    %eax,%ebx
  8018f7:	83 c4 10             	add    $0x10,%esp
  8018fa:	85 c0                	test   %eax,%eax
  8018fc:	78 1b                	js     801919 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8018fe:	83 ec 08             	sub    $0x8,%esp
  801901:	ff 75 0c             	pushl  0xc(%ebp)
  801904:	50                   	push   %eax
  801905:	e8 5d ff ff ff       	call   801867 <fstat>
  80190a:	89 c6                	mov    %eax,%esi
	close(fd);
  80190c:	89 1c 24             	mov    %ebx,(%esp)
  80190f:	e8 fd fb ff ff       	call   801511 <close>
	return r;
  801914:	83 c4 10             	add    $0x10,%esp
  801917:	89 f3                	mov    %esi,%ebx
}
  801919:	89 d8                	mov    %ebx,%eax
  80191b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80191e:	5b                   	pop    %ebx
  80191f:	5e                   	pop    %esi
  801920:	5d                   	pop    %ebp
  801921:	c3                   	ret    

00801922 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801922:	55                   	push   %ebp
  801923:	89 e5                	mov    %esp,%ebp
  801925:	56                   	push   %esi
  801926:	53                   	push   %ebx
  801927:	89 c6                	mov    %eax,%esi
  801929:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80192b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801932:	74 27                	je     80195b <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801934:	6a 07                	push   $0x7
  801936:	68 00 50 80 00       	push   $0x805000
  80193b:	56                   	push   %esi
  80193c:	ff 35 00 40 80 00    	pushl  0x804000
  801942:	e8 66 f9 ff ff       	call   8012ad <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801947:	83 c4 0c             	add    $0xc,%esp
  80194a:	6a 00                	push   $0x0
  80194c:	53                   	push   %ebx
  80194d:	6a 00                	push   $0x0
  80194f:	e8 eb f8 ff ff       	call   80123f <ipc_recv>
}
  801954:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801957:	5b                   	pop    %ebx
  801958:	5e                   	pop    %esi
  801959:	5d                   	pop    %ebp
  80195a:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80195b:	83 ec 0c             	sub    $0xc,%esp
  80195e:	6a 01                	push   $0x1
  801960:	e8 ad f9 ff ff       	call   801312 <ipc_find_env>
  801965:	a3 00 40 80 00       	mov    %eax,0x804000
  80196a:	83 c4 10             	add    $0x10,%esp
  80196d:	eb c5                	jmp    801934 <fsipc+0x12>

0080196f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80196f:	f3 0f 1e fb          	endbr32 
  801973:	55                   	push   %ebp
  801974:	89 e5                	mov    %esp,%ebp
  801976:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801979:	8b 45 08             	mov    0x8(%ebp),%eax
  80197c:	8b 40 0c             	mov    0xc(%eax),%eax
  80197f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801984:	8b 45 0c             	mov    0xc(%ebp),%eax
  801987:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80198c:	ba 00 00 00 00       	mov    $0x0,%edx
  801991:	b8 02 00 00 00       	mov    $0x2,%eax
  801996:	e8 87 ff ff ff       	call   801922 <fsipc>
}
  80199b:	c9                   	leave  
  80199c:	c3                   	ret    

0080199d <devfile_flush>:
{
  80199d:	f3 0f 1e fb          	endbr32 
  8019a1:	55                   	push   %ebp
  8019a2:	89 e5                	mov    %esp,%ebp
  8019a4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019a7:	8b 45 08             	mov    0x8(%ebp),%eax
  8019aa:	8b 40 0c             	mov    0xc(%eax),%eax
  8019ad:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8019b7:	b8 06 00 00 00       	mov    $0x6,%eax
  8019bc:	e8 61 ff ff ff       	call   801922 <fsipc>
}
  8019c1:	c9                   	leave  
  8019c2:	c3                   	ret    

008019c3 <devfile_stat>:
{
  8019c3:	f3 0f 1e fb          	endbr32 
  8019c7:	55                   	push   %ebp
  8019c8:	89 e5                	mov    %esp,%ebp
  8019ca:	53                   	push   %ebx
  8019cb:	83 ec 04             	sub    $0x4,%esp
  8019ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8019d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d4:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8019dc:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e1:	b8 05 00 00 00       	mov    $0x5,%eax
  8019e6:	e8 37 ff ff ff       	call   801922 <fsipc>
  8019eb:	85 c0                	test   %eax,%eax
  8019ed:	78 2c                	js     801a1b <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8019ef:	83 ec 08             	sub    $0x8,%esp
  8019f2:	68 00 50 80 00       	push   $0x805000
  8019f7:	53                   	push   %ebx
  8019f8:	e8 3a ed ff ff       	call   800737 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8019fd:	a1 80 50 80 00       	mov    0x805080,%eax
  801a02:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a08:	a1 84 50 80 00       	mov    0x805084,%eax
  801a0d:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a13:	83 c4 10             	add    $0x10,%esp
  801a16:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a1b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a1e:	c9                   	leave  
  801a1f:	c3                   	ret    

00801a20 <devfile_write>:
{
  801a20:	f3 0f 1e fb          	endbr32 
  801a24:	55                   	push   %ebp
  801a25:	89 e5                	mov    %esp,%ebp
  801a27:	83 ec 0c             	sub    $0xc,%esp
  801a2a:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a2d:	8b 55 08             	mov    0x8(%ebp),%edx
  801a30:	8b 52 0c             	mov    0xc(%edx),%edx
  801a33:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801a39:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a3e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a43:	0f 47 c2             	cmova  %edx,%eax
  801a46:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801a4b:	50                   	push   %eax
  801a4c:	ff 75 0c             	pushl  0xc(%ebp)
  801a4f:	68 08 50 80 00       	push   $0x805008
  801a54:	e8 96 ee ff ff       	call   8008ef <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801a59:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5e:	b8 04 00 00 00       	mov    $0x4,%eax
  801a63:	e8 ba fe ff ff       	call   801922 <fsipc>
}
  801a68:	c9                   	leave  
  801a69:	c3                   	ret    

00801a6a <devfile_read>:
{
  801a6a:	f3 0f 1e fb          	endbr32 
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	56                   	push   %esi
  801a72:	53                   	push   %ebx
  801a73:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801a76:	8b 45 08             	mov    0x8(%ebp),%eax
  801a79:	8b 40 0c             	mov    0xc(%eax),%eax
  801a7c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801a81:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801a87:	ba 00 00 00 00       	mov    $0x0,%edx
  801a8c:	b8 03 00 00 00       	mov    $0x3,%eax
  801a91:	e8 8c fe ff ff       	call   801922 <fsipc>
  801a96:	89 c3                	mov    %eax,%ebx
  801a98:	85 c0                	test   %eax,%eax
  801a9a:	78 1f                	js     801abb <devfile_read+0x51>
	assert(r <= n);
  801a9c:	39 f0                	cmp    %esi,%eax
  801a9e:	77 24                	ja     801ac4 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801aa0:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801aa5:	7f 33                	jg     801ada <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801aa7:	83 ec 04             	sub    $0x4,%esp
  801aaa:	50                   	push   %eax
  801aab:	68 00 50 80 00       	push   $0x805000
  801ab0:	ff 75 0c             	pushl  0xc(%ebp)
  801ab3:	e8 37 ee ff ff       	call   8008ef <memmove>
	return r;
  801ab8:	83 c4 10             	add    $0x10,%esp
}
  801abb:	89 d8                	mov    %ebx,%eax
  801abd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac0:	5b                   	pop    %ebx
  801ac1:	5e                   	pop    %esi
  801ac2:	5d                   	pop    %ebp
  801ac3:	c3                   	ret    
	assert(r <= n);
  801ac4:	68 10 2a 80 00       	push   $0x802a10
  801ac9:	68 17 2a 80 00       	push   $0x802a17
  801ace:	6a 7c                	push   $0x7c
  801ad0:	68 2c 2a 80 00       	push   $0x802a2c
  801ad5:	e8 be 05 00 00       	call   802098 <_panic>
	assert(r <= PGSIZE);
  801ada:	68 37 2a 80 00       	push   $0x802a37
  801adf:	68 17 2a 80 00       	push   $0x802a17
  801ae4:	6a 7d                	push   $0x7d
  801ae6:	68 2c 2a 80 00       	push   $0x802a2c
  801aeb:	e8 a8 05 00 00       	call   802098 <_panic>

00801af0 <open>:
{
  801af0:	f3 0f 1e fb          	endbr32 
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	56                   	push   %esi
  801af8:	53                   	push   %ebx
  801af9:	83 ec 1c             	sub    $0x1c,%esp
  801afc:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801aff:	56                   	push   %esi
  801b00:	e8 ef eb ff ff       	call   8006f4 <strlen>
  801b05:	83 c4 10             	add    $0x10,%esp
  801b08:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b0d:	7f 6c                	jg     801b7b <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801b0f:	83 ec 0c             	sub    $0xc,%esp
  801b12:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b15:	50                   	push   %eax
  801b16:	e8 67 f8 ff ff       	call   801382 <fd_alloc>
  801b1b:	89 c3                	mov    %eax,%ebx
  801b1d:	83 c4 10             	add    $0x10,%esp
  801b20:	85 c0                	test   %eax,%eax
  801b22:	78 3c                	js     801b60 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801b24:	83 ec 08             	sub    $0x8,%esp
  801b27:	56                   	push   %esi
  801b28:	68 00 50 80 00       	push   $0x805000
  801b2d:	e8 05 ec ff ff       	call   800737 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b32:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b35:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b3a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b3d:	b8 01 00 00 00       	mov    $0x1,%eax
  801b42:	e8 db fd ff ff       	call   801922 <fsipc>
  801b47:	89 c3                	mov    %eax,%ebx
  801b49:	83 c4 10             	add    $0x10,%esp
  801b4c:	85 c0                	test   %eax,%eax
  801b4e:	78 19                	js     801b69 <open+0x79>
	return fd2num(fd);
  801b50:	83 ec 0c             	sub    $0xc,%esp
  801b53:	ff 75 f4             	pushl  -0xc(%ebp)
  801b56:	e8 f4 f7 ff ff       	call   80134f <fd2num>
  801b5b:	89 c3                	mov    %eax,%ebx
  801b5d:	83 c4 10             	add    $0x10,%esp
}
  801b60:	89 d8                	mov    %ebx,%eax
  801b62:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b65:	5b                   	pop    %ebx
  801b66:	5e                   	pop    %esi
  801b67:	5d                   	pop    %ebp
  801b68:	c3                   	ret    
		fd_close(fd, 0);
  801b69:	83 ec 08             	sub    $0x8,%esp
  801b6c:	6a 00                	push   $0x0
  801b6e:	ff 75 f4             	pushl  -0xc(%ebp)
  801b71:	e8 10 f9 ff ff       	call   801486 <fd_close>
		return r;
  801b76:	83 c4 10             	add    $0x10,%esp
  801b79:	eb e5                	jmp    801b60 <open+0x70>
		return -E_BAD_PATH;
  801b7b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801b80:	eb de                	jmp    801b60 <open+0x70>

00801b82 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801b82:	f3 0f 1e fb          	endbr32 
  801b86:	55                   	push   %ebp
  801b87:	89 e5                	mov    %esp,%ebp
  801b89:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801b8c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b91:	b8 08 00 00 00       	mov    $0x8,%eax
  801b96:	e8 87 fd ff ff       	call   801922 <fsipc>
}
  801b9b:	c9                   	leave  
  801b9c:	c3                   	ret    

00801b9d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801b9d:	f3 0f 1e fb          	endbr32 
  801ba1:	55                   	push   %ebp
  801ba2:	89 e5                	mov    %esp,%ebp
  801ba4:	56                   	push   %esi
  801ba5:	53                   	push   %ebx
  801ba6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ba9:	83 ec 0c             	sub    $0xc,%esp
  801bac:	ff 75 08             	pushl  0x8(%ebp)
  801baf:	e8 af f7 ff ff       	call   801363 <fd2data>
  801bb4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bb6:	83 c4 08             	add    $0x8,%esp
  801bb9:	68 43 2a 80 00       	push   $0x802a43
  801bbe:	53                   	push   %ebx
  801bbf:	e8 73 eb ff ff       	call   800737 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801bc4:	8b 46 04             	mov    0x4(%esi),%eax
  801bc7:	2b 06                	sub    (%esi),%eax
  801bc9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801bcf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801bd6:	00 00 00 
	stat->st_dev = &devpipe;
  801bd9:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801be0:	30 80 00 
	return 0;
}
  801be3:	b8 00 00 00 00       	mov    $0x0,%eax
  801be8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801beb:	5b                   	pop    %ebx
  801bec:	5e                   	pop    %esi
  801bed:	5d                   	pop    %ebp
  801bee:	c3                   	ret    

00801bef <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801bef:	f3 0f 1e fb          	endbr32 
  801bf3:	55                   	push   %ebp
  801bf4:	89 e5                	mov    %esp,%ebp
  801bf6:	53                   	push   %ebx
  801bf7:	83 ec 0c             	sub    $0xc,%esp
  801bfa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801bfd:	53                   	push   %ebx
  801bfe:	6a 00                	push   $0x0
  801c00:	e8 0c f0 ff ff       	call   800c11 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c05:	89 1c 24             	mov    %ebx,(%esp)
  801c08:	e8 56 f7 ff ff       	call   801363 <fd2data>
  801c0d:	83 c4 08             	add    $0x8,%esp
  801c10:	50                   	push   %eax
  801c11:	6a 00                	push   $0x0
  801c13:	e8 f9 ef ff ff       	call   800c11 <sys_page_unmap>
}
  801c18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c1b:	c9                   	leave  
  801c1c:	c3                   	ret    

00801c1d <_pipeisclosed>:
{
  801c1d:	55                   	push   %ebp
  801c1e:	89 e5                	mov    %esp,%ebp
  801c20:	57                   	push   %edi
  801c21:	56                   	push   %esi
  801c22:	53                   	push   %ebx
  801c23:	83 ec 1c             	sub    $0x1c,%esp
  801c26:	89 c7                	mov    %eax,%edi
  801c28:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801c2a:	a1 04 40 80 00       	mov    0x804004,%eax
  801c2f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c32:	83 ec 0c             	sub    $0xc,%esp
  801c35:	57                   	push   %edi
  801c36:	e8 2a 05 00 00       	call   802165 <pageref>
  801c3b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c3e:	89 34 24             	mov    %esi,(%esp)
  801c41:	e8 1f 05 00 00       	call   802165 <pageref>
		nn = thisenv->env_runs;
  801c46:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801c4c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c4f:	83 c4 10             	add    $0x10,%esp
  801c52:	39 cb                	cmp    %ecx,%ebx
  801c54:	74 1b                	je     801c71 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801c56:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c59:	75 cf                	jne    801c2a <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c5b:	8b 42 58             	mov    0x58(%edx),%eax
  801c5e:	6a 01                	push   $0x1
  801c60:	50                   	push   %eax
  801c61:	53                   	push   %ebx
  801c62:	68 4a 2a 80 00       	push   $0x802a4a
  801c67:	e8 61 e5 ff ff       	call   8001cd <cprintf>
  801c6c:	83 c4 10             	add    $0x10,%esp
  801c6f:	eb b9                	jmp    801c2a <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801c71:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c74:	0f 94 c0             	sete   %al
  801c77:	0f b6 c0             	movzbl %al,%eax
}
  801c7a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c7d:	5b                   	pop    %ebx
  801c7e:	5e                   	pop    %esi
  801c7f:	5f                   	pop    %edi
  801c80:	5d                   	pop    %ebp
  801c81:	c3                   	ret    

00801c82 <devpipe_write>:
{
  801c82:	f3 0f 1e fb          	endbr32 
  801c86:	55                   	push   %ebp
  801c87:	89 e5                	mov    %esp,%ebp
  801c89:	57                   	push   %edi
  801c8a:	56                   	push   %esi
  801c8b:	53                   	push   %ebx
  801c8c:	83 ec 28             	sub    $0x28,%esp
  801c8f:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801c92:	56                   	push   %esi
  801c93:	e8 cb f6 ff ff       	call   801363 <fd2data>
  801c98:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c9a:	83 c4 10             	add    $0x10,%esp
  801c9d:	bf 00 00 00 00       	mov    $0x0,%edi
  801ca2:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ca5:	74 4f                	je     801cf6 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801ca7:	8b 43 04             	mov    0x4(%ebx),%eax
  801caa:	8b 0b                	mov    (%ebx),%ecx
  801cac:	8d 51 20             	lea    0x20(%ecx),%edx
  801caf:	39 d0                	cmp    %edx,%eax
  801cb1:	72 14                	jb     801cc7 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801cb3:	89 da                	mov    %ebx,%edx
  801cb5:	89 f0                	mov    %esi,%eax
  801cb7:	e8 61 ff ff ff       	call   801c1d <_pipeisclosed>
  801cbc:	85 c0                	test   %eax,%eax
  801cbe:	75 3b                	jne    801cfb <devpipe_write+0x79>
			sys_yield();
  801cc0:	e8 cf ee ff ff       	call   800b94 <sys_yield>
  801cc5:	eb e0                	jmp    801ca7 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801cc7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cca:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801cce:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801cd1:	89 c2                	mov    %eax,%edx
  801cd3:	c1 fa 1f             	sar    $0x1f,%edx
  801cd6:	89 d1                	mov    %edx,%ecx
  801cd8:	c1 e9 1b             	shr    $0x1b,%ecx
  801cdb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801cde:	83 e2 1f             	and    $0x1f,%edx
  801ce1:	29 ca                	sub    %ecx,%edx
  801ce3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ce7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ceb:	83 c0 01             	add    $0x1,%eax
  801cee:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801cf1:	83 c7 01             	add    $0x1,%edi
  801cf4:	eb ac                	jmp    801ca2 <devpipe_write+0x20>
	return i;
  801cf6:	8b 45 10             	mov    0x10(%ebp),%eax
  801cf9:	eb 05                	jmp    801d00 <devpipe_write+0x7e>
				return 0;
  801cfb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d03:	5b                   	pop    %ebx
  801d04:	5e                   	pop    %esi
  801d05:	5f                   	pop    %edi
  801d06:	5d                   	pop    %ebp
  801d07:	c3                   	ret    

00801d08 <devpipe_read>:
{
  801d08:	f3 0f 1e fb          	endbr32 
  801d0c:	55                   	push   %ebp
  801d0d:	89 e5                	mov    %esp,%ebp
  801d0f:	57                   	push   %edi
  801d10:	56                   	push   %esi
  801d11:	53                   	push   %ebx
  801d12:	83 ec 18             	sub    $0x18,%esp
  801d15:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801d18:	57                   	push   %edi
  801d19:	e8 45 f6 ff ff       	call   801363 <fd2data>
  801d1e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d20:	83 c4 10             	add    $0x10,%esp
  801d23:	be 00 00 00 00       	mov    $0x0,%esi
  801d28:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d2b:	75 14                	jne    801d41 <devpipe_read+0x39>
	return i;
  801d2d:	8b 45 10             	mov    0x10(%ebp),%eax
  801d30:	eb 02                	jmp    801d34 <devpipe_read+0x2c>
				return i;
  801d32:	89 f0                	mov    %esi,%eax
}
  801d34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d37:	5b                   	pop    %ebx
  801d38:	5e                   	pop    %esi
  801d39:	5f                   	pop    %edi
  801d3a:	5d                   	pop    %ebp
  801d3b:	c3                   	ret    
			sys_yield();
  801d3c:	e8 53 ee ff ff       	call   800b94 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801d41:	8b 03                	mov    (%ebx),%eax
  801d43:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d46:	75 18                	jne    801d60 <devpipe_read+0x58>
			if (i > 0)
  801d48:	85 f6                	test   %esi,%esi
  801d4a:	75 e6                	jne    801d32 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801d4c:	89 da                	mov    %ebx,%edx
  801d4e:	89 f8                	mov    %edi,%eax
  801d50:	e8 c8 fe ff ff       	call   801c1d <_pipeisclosed>
  801d55:	85 c0                	test   %eax,%eax
  801d57:	74 e3                	je     801d3c <devpipe_read+0x34>
				return 0;
  801d59:	b8 00 00 00 00       	mov    $0x0,%eax
  801d5e:	eb d4                	jmp    801d34 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801d60:	99                   	cltd   
  801d61:	c1 ea 1b             	shr    $0x1b,%edx
  801d64:	01 d0                	add    %edx,%eax
  801d66:	83 e0 1f             	and    $0x1f,%eax
  801d69:	29 d0                	sub    %edx,%eax
  801d6b:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801d70:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d73:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801d76:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801d79:	83 c6 01             	add    $0x1,%esi
  801d7c:	eb aa                	jmp    801d28 <devpipe_read+0x20>

00801d7e <pipe>:
{
  801d7e:	f3 0f 1e fb          	endbr32 
  801d82:	55                   	push   %ebp
  801d83:	89 e5                	mov    %esp,%ebp
  801d85:	56                   	push   %esi
  801d86:	53                   	push   %ebx
  801d87:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801d8a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801d8d:	50                   	push   %eax
  801d8e:	e8 ef f5 ff ff       	call   801382 <fd_alloc>
  801d93:	89 c3                	mov    %eax,%ebx
  801d95:	83 c4 10             	add    $0x10,%esp
  801d98:	85 c0                	test   %eax,%eax
  801d9a:	0f 88 23 01 00 00    	js     801ec3 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801da0:	83 ec 04             	sub    $0x4,%esp
  801da3:	68 07 04 00 00       	push   $0x407
  801da8:	ff 75 f4             	pushl  -0xc(%ebp)
  801dab:	6a 00                	push   $0x0
  801dad:	e8 0d ee ff ff       	call   800bbf <sys_page_alloc>
  801db2:	89 c3                	mov    %eax,%ebx
  801db4:	83 c4 10             	add    $0x10,%esp
  801db7:	85 c0                	test   %eax,%eax
  801db9:	0f 88 04 01 00 00    	js     801ec3 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801dbf:	83 ec 0c             	sub    $0xc,%esp
  801dc2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801dc5:	50                   	push   %eax
  801dc6:	e8 b7 f5 ff ff       	call   801382 <fd_alloc>
  801dcb:	89 c3                	mov    %eax,%ebx
  801dcd:	83 c4 10             	add    $0x10,%esp
  801dd0:	85 c0                	test   %eax,%eax
  801dd2:	0f 88 db 00 00 00    	js     801eb3 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801dd8:	83 ec 04             	sub    $0x4,%esp
  801ddb:	68 07 04 00 00       	push   $0x407
  801de0:	ff 75 f0             	pushl  -0x10(%ebp)
  801de3:	6a 00                	push   $0x0
  801de5:	e8 d5 ed ff ff       	call   800bbf <sys_page_alloc>
  801dea:	89 c3                	mov    %eax,%ebx
  801dec:	83 c4 10             	add    $0x10,%esp
  801def:	85 c0                	test   %eax,%eax
  801df1:	0f 88 bc 00 00 00    	js     801eb3 <pipe+0x135>
	va = fd2data(fd0);
  801df7:	83 ec 0c             	sub    $0xc,%esp
  801dfa:	ff 75 f4             	pushl  -0xc(%ebp)
  801dfd:	e8 61 f5 ff ff       	call   801363 <fd2data>
  801e02:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e04:	83 c4 0c             	add    $0xc,%esp
  801e07:	68 07 04 00 00       	push   $0x407
  801e0c:	50                   	push   %eax
  801e0d:	6a 00                	push   $0x0
  801e0f:	e8 ab ed ff ff       	call   800bbf <sys_page_alloc>
  801e14:	89 c3                	mov    %eax,%ebx
  801e16:	83 c4 10             	add    $0x10,%esp
  801e19:	85 c0                	test   %eax,%eax
  801e1b:	0f 88 82 00 00 00    	js     801ea3 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e21:	83 ec 0c             	sub    $0xc,%esp
  801e24:	ff 75 f0             	pushl  -0x10(%ebp)
  801e27:	e8 37 f5 ff ff       	call   801363 <fd2data>
  801e2c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e33:	50                   	push   %eax
  801e34:	6a 00                	push   $0x0
  801e36:	56                   	push   %esi
  801e37:	6a 00                	push   $0x0
  801e39:	e8 a9 ed ff ff       	call   800be7 <sys_page_map>
  801e3e:	89 c3                	mov    %eax,%ebx
  801e40:	83 c4 20             	add    $0x20,%esp
  801e43:	85 c0                	test   %eax,%eax
  801e45:	78 4e                	js     801e95 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801e47:	a1 20 30 80 00       	mov    0x803020,%eax
  801e4c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e4f:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801e51:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e54:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801e5b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801e5e:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801e60:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801e63:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801e6a:	83 ec 0c             	sub    $0xc,%esp
  801e6d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e70:	e8 da f4 ff ff       	call   80134f <fd2num>
  801e75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e78:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801e7a:	83 c4 04             	add    $0x4,%esp
  801e7d:	ff 75 f0             	pushl  -0x10(%ebp)
  801e80:	e8 ca f4 ff ff       	call   80134f <fd2num>
  801e85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801e88:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801e8b:	83 c4 10             	add    $0x10,%esp
  801e8e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801e93:	eb 2e                	jmp    801ec3 <pipe+0x145>
	sys_page_unmap(0, va);
  801e95:	83 ec 08             	sub    $0x8,%esp
  801e98:	56                   	push   %esi
  801e99:	6a 00                	push   $0x0
  801e9b:	e8 71 ed ff ff       	call   800c11 <sys_page_unmap>
  801ea0:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801ea3:	83 ec 08             	sub    $0x8,%esp
  801ea6:	ff 75 f0             	pushl  -0x10(%ebp)
  801ea9:	6a 00                	push   $0x0
  801eab:	e8 61 ed ff ff       	call   800c11 <sys_page_unmap>
  801eb0:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801eb3:	83 ec 08             	sub    $0x8,%esp
  801eb6:	ff 75 f4             	pushl  -0xc(%ebp)
  801eb9:	6a 00                	push   $0x0
  801ebb:	e8 51 ed ff ff       	call   800c11 <sys_page_unmap>
  801ec0:	83 c4 10             	add    $0x10,%esp
}
  801ec3:	89 d8                	mov    %ebx,%eax
  801ec5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ec8:	5b                   	pop    %ebx
  801ec9:	5e                   	pop    %esi
  801eca:	5d                   	pop    %ebp
  801ecb:	c3                   	ret    

00801ecc <pipeisclosed>:
{
  801ecc:	f3 0f 1e fb          	endbr32 
  801ed0:	55                   	push   %ebp
  801ed1:	89 e5                	mov    %esp,%ebp
  801ed3:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ed6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed9:	50                   	push   %eax
  801eda:	ff 75 08             	pushl  0x8(%ebp)
  801edd:	e8 f6 f4 ff ff       	call   8013d8 <fd_lookup>
  801ee2:	83 c4 10             	add    $0x10,%esp
  801ee5:	85 c0                	test   %eax,%eax
  801ee7:	78 18                	js     801f01 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801ee9:	83 ec 0c             	sub    $0xc,%esp
  801eec:	ff 75 f4             	pushl  -0xc(%ebp)
  801eef:	e8 6f f4 ff ff       	call   801363 <fd2data>
  801ef4:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801ef6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801ef9:	e8 1f fd ff ff       	call   801c1d <_pipeisclosed>
  801efe:	83 c4 10             	add    $0x10,%esp
}
  801f01:	c9                   	leave  
  801f02:	c3                   	ret    

00801f03 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f03:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801f07:	b8 00 00 00 00       	mov    $0x0,%eax
  801f0c:	c3                   	ret    

00801f0d <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f0d:	f3 0f 1e fb          	endbr32 
  801f11:	55                   	push   %ebp
  801f12:	89 e5                	mov    %esp,%ebp
  801f14:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f17:	68 62 2a 80 00       	push   $0x802a62
  801f1c:	ff 75 0c             	pushl  0xc(%ebp)
  801f1f:	e8 13 e8 ff ff       	call   800737 <strcpy>
	return 0;
}
  801f24:	b8 00 00 00 00       	mov    $0x0,%eax
  801f29:	c9                   	leave  
  801f2a:	c3                   	ret    

00801f2b <devcons_write>:
{
  801f2b:	f3 0f 1e fb          	endbr32 
  801f2f:	55                   	push   %ebp
  801f30:	89 e5                	mov    %esp,%ebp
  801f32:	57                   	push   %edi
  801f33:	56                   	push   %esi
  801f34:	53                   	push   %ebx
  801f35:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801f3b:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f40:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801f46:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f49:	73 31                	jae    801f7c <devcons_write+0x51>
		m = n - tot;
  801f4b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f4e:	29 f3                	sub    %esi,%ebx
  801f50:	83 fb 7f             	cmp    $0x7f,%ebx
  801f53:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801f58:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f5b:	83 ec 04             	sub    $0x4,%esp
  801f5e:	53                   	push   %ebx
  801f5f:	89 f0                	mov    %esi,%eax
  801f61:	03 45 0c             	add    0xc(%ebp),%eax
  801f64:	50                   	push   %eax
  801f65:	57                   	push   %edi
  801f66:	e8 84 e9 ff ff       	call   8008ef <memmove>
		sys_cputs(buf, m);
  801f6b:	83 c4 08             	add    $0x8,%esp
  801f6e:	53                   	push   %ebx
  801f6f:	57                   	push   %edi
  801f70:	e8 7f eb ff ff       	call   800af4 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801f75:	01 de                	add    %ebx,%esi
  801f77:	83 c4 10             	add    $0x10,%esp
  801f7a:	eb ca                	jmp    801f46 <devcons_write+0x1b>
}
  801f7c:	89 f0                	mov    %esi,%eax
  801f7e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f81:	5b                   	pop    %ebx
  801f82:	5e                   	pop    %esi
  801f83:	5f                   	pop    %edi
  801f84:	5d                   	pop    %ebp
  801f85:	c3                   	ret    

00801f86 <devcons_read>:
{
  801f86:	f3 0f 1e fb          	endbr32 
  801f8a:	55                   	push   %ebp
  801f8b:	89 e5                	mov    %esp,%ebp
  801f8d:	83 ec 08             	sub    $0x8,%esp
  801f90:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801f95:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801f99:	74 21                	je     801fbc <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801f9b:	e8 7e eb ff ff       	call   800b1e <sys_cgetc>
  801fa0:	85 c0                	test   %eax,%eax
  801fa2:	75 07                	jne    801fab <devcons_read+0x25>
		sys_yield();
  801fa4:	e8 eb eb ff ff       	call   800b94 <sys_yield>
  801fa9:	eb f0                	jmp    801f9b <devcons_read+0x15>
	if (c < 0)
  801fab:	78 0f                	js     801fbc <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801fad:	83 f8 04             	cmp    $0x4,%eax
  801fb0:	74 0c                	je     801fbe <devcons_read+0x38>
	*(char*)vbuf = c;
  801fb2:	8b 55 0c             	mov    0xc(%ebp),%edx
  801fb5:	88 02                	mov    %al,(%edx)
	return 1;
  801fb7:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801fbc:	c9                   	leave  
  801fbd:	c3                   	ret    
		return 0;
  801fbe:	b8 00 00 00 00       	mov    $0x0,%eax
  801fc3:	eb f7                	jmp    801fbc <devcons_read+0x36>

00801fc5 <cputchar>:
{
  801fc5:	f3 0f 1e fb          	endbr32 
  801fc9:	55                   	push   %ebp
  801fca:	89 e5                	mov    %esp,%ebp
  801fcc:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801fcf:	8b 45 08             	mov    0x8(%ebp),%eax
  801fd2:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801fd5:	6a 01                	push   $0x1
  801fd7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801fda:	50                   	push   %eax
  801fdb:	e8 14 eb ff ff       	call   800af4 <sys_cputs>
}
  801fe0:	83 c4 10             	add    $0x10,%esp
  801fe3:	c9                   	leave  
  801fe4:	c3                   	ret    

00801fe5 <getchar>:
{
  801fe5:	f3 0f 1e fb          	endbr32 
  801fe9:	55                   	push   %ebp
  801fea:	89 e5                	mov    %esp,%ebp
  801fec:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801fef:	6a 01                	push   $0x1
  801ff1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801ff4:	50                   	push   %eax
  801ff5:	6a 00                	push   $0x0
  801ff7:	e8 5f f6 ff ff       	call   80165b <read>
	if (r < 0)
  801ffc:	83 c4 10             	add    $0x10,%esp
  801fff:	85 c0                	test   %eax,%eax
  802001:	78 06                	js     802009 <getchar+0x24>
	if (r < 1)
  802003:	74 06                	je     80200b <getchar+0x26>
	return c;
  802005:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  802009:	c9                   	leave  
  80200a:	c3                   	ret    
		return -E_EOF;
  80200b:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802010:	eb f7                	jmp    802009 <getchar+0x24>

00802012 <iscons>:
{
  802012:	f3 0f 1e fb          	endbr32 
  802016:	55                   	push   %ebp
  802017:	89 e5                	mov    %esp,%ebp
  802019:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80201c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80201f:	50                   	push   %eax
  802020:	ff 75 08             	pushl  0x8(%ebp)
  802023:	e8 b0 f3 ff ff       	call   8013d8 <fd_lookup>
  802028:	83 c4 10             	add    $0x10,%esp
  80202b:	85 c0                	test   %eax,%eax
  80202d:	78 11                	js     802040 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80202f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802032:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  802038:	39 10                	cmp    %edx,(%eax)
  80203a:	0f 94 c0             	sete   %al
  80203d:	0f b6 c0             	movzbl %al,%eax
}
  802040:	c9                   	leave  
  802041:	c3                   	ret    

00802042 <opencons>:
{
  802042:	f3 0f 1e fb          	endbr32 
  802046:	55                   	push   %ebp
  802047:	89 e5                	mov    %esp,%ebp
  802049:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80204c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80204f:	50                   	push   %eax
  802050:	e8 2d f3 ff ff       	call   801382 <fd_alloc>
  802055:	83 c4 10             	add    $0x10,%esp
  802058:	85 c0                	test   %eax,%eax
  80205a:	78 3a                	js     802096 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80205c:	83 ec 04             	sub    $0x4,%esp
  80205f:	68 07 04 00 00       	push   $0x407
  802064:	ff 75 f4             	pushl  -0xc(%ebp)
  802067:	6a 00                	push   $0x0
  802069:	e8 51 eb ff ff       	call   800bbf <sys_page_alloc>
  80206e:	83 c4 10             	add    $0x10,%esp
  802071:	85 c0                	test   %eax,%eax
  802073:	78 21                	js     802096 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  802075:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802078:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80207e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802080:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802083:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80208a:	83 ec 0c             	sub    $0xc,%esp
  80208d:	50                   	push   %eax
  80208e:	e8 bc f2 ff ff       	call   80134f <fd2num>
  802093:	83 c4 10             	add    $0x10,%esp
}
  802096:	c9                   	leave  
  802097:	c3                   	ret    

00802098 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802098:	f3 0f 1e fb          	endbr32 
  80209c:	55                   	push   %ebp
  80209d:	89 e5                	mov    %esp,%ebp
  80209f:	56                   	push   %esi
  8020a0:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8020a1:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8020a4:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8020aa:	e8 bd ea ff ff       	call   800b6c <sys_getenvid>
  8020af:	83 ec 0c             	sub    $0xc,%esp
  8020b2:	ff 75 0c             	pushl  0xc(%ebp)
  8020b5:	ff 75 08             	pushl  0x8(%ebp)
  8020b8:	56                   	push   %esi
  8020b9:	50                   	push   %eax
  8020ba:	68 70 2a 80 00       	push   $0x802a70
  8020bf:	e8 09 e1 ff ff       	call   8001cd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8020c4:	83 c4 18             	add    $0x18,%esp
  8020c7:	53                   	push   %ebx
  8020c8:	ff 75 10             	pushl  0x10(%ebp)
  8020cb:	e8 a8 e0 ff ff       	call   800178 <vcprintf>
	cprintf("\n");
  8020d0:	c7 04 24 5b 2a 80 00 	movl   $0x802a5b,(%esp)
  8020d7:	e8 f1 e0 ff ff       	call   8001cd <cprintf>
  8020dc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8020df:	cc                   	int3   
  8020e0:	eb fd                	jmp    8020df <_panic+0x47>

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
  802107:	e8 7a eb ff ff       	call   800c86 <sys_env_set_pgfault_upcall>
}
  80210c:	83 c4 10             	add    $0x10,%esp
  80210f:	c9                   	leave  
  802110:	c3                   	ret    
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
  802111:	83 ec 04             	sub    $0x4,%esp
  802114:	6a 02                	push   $0x2
  802116:	68 00 f0 bf ee       	push   $0xeebff000
  80211b:	6a 00                	push   $0x0
  80211d:	e8 9d ea ff ff       	call   800bbf <sys_page_alloc>
  802122:	83 c4 10             	add    $0x10,%esp
  802125:	85 c0                	test   %eax,%eax
  802127:	79 cc                	jns    8020f5 <set_pgfault_handler+0x13>
  802129:	83 ec 04             	sub    $0x4,%esp
  80212c:	68 93 2a 80 00       	push   $0x802a93
  802131:	6a 20                	push   $0x20
  802133:	68 ae 2a 80 00       	push   $0x802aae
  802138:	e8 5b ff ff ff       	call   802098 <_panic>

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

00802165 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802165:	f3 0f 1e fb          	endbr32 
  802169:	55                   	push   %ebp
  80216a:	89 e5                	mov    %esp,%ebp
  80216c:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80216f:	89 c2                	mov    %eax,%edx
  802171:	c1 ea 16             	shr    $0x16,%edx
  802174:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80217b:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802180:	f6 c1 01             	test   $0x1,%cl
  802183:	74 1c                	je     8021a1 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802185:	c1 e8 0c             	shr    $0xc,%eax
  802188:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80218f:	a8 01                	test   $0x1,%al
  802191:	74 0e                	je     8021a1 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802193:	c1 e8 0c             	shr    $0xc,%eax
  802196:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80219d:	ef 
  80219e:	0f b7 d2             	movzwl %dx,%edx
}
  8021a1:	89 d0                	mov    %edx,%eax
  8021a3:	5d                   	pop    %ebp
  8021a4:	c3                   	ret    
  8021a5:	66 90                	xchg   %ax,%ax
  8021a7:	66 90                	xchg   %ax,%ax
  8021a9:	66 90                	xchg   %ax,%ax
  8021ab:	66 90                	xchg   %ax,%ax
  8021ad:	66 90                	xchg   %ax,%ax
  8021af:	90                   	nop

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
