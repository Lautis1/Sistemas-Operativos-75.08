
obj/user/pingpongs.debug:     formato del fichero elf32-i386


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
  80002c:	e8 d6 00 00 00       	call   800107 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

uint32_t val;

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 2c             	sub    $0x2c,%esp
	envid_t who;
	uint32_t i;

	i = 0;
	if ((who = sfork()) != 0) {
  800040:	e8 1f 12 00 00       	call   801264 <sfork>
  800045:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800048:	85 c0                	test   %eax,%eax
  80004a:	75 74                	jne    8000c0 <umain+0x8d>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
		ipc_send(who, 0, 0, 0);
	}

	while (1) {
		ipc_recv(&who, 0, 0);
  80004c:	83 ec 04             	sub    $0x4,%esp
  80004f:	6a 00                	push   $0x0
  800051:	6a 00                	push   $0x0
  800053:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800056:	50                   	push   %eax
  800057:	e8 26 12 00 00       	call   801282 <ipc_recv>
		cprintf("%x got %d from %x (thisenv is %p %x)\n", sys_getenvid(), val, who, thisenv, thisenv->env_id);
  80005c:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  800062:	8b 7b 48             	mov    0x48(%ebx),%edi
  800065:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  800068:	a1 04 40 80 00       	mov    0x804004,%eax
  80006d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800070:	e8 3a 0b 00 00       	call   800baf <sys_getenvid>
  800075:	83 c4 08             	add    $0x8,%esp
  800078:	57                   	push   %edi
  800079:	53                   	push   %ebx
  80007a:	56                   	push   %esi
  80007b:	ff 75 d4             	pushl  -0x2c(%ebp)
  80007e:	50                   	push   %eax
  80007f:	68 90 24 80 00       	push   $0x802490
  800084:	e8 87 01 00 00       	call   800210 <cprintf>
		if (val == 10)
  800089:	a1 04 40 80 00       	mov    0x804004,%eax
  80008e:	83 c4 20             	add    $0x20,%esp
  800091:	83 f8 0a             	cmp    $0xa,%eax
  800094:	74 22                	je     8000b8 <umain+0x85>
			return;
		++val;
  800096:	83 c0 01             	add    $0x1,%eax
  800099:	a3 04 40 80 00       	mov    %eax,0x804004
		ipc_send(who, 0, 0, 0);
  80009e:	6a 00                	push   $0x0
  8000a0:	6a 00                	push   $0x0
  8000a2:	6a 00                	push   $0x0
  8000a4:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000a7:	e8 44 12 00 00       	call   8012f0 <ipc_send>
		if (val == 10)
  8000ac:	83 c4 10             	add    $0x10,%esp
  8000af:	83 3d 04 40 80 00 0a 	cmpl   $0xa,0x804004
  8000b6:	75 94                	jne    80004c <umain+0x19>
			return;
	}

}
  8000b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    
		cprintf("i am %08x; thisenv is %p\n", sys_getenvid(), thisenv);
  8000c0:	8b 1d 08 40 80 00    	mov    0x804008,%ebx
  8000c6:	e8 e4 0a 00 00       	call   800baf <sys_getenvid>
  8000cb:	83 ec 04             	sub    $0x4,%esp
  8000ce:	53                   	push   %ebx
  8000cf:	50                   	push   %eax
  8000d0:	68 60 24 80 00       	push   $0x802460
  8000d5:	e8 36 01 00 00       	call   800210 <cprintf>
		cprintf("send 0 from %x to %x\n", sys_getenvid(), who);
  8000da:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
  8000dd:	e8 cd 0a 00 00       	call   800baf <sys_getenvid>
  8000e2:	83 c4 0c             	add    $0xc,%esp
  8000e5:	53                   	push   %ebx
  8000e6:	50                   	push   %eax
  8000e7:	68 7a 24 80 00       	push   $0x80247a
  8000ec:	e8 1f 01 00 00       	call   800210 <cprintf>
		ipc_send(who, 0, 0, 0);
  8000f1:	6a 00                	push   $0x0
  8000f3:	6a 00                	push   $0x0
  8000f5:	6a 00                	push   $0x0
  8000f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8000fa:	e8 f1 11 00 00       	call   8012f0 <ipc_send>
  8000ff:	83 c4 20             	add    $0x20,%esp
  800102:	e9 45 ff ff ff       	jmp    80004c <umain+0x19>

00800107 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800107:	f3 0f 1e fb          	endbr32 
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	56                   	push   %esi
  80010f:	53                   	push   %ebx
  800110:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800113:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800116:	e8 94 0a 00 00       	call   800baf <sys_getenvid>
	if (id >= 0)
  80011b:	85 c0                	test   %eax,%eax
  80011d:	78 12                	js     800131 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  80011f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800124:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800127:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80012c:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800131:	85 db                	test   %ebx,%ebx
  800133:	7e 07                	jle    80013c <libmain+0x35>
		binaryname = argv[0];
  800135:	8b 06                	mov    (%esi),%eax
  800137:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80013c:	83 ec 08             	sub    $0x8,%esp
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
  800141:	e8 ed fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800146:	e8 0a 00 00 00       	call   800155 <exit>
}
  80014b:	83 c4 10             	add    $0x10,%esp
  80014e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800151:	5b                   	pop    %ebx
  800152:	5e                   	pop    %esi
  800153:	5d                   	pop    %ebp
  800154:	c3                   	ret    

00800155 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800155:	f3 0f 1e fb          	endbr32 
  800159:	55                   	push   %ebp
  80015a:	89 e5                	mov    %esp,%ebp
  80015c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80015f:	e8 21 14 00 00       	call   801585 <close_all>
	sys_env_destroy(0);
  800164:	83 ec 0c             	sub    $0xc,%esp
  800167:	6a 00                	push   $0x0
  800169:	e8 1b 0a 00 00       	call   800b89 <sys_env_destroy>
}
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	c9                   	leave  
  800172:	c3                   	ret    

00800173 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800173:	f3 0f 1e fb          	endbr32 
  800177:	55                   	push   %ebp
  800178:	89 e5                	mov    %esp,%ebp
  80017a:	53                   	push   %ebx
  80017b:	83 ec 04             	sub    $0x4,%esp
  80017e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800181:	8b 13                	mov    (%ebx),%edx
  800183:	8d 42 01             	lea    0x1(%edx),%eax
  800186:	89 03                	mov    %eax,(%ebx)
  800188:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80018b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80018f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800194:	74 09                	je     80019f <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800196:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80019a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80019d:	c9                   	leave  
  80019e:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80019f:	83 ec 08             	sub    $0x8,%esp
  8001a2:	68 ff 00 00 00       	push   $0xff
  8001a7:	8d 43 08             	lea    0x8(%ebx),%eax
  8001aa:	50                   	push   %eax
  8001ab:	e8 87 09 00 00       	call   800b37 <sys_cputs>
		b->idx = 0;
  8001b0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001b6:	83 c4 10             	add    $0x10,%esp
  8001b9:	eb db                	jmp    800196 <putch+0x23>

008001bb <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001bb:	f3 0f 1e fb          	endbr32 
  8001bf:	55                   	push   %ebp
  8001c0:	89 e5                	mov    %esp,%ebp
  8001c2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001c8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001cf:	00 00 00 
	b.cnt = 0;
  8001d2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001d9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001dc:	ff 75 0c             	pushl  0xc(%ebp)
  8001df:	ff 75 08             	pushl  0x8(%ebp)
  8001e2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001e8:	50                   	push   %eax
  8001e9:	68 73 01 80 00       	push   $0x800173
  8001ee:	e8 80 01 00 00       	call   800373 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8001f3:	83 c4 08             	add    $0x8,%esp
  8001f6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8001fc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800202:	50                   	push   %eax
  800203:	e8 2f 09 00 00       	call   800b37 <sys_cputs>

	return b.cnt;
}
  800208:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80020e:	c9                   	leave  
  80020f:	c3                   	ret    

00800210 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800210:	f3 0f 1e fb          	endbr32 
  800214:	55                   	push   %ebp
  800215:	89 e5                	mov    %esp,%ebp
  800217:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80021a:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80021d:	50                   	push   %eax
  80021e:	ff 75 08             	pushl  0x8(%ebp)
  800221:	e8 95 ff ff ff       	call   8001bb <vcprintf>
	va_end(ap);

	return cnt;
}
  800226:	c9                   	leave  
  800227:	c3                   	ret    

00800228 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	57                   	push   %edi
  80022c:	56                   	push   %esi
  80022d:	53                   	push   %ebx
  80022e:	83 ec 1c             	sub    $0x1c,%esp
  800231:	89 c7                	mov    %eax,%edi
  800233:	89 d6                	mov    %edx,%esi
  800235:	8b 45 08             	mov    0x8(%ebp),%eax
  800238:	8b 55 0c             	mov    0xc(%ebp),%edx
  80023b:	89 d1                	mov    %edx,%ecx
  80023d:	89 c2                	mov    %eax,%edx
  80023f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800242:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800245:	8b 45 10             	mov    0x10(%ebp),%eax
  800248:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80024b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80024e:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800255:	39 c2                	cmp    %eax,%edx
  800257:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80025a:	72 3e                	jb     80029a <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80025c:	83 ec 0c             	sub    $0xc,%esp
  80025f:	ff 75 18             	pushl  0x18(%ebp)
  800262:	83 eb 01             	sub    $0x1,%ebx
  800265:	53                   	push   %ebx
  800266:	50                   	push   %eax
  800267:	83 ec 08             	sub    $0x8,%esp
  80026a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80026d:	ff 75 e0             	pushl  -0x20(%ebp)
  800270:	ff 75 dc             	pushl  -0x24(%ebp)
  800273:	ff 75 d8             	pushl  -0x28(%ebp)
  800276:	e8 75 1f 00 00       	call   8021f0 <__udivdi3>
  80027b:	83 c4 18             	add    $0x18,%esp
  80027e:	52                   	push   %edx
  80027f:	50                   	push   %eax
  800280:	89 f2                	mov    %esi,%edx
  800282:	89 f8                	mov    %edi,%eax
  800284:	e8 9f ff ff ff       	call   800228 <printnum>
  800289:	83 c4 20             	add    $0x20,%esp
  80028c:	eb 13                	jmp    8002a1 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80028e:	83 ec 08             	sub    $0x8,%esp
  800291:	56                   	push   %esi
  800292:	ff 75 18             	pushl  0x18(%ebp)
  800295:	ff d7                	call   *%edi
  800297:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80029a:	83 eb 01             	sub    $0x1,%ebx
  80029d:	85 db                	test   %ebx,%ebx
  80029f:	7f ed                	jg     80028e <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002a1:	83 ec 08             	sub    $0x8,%esp
  8002a4:	56                   	push   %esi
  8002a5:	83 ec 04             	sub    $0x4,%esp
  8002a8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002ab:	ff 75 e0             	pushl  -0x20(%ebp)
  8002ae:	ff 75 dc             	pushl  -0x24(%ebp)
  8002b1:	ff 75 d8             	pushl  -0x28(%ebp)
  8002b4:	e8 47 20 00 00       	call   802300 <__umoddi3>
  8002b9:	83 c4 14             	add    $0x14,%esp
  8002bc:	0f be 80 c0 24 80 00 	movsbl 0x8024c0(%eax),%eax
  8002c3:	50                   	push   %eax
  8002c4:	ff d7                	call   *%edi
}
  8002c6:	83 c4 10             	add    $0x10,%esp
  8002c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002cc:	5b                   	pop    %ebx
  8002cd:	5e                   	pop    %esi
  8002ce:	5f                   	pop    %edi
  8002cf:	5d                   	pop    %ebp
  8002d0:	c3                   	ret    

008002d1 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002d1:	83 fa 01             	cmp    $0x1,%edx
  8002d4:	7f 13                	jg     8002e9 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8002d6:	85 d2                	test   %edx,%edx
  8002d8:	74 1c                	je     8002f6 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8002da:	8b 10                	mov    (%eax),%edx
  8002dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002df:	89 08                	mov    %ecx,(%eax)
  8002e1:	8b 02                	mov    (%edx),%eax
  8002e3:	ba 00 00 00 00       	mov    $0x0,%edx
  8002e8:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8002e9:	8b 10                	mov    (%eax),%edx
  8002eb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8002ee:	89 08                	mov    %ecx,(%eax)
  8002f0:	8b 02                	mov    (%edx),%eax
  8002f2:	8b 52 04             	mov    0x4(%edx),%edx
  8002f5:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8002f6:	8b 10                	mov    (%eax),%edx
  8002f8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002fb:	89 08                	mov    %ecx,(%eax)
  8002fd:	8b 02                	mov    (%edx),%eax
  8002ff:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800304:	c3                   	ret    

00800305 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800305:	83 fa 01             	cmp    $0x1,%edx
  800308:	7f 0f                	jg     800319 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  80030a:	85 d2                	test   %edx,%edx
  80030c:	74 18                	je     800326 <getint+0x21>
		return va_arg(*ap, long);
  80030e:	8b 10                	mov    (%eax),%edx
  800310:	8d 4a 04             	lea    0x4(%edx),%ecx
  800313:	89 08                	mov    %ecx,(%eax)
  800315:	8b 02                	mov    (%edx),%eax
  800317:	99                   	cltd   
  800318:	c3                   	ret    
		return va_arg(*ap, long long);
  800319:	8b 10                	mov    (%eax),%edx
  80031b:	8d 4a 08             	lea    0x8(%edx),%ecx
  80031e:	89 08                	mov    %ecx,(%eax)
  800320:	8b 02                	mov    (%edx),%eax
  800322:	8b 52 04             	mov    0x4(%edx),%edx
  800325:	c3                   	ret    
	else
		return va_arg(*ap, int);
  800326:	8b 10                	mov    (%eax),%edx
  800328:	8d 4a 04             	lea    0x4(%edx),%ecx
  80032b:	89 08                	mov    %ecx,(%eax)
  80032d:	8b 02                	mov    (%edx),%eax
  80032f:	99                   	cltd   
}
  800330:	c3                   	ret    

00800331 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800331:	f3 0f 1e fb          	endbr32 
  800335:	55                   	push   %ebp
  800336:	89 e5                	mov    %esp,%ebp
  800338:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80033b:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80033f:	8b 10                	mov    (%eax),%edx
  800341:	3b 50 04             	cmp    0x4(%eax),%edx
  800344:	73 0a                	jae    800350 <sprintputch+0x1f>
		*b->buf++ = ch;
  800346:	8d 4a 01             	lea    0x1(%edx),%ecx
  800349:	89 08                	mov    %ecx,(%eax)
  80034b:	8b 45 08             	mov    0x8(%ebp),%eax
  80034e:	88 02                	mov    %al,(%edx)
}
  800350:	5d                   	pop    %ebp
  800351:	c3                   	ret    

00800352 <printfmt>:
{
  800352:	f3 0f 1e fb          	endbr32 
  800356:	55                   	push   %ebp
  800357:	89 e5                	mov    %esp,%ebp
  800359:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80035c:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80035f:	50                   	push   %eax
  800360:	ff 75 10             	pushl  0x10(%ebp)
  800363:	ff 75 0c             	pushl  0xc(%ebp)
  800366:	ff 75 08             	pushl  0x8(%ebp)
  800369:	e8 05 00 00 00       	call   800373 <vprintfmt>
}
  80036e:	83 c4 10             	add    $0x10,%esp
  800371:	c9                   	leave  
  800372:	c3                   	ret    

00800373 <vprintfmt>:
{
  800373:	f3 0f 1e fb          	endbr32 
  800377:	55                   	push   %ebp
  800378:	89 e5                	mov    %esp,%ebp
  80037a:	57                   	push   %edi
  80037b:	56                   	push   %esi
  80037c:	53                   	push   %ebx
  80037d:	83 ec 2c             	sub    $0x2c,%esp
  800380:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800383:	8b 75 0c             	mov    0xc(%ebp),%esi
  800386:	8b 7d 10             	mov    0x10(%ebp),%edi
  800389:	e9 86 02 00 00       	jmp    800614 <vprintfmt+0x2a1>
		padc = ' ';
  80038e:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800392:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800399:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003a0:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003a7:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003ac:	8d 47 01             	lea    0x1(%edi),%eax
  8003af:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003b2:	0f b6 17             	movzbl (%edi),%edx
  8003b5:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003b8:	3c 55                	cmp    $0x55,%al
  8003ba:	0f 87 df 02 00 00    	ja     80069f <vprintfmt+0x32c>
  8003c0:	0f b6 c0             	movzbl %al,%eax
  8003c3:	3e ff 24 85 00 26 80 	notrack jmp *0x802600(,%eax,4)
  8003ca:	00 
  8003cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003ce:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003d2:	eb d8                	jmp    8003ac <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003d7:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003db:	eb cf                	jmp    8003ac <vprintfmt+0x39>
  8003dd:	0f b6 d2             	movzbl %dl,%edx
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003e3:	b8 00 00 00 00       	mov    $0x0,%eax
  8003e8:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8003eb:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8003ee:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8003f2:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8003f5:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8003f8:	83 f9 09             	cmp    $0x9,%ecx
  8003fb:	77 52                	ja     80044f <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  8003fd:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800400:	eb e9                	jmp    8003eb <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800402:	8b 45 14             	mov    0x14(%ebp),%eax
  800405:	8d 50 04             	lea    0x4(%eax),%edx
  800408:	89 55 14             	mov    %edx,0x14(%ebp)
  80040b:	8b 00                	mov    (%eax),%eax
  80040d:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800410:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800413:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800417:	79 93                	jns    8003ac <vprintfmt+0x39>
				width = precision, precision = -1;
  800419:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80041c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80041f:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800426:	eb 84                	jmp    8003ac <vprintfmt+0x39>
  800428:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80042b:	85 c0                	test   %eax,%eax
  80042d:	ba 00 00 00 00       	mov    $0x0,%edx
  800432:	0f 49 d0             	cmovns %eax,%edx
  800435:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800438:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80043b:	e9 6c ff ff ff       	jmp    8003ac <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800440:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800443:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80044a:	e9 5d ff ff ff       	jmp    8003ac <vprintfmt+0x39>
  80044f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800452:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800455:	eb bc                	jmp    800413 <vprintfmt+0xa0>
			lflag++;
  800457:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80045a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80045d:	e9 4a ff ff ff       	jmp    8003ac <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800462:	8b 45 14             	mov    0x14(%ebp),%eax
  800465:	8d 50 04             	lea    0x4(%eax),%edx
  800468:	89 55 14             	mov    %edx,0x14(%ebp)
  80046b:	83 ec 08             	sub    $0x8,%esp
  80046e:	56                   	push   %esi
  80046f:	ff 30                	pushl  (%eax)
  800471:	ff d3                	call   *%ebx
			break;
  800473:	83 c4 10             	add    $0x10,%esp
  800476:	e9 96 01 00 00       	jmp    800611 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  80047b:	8b 45 14             	mov    0x14(%ebp),%eax
  80047e:	8d 50 04             	lea    0x4(%eax),%edx
  800481:	89 55 14             	mov    %edx,0x14(%ebp)
  800484:	8b 00                	mov    (%eax),%eax
  800486:	99                   	cltd   
  800487:	31 d0                	xor    %edx,%eax
  800489:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80048b:	83 f8 0f             	cmp    $0xf,%eax
  80048e:	7f 20                	jg     8004b0 <vprintfmt+0x13d>
  800490:	8b 14 85 60 27 80 00 	mov    0x802760(,%eax,4),%edx
  800497:	85 d2                	test   %edx,%edx
  800499:	74 15                	je     8004b0 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  80049b:	52                   	push   %edx
  80049c:	68 89 2a 80 00       	push   $0x802a89
  8004a1:	56                   	push   %esi
  8004a2:	53                   	push   %ebx
  8004a3:	e8 aa fe ff ff       	call   800352 <printfmt>
  8004a8:	83 c4 10             	add    $0x10,%esp
  8004ab:	e9 61 01 00 00       	jmp    800611 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8004b0:	50                   	push   %eax
  8004b1:	68 d8 24 80 00       	push   $0x8024d8
  8004b6:	56                   	push   %esi
  8004b7:	53                   	push   %ebx
  8004b8:	e8 95 fe ff ff       	call   800352 <printfmt>
  8004bd:	83 c4 10             	add    $0x10,%esp
  8004c0:	e9 4c 01 00 00       	jmp    800611 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004c5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004c8:	8d 50 04             	lea    0x4(%eax),%edx
  8004cb:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ce:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8004d0:	85 c9                	test   %ecx,%ecx
  8004d2:	b8 d1 24 80 00       	mov    $0x8024d1,%eax
  8004d7:	0f 45 c1             	cmovne %ecx,%eax
  8004da:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004dd:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004e1:	7e 06                	jle    8004e9 <vprintfmt+0x176>
  8004e3:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004e7:	75 0d                	jne    8004f6 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004e9:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8004ec:	89 c7                	mov    %eax,%edi
  8004ee:	03 45 e0             	add    -0x20(%ebp),%eax
  8004f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004f4:	eb 57                	jmp    80054d <vprintfmt+0x1da>
  8004f6:	83 ec 08             	sub    $0x8,%esp
  8004f9:	ff 75 d8             	pushl  -0x28(%ebp)
  8004fc:	ff 75 cc             	pushl  -0x34(%ebp)
  8004ff:	e8 4f 02 00 00       	call   800753 <strnlen>
  800504:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800507:	29 c2                	sub    %eax,%edx
  800509:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80050c:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80050f:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800513:	89 5d 08             	mov    %ebx,0x8(%ebp)
  800516:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800518:	85 db                	test   %ebx,%ebx
  80051a:	7e 10                	jle    80052c <vprintfmt+0x1b9>
					putch(padc, putdat);
  80051c:	83 ec 08             	sub    $0x8,%esp
  80051f:	56                   	push   %esi
  800520:	57                   	push   %edi
  800521:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800524:	83 eb 01             	sub    $0x1,%ebx
  800527:	83 c4 10             	add    $0x10,%esp
  80052a:	eb ec                	jmp    800518 <vprintfmt+0x1a5>
  80052c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80052f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800532:	85 d2                	test   %edx,%edx
  800534:	b8 00 00 00 00       	mov    $0x0,%eax
  800539:	0f 49 c2             	cmovns %edx,%eax
  80053c:	29 c2                	sub    %eax,%edx
  80053e:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800541:	eb a6                	jmp    8004e9 <vprintfmt+0x176>
					putch(ch, putdat);
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	56                   	push   %esi
  800547:	52                   	push   %edx
  800548:	ff d3                	call   *%ebx
  80054a:	83 c4 10             	add    $0x10,%esp
  80054d:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800550:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800552:	83 c7 01             	add    $0x1,%edi
  800555:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800559:	0f be d0             	movsbl %al,%edx
  80055c:	85 d2                	test   %edx,%edx
  80055e:	74 42                	je     8005a2 <vprintfmt+0x22f>
  800560:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800564:	78 06                	js     80056c <vprintfmt+0x1f9>
  800566:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80056a:	78 1e                	js     80058a <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  80056c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800570:	74 d1                	je     800543 <vprintfmt+0x1d0>
  800572:	0f be c0             	movsbl %al,%eax
  800575:	83 e8 20             	sub    $0x20,%eax
  800578:	83 f8 5e             	cmp    $0x5e,%eax
  80057b:	76 c6                	jbe    800543 <vprintfmt+0x1d0>
					putch('?', putdat);
  80057d:	83 ec 08             	sub    $0x8,%esp
  800580:	56                   	push   %esi
  800581:	6a 3f                	push   $0x3f
  800583:	ff d3                	call   *%ebx
  800585:	83 c4 10             	add    $0x10,%esp
  800588:	eb c3                	jmp    80054d <vprintfmt+0x1da>
  80058a:	89 cf                	mov    %ecx,%edi
  80058c:	eb 0e                	jmp    80059c <vprintfmt+0x229>
				putch(' ', putdat);
  80058e:	83 ec 08             	sub    $0x8,%esp
  800591:	56                   	push   %esi
  800592:	6a 20                	push   $0x20
  800594:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800596:	83 ef 01             	sub    $0x1,%edi
  800599:	83 c4 10             	add    $0x10,%esp
  80059c:	85 ff                	test   %edi,%edi
  80059e:	7f ee                	jg     80058e <vprintfmt+0x21b>
  8005a0:	eb 6f                	jmp    800611 <vprintfmt+0x29e>
  8005a2:	89 cf                	mov    %ecx,%edi
  8005a4:	eb f6                	jmp    80059c <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8005a6:	89 ca                	mov    %ecx,%edx
  8005a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005ab:	e8 55 fd ff ff       	call   800305 <getint>
  8005b0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005b3:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8005b6:	85 d2                	test   %edx,%edx
  8005b8:	78 0b                	js     8005c5 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8005ba:	89 d1                	mov    %edx,%ecx
  8005bc:	89 c2                	mov    %eax,%edx
			base = 10;
  8005be:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005c3:	eb 32                	jmp    8005f7 <vprintfmt+0x284>
				putch('-', putdat);
  8005c5:	83 ec 08             	sub    $0x8,%esp
  8005c8:	56                   	push   %esi
  8005c9:	6a 2d                	push   $0x2d
  8005cb:	ff d3                	call   *%ebx
				num = -(long long) num;
  8005cd:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005d0:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005d3:	f7 da                	neg    %edx
  8005d5:	83 d1 00             	adc    $0x0,%ecx
  8005d8:	f7 d9                	neg    %ecx
  8005da:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005dd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005e2:	eb 13                	jmp    8005f7 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8005e4:	89 ca                	mov    %ecx,%edx
  8005e6:	8d 45 14             	lea    0x14(%ebp),%eax
  8005e9:	e8 e3 fc ff ff       	call   8002d1 <getuint>
  8005ee:	89 d1                	mov    %edx,%ecx
  8005f0:	89 c2                	mov    %eax,%edx
			base = 10;
  8005f2:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  8005f7:	83 ec 0c             	sub    $0xc,%esp
  8005fa:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005fe:	57                   	push   %edi
  8005ff:	ff 75 e0             	pushl  -0x20(%ebp)
  800602:	50                   	push   %eax
  800603:	51                   	push   %ecx
  800604:	52                   	push   %edx
  800605:	89 f2                	mov    %esi,%edx
  800607:	89 d8                	mov    %ebx,%eax
  800609:	e8 1a fc ff ff       	call   800228 <printnum>
			break;
  80060e:	83 c4 20             	add    $0x20,%esp
{
  800611:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800614:	83 c7 01             	add    $0x1,%edi
  800617:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80061b:	83 f8 25             	cmp    $0x25,%eax
  80061e:	0f 84 6a fd ff ff    	je     80038e <vprintfmt+0x1b>
			if (ch == '\0')
  800624:	85 c0                	test   %eax,%eax
  800626:	0f 84 93 00 00 00    	je     8006bf <vprintfmt+0x34c>
			putch(ch, putdat);
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	56                   	push   %esi
  800630:	50                   	push   %eax
  800631:	ff d3                	call   *%ebx
  800633:	83 c4 10             	add    $0x10,%esp
  800636:	eb dc                	jmp    800614 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  800638:	89 ca                	mov    %ecx,%edx
  80063a:	8d 45 14             	lea    0x14(%ebp),%eax
  80063d:	e8 8f fc ff ff       	call   8002d1 <getuint>
  800642:	89 d1                	mov    %edx,%ecx
  800644:	89 c2                	mov    %eax,%edx
			base = 8;
  800646:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80064b:	eb aa                	jmp    8005f7 <vprintfmt+0x284>
			putch('0', putdat);
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	56                   	push   %esi
  800651:	6a 30                	push   $0x30
  800653:	ff d3                	call   *%ebx
			putch('x', putdat);
  800655:	83 c4 08             	add    $0x8,%esp
  800658:	56                   	push   %esi
  800659:	6a 78                	push   $0x78
  80065b:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  80065d:	8b 45 14             	mov    0x14(%ebp),%eax
  800660:	8d 50 04             	lea    0x4(%eax),%edx
  800663:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800666:	8b 10                	mov    (%eax),%edx
  800668:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80066d:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800670:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800675:	eb 80                	jmp    8005f7 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800677:	89 ca                	mov    %ecx,%edx
  800679:	8d 45 14             	lea    0x14(%ebp),%eax
  80067c:	e8 50 fc ff ff       	call   8002d1 <getuint>
  800681:	89 d1                	mov    %edx,%ecx
  800683:	89 c2                	mov    %eax,%edx
			base = 16;
  800685:	b8 10 00 00 00       	mov    $0x10,%eax
  80068a:	e9 68 ff ff ff       	jmp    8005f7 <vprintfmt+0x284>
			putch(ch, putdat);
  80068f:	83 ec 08             	sub    $0x8,%esp
  800692:	56                   	push   %esi
  800693:	6a 25                	push   $0x25
  800695:	ff d3                	call   *%ebx
			break;
  800697:	83 c4 10             	add    $0x10,%esp
  80069a:	e9 72 ff ff ff       	jmp    800611 <vprintfmt+0x29e>
			putch('%', putdat);
  80069f:	83 ec 08             	sub    $0x8,%esp
  8006a2:	56                   	push   %esi
  8006a3:	6a 25                	push   $0x25
  8006a5:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006a7:	83 c4 10             	add    $0x10,%esp
  8006aa:	89 f8                	mov    %edi,%eax
  8006ac:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006b0:	74 05                	je     8006b7 <vprintfmt+0x344>
  8006b2:	83 e8 01             	sub    $0x1,%eax
  8006b5:	eb f5                	jmp    8006ac <vprintfmt+0x339>
  8006b7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006ba:	e9 52 ff ff ff       	jmp    800611 <vprintfmt+0x29e>
}
  8006bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c2:	5b                   	pop    %ebx
  8006c3:	5e                   	pop    %esi
  8006c4:	5f                   	pop    %edi
  8006c5:	5d                   	pop    %ebp
  8006c6:	c3                   	ret    

008006c7 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006c7:	f3 0f 1e fb          	endbr32 
  8006cb:	55                   	push   %ebp
  8006cc:	89 e5                	mov    %esp,%ebp
  8006ce:	83 ec 18             	sub    $0x18,%esp
  8006d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8006d4:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006d7:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006da:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006de:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006e1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006e8:	85 c0                	test   %eax,%eax
  8006ea:	74 26                	je     800712 <vsnprintf+0x4b>
  8006ec:	85 d2                	test   %edx,%edx
  8006ee:	7e 22                	jle    800712 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8006f0:	ff 75 14             	pushl  0x14(%ebp)
  8006f3:	ff 75 10             	pushl  0x10(%ebp)
  8006f6:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8006f9:	50                   	push   %eax
  8006fa:	68 31 03 80 00       	push   $0x800331
  8006ff:	e8 6f fc ff ff       	call   800373 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800704:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800707:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80070a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80070d:	83 c4 10             	add    $0x10,%esp
}
  800710:	c9                   	leave  
  800711:	c3                   	ret    
		return -E_INVAL;
  800712:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800717:	eb f7                	jmp    800710 <vsnprintf+0x49>

00800719 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800719:	f3 0f 1e fb          	endbr32 
  80071d:	55                   	push   %ebp
  80071e:	89 e5                	mov    %esp,%ebp
  800720:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800723:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800726:	50                   	push   %eax
  800727:	ff 75 10             	pushl  0x10(%ebp)
  80072a:	ff 75 0c             	pushl  0xc(%ebp)
  80072d:	ff 75 08             	pushl  0x8(%ebp)
  800730:	e8 92 ff ff ff       	call   8006c7 <vsnprintf>
	va_end(ap);

	return rc;
}
  800735:	c9                   	leave  
  800736:	c3                   	ret    

00800737 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800737:	f3 0f 1e fb          	endbr32 
  80073b:	55                   	push   %ebp
  80073c:	89 e5                	mov    %esp,%ebp
  80073e:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800741:	b8 00 00 00 00       	mov    $0x0,%eax
  800746:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80074a:	74 05                	je     800751 <strlen+0x1a>
		n++;
  80074c:	83 c0 01             	add    $0x1,%eax
  80074f:	eb f5                	jmp    800746 <strlen+0xf>
	return n;
}
  800751:	5d                   	pop    %ebp
  800752:	c3                   	ret    

00800753 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800753:	f3 0f 1e fb          	endbr32 
  800757:	55                   	push   %ebp
  800758:	89 e5                	mov    %esp,%ebp
  80075a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80075d:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800760:	b8 00 00 00 00       	mov    $0x0,%eax
  800765:	39 d0                	cmp    %edx,%eax
  800767:	74 0d                	je     800776 <strnlen+0x23>
  800769:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80076d:	74 05                	je     800774 <strnlen+0x21>
		n++;
  80076f:	83 c0 01             	add    $0x1,%eax
  800772:	eb f1                	jmp    800765 <strnlen+0x12>
  800774:	89 c2                	mov    %eax,%edx
	return n;
}
  800776:	89 d0                	mov    %edx,%eax
  800778:	5d                   	pop    %ebp
  800779:	c3                   	ret    

0080077a <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80077a:	f3 0f 1e fb          	endbr32 
  80077e:	55                   	push   %ebp
  80077f:	89 e5                	mov    %esp,%ebp
  800781:	53                   	push   %ebx
  800782:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800785:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800788:	b8 00 00 00 00       	mov    $0x0,%eax
  80078d:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800791:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800794:	83 c0 01             	add    $0x1,%eax
  800797:	84 d2                	test   %dl,%dl
  800799:	75 f2                	jne    80078d <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  80079b:	89 c8                	mov    %ecx,%eax
  80079d:	5b                   	pop    %ebx
  80079e:	5d                   	pop    %ebp
  80079f:	c3                   	ret    

008007a0 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007a0:	f3 0f 1e fb          	endbr32 
  8007a4:	55                   	push   %ebp
  8007a5:	89 e5                	mov    %esp,%ebp
  8007a7:	53                   	push   %ebx
  8007a8:	83 ec 10             	sub    $0x10,%esp
  8007ab:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007ae:	53                   	push   %ebx
  8007af:	e8 83 ff ff ff       	call   800737 <strlen>
  8007b4:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007b7:	ff 75 0c             	pushl  0xc(%ebp)
  8007ba:	01 d8                	add    %ebx,%eax
  8007bc:	50                   	push   %eax
  8007bd:	e8 b8 ff ff ff       	call   80077a <strcpy>
	return dst;
}
  8007c2:	89 d8                	mov    %ebx,%eax
  8007c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007c7:	c9                   	leave  
  8007c8:	c3                   	ret    

008007c9 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007c9:	f3 0f 1e fb          	endbr32 
  8007cd:	55                   	push   %ebp
  8007ce:	89 e5                	mov    %esp,%ebp
  8007d0:	56                   	push   %esi
  8007d1:	53                   	push   %ebx
  8007d2:	8b 75 08             	mov    0x8(%ebp),%esi
  8007d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d8:	89 f3                	mov    %esi,%ebx
  8007da:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007dd:	89 f0                	mov    %esi,%eax
  8007df:	39 d8                	cmp    %ebx,%eax
  8007e1:	74 11                	je     8007f4 <strncpy+0x2b>
		*dst++ = *src;
  8007e3:	83 c0 01             	add    $0x1,%eax
  8007e6:	0f b6 0a             	movzbl (%edx),%ecx
  8007e9:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  8007ec:	80 f9 01             	cmp    $0x1,%cl
  8007ef:	83 da ff             	sbb    $0xffffffff,%edx
  8007f2:	eb eb                	jmp    8007df <strncpy+0x16>
	}
	return ret;
}
  8007f4:	89 f0                	mov    %esi,%eax
  8007f6:	5b                   	pop    %ebx
  8007f7:	5e                   	pop    %esi
  8007f8:	5d                   	pop    %ebp
  8007f9:	c3                   	ret    

008007fa <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8007fa:	f3 0f 1e fb          	endbr32 
  8007fe:	55                   	push   %ebp
  8007ff:	89 e5                	mov    %esp,%ebp
  800801:	56                   	push   %esi
  800802:	53                   	push   %ebx
  800803:	8b 75 08             	mov    0x8(%ebp),%esi
  800806:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800809:	8b 55 10             	mov    0x10(%ebp),%edx
  80080c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80080e:	85 d2                	test   %edx,%edx
  800810:	74 21                	je     800833 <strlcpy+0x39>
  800812:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800816:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800818:	39 c2                	cmp    %eax,%edx
  80081a:	74 14                	je     800830 <strlcpy+0x36>
  80081c:	0f b6 19             	movzbl (%ecx),%ebx
  80081f:	84 db                	test   %bl,%bl
  800821:	74 0b                	je     80082e <strlcpy+0x34>
			*dst++ = *src++;
  800823:	83 c1 01             	add    $0x1,%ecx
  800826:	83 c2 01             	add    $0x1,%edx
  800829:	88 5a ff             	mov    %bl,-0x1(%edx)
  80082c:	eb ea                	jmp    800818 <strlcpy+0x1e>
  80082e:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800830:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800833:	29 f0                	sub    %esi,%eax
}
  800835:	5b                   	pop    %ebx
  800836:	5e                   	pop    %esi
  800837:	5d                   	pop    %ebp
  800838:	c3                   	ret    

00800839 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800839:	f3 0f 1e fb          	endbr32 
  80083d:	55                   	push   %ebp
  80083e:	89 e5                	mov    %esp,%ebp
  800840:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800843:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800846:	0f b6 01             	movzbl (%ecx),%eax
  800849:	84 c0                	test   %al,%al
  80084b:	74 0c                	je     800859 <strcmp+0x20>
  80084d:	3a 02                	cmp    (%edx),%al
  80084f:	75 08                	jne    800859 <strcmp+0x20>
		p++, q++;
  800851:	83 c1 01             	add    $0x1,%ecx
  800854:	83 c2 01             	add    $0x1,%edx
  800857:	eb ed                	jmp    800846 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800859:	0f b6 c0             	movzbl %al,%eax
  80085c:	0f b6 12             	movzbl (%edx),%edx
  80085f:	29 d0                	sub    %edx,%eax
}
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800863:	f3 0f 1e fb          	endbr32 
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	53                   	push   %ebx
  80086b:	8b 45 08             	mov    0x8(%ebp),%eax
  80086e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800871:	89 c3                	mov    %eax,%ebx
  800873:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800876:	eb 06                	jmp    80087e <strncmp+0x1b>
		n--, p++, q++;
  800878:	83 c0 01             	add    $0x1,%eax
  80087b:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80087e:	39 d8                	cmp    %ebx,%eax
  800880:	74 16                	je     800898 <strncmp+0x35>
  800882:	0f b6 08             	movzbl (%eax),%ecx
  800885:	84 c9                	test   %cl,%cl
  800887:	74 04                	je     80088d <strncmp+0x2a>
  800889:	3a 0a                	cmp    (%edx),%cl
  80088b:	74 eb                	je     800878 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80088d:	0f b6 00             	movzbl (%eax),%eax
  800890:	0f b6 12             	movzbl (%edx),%edx
  800893:	29 d0                	sub    %edx,%eax
}
  800895:	5b                   	pop    %ebx
  800896:	5d                   	pop    %ebp
  800897:	c3                   	ret    
		return 0;
  800898:	b8 00 00 00 00       	mov    $0x0,%eax
  80089d:	eb f6                	jmp    800895 <strncmp+0x32>

0080089f <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80089f:	f3 0f 1e fb          	endbr32 
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008a9:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008ad:	0f b6 10             	movzbl (%eax),%edx
  8008b0:	84 d2                	test   %dl,%dl
  8008b2:	74 09                	je     8008bd <strchr+0x1e>
		if (*s == c)
  8008b4:	38 ca                	cmp    %cl,%dl
  8008b6:	74 0a                	je     8008c2 <strchr+0x23>
	for (; *s; s++)
  8008b8:	83 c0 01             	add    $0x1,%eax
  8008bb:	eb f0                	jmp    8008ad <strchr+0xe>
			return (char *) s;
	return 0;
  8008bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008c2:	5d                   	pop    %ebp
  8008c3:	c3                   	ret    

008008c4 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008c4:	f3 0f 1e fb          	endbr32 
  8008c8:	55                   	push   %ebp
  8008c9:	89 e5                	mov    %esp,%ebp
  8008cb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ce:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d2:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008d5:	38 ca                	cmp    %cl,%dl
  8008d7:	74 09                	je     8008e2 <strfind+0x1e>
  8008d9:	84 d2                	test   %dl,%dl
  8008db:	74 05                	je     8008e2 <strfind+0x1e>
	for (; *s; s++)
  8008dd:	83 c0 01             	add    $0x1,%eax
  8008e0:	eb f0                	jmp    8008d2 <strfind+0xe>
			break;
	return (char *) s;
}
  8008e2:	5d                   	pop    %ebp
  8008e3:	c3                   	ret    

008008e4 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008e4:	f3 0f 1e fb          	endbr32 
  8008e8:	55                   	push   %ebp
  8008e9:	89 e5                	mov    %esp,%ebp
  8008eb:	57                   	push   %edi
  8008ec:	56                   	push   %esi
  8008ed:	53                   	push   %ebx
  8008ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8008f1:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8008f4:	85 c9                	test   %ecx,%ecx
  8008f6:	74 33                	je     80092b <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8008f8:	89 d0                	mov    %edx,%eax
  8008fa:	09 c8                	or     %ecx,%eax
  8008fc:	a8 03                	test   $0x3,%al
  8008fe:	75 23                	jne    800923 <memset+0x3f>
		c &= 0xFF;
  800900:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800904:	89 d8                	mov    %ebx,%eax
  800906:	c1 e0 08             	shl    $0x8,%eax
  800909:	89 df                	mov    %ebx,%edi
  80090b:	c1 e7 18             	shl    $0x18,%edi
  80090e:	89 de                	mov    %ebx,%esi
  800910:	c1 e6 10             	shl    $0x10,%esi
  800913:	09 f7                	or     %esi,%edi
  800915:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800917:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80091a:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  80091c:	89 d7                	mov    %edx,%edi
  80091e:	fc                   	cld    
  80091f:	f3 ab                	rep stos %eax,%es:(%edi)
  800921:	eb 08                	jmp    80092b <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800923:	89 d7                	mov    %edx,%edi
  800925:	8b 45 0c             	mov    0xc(%ebp),%eax
  800928:	fc                   	cld    
  800929:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  80092b:	89 d0                	mov    %edx,%eax
  80092d:	5b                   	pop    %ebx
  80092e:	5e                   	pop    %esi
  80092f:	5f                   	pop    %edi
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    

00800932 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800932:	f3 0f 1e fb          	endbr32 
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	57                   	push   %edi
  80093a:	56                   	push   %esi
  80093b:	8b 45 08             	mov    0x8(%ebp),%eax
  80093e:	8b 75 0c             	mov    0xc(%ebp),%esi
  800941:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800944:	39 c6                	cmp    %eax,%esi
  800946:	73 32                	jae    80097a <memmove+0x48>
  800948:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80094b:	39 c2                	cmp    %eax,%edx
  80094d:	76 2b                	jbe    80097a <memmove+0x48>
		s += n;
		d += n;
  80094f:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800952:	89 fe                	mov    %edi,%esi
  800954:	09 ce                	or     %ecx,%esi
  800956:	09 d6                	or     %edx,%esi
  800958:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80095e:	75 0e                	jne    80096e <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800960:	83 ef 04             	sub    $0x4,%edi
  800963:	8d 72 fc             	lea    -0x4(%edx),%esi
  800966:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800969:	fd                   	std    
  80096a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80096c:	eb 09                	jmp    800977 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80096e:	83 ef 01             	sub    $0x1,%edi
  800971:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800974:	fd                   	std    
  800975:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800977:	fc                   	cld    
  800978:	eb 1a                	jmp    800994 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097a:	89 c2                	mov    %eax,%edx
  80097c:	09 ca                	or     %ecx,%edx
  80097e:	09 f2                	or     %esi,%edx
  800980:	f6 c2 03             	test   $0x3,%dl
  800983:	75 0a                	jne    80098f <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800985:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800988:	89 c7                	mov    %eax,%edi
  80098a:	fc                   	cld    
  80098b:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80098d:	eb 05                	jmp    800994 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  80098f:	89 c7                	mov    %eax,%edi
  800991:	fc                   	cld    
  800992:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800994:	5e                   	pop    %esi
  800995:	5f                   	pop    %edi
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800998:	f3 0f 1e fb          	endbr32 
  80099c:	55                   	push   %ebp
  80099d:	89 e5                	mov    %esp,%ebp
  80099f:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009a2:	ff 75 10             	pushl  0x10(%ebp)
  8009a5:	ff 75 0c             	pushl  0xc(%ebp)
  8009a8:	ff 75 08             	pushl  0x8(%ebp)
  8009ab:	e8 82 ff ff ff       	call   800932 <memmove>
}
  8009b0:	c9                   	leave  
  8009b1:	c3                   	ret    

008009b2 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009b2:	f3 0f 1e fb          	endbr32 
  8009b6:	55                   	push   %ebp
  8009b7:	89 e5                	mov    %esp,%ebp
  8009b9:	56                   	push   %esi
  8009ba:	53                   	push   %ebx
  8009bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8009be:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009c1:	89 c6                	mov    %eax,%esi
  8009c3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009c6:	39 f0                	cmp    %esi,%eax
  8009c8:	74 1c                	je     8009e6 <memcmp+0x34>
		if (*s1 != *s2)
  8009ca:	0f b6 08             	movzbl (%eax),%ecx
  8009cd:	0f b6 1a             	movzbl (%edx),%ebx
  8009d0:	38 d9                	cmp    %bl,%cl
  8009d2:	75 08                	jne    8009dc <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009d4:	83 c0 01             	add    $0x1,%eax
  8009d7:	83 c2 01             	add    $0x1,%edx
  8009da:	eb ea                	jmp    8009c6 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8009dc:	0f b6 c1             	movzbl %cl,%eax
  8009df:	0f b6 db             	movzbl %bl,%ebx
  8009e2:	29 d8                	sub    %ebx,%eax
  8009e4:	eb 05                	jmp    8009eb <memcmp+0x39>
	}

	return 0;
  8009e6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009eb:	5b                   	pop    %ebx
  8009ec:	5e                   	pop    %esi
  8009ed:	5d                   	pop    %ebp
  8009ee:	c3                   	ret    

008009ef <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  8009ef:	f3 0f 1e fb          	endbr32 
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  8009fc:	89 c2                	mov    %eax,%edx
  8009fe:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a01:	39 d0                	cmp    %edx,%eax
  800a03:	73 09                	jae    800a0e <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a05:	38 08                	cmp    %cl,(%eax)
  800a07:	74 05                	je     800a0e <memfind+0x1f>
	for (; s < ends; s++)
  800a09:	83 c0 01             	add    $0x1,%eax
  800a0c:	eb f3                	jmp    800a01 <memfind+0x12>
			break;
	return (void *) s;
}
  800a0e:	5d                   	pop    %ebp
  800a0f:	c3                   	ret    

00800a10 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a10:	f3 0f 1e fb          	endbr32 
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	57                   	push   %edi
  800a18:	56                   	push   %esi
  800a19:	53                   	push   %ebx
  800a1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a1d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a20:	eb 03                	jmp    800a25 <strtol+0x15>
		s++;
  800a22:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a25:	0f b6 01             	movzbl (%ecx),%eax
  800a28:	3c 20                	cmp    $0x20,%al
  800a2a:	74 f6                	je     800a22 <strtol+0x12>
  800a2c:	3c 09                	cmp    $0x9,%al
  800a2e:	74 f2                	je     800a22 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a30:	3c 2b                	cmp    $0x2b,%al
  800a32:	74 2a                	je     800a5e <strtol+0x4e>
	int neg = 0;
  800a34:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a39:	3c 2d                	cmp    $0x2d,%al
  800a3b:	74 2b                	je     800a68 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a3d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a43:	75 0f                	jne    800a54 <strtol+0x44>
  800a45:	80 39 30             	cmpb   $0x30,(%ecx)
  800a48:	74 28                	je     800a72 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a4a:	85 db                	test   %ebx,%ebx
  800a4c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a51:	0f 44 d8             	cmove  %eax,%ebx
  800a54:	b8 00 00 00 00       	mov    $0x0,%eax
  800a59:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a5c:	eb 46                	jmp    800aa4 <strtol+0x94>
		s++;
  800a5e:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a61:	bf 00 00 00 00       	mov    $0x0,%edi
  800a66:	eb d5                	jmp    800a3d <strtol+0x2d>
		s++, neg = 1;
  800a68:	83 c1 01             	add    $0x1,%ecx
  800a6b:	bf 01 00 00 00       	mov    $0x1,%edi
  800a70:	eb cb                	jmp    800a3d <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a72:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a76:	74 0e                	je     800a86 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a78:	85 db                	test   %ebx,%ebx
  800a7a:	75 d8                	jne    800a54 <strtol+0x44>
		s++, base = 8;
  800a7c:	83 c1 01             	add    $0x1,%ecx
  800a7f:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a84:	eb ce                	jmp    800a54 <strtol+0x44>
		s += 2, base = 16;
  800a86:	83 c1 02             	add    $0x2,%ecx
  800a89:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a8e:	eb c4                	jmp    800a54 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a90:	0f be d2             	movsbl %dl,%edx
  800a93:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a96:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a99:	7d 3a                	jge    800ad5 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a9b:	83 c1 01             	add    $0x1,%ecx
  800a9e:	0f af 45 10          	imul   0x10(%ebp),%eax
  800aa2:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800aa4:	0f b6 11             	movzbl (%ecx),%edx
  800aa7:	8d 72 d0             	lea    -0x30(%edx),%esi
  800aaa:	89 f3                	mov    %esi,%ebx
  800aac:	80 fb 09             	cmp    $0x9,%bl
  800aaf:	76 df                	jbe    800a90 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800ab1:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ab4:	89 f3                	mov    %esi,%ebx
  800ab6:	80 fb 19             	cmp    $0x19,%bl
  800ab9:	77 08                	ja     800ac3 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800abb:	0f be d2             	movsbl %dl,%edx
  800abe:	83 ea 57             	sub    $0x57,%edx
  800ac1:	eb d3                	jmp    800a96 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800ac3:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ac6:	89 f3                	mov    %esi,%ebx
  800ac8:	80 fb 19             	cmp    $0x19,%bl
  800acb:	77 08                	ja     800ad5 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800acd:	0f be d2             	movsbl %dl,%edx
  800ad0:	83 ea 37             	sub    $0x37,%edx
  800ad3:	eb c1                	jmp    800a96 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ad5:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ad9:	74 05                	je     800ae0 <strtol+0xd0>
		*endptr = (char *) s;
  800adb:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ade:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ae0:	89 c2                	mov    %eax,%edx
  800ae2:	f7 da                	neg    %edx
  800ae4:	85 ff                	test   %edi,%edi
  800ae6:	0f 45 c2             	cmovne %edx,%eax
}
  800ae9:	5b                   	pop    %ebx
  800aea:	5e                   	pop    %esi
  800aeb:	5f                   	pop    %edi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
  800af4:	83 ec 1c             	sub    $0x1c,%esp
  800af7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800afa:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800afd:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800aff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b05:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b08:	8b 75 14             	mov    0x14(%ebp),%esi
  800b0b:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b0d:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b11:	74 04                	je     800b17 <syscall+0x29>
  800b13:	85 c0                	test   %eax,%eax
  800b15:	7f 08                	jg     800b1f <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800b17:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b1a:	5b                   	pop    %ebx
  800b1b:	5e                   	pop    %esi
  800b1c:	5f                   	pop    %edi
  800b1d:	5d                   	pop    %ebp
  800b1e:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b1f:	83 ec 0c             	sub    $0xc,%esp
  800b22:	50                   	push   %eax
  800b23:	ff 75 e0             	pushl  -0x20(%ebp)
  800b26:	68 bf 27 80 00       	push   $0x8027bf
  800b2b:	6a 23                	push   $0x23
  800b2d:	68 dc 27 80 00       	push   $0x8027dc
  800b32:	e8 a4 15 00 00       	call   8020db <_panic>

00800b37 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800b37:	f3 0f 1e fb          	endbr32 
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b41:	6a 00                	push   $0x0
  800b43:	6a 00                	push   $0x0
  800b45:	6a 00                	push   $0x0
  800b47:	ff 75 0c             	pushl  0xc(%ebp)
  800b4a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b4d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b52:	b8 00 00 00 00       	mov    $0x0,%eax
  800b57:	e8 92 ff ff ff       	call   800aee <syscall>
}
  800b5c:	83 c4 10             	add    $0x10,%esp
  800b5f:	c9                   	leave  
  800b60:	c3                   	ret    

00800b61 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b61:	f3 0f 1e fb          	endbr32 
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b6b:	6a 00                	push   $0x0
  800b6d:	6a 00                	push   $0x0
  800b6f:	6a 00                	push   $0x0
  800b71:	6a 00                	push   $0x0
  800b73:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b78:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7d:	b8 01 00 00 00       	mov    $0x1,%eax
  800b82:	e8 67 ff ff ff       	call   800aee <syscall>
}
  800b87:	c9                   	leave  
  800b88:	c3                   	ret    

00800b89 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b89:	f3 0f 1e fb          	endbr32 
  800b8d:	55                   	push   %ebp
  800b8e:	89 e5                	mov    %esp,%ebp
  800b90:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b93:	6a 00                	push   $0x0
  800b95:	6a 00                	push   $0x0
  800b97:	6a 00                	push   $0x0
  800b99:	6a 00                	push   $0x0
  800b9b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b9e:	ba 01 00 00 00       	mov    $0x1,%edx
  800ba3:	b8 03 00 00 00       	mov    $0x3,%eax
  800ba8:	e8 41 ff ff ff       	call   800aee <syscall>
}
  800bad:	c9                   	leave  
  800bae:	c3                   	ret    

00800baf <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800baf:	f3 0f 1e fb          	endbr32 
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800bb9:	6a 00                	push   $0x0
  800bbb:	6a 00                	push   $0x0
  800bbd:	6a 00                	push   $0x0
  800bbf:	6a 00                	push   $0x0
  800bc1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bc6:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcb:	b8 02 00 00 00       	mov    $0x2,%eax
  800bd0:	e8 19 ff ff ff       	call   800aee <syscall>
}
  800bd5:	c9                   	leave  
  800bd6:	c3                   	ret    

00800bd7 <sys_yield>:

void
sys_yield(void)
{
  800bd7:	f3 0f 1e fb          	endbr32 
  800bdb:	55                   	push   %ebp
  800bdc:	89 e5                	mov    %esp,%ebp
  800bde:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800be1:	6a 00                	push   $0x0
  800be3:	6a 00                	push   $0x0
  800be5:	6a 00                	push   $0x0
  800be7:	6a 00                	push   $0x0
  800be9:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bee:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf3:	b8 0b 00 00 00       	mov    $0xb,%eax
  800bf8:	e8 f1 fe ff ff       	call   800aee <syscall>
}
  800bfd:	83 c4 10             	add    $0x10,%esp
  800c00:	c9                   	leave  
  800c01:	c3                   	ret    

00800c02 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c02:	f3 0f 1e fb          	endbr32 
  800c06:	55                   	push   %ebp
  800c07:	89 e5                	mov    %esp,%ebp
  800c09:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c0c:	6a 00                	push   $0x0
  800c0e:	6a 00                	push   $0x0
  800c10:	ff 75 10             	pushl  0x10(%ebp)
  800c13:	ff 75 0c             	pushl  0xc(%ebp)
  800c16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c19:	ba 01 00 00 00       	mov    $0x1,%edx
  800c1e:	b8 04 00 00 00       	mov    $0x4,%eax
  800c23:	e8 c6 fe ff ff       	call   800aee <syscall>
}
  800c28:	c9                   	leave  
  800c29:	c3                   	ret    

00800c2a <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c2a:	f3 0f 1e fb          	endbr32 
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c34:	ff 75 18             	pushl  0x18(%ebp)
  800c37:	ff 75 14             	pushl  0x14(%ebp)
  800c3a:	ff 75 10             	pushl  0x10(%ebp)
  800c3d:	ff 75 0c             	pushl  0xc(%ebp)
  800c40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c43:	ba 01 00 00 00       	mov    $0x1,%edx
  800c48:	b8 05 00 00 00       	mov    $0x5,%eax
  800c4d:	e8 9c fe ff ff       	call   800aee <syscall>
}
  800c52:	c9                   	leave  
  800c53:	c3                   	ret    

00800c54 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c54:	f3 0f 1e fb          	endbr32 
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c5e:	6a 00                	push   $0x0
  800c60:	6a 00                	push   $0x0
  800c62:	6a 00                	push   $0x0
  800c64:	ff 75 0c             	pushl  0xc(%ebp)
  800c67:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6a:	ba 01 00 00 00       	mov    $0x1,%edx
  800c6f:	b8 06 00 00 00       	mov    $0x6,%eax
  800c74:	e8 75 fe ff ff       	call   800aee <syscall>
}
  800c79:	c9                   	leave  
  800c7a:	c3                   	ret    

00800c7b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c7b:	f3 0f 1e fb          	endbr32 
  800c7f:	55                   	push   %ebp
  800c80:	89 e5                	mov    %esp,%ebp
  800c82:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c85:	6a 00                	push   $0x0
  800c87:	6a 00                	push   $0x0
  800c89:	6a 00                	push   $0x0
  800c8b:	ff 75 0c             	pushl  0xc(%ebp)
  800c8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c91:	ba 01 00 00 00       	mov    $0x1,%edx
  800c96:	b8 08 00 00 00       	mov    $0x8,%eax
  800c9b:	e8 4e fe ff ff       	call   800aee <syscall>
}
  800ca0:	c9                   	leave  
  800ca1:	c3                   	ret    

00800ca2 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ca2:	f3 0f 1e fb          	endbr32 
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800cac:	6a 00                	push   $0x0
  800cae:	6a 00                	push   $0x0
  800cb0:	6a 00                	push   $0x0
  800cb2:	ff 75 0c             	pushl  0xc(%ebp)
  800cb5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cb8:	ba 01 00 00 00       	mov    $0x1,%edx
  800cbd:	b8 09 00 00 00       	mov    $0x9,%eax
  800cc2:	e8 27 fe ff ff       	call   800aee <syscall>
}
  800cc7:	c9                   	leave  
  800cc8:	c3                   	ret    

00800cc9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cc9:	f3 0f 1e fb          	endbr32 
  800ccd:	55                   	push   %ebp
  800cce:	89 e5                	mov    %esp,%ebp
  800cd0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800cd3:	6a 00                	push   $0x0
  800cd5:	6a 00                	push   $0x0
  800cd7:	6a 00                	push   $0x0
  800cd9:	ff 75 0c             	pushl  0xc(%ebp)
  800cdc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cdf:	ba 01 00 00 00       	mov    $0x1,%edx
  800ce4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ce9:	e8 00 fe ff ff       	call   800aee <syscall>
}
  800cee:	c9                   	leave  
  800cef:	c3                   	ret    

00800cf0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800cf0:	f3 0f 1e fb          	endbr32 
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800cfa:	6a 00                	push   $0x0
  800cfc:	ff 75 14             	pushl  0x14(%ebp)
  800cff:	ff 75 10             	pushl  0x10(%ebp)
  800d02:	ff 75 0c             	pushl  0xc(%ebp)
  800d05:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d08:	ba 00 00 00 00       	mov    $0x0,%edx
  800d0d:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d12:	e8 d7 fd ff ff       	call   800aee <syscall>
}
  800d17:	c9                   	leave  
  800d18:	c3                   	ret    

00800d19 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d19:	f3 0f 1e fb          	endbr32 
  800d1d:	55                   	push   %ebp
  800d1e:	89 e5                	mov    %esp,%ebp
  800d20:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d23:	6a 00                	push   $0x0
  800d25:	6a 00                	push   $0x0
  800d27:	6a 00                	push   $0x0
  800d29:	6a 00                	push   $0x0
  800d2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d2e:	ba 01 00 00 00       	mov    $0x1,%edx
  800d33:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d38:	e8 b1 fd ff ff       	call   800aee <syscall>
}
  800d3d:	c9                   	leave  
  800d3e:	c3                   	ret    

00800d3f <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d3f:	55                   	push   %ebp
  800d40:	89 e5                	mov    %esp,%ebp
  800d42:	53                   	push   %ebx
  800d43:	83 ec 04             	sub    $0x4,%esp
  800d46:	89 d3                	mov    %edx,%ebx
	int r;

	// LAB 4: Your code here.

	// Page Table Entry
	pte_t pt_e = uvpt[pn];
  800d48:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Obtenemos la virtual address
	void *v_add = (void *) (pn << PTXSHIFT);
  800d4f:	c1 e3 0c             	shl    $0xc,%ebx

	if (pt_e & PTE_SHARE) {
  800d52:	f6 c6 04             	test   $0x4,%dh
  800d55:	75 54                	jne    800dab <duppage+0x6c>
		// Permisos compartidos
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
		if (r < 0)
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	} else if ((pt_e & PTE_W) || (pt_e & PTE_COW)) {
  800d57:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800d5d:	0f 84 8d 00 00 00    	je     800df0 <duppage+0xb1>
		// Copy on write
		r = sys_page_map(0, v_add, envid, v_add, PTE_COW | PTE_U | PTE_P);
  800d63:	83 ec 0c             	sub    $0xc,%esp
  800d66:	68 05 08 00 00       	push   $0x805
  800d6b:	53                   	push   %ebx
  800d6c:	50                   	push   %eax
  800d6d:	53                   	push   %ebx
  800d6e:	6a 00                	push   $0x0
  800d70:	e8 b5 fe ff ff       	call   800c2a <sys_page_map>
		if (r < 0)
  800d75:	83 c4 20             	add    $0x20,%esp
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	78 5f                	js     800ddb <duppage+0x9c>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);

		r = sys_page_map(0, v_add, 0, v_add, PTE_COW | PTE_U | PTE_P);
  800d7c:	83 ec 0c             	sub    $0xc,%esp
  800d7f:	68 05 08 00 00       	push   $0x805
  800d84:	53                   	push   %ebx
  800d85:	6a 00                	push   $0x0
  800d87:	53                   	push   %ebx
  800d88:	6a 00                	push   $0x0
  800d8a:	e8 9b fe ff ff       	call   800c2a <sys_page_map>
		if (r < 0)
  800d8f:	83 c4 20             	add    $0x20,%esp
  800d92:	85 c0                	test   %eax,%eax
  800d94:	79 70                	jns    800e06 <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800d96:	50                   	push   %eax
  800d97:	68 ec 27 80 00       	push   $0x8027ec
  800d9c:	68 9b 00 00 00       	push   $0x9b
  800da1:	68 5a 29 80 00       	push   $0x80295a
  800da6:	e8 30 13 00 00       	call   8020db <_panic>
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
  800dab:	83 ec 0c             	sub    $0xc,%esp
  800dae:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800db4:	52                   	push   %edx
  800db5:	53                   	push   %ebx
  800db6:	50                   	push   %eax
  800db7:	53                   	push   %ebx
  800db8:	6a 00                	push   $0x0
  800dba:	e8 6b fe ff ff       	call   800c2a <sys_page_map>
		if (r < 0)
  800dbf:	83 c4 20             	add    $0x20,%esp
  800dc2:	85 c0                	test   %eax,%eax
  800dc4:	79 40                	jns    800e06 <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800dc6:	50                   	push   %eax
  800dc7:	68 ec 27 80 00       	push   $0x8027ec
  800dcc:	68 92 00 00 00       	push   $0x92
  800dd1:	68 5a 29 80 00       	push   $0x80295a
  800dd6:	e8 00 13 00 00       	call   8020db <_panic>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800ddb:	50                   	push   %eax
  800ddc:	68 ec 27 80 00       	push   $0x8027ec
  800de1:	68 97 00 00 00       	push   $0x97
  800de6:	68 5a 29 80 00       	push   $0x80295a
  800deb:	e8 eb 12 00 00       	call   8020db <_panic>
	} else {
		// En caso de lectura, compartir.
		r = sys_page_map(0, v_add, envid, v_add, PTE_U | PTE_P);
  800df0:	83 ec 0c             	sub    $0xc,%esp
  800df3:	6a 05                	push   $0x5
  800df5:	53                   	push   %ebx
  800df6:	50                   	push   %eax
  800df7:	53                   	push   %ebx
  800df8:	6a 00                	push   $0x0
  800dfa:	e8 2b fe ff ff       	call   800c2a <sys_page_map>
		if (r < 0)
  800dff:	83 c4 20             	add    $0x20,%esp
  800e02:	85 c0                	test   %eax,%eax
  800e04:	78 0a                	js     800e10 <duppage+0xd1>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	}
	return 0;
}
  800e06:	b8 00 00 00 00       	mov    $0x0,%eax
  800e0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e0e:	c9                   	leave  
  800e0f:	c3                   	ret    
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800e10:	50                   	push   %eax
  800e11:	68 ec 27 80 00       	push   $0x8027ec
  800e16:	68 a0 00 00 00       	push   $0xa0
  800e1b:	68 5a 29 80 00       	push   $0x80295a
  800e20:	e8 b6 12 00 00       	call   8020db <_panic>

00800e25 <dup_or_share>:
{
  800e25:	55                   	push   %ebp
  800e26:	89 e5                	mov    %esp,%ebp
  800e28:	57                   	push   %edi
  800e29:	56                   	push   %esi
  800e2a:	53                   	push   %ebx
  800e2b:	83 ec 0c             	sub    $0xc,%esp
  800e2e:	89 c7                	mov    %eax,%edi
  800e30:	89 d6                	mov    %edx,%esi
  800e32:	89 cb                	mov    %ecx,%ebx
	if (perm & PTE_W) {
  800e34:	f6 c1 02             	test   $0x2,%cl
  800e37:	0f 84 90 00 00 00    	je     800ecd <dup_or_share+0xa8>
		if ((r = sys_page_alloc(dstenv, va, perm)) < 0)
  800e3d:	83 ec 04             	sub    $0x4,%esp
  800e40:	51                   	push   %ecx
  800e41:	52                   	push   %edx
  800e42:	50                   	push   %eax
  800e43:	e8 ba fd ff ff       	call   800c02 <sys_page_alloc>
  800e48:	83 c4 10             	add    $0x10,%esp
  800e4b:	85 c0                	test   %eax,%eax
  800e4d:	78 56                	js     800ea5 <dup_or_share+0x80>
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, perm)) < 0)
  800e4f:	83 ec 0c             	sub    $0xc,%esp
  800e52:	53                   	push   %ebx
  800e53:	68 00 00 40 00       	push   $0x400000
  800e58:	6a 00                	push   $0x0
  800e5a:	56                   	push   %esi
  800e5b:	57                   	push   %edi
  800e5c:	e8 c9 fd ff ff       	call   800c2a <sys_page_map>
  800e61:	83 c4 20             	add    $0x20,%esp
  800e64:	85 c0                	test   %eax,%eax
  800e66:	78 51                	js     800eb9 <dup_or_share+0x94>
		memmove(UTEMP, va, PGSIZE);
  800e68:	83 ec 04             	sub    $0x4,%esp
  800e6b:	68 00 10 00 00       	push   $0x1000
  800e70:	56                   	push   %esi
  800e71:	68 00 00 40 00       	push   $0x400000
  800e76:	e8 b7 fa ff ff       	call   800932 <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800e7b:	83 c4 08             	add    $0x8,%esp
  800e7e:	68 00 00 40 00       	push   $0x400000
  800e83:	6a 00                	push   $0x0
  800e85:	e8 ca fd ff ff       	call   800c54 <sys_page_unmap>
  800e8a:	83 c4 10             	add    $0x10,%esp
  800e8d:	85 c0                	test   %eax,%eax
  800e8f:	79 51                	jns    800ee2 <dup_or_share+0xbd>
			panic("sys_page_unmap failed at dup_or_share");
  800e91:	83 ec 04             	sub    $0x4,%esp
  800e94:	68 5c 28 80 00       	push   $0x80285c
  800e99:	6a 18                	push   $0x18
  800e9b:	68 5a 29 80 00       	push   $0x80295a
  800ea0:	e8 36 12 00 00       	call   8020db <_panic>
			panic("sys_page_alloc failed at dup_or_share");
  800ea5:	83 ec 04             	sub    $0x4,%esp
  800ea8:	68 10 28 80 00       	push   $0x802810
  800ead:	6a 13                	push   $0x13
  800eaf:	68 5a 29 80 00       	push   $0x80295a
  800eb4:	e8 22 12 00 00       	call   8020db <_panic>
			panic("sys_page_map failed at dup_or_share");
  800eb9:	83 ec 04             	sub    $0x4,%esp
  800ebc:	68 38 28 80 00       	push   $0x802838
  800ec1:	6a 15                	push   $0x15
  800ec3:	68 5a 29 80 00       	push   $0x80295a
  800ec8:	e8 0e 12 00 00       	call   8020db <_panic>
		if ((r = sys_page_map(0, va, dstenv, va, perm)) < 0)
  800ecd:	83 ec 0c             	sub    $0xc,%esp
  800ed0:	51                   	push   %ecx
  800ed1:	52                   	push   %edx
  800ed2:	50                   	push   %eax
  800ed3:	52                   	push   %edx
  800ed4:	6a 00                	push   $0x0
  800ed6:	e8 4f fd ff ff       	call   800c2a <sys_page_map>
  800edb:	83 c4 20             	add    $0x20,%esp
  800ede:	85 c0                	test   %eax,%eax
  800ee0:	78 08                	js     800eea <dup_or_share+0xc5>
}
  800ee2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ee5:	5b                   	pop    %ebx
  800ee6:	5e                   	pop    %esi
  800ee7:	5f                   	pop    %edi
  800ee8:	5d                   	pop    %ebp
  800ee9:	c3                   	ret    
			panic("sys_page_map failed at dup_or_share");
  800eea:	83 ec 04             	sub    $0x4,%esp
  800eed:	68 38 28 80 00       	push   $0x802838
  800ef2:	6a 1c                	push   $0x1c
  800ef4:	68 5a 29 80 00       	push   $0x80295a
  800ef9:	e8 dd 11 00 00       	call   8020db <_panic>

00800efe <pgfault>:
{
  800efe:	f3 0f 1e fb          	endbr32 
  800f02:	55                   	push   %ebp
  800f03:	89 e5                	mov    %esp,%ebp
  800f05:	53                   	push   %ebx
  800f06:	83 ec 04             	sub    $0x4,%esp
  800f09:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f0c:	8b 18                	mov    (%eax),%ebx
	pte_t pt_e = uvpt[PGNUM(addr)];
  800f0e:	89 da                	mov    %ebx,%edx
  800f10:	c1 ea 0c             	shr    $0xc,%edx
  800f13:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if ((err & FEC_WR) == 0)
  800f1a:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f1e:	74 6e                	je     800f8e <pgfault+0x90>
	if ((pt_e & PTE_COW) == 0)
  800f20:	f6 c6 08             	test   $0x8,%dh
  800f23:	74 7d                	je     800fa2 <pgfault+0xa4>
	if ((r = sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  800f25:	83 ec 04             	sub    $0x4,%esp
  800f28:	6a 07                	push   $0x7
  800f2a:	68 00 f0 7f 00       	push   $0x7ff000
  800f2f:	6a 00                	push   $0x0
  800f31:	e8 cc fc ff ff       	call   800c02 <sys_page_alloc>
  800f36:	83 c4 10             	add    $0x10,%esp
  800f39:	85 c0                	test   %eax,%eax
  800f3b:	78 79                	js     800fb6 <pgfault+0xb8>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800f3d:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800f43:	83 ec 04             	sub    $0x4,%esp
  800f46:	68 00 10 00 00       	push   $0x1000
  800f4b:	53                   	push   %ebx
  800f4c:	68 00 f0 7f 00       	push   $0x7ff000
  800f51:	e8 dc f9 ff ff       	call   800932 <memmove>
	if ((r = sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U)) <
  800f56:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f5d:	53                   	push   %ebx
  800f5e:	6a 00                	push   $0x0
  800f60:	68 00 f0 7f 00       	push   $0x7ff000
  800f65:	6a 00                	push   $0x0
  800f67:	e8 be fc ff ff       	call   800c2a <sys_page_map>
  800f6c:	83 c4 20             	add    $0x20,%esp
  800f6f:	85 c0                	test   %eax,%eax
  800f71:	78 57                	js     800fca <pgfault+0xcc>
	if ((r = sys_page_unmap(0, (void *) PFTEMP)) < 0)
  800f73:	83 ec 08             	sub    $0x8,%esp
  800f76:	68 00 f0 7f 00       	push   $0x7ff000
  800f7b:	6a 00                	push   $0x0
  800f7d:	e8 d2 fc ff ff       	call   800c54 <sys_page_unmap>
  800f82:	83 c4 10             	add    $0x10,%esp
  800f85:	85 c0                	test   %eax,%eax
  800f87:	78 55                	js     800fde <pgfault+0xe0>
}
  800f89:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f8c:	c9                   	leave  
  800f8d:	c3                   	ret    
		panic("ERROR EN PGFAULT: WRITE");
  800f8e:	83 ec 04             	sub    $0x4,%esp
  800f91:	68 65 29 80 00       	push   $0x802965
  800f96:	6a 5e                	push   $0x5e
  800f98:	68 5a 29 80 00       	push   $0x80295a
  800f9d:	e8 39 11 00 00       	call   8020db <_panic>
		panic("ERROR EN PGFAULT: COPY-ON-WRITE");
  800fa2:	83 ec 04             	sub    $0x4,%esp
  800fa5:	68 84 28 80 00       	push   $0x802884
  800faa:	6a 62                	push   $0x62
  800fac:	68 5a 29 80 00       	push   $0x80295a
  800fb1:	e8 25 11 00 00       	call   8020db <_panic>
		panic("pgfault failed");
  800fb6:	83 ec 04             	sub    $0x4,%esp
  800fb9:	68 7d 29 80 00       	push   $0x80297d
  800fbe:	6a 6d                	push   $0x6d
  800fc0:	68 5a 29 80 00       	push   $0x80295a
  800fc5:	e8 11 11 00 00       	call   8020db <_panic>
		panic("pgfault failed");
  800fca:	83 ec 04             	sub    $0x4,%esp
  800fcd:	68 7d 29 80 00       	push   $0x80297d
  800fd2:	6a 72                	push   $0x72
  800fd4:	68 5a 29 80 00       	push   $0x80295a
  800fd9:	e8 fd 10 00 00       	call   8020db <_panic>
		panic("pgfault failed");
  800fde:	83 ec 04             	sub    $0x4,%esp
  800fe1:	68 7d 29 80 00       	push   $0x80297d
  800fe6:	6a 74                	push   $0x74
  800fe8:	68 5a 29 80 00       	push   $0x80295a
  800fed:	e8 e9 10 00 00       	call   8020db <_panic>

00800ff2 <fork_v0>:
{
  800ff2:	f3 0f 1e fb          	endbr32 
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	57                   	push   %edi
  800ffa:	56                   	push   %esi
  800ffb:	53                   	push   %ebx
  800ffc:	83 ec 1c             	sub    $0x1c,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  800fff:	b8 07 00 00 00       	mov    $0x7,%eax
  801004:	cd 30                	int    $0x30
  801006:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801009:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (envid < 0)
  80100c:	85 c0                	test   %eax,%eax
  80100e:	78 1d                	js     80102d <fork_v0+0x3b>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  801010:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  801015:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801019:	74 26                	je     801041 <fork_v0+0x4f>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  80101b:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  801020:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
			        (pte_t *) (PGADDR(PDX(uvpt),
  801026:	bf 00 00 40 ef       	mov    $0xef400000,%edi
  80102b:	eb 4b                	jmp    801078 <fork_v0+0x86>
		panic("sys_exofork failed");
  80102d:	83 ec 04             	sub    $0x4,%esp
  801030:	68 8c 29 80 00       	push   $0x80298c
  801035:	6a 2b                	push   $0x2b
  801037:	68 5a 29 80 00       	push   $0x80295a
  80103c:	e8 9a 10 00 00       	call   8020db <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
  801041:	e8 69 fb ff ff       	call   800baf <sys_getenvid>
  801046:	25 ff 03 00 00       	and    $0x3ff,%eax
  80104b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80104e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801053:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  801058:	eb 68                	jmp    8010c2 <fork_v0+0xd0>
				dup_or_share(envid,
  80105a:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  801060:	89 da                	mov    %ebx,%edx
  801062:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801065:	e8 bb fd ff ff       	call   800e25 <dup_or_share>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  80106a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801070:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801076:	74 36                	je     8010ae <fork_v0+0xbc>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  801078:	89 d8                	mov    %ebx,%eax
  80107a:	c1 e8 16             	shr    $0x16,%eax
  80107d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801084:	09 f2                	or     %esi,%edx
		if ((*pgdirentry) & PTE_P) {
  801086:	f6 02 01             	testb  $0x1,(%edx)
  801089:	74 df                	je     80106a <fork_v0+0x78>
			        (pte_t *) (PGADDR(PDX(uvpt),
  80108b:	89 da                	mov    %ebx,%edx
  80108d:	c1 ea 0a             	shr    $0xa,%edx
  801090:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  801096:	c1 e0 0c             	shl    $0xc,%eax
  801099:	89 f9                	mov    %edi,%ecx
  80109b:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
  8010a1:	09 c8                	or     %ecx,%eax
  8010a3:	09 d0                	or     %edx,%eax
			if ((*pgtablentry) & PTE_P)
  8010a5:	8b 08                	mov    (%eax),%ecx
  8010a7:	f6 c1 01             	test   $0x1,%cl
  8010aa:	74 be                	je     80106a <fork_v0+0x78>
  8010ac:	eb ac                	jmp    80105a <fork_v0+0x68>
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8010ae:	83 ec 08             	sub    $0x8,%esp
  8010b1:	6a 02                	push   $0x2
  8010b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8010b6:	e8 c0 fb ff ff       	call   800c7b <sys_env_set_status>
  8010bb:	83 c4 10             	add    $0x10,%esp
  8010be:	85 c0                	test   %eax,%eax
  8010c0:	78 0b                	js     8010cd <fork_v0+0xdb>
}
  8010c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010c8:	5b                   	pop    %ebx
  8010c9:	5e                   	pop    %esi
  8010ca:	5f                   	pop    %edi
  8010cb:	5d                   	pop    %ebp
  8010cc:	c3                   	ret    
		panic("sys_env_set_status failed at fork_v0");
  8010cd:	83 ec 04             	sub    $0x4,%esp
  8010d0:	68 a4 28 80 00       	push   $0x8028a4
  8010d5:	6a 43                	push   $0x43
  8010d7:	68 5a 29 80 00       	push   $0x80295a
  8010dc:	e8 fa 0f 00 00       	call   8020db <_panic>

008010e1 <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  8010e1:	f3 0f 1e fb          	endbr32 
  8010e5:	55                   	push   %ebp
  8010e6:	89 e5                	mov    %esp,%ebp
  8010e8:	57                   	push   %edi
  8010e9:	56                   	push   %esi
  8010ea:	53                   	push   %ebx
  8010eb:	83 ec 28             	sub    $0x28,%esp
	int err;

	// handle padre
	set_pgfault_handler(pgfault);
  8010ee:	68 fe 0e 80 00       	push   $0x800efe
  8010f3:	e8 2d 10 00 00       	call   802125 <set_pgfault_handler>
  8010f8:	b8 07 00 00 00       	mov    $0x7,%eax
  8010fd:	cd 30                	int    $0x30
  8010ff:	89 45 e0             	mov    %eax,-0x20(%ebp)

	// Proceso hijo
	envid_t e_id = sys_exofork();

	if (e_id < 0)
  801102:	83 c4 10             	add    $0x10,%esp
  801105:	85 c0                	test   %eax,%eax
  801107:	78 2f                	js     801138 <fork+0x57>
  801109:	89 c7                	mov    %eax,%edi
  80110b:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		panic("ERROR EN FORK: sys_exofork: %e", e_id);

	if (e_id == 0) {
  801112:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801116:	0f 85 9e 00 00 00    	jne    8011ba <fork+0xd9>
		// Si es hijo
		thisenv = &envs[ENVX(sys_getenvid())];
  80111c:	e8 8e fa ff ff       	call   800baf <sys_getenvid>
  801121:	25 ff 03 00 00       	and    $0x3ff,%eax
  801126:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801129:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80112e:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  801133:	e9 de 00 00 00       	jmp    801216 <fork+0x135>
		panic("ERROR EN FORK: sys_exofork: %e", e_id);
  801138:	50                   	push   %eax
  801139:	68 cc 28 80 00       	push   $0x8028cc
  80113e:	68 c2 00 00 00       	push   $0xc2
  801143:	68 5a 29 80 00       	push   $0x80295a
  801148:	e8 8e 0f 00 00       	call   8020db <_panic>
		// LOOP PTEs
		while (pt_x < NPTENTRIES) {
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
			pte_t pt_e = uvpt[PGNUM(dir)];
			if (dir == (UXSTACKTOP - PGSIZE)) {
				err = sys_page_alloc(e_id,
  80114d:	83 ec 04             	sub    $0x4,%esp
  801150:	6a 07                	push   $0x7
  801152:	68 00 f0 bf ee       	push   $0xeebff000
  801157:	57                   	push   %edi
  801158:	e8 a5 fa ff ff       	call   800c02 <sys_page_alloc>
				                     (void *) dir,
				                     PTE_W | PTE_U | PTE_P);
				if (err)
  80115d:	83 c4 10             	add    $0x10,%esp
  801160:	85 c0                	test   %eax,%eax
  801162:	75 33                	jne    801197 <fork+0xb6>
  801164:	83 c3 01             	add    $0x1,%ebx
		while (pt_x < NPTENTRIES) {
  801167:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  80116d:	74 3d                	je     8011ac <fork+0xcb>
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
  80116f:	89 d8                	mov    %ebx,%eax
  801171:	c1 e0 0c             	shl    $0xc,%eax
  801174:	09 f0                	or     %esi,%eax
			pte_t pt_e = uvpt[PGNUM(dir)];
  801176:	89 c2                	mov    %eax,%edx
  801178:	c1 ea 0c             	shr    $0xc,%edx
  80117b:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
			if (dir == (UXSTACKTOP - PGSIZE)) {
  801182:	3d 00 f0 bf ee       	cmp    $0xeebff000,%eax
  801187:	74 c4                	je     80114d <fork+0x6c>
					      "%e",
					      err);
				pt_x++;
				continue;
			}
			if ((pt_e & PTE_P) == 0) {
  801189:	f6 c1 01             	test   $0x1,%cl
  80118c:	74 d6                	je     801164 <fork+0x83>
				pt_x++;
				continue;
			}
			duppage(e_id, PGNUM(dir));
  80118e:	89 f8                	mov    %edi,%eax
  801190:	e8 aa fb ff ff       	call   800d3f <duppage>
  801195:	eb cd                	jmp    801164 <fork+0x83>
					panic("ERROR EN FORK: sys_page_alloc: "
  801197:	50                   	push   %eax
  801198:	68 ec 28 80 00       	push   $0x8028ec
  80119d:	68 e1 00 00 00       	push   $0xe1
  8011a2:	68 5a 29 80 00       	push   $0x80295a
  8011a7:	e8 2f 0f 00 00       	call   8020db <_panic>
  8011ac:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  8011b0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
	while (pd_x < PDX(UTOP)) {
  8011b3:	3d bb 03 00 00       	cmp    $0x3bb,%eax
  8011b8:	74 18                	je     8011d2 <fork+0xf1>
		pde_t pd_e = uvpd[pd_x];
  8011ba:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8011bd:	8b 04 b5 00 d0 7b ef 	mov    -0x10843000(,%esi,4),%eax
		if ((pd_e & PTE_P) == 0) {
  8011c4:	a8 01                	test   $0x1,%al
  8011c6:	74 e4                	je     8011ac <fork+0xcb>
  8011c8:	c1 e6 16             	shl    $0x16,%esi
  8011cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011d0:	eb 9d                	jmp    80116f <fork+0x8e>
			pt_x++;
		}
		pd_x++;
	}

	if ((err = sys_page_alloc(e_id,
  8011d2:	83 ec 04             	sub    $0x4,%esp
  8011d5:	6a 07                	push   $0x7
  8011d7:	68 00 f0 bf ee       	push   $0xeebff000
  8011dc:	ff 75 e0             	pushl  -0x20(%ebp)
  8011df:	e8 1e fa ff ff       	call   800c02 <sys_page_alloc>
  8011e4:	83 c4 10             	add    $0x10,%esp
  8011e7:	85 c0                	test   %eax,%eax
  8011e9:	78 36                	js     801221 <fork+0x140>
	                          (void *) (UXSTACKTOP - PGSIZE),
	                          PTE_P | PTE_U | PTE_W) < 0))
		panic("Error en sys_page_alloc");


	if ((sys_env_set_pgfault_upcall(e_id, _pgfault_upcall) < 0))
  8011eb:	83 ec 08             	sub    $0x8,%esp
  8011ee:	68 80 21 80 00       	push   $0x802180
  8011f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8011f6:	e8 ce fa ff ff       	call   800cc9 <sys_env_set_pgfault_upcall>
  8011fb:	83 c4 10             	add    $0x10,%esp
  8011fe:	85 c0                	test   %eax,%eax
  801200:	78 36                	js     801238 <fork+0x157>
		panic("sys_env_set_pgfault_upcall failed");

	// HIJO RUNNABLE
	if ((err = sys_env_set_status(e_id, ENV_RUNNABLE)) < 0)
  801202:	83 ec 08             	sub    $0x8,%esp
  801205:	6a 02                	push   $0x2
  801207:	ff 75 e0             	pushl  -0x20(%ebp)
  80120a:	e8 6c fa ff ff       	call   800c7b <sys_env_set_status>
  80120f:	83 c4 10             	add    $0x10,%esp
  801212:	85 c0                	test   %eax,%eax
  801214:	78 39                	js     80124f <fork+0x16e>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);

	return e_id;
}
  801216:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801219:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80121c:	5b                   	pop    %ebx
  80121d:	5e                   	pop    %esi
  80121e:	5f                   	pop    %edi
  80121f:	5d                   	pop    %ebp
  801220:	c3                   	ret    
		panic("Error en sys_page_alloc");
  801221:	83 ec 04             	sub    $0x4,%esp
  801224:	68 9f 29 80 00       	push   $0x80299f
  801229:	68 f4 00 00 00       	push   $0xf4
  80122e:	68 5a 29 80 00       	push   $0x80295a
  801233:	e8 a3 0e 00 00       	call   8020db <_panic>
		panic("sys_env_set_pgfault_upcall failed");
  801238:	83 ec 04             	sub    $0x4,%esp
  80123b:	68 10 29 80 00       	push   $0x802910
  801240:	68 f8 00 00 00       	push   $0xf8
  801245:	68 5a 29 80 00       	push   $0x80295a
  80124a:	e8 8c 0e 00 00       	call   8020db <_panic>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);
  80124f:	50                   	push   %eax
  801250:	68 34 29 80 00       	push   $0x802934
  801255:	68 fc 00 00 00       	push   $0xfc
  80125a:	68 5a 29 80 00       	push   $0x80295a
  80125f:	e8 77 0e 00 00       	call   8020db <_panic>

00801264 <sfork>:

// Challenge!
int
sfork(void)
{
  801264:	f3 0f 1e fb          	endbr32 
  801268:	55                   	push   %ebp
  801269:	89 e5                	mov    %esp,%ebp
  80126b:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80126e:	68 b7 29 80 00       	push   $0x8029b7
  801273:	68 05 01 00 00       	push   $0x105
  801278:	68 5a 29 80 00       	push   $0x80295a
  80127d:	e8 59 0e 00 00       	call   8020db <_panic>

00801282 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801282:	f3 0f 1e fb          	endbr32 
  801286:	55                   	push   %ebp
  801287:	89 e5                	mov    %esp,%ebp
  801289:	56                   	push   %esi
  80128a:	53                   	push   %ebx
  80128b:	8b 75 08             	mov    0x8(%ebp),%esi
  80128e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801291:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  801294:	85 c0                	test   %eax,%eax
  801296:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80129b:	0f 44 c2             	cmove  %edx,%eax
  80129e:	83 ec 0c             	sub    $0xc,%esp
  8012a1:	50                   	push   %eax
  8012a2:	e8 72 fa ff ff       	call   800d19 <sys_ipc_recv>

	if (from_env_store != NULL)
  8012a7:	83 c4 10             	add    $0x10,%esp
  8012aa:	85 f6                	test   %esi,%esi
  8012ac:	74 15                	je     8012c3 <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  8012ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8012b3:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8012b6:	74 09                	je     8012c1 <ipc_recv+0x3f>
  8012b8:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8012be:	8b 52 74             	mov    0x74(%edx),%edx
  8012c1:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  8012c3:	85 db                	test   %ebx,%ebx
  8012c5:	74 15                	je     8012dc <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  8012c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8012cc:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8012cf:	74 09                	je     8012da <ipc_recv+0x58>
  8012d1:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8012d7:	8b 52 78             	mov    0x78(%edx),%edx
  8012da:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  8012dc:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8012df:	74 08                	je     8012e9 <ipc_recv+0x67>
  8012e1:	a1 08 40 80 00       	mov    0x804008,%eax
  8012e6:	8b 40 70             	mov    0x70(%eax),%eax
}
  8012e9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012ec:	5b                   	pop    %ebx
  8012ed:	5e                   	pop    %esi
  8012ee:	5d                   	pop    %ebp
  8012ef:	c3                   	ret    

008012f0 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8012f0:	f3 0f 1e fb          	endbr32 
  8012f4:	55                   	push   %ebp
  8012f5:	89 e5                	mov    %esp,%ebp
  8012f7:	57                   	push   %edi
  8012f8:	56                   	push   %esi
  8012f9:	53                   	push   %ebx
  8012fa:	83 ec 0c             	sub    $0xc,%esp
  8012fd:	8b 7d 08             	mov    0x8(%ebp),%edi
  801300:	8b 75 0c             	mov    0xc(%ebp),%esi
  801303:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801306:	eb 1f                	jmp    801327 <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  801308:	6a 00                	push   $0x0
  80130a:	68 00 00 c0 ee       	push   $0xeec00000
  80130f:	56                   	push   %esi
  801310:	57                   	push   %edi
  801311:	e8 da f9 ff ff       	call   800cf0 <sys_ipc_try_send>
  801316:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  801319:	85 c0                	test   %eax,%eax
  80131b:	74 30                	je     80134d <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  80131d:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801320:	75 19                	jne    80133b <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  801322:	e8 b0 f8 ff ff       	call   800bd7 <sys_yield>
		if (pg != NULL) {
  801327:	85 db                	test   %ebx,%ebx
  801329:	74 dd                	je     801308 <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  80132b:	ff 75 14             	pushl  0x14(%ebp)
  80132e:	53                   	push   %ebx
  80132f:	56                   	push   %esi
  801330:	57                   	push   %edi
  801331:	e8 ba f9 ff ff       	call   800cf0 <sys_ipc_try_send>
  801336:	83 c4 10             	add    $0x10,%esp
  801339:	eb de                	jmp    801319 <ipc_send+0x29>
			panic("ipc_send: %d", res);
  80133b:	50                   	push   %eax
  80133c:	68 cd 29 80 00       	push   $0x8029cd
  801341:	6a 3e                	push   $0x3e
  801343:	68 da 29 80 00       	push   $0x8029da
  801348:	e8 8e 0d 00 00       	call   8020db <_panic>
	}
}
  80134d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801350:	5b                   	pop    %ebx
  801351:	5e                   	pop    %esi
  801352:	5f                   	pop    %edi
  801353:	5d                   	pop    %ebp
  801354:	c3                   	ret    

00801355 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801355:	f3 0f 1e fb          	endbr32 
  801359:	55                   	push   %ebp
  80135a:	89 e5                	mov    %esp,%ebp
  80135c:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80135f:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801364:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801367:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80136d:	8b 52 50             	mov    0x50(%edx),%edx
  801370:	39 ca                	cmp    %ecx,%edx
  801372:	74 11                	je     801385 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801374:	83 c0 01             	add    $0x1,%eax
  801377:	3d 00 04 00 00       	cmp    $0x400,%eax
  80137c:	75 e6                	jne    801364 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  80137e:	b8 00 00 00 00       	mov    $0x0,%eax
  801383:	eb 0b                	jmp    801390 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801385:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801388:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80138d:	8b 40 48             	mov    0x48(%eax),%eax
}
  801390:	5d                   	pop    %ebp
  801391:	c3                   	ret    

00801392 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801392:	f3 0f 1e fb          	endbr32 
  801396:	55                   	push   %ebp
  801397:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801399:	8b 45 08             	mov    0x8(%ebp),%eax
  80139c:	05 00 00 00 30       	add    $0x30000000,%eax
  8013a1:	c1 e8 0c             	shr    $0xc,%eax
}
  8013a4:	5d                   	pop    %ebp
  8013a5:	c3                   	ret    

008013a6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8013a6:	f3 0f 1e fb          	endbr32 
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
  8013ad:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  8013b0:	ff 75 08             	pushl  0x8(%ebp)
  8013b3:	e8 da ff ff ff       	call   801392 <fd2num>
  8013b8:	83 c4 10             	add    $0x10,%esp
  8013bb:	c1 e0 0c             	shl    $0xc,%eax
  8013be:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8013c3:	c9                   	leave  
  8013c4:	c3                   	ret    

008013c5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8013c5:	f3 0f 1e fb          	endbr32 
  8013c9:	55                   	push   %ebp
  8013ca:	89 e5                	mov    %esp,%ebp
  8013cc:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8013d1:	89 c2                	mov    %eax,%edx
  8013d3:	c1 ea 16             	shr    $0x16,%edx
  8013d6:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8013dd:	f6 c2 01             	test   $0x1,%dl
  8013e0:	74 2d                	je     80140f <fd_alloc+0x4a>
  8013e2:	89 c2                	mov    %eax,%edx
  8013e4:	c1 ea 0c             	shr    $0xc,%edx
  8013e7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8013ee:	f6 c2 01             	test   $0x1,%dl
  8013f1:	74 1c                	je     80140f <fd_alloc+0x4a>
  8013f3:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8013f8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8013fd:	75 d2                	jne    8013d1 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8013ff:	8b 45 08             	mov    0x8(%ebp),%eax
  801402:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801408:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80140d:	eb 0a                	jmp    801419 <fd_alloc+0x54>
			*fd_store = fd;
  80140f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801412:	89 01                	mov    %eax,(%ecx)
			return 0;
  801414:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801419:	5d                   	pop    %ebp
  80141a:	c3                   	ret    

0080141b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80141b:	f3 0f 1e fb          	endbr32 
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
  801422:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801425:	83 f8 1f             	cmp    $0x1f,%eax
  801428:	77 30                	ja     80145a <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80142a:	c1 e0 0c             	shl    $0xc,%eax
  80142d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801432:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801438:	f6 c2 01             	test   $0x1,%dl
  80143b:	74 24                	je     801461 <fd_lookup+0x46>
  80143d:	89 c2                	mov    %eax,%edx
  80143f:	c1 ea 0c             	shr    $0xc,%edx
  801442:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801449:	f6 c2 01             	test   $0x1,%dl
  80144c:	74 1a                	je     801468 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80144e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801451:	89 02                	mov    %eax,(%edx)
	return 0;
  801453:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801458:	5d                   	pop    %ebp
  801459:	c3                   	ret    
		return -E_INVAL;
  80145a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80145f:	eb f7                	jmp    801458 <fd_lookup+0x3d>
		return -E_INVAL;
  801461:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801466:	eb f0                	jmp    801458 <fd_lookup+0x3d>
  801468:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80146d:	eb e9                	jmp    801458 <fd_lookup+0x3d>

0080146f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80146f:	f3 0f 1e fb          	endbr32 
  801473:	55                   	push   %ebp
  801474:	89 e5                	mov    %esp,%ebp
  801476:	83 ec 08             	sub    $0x8,%esp
  801479:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80147c:	ba 60 2a 80 00       	mov    $0x802a60,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801481:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  801486:	39 08                	cmp    %ecx,(%eax)
  801488:	74 33                	je     8014bd <dev_lookup+0x4e>
  80148a:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80148d:	8b 02                	mov    (%edx),%eax
  80148f:	85 c0                	test   %eax,%eax
  801491:	75 f3                	jne    801486 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801493:	a1 08 40 80 00       	mov    0x804008,%eax
  801498:	8b 40 48             	mov    0x48(%eax),%eax
  80149b:	83 ec 04             	sub    $0x4,%esp
  80149e:	51                   	push   %ecx
  80149f:	50                   	push   %eax
  8014a0:	68 e4 29 80 00       	push   $0x8029e4
  8014a5:	e8 66 ed ff ff       	call   800210 <cprintf>
	*dev = 0;
  8014aa:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014ad:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8014b3:	83 c4 10             	add    $0x10,%esp
  8014b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8014bb:	c9                   	leave  
  8014bc:	c3                   	ret    
			*dev = devtab[i];
  8014bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8014c0:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8014c7:	eb f2                	jmp    8014bb <dev_lookup+0x4c>

008014c9 <fd_close>:
{
  8014c9:	f3 0f 1e fb          	endbr32 
  8014cd:	55                   	push   %ebp
  8014ce:	89 e5                	mov    %esp,%ebp
  8014d0:	57                   	push   %edi
  8014d1:	56                   	push   %esi
  8014d2:	53                   	push   %ebx
  8014d3:	83 ec 28             	sub    $0x28,%esp
  8014d6:	8b 75 08             	mov    0x8(%ebp),%esi
  8014d9:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8014dc:	56                   	push   %esi
  8014dd:	e8 b0 fe ff ff       	call   801392 <fd2num>
  8014e2:	83 c4 08             	add    $0x8,%esp
  8014e5:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8014e8:	52                   	push   %edx
  8014e9:	50                   	push   %eax
  8014ea:	e8 2c ff ff ff       	call   80141b <fd_lookup>
  8014ef:	89 c3                	mov    %eax,%ebx
  8014f1:	83 c4 10             	add    $0x10,%esp
  8014f4:	85 c0                	test   %eax,%eax
  8014f6:	78 05                	js     8014fd <fd_close+0x34>
	    || fd != fd2)
  8014f8:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8014fb:	74 16                	je     801513 <fd_close+0x4a>
		return (must_exist ? r : 0);
  8014fd:	89 f8                	mov    %edi,%eax
  8014ff:	84 c0                	test   %al,%al
  801501:	b8 00 00 00 00       	mov    $0x0,%eax
  801506:	0f 44 d8             	cmove  %eax,%ebx
}
  801509:	89 d8                	mov    %ebx,%eax
  80150b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80150e:	5b                   	pop    %ebx
  80150f:	5e                   	pop    %esi
  801510:	5f                   	pop    %edi
  801511:	5d                   	pop    %ebp
  801512:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801513:	83 ec 08             	sub    $0x8,%esp
  801516:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801519:	50                   	push   %eax
  80151a:	ff 36                	pushl  (%esi)
  80151c:	e8 4e ff ff ff       	call   80146f <dev_lookup>
  801521:	89 c3                	mov    %eax,%ebx
  801523:	83 c4 10             	add    $0x10,%esp
  801526:	85 c0                	test   %eax,%eax
  801528:	78 1a                	js     801544 <fd_close+0x7b>
		if (dev->dev_close)
  80152a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80152d:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801530:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801535:	85 c0                	test   %eax,%eax
  801537:	74 0b                	je     801544 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801539:	83 ec 0c             	sub    $0xc,%esp
  80153c:	56                   	push   %esi
  80153d:	ff d0                	call   *%eax
  80153f:	89 c3                	mov    %eax,%ebx
  801541:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801544:	83 ec 08             	sub    $0x8,%esp
  801547:	56                   	push   %esi
  801548:	6a 00                	push   $0x0
  80154a:	e8 05 f7 ff ff       	call   800c54 <sys_page_unmap>
	return r;
  80154f:	83 c4 10             	add    $0x10,%esp
  801552:	eb b5                	jmp    801509 <fd_close+0x40>

00801554 <close>:

int
close(int fdnum)
{
  801554:	f3 0f 1e fb          	endbr32 
  801558:	55                   	push   %ebp
  801559:	89 e5                	mov    %esp,%ebp
  80155b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80155e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801561:	50                   	push   %eax
  801562:	ff 75 08             	pushl  0x8(%ebp)
  801565:	e8 b1 fe ff ff       	call   80141b <fd_lookup>
  80156a:	83 c4 10             	add    $0x10,%esp
  80156d:	85 c0                	test   %eax,%eax
  80156f:	79 02                	jns    801573 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801571:	c9                   	leave  
  801572:	c3                   	ret    
		return fd_close(fd, 1);
  801573:	83 ec 08             	sub    $0x8,%esp
  801576:	6a 01                	push   $0x1
  801578:	ff 75 f4             	pushl  -0xc(%ebp)
  80157b:	e8 49 ff ff ff       	call   8014c9 <fd_close>
  801580:	83 c4 10             	add    $0x10,%esp
  801583:	eb ec                	jmp    801571 <close+0x1d>

00801585 <close_all>:

void
close_all(void)
{
  801585:	f3 0f 1e fb          	endbr32 
  801589:	55                   	push   %ebp
  80158a:	89 e5                	mov    %esp,%ebp
  80158c:	53                   	push   %ebx
  80158d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801590:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801595:	83 ec 0c             	sub    $0xc,%esp
  801598:	53                   	push   %ebx
  801599:	e8 b6 ff ff ff       	call   801554 <close>
	for (i = 0; i < MAXFD; i++)
  80159e:	83 c3 01             	add    $0x1,%ebx
  8015a1:	83 c4 10             	add    $0x10,%esp
  8015a4:	83 fb 20             	cmp    $0x20,%ebx
  8015a7:	75 ec                	jne    801595 <close_all+0x10>
}
  8015a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015ac:	c9                   	leave  
  8015ad:	c3                   	ret    

008015ae <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8015ae:	f3 0f 1e fb          	endbr32 
  8015b2:	55                   	push   %ebp
  8015b3:	89 e5                	mov    %esp,%ebp
  8015b5:	57                   	push   %edi
  8015b6:	56                   	push   %esi
  8015b7:	53                   	push   %ebx
  8015b8:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8015bb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8015be:	50                   	push   %eax
  8015bf:	ff 75 08             	pushl  0x8(%ebp)
  8015c2:	e8 54 fe ff ff       	call   80141b <fd_lookup>
  8015c7:	89 c3                	mov    %eax,%ebx
  8015c9:	83 c4 10             	add    $0x10,%esp
  8015cc:	85 c0                	test   %eax,%eax
  8015ce:	0f 88 81 00 00 00    	js     801655 <dup+0xa7>
		return r;
	close(newfdnum);
  8015d4:	83 ec 0c             	sub    $0xc,%esp
  8015d7:	ff 75 0c             	pushl  0xc(%ebp)
  8015da:	e8 75 ff ff ff       	call   801554 <close>

	newfd = INDEX2FD(newfdnum);
  8015df:	8b 75 0c             	mov    0xc(%ebp),%esi
  8015e2:	c1 e6 0c             	shl    $0xc,%esi
  8015e5:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8015eb:	83 c4 04             	add    $0x4,%esp
  8015ee:	ff 75 e4             	pushl  -0x1c(%ebp)
  8015f1:	e8 b0 fd ff ff       	call   8013a6 <fd2data>
  8015f6:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8015f8:	89 34 24             	mov    %esi,(%esp)
  8015fb:	e8 a6 fd ff ff       	call   8013a6 <fd2data>
  801600:	83 c4 10             	add    $0x10,%esp
  801603:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801605:	89 d8                	mov    %ebx,%eax
  801607:	c1 e8 16             	shr    $0x16,%eax
  80160a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801611:	a8 01                	test   $0x1,%al
  801613:	74 11                	je     801626 <dup+0x78>
  801615:	89 d8                	mov    %ebx,%eax
  801617:	c1 e8 0c             	shr    $0xc,%eax
  80161a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801621:	f6 c2 01             	test   $0x1,%dl
  801624:	75 39                	jne    80165f <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801626:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801629:	89 d0                	mov    %edx,%eax
  80162b:	c1 e8 0c             	shr    $0xc,%eax
  80162e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801635:	83 ec 0c             	sub    $0xc,%esp
  801638:	25 07 0e 00 00       	and    $0xe07,%eax
  80163d:	50                   	push   %eax
  80163e:	56                   	push   %esi
  80163f:	6a 00                	push   $0x0
  801641:	52                   	push   %edx
  801642:	6a 00                	push   $0x0
  801644:	e8 e1 f5 ff ff       	call   800c2a <sys_page_map>
  801649:	89 c3                	mov    %eax,%ebx
  80164b:	83 c4 20             	add    $0x20,%esp
  80164e:	85 c0                	test   %eax,%eax
  801650:	78 31                	js     801683 <dup+0xd5>
		goto err;

	return newfdnum;
  801652:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801655:	89 d8                	mov    %ebx,%eax
  801657:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80165a:	5b                   	pop    %ebx
  80165b:	5e                   	pop    %esi
  80165c:	5f                   	pop    %edi
  80165d:	5d                   	pop    %ebp
  80165e:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80165f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801666:	83 ec 0c             	sub    $0xc,%esp
  801669:	25 07 0e 00 00       	and    $0xe07,%eax
  80166e:	50                   	push   %eax
  80166f:	57                   	push   %edi
  801670:	6a 00                	push   $0x0
  801672:	53                   	push   %ebx
  801673:	6a 00                	push   $0x0
  801675:	e8 b0 f5 ff ff       	call   800c2a <sys_page_map>
  80167a:	89 c3                	mov    %eax,%ebx
  80167c:	83 c4 20             	add    $0x20,%esp
  80167f:	85 c0                	test   %eax,%eax
  801681:	79 a3                	jns    801626 <dup+0x78>
	sys_page_unmap(0, newfd);
  801683:	83 ec 08             	sub    $0x8,%esp
  801686:	56                   	push   %esi
  801687:	6a 00                	push   $0x0
  801689:	e8 c6 f5 ff ff       	call   800c54 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80168e:	83 c4 08             	add    $0x8,%esp
  801691:	57                   	push   %edi
  801692:	6a 00                	push   $0x0
  801694:	e8 bb f5 ff ff       	call   800c54 <sys_page_unmap>
	return r;
  801699:	83 c4 10             	add    $0x10,%esp
  80169c:	eb b7                	jmp    801655 <dup+0xa7>

0080169e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80169e:	f3 0f 1e fb          	endbr32 
  8016a2:	55                   	push   %ebp
  8016a3:	89 e5                	mov    %esp,%ebp
  8016a5:	53                   	push   %ebx
  8016a6:	83 ec 1c             	sub    $0x1c,%esp
  8016a9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8016ac:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8016af:	50                   	push   %eax
  8016b0:	53                   	push   %ebx
  8016b1:	e8 65 fd ff ff       	call   80141b <fd_lookup>
  8016b6:	83 c4 10             	add    $0x10,%esp
  8016b9:	85 c0                	test   %eax,%eax
  8016bb:	78 3f                	js     8016fc <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016bd:	83 ec 08             	sub    $0x8,%esp
  8016c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016c3:	50                   	push   %eax
  8016c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c7:	ff 30                	pushl  (%eax)
  8016c9:	e8 a1 fd ff ff       	call   80146f <dev_lookup>
  8016ce:	83 c4 10             	add    $0x10,%esp
  8016d1:	85 c0                	test   %eax,%eax
  8016d3:	78 27                	js     8016fc <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8016d5:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8016d8:	8b 42 08             	mov    0x8(%edx),%eax
  8016db:	83 e0 03             	and    $0x3,%eax
  8016de:	83 f8 01             	cmp    $0x1,%eax
  8016e1:	74 1e                	je     801701 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8016e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8016e6:	8b 40 08             	mov    0x8(%eax),%eax
  8016e9:	85 c0                	test   %eax,%eax
  8016eb:	74 35                	je     801722 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8016ed:	83 ec 04             	sub    $0x4,%esp
  8016f0:	ff 75 10             	pushl  0x10(%ebp)
  8016f3:	ff 75 0c             	pushl  0xc(%ebp)
  8016f6:	52                   	push   %edx
  8016f7:	ff d0                	call   *%eax
  8016f9:	83 c4 10             	add    $0x10,%esp
}
  8016fc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ff:	c9                   	leave  
  801700:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801701:	a1 08 40 80 00       	mov    0x804008,%eax
  801706:	8b 40 48             	mov    0x48(%eax),%eax
  801709:	83 ec 04             	sub    $0x4,%esp
  80170c:	53                   	push   %ebx
  80170d:	50                   	push   %eax
  80170e:	68 25 2a 80 00       	push   $0x802a25
  801713:	e8 f8 ea ff ff       	call   800210 <cprintf>
		return -E_INVAL;
  801718:	83 c4 10             	add    $0x10,%esp
  80171b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801720:	eb da                	jmp    8016fc <read+0x5e>
		return -E_NOT_SUPP;
  801722:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801727:	eb d3                	jmp    8016fc <read+0x5e>

00801729 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801729:	f3 0f 1e fb          	endbr32 
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	57                   	push   %edi
  801731:	56                   	push   %esi
  801732:	53                   	push   %ebx
  801733:	83 ec 0c             	sub    $0xc,%esp
  801736:	8b 7d 08             	mov    0x8(%ebp),%edi
  801739:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80173c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801741:	eb 02                	jmp    801745 <readn+0x1c>
  801743:	01 c3                	add    %eax,%ebx
  801745:	39 f3                	cmp    %esi,%ebx
  801747:	73 21                	jae    80176a <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801749:	83 ec 04             	sub    $0x4,%esp
  80174c:	89 f0                	mov    %esi,%eax
  80174e:	29 d8                	sub    %ebx,%eax
  801750:	50                   	push   %eax
  801751:	89 d8                	mov    %ebx,%eax
  801753:	03 45 0c             	add    0xc(%ebp),%eax
  801756:	50                   	push   %eax
  801757:	57                   	push   %edi
  801758:	e8 41 ff ff ff       	call   80169e <read>
		if (m < 0)
  80175d:	83 c4 10             	add    $0x10,%esp
  801760:	85 c0                	test   %eax,%eax
  801762:	78 04                	js     801768 <readn+0x3f>
			return m;
		if (m == 0)
  801764:	75 dd                	jne    801743 <readn+0x1a>
  801766:	eb 02                	jmp    80176a <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801768:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80176a:	89 d8                	mov    %ebx,%eax
  80176c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80176f:	5b                   	pop    %ebx
  801770:	5e                   	pop    %esi
  801771:	5f                   	pop    %edi
  801772:	5d                   	pop    %ebp
  801773:	c3                   	ret    

00801774 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801774:	f3 0f 1e fb          	endbr32 
  801778:	55                   	push   %ebp
  801779:	89 e5                	mov    %esp,%ebp
  80177b:	53                   	push   %ebx
  80177c:	83 ec 1c             	sub    $0x1c,%esp
  80177f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801782:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801785:	50                   	push   %eax
  801786:	53                   	push   %ebx
  801787:	e8 8f fc ff ff       	call   80141b <fd_lookup>
  80178c:	83 c4 10             	add    $0x10,%esp
  80178f:	85 c0                	test   %eax,%eax
  801791:	78 3a                	js     8017cd <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801793:	83 ec 08             	sub    $0x8,%esp
  801796:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801799:	50                   	push   %eax
  80179a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80179d:	ff 30                	pushl  (%eax)
  80179f:	e8 cb fc ff ff       	call   80146f <dev_lookup>
  8017a4:	83 c4 10             	add    $0x10,%esp
  8017a7:	85 c0                	test   %eax,%eax
  8017a9:	78 22                	js     8017cd <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8017ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ae:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8017b2:	74 1e                	je     8017d2 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8017b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017b7:	8b 52 0c             	mov    0xc(%edx),%edx
  8017ba:	85 d2                	test   %edx,%edx
  8017bc:	74 35                	je     8017f3 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8017be:	83 ec 04             	sub    $0x4,%esp
  8017c1:	ff 75 10             	pushl  0x10(%ebp)
  8017c4:	ff 75 0c             	pushl  0xc(%ebp)
  8017c7:	50                   	push   %eax
  8017c8:	ff d2                	call   *%edx
  8017ca:	83 c4 10             	add    $0x10,%esp
}
  8017cd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017d0:	c9                   	leave  
  8017d1:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8017d2:	a1 08 40 80 00       	mov    0x804008,%eax
  8017d7:	8b 40 48             	mov    0x48(%eax),%eax
  8017da:	83 ec 04             	sub    $0x4,%esp
  8017dd:	53                   	push   %ebx
  8017de:	50                   	push   %eax
  8017df:	68 41 2a 80 00       	push   $0x802a41
  8017e4:	e8 27 ea ff ff       	call   800210 <cprintf>
		return -E_INVAL;
  8017e9:	83 c4 10             	add    $0x10,%esp
  8017ec:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017f1:	eb da                	jmp    8017cd <write+0x59>
		return -E_NOT_SUPP;
  8017f3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017f8:	eb d3                	jmp    8017cd <write+0x59>

008017fa <seek>:

int
seek(int fdnum, off_t offset)
{
  8017fa:	f3 0f 1e fb          	endbr32 
  8017fe:	55                   	push   %ebp
  8017ff:	89 e5                	mov    %esp,%ebp
  801801:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801804:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801807:	50                   	push   %eax
  801808:	ff 75 08             	pushl  0x8(%ebp)
  80180b:	e8 0b fc ff ff       	call   80141b <fd_lookup>
  801810:	83 c4 10             	add    $0x10,%esp
  801813:	85 c0                	test   %eax,%eax
  801815:	78 0e                	js     801825 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801817:	8b 55 0c             	mov    0xc(%ebp),%edx
  80181a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80181d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801820:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801825:	c9                   	leave  
  801826:	c3                   	ret    

00801827 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801827:	f3 0f 1e fb          	endbr32 
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	53                   	push   %ebx
  80182f:	83 ec 1c             	sub    $0x1c,%esp
  801832:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801835:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801838:	50                   	push   %eax
  801839:	53                   	push   %ebx
  80183a:	e8 dc fb ff ff       	call   80141b <fd_lookup>
  80183f:	83 c4 10             	add    $0x10,%esp
  801842:	85 c0                	test   %eax,%eax
  801844:	78 37                	js     80187d <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801846:	83 ec 08             	sub    $0x8,%esp
  801849:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80184c:	50                   	push   %eax
  80184d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801850:	ff 30                	pushl  (%eax)
  801852:	e8 18 fc ff ff       	call   80146f <dev_lookup>
  801857:	83 c4 10             	add    $0x10,%esp
  80185a:	85 c0                	test   %eax,%eax
  80185c:	78 1f                	js     80187d <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80185e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801861:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801865:	74 1b                	je     801882 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801867:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80186a:	8b 52 18             	mov    0x18(%edx),%edx
  80186d:	85 d2                	test   %edx,%edx
  80186f:	74 32                	je     8018a3 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801871:	83 ec 08             	sub    $0x8,%esp
  801874:	ff 75 0c             	pushl  0xc(%ebp)
  801877:	50                   	push   %eax
  801878:	ff d2                	call   *%edx
  80187a:	83 c4 10             	add    $0x10,%esp
}
  80187d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801880:	c9                   	leave  
  801881:	c3                   	ret    
			thisenv->env_id, fdnum);
  801882:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801887:	8b 40 48             	mov    0x48(%eax),%eax
  80188a:	83 ec 04             	sub    $0x4,%esp
  80188d:	53                   	push   %ebx
  80188e:	50                   	push   %eax
  80188f:	68 04 2a 80 00       	push   $0x802a04
  801894:	e8 77 e9 ff ff       	call   800210 <cprintf>
		return -E_INVAL;
  801899:	83 c4 10             	add    $0x10,%esp
  80189c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018a1:	eb da                	jmp    80187d <ftruncate+0x56>
		return -E_NOT_SUPP;
  8018a3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018a8:	eb d3                	jmp    80187d <ftruncate+0x56>

008018aa <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8018aa:	f3 0f 1e fb          	endbr32 
  8018ae:	55                   	push   %ebp
  8018af:	89 e5                	mov    %esp,%ebp
  8018b1:	53                   	push   %ebx
  8018b2:	83 ec 1c             	sub    $0x1c,%esp
  8018b5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018b8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018bb:	50                   	push   %eax
  8018bc:	ff 75 08             	pushl  0x8(%ebp)
  8018bf:	e8 57 fb ff ff       	call   80141b <fd_lookup>
  8018c4:	83 c4 10             	add    $0x10,%esp
  8018c7:	85 c0                	test   %eax,%eax
  8018c9:	78 4b                	js     801916 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018cb:	83 ec 08             	sub    $0x8,%esp
  8018ce:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d1:	50                   	push   %eax
  8018d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d5:	ff 30                	pushl  (%eax)
  8018d7:	e8 93 fb ff ff       	call   80146f <dev_lookup>
  8018dc:	83 c4 10             	add    $0x10,%esp
  8018df:	85 c0                	test   %eax,%eax
  8018e1:	78 33                	js     801916 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8018e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018e6:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8018ea:	74 2f                	je     80191b <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8018ec:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8018ef:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8018f6:	00 00 00 
	stat->st_isdir = 0;
  8018f9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801900:	00 00 00 
	stat->st_dev = dev;
  801903:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801909:	83 ec 08             	sub    $0x8,%esp
  80190c:	53                   	push   %ebx
  80190d:	ff 75 f0             	pushl  -0x10(%ebp)
  801910:	ff 50 14             	call   *0x14(%eax)
  801913:	83 c4 10             	add    $0x10,%esp
}
  801916:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801919:	c9                   	leave  
  80191a:	c3                   	ret    
		return -E_NOT_SUPP;
  80191b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801920:	eb f4                	jmp    801916 <fstat+0x6c>

00801922 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801922:	f3 0f 1e fb          	endbr32 
  801926:	55                   	push   %ebp
  801927:	89 e5                	mov    %esp,%ebp
  801929:	56                   	push   %esi
  80192a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80192b:	83 ec 08             	sub    $0x8,%esp
  80192e:	6a 00                	push   $0x0
  801930:	ff 75 08             	pushl  0x8(%ebp)
  801933:	e8 fb 01 00 00       	call   801b33 <open>
  801938:	89 c3                	mov    %eax,%ebx
  80193a:	83 c4 10             	add    $0x10,%esp
  80193d:	85 c0                	test   %eax,%eax
  80193f:	78 1b                	js     80195c <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801941:	83 ec 08             	sub    $0x8,%esp
  801944:	ff 75 0c             	pushl  0xc(%ebp)
  801947:	50                   	push   %eax
  801948:	e8 5d ff ff ff       	call   8018aa <fstat>
  80194d:	89 c6                	mov    %eax,%esi
	close(fd);
  80194f:	89 1c 24             	mov    %ebx,(%esp)
  801952:	e8 fd fb ff ff       	call   801554 <close>
	return r;
  801957:	83 c4 10             	add    $0x10,%esp
  80195a:	89 f3                	mov    %esi,%ebx
}
  80195c:	89 d8                	mov    %ebx,%eax
  80195e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801961:	5b                   	pop    %ebx
  801962:	5e                   	pop    %esi
  801963:	5d                   	pop    %ebp
  801964:	c3                   	ret    

00801965 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801965:	55                   	push   %ebp
  801966:	89 e5                	mov    %esp,%ebp
  801968:	56                   	push   %esi
  801969:	53                   	push   %ebx
  80196a:	89 c6                	mov    %eax,%esi
  80196c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80196e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801975:	74 27                	je     80199e <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801977:	6a 07                	push   $0x7
  801979:	68 00 50 80 00       	push   $0x805000
  80197e:	56                   	push   %esi
  80197f:	ff 35 00 40 80 00    	pushl  0x804000
  801985:	e8 66 f9 ff ff       	call   8012f0 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80198a:	83 c4 0c             	add    $0xc,%esp
  80198d:	6a 00                	push   $0x0
  80198f:	53                   	push   %ebx
  801990:	6a 00                	push   $0x0
  801992:	e8 eb f8 ff ff       	call   801282 <ipc_recv>
}
  801997:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80199a:	5b                   	pop    %ebx
  80199b:	5e                   	pop    %esi
  80199c:	5d                   	pop    %ebp
  80199d:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80199e:	83 ec 0c             	sub    $0xc,%esp
  8019a1:	6a 01                	push   $0x1
  8019a3:	e8 ad f9 ff ff       	call   801355 <ipc_find_env>
  8019a8:	a3 00 40 80 00       	mov    %eax,0x804000
  8019ad:	83 c4 10             	add    $0x10,%esp
  8019b0:	eb c5                	jmp    801977 <fsipc+0x12>

008019b2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8019b2:	f3 0f 1e fb          	endbr32 
  8019b6:	55                   	push   %ebp
  8019b7:	89 e5                	mov    %esp,%ebp
  8019b9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8019bc:	8b 45 08             	mov    0x8(%ebp),%eax
  8019bf:	8b 40 0c             	mov    0xc(%eax),%eax
  8019c2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8019c7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8019ca:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8019cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8019d4:	b8 02 00 00 00       	mov    $0x2,%eax
  8019d9:	e8 87 ff ff ff       	call   801965 <fsipc>
}
  8019de:	c9                   	leave  
  8019df:	c3                   	ret    

008019e0 <devfile_flush>:
{
  8019e0:	f3 0f 1e fb          	endbr32 
  8019e4:	55                   	push   %ebp
  8019e5:	89 e5                	mov    %esp,%ebp
  8019e7:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  8019ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8019ed:	8b 40 0c             	mov    0xc(%eax),%eax
  8019f0:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8019f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8019fa:	b8 06 00 00 00       	mov    $0x6,%eax
  8019ff:	e8 61 ff ff ff       	call   801965 <fsipc>
}
  801a04:	c9                   	leave  
  801a05:	c3                   	ret    

00801a06 <devfile_stat>:
{
  801a06:	f3 0f 1e fb          	endbr32 
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	53                   	push   %ebx
  801a0e:	83 ec 04             	sub    $0x4,%esp
  801a11:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a14:	8b 45 08             	mov    0x8(%ebp),%eax
  801a17:	8b 40 0c             	mov    0xc(%eax),%eax
  801a1a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a1f:	ba 00 00 00 00       	mov    $0x0,%edx
  801a24:	b8 05 00 00 00       	mov    $0x5,%eax
  801a29:	e8 37 ff ff ff       	call   801965 <fsipc>
  801a2e:	85 c0                	test   %eax,%eax
  801a30:	78 2c                	js     801a5e <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a32:	83 ec 08             	sub    $0x8,%esp
  801a35:	68 00 50 80 00       	push   $0x805000
  801a3a:	53                   	push   %ebx
  801a3b:	e8 3a ed ff ff       	call   80077a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801a40:	a1 80 50 80 00       	mov    0x805080,%eax
  801a45:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801a4b:	a1 84 50 80 00       	mov    0x805084,%eax
  801a50:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801a56:	83 c4 10             	add    $0x10,%esp
  801a59:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801a5e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a61:	c9                   	leave  
  801a62:	c3                   	ret    

00801a63 <devfile_write>:
{
  801a63:	f3 0f 1e fb          	endbr32 
  801a67:	55                   	push   %ebp
  801a68:	89 e5                	mov    %esp,%ebp
  801a6a:	83 ec 0c             	sub    $0xc,%esp
  801a6d:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801a70:	8b 55 08             	mov    0x8(%ebp),%edx
  801a73:	8b 52 0c             	mov    0xc(%edx),%edx
  801a76:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801a7c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801a81:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801a86:	0f 47 c2             	cmova  %edx,%eax
  801a89:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801a8e:	50                   	push   %eax
  801a8f:	ff 75 0c             	pushl  0xc(%ebp)
  801a92:	68 08 50 80 00       	push   $0x805008
  801a97:	e8 96 ee ff ff       	call   800932 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801a9c:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa1:	b8 04 00 00 00       	mov    $0x4,%eax
  801aa6:	e8 ba fe ff ff       	call   801965 <fsipc>
}
  801aab:	c9                   	leave  
  801aac:	c3                   	ret    

00801aad <devfile_read>:
{
  801aad:	f3 0f 1e fb          	endbr32 
  801ab1:	55                   	push   %ebp
  801ab2:	89 e5                	mov    %esp,%ebp
  801ab4:	56                   	push   %esi
  801ab5:	53                   	push   %ebx
  801ab6:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801ab9:	8b 45 08             	mov    0x8(%ebp),%eax
  801abc:	8b 40 0c             	mov    0xc(%eax),%eax
  801abf:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801ac4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801aca:	ba 00 00 00 00       	mov    $0x0,%edx
  801acf:	b8 03 00 00 00       	mov    $0x3,%eax
  801ad4:	e8 8c fe ff ff       	call   801965 <fsipc>
  801ad9:	89 c3                	mov    %eax,%ebx
  801adb:	85 c0                	test   %eax,%eax
  801add:	78 1f                	js     801afe <devfile_read+0x51>
	assert(r <= n);
  801adf:	39 f0                	cmp    %esi,%eax
  801ae1:	77 24                	ja     801b07 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801ae3:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801ae8:	7f 33                	jg     801b1d <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801aea:	83 ec 04             	sub    $0x4,%esp
  801aed:	50                   	push   %eax
  801aee:	68 00 50 80 00       	push   $0x805000
  801af3:	ff 75 0c             	pushl  0xc(%ebp)
  801af6:	e8 37 ee ff ff       	call   800932 <memmove>
	return r;
  801afb:	83 c4 10             	add    $0x10,%esp
}
  801afe:	89 d8                	mov    %ebx,%eax
  801b00:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b03:	5b                   	pop    %ebx
  801b04:	5e                   	pop    %esi
  801b05:	5d                   	pop    %ebp
  801b06:	c3                   	ret    
	assert(r <= n);
  801b07:	68 70 2a 80 00       	push   $0x802a70
  801b0c:	68 77 2a 80 00       	push   $0x802a77
  801b11:	6a 7c                	push   $0x7c
  801b13:	68 8c 2a 80 00       	push   $0x802a8c
  801b18:	e8 be 05 00 00       	call   8020db <_panic>
	assert(r <= PGSIZE);
  801b1d:	68 97 2a 80 00       	push   $0x802a97
  801b22:	68 77 2a 80 00       	push   $0x802a77
  801b27:	6a 7d                	push   $0x7d
  801b29:	68 8c 2a 80 00       	push   $0x802a8c
  801b2e:	e8 a8 05 00 00       	call   8020db <_panic>

00801b33 <open>:
{
  801b33:	f3 0f 1e fb          	endbr32 
  801b37:	55                   	push   %ebp
  801b38:	89 e5                	mov    %esp,%ebp
  801b3a:	56                   	push   %esi
  801b3b:	53                   	push   %ebx
  801b3c:	83 ec 1c             	sub    $0x1c,%esp
  801b3f:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801b42:	56                   	push   %esi
  801b43:	e8 ef eb ff ff       	call   800737 <strlen>
  801b48:	83 c4 10             	add    $0x10,%esp
  801b4b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801b50:	7f 6c                	jg     801bbe <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801b52:	83 ec 0c             	sub    $0xc,%esp
  801b55:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b58:	50                   	push   %eax
  801b59:	e8 67 f8 ff ff       	call   8013c5 <fd_alloc>
  801b5e:	89 c3                	mov    %eax,%ebx
  801b60:	83 c4 10             	add    $0x10,%esp
  801b63:	85 c0                	test   %eax,%eax
  801b65:	78 3c                	js     801ba3 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801b67:	83 ec 08             	sub    $0x8,%esp
  801b6a:	56                   	push   %esi
  801b6b:	68 00 50 80 00       	push   $0x805000
  801b70:	e8 05 ec ff ff       	call   80077a <strcpy>
	fsipcbuf.open.req_omode = mode;
  801b75:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b78:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801b7d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b80:	b8 01 00 00 00       	mov    $0x1,%eax
  801b85:	e8 db fd ff ff       	call   801965 <fsipc>
  801b8a:	89 c3                	mov    %eax,%ebx
  801b8c:	83 c4 10             	add    $0x10,%esp
  801b8f:	85 c0                	test   %eax,%eax
  801b91:	78 19                	js     801bac <open+0x79>
	return fd2num(fd);
  801b93:	83 ec 0c             	sub    $0xc,%esp
  801b96:	ff 75 f4             	pushl  -0xc(%ebp)
  801b99:	e8 f4 f7 ff ff       	call   801392 <fd2num>
  801b9e:	89 c3                	mov    %eax,%ebx
  801ba0:	83 c4 10             	add    $0x10,%esp
}
  801ba3:	89 d8                	mov    %ebx,%eax
  801ba5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ba8:	5b                   	pop    %ebx
  801ba9:	5e                   	pop    %esi
  801baa:	5d                   	pop    %ebp
  801bab:	c3                   	ret    
		fd_close(fd, 0);
  801bac:	83 ec 08             	sub    $0x8,%esp
  801baf:	6a 00                	push   $0x0
  801bb1:	ff 75 f4             	pushl  -0xc(%ebp)
  801bb4:	e8 10 f9 ff ff       	call   8014c9 <fd_close>
		return r;
  801bb9:	83 c4 10             	add    $0x10,%esp
  801bbc:	eb e5                	jmp    801ba3 <open+0x70>
		return -E_BAD_PATH;
  801bbe:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801bc3:	eb de                	jmp    801ba3 <open+0x70>

00801bc5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801bc5:	f3 0f 1e fb          	endbr32 
  801bc9:	55                   	push   %ebp
  801bca:	89 e5                	mov    %esp,%ebp
  801bcc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801bcf:	ba 00 00 00 00       	mov    $0x0,%edx
  801bd4:	b8 08 00 00 00       	mov    $0x8,%eax
  801bd9:	e8 87 fd ff ff       	call   801965 <fsipc>
}
  801bde:	c9                   	leave  
  801bdf:	c3                   	ret    

00801be0 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801be0:	f3 0f 1e fb          	endbr32 
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	56                   	push   %esi
  801be8:	53                   	push   %ebx
  801be9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801bec:	83 ec 0c             	sub    $0xc,%esp
  801bef:	ff 75 08             	pushl  0x8(%ebp)
  801bf2:	e8 af f7 ff ff       	call   8013a6 <fd2data>
  801bf7:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801bf9:	83 c4 08             	add    $0x8,%esp
  801bfc:	68 a3 2a 80 00       	push   $0x802aa3
  801c01:	53                   	push   %ebx
  801c02:	e8 73 eb ff ff       	call   80077a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c07:	8b 46 04             	mov    0x4(%esi),%eax
  801c0a:	2b 06                	sub    (%esi),%eax
  801c0c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c12:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c19:	00 00 00 
	stat->st_dev = &devpipe;
  801c1c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c23:	30 80 00 
	return 0;
}
  801c26:	b8 00 00 00 00       	mov    $0x0,%eax
  801c2b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c2e:	5b                   	pop    %ebx
  801c2f:	5e                   	pop    %esi
  801c30:	5d                   	pop    %ebp
  801c31:	c3                   	ret    

00801c32 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c32:	f3 0f 1e fb          	endbr32 
  801c36:	55                   	push   %ebp
  801c37:	89 e5                	mov    %esp,%ebp
  801c39:	53                   	push   %ebx
  801c3a:	83 ec 0c             	sub    $0xc,%esp
  801c3d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c40:	53                   	push   %ebx
  801c41:	6a 00                	push   $0x0
  801c43:	e8 0c f0 ff ff       	call   800c54 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c48:	89 1c 24             	mov    %ebx,(%esp)
  801c4b:	e8 56 f7 ff ff       	call   8013a6 <fd2data>
  801c50:	83 c4 08             	add    $0x8,%esp
  801c53:	50                   	push   %eax
  801c54:	6a 00                	push   $0x0
  801c56:	e8 f9 ef ff ff       	call   800c54 <sys_page_unmap>
}
  801c5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c5e:	c9                   	leave  
  801c5f:	c3                   	ret    

00801c60 <_pipeisclosed>:
{
  801c60:	55                   	push   %ebp
  801c61:	89 e5                	mov    %esp,%ebp
  801c63:	57                   	push   %edi
  801c64:	56                   	push   %esi
  801c65:	53                   	push   %ebx
  801c66:	83 ec 1c             	sub    $0x1c,%esp
  801c69:	89 c7                	mov    %eax,%edi
  801c6b:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801c6d:	a1 08 40 80 00       	mov    0x804008,%eax
  801c72:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801c75:	83 ec 0c             	sub    $0xc,%esp
  801c78:	57                   	push   %edi
  801c79:	e8 2a 05 00 00       	call   8021a8 <pageref>
  801c7e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801c81:	89 34 24             	mov    %esi,(%esp)
  801c84:	e8 1f 05 00 00       	call   8021a8 <pageref>
		nn = thisenv->env_runs;
  801c89:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801c8f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801c92:	83 c4 10             	add    $0x10,%esp
  801c95:	39 cb                	cmp    %ecx,%ebx
  801c97:	74 1b                	je     801cb4 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801c99:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801c9c:	75 cf                	jne    801c6d <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801c9e:	8b 42 58             	mov    0x58(%edx),%eax
  801ca1:	6a 01                	push   $0x1
  801ca3:	50                   	push   %eax
  801ca4:	53                   	push   %ebx
  801ca5:	68 aa 2a 80 00       	push   $0x802aaa
  801caa:	e8 61 e5 ff ff       	call   800210 <cprintf>
  801caf:	83 c4 10             	add    $0x10,%esp
  801cb2:	eb b9                	jmp    801c6d <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801cb4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801cb7:	0f 94 c0             	sete   %al
  801cba:	0f b6 c0             	movzbl %al,%eax
}
  801cbd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cc0:	5b                   	pop    %ebx
  801cc1:	5e                   	pop    %esi
  801cc2:	5f                   	pop    %edi
  801cc3:	5d                   	pop    %ebp
  801cc4:	c3                   	ret    

00801cc5 <devpipe_write>:
{
  801cc5:	f3 0f 1e fb          	endbr32 
  801cc9:	55                   	push   %ebp
  801cca:	89 e5                	mov    %esp,%ebp
  801ccc:	57                   	push   %edi
  801ccd:	56                   	push   %esi
  801cce:	53                   	push   %ebx
  801ccf:	83 ec 28             	sub    $0x28,%esp
  801cd2:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801cd5:	56                   	push   %esi
  801cd6:	e8 cb f6 ff ff       	call   8013a6 <fd2data>
  801cdb:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801cdd:	83 c4 10             	add    $0x10,%esp
  801ce0:	bf 00 00 00 00       	mov    $0x0,%edi
  801ce5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801ce8:	74 4f                	je     801d39 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801cea:	8b 43 04             	mov    0x4(%ebx),%eax
  801ced:	8b 0b                	mov    (%ebx),%ecx
  801cef:	8d 51 20             	lea    0x20(%ecx),%edx
  801cf2:	39 d0                	cmp    %edx,%eax
  801cf4:	72 14                	jb     801d0a <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801cf6:	89 da                	mov    %ebx,%edx
  801cf8:	89 f0                	mov    %esi,%eax
  801cfa:	e8 61 ff ff ff       	call   801c60 <_pipeisclosed>
  801cff:	85 c0                	test   %eax,%eax
  801d01:	75 3b                	jne    801d3e <devpipe_write+0x79>
			sys_yield();
  801d03:	e8 cf ee ff ff       	call   800bd7 <sys_yield>
  801d08:	eb e0                	jmp    801cea <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d0a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d0d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d11:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d14:	89 c2                	mov    %eax,%edx
  801d16:	c1 fa 1f             	sar    $0x1f,%edx
  801d19:	89 d1                	mov    %edx,%ecx
  801d1b:	c1 e9 1b             	shr    $0x1b,%ecx
  801d1e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d21:	83 e2 1f             	and    $0x1f,%edx
  801d24:	29 ca                	sub    %ecx,%edx
  801d26:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d2a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d2e:	83 c0 01             	add    $0x1,%eax
  801d31:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801d34:	83 c7 01             	add    $0x1,%edi
  801d37:	eb ac                	jmp    801ce5 <devpipe_write+0x20>
	return i;
  801d39:	8b 45 10             	mov    0x10(%ebp),%eax
  801d3c:	eb 05                	jmp    801d43 <devpipe_write+0x7e>
				return 0;
  801d3e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d46:	5b                   	pop    %ebx
  801d47:	5e                   	pop    %esi
  801d48:	5f                   	pop    %edi
  801d49:	5d                   	pop    %ebp
  801d4a:	c3                   	ret    

00801d4b <devpipe_read>:
{
  801d4b:	f3 0f 1e fb          	endbr32 
  801d4f:	55                   	push   %ebp
  801d50:	89 e5                	mov    %esp,%ebp
  801d52:	57                   	push   %edi
  801d53:	56                   	push   %esi
  801d54:	53                   	push   %ebx
  801d55:	83 ec 18             	sub    $0x18,%esp
  801d58:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801d5b:	57                   	push   %edi
  801d5c:	e8 45 f6 ff ff       	call   8013a6 <fd2data>
  801d61:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d63:	83 c4 10             	add    $0x10,%esp
  801d66:	be 00 00 00 00       	mov    $0x0,%esi
  801d6b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d6e:	75 14                	jne    801d84 <devpipe_read+0x39>
	return i;
  801d70:	8b 45 10             	mov    0x10(%ebp),%eax
  801d73:	eb 02                	jmp    801d77 <devpipe_read+0x2c>
				return i;
  801d75:	89 f0                	mov    %esi,%eax
}
  801d77:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d7a:	5b                   	pop    %ebx
  801d7b:	5e                   	pop    %esi
  801d7c:	5f                   	pop    %edi
  801d7d:	5d                   	pop    %ebp
  801d7e:	c3                   	ret    
			sys_yield();
  801d7f:	e8 53 ee ff ff       	call   800bd7 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801d84:	8b 03                	mov    (%ebx),%eax
  801d86:	3b 43 04             	cmp    0x4(%ebx),%eax
  801d89:	75 18                	jne    801da3 <devpipe_read+0x58>
			if (i > 0)
  801d8b:	85 f6                	test   %esi,%esi
  801d8d:	75 e6                	jne    801d75 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801d8f:	89 da                	mov    %ebx,%edx
  801d91:	89 f8                	mov    %edi,%eax
  801d93:	e8 c8 fe ff ff       	call   801c60 <_pipeisclosed>
  801d98:	85 c0                	test   %eax,%eax
  801d9a:	74 e3                	je     801d7f <devpipe_read+0x34>
				return 0;
  801d9c:	b8 00 00 00 00       	mov    $0x0,%eax
  801da1:	eb d4                	jmp    801d77 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801da3:	99                   	cltd   
  801da4:	c1 ea 1b             	shr    $0x1b,%edx
  801da7:	01 d0                	add    %edx,%eax
  801da9:	83 e0 1f             	and    $0x1f,%eax
  801dac:	29 d0                	sub    %edx,%eax
  801dae:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801db3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801db6:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801db9:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801dbc:	83 c6 01             	add    $0x1,%esi
  801dbf:	eb aa                	jmp    801d6b <devpipe_read+0x20>

00801dc1 <pipe>:
{
  801dc1:	f3 0f 1e fb          	endbr32 
  801dc5:	55                   	push   %ebp
  801dc6:	89 e5                	mov    %esp,%ebp
  801dc8:	56                   	push   %esi
  801dc9:	53                   	push   %ebx
  801dca:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801dcd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801dd0:	50                   	push   %eax
  801dd1:	e8 ef f5 ff ff       	call   8013c5 <fd_alloc>
  801dd6:	89 c3                	mov    %eax,%ebx
  801dd8:	83 c4 10             	add    $0x10,%esp
  801ddb:	85 c0                	test   %eax,%eax
  801ddd:	0f 88 23 01 00 00    	js     801f06 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801de3:	83 ec 04             	sub    $0x4,%esp
  801de6:	68 07 04 00 00       	push   $0x407
  801deb:	ff 75 f4             	pushl  -0xc(%ebp)
  801dee:	6a 00                	push   $0x0
  801df0:	e8 0d ee ff ff       	call   800c02 <sys_page_alloc>
  801df5:	89 c3                	mov    %eax,%ebx
  801df7:	83 c4 10             	add    $0x10,%esp
  801dfa:	85 c0                	test   %eax,%eax
  801dfc:	0f 88 04 01 00 00    	js     801f06 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801e02:	83 ec 0c             	sub    $0xc,%esp
  801e05:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e08:	50                   	push   %eax
  801e09:	e8 b7 f5 ff ff       	call   8013c5 <fd_alloc>
  801e0e:	89 c3                	mov    %eax,%ebx
  801e10:	83 c4 10             	add    $0x10,%esp
  801e13:	85 c0                	test   %eax,%eax
  801e15:	0f 88 db 00 00 00    	js     801ef6 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e1b:	83 ec 04             	sub    $0x4,%esp
  801e1e:	68 07 04 00 00       	push   $0x407
  801e23:	ff 75 f0             	pushl  -0x10(%ebp)
  801e26:	6a 00                	push   $0x0
  801e28:	e8 d5 ed ff ff       	call   800c02 <sys_page_alloc>
  801e2d:	89 c3                	mov    %eax,%ebx
  801e2f:	83 c4 10             	add    $0x10,%esp
  801e32:	85 c0                	test   %eax,%eax
  801e34:	0f 88 bc 00 00 00    	js     801ef6 <pipe+0x135>
	va = fd2data(fd0);
  801e3a:	83 ec 0c             	sub    $0xc,%esp
  801e3d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e40:	e8 61 f5 ff ff       	call   8013a6 <fd2data>
  801e45:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e47:	83 c4 0c             	add    $0xc,%esp
  801e4a:	68 07 04 00 00       	push   $0x407
  801e4f:	50                   	push   %eax
  801e50:	6a 00                	push   $0x0
  801e52:	e8 ab ed ff ff       	call   800c02 <sys_page_alloc>
  801e57:	89 c3                	mov    %eax,%ebx
  801e59:	83 c4 10             	add    $0x10,%esp
  801e5c:	85 c0                	test   %eax,%eax
  801e5e:	0f 88 82 00 00 00    	js     801ee6 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e64:	83 ec 0c             	sub    $0xc,%esp
  801e67:	ff 75 f0             	pushl  -0x10(%ebp)
  801e6a:	e8 37 f5 ff ff       	call   8013a6 <fd2data>
  801e6f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801e76:	50                   	push   %eax
  801e77:	6a 00                	push   $0x0
  801e79:	56                   	push   %esi
  801e7a:	6a 00                	push   $0x0
  801e7c:	e8 a9 ed ff ff       	call   800c2a <sys_page_map>
  801e81:	89 c3                	mov    %eax,%ebx
  801e83:	83 c4 20             	add    $0x20,%esp
  801e86:	85 c0                	test   %eax,%eax
  801e88:	78 4e                	js     801ed8 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801e8a:	a1 20 30 80 00       	mov    0x803020,%eax
  801e8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e92:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801e94:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e97:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801e9e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ea1:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801ea3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ea6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801ead:	83 ec 0c             	sub    $0xc,%esp
  801eb0:	ff 75 f4             	pushl  -0xc(%ebp)
  801eb3:	e8 da f4 ff ff       	call   801392 <fd2num>
  801eb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ebb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801ebd:	83 c4 04             	add    $0x4,%esp
  801ec0:	ff 75 f0             	pushl  -0x10(%ebp)
  801ec3:	e8 ca f4 ff ff       	call   801392 <fd2num>
  801ec8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801ecb:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801ece:	83 c4 10             	add    $0x10,%esp
  801ed1:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ed6:	eb 2e                	jmp    801f06 <pipe+0x145>
	sys_page_unmap(0, va);
  801ed8:	83 ec 08             	sub    $0x8,%esp
  801edb:	56                   	push   %esi
  801edc:	6a 00                	push   $0x0
  801ede:	e8 71 ed ff ff       	call   800c54 <sys_page_unmap>
  801ee3:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801ee6:	83 ec 08             	sub    $0x8,%esp
  801ee9:	ff 75 f0             	pushl  -0x10(%ebp)
  801eec:	6a 00                	push   $0x0
  801eee:	e8 61 ed ff ff       	call   800c54 <sys_page_unmap>
  801ef3:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801ef6:	83 ec 08             	sub    $0x8,%esp
  801ef9:	ff 75 f4             	pushl  -0xc(%ebp)
  801efc:	6a 00                	push   $0x0
  801efe:	e8 51 ed ff ff       	call   800c54 <sys_page_unmap>
  801f03:	83 c4 10             	add    $0x10,%esp
}
  801f06:	89 d8                	mov    %ebx,%eax
  801f08:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f0b:	5b                   	pop    %ebx
  801f0c:	5e                   	pop    %esi
  801f0d:	5d                   	pop    %ebp
  801f0e:	c3                   	ret    

00801f0f <pipeisclosed>:
{
  801f0f:	f3 0f 1e fb          	endbr32 
  801f13:	55                   	push   %ebp
  801f14:	89 e5                	mov    %esp,%ebp
  801f16:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f19:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f1c:	50                   	push   %eax
  801f1d:	ff 75 08             	pushl  0x8(%ebp)
  801f20:	e8 f6 f4 ff ff       	call   80141b <fd_lookup>
  801f25:	83 c4 10             	add    $0x10,%esp
  801f28:	85 c0                	test   %eax,%eax
  801f2a:	78 18                	js     801f44 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801f2c:	83 ec 0c             	sub    $0xc,%esp
  801f2f:	ff 75 f4             	pushl  -0xc(%ebp)
  801f32:	e8 6f f4 ff ff       	call   8013a6 <fd2data>
  801f37:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801f39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f3c:	e8 1f fd ff ff       	call   801c60 <_pipeisclosed>
  801f41:	83 c4 10             	add    $0x10,%esp
}
  801f44:	c9                   	leave  
  801f45:	c3                   	ret    

00801f46 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f46:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801f4a:	b8 00 00 00 00       	mov    $0x0,%eax
  801f4f:	c3                   	ret    

00801f50 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f50:	f3 0f 1e fb          	endbr32 
  801f54:	55                   	push   %ebp
  801f55:	89 e5                	mov    %esp,%ebp
  801f57:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f5a:	68 c2 2a 80 00       	push   $0x802ac2
  801f5f:	ff 75 0c             	pushl  0xc(%ebp)
  801f62:	e8 13 e8 ff ff       	call   80077a <strcpy>
	return 0;
}
  801f67:	b8 00 00 00 00       	mov    $0x0,%eax
  801f6c:	c9                   	leave  
  801f6d:	c3                   	ret    

00801f6e <devcons_write>:
{
  801f6e:	f3 0f 1e fb          	endbr32 
  801f72:	55                   	push   %ebp
  801f73:	89 e5                	mov    %esp,%ebp
  801f75:	57                   	push   %edi
  801f76:	56                   	push   %esi
  801f77:	53                   	push   %ebx
  801f78:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801f7e:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801f83:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801f89:	3b 75 10             	cmp    0x10(%ebp),%esi
  801f8c:	73 31                	jae    801fbf <devcons_write+0x51>
		m = n - tot;
  801f8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801f91:	29 f3                	sub    %esi,%ebx
  801f93:	83 fb 7f             	cmp    $0x7f,%ebx
  801f96:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801f9b:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801f9e:	83 ec 04             	sub    $0x4,%esp
  801fa1:	53                   	push   %ebx
  801fa2:	89 f0                	mov    %esi,%eax
  801fa4:	03 45 0c             	add    0xc(%ebp),%eax
  801fa7:	50                   	push   %eax
  801fa8:	57                   	push   %edi
  801fa9:	e8 84 e9 ff ff       	call   800932 <memmove>
		sys_cputs(buf, m);
  801fae:	83 c4 08             	add    $0x8,%esp
  801fb1:	53                   	push   %ebx
  801fb2:	57                   	push   %edi
  801fb3:	e8 7f eb ff ff       	call   800b37 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801fb8:	01 de                	add    %ebx,%esi
  801fba:	83 c4 10             	add    $0x10,%esp
  801fbd:	eb ca                	jmp    801f89 <devcons_write+0x1b>
}
  801fbf:	89 f0                	mov    %esi,%eax
  801fc1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fc4:	5b                   	pop    %ebx
  801fc5:	5e                   	pop    %esi
  801fc6:	5f                   	pop    %edi
  801fc7:	5d                   	pop    %ebp
  801fc8:	c3                   	ret    

00801fc9 <devcons_read>:
{
  801fc9:	f3 0f 1e fb          	endbr32 
  801fcd:	55                   	push   %ebp
  801fce:	89 e5                	mov    %esp,%ebp
  801fd0:	83 ec 08             	sub    $0x8,%esp
  801fd3:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801fd8:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801fdc:	74 21                	je     801fff <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801fde:	e8 7e eb ff ff       	call   800b61 <sys_cgetc>
  801fe3:	85 c0                	test   %eax,%eax
  801fe5:	75 07                	jne    801fee <devcons_read+0x25>
		sys_yield();
  801fe7:	e8 eb eb ff ff       	call   800bd7 <sys_yield>
  801fec:	eb f0                	jmp    801fde <devcons_read+0x15>
	if (c < 0)
  801fee:	78 0f                	js     801fff <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801ff0:	83 f8 04             	cmp    $0x4,%eax
  801ff3:	74 0c                	je     802001 <devcons_read+0x38>
	*(char*)vbuf = c;
  801ff5:	8b 55 0c             	mov    0xc(%ebp),%edx
  801ff8:	88 02                	mov    %al,(%edx)
	return 1;
  801ffa:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801fff:	c9                   	leave  
  802000:	c3                   	ret    
		return 0;
  802001:	b8 00 00 00 00       	mov    $0x0,%eax
  802006:	eb f7                	jmp    801fff <devcons_read+0x36>

00802008 <cputchar>:
{
  802008:	f3 0f 1e fb          	endbr32 
  80200c:	55                   	push   %ebp
  80200d:	89 e5                	mov    %esp,%ebp
  80200f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802012:	8b 45 08             	mov    0x8(%ebp),%eax
  802015:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802018:	6a 01                	push   $0x1
  80201a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80201d:	50                   	push   %eax
  80201e:	e8 14 eb ff ff       	call   800b37 <sys_cputs>
}
  802023:	83 c4 10             	add    $0x10,%esp
  802026:	c9                   	leave  
  802027:	c3                   	ret    

00802028 <getchar>:
{
  802028:	f3 0f 1e fb          	endbr32 
  80202c:	55                   	push   %ebp
  80202d:	89 e5                	mov    %esp,%ebp
  80202f:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802032:	6a 01                	push   $0x1
  802034:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802037:	50                   	push   %eax
  802038:	6a 00                	push   $0x0
  80203a:	e8 5f f6 ff ff       	call   80169e <read>
	if (r < 0)
  80203f:	83 c4 10             	add    $0x10,%esp
  802042:	85 c0                	test   %eax,%eax
  802044:	78 06                	js     80204c <getchar+0x24>
	if (r < 1)
  802046:	74 06                	je     80204e <getchar+0x26>
	return c;
  802048:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80204c:	c9                   	leave  
  80204d:	c3                   	ret    
		return -E_EOF;
  80204e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802053:	eb f7                	jmp    80204c <getchar+0x24>

00802055 <iscons>:
{
  802055:	f3 0f 1e fb          	endbr32 
  802059:	55                   	push   %ebp
  80205a:	89 e5                	mov    %esp,%ebp
  80205c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80205f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802062:	50                   	push   %eax
  802063:	ff 75 08             	pushl  0x8(%ebp)
  802066:	e8 b0 f3 ff ff       	call   80141b <fd_lookup>
  80206b:	83 c4 10             	add    $0x10,%esp
  80206e:	85 c0                	test   %eax,%eax
  802070:	78 11                	js     802083 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  802072:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802075:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80207b:	39 10                	cmp    %edx,(%eax)
  80207d:	0f 94 c0             	sete   %al
  802080:	0f b6 c0             	movzbl %al,%eax
}
  802083:	c9                   	leave  
  802084:	c3                   	ret    

00802085 <opencons>:
{
  802085:	f3 0f 1e fb          	endbr32 
  802089:	55                   	push   %ebp
  80208a:	89 e5                	mov    %esp,%ebp
  80208c:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80208f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802092:	50                   	push   %eax
  802093:	e8 2d f3 ff ff       	call   8013c5 <fd_alloc>
  802098:	83 c4 10             	add    $0x10,%esp
  80209b:	85 c0                	test   %eax,%eax
  80209d:	78 3a                	js     8020d9 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80209f:	83 ec 04             	sub    $0x4,%esp
  8020a2:	68 07 04 00 00       	push   $0x407
  8020a7:	ff 75 f4             	pushl  -0xc(%ebp)
  8020aa:	6a 00                	push   $0x0
  8020ac:	e8 51 eb ff ff       	call   800c02 <sys_page_alloc>
  8020b1:	83 c4 10             	add    $0x10,%esp
  8020b4:	85 c0                	test   %eax,%eax
  8020b6:	78 21                	js     8020d9 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8020b8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020bb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020c1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020c3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020c6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020cd:	83 ec 0c             	sub    $0xc,%esp
  8020d0:	50                   	push   %eax
  8020d1:	e8 bc f2 ff ff       	call   801392 <fd2num>
  8020d6:	83 c4 10             	add    $0x10,%esp
}
  8020d9:	c9                   	leave  
  8020da:	c3                   	ret    

008020db <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8020db:	f3 0f 1e fb          	endbr32 
  8020df:	55                   	push   %ebp
  8020e0:	89 e5                	mov    %esp,%ebp
  8020e2:	56                   	push   %esi
  8020e3:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8020e4:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8020e7:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8020ed:	e8 bd ea ff ff       	call   800baf <sys_getenvid>
  8020f2:	83 ec 0c             	sub    $0xc,%esp
  8020f5:	ff 75 0c             	pushl  0xc(%ebp)
  8020f8:	ff 75 08             	pushl  0x8(%ebp)
  8020fb:	56                   	push   %esi
  8020fc:	50                   	push   %eax
  8020fd:	68 d0 2a 80 00       	push   $0x802ad0
  802102:	e8 09 e1 ff ff       	call   800210 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  802107:	83 c4 18             	add    $0x18,%esp
  80210a:	53                   	push   %ebx
  80210b:	ff 75 10             	pushl  0x10(%ebp)
  80210e:	e8 a8 e0 ff ff       	call   8001bb <vcprintf>
	cprintf("\n");
  802113:	c7 04 24 bb 2a 80 00 	movl   $0x802abb,(%esp)
  80211a:	e8 f1 e0 ff ff       	call   800210 <cprintf>
  80211f:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  802122:	cc                   	int3   
  802123:	eb fd                	jmp    802122 <_panic+0x47>

00802125 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802125:	f3 0f 1e fb          	endbr32 
  802129:	55                   	push   %ebp
  80212a:	89 e5                	mov    %esp,%ebp
  80212c:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80212f:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802136:	74 1c                	je     802154 <set_pgfault_handler+0x2f>
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802138:	8b 45 08             	mov    0x8(%ebp),%eax
  80213b:	a3 00 60 80 00       	mov    %eax,0x806000

	//Indicarle al kerne que _pgfault_upcall va a ser el manejador de pgfaults de un proceso
	sys_env_set_pgfault_upcall(0, &(_pgfault_upcall));
  802140:	83 ec 08             	sub    $0x8,%esp
  802143:	68 80 21 80 00       	push   $0x802180
  802148:	6a 00                	push   $0x0
  80214a:	e8 7a eb ff ff       	call   800cc9 <sys_env_set_pgfault_upcall>
}
  80214f:	83 c4 10             	add    $0x10,%esp
  802152:	c9                   	leave  
  802153:	c3                   	ret    
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
  802154:	83 ec 04             	sub    $0x4,%esp
  802157:	6a 02                	push   $0x2
  802159:	68 00 f0 bf ee       	push   $0xeebff000
  80215e:	6a 00                	push   $0x0
  802160:	e8 9d ea ff ff       	call   800c02 <sys_page_alloc>
  802165:	83 c4 10             	add    $0x10,%esp
  802168:	85 c0                	test   %eax,%eax
  80216a:	79 cc                	jns    802138 <set_pgfault_handler+0x13>
  80216c:	83 ec 04             	sub    $0x4,%esp
  80216f:	68 f3 2a 80 00       	push   $0x802af3
  802174:	6a 20                	push   $0x20
  802176:	68 0e 2b 80 00       	push   $0x802b0e
  80217b:	e8 5b ff ff ff       	call   8020db <_panic>

00802180 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802180:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802181:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802186:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802188:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 40(%esp), %eax
  80218b:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	
  80218f:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  802193:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, (%ebx)
  802196:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 48(%esp)
  802198:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  80219c:	83 c4 08             	add    $0x8,%esp
	popal
  80219f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8021a0:	83 c4 04             	add    $0x4,%esp
	popfl
  8021a3:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  8021a4:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8021a7:	c3                   	ret    

008021a8 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8021a8:	f3 0f 1e fb          	endbr32 
  8021ac:	55                   	push   %ebp
  8021ad:	89 e5                	mov    %esp,%ebp
  8021af:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8021b2:	89 c2                	mov    %eax,%edx
  8021b4:	c1 ea 16             	shr    $0x16,%edx
  8021b7:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8021be:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8021c3:	f6 c1 01             	test   $0x1,%cl
  8021c6:	74 1c                	je     8021e4 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8021c8:	c1 e8 0c             	shr    $0xc,%eax
  8021cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8021d2:	a8 01                	test   $0x1,%al
  8021d4:	74 0e                	je     8021e4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021d6:	c1 e8 0c             	shr    $0xc,%eax
  8021d9:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8021e0:	ef 
  8021e1:	0f b7 d2             	movzwl %dx,%edx
}
  8021e4:	89 d0                	mov    %edx,%eax
  8021e6:	5d                   	pop    %ebp
  8021e7:	c3                   	ret    
  8021e8:	66 90                	xchg   %ax,%ax
  8021ea:	66 90                	xchg   %ax,%ax
  8021ec:	66 90                	xchg   %ax,%ax
  8021ee:	66 90                	xchg   %ax,%ax

008021f0 <__udivdi3>:
  8021f0:	f3 0f 1e fb          	endbr32 
  8021f4:	55                   	push   %ebp
  8021f5:	57                   	push   %edi
  8021f6:	56                   	push   %esi
  8021f7:	53                   	push   %ebx
  8021f8:	83 ec 1c             	sub    $0x1c,%esp
  8021fb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021ff:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802203:	8b 74 24 34          	mov    0x34(%esp),%esi
  802207:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80220b:	85 d2                	test   %edx,%edx
  80220d:	75 19                	jne    802228 <__udivdi3+0x38>
  80220f:	39 f3                	cmp    %esi,%ebx
  802211:	76 4d                	jbe    802260 <__udivdi3+0x70>
  802213:	31 ff                	xor    %edi,%edi
  802215:	89 e8                	mov    %ebp,%eax
  802217:	89 f2                	mov    %esi,%edx
  802219:	f7 f3                	div    %ebx
  80221b:	89 fa                	mov    %edi,%edx
  80221d:	83 c4 1c             	add    $0x1c,%esp
  802220:	5b                   	pop    %ebx
  802221:	5e                   	pop    %esi
  802222:	5f                   	pop    %edi
  802223:	5d                   	pop    %ebp
  802224:	c3                   	ret    
  802225:	8d 76 00             	lea    0x0(%esi),%esi
  802228:	39 f2                	cmp    %esi,%edx
  80222a:	76 14                	jbe    802240 <__udivdi3+0x50>
  80222c:	31 ff                	xor    %edi,%edi
  80222e:	31 c0                	xor    %eax,%eax
  802230:	89 fa                	mov    %edi,%edx
  802232:	83 c4 1c             	add    $0x1c,%esp
  802235:	5b                   	pop    %ebx
  802236:	5e                   	pop    %esi
  802237:	5f                   	pop    %edi
  802238:	5d                   	pop    %ebp
  802239:	c3                   	ret    
  80223a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802240:	0f bd fa             	bsr    %edx,%edi
  802243:	83 f7 1f             	xor    $0x1f,%edi
  802246:	75 48                	jne    802290 <__udivdi3+0xa0>
  802248:	39 f2                	cmp    %esi,%edx
  80224a:	72 06                	jb     802252 <__udivdi3+0x62>
  80224c:	31 c0                	xor    %eax,%eax
  80224e:	39 eb                	cmp    %ebp,%ebx
  802250:	77 de                	ja     802230 <__udivdi3+0x40>
  802252:	b8 01 00 00 00       	mov    $0x1,%eax
  802257:	eb d7                	jmp    802230 <__udivdi3+0x40>
  802259:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802260:	89 d9                	mov    %ebx,%ecx
  802262:	85 db                	test   %ebx,%ebx
  802264:	75 0b                	jne    802271 <__udivdi3+0x81>
  802266:	b8 01 00 00 00       	mov    $0x1,%eax
  80226b:	31 d2                	xor    %edx,%edx
  80226d:	f7 f3                	div    %ebx
  80226f:	89 c1                	mov    %eax,%ecx
  802271:	31 d2                	xor    %edx,%edx
  802273:	89 f0                	mov    %esi,%eax
  802275:	f7 f1                	div    %ecx
  802277:	89 c6                	mov    %eax,%esi
  802279:	89 e8                	mov    %ebp,%eax
  80227b:	89 f7                	mov    %esi,%edi
  80227d:	f7 f1                	div    %ecx
  80227f:	89 fa                	mov    %edi,%edx
  802281:	83 c4 1c             	add    $0x1c,%esp
  802284:	5b                   	pop    %ebx
  802285:	5e                   	pop    %esi
  802286:	5f                   	pop    %edi
  802287:	5d                   	pop    %ebp
  802288:	c3                   	ret    
  802289:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802290:	89 f9                	mov    %edi,%ecx
  802292:	b8 20 00 00 00       	mov    $0x20,%eax
  802297:	29 f8                	sub    %edi,%eax
  802299:	d3 e2                	shl    %cl,%edx
  80229b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80229f:	89 c1                	mov    %eax,%ecx
  8022a1:	89 da                	mov    %ebx,%edx
  8022a3:	d3 ea                	shr    %cl,%edx
  8022a5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8022a9:	09 d1                	or     %edx,%ecx
  8022ab:	89 f2                	mov    %esi,%edx
  8022ad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8022b1:	89 f9                	mov    %edi,%ecx
  8022b3:	d3 e3                	shl    %cl,%ebx
  8022b5:	89 c1                	mov    %eax,%ecx
  8022b7:	d3 ea                	shr    %cl,%edx
  8022b9:	89 f9                	mov    %edi,%ecx
  8022bb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8022bf:	89 eb                	mov    %ebp,%ebx
  8022c1:	d3 e6                	shl    %cl,%esi
  8022c3:	89 c1                	mov    %eax,%ecx
  8022c5:	d3 eb                	shr    %cl,%ebx
  8022c7:	09 de                	or     %ebx,%esi
  8022c9:	89 f0                	mov    %esi,%eax
  8022cb:	f7 74 24 08          	divl   0x8(%esp)
  8022cf:	89 d6                	mov    %edx,%esi
  8022d1:	89 c3                	mov    %eax,%ebx
  8022d3:	f7 64 24 0c          	mull   0xc(%esp)
  8022d7:	39 d6                	cmp    %edx,%esi
  8022d9:	72 15                	jb     8022f0 <__udivdi3+0x100>
  8022db:	89 f9                	mov    %edi,%ecx
  8022dd:	d3 e5                	shl    %cl,%ebp
  8022df:	39 c5                	cmp    %eax,%ebp
  8022e1:	73 04                	jae    8022e7 <__udivdi3+0xf7>
  8022e3:	39 d6                	cmp    %edx,%esi
  8022e5:	74 09                	je     8022f0 <__udivdi3+0x100>
  8022e7:	89 d8                	mov    %ebx,%eax
  8022e9:	31 ff                	xor    %edi,%edi
  8022eb:	e9 40 ff ff ff       	jmp    802230 <__udivdi3+0x40>
  8022f0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8022f3:	31 ff                	xor    %edi,%edi
  8022f5:	e9 36 ff ff ff       	jmp    802230 <__udivdi3+0x40>
  8022fa:	66 90                	xchg   %ax,%ax
  8022fc:	66 90                	xchg   %ax,%ax
  8022fe:	66 90                	xchg   %ax,%ax

00802300 <__umoddi3>:
  802300:	f3 0f 1e fb          	endbr32 
  802304:	55                   	push   %ebp
  802305:	57                   	push   %edi
  802306:	56                   	push   %esi
  802307:	53                   	push   %ebx
  802308:	83 ec 1c             	sub    $0x1c,%esp
  80230b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80230f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802313:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802317:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80231b:	85 c0                	test   %eax,%eax
  80231d:	75 19                	jne    802338 <__umoddi3+0x38>
  80231f:	39 df                	cmp    %ebx,%edi
  802321:	76 5d                	jbe    802380 <__umoddi3+0x80>
  802323:	89 f0                	mov    %esi,%eax
  802325:	89 da                	mov    %ebx,%edx
  802327:	f7 f7                	div    %edi
  802329:	89 d0                	mov    %edx,%eax
  80232b:	31 d2                	xor    %edx,%edx
  80232d:	83 c4 1c             	add    $0x1c,%esp
  802330:	5b                   	pop    %ebx
  802331:	5e                   	pop    %esi
  802332:	5f                   	pop    %edi
  802333:	5d                   	pop    %ebp
  802334:	c3                   	ret    
  802335:	8d 76 00             	lea    0x0(%esi),%esi
  802338:	89 f2                	mov    %esi,%edx
  80233a:	39 d8                	cmp    %ebx,%eax
  80233c:	76 12                	jbe    802350 <__umoddi3+0x50>
  80233e:	89 f0                	mov    %esi,%eax
  802340:	89 da                	mov    %ebx,%edx
  802342:	83 c4 1c             	add    $0x1c,%esp
  802345:	5b                   	pop    %ebx
  802346:	5e                   	pop    %esi
  802347:	5f                   	pop    %edi
  802348:	5d                   	pop    %ebp
  802349:	c3                   	ret    
  80234a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802350:	0f bd e8             	bsr    %eax,%ebp
  802353:	83 f5 1f             	xor    $0x1f,%ebp
  802356:	75 50                	jne    8023a8 <__umoddi3+0xa8>
  802358:	39 d8                	cmp    %ebx,%eax
  80235a:	0f 82 e0 00 00 00    	jb     802440 <__umoddi3+0x140>
  802360:	89 d9                	mov    %ebx,%ecx
  802362:	39 f7                	cmp    %esi,%edi
  802364:	0f 86 d6 00 00 00    	jbe    802440 <__umoddi3+0x140>
  80236a:	89 d0                	mov    %edx,%eax
  80236c:	89 ca                	mov    %ecx,%edx
  80236e:	83 c4 1c             	add    $0x1c,%esp
  802371:	5b                   	pop    %ebx
  802372:	5e                   	pop    %esi
  802373:	5f                   	pop    %edi
  802374:	5d                   	pop    %ebp
  802375:	c3                   	ret    
  802376:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80237d:	8d 76 00             	lea    0x0(%esi),%esi
  802380:	89 fd                	mov    %edi,%ebp
  802382:	85 ff                	test   %edi,%edi
  802384:	75 0b                	jne    802391 <__umoddi3+0x91>
  802386:	b8 01 00 00 00       	mov    $0x1,%eax
  80238b:	31 d2                	xor    %edx,%edx
  80238d:	f7 f7                	div    %edi
  80238f:	89 c5                	mov    %eax,%ebp
  802391:	89 d8                	mov    %ebx,%eax
  802393:	31 d2                	xor    %edx,%edx
  802395:	f7 f5                	div    %ebp
  802397:	89 f0                	mov    %esi,%eax
  802399:	f7 f5                	div    %ebp
  80239b:	89 d0                	mov    %edx,%eax
  80239d:	31 d2                	xor    %edx,%edx
  80239f:	eb 8c                	jmp    80232d <__umoddi3+0x2d>
  8023a1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023a8:	89 e9                	mov    %ebp,%ecx
  8023aa:	ba 20 00 00 00       	mov    $0x20,%edx
  8023af:	29 ea                	sub    %ebp,%edx
  8023b1:	d3 e0                	shl    %cl,%eax
  8023b3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8023b7:	89 d1                	mov    %edx,%ecx
  8023b9:	89 f8                	mov    %edi,%eax
  8023bb:	d3 e8                	shr    %cl,%eax
  8023bd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8023c1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8023c5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8023c9:	09 c1                	or     %eax,%ecx
  8023cb:	89 d8                	mov    %ebx,%eax
  8023cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023d1:	89 e9                	mov    %ebp,%ecx
  8023d3:	d3 e7                	shl    %cl,%edi
  8023d5:	89 d1                	mov    %edx,%ecx
  8023d7:	d3 e8                	shr    %cl,%eax
  8023d9:	89 e9                	mov    %ebp,%ecx
  8023db:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8023df:	d3 e3                	shl    %cl,%ebx
  8023e1:	89 c7                	mov    %eax,%edi
  8023e3:	89 d1                	mov    %edx,%ecx
  8023e5:	89 f0                	mov    %esi,%eax
  8023e7:	d3 e8                	shr    %cl,%eax
  8023e9:	89 e9                	mov    %ebp,%ecx
  8023eb:	89 fa                	mov    %edi,%edx
  8023ed:	d3 e6                	shl    %cl,%esi
  8023ef:	09 d8                	or     %ebx,%eax
  8023f1:	f7 74 24 08          	divl   0x8(%esp)
  8023f5:	89 d1                	mov    %edx,%ecx
  8023f7:	89 f3                	mov    %esi,%ebx
  8023f9:	f7 64 24 0c          	mull   0xc(%esp)
  8023fd:	89 c6                	mov    %eax,%esi
  8023ff:	89 d7                	mov    %edx,%edi
  802401:	39 d1                	cmp    %edx,%ecx
  802403:	72 06                	jb     80240b <__umoddi3+0x10b>
  802405:	75 10                	jne    802417 <__umoddi3+0x117>
  802407:	39 c3                	cmp    %eax,%ebx
  802409:	73 0c                	jae    802417 <__umoddi3+0x117>
  80240b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80240f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802413:	89 d7                	mov    %edx,%edi
  802415:	89 c6                	mov    %eax,%esi
  802417:	89 ca                	mov    %ecx,%edx
  802419:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80241e:	29 f3                	sub    %esi,%ebx
  802420:	19 fa                	sbb    %edi,%edx
  802422:	89 d0                	mov    %edx,%eax
  802424:	d3 e0                	shl    %cl,%eax
  802426:	89 e9                	mov    %ebp,%ecx
  802428:	d3 eb                	shr    %cl,%ebx
  80242a:	d3 ea                	shr    %cl,%edx
  80242c:	09 d8                	or     %ebx,%eax
  80242e:	83 c4 1c             	add    $0x1c,%esp
  802431:	5b                   	pop    %ebx
  802432:	5e                   	pop    %esi
  802433:	5f                   	pop    %edi
  802434:	5d                   	pop    %ebp
  802435:	c3                   	ret    
  802436:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80243d:	8d 76 00             	lea    0x0(%esi),%esi
  802440:	29 fe                	sub    %edi,%esi
  802442:	19 c3                	sbb    %eax,%ebx
  802444:	89 f2                	mov    %esi,%edx
  802446:	89 d9                	mov    %ebx,%ecx
  802448:	e9 1d ff ff ff       	jmp    80236a <__umoddi3+0x6a>
