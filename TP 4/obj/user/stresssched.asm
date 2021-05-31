
obj/user/stresssched.debug:     formato del fichero elf32-i386


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
  80002c:	e8 b6 00 00 00       	call   8000e7 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

volatile int counter;

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
	int i, j;
	int seen;
	envid_t parent = sys_getenvid();
  80003c:	e8 98 0b 00 00       	call   800bd9 <sys_getenvid>
  800041:	89 c6                	mov    %eax,%esi

	// Fork several environments
	for (i = 0; i < 20; i++)
  800043:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (fork() == 0)
  800048:	e8 be 10 00 00       	call   80110b <fork>
  80004d:	85 c0                	test   %eax,%eax
  80004f:	74 0f                	je     800060 <umain+0x2d>
	for (i = 0; i < 20; i++)
  800051:	83 c3 01             	add    $0x1,%ebx
  800054:	83 fb 14             	cmp    $0x14,%ebx
  800057:	75 ef                	jne    800048 <umain+0x15>
			break;
	if (i == 20) {
		sys_yield();
  800059:	e8 a3 0b 00 00       	call   800c01 <sys_yield>
		return;
  80005e:	eb 69                	jmp    8000c9 <umain+0x96>
	}

	// Wait for the parent to finish forking
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800060:	89 f0                	mov    %esi,%eax
  800062:	25 ff 03 00 00       	and    $0x3ff,%eax
  800067:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006f:	eb 02                	jmp    800073 <umain+0x40>
		asm volatile("pause");
  800071:	f3 90                	pause  
	while (envs[ENVX(parent)].env_status != ENV_FREE)
  800073:	8b 50 54             	mov    0x54(%eax),%edx
  800076:	85 d2                	test   %edx,%edx
  800078:	75 f7                	jne    800071 <umain+0x3e>
  80007a:	bb 0a 00 00 00       	mov    $0xa,%ebx

	// Check that one environment doesn't run on two CPUs at once
	for (i = 0; i < 10; i++) {
		sys_yield();
  80007f:	e8 7d 0b 00 00       	call   800c01 <sys_yield>
  800084:	ba 10 27 00 00       	mov    $0x2710,%edx
		for (j = 0; j < 10000; j++)
			counter++;
  800089:	a1 04 40 80 00       	mov    0x804004,%eax
  80008e:	83 c0 01             	add    $0x1,%eax
  800091:	a3 04 40 80 00       	mov    %eax,0x804004
		for (j = 0; j < 10000; j++)
  800096:	83 ea 01             	sub    $0x1,%edx
  800099:	75 ee                	jne    800089 <umain+0x56>
	for (i = 0; i < 10; i++) {
  80009b:	83 eb 01             	sub    $0x1,%ebx
  80009e:	75 df                	jne    80007f <umain+0x4c>
	}

	if (counter != 10*10000)
  8000a0:	a1 04 40 80 00       	mov    0x804004,%eax
  8000a5:	3d a0 86 01 00       	cmp    $0x186a0,%eax
  8000aa:	75 24                	jne    8000d0 <umain+0x9d>
		panic("ran on two CPUs at once (counter is %d)", counter);

	// Check that we see environments running on different CPUs
	cprintf("[%08x] stresssched on CPU %d\n", thisenv->env_id, thisenv->env_cpunum);
  8000ac:	a1 08 40 80 00       	mov    0x804008,%eax
  8000b1:	8b 50 5c             	mov    0x5c(%eax),%edx
  8000b4:	8b 40 48             	mov    0x48(%eax),%eax
  8000b7:	83 ec 04             	sub    $0x4,%esp
  8000ba:	52                   	push   %edx
  8000bb:	50                   	push   %eax
  8000bc:	68 7b 24 80 00       	push   $0x80247b
  8000c1:	e8 74 01 00 00       	call   80023a <cprintf>
  8000c6:	83 c4 10             	add    $0x10,%esp

}
  8000c9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cc:	5b                   	pop    %ebx
  8000cd:	5e                   	pop    %esi
  8000ce:	5d                   	pop    %ebp
  8000cf:	c3                   	ret    
		panic("ran on two CPUs at once (counter is %d)", counter);
  8000d0:	a1 04 40 80 00       	mov    0x804004,%eax
  8000d5:	50                   	push   %eax
  8000d6:	68 40 24 80 00       	push   $0x802440
  8000db:	6a 21                	push   $0x21
  8000dd:	68 68 24 80 00       	push   $0x802468
  8000e2:	e8 6c 00 00 00       	call   800153 <_panic>

008000e7 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000e7:	f3 0f 1e fb          	endbr32 
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	56                   	push   %esi
  8000ef:	53                   	push   %ebx
  8000f0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000f3:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8000f6:	e8 de 0a 00 00       	call   800bd9 <sys_getenvid>
	if (id >= 0)
  8000fb:	85 c0                	test   %eax,%eax
  8000fd:	78 12                	js     800111 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8000ff:	25 ff 03 00 00       	and    $0x3ff,%eax
  800104:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800107:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80010c:	a3 08 40 80 00       	mov    %eax,0x804008

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800111:	85 db                	test   %ebx,%ebx
  800113:	7e 07                	jle    80011c <libmain+0x35>
		binaryname = argv[0];
  800115:	8b 06                	mov    (%esi),%eax
  800117:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80011c:	83 ec 08             	sub    $0x8,%esp
  80011f:	56                   	push   %esi
  800120:	53                   	push   %ebx
  800121:	e8 0d ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800126:	e8 0a 00 00 00       	call   800135 <exit>
}
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800131:	5b                   	pop    %ebx
  800132:	5e                   	pop    %esi
  800133:	5d                   	pop    %ebp
  800134:	c3                   	ret    

00800135 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800135:	f3 0f 1e fb          	endbr32 
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80013f:	e8 5b 13 00 00       	call   80149f <close_all>
	sys_env_destroy(0);
  800144:	83 ec 0c             	sub    $0xc,%esp
  800147:	6a 00                	push   $0x0
  800149:	e8 65 0a 00 00       	call   800bb3 <sys_env_destroy>
}
  80014e:	83 c4 10             	add    $0x10,%esp
  800151:	c9                   	leave  
  800152:	c3                   	ret    

00800153 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800153:	f3 0f 1e fb          	endbr32 
  800157:	55                   	push   %ebp
  800158:	89 e5                	mov    %esp,%ebp
  80015a:	56                   	push   %esi
  80015b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80015c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80015f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800165:	e8 6f 0a 00 00       	call   800bd9 <sys_getenvid>
  80016a:	83 ec 0c             	sub    $0xc,%esp
  80016d:	ff 75 0c             	pushl  0xc(%ebp)
  800170:	ff 75 08             	pushl  0x8(%ebp)
  800173:	56                   	push   %esi
  800174:	50                   	push   %eax
  800175:	68 a4 24 80 00       	push   $0x8024a4
  80017a:	e8 bb 00 00 00       	call   80023a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80017f:	83 c4 18             	add    $0x18,%esp
  800182:	53                   	push   %ebx
  800183:	ff 75 10             	pushl  0x10(%ebp)
  800186:	e8 5a 00 00 00       	call   8001e5 <vcprintf>
	cprintf("\n");
  80018b:	c7 04 24 97 24 80 00 	movl   $0x802497,(%esp)
  800192:	e8 a3 00 00 00       	call   80023a <cprintf>
  800197:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80019a:	cc                   	int3   
  80019b:	eb fd                	jmp    80019a <_panic+0x47>

0080019d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80019d:	f3 0f 1e fb          	endbr32 
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	53                   	push   %ebx
  8001a5:	83 ec 04             	sub    $0x4,%esp
  8001a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001ab:	8b 13                	mov    (%ebx),%edx
  8001ad:	8d 42 01             	lea    0x1(%edx),%eax
  8001b0:	89 03                	mov    %eax,(%ebx)
  8001b2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001b5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001b9:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001be:	74 09                	je     8001c9 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001c0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001c7:	c9                   	leave  
  8001c8:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001c9:	83 ec 08             	sub    $0x8,%esp
  8001cc:	68 ff 00 00 00       	push   $0xff
  8001d1:	8d 43 08             	lea    0x8(%ebx),%eax
  8001d4:	50                   	push   %eax
  8001d5:	e8 87 09 00 00       	call   800b61 <sys_cputs>
		b->idx = 0;
  8001da:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001e0:	83 c4 10             	add    $0x10,%esp
  8001e3:	eb db                	jmp    8001c0 <putch+0x23>

008001e5 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001e5:	f3 0f 1e fb          	endbr32 
  8001e9:	55                   	push   %ebp
  8001ea:	89 e5                	mov    %esp,%ebp
  8001ec:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001f2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001f9:	00 00 00 
	b.cnt = 0;
  8001fc:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800203:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800206:	ff 75 0c             	pushl  0xc(%ebp)
  800209:	ff 75 08             	pushl  0x8(%ebp)
  80020c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800212:	50                   	push   %eax
  800213:	68 9d 01 80 00       	push   $0x80019d
  800218:	e8 80 01 00 00       	call   80039d <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80021d:	83 c4 08             	add    $0x8,%esp
  800220:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800226:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80022c:	50                   	push   %eax
  80022d:	e8 2f 09 00 00       	call   800b61 <sys_cputs>

	return b.cnt;
}
  800232:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800238:	c9                   	leave  
  800239:	c3                   	ret    

0080023a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80023a:	f3 0f 1e fb          	endbr32 
  80023e:	55                   	push   %ebp
  80023f:	89 e5                	mov    %esp,%ebp
  800241:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800244:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800247:	50                   	push   %eax
  800248:	ff 75 08             	pushl  0x8(%ebp)
  80024b:	e8 95 ff ff ff       	call   8001e5 <vcprintf>
	va_end(ap);

	return cnt;
}
  800250:	c9                   	leave  
  800251:	c3                   	ret    

00800252 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800252:	55                   	push   %ebp
  800253:	89 e5                	mov    %esp,%ebp
  800255:	57                   	push   %edi
  800256:	56                   	push   %esi
  800257:	53                   	push   %ebx
  800258:	83 ec 1c             	sub    $0x1c,%esp
  80025b:	89 c7                	mov    %eax,%edi
  80025d:	89 d6                	mov    %edx,%esi
  80025f:	8b 45 08             	mov    0x8(%ebp),%eax
  800262:	8b 55 0c             	mov    0xc(%ebp),%edx
  800265:	89 d1                	mov    %edx,%ecx
  800267:	89 c2                	mov    %eax,%edx
  800269:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80026c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80026f:	8b 45 10             	mov    0x10(%ebp),%eax
  800272:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800275:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800278:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80027f:	39 c2                	cmp    %eax,%edx
  800281:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800284:	72 3e                	jb     8002c4 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	ff 75 18             	pushl  0x18(%ebp)
  80028c:	83 eb 01             	sub    $0x1,%ebx
  80028f:	53                   	push   %ebx
  800290:	50                   	push   %eax
  800291:	83 ec 08             	sub    $0x8,%esp
  800294:	ff 75 e4             	pushl  -0x1c(%ebp)
  800297:	ff 75 e0             	pushl  -0x20(%ebp)
  80029a:	ff 75 dc             	pushl  -0x24(%ebp)
  80029d:	ff 75 d8             	pushl  -0x28(%ebp)
  8002a0:	e8 2b 1f 00 00       	call   8021d0 <__udivdi3>
  8002a5:	83 c4 18             	add    $0x18,%esp
  8002a8:	52                   	push   %edx
  8002a9:	50                   	push   %eax
  8002aa:	89 f2                	mov    %esi,%edx
  8002ac:	89 f8                	mov    %edi,%eax
  8002ae:	e8 9f ff ff ff       	call   800252 <printnum>
  8002b3:	83 c4 20             	add    $0x20,%esp
  8002b6:	eb 13                	jmp    8002cb <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002b8:	83 ec 08             	sub    $0x8,%esp
  8002bb:	56                   	push   %esi
  8002bc:	ff 75 18             	pushl  0x18(%ebp)
  8002bf:	ff d7                	call   *%edi
  8002c1:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002c4:	83 eb 01             	sub    $0x1,%ebx
  8002c7:	85 db                	test   %ebx,%ebx
  8002c9:	7f ed                	jg     8002b8 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002cb:	83 ec 08             	sub    $0x8,%esp
  8002ce:	56                   	push   %esi
  8002cf:	83 ec 04             	sub    $0x4,%esp
  8002d2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002d5:	ff 75 e0             	pushl  -0x20(%ebp)
  8002d8:	ff 75 dc             	pushl  -0x24(%ebp)
  8002db:	ff 75 d8             	pushl  -0x28(%ebp)
  8002de:	e8 fd 1f 00 00       	call   8022e0 <__umoddi3>
  8002e3:	83 c4 14             	add    $0x14,%esp
  8002e6:	0f be 80 c7 24 80 00 	movsbl 0x8024c7(%eax),%eax
  8002ed:	50                   	push   %eax
  8002ee:	ff d7                	call   *%edi
}
  8002f0:	83 c4 10             	add    $0x10,%esp
  8002f3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f6:	5b                   	pop    %ebx
  8002f7:	5e                   	pop    %esi
  8002f8:	5f                   	pop    %edi
  8002f9:	5d                   	pop    %ebp
  8002fa:	c3                   	ret    

008002fb <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002fb:	83 fa 01             	cmp    $0x1,%edx
  8002fe:	7f 13                	jg     800313 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800300:	85 d2                	test   %edx,%edx
  800302:	74 1c                	je     800320 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800304:	8b 10                	mov    (%eax),%edx
  800306:	8d 4a 04             	lea    0x4(%edx),%ecx
  800309:	89 08                	mov    %ecx,(%eax)
  80030b:	8b 02                	mov    (%edx),%eax
  80030d:	ba 00 00 00 00       	mov    $0x0,%edx
  800312:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800313:	8b 10                	mov    (%eax),%edx
  800315:	8d 4a 08             	lea    0x8(%edx),%ecx
  800318:	89 08                	mov    %ecx,(%eax)
  80031a:	8b 02                	mov    (%edx),%eax
  80031c:	8b 52 04             	mov    0x4(%edx),%edx
  80031f:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800320:	8b 10                	mov    (%eax),%edx
  800322:	8d 4a 04             	lea    0x4(%edx),%ecx
  800325:	89 08                	mov    %ecx,(%eax)
  800327:	8b 02                	mov    (%edx),%eax
  800329:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80032e:	c3                   	ret    

0080032f <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80032f:	83 fa 01             	cmp    $0x1,%edx
  800332:	7f 0f                	jg     800343 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800334:	85 d2                	test   %edx,%edx
  800336:	74 18                	je     800350 <getint+0x21>
		return va_arg(*ap, long);
  800338:	8b 10                	mov    (%eax),%edx
  80033a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80033d:	89 08                	mov    %ecx,(%eax)
  80033f:	8b 02                	mov    (%edx),%eax
  800341:	99                   	cltd   
  800342:	c3                   	ret    
		return va_arg(*ap, long long);
  800343:	8b 10                	mov    (%eax),%edx
  800345:	8d 4a 08             	lea    0x8(%edx),%ecx
  800348:	89 08                	mov    %ecx,(%eax)
  80034a:	8b 02                	mov    (%edx),%eax
  80034c:	8b 52 04             	mov    0x4(%edx),%edx
  80034f:	c3                   	ret    
	else
		return va_arg(*ap, int);
  800350:	8b 10                	mov    (%eax),%edx
  800352:	8d 4a 04             	lea    0x4(%edx),%ecx
  800355:	89 08                	mov    %ecx,(%eax)
  800357:	8b 02                	mov    (%edx),%eax
  800359:	99                   	cltd   
}
  80035a:	c3                   	ret    

0080035b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80035b:	f3 0f 1e fb          	endbr32 
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
  800362:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800365:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800369:	8b 10                	mov    (%eax),%edx
  80036b:	3b 50 04             	cmp    0x4(%eax),%edx
  80036e:	73 0a                	jae    80037a <sprintputch+0x1f>
		*b->buf++ = ch;
  800370:	8d 4a 01             	lea    0x1(%edx),%ecx
  800373:	89 08                	mov    %ecx,(%eax)
  800375:	8b 45 08             	mov    0x8(%ebp),%eax
  800378:	88 02                	mov    %al,(%edx)
}
  80037a:	5d                   	pop    %ebp
  80037b:	c3                   	ret    

0080037c <printfmt>:
{
  80037c:	f3 0f 1e fb          	endbr32 
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800386:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800389:	50                   	push   %eax
  80038a:	ff 75 10             	pushl  0x10(%ebp)
  80038d:	ff 75 0c             	pushl  0xc(%ebp)
  800390:	ff 75 08             	pushl  0x8(%ebp)
  800393:	e8 05 00 00 00       	call   80039d <vprintfmt>
}
  800398:	83 c4 10             	add    $0x10,%esp
  80039b:	c9                   	leave  
  80039c:	c3                   	ret    

0080039d <vprintfmt>:
{
  80039d:	f3 0f 1e fb          	endbr32 
  8003a1:	55                   	push   %ebp
  8003a2:	89 e5                	mov    %esp,%ebp
  8003a4:	57                   	push   %edi
  8003a5:	56                   	push   %esi
  8003a6:	53                   	push   %ebx
  8003a7:	83 ec 2c             	sub    $0x2c,%esp
  8003aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003ad:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003b0:	8b 7d 10             	mov    0x10(%ebp),%edi
  8003b3:	e9 86 02 00 00       	jmp    80063e <vprintfmt+0x2a1>
		padc = ' ';
  8003b8:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8003bc:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003c3:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003ca:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003d1:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003d6:	8d 47 01             	lea    0x1(%edi),%eax
  8003d9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003dc:	0f b6 17             	movzbl (%edi),%edx
  8003df:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003e2:	3c 55                	cmp    $0x55,%al
  8003e4:	0f 87 df 02 00 00    	ja     8006c9 <vprintfmt+0x32c>
  8003ea:	0f b6 c0             	movzbl %al,%eax
  8003ed:	3e ff 24 85 00 26 80 	notrack jmp *0x802600(,%eax,4)
  8003f4:	00 
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003f8:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003fc:	eb d8                	jmp    8003d6 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003fe:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800401:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800405:	eb cf                	jmp    8003d6 <vprintfmt+0x39>
  800407:	0f b6 d2             	movzbl %dl,%edx
  80040a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80040d:	b8 00 00 00 00       	mov    $0x0,%eax
  800412:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800415:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800418:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80041c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80041f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800422:	83 f9 09             	cmp    $0x9,%ecx
  800425:	77 52                	ja     800479 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  800427:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80042a:	eb e9                	jmp    800415 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80042c:	8b 45 14             	mov    0x14(%ebp),%eax
  80042f:	8d 50 04             	lea    0x4(%eax),%edx
  800432:	89 55 14             	mov    %edx,0x14(%ebp)
  800435:	8b 00                	mov    (%eax),%eax
  800437:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80043a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80043d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800441:	79 93                	jns    8003d6 <vprintfmt+0x39>
				width = precision, precision = -1;
  800443:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800446:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800449:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800450:	eb 84                	jmp    8003d6 <vprintfmt+0x39>
  800452:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800455:	85 c0                	test   %eax,%eax
  800457:	ba 00 00 00 00       	mov    $0x0,%edx
  80045c:	0f 49 d0             	cmovns %eax,%edx
  80045f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800462:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800465:	e9 6c ff ff ff       	jmp    8003d6 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80046a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80046d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800474:	e9 5d ff ff ff       	jmp    8003d6 <vprintfmt+0x39>
  800479:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80047c:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80047f:	eb bc                	jmp    80043d <vprintfmt+0xa0>
			lflag++;
  800481:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800484:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800487:	e9 4a ff ff ff       	jmp    8003d6 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80048c:	8b 45 14             	mov    0x14(%ebp),%eax
  80048f:	8d 50 04             	lea    0x4(%eax),%edx
  800492:	89 55 14             	mov    %edx,0x14(%ebp)
  800495:	83 ec 08             	sub    $0x8,%esp
  800498:	56                   	push   %esi
  800499:	ff 30                	pushl  (%eax)
  80049b:	ff d3                	call   *%ebx
			break;
  80049d:	83 c4 10             	add    $0x10,%esp
  8004a0:	e9 96 01 00 00       	jmp    80063b <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8004a5:	8b 45 14             	mov    0x14(%ebp),%eax
  8004a8:	8d 50 04             	lea    0x4(%eax),%edx
  8004ab:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ae:	8b 00                	mov    (%eax),%eax
  8004b0:	99                   	cltd   
  8004b1:	31 d0                	xor    %edx,%eax
  8004b3:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004b5:	83 f8 0f             	cmp    $0xf,%eax
  8004b8:	7f 20                	jg     8004da <vprintfmt+0x13d>
  8004ba:	8b 14 85 60 27 80 00 	mov    0x802760(,%eax,4),%edx
  8004c1:	85 d2                	test   %edx,%edx
  8004c3:	74 15                	je     8004da <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8004c5:	52                   	push   %edx
  8004c6:	68 75 2a 80 00       	push   $0x802a75
  8004cb:	56                   	push   %esi
  8004cc:	53                   	push   %ebx
  8004cd:	e8 aa fe ff ff       	call   80037c <printfmt>
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	e9 61 01 00 00       	jmp    80063b <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8004da:	50                   	push   %eax
  8004db:	68 df 24 80 00       	push   $0x8024df
  8004e0:	56                   	push   %esi
  8004e1:	53                   	push   %ebx
  8004e2:	e8 95 fe ff ff       	call   80037c <printfmt>
  8004e7:	83 c4 10             	add    $0x10,%esp
  8004ea:	e9 4c 01 00 00       	jmp    80063b <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004ef:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f2:	8d 50 04             	lea    0x4(%eax),%edx
  8004f5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004f8:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8004fa:	85 c9                	test   %ecx,%ecx
  8004fc:	b8 d8 24 80 00       	mov    $0x8024d8,%eax
  800501:	0f 45 c1             	cmovne %ecx,%eax
  800504:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800507:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80050b:	7e 06                	jle    800513 <vprintfmt+0x176>
  80050d:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800511:	75 0d                	jne    800520 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  800513:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800516:	89 c7                	mov    %eax,%edi
  800518:	03 45 e0             	add    -0x20(%ebp),%eax
  80051b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80051e:	eb 57                	jmp    800577 <vprintfmt+0x1da>
  800520:	83 ec 08             	sub    $0x8,%esp
  800523:	ff 75 d8             	pushl  -0x28(%ebp)
  800526:	ff 75 cc             	pushl  -0x34(%ebp)
  800529:	e8 4f 02 00 00       	call   80077d <strnlen>
  80052e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800531:	29 c2                	sub    %eax,%edx
  800533:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800536:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800539:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80053d:	89 5d 08             	mov    %ebx,0x8(%ebp)
  800540:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800542:	85 db                	test   %ebx,%ebx
  800544:	7e 10                	jle    800556 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800546:	83 ec 08             	sub    $0x8,%esp
  800549:	56                   	push   %esi
  80054a:	57                   	push   %edi
  80054b:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80054e:	83 eb 01             	sub    $0x1,%ebx
  800551:	83 c4 10             	add    $0x10,%esp
  800554:	eb ec                	jmp    800542 <vprintfmt+0x1a5>
  800556:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800559:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80055c:	85 d2                	test   %edx,%edx
  80055e:	b8 00 00 00 00       	mov    $0x0,%eax
  800563:	0f 49 c2             	cmovns %edx,%eax
  800566:	29 c2                	sub    %eax,%edx
  800568:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80056b:	eb a6                	jmp    800513 <vprintfmt+0x176>
					putch(ch, putdat);
  80056d:	83 ec 08             	sub    $0x8,%esp
  800570:	56                   	push   %esi
  800571:	52                   	push   %edx
  800572:	ff d3                	call   *%ebx
  800574:	83 c4 10             	add    $0x10,%esp
  800577:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80057a:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80057c:	83 c7 01             	add    $0x1,%edi
  80057f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800583:	0f be d0             	movsbl %al,%edx
  800586:	85 d2                	test   %edx,%edx
  800588:	74 42                	je     8005cc <vprintfmt+0x22f>
  80058a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80058e:	78 06                	js     800596 <vprintfmt+0x1f9>
  800590:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800594:	78 1e                	js     8005b4 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  800596:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80059a:	74 d1                	je     80056d <vprintfmt+0x1d0>
  80059c:	0f be c0             	movsbl %al,%eax
  80059f:	83 e8 20             	sub    $0x20,%eax
  8005a2:	83 f8 5e             	cmp    $0x5e,%eax
  8005a5:	76 c6                	jbe    80056d <vprintfmt+0x1d0>
					putch('?', putdat);
  8005a7:	83 ec 08             	sub    $0x8,%esp
  8005aa:	56                   	push   %esi
  8005ab:	6a 3f                	push   $0x3f
  8005ad:	ff d3                	call   *%ebx
  8005af:	83 c4 10             	add    $0x10,%esp
  8005b2:	eb c3                	jmp    800577 <vprintfmt+0x1da>
  8005b4:	89 cf                	mov    %ecx,%edi
  8005b6:	eb 0e                	jmp    8005c6 <vprintfmt+0x229>
				putch(' ', putdat);
  8005b8:	83 ec 08             	sub    $0x8,%esp
  8005bb:	56                   	push   %esi
  8005bc:	6a 20                	push   $0x20
  8005be:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8005c0:	83 ef 01             	sub    $0x1,%edi
  8005c3:	83 c4 10             	add    $0x10,%esp
  8005c6:	85 ff                	test   %edi,%edi
  8005c8:	7f ee                	jg     8005b8 <vprintfmt+0x21b>
  8005ca:	eb 6f                	jmp    80063b <vprintfmt+0x29e>
  8005cc:	89 cf                	mov    %ecx,%edi
  8005ce:	eb f6                	jmp    8005c6 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8005d0:	89 ca                	mov    %ecx,%edx
  8005d2:	8d 45 14             	lea    0x14(%ebp),%eax
  8005d5:	e8 55 fd ff ff       	call   80032f <getint>
  8005da:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005dd:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8005e0:	85 d2                	test   %edx,%edx
  8005e2:	78 0b                	js     8005ef <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8005e4:	89 d1                	mov    %edx,%ecx
  8005e6:	89 c2                	mov    %eax,%edx
			base = 10;
  8005e8:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005ed:	eb 32                	jmp    800621 <vprintfmt+0x284>
				putch('-', putdat);
  8005ef:	83 ec 08             	sub    $0x8,%esp
  8005f2:	56                   	push   %esi
  8005f3:	6a 2d                	push   $0x2d
  8005f5:	ff d3                	call   *%ebx
				num = -(long long) num;
  8005f7:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005fa:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005fd:	f7 da                	neg    %edx
  8005ff:	83 d1 00             	adc    $0x0,%ecx
  800602:	f7 d9                	neg    %ecx
  800604:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800607:	b8 0a 00 00 00       	mov    $0xa,%eax
  80060c:	eb 13                	jmp    800621 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  80060e:	89 ca                	mov    %ecx,%edx
  800610:	8d 45 14             	lea    0x14(%ebp),%eax
  800613:	e8 e3 fc ff ff       	call   8002fb <getuint>
  800618:	89 d1                	mov    %edx,%ecx
  80061a:	89 c2                	mov    %eax,%edx
			base = 10;
  80061c:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  800621:	83 ec 0c             	sub    $0xc,%esp
  800624:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800628:	57                   	push   %edi
  800629:	ff 75 e0             	pushl  -0x20(%ebp)
  80062c:	50                   	push   %eax
  80062d:	51                   	push   %ecx
  80062e:	52                   	push   %edx
  80062f:	89 f2                	mov    %esi,%edx
  800631:	89 d8                	mov    %ebx,%eax
  800633:	e8 1a fc ff ff       	call   800252 <printnum>
			break;
  800638:	83 c4 20             	add    $0x20,%esp
{
  80063b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80063e:	83 c7 01             	add    $0x1,%edi
  800641:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800645:	83 f8 25             	cmp    $0x25,%eax
  800648:	0f 84 6a fd ff ff    	je     8003b8 <vprintfmt+0x1b>
			if (ch == '\0')
  80064e:	85 c0                	test   %eax,%eax
  800650:	0f 84 93 00 00 00    	je     8006e9 <vprintfmt+0x34c>
			putch(ch, putdat);
  800656:	83 ec 08             	sub    $0x8,%esp
  800659:	56                   	push   %esi
  80065a:	50                   	push   %eax
  80065b:	ff d3                	call   *%ebx
  80065d:	83 c4 10             	add    $0x10,%esp
  800660:	eb dc                	jmp    80063e <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  800662:	89 ca                	mov    %ecx,%edx
  800664:	8d 45 14             	lea    0x14(%ebp),%eax
  800667:	e8 8f fc ff ff       	call   8002fb <getuint>
  80066c:	89 d1                	mov    %edx,%ecx
  80066e:	89 c2                	mov    %eax,%edx
			base = 8;
  800670:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800675:	eb aa                	jmp    800621 <vprintfmt+0x284>
			putch('0', putdat);
  800677:	83 ec 08             	sub    $0x8,%esp
  80067a:	56                   	push   %esi
  80067b:	6a 30                	push   $0x30
  80067d:	ff d3                	call   *%ebx
			putch('x', putdat);
  80067f:	83 c4 08             	add    $0x8,%esp
  800682:	56                   	push   %esi
  800683:	6a 78                	push   $0x78
  800685:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  800687:	8b 45 14             	mov    0x14(%ebp),%eax
  80068a:	8d 50 04             	lea    0x4(%eax),%edx
  80068d:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800690:	8b 10                	mov    (%eax),%edx
  800692:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800697:	83 c4 10             	add    $0x10,%esp
			base = 16;
  80069a:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80069f:	eb 80                	jmp    800621 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8006a1:	89 ca                	mov    %ecx,%edx
  8006a3:	8d 45 14             	lea    0x14(%ebp),%eax
  8006a6:	e8 50 fc ff ff       	call   8002fb <getuint>
  8006ab:	89 d1                	mov    %edx,%ecx
  8006ad:	89 c2                	mov    %eax,%edx
			base = 16;
  8006af:	b8 10 00 00 00       	mov    $0x10,%eax
  8006b4:	e9 68 ff ff ff       	jmp    800621 <vprintfmt+0x284>
			putch(ch, putdat);
  8006b9:	83 ec 08             	sub    $0x8,%esp
  8006bc:	56                   	push   %esi
  8006bd:	6a 25                	push   $0x25
  8006bf:	ff d3                	call   *%ebx
			break;
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	e9 72 ff ff ff       	jmp    80063b <vprintfmt+0x29e>
			putch('%', putdat);
  8006c9:	83 ec 08             	sub    $0x8,%esp
  8006cc:	56                   	push   %esi
  8006cd:	6a 25                	push   $0x25
  8006cf:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006d1:	83 c4 10             	add    $0x10,%esp
  8006d4:	89 f8                	mov    %edi,%eax
  8006d6:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006da:	74 05                	je     8006e1 <vprintfmt+0x344>
  8006dc:	83 e8 01             	sub    $0x1,%eax
  8006df:	eb f5                	jmp    8006d6 <vprintfmt+0x339>
  8006e1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006e4:	e9 52 ff ff ff       	jmp    80063b <vprintfmt+0x29e>
}
  8006e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ec:	5b                   	pop    %ebx
  8006ed:	5e                   	pop    %esi
  8006ee:	5f                   	pop    %edi
  8006ef:	5d                   	pop    %ebp
  8006f0:	c3                   	ret    

008006f1 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006f1:	f3 0f 1e fb          	endbr32 
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	83 ec 18             	sub    $0x18,%esp
  8006fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8006fe:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800701:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800704:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800708:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80070b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800712:	85 c0                	test   %eax,%eax
  800714:	74 26                	je     80073c <vsnprintf+0x4b>
  800716:	85 d2                	test   %edx,%edx
  800718:	7e 22                	jle    80073c <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80071a:	ff 75 14             	pushl  0x14(%ebp)
  80071d:	ff 75 10             	pushl  0x10(%ebp)
  800720:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800723:	50                   	push   %eax
  800724:	68 5b 03 80 00       	push   $0x80035b
  800729:	e8 6f fc ff ff       	call   80039d <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80072e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800731:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800734:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800737:	83 c4 10             	add    $0x10,%esp
}
  80073a:	c9                   	leave  
  80073b:	c3                   	ret    
		return -E_INVAL;
  80073c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800741:	eb f7                	jmp    80073a <vsnprintf+0x49>

00800743 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800743:	f3 0f 1e fb          	endbr32 
  800747:	55                   	push   %ebp
  800748:	89 e5                	mov    %esp,%ebp
  80074a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80074d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800750:	50                   	push   %eax
  800751:	ff 75 10             	pushl  0x10(%ebp)
  800754:	ff 75 0c             	pushl  0xc(%ebp)
  800757:	ff 75 08             	pushl  0x8(%ebp)
  80075a:	e8 92 ff ff ff       	call   8006f1 <vsnprintf>
	va_end(ap);

	return rc;
}
  80075f:	c9                   	leave  
  800760:	c3                   	ret    

00800761 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800761:	f3 0f 1e fb          	endbr32 
  800765:	55                   	push   %ebp
  800766:	89 e5                	mov    %esp,%ebp
  800768:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80076b:	b8 00 00 00 00       	mov    $0x0,%eax
  800770:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800774:	74 05                	je     80077b <strlen+0x1a>
		n++;
  800776:	83 c0 01             	add    $0x1,%eax
  800779:	eb f5                	jmp    800770 <strlen+0xf>
	return n;
}
  80077b:	5d                   	pop    %ebp
  80077c:	c3                   	ret    

0080077d <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80077d:	f3 0f 1e fb          	endbr32 
  800781:	55                   	push   %ebp
  800782:	89 e5                	mov    %esp,%ebp
  800784:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800787:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80078a:	b8 00 00 00 00       	mov    $0x0,%eax
  80078f:	39 d0                	cmp    %edx,%eax
  800791:	74 0d                	je     8007a0 <strnlen+0x23>
  800793:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800797:	74 05                	je     80079e <strnlen+0x21>
		n++;
  800799:	83 c0 01             	add    $0x1,%eax
  80079c:	eb f1                	jmp    80078f <strnlen+0x12>
  80079e:	89 c2                	mov    %eax,%edx
	return n;
}
  8007a0:	89 d0                	mov    %edx,%eax
  8007a2:	5d                   	pop    %ebp
  8007a3:	c3                   	ret    

008007a4 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007a4:	f3 0f 1e fb          	endbr32 
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	53                   	push   %ebx
  8007ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007af:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8007b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8007b7:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007bb:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007be:	83 c0 01             	add    $0x1,%eax
  8007c1:	84 d2                	test   %dl,%dl
  8007c3:	75 f2                	jne    8007b7 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007c5:	89 c8                	mov    %ecx,%eax
  8007c7:	5b                   	pop    %ebx
  8007c8:	5d                   	pop    %ebp
  8007c9:	c3                   	ret    

008007ca <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007ca:	f3 0f 1e fb          	endbr32 
  8007ce:	55                   	push   %ebp
  8007cf:	89 e5                	mov    %esp,%ebp
  8007d1:	53                   	push   %ebx
  8007d2:	83 ec 10             	sub    $0x10,%esp
  8007d5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007d8:	53                   	push   %ebx
  8007d9:	e8 83 ff ff ff       	call   800761 <strlen>
  8007de:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007e1:	ff 75 0c             	pushl  0xc(%ebp)
  8007e4:	01 d8                	add    %ebx,%eax
  8007e6:	50                   	push   %eax
  8007e7:	e8 b8 ff ff ff       	call   8007a4 <strcpy>
	return dst;
}
  8007ec:	89 d8                	mov    %ebx,%eax
  8007ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f1:	c9                   	leave  
  8007f2:	c3                   	ret    

008007f3 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007f3:	f3 0f 1e fb          	endbr32 
  8007f7:	55                   	push   %ebp
  8007f8:	89 e5                	mov    %esp,%ebp
  8007fa:	56                   	push   %esi
  8007fb:	53                   	push   %ebx
  8007fc:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800802:	89 f3                	mov    %esi,%ebx
  800804:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800807:	89 f0                	mov    %esi,%eax
  800809:	39 d8                	cmp    %ebx,%eax
  80080b:	74 11                	je     80081e <strncpy+0x2b>
		*dst++ = *src;
  80080d:	83 c0 01             	add    $0x1,%eax
  800810:	0f b6 0a             	movzbl (%edx),%ecx
  800813:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800816:	80 f9 01             	cmp    $0x1,%cl
  800819:	83 da ff             	sbb    $0xffffffff,%edx
  80081c:	eb eb                	jmp    800809 <strncpy+0x16>
	}
	return ret;
}
  80081e:	89 f0                	mov    %esi,%eax
  800820:	5b                   	pop    %ebx
  800821:	5e                   	pop    %esi
  800822:	5d                   	pop    %ebp
  800823:	c3                   	ret    

00800824 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800824:	f3 0f 1e fb          	endbr32 
  800828:	55                   	push   %ebp
  800829:	89 e5                	mov    %esp,%ebp
  80082b:	56                   	push   %esi
  80082c:	53                   	push   %ebx
  80082d:	8b 75 08             	mov    0x8(%ebp),%esi
  800830:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800833:	8b 55 10             	mov    0x10(%ebp),%edx
  800836:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800838:	85 d2                	test   %edx,%edx
  80083a:	74 21                	je     80085d <strlcpy+0x39>
  80083c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800840:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800842:	39 c2                	cmp    %eax,%edx
  800844:	74 14                	je     80085a <strlcpy+0x36>
  800846:	0f b6 19             	movzbl (%ecx),%ebx
  800849:	84 db                	test   %bl,%bl
  80084b:	74 0b                	je     800858 <strlcpy+0x34>
			*dst++ = *src++;
  80084d:	83 c1 01             	add    $0x1,%ecx
  800850:	83 c2 01             	add    $0x1,%edx
  800853:	88 5a ff             	mov    %bl,-0x1(%edx)
  800856:	eb ea                	jmp    800842 <strlcpy+0x1e>
  800858:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80085a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80085d:	29 f0                	sub    %esi,%eax
}
  80085f:	5b                   	pop    %ebx
  800860:	5e                   	pop    %esi
  800861:	5d                   	pop    %ebp
  800862:	c3                   	ret    

00800863 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800863:	f3 0f 1e fb          	endbr32 
  800867:	55                   	push   %ebp
  800868:	89 e5                	mov    %esp,%ebp
  80086a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80086d:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800870:	0f b6 01             	movzbl (%ecx),%eax
  800873:	84 c0                	test   %al,%al
  800875:	74 0c                	je     800883 <strcmp+0x20>
  800877:	3a 02                	cmp    (%edx),%al
  800879:	75 08                	jne    800883 <strcmp+0x20>
		p++, q++;
  80087b:	83 c1 01             	add    $0x1,%ecx
  80087e:	83 c2 01             	add    $0x1,%edx
  800881:	eb ed                	jmp    800870 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800883:	0f b6 c0             	movzbl %al,%eax
  800886:	0f b6 12             	movzbl (%edx),%edx
  800889:	29 d0                	sub    %edx,%eax
}
  80088b:	5d                   	pop    %ebp
  80088c:	c3                   	ret    

0080088d <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80088d:	f3 0f 1e fb          	endbr32 
  800891:	55                   	push   %ebp
  800892:	89 e5                	mov    %esp,%ebp
  800894:	53                   	push   %ebx
  800895:	8b 45 08             	mov    0x8(%ebp),%eax
  800898:	8b 55 0c             	mov    0xc(%ebp),%edx
  80089b:	89 c3                	mov    %eax,%ebx
  80089d:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008a0:	eb 06                	jmp    8008a8 <strncmp+0x1b>
		n--, p++, q++;
  8008a2:	83 c0 01             	add    $0x1,%eax
  8008a5:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008a8:	39 d8                	cmp    %ebx,%eax
  8008aa:	74 16                	je     8008c2 <strncmp+0x35>
  8008ac:	0f b6 08             	movzbl (%eax),%ecx
  8008af:	84 c9                	test   %cl,%cl
  8008b1:	74 04                	je     8008b7 <strncmp+0x2a>
  8008b3:	3a 0a                	cmp    (%edx),%cl
  8008b5:	74 eb                	je     8008a2 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008b7:	0f b6 00             	movzbl (%eax),%eax
  8008ba:	0f b6 12             	movzbl (%edx),%edx
  8008bd:	29 d0                	sub    %edx,%eax
}
  8008bf:	5b                   	pop    %ebx
  8008c0:	5d                   	pop    %ebp
  8008c1:	c3                   	ret    
		return 0;
  8008c2:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c7:	eb f6                	jmp    8008bf <strncmp+0x32>

008008c9 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008c9:	f3 0f 1e fb          	endbr32 
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008d3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008d7:	0f b6 10             	movzbl (%eax),%edx
  8008da:	84 d2                	test   %dl,%dl
  8008dc:	74 09                	je     8008e7 <strchr+0x1e>
		if (*s == c)
  8008de:	38 ca                	cmp    %cl,%dl
  8008e0:	74 0a                	je     8008ec <strchr+0x23>
	for (; *s; s++)
  8008e2:	83 c0 01             	add    $0x1,%eax
  8008e5:	eb f0                	jmp    8008d7 <strchr+0xe>
			return (char *) s;
	return 0;
  8008e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008ec:	5d                   	pop    %ebp
  8008ed:	c3                   	ret    

008008ee <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008ee:	f3 0f 1e fb          	endbr32 
  8008f2:	55                   	push   %ebp
  8008f3:	89 e5                	mov    %esp,%ebp
  8008f5:	8b 45 08             	mov    0x8(%ebp),%eax
  8008f8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008fc:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ff:	38 ca                	cmp    %cl,%dl
  800901:	74 09                	je     80090c <strfind+0x1e>
  800903:	84 d2                	test   %dl,%dl
  800905:	74 05                	je     80090c <strfind+0x1e>
	for (; *s; s++)
  800907:	83 c0 01             	add    $0x1,%eax
  80090a:	eb f0                	jmp    8008fc <strfind+0xe>
			break;
	return (char *) s;
}
  80090c:	5d                   	pop    %ebp
  80090d:	c3                   	ret    

0080090e <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80090e:	f3 0f 1e fb          	endbr32 
  800912:	55                   	push   %ebp
  800913:	89 e5                	mov    %esp,%ebp
  800915:	57                   	push   %edi
  800916:	56                   	push   %esi
  800917:	53                   	push   %ebx
  800918:	8b 55 08             	mov    0x8(%ebp),%edx
  80091b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  80091e:	85 c9                	test   %ecx,%ecx
  800920:	74 33                	je     800955 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800922:	89 d0                	mov    %edx,%eax
  800924:	09 c8                	or     %ecx,%eax
  800926:	a8 03                	test   $0x3,%al
  800928:	75 23                	jne    80094d <memset+0x3f>
		c &= 0xFF;
  80092a:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80092e:	89 d8                	mov    %ebx,%eax
  800930:	c1 e0 08             	shl    $0x8,%eax
  800933:	89 df                	mov    %ebx,%edi
  800935:	c1 e7 18             	shl    $0x18,%edi
  800938:	89 de                	mov    %ebx,%esi
  80093a:	c1 e6 10             	shl    $0x10,%esi
  80093d:	09 f7                	or     %esi,%edi
  80093f:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800941:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800944:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800946:	89 d7                	mov    %edx,%edi
  800948:	fc                   	cld    
  800949:	f3 ab                	rep stos %eax,%es:(%edi)
  80094b:	eb 08                	jmp    800955 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80094d:	89 d7                	mov    %edx,%edi
  80094f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800952:	fc                   	cld    
  800953:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800955:	89 d0                	mov    %edx,%eax
  800957:	5b                   	pop    %ebx
  800958:	5e                   	pop    %esi
  800959:	5f                   	pop    %edi
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80095c:	f3 0f 1e fb          	endbr32 
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	57                   	push   %edi
  800964:	56                   	push   %esi
  800965:	8b 45 08             	mov    0x8(%ebp),%eax
  800968:	8b 75 0c             	mov    0xc(%ebp),%esi
  80096b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80096e:	39 c6                	cmp    %eax,%esi
  800970:	73 32                	jae    8009a4 <memmove+0x48>
  800972:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800975:	39 c2                	cmp    %eax,%edx
  800977:	76 2b                	jbe    8009a4 <memmove+0x48>
		s += n;
		d += n;
  800979:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80097c:	89 fe                	mov    %edi,%esi
  80097e:	09 ce                	or     %ecx,%esi
  800980:	09 d6                	or     %edx,%esi
  800982:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800988:	75 0e                	jne    800998 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80098a:	83 ef 04             	sub    $0x4,%edi
  80098d:	8d 72 fc             	lea    -0x4(%edx),%esi
  800990:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800993:	fd                   	std    
  800994:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800996:	eb 09                	jmp    8009a1 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800998:	83 ef 01             	sub    $0x1,%edi
  80099b:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80099e:	fd                   	std    
  80099f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009a1:	fc                   	cld    
  8009a2:	eb 1a                	jmp    8009be <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009a4:	89 c2                	mov    %eax,%edx
  8009a6:	09 ca                	or     %ecx,%edx
  8009a8:	09 f2                	or     %esi,%edx
  8009aa:	f6 c2 03             	test   $0x3,%dl
  8009ad:	75 0a                	jne    8009b9 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009af:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8009b2:	89 c7                	mov    %eax,%edi
  8009b4:	fc                   	cld    
  8009b5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009b7:	eb 05                	jmp    8009be <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009b9:	89 c7                	mov    %eax,%edi
  8009bb:	fc                   	cld    
  8009bc:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009be:	5e                   	pop    %esi
  8009bf:	5f                   	pop    %edi
  8009c0:	5d                   	pop    %ebp
  8009c1:	c3                   	ret    

008009c2 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009c2:	f3 0f 1e fb          	endbr32 
  8009c6:	55                   	push   %ebp
  8009c7:	89 e5                	mov    %esp,%ebp
  8009c9:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009cc:	ff 75 10             	pushl  0x10(%ebp)
  8009cf:	ff 75 0c             	pushl  0xc(%ebp)
  8009d2:	ff 75 08             	pushl  0x8(%ebp)
  8009d5:	e8 82 ff ff ff       	call   80095c <memmove>
}
  8009da:	c9                   	leave  
  8009db:	c3                   	ret    

008009dc <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009dc:	f3 0f 1e fb          	endbr32 
  8009e0:	55                   	push   %ebp
  8009e1:	89 e5                	mov    %esp,%ebp
  8009e3:	56                   	push   %esi
  8009e4:	53                   	push   %ebx
  8009e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8009e8:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009eb:	89 c6                	mov    %eax,%esi
  8009ed:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009f0:	39 f0                	cmp    %esi,%eax
  8009f2:	74 1c                	je     800a10 <memcmp+0x34>
		if (*s1 != *s2)
  8009f4:	0f b6 08             	movzbl (%eax),%ecx
  8009f7:	0f b6 1a             	movzbl (%edx),%ebx
  8009fa:	38 d9                	cmp    %bl,%cl
  8009fc:	75 08                	jne    800a06 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009fe:	83 c0 01             	add    $0x1,%eax
  800a01:	83 c2 01             	add    $0x1,%edx
  800a04:	eb ea                	jmp    8009f0 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a06:	0f b6 c1             	movzbl %cl,%eax
  800a09:	0f b6 db             	movzbl %bl,%ebx
  800a0c:	29 d8                	sub    %ebx,%eax
  800a0e:	eb 05                	jmp    800a15 <memcmp+0x39>
	}

	return 0;
  800a10:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a15:	5b                   	pop    %ebx
  800a16:	5e                   	pop    %esi
  800a17:	5d                   	pop    %ebp
  800a18:	c3                   	ret    

00800a19 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a19:	f3 0f 1e fb          	endbr32 
  800a1d:	55                   	push   %ebp
  800a1e:	89 e5                	mov    %esp,%ebp
  800a20:	8b 45 08             	mov    0x8(%ebp),%eax
  800a23:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a26:	89 c2                	mov    %eax,%edx
  800a28:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a2b:	39 d0                	cmp    %edx,%eax
  800a2d:	73 09                	jae    800a38 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a2f:	38 08                	cmp    %cl,(%eax)
  800a31:	74 05                	je     800a38 <memfind+0x1f>
	for (; s < ends; s++)
  800a33:	83 c0 01             	add    $0x1,%eax
  800a36:	eb f3                	jmp    800a2b <memfind+0x12>
			break;
	return (void *) s;
}
  800a38:	5d                   	pop    %ebp
  800a39:	c3                   	ret    

00800a3a <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a3a:	f3 0f 1e fb          	endbr32 
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	57                   	push   %edi
  800a42:	56                   	push   %esi
  800a43:	53                   	push   %ebx
  800a44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a47:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a4a:	eb 03                	jmp    800a4f <strtol+0x15>
		s++;
  800a4c:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a4f:	0f b6 01             	movzbl (%ecx),%eax
  800a52:	3c 20                	cmp    $0x20,%al
  800a54:	74 f6                	je     800a4c <strtol+0x12>
  800a56:	3c 09                	cmp    $0x9,%al
  800a58:	74 f2                	je     800a4c <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a5a:	3c 2b                	cmp    $0x2b,%al
  800a5c:	74 2a                	je     800a88 <strtol+0x4e>
	int neg = 0;
  800a5e:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a63:	3c 2d                	cmp    $0x2d,%al
  800a65:	74 2b                	je     800a92 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a67:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a6d:	75 0f                	jne    800a7e <strtol+0x44>
  800a6f:	80 39 30             	cmpb   $0x30,(%ecx)
  800a72:	74 28                	je     800a9c <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a74:	85 db                	test   %ebx,%ebx
  800a76:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a7b:	0f 44 d8             	cmove  %eax,%ebx
  800a7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800a83:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a86:	eb 46                	jmp    800ace <strtol+0x94>
		s++;
  800a88:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a8b:	bf 00 00 00 00       	mov    $0x0,%edi
  800a90:	eb d5                	jmp    800a67 <strtol+0x2d>
		s++, neg = 1;
  800a92:	83 c1 01             	add    $0x1,%ecx
  800a95:	bf 01 00 00 00       	mov    $0x1,%edi
  800a9a:	eb cb                	jmp    800a67 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a9c:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aa0:	74 0e                	je     800ab0 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800aa2:	85 db                	test   %ebx,%ebx
  800aa4:	75 d8                	jne    800a7e <strtol+0x44>
		s++, base = 8;
  800aa6:	83 c1 01             	add    $0x1,%ecx
  800aa9:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aae:	eb ce                	jmp    800a7e <strtol+0x44>
		s += 2, base = 16;
  800ab0:	83 c1 02             	add    $0x2,%ecx
  800ab3:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ab8:	eb c4                	jmp    800a7e <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800aba:	0f be d2             	movsbl %dl,%edx
  800abd:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800ac0:	3b 55 10             	cmp    0x10(%ebp),%edx
  800ac3:	7d 3a                	jge    800aff <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ac5:	83 c1 01             	add    $0x1,%ecx
  800ac8:	0f af 45 10          	imul   0x10(%ebp),%eax
  800acc:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ace:	0f b6 11             	movzbl (%ecx),%edx
  800ad1:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ad4:	89 f3                	mov    %esi,%ebx
  800ad6:	80 fb 09             	cmp    $0x9,%bl
  800ad9:	76 df                	jbe    800aba <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800adb:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ade:	89 f3                	mov    %esi,%ebx
  800ae0:	80 fb 19             	cmp    $0x19,%bl
  800ae3:	77 08                	ja     800aed <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ae5:	0f be d2             	movsbl %dl,%edx
  800ae8:	83 ea 57             	sub    $0x57,%edx
  800aeb:	eb d3                	jmp    800ac0 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800aed:	8d 72 bf             	lea    -0x41(%edx),%esi
  800af0:	89 f3                	mov    %esi,%ebx
  800af2:	80 fb 19             	cmp    $0x19,%bl
  800af5:	77 08                	ja     800aff <strtol+0xc5>
			dig = *s - 'A' + 10;
  800af7:	0f be d2             	movsbl %dl,%edx
  800afa:	83 ea 37             	sub    $0x37,%edx
  800afd:	eb c1                	jmp    800ac0 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800aff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b03:	74 05                	je     800b0a <strtol+0xd0>
		*endptr = (char *) s;
  800b05:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b08:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b0a:	89 c2                	mov    %eax,%edx
  800b0c:	f7 da                	neg    %edx
  800b0e:	85 ff                	test   %edi,%edi
  800b10:	0f 45 c2             	cmovne %edx,%eax
}
  800b13:	5b                   	pop    %ebx
  800b14:	5e                   	pop    %esi
  800b15:	5f                   	pop    %edi
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	57                   	push   %edi
  800b1c:	56                   	push   %esi
  800b1d:	53                   	push   %ebx
  800b1e:	83 ec 1c             	sub    $0x1c,%esp
  800b21:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b24:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800b27:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b29:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b2c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b2f:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b32:	8b 75 14             	mov    0x14(%ebp),%esi
  800b35:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b37:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b3b:	74 04                	je     800b41 <syscall+0x29>
  800b3d:	85 c0                	test   %eax,%eax
  800b3f:	7f 08                	jg     800b49 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800b41:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b44:	5b                   	pop    %ebx
  800b45:	5e                   	pop    %esi
  800b46:	5f                   	pop    %edi
  800b47:	5d                   	pop    %ebp
  800b48:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b49:	83 ec 0c             	sub    $0xc,%esp
  800b4c:	50                   	push   %eax
  800b4d:	ff 75 e0             	pushl  -0x20(%ebp)
  800b50:	68 bf 27 80 00       	push   $0x8027bf
  800b55:	6a 23                	push   $0x23
  800b57:	68 dc 27 80 00       	push   $0x8027dc
  800b5c:	e8 f2 f5 ff ff       	call   800153 <_panic>

00800b61 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800b61:	f3 0f 1e fb          	endbr32 
  800b65:	55                   	push   %ebp
  800b66:	89 e5                	mov    %esp,%ebp
  800b68:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b6b:	6a 00                	push   $0x0
  800b6d:	6a 00                	push   $0x0
  800b6f:	6a 00                	push   $0x0
  800b71:	ff 75 0c             	pushl  0xc(%ebp)
  800b74:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b77:	ba 00 00 00 00       	mov    $0x0,%edx
  800b7c:	b8 00 00 00 00       	mov    $0x0,%eax
  800b81:	e8 92 ff ff ff       	call   800b18 <syscall>
}
  800b86:	83 c4 10             	add    $0x10,%esp
  800b89:	c9                   	leave  
  800b8a:	c3                   	ret    

00800b8b <sys_cgetc>:

int
sys_cgetc(void)
{
  800b8b:	f3 0f 1e fb          	endbr32 
  800b8f:	55                   	push   %ebp
  800b90:	89 e5                	mov    %esp,%ebp
  800b92:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b95:	6a 00                	push   $0x0
  800b97:	6a 00                	push   $0x0
  800b99:	6a 00                	push   $0x0
  800b9b:	6a 00                	push   $0x0
  800b9d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ba2:	ba 00 00 00 00       	mov    $0x0,%edx
  800ba7:	b8 01 00 00 00       	mov    $0x1,%eax
  800bac:	e8 67 ff ff ff       	call   800b18 <syscall>
}
  800bb1:	c9                   	leave  
  800bb2:	c3                   	ret    

00800bb3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800bb3:	f3 0f 1e fb          	endbr32 
  800bb7:	55                   	push   %ebp
  800bb8:	89 e5                	mov    %esp,%ebp
  800bba:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800bbd:	6a 00                	push   $0x0
  800bbf:	6a 00                	push   $0x0
  800bc1:	6a 00                	push   $0x0
  800bc3:	6a 00                	push   $0x0
  800bc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc8:	ba 01 00 00 00       	mov    $0x1,%edx
  800bcd:	b8 03 00 00 00       	mov    $0x3,%eax
  800bd2:	e8 41 ff ff ff       	call   800b18 <syscall>
}
  800bd7:	c9                   	leave  
  800bd8:	c3                   	ret    

00800bd9 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bd9:	f3 0f 1e fb          	endbr32 
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800be3:	6a 00                	push   $0x0
  800be5:	6a 00                	push   $0x0
  800be7:	6a 00                	push   $0x0
  800be9:	6a 00                	push   $0x0
  800beb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf5:	b8 02 00 00 00       	mov    $0x2,%eax
  800bfa:	e8 19 ff ff ff       	call   800b18 <syscall>
}
  800bff:	c9                   	leave  
  800c00:	c3                   	ret    

00800c01 <sys_yield>:

void
sys_yield(void)
{
  800c01:	f3 0f 1e fb          	endbr32 
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c0b:	6a 00                	push   $0x0
  800c0d:	6a 00                	push   $0x0
  800c0f:	6a 00                	push   $0x0
  800c11:	6a 00                	push   $0x0
  800c13:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c18:	ba 00 00 00 00       	mov    $0x0,%edx
  800c1d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c22:	e8 f1 fe ff ff       	call   800b18 <syscall>
}
  800c27:	83 c4 10             	add    $0x10,%esp
  800c2a:	c9                   	leave  
  800c2b:	c3                   	ret    

00800c2c <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c2c:	f3 0f 1e fb          	endbr32 
  800c30:	55                   	push   %ebp
  800c31:	89 e5                	mov    %esp,%ebp
  800c33:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c36:	6a 00                	push   $0x0
  800c38:	6a 00                	push   $0x0
  800c3a:	ff 75 10             	pushl  0x10(%ebp)
  800c3d:	ff 75 0c             	pushl  0xc(%ebp)
  800c40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c43:	ba 01 00 00 00       	mov    $0x1,%edx
  800c48:	b8 04 00 00 00       	mov    $0x4,%eax
  800c4d:	e8 c6 fe ff ff       	call   800b18 <syscall>
}
  800c52:	c9                   	leave  
  800c53:	c3                   	ret    

00800c54 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c54:	f3 0f 1e fb          	endbr32 
  800c58:	55                   	push   %ebp
  800c59:	89 e5                	mov    %esp,%ebp
  800c5b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c5e:	ff 75 18             	pushl  0x18(%ebp)
  800c61:	ff 75 14             	pushl  0x14(%ebp)
  800c64:	ff 75 10             	pushl  0x10(%ebp)
  800c67:	ff 75 0c             	pushl  0xc(%ebp)
  800c6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c6d:	ba 01 00 00 00       	mov    $0x1,%edx
  800c72:	b8 05 00 00 00       	mov    $0x5,%eax
  800c77:	e8 9c fe ff ff       	call   800b18 <syscall>
}
  800c7c:	c9                   	leave  
  800c7d:	c3                   	ret    

00800c7e <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c7e:	f3 0f 1e fb          	endbr32 
  800c82:	55                   	push   %ebp
  800c83:	89 e5                	mov    %esp,%ebp
  800c85:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c88:	6a 00                	push   $0x0
  800c8a:	6a 00                	push   $0x0
  800c8c:	6a 00                	push   $0x0
  800c8e:	ff 75 0c             	pushl  0xc(%ebp)
  800c91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c94:	ba 01 00 00 00       	mov    $0x1,%edx
  800c99:	b8 06 00 00 00       	mov    $0x6,%eax
  800c9e:	e8 75 fe ff ff       	call   800b18 <syscall>
}
  800ca3:	c9                   	leave  
  800ca4:	c3                   	ret    

00800ca5 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800ca5:	f3 0f 1e fb          	endbr32 
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800caf:	6a 00                	push   $0x0
  800cb1:	6a 00                	push   $0x0
  800cb3:	6a 00                	push   $0x0
  800cb5:	ff 75 0c             	pushl  0xc(%ebp)
  800cb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cbb:	ba 01 00 00 00       	mov    $0x1,%edx
  800cc0:	b8 08 00 00 00       	mov    $0x8,%eax
  800cc5:	e8 4e fe ff ff       	call   800b18 <syscall>
}
  800cca:	c9                   	leave  
  800ccb:	c3                   	ret    

00800ccc <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ccc:	f3 0f 1e fb          	endbr32 
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800cd6:	6a 00                	push   $0x0
  800cd8:	6a 00                	push   $0x0
  800cda:	6a 00                	push   $0x0
  800cdc:	ff 75 0c             	pushl  0xc(%ebp)
  800cdf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce2:	ba 01 00 00 00       	mov    $0x1,%edx
  800ce7:	b8 09 00 00 00       	mov    $0x9,%eax
  800cec:	e8 27 fe ff ff       	call   800b18 <syscall>
}
  800cf1:	c9                   	leave  
  800cf2:	c3                   	ret    

00800cf3 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cf3:	f3 0f 1e fb          	endbr32 
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800cfd:	6a 00                	push   $0x0
  800cff:	6a 00                	push   $0x0
  800d01:	6a 00                	push   $0x0
  800d03:	ff 75 0c             	pushl  0xc(%ebp)
  800d06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d09:	ba 01 00 00 00       	mov    $0x1,%edx
  800d0e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d13:	e8 00 fe ff ff       	call   800b18 <syscall>
}
  800d18:	c9                   	leave  
  800d19:	c3                   	ret    

00800d1a <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d1a:	f3 0f 1e fb          	endbr32 
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d24:	6a 00                	push   $0x0
  800d26:	ff 75 14             	pushl  0x14(%ebp)
  800d29:	ff 75 10             	pushl  0x10(%ebp)
  800d2c:	ff 75 0c             	pushl  0xc(%ebp)
  800d2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d32:	ba 00 00 00 00       	mov    $0x0,%edx
  800d37:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d3c:	e8 d7 fd ff ff       	call   800b18 <syscall>
}
  800d41:	c9                   	leave  
  800d42:	c3                   	ret    

00800d43 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d43:	f3 0f 1e fb          	endbr32 
  800d47:	55                   	push   %ebp
  800d48:	89 e5                	mov    %esp,%ebp
  800d4a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d4d:	6a 00                	push   $0x0
  800d4f:	6a 00                	push   $0x0
  800d51:	6a 00                	push   $0x0
  800d53:	6a 00                	push   $0x0
  800d55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d58:	ba 01 00 00 00       	mov    $0x1,%edx
  800d5d:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d62:	e8 b1 fd ff ff       	call   800b18 <syscall>
}
  800d67:	c9                   	leave  
  800d68:	c3                   	ret    

00800d69 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800d69:	55                   	push   %ebp
  800d6a:	89 e5                	mov    %esp,%ebp
  800d6c:	53                   	push   %ebx
  800d6d:	83 ec 04             	sub    $0x4,%esp
  800d70:	89 d3                	mov    %edx,%ebx
	int r;

	// LAB 4: Your code here.

	// Page Table Entry
	pte_t pt_e = uvpt[pn];
  800d72:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Obtenemos la virtual address
	void *v_add = (void *) (pn << PTXSHIFT);
  800d79:	c1 e3 0c             	shl    $0xc,%ebx

	if (pt_e & PTE_SHARE) {
  800d7c:	f6 c6 04             	test   $0x4,%dh
  800d7f:	75 54                	jne    800dd5 <duppage+0x6c>
		// Permisos compartidos
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
		if (r < 0)
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	} else if ((pt_e & PTE_W) || (pt_e & PTE_COW)) {
  800d81:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800d87:	0f 84 8d 00 00 00    	je     800e1a <duppage+0xb1>
		// Copy on write
		r = sys_page_map(0, v_add, envid, v_add, PTE_COW | PTE_U | PTE_P);
  800d8d:	83 ec 0c             	sub    $0xc,%esp
  800d90:	68 05 08 00 00       	push   $0x805
  800d95:	53                   	push   %ebx
  800d96:	50                   	push   %eax
  800d97:	53                   	push   %ebx
  800d98:	6a 00                	push   $0x0
  800d9a:	e8 b5 fe ff ff       	call   800c54 <sys_page_map>
		if (r < 0)
  800d9f:	83 c4 20             	add    $0x20,%esp
  800da2:	85 c0                	test   %eax,%eax
  800da4:	78 5f                	js     800e05 <duppage+0x9c>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);

		r = sys_page_map(0, v_add, 0, v_add, PTE_COW | PTE_U | PTE_P);
  800da6:	83 ec 0c             	sub    $0xc,%esp
  800da9:	68 05 08 00 00       	push   $0x805
  800dae:	53                   	push   %ebx
  800daf:	6a 00                	push   $0x0
  800db1:	53                   	push   %ebx
  800db2:	6a 00                	push   $0x0
  800db4:	e8 9b fe ff ff       	call   800c54 <sys_page_map>
		if (r < 0)
  800db9:	83 c4 20             	add    $0x20,%esp
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	79 70                	jns    800e30 <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800dc0:	50                   	push   %eax
  800dc1:	68 ec 27 80 00       	push   $0x8027ec
  800dc6:	68 9b 00 00 00       	push   $0x9b
  800dcb:	68 5a 29 80 00       	push   $0x80295a
  800dd0:	e8 7e f3 ff ff       	call   800153 <_panic>
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
  800dd5:	83 ec 0c             	sub    $0xc,%esp
  800dd8:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800dde:	52                   	push   %edx
  800ddf:	53                   	push   %ebx
  800de0:	50                   	push   %eax
  800de1:	53                   	push   %ebx
  800de2:	6a 00                	push   $0x0
  800de4:	e8 6b fe ff ff       	call   800c54 <sys_page_map>
		if (r < 0)
  800de9:	83 c4 20             	add    $0x20,%esp
  800dec:	85 c0                	test   %eax,%eax
  800dee:	79 40                	jns    800e30 <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800df0:	50                   	push   %eax
  800df1:	68 ec 27 80 00       	push   $0x8027ec
  800df6:	68 92 00 00 00       	push   $0x92
  800dfb:	68 5a 29 80 00       	push   $0x80295a
  800e00:	e8 4e f3 ff ff       	call   800153 <_panic>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800e05:	50                   	push   %eax
  800e06:	68 ec 27 80 00       	push   $0x8027ec
  800e0b:	68 97 00 00 00       	push   $0x97
  800e10:	68 5a 29 80 00       	push   $0x80295a
  800e15:	e8 39 f3 ff ff       	call   800153 <_panic>
	} else {
		// En caso de lectura, compartir.
		r = sys_page_map(0, v_add, envid, v_add, PTE_U | PTE_P);
  800e1a:	83 ec 0c             	sub    $0xc,%esp
  800e1d:	6a 05                	push   $0x5
  800e1f:	53                   	push   %ebx
  800e20:	50                   	push   %eax
  800e21:	53                   	push   %ebx
  800e22:	6a 00                	push   $0x0
  800e24:	e8 2b fe ff ff       	call   800c54 <sys_page_map>
		if (r < 0)
  800e29:	83 c4 20             	add    $0x20,%esp
  800e2c:	85 c0                	test   %eax,%eax
  800e2e:	78 0a                	js     800e3a <duppage+0xd1>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	}
	return 0;
}
  800e30:	b8 00 00 00 00       	mov    $0x0,%eax
  800e35:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800e38:	c9                   	leave  
  800e39:	c3                   	ret    
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800e3a:	50                   	push   %eax
  800e3b:	68 ec 27 80 00       	push   $0x8027ec
  800e40:	68 a0 00 00 00       	push   $0xa0
  800e45:	68 5a 29 80 00       	push   $0x80295a
  800e4a:	e8 04 f3 ff ff       	call   800153 <_panic>

00800e4f <dup_or_share>:
{
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	57                   	push   %edi
  800e53:	56                   	push   %esi
  800e54:	53                   	push   %ebx
  800e55:	83 ec 0c             	sub    $0xc,%esp
  800e58:	89 c7                	mov    %eax,%edi
  800e5a:	89 d6                	mov    %edx,%esi
  800e5c:	89 cb                	mov    %ecx,%ebx
	if (perm & PTE_W) {
  800e5e:	f6 c1 02             	test   $0x2,%cl
  800e61:	0f 84 90 00 00 00    	je     800ef7 <dup_or_share+0xa8>
		if ((r = sys_page_alloc(dstenv, va, perm)) < 0)
  800e67:	83 ec 04             	sub    $0x4,%esp
  800e6a:	51                   	push   %ecx
  800e6b:	52                   	push   %edx
  800e6c:	50                   	push   %eax
  800e6d:	e8 ba fd ff ff       	call   800c2c <sys_page_alloc>
  800e72:	83 c4 10             	add    $0x10,%esp
  800e75:	85 c0                	test   %eax,%eax
  800e77:	78 56                	js     800ecf <dup_or_share+0x80>
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, perm)) < 0)
  800e79:	83 ec 0c             	sub    $0xc,%esp
  800e7c:	53                   	push   %ebx
  800e7d:	68 00 00 40 00       	push   $0x400000
  800e82:	6a 00                	push   $0x0
  800e84:	56                   	push   %esi
  800e85:	57                   	push   %edi
  800e86:	e8 c9 fd ff ff       	call   800c54 <sys_page_map>
  800e8b:	83 c4 20             	add    $0x20,%esp
  800e8e:	85 c0                	test   %eax,%eax
  800e90:	78 51                	js     800ee3 <dup_or_share+0x94>
		memmove(UTEMP, va, PGSIZE);
  800e92:	83 ec 04             	sub    $0x4,%esp
  800e95:	68 00 10 00 00       	push   $0x1000
  800e9a:	56                   	push   %esi
  800e9b:	68 00 00 40 00       	push   $0x400000
  800ea0:	e8 b7 fa ff ff       	call   80095c <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800ea5:	83 c4 08             	add    $0x8,%esp
  800ea8:	68 00 00 40 00       	push   $0x400000
  800ead:	6a 00                	push   $0x0
  800eaf:	e8 ca fd ff ff       	call   800c7e <sys_page_unmap>
  800eb4:	83 c4 10             	add    $0x10,%esp
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	79 51                	jns    800f0c <dup_or_share+0xbd>
			panic("sys_page_unmap failed at dup_or_share");
  800ebb:	83 ec 04             	sub    $0x4,%esp
  800ebe:	68 5c 28 80 00       	push   $0x80285c
  800ec3:	6a 18                	push   $0x18
  800ec5:	68 5a 29 80 00       	push   $0x80295a
  800eca:	e8 84 f2 ff ff       	call   800153 <_panic>
			panic("sys_page_alloc failed at dup_or_share");
  800ecf:	83 ec 04             	sub    $0x4,%esp
  800ed2:	68 10 28 80 00       	push   $0x802810
  800ed7:	6a 13                	push   $0x13
  800ed9:	68 5a 29 80 00       	push   $0x80295a
  800ede:	e8 70 f2 ff ff       	call   800153 <_panic>
			panic("sys_page_map failed at dup_or_share");
  800ee3:	83 ec 04             	sub    $0x4,%esp
  800ee6:	68 38 28 80 00       	push   $0x802838
  800eeb:	6a 15                	push   $0x15
  800eed:	68 5a 29 80 00       	push   $0x80295a
  800ef2:	e8 5c f2 ff ff       	call   800153 <_panic>
		if ((r = sys_page_map(0, va, dstenv, va, perm)) < 0)
  800ef7:	83 ec 0c             	sub    $0xc,%esp
  800efa:	51                   	push   %ecx
  800efb:	52                   	push   %edx
  800efc:	50                   	push   %eax
  800efd:	52                   	push   %edx
  800efe:	6a 00                	push   $0x0
  800f00:	e8 4f fd ff ff       	call   800c54 <sys_page_map>
  800f05:	83 c4 20             	add    $0x20,%esp
  800f08:	85 c0                	test   %eax,%eax
  800f0a:	78 08                	js     800f14 <dup_or_share+0xc5>
}
  800f0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f0f:	5b                   	pop    %ebx
  800f10:	5e                   	pop    %esi
  800f11:	5f                   	pop    %edi
  800f12:	5d                   	pop    %ebp
  800f13:	c3                   	ret    
			panic("sys_page_map failed at dup_or_share");
  800f14:	83 ec 04             	sub    $0x4,%esp
  800f17:	68 38 28 80 00       	push   $0x802838
  800f1c:	6a 1c                	push   $0x1c
  800f1e:	68 5a 29 80 00       	push   $0x80295a
  800f23:	e8 2b f2 ff ff       	call   800153 <_panic>

00800f28 <pgfault>:
{
  800f28:	f3 0f 1e fb          	endbr32 
  800f2c:	55                   	push   %ebp
  800f2d:	89 e5                	mov    %esp,%ebp
  800f2f:	53                   	push   %ebx
  800f30:	83 ec 04             	sub    $0x4,%esp
  800f33:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800f36:	8b 18                	mov    (%eax),%ebx
	pte_t pt_e = uvpt[PGNUM(addr)];
  800f38:	89 da                	mov    %ebx,%edx
  800f3a:	c1 ea 0c             	shr    $0xc,%edx
  800f3d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if ((err & FEC_WR) == 0)
  800f44:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800f48:	74 6e                	je     800fb8 <pgfault+0x90>
	if ((pt_e & PTE_COW) == 0)
  800f4a:	f6 c6 08             	test   $0x8,%dh
  800f4d:	74 7d                	je     800fcc <pgfault+0xa4>
	if ((r = sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  800f4f:	83 ec 04             	sub    $0x4,%esp
  800f52:	6a 07                	push   $0x7
  800f54:	68 00 f0 7f 00       	push   $0x7ff000
  800f59:	6a 00                	push   $0x0
  800f5b:	e8 cc fc ff ff       	call   800c2c <sys_page_alloc>
  800f60:	83 c4 10             	add    $0x10,%esp
  800f63:	85 c0                	test   %eax,%eax
  800f65:	78 79                	js     800fe0 <pgfault+0xb8>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800f67:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800f6d:	83 ec 04             	sub    $0x4,%esp
  800f70:	68 00 10 00 00       	push   $0x1000
  800f75:	53                   	push   %ebx
  800f76:	68 00 f0 7f 00       	push   $0x7ff000
  800f7b:	e8 dc f9 ff ff       	call   80095c <memmove>
	if ((r = sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U)) <
  800f80:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  800f87:	53                   	push   %ebx
  800f88:	6a 00                	push   $0x0
  800f8a:	68 00 f0 7f 00       	push   $0x7ff000
  800f8f:	6a 00                	push   $0x0
  800f91:	e8 be fc ff ff       	call   800c54 <sys_page_map>
  800f96:	83 c4 20             	add    $0x20,%esp
  800f99:	85 c0                	test   %eax,%eax
  800f9b:	78 57                	js     800ff4 <pgfault+0xcc>
	if ((r = sys_page_unmap(0, (void *) PFTEMP)) < 0)
  800f9d:	83 ec 08             	sub    $0x8,%esp
  800fa0:	68 00 f0 7f 00       	push   $0x7ff000
  800fa5:	6a 00                	push   $0x0
  800fa7:	e8 d2 fc ff ff       	call   800c7e <sys_page_unmap>
  800fac:	83 c4 10             	add    $0x10,%esp
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	78 55                	js     801008 <pgfault+0xe0>
}
  800fb3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fb6:	c9                   	leave  
  800fb7:	c3                   	ret    
		panic("ERROR EN PGFAULT: WRITE");
  800fb8:	83 ec 04             	sub    $0x4,%esp
  800fbb:	68 65 29 80 00       	push   $0x802965
  800fc0:	6a 5e                	push   $0x5e
  800fc2:	68 5a 29 80 00       	push   $0x80295a
  800fc7:	e8 87 f1 ff ff       	call   800153 <_panic>
		panic("ERROR EN PGFAULT: COPY-ON-WRITE");
  800fcc:	83 ec 04             	sub    $0x4,%esp
  800fcf:	68 84 28 80 00       	push   $0x802884
  800fd4:	6a 62                	push   $0x62
  800fd6:	68 5a 29 80 00       	push   $0x80295a
  800fdb:	e8 73 f1 ff ff       	call   800153 <_panic>
		panic("pgfault failed");
  800fe0:	83 ec 04             	sub    $0x4,%esp
  800fe3:	68 7d 29 80 00       	push   $0x80297d
  800fe8:	6a 6d                	push   $0x6d
  800fea:	68 5a 29 80 00       	push   $0x80295a
  800fef:	e8 5f f1 ff ff       	call   800153 <_panic>
		panic("pgfault failed");
  800ff4:	83 ec 04             	sub    $0x4,%esp
  800ff7:	68 7d 29 80 00       	push   $0x80297d
  800ffc:	6a 72                	push   $0x72
  800ffe:	68 5a 29 80 00       	push   $0x80295a
  801003:	e8 4b f1 ff ff       	call   800153 <_panic>
		panic("pgfault failed");
  801008:	83 ec 04             	sub    $0x4,%esp
  80100b:	68 7d 29 80 00       	push   $0x80297d
  801010:	6a 74                	push   $0x74
  801012:	68 5a 29 80 00       	push   $0x80295a
  801017:	e8 37 f1 ff ff       	call   800153 <_panic>

0080101c <fork_v0>:
{
  80101c:	f3 0f 1e fb          	endbr32 
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	57                   	push   %edi
  801024:	56                   	push   %esi
  801025:	53                   	push   %ebx
  801026:	83 ec 1c             	sub    $0x1c,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801029:	b8 07 00 00 00       	mov    $0x7,%eax
  80102e:	cd 30                	int    $0x30
  801030:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801033:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (envid < 0)
  801036:	85 c0                	test   %eax,%eax
  801038:	78 1d                	js     801057 <fork_v0+0x3b>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  80103a:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  80103f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801043:	74 26                	je     80106b <fork_v0+0x4f>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  801045:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  80104a:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
			        (pte_t *) (PGADDR(PDX(uvpt),
  801050:	bf 00 00 40 ef       	mov    $0xef400000,%edi
  801055:	eb 4b                	jmp    8010a2 <fork_v0+0x86>
		panic("sys_exofork failed");
  801057:	83 ec 04             	sub    $0x4,%esp
  80105a:	68 8c 29 80 00       	push   $0x80298c
  80105f:	6a 2b                	push   $0x2b
  801061:	68 5a 29 80 00       	push   $0x80295a
  801066:	e8 e8 f0 ff ff       	call   800153 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
  80106b:	e8 69 fb ff ff       	call   800bd9 <sys_getenvid>
  801070:	25 ff 03 00 00       	and    $0x3ff,%eax
  801075:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801078:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80107d:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  801082:	eb 68                	jmp    8010ec <fork_v0+0xd0>
				dup_or_share(envid,
  801084:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  80108a:	89 da                	mov    %ebx,%edx
  80108c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80108f:	e8 bb fd ff ff       	call   800e4f <dup_or_share>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  801094:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80109a:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8010a0:	74 36                	je     8010d8 <fork_v0+0xbc>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  8010a2:	89 d8                	mov    %ebx,%eax
  8010a4:	c1 e8 16             	shr    $0x16,%eax
  8010a7:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  8010ae:	09 f2                	or     %esi,%edx
		if ((*pgdirentry) & PTE_P) {
  8010b0:	f6 02 01             	testb  $0x1,(%edx)
  8010b3:	74 df                	je     801094 <fork_v0+0x78>
			        (pte_t *) (PGADDR(PDX(uvpt),
  8010b5:	89 da                	mov    %ebx,%edx
  8010b7:	c1 ea 0a             	shr    $0xa,%edx
  8010ba:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  8010c0:	c1 e0 0c             	shl    $0xc,%eax
  8010c3:	89 f9                	mov    %edi,%ecx
  8010c5:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
  8010cb:	09 c8                	or     %ecx,%eax
  8010cd:	09 d0                	or     %edx,%eax
			if ((*pgtablentry) & PTE_P)
  8010cf:	8b 08                	mov    (%eax),%ecx
  8010d1:	f6 c1 01             	test   $0x1,%cl
  8010d4:	74 be                	je     801094 <fork_v0+0x78>
  8010d6:	eb ac                	jmp    801084 <fork_v0+0x68>
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8010d8:	83 ec 08             	sub    $0x8,%esp
  8010db:	6a 02                	push   $0x2
  8010dd:	ff 75 e0             	pushl  -0x20(%ebp)
  8010e0:	e8 c0 fb ff ff       	call   800ca5 <sys_env_set_status>
  8010e5:	83 c4 10             	add    $0x10,%esp
  8010e8:	85 c0                	test   %eax,%eax
  8010ea:	78 0b                	js     8010f7 <fork_v0+0xdb>
}
  8010ec:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8010ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010f2:	5b                   	pop    %ebx
  8010f3:	5e                   	pop    %esi
  8010f4:	5f                   	pop    %edi
  8010f5:	5d                   	pop    %ebp
  8010f6:	c3                   	ret    
		panic("sys_env_set_status failed at fork_v0");
  8010f7:	83 ec 04             	sub    $0x4,%esp
  8010fa:	68 a4 28 80 00       	push   $0x8028a4
  8010ff:	6a 43                	push   $0x43
  801101:	68 5a 29 80 00       	push   $0x80295a
  801106:	e8 48 f0 ff ff       	call   800153 <_panic>

0080110b <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  80110b:	f3 0f 1e fb          	endbr32 
  80110f:	55                   	push   %ebp
  801110:	89 e5                	mov    %esp,%ebp
  801112:	57                   	push   %edi
  801113:	56                   	push   %esi
  801114:	53                   	push   %ebx
  801115:	83 ec 28             	sub    $0x28,%esp
	int err;

	// handle padre
	set_pgfault_handler(pgfault);
  801118:	68 28 0f 80 00       	push   $0x800f28
  80111d:	e8 d3 0e 00 00       	call   801ff5 <set_pgfault_handler>
  801122:	b8 07 00 00 00       	mov    $0x7,%eax
  801127:	cd 30                	int    $0x30
  801129:	89 45 e0             	mov    %eax,-0x20(%ebp)

	// Proceso hijo
	envid_t e_id = sys_exofork();

	if (e_id < 0)
  80112c:	83 c4 10             	add    $0x10,%esp
  80112f:	85 c0                	test   %eax,%eax
  801131:	78 2f                	js     801162 <fork+0x57>
  801133:	89 c7                	mov    %eax,%edi
  801135:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		panic("ERROR EN FORK: sys_exofork: %e", e_id);

	if (e_id == 0) {
  80113c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801140:	0f 85 9e 00 00 00    	jne    8011e4 <fork+0xd9>
		// Si es hijo
		thisenv = &envs[ENVX(sys_getenvid())];
  801146:	e8 8e fa ff ff       	call   800bd9 <sys_getenvid>
  80114b:	25 ff 03 00 00       	and    $0x3ff,%eax
  801150:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801153:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801158:	a3 08 40 80 00       	mov    %eax,0x804008
		return 0;
  80115d:	e9 de 00 00 00       	jmp    801240 <fork+0x135>
		panic("ERROR EN FORK: sys_exofork: %e", e_id);
  801162:	50                   	push   %eax
  801163:	68 cc 28 80 00       	push   $0x8028cc
  801168:	68 c2 00 00 00       	push   $0xc2
  80116d:	68 5a 29 80 00       	push   $0x80295a
  801172:	e8 dc ef ff ff       	call   800153 <_panic>
		// LOOP PTEs
		while (pt_x < NPTENTRIES) {
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
			pte_t pt_e = uvpt[PGNUM(dir)];
			if (dir == (UXSTACKTOP - PGSIZE)) {
				err = sys_page_alloc(e_id,
  801177:	83 ec 04             	sub    $0x4,%esp
  80117a:	6a 07                	push   $0x7
  80117c:	68 00 f0 bf ee       	push   $0xeebff000
  801181:	57                   	push   %edi
  801182:	e8 a5 fa ff ff       	call   800c2c <sys_page_alloc>
				                     (void *) dir,
				                     PTE_W | PTE_U | PTE_P);
				if (err)
  801187:	83 c4 10             	add    $0x10,%esp
  80118a:	85 c0                	test   %eax,%eax
  80118c:	75 33                	jne    8011c1 <fork+0xb6>
  80118e:	83 c3 01             	add    $0x1,%ebx
		while (pt_x < NPTENTRIES) {
  801191:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801197:	74 3d                	je     8011d6 <fork+0xcb>
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
  801199:	89 d8                	mov    %ebx,%eax
  80119b:	c1 e0 0c             	shl    $0xc,%eax
  80119e:	09 f0                	or     %esi,%eax
			pte_t pt_e = uvpt[PGNUM(dir)];
  8011a0:	89 c2                	mov    %eax,%edx
  8011a2:	c1 ea 0c             	shr    $0xc,%edx
  8011a5:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
			if (dir == (UXSTACKTOP - PGSIZE)) {
  8011ac:	3d 00 f0 bf ee       	cmp    $0xeebff000,%eax
  8011b1:	74 c4                	je     801177 <fork+0x6c>
					      "%e",
					      err);
				pt_x++;
				continue;
			}
			if ((pt_e & PTE_P) == 0) {
  8011b3:	f6 c1 01             	test   $0x1,%cl
  8011b6:	74 d6                	je     80118e <fork+0x83>
				pt_x++;
				continue;
			}
			duppage(e_id, PGNUM(dir));
  8011b8:	89 f8                	mov    %edi,%eax
  8011ba:	e8 aa fb ff ff       	call   800d69 <duppage>
  8011bf:	eb cd                	jmp    80118e <fork+0x83>
					panic("ERROR EN FORK: sys_page_alloc: "
  8011c1:	50                   	push   %eax
  8011c2:	68 ec 28 80 00       	push   $0x8028ec
  8011c7:	68 e1 00 00 00       	push   $0xe1
  8011cc:	68 5a 29 80 00       	push   $0x80295a
  8011d1:	e8 7d ef ff ff       	call   800153 <_panic>
  8011d6:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  8011da:	8b 45 e4             	mov    -0x1c(%ebp),%eax
	while (pd_x < PDX(UTOP)) {
  8011dd:	3d bb 03 00 00       	cmp    $0x3bb,%eax
  8011e2:	74 18                	je     8011fc <fork+0xf1>
		pde_t pd_e = uvpd[pd_x];
  8011e4:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8011e7:	8b 04 b5 00 d0 7b ef 	mov    -0x10843000(,%esi,4),%eax
		if ((pd_e & PTE_P) == 0) {
  8011ee:	a8 01                	test   $0x1,%al
  8011f0:	74 e4                	je     8011d6 <fork+0xcb>
  8011f2:	c1 e6 16             	shl    $0x16,%esi
  8011f5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8011fa:	eb 9d                	jmp    801199 <fork+0x8e>
			pt_x++;
		}
		pd_x++;
	}

	if ((err = sys_page_alloc(e_id,
  8011fc:	83 ec 04             	sub    $0x4,%esp
  8011ff:	6a 07                	push   $0x7
  801201:	68 00 f0 bf ee       	push   $0xeebff000
  801206:	ff 75 e0             	pushl  -0x20(%ebp)
  801209:	e8 1e fa ff ff       	call   800c2c <sys_page_alloc>
  80120e:	83 c4 10             	add    $0x10,%esp
  801211:	85 c0                	test   %eax,%eax
  801213:	78 36                	js     80124b <fork+0x140>
	                          (void *) (UXSTACKTOP - PGSIZE),
	                          PTE_P | PTE_U | PTE_W) < 0))
		panic("Error en sys_page_alloc");


	if ((sys_env_set_pgfault_upcall(e_id, _pgfault_upcall) < 0))
  801215:	83 ec 08             	sub    $0x8,%esp
  801218:	68 50 20 80 00       	push   $0x802050
  80121d:	ff 75 e0             	pushl  -0x20(%ebp)
  801220:	e8 ce fa ff ff       	call   800cf3 <sys_env_set_pgfault_upcall>
  801225:	83 c4 10             	add    $0x10,%esp
  801228:	85 c0                	test   %eax,%eax
  80122a:	78 36                	js     801262 <fork+0x157>
		panic("sys_env_set_pgfault_upcall failed");

	// HIJO RUNNABLE
	if ((err = sys_env_set_status(e_id, ENV_RUNNABLE)) < 0)
  80122c:	83 ec 08             	sub    $0x8,%esp
  80122f:	6a 02                	push   $0x2
  801231:	ff 75 e0             	pushl  -0x20(%ebp)
  801234:	e8 6c fa ff ff       	call   800ca5 <sys_env_set_status>
  801239:	83 c4 10             	add    $0x10,%esp
  80123c:	85 c0                	test   %eax,%eax
  80123e:	78 39                	js     801279 <fork+0x16e>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);

	return e_id;
}
  801240:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801243:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801246:	5b                   	pop    %ebx
  801247:	5e                   	pop    %esi
  801248:	5f                   	pop    %edi
  801249:	5d                   	pop    %ebp
  80124a:	c3                   	ret    
		panic("Error en sys_page_alloc");
  80124b:	83 ec 04             	sub    $0x4,%esp
  80124e:	68 9f 29 80 00       	push   $0x80299f
  801253:	68 f4 00 00 00       	push   $0xf4
  801258:	68 5a 29 80 00       	push   $0x80295a
  80125d:	e8 f1 ee ff ff       	call   800153 <_panic>
		panic("sys_env_set_pgfault_upcall failed");
  801262:	83 ec 04             	sub    $0x4,%esp
  801265:	68 10 29 80 00       	push   $0x802910
  80126a:	68 f8 00 00 00       	push   $0xf8
  80126f:	68 5a 29 80 00       	push   $0x80295a
  801274:	e8 da ee ff ff       	call   800153 <_panic>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);
  801279:	50                   	push   %eax
  80127a:	68 34 29 80 00       	push   $0x802934
  80127f:	68 fc 00 00 00       	push   $0xfc
  801284:	68 5a 29 80 00       	push   $0x80295a
  801289:	e8 c5 ee ff ff       	call   800153 <_panic>

0080128e <sfork>:

// Challenge!
int
sfork(void)
{
  80128e:	f3 0f 1e fb          	endbr32 
  801292:	55                   	push   %ebp
  801293:	89 e5                	mov    %esp,%ebp
  801295:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801298:	68 b7 29 80 00       	push   $0x8029b7
  80129d:	68 05 01 00 00       	push   $0x105
  8012a2:	68 5a 29 80 00       	push   $0x80295a
  8012a7:	e8 a7 ee ff ff       	call   800153 <_panic>

008012ac <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8012ac:	f3 0f 1e fb          	endbr32 
  8012b0:	55                   	push   %ebp
  8012b1:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8012b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8012b6:	05 00 00 00 30       	add    $0x30000000,%eax
  8012bb:	c1 e8 0c             	shr    $0xc,%eax
}
  8012be:	5d                   	pop    %ebp
  8012bf:	c3                   	ret    

008012c0 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8012c0:	f3 0f 1e fb          	endbr32 
  8012c4:	55                   	push   %ebp
  8012c5:	89 e5                	mov    %esp,%ebp
  8012c7:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  8012ca:	ff 75 08             	pushl  0x8(%ebp)
  8012cd:	e8 da ff ff ff       	call   8012ac <fd2num>
  8012d2:	83 c4 10             	add    $0x10,%esp
  8012d5:	c1 e0 0c             	shl    $0xc,%eax
  8012d8:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8012dd:	c9                   	leave  
  8012de:	c3                   	ret    

008012df <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8012df:	f3 0f 1e fb          	endbr32 
  8012e3:	55                   	push   %ebp
  8012e4:	89 e5                	mov    %esp,%ebp
  8012e6:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8012eb:	89 c2                	mov    %eax,%edx
  8012ed:	c1 ea 16             	shr    $0x16,%edx
  8012f0:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8012f7:	f6 c2 01             	test   $0x1,%dl
  8012fa:	74 2d                	je     801329 <fd_alloc+0x4a>
  8012fc:	89 c2                	mov    %eax,%edx
  8012fe:	c1 ea 0c             	shr    $0xc,%edx
  801301:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801308:	f6 c2 01             	test   $0x1,%dl
  80130b:	74 1c                	je     801329 <fd_alloc+0x4a>
  80130d:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801312:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801317:	75 d2                	jne    8012eb <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801319:	8b 45 08             	mov    0x8(%ebp),%eax
  80131c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801322:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801327:	eb 0a                	jmp    801333 <fd_alloc+0x54>
			*fd_store = fd;
  801329:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80132c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80132e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801333:	5d                   	pop    %ebp
  801334:	c3                   	ret    

00801335 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801335:	f3 0f 1e fb          	endbr32 
  801339:	55                   	push   %ebp
  80133a:	89 e5                	mov    %esp,%ebp
  80133c:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80133f:	83 f8 1f             	cmp    $0x1f,%eax
  801342:	77 30                	ja     801374 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801344:	c1 e0 0c             	shl    $0xc,%eax
  801347:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80134c:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801352:	f6 c2 01             	test   $0x1,%dl
  801355:	74 24                	je     80137b <fd_lookup+0x46>
  801357:	89 c2                	mov    %eax,%edx
  801359:	c1 ea 0c             	shr    $0xc,%edx
  80135c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801363:	f6 c2 01             	test   $0x1,%dl
  801366:	74 1a                	je     801382 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801368:	8b 55 0c             	mov    0xc(%ebp),%edx
  80136b:	89 02                	mov    %eax,(%edx)
	return 0;
  80136d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801372:	5d                   	pop    %ebp
  801373:	c3                   	ret    
		return -E_INVAL;
  801374:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801379:	eb f7                	jmp    801372 <fd_lookup+0x3d>
		return -E_INVAL;
  80137b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801380:	eb f0                	jmp    801372 <fd_lookup+0x3d>
  801382:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801387:	eb e9                	jmp    801372 <fd_lookup+0x3d>

00801389 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801389:	f3 0f 1e fb          	endbr32 
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	83 ec 08             	sub    $0x8,%esp
  801393:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801396:	ba 4c 2a 80 00       	mov    $0x802a4c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80139b:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8013a0:	39 08                	cmp    %ecx,(%eax)
  8013a2:	74 33                	je     8013d7 <dev_lookup+0x4e>
  8013a4:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8013a7:	8b 02                	mov    (%edx),%eax
  8013a9:	85 c0                	test   %eax,%eax
  8013ab:	75 f3                	jne    8013a0 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8013ad:	a1 08 40 80 00       	mov    0x804008,%eax
  8013b2:	8b 40 48             	mov    0x48(%eax),%eax
  8013b5:	83 ec 04             	sub    $0x4,%esp
  8013b8:	51                   	push   %ecx
  8013b9:	50                   	push   %eax
  8013ba:	68 d0 29 80 00       	push   $0x8029d0
  8013bf:	e8 76 ee ff ff       	call   80023a <cprintf>
	*dev = 0;
  8013c4:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013c7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8013cd:	83 c4 10             	add    $0x10,%esp
  8013d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8013d5:	c9                   	leave  
  8013d6:	c3                   	ret    
			*dev = devtab[i];
  8013d7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8013da:	89 01                	mov    %eax,(%ecx)
			return 0;
  8013dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8013e1:	eb f2                	jmp    8013d5 <dev_lookup+0x4c>

008013e3 <fd_close>:
{
  8013e3:	f3 0f 1e fb          	endbr32 
  8013e7:	55                   	push   %ebp
  8013e8:	89 e5                	mov    %esp,%ebp
  8013ea:	57                   	push   %edi
  8013eb:	56                   	push   %esi
  8013ec:	53                   	push   %ebx
  8013ed:	83 ec 28             	sub    $0x28,%esp
  8013f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8013f3:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8013f6:	56                   	push   %esi
  8013f7:	e8 b0 fe ff ff       	call   8012ac <fd2num>
  8013fc:	83 c4 08             	add    $0x8,%esp
  8013ff:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801402:	52                   	push   %edx
  801403:	50                   	push   %eax
  801404:	e8 2c ff ff ff       	call   801335 <fd_lookup>
  801409:	89 c3                	mov    %eax,%ebx
  80140b:	83 c4 10             	add    $0x10,%esp
  80140e:	85 c0                	test   %eax,%eax
  801410:	78 05                	js     801417 <fd_close+0x34>
	    || fd != fd2)
  801412:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801415:	74 16                	je     80142d <fd_close+0x4a>
		return (must_exist ? r : 0);
  801417:	89 f8                	mov    %edi,%eax
  801419:	84 c0                	test   %al,%al
  80141b:	b8 00 00 00 00       	mov    $0x0,%eax
  801420:	0f 44 d8             	cmove  %eax,%ebx
}
  801423:	89 d8                	mov    %ebx,%eax
  801425:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801428:	5b                   	pop    %ebx
  801429:	5e                   	pop    %esi
  80142a:	5f                   	pop    %edi
  80142b:	5d                   	pop    %ebp
  80142c:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80142d:	83 ec 08             	sub    $0x8,%esp
  801430:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801433:	50                   	push   %eax
  801434:	ff 36                	pushl  (%esi)
  801436:	e8 4e ff ff ff       	call   801389 <dev_lookup>
  80143b:	89 c3                	mov    %eax,%ebx
  80143d:	83 c4 10             	add    $0x10,%esp
  801440:	85 c0                	test   %eax,%eax
  801442:	78 1a                	js     80145e <fd_close+0x7b>
		if (dev->dev_close)
  801444:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801447:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80144a:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80144f:	85 c0                	test   %eax,%eax
  801451:	74 0b                	je     80145e <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801453:	83 ec 0c             	sub    $0xc,%esp
  801456:	56                   	push   %esi
  801457:	ff d0                	call   *%eax
  801459:	89 c3                	mov    %eax,%ebx
  80145b:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80145e:	83 ec 08             	sub    $0x8,%esp
  801461:	56                   	push   %esi
  801462:	6a 00                	push   $0x0
  801464:	e8 15 f8 ff ff       	call   800c7e <sys_page_unmap>
	return r;
  801469:	83 c4 10             	add    $0x10,%esp
  80146c:	eb b5                	jmp    801423 <fd_close+0x40>

0080146e <close>:

int
close(int fdnum)
{
  80146e:	f3 0f 1e fb          	endbr32 
  801472:	55                   	push   %ebp
  801473:	89 e5                	mov    %esp,%ebp
  801475:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801478:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80147b:	50                   	push   %eax
  80147c:	ff 75 08             	pushl  0x8(%ebp)
  80147f:	e8 b1 fe ff ff       	call   801335 <fd_lookup>
  801484:	83 c4 10             	add    $0x10,%esp
  801487:	85 c0                	test   %eax,%eax
  801489:	79 02                	jns    80148d <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  80148b:	c9                   	leave  
  80148c:	c3                   	ret    
		return fd_close(fd, 1);
  80148d:	83 ec 08             	sub    $0x8,%esp
  801490:	6a 01                	push   $0x1
  801492:	ff 75 f4             	pushl  -0xc(%ebp)
  801495:	e8 49 ff ff ff       	call   8013e3 <fd_close>
  80149a:	83 c4 10             	add    $0x10,%esp
  80149d:	eb ec                	jmp    80148b <close+0x1d>

0080149f <close_all>:

void
close_all(void)
{
  80149f:	f3 0f 1e fb          	endbr32 
  8014a3:	55                   	push   %ebp
  8014a4:	89 e5                	mov    %esp,%ebp
  8014a6:	53                   	push   %ebx
  8014a7:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8014aa:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8014af:	83 ec 0c             	sub    $0xc,%esp
  8014b2:	53                   	push   %ebx
  8014b3:	e8 b6 ff ff ff       	call   80146e <close>
	for (i = 0; i < MAXFD; i++)
  8014b8:	83 c3 01             	add    $0x1,%ebx
  8014bb:	83 c4 10             	add    $0x10,%esp
  8014be:	83 fb 20             	cmp    $0x20,%ebx
  8014c1:	75 ec                	jne    8014af <close_all+0x10>
}
  8014c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014c6:	c9                   	leave  
  8014c7:	c3                   	ret    

008014c8 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8014c8:	f3 0f 1e fb          	endbr32 
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	57                   	push   %edi
  8014d0:	56                   	push   %esi
  8014d1:	53                   	push   %ebx
  8014d2:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8014d5:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8014d8:	50                   	push   %eax
  8014d9:	ff 75 08             	pushl  0x8(%ebp)
  8014dc:	e8 54 fe ff ff       	call   801335 <fd_lookup>
  8014e1:	89 c3                	mov    %eax,%ebx
  8014e3:	83 c4 10             	add    $0x10,%esp
  8014e6:	85 c0                	test   %eax,%eax
  8014e8:	0f 88 81 00 00 00    	js     80156f <dup+0xa7>
		return r;
	close(newfdnum);
  8014ee:	83 ec 0c             	sub    $0xc,%esp
  8014f1:	ff 75 0c             	pushl  0xc(%ebp)
  8014f4:	e8 75 ff ff ff       	call   80146e <close>

	newfd = INDEX2FD(newfdnum);
  8014f9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8014fc:	c1 e6 0c             	shl    $0xc,%esi
  8014ff:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801505:	83 c4 04             	add    $0x4,%esp
  801508:	ff 75 e4             	pushl  -0x1c(%ebp)
  80150b:	e8 b0 fd ff ff       	call   8012c0 <fd2data>
  801510:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801512:	89 34 24             	mov    %esi,(%esp)
  801515:	e8 a6 fd ff ff       	call   8012c0 <fd2data>
  80151a:	83 c4 10             	add    $0x10,%esp
  80151d:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80151f:	89 d8                	mov    %ebx,%eax
  801521:	c1 e8 16             	shr    $0x16,%eax
  801524:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80152b:	a8 01                	test   $0x1,%al
  80152d:	74 11                	je     801540 <dup+0x78>
  80152f:	89 d8                	mov    %ebx,%eax
  801531:	c1 e8 0c             	shr    $0xc,%eax
  801534:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80153b:	f6 c2 01             	test   $0x1,%dl
  80153e:	75 39                	jne    801579 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801540:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801543:	89 d0                	mov    %edx,%eax
  801545:	c1 e8 0c             	shr    $0xc,%eax
  801548:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80154f:	83 ec 0c             	sub    $0xc,%esp
  801552:	25 07 0e 00 00       	and    $0xe07,%eax
  801557:	50                   	push   %eax
  801558:	56                   	push   %esi
  801559:	6a 00                	push   $0x0
  80155b:	52                   	push   %edx
  80155c:	6a 00                	push   $0x0
  80155e:	e8 f1 f6 ff ff       	call   800c54 <sys_page_map>
  801563:	89 c3                	mov    %eax,%ebx
  801565:	83 c4 20             	add    $0x20,%esp
  801568:	85 c0                	test   %eax,%eax
  80156a:	78 31                	js     80159d <dup+0xd5>
		goto err;

	return newfdnum;
  80156c:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80156f:	89 d8                	mov    %ebx,%eax
  801571:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801574:	5b                   	pop    %ebx
  801575:	5e                   	pop    %esi
  801576:	5f                   	pop    %edi
  801577:	5d                   	pop    %ebp
  801578:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801579:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801580:	83 ec 0c             	sub    $0xc,%esp
  801583:	25 07 0e 00 00       	and    $0xe07,%eax
  801588:	50                   	push   %eax
  801589:	57                   	push   %edi
  80158a:	6a 00                	push   $0x0
  80158c:	53                   	push   %ebx
  80158d:	6a 00                	push   $0x0
  80158f:	e8 c0 f6 ff ff       	call   800c54 <sys_page_map>
  801594:	89 c3                	mov    %eax,%ebx
  801596:	83 c4 20             	add    $0x20,%esp
  801599:	85 c0                	test   %eax,%eax
  80159b:	79 a3                	jns    801540 <dup+0x78>
	sys_page_unmap(0, newfd);
  80159d:	83 ec 08             	sub    $0x8,%esp
  8015a0:	56                   	push   %esi
  8015a1:	6a 00                	push   $0x0
  8015a3:	e8 d6 f6 ff ff       	call   800c7e <sys_page_unmap>
	sys_page_unmap(0, nva);
  8015a8:	83 c4 08             	add    $0x8,%esp
  8015ab:	57                   	push   %edi
  8015ac:	6a 00                	push   $0x0
  8015ae:	e8 cb f6 ff ff       	call   800c7e <sys_page_unmap>
	return r;
  8015b3:	83 c4 10             	add    $0x10,%esp
  8015b6:	eb b7                	jmp    80156f <dup+0xa7>

008015b8 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8015b8:	f3 0f 1e fb          	endbr32 
  8015bc:	55                   	push   %ebp
  8015bd:	89 e5                	mov    %esp,%ebp
  8015bf:	53                   	push   %ebx
  8015c0:	83 ec 1c             	sub    $0x1c,%esp
  8015c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8015c6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8015c9:	50                   	push   %eax
  8015ca:	53                   	push   %ebx
  8015cb:	e8 65 fd ff ff       	call   801335 <fd_lookup>
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	78 3f                	js     801616 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8015d7:	83 ec 08             	sub    $0x8,%esp
  8015da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015dd:	50                   	push   %eax
  8015de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8015e1:	ff 30                	pushl  (%eax)
  8015e3:	e8 a1 fd ff ff       	call   801389 <dev_lookup>
  8015e8:	83 c4 10             	add    $0x10,%esp
  8015eb:	85 c0                	test   %eax,%eax
  8015ed:	78 27                	js     801616 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8015ef:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8015f2:	8b 42 08             	mov    0x8(%edx),%eax
  8015f5:	83 e0 03             	and    $0x3,%eax
  8015f8:	83 f8 01             	cmp    $0x1,%eax
  8015fb:	74 1e                	je     80161b <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8015fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801600:	8b 40 08             	mov    0x8(%eax),%eax
  801603:	85 c0                	test   %eax,%eax
  801605:	74 35                	je     80163c <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801607:	83 ec 04             	sub    $0x4,%esp
  80160a:	ff 75 10             	pushl  0x10(%ebp)
  80160d:	ff 75 0c             	pushl  0xc(%ebp)
  801610:	52                   	push   %edx
  801611:	ff d0                	call   *%eax
  801613:	83 c4 10             	add    $0x10,%esp
}
  801616:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801619:	c9                   	leave  
  80161a:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80161b:	a1 08 40 80 00       	mov    0x804008,%eax
  801620:	8b 40 48             	mov    0x48(%eax),%eax
  801623:	83 ec 04             	sub    $0x4,%esp
  801626:	53                   	push   %ebx
  801627:	50                   	push   %eax
  801628:	68 11 2a 80 00       	push   $0x802a11
  80162d:	e8 08 ec ff ff       	call   80023a <cprintf>
		return -E_INVAL;
  801632:	83 c4 10             	add    $0x10,%esp
  801635:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80163a:	eb da                	jmp    801616 <read+0x5e>
		return -E_NOT_SUPP;
  80163c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801641:	eb d3                	jmp    801616 <read+0x5e>

00801643 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801643:	f3 0f 1e fb          	endbr32 
  801647:	55                   	push   %ebp
  801648:	89 e5                	mov    %esp,%ebp
  80164a:	57                   	push   %edi
  80164b:	56                   	push   %esi
  80164c:	53                   	push   %ebx
  80164d:	83 ec 0c             	sub    $0xc,%esp
  801650:	8b 7d 08             	mov    0x8(%ebp),%edi
  801653:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801656:	bb 00 00 00 00       	mov    $0x0,%ebx
  80165b:	eb 02                	jmp    80165f <readn+0x1c>
  80165d:	01 c3                	add    %eax,%ebx
  80165f:	39 f3                	cmp    %esi,%ebx
  801661:	73 21                	jae    801684 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801663:	83 ec 04             	sub    $0x4,%esp
  801666:	89 f0                	mov    %esi,%eax
  801668:	29 d8                	sub    %ebx,%eax
  80166a:	50                   	push   %eax
  80166b:	89 d8                	mov    %ebx,%eax
  80166d:	03 45 0c             	add    0xc(%ebp),%eax
  801670:	50                   	push   %eax
  801671:	57                   	push   %edi
  801672:	e8 41 ff ff ff       	call   8015b8 <read>
		if (m < 0)
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	85 c0                	test   %eax,%eax
  80167c:	78 04                	js     801682 <readn+0x3f>
			return m;
		if (m == 0)
  80167e:	75 dd                	jne    80165d <readn+0x1a>
  801680:	eb 02                	jmp    801684 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801682:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801684:	89 d8                	mov    %ebx,%eax
  801686:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801689:	5b                   	pop    %ebx
  80168a:	5e                   	pop    %esi
  80168b:	5f                   	pop    %edi
  80168c:	5d                   	pop    %ebp
  80168d:	c3                   	ret    

0080168e <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80168e:	f3 0f 1e fb          	endbr32 
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	53                   	push   %ebx
  801696:	83 ec 1c             	sub    $0x1c,%esp
  801699:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80169c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80169f:	50                   	push   %eax
  8016a0:	53                   	push   %ebx
  8016a1:	e8 8f fc ff ff       	call   801335 <fd_lookup>
  8016a6:	83 c4 10             	add    $0x10,%esp
  8016a9:	85 c0                	test   %eax,%eax
  8016ab:	78 3a                	js     8016e7 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8016ad:	83 ec 08             	sub    $0x8,%esp
  8016b0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016b3:	50                   	push   %eax
  8016b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016b7:	ff 30                	pushl  (%eax)
  8016b9:	e8 cb fc ff ff       	call   801389 <dev_lookup>
  8016be:	83 c4 10             	add    $0x10,%esp
  8016c1:	85 c0                	test   %eax,%eax
  8016c3:	78 22                	js     8016e7 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8016c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8016c8:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8016cc:	74 1e                	je     8016ec <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8016ce:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8016d1:	8b 52 0c             	mov    0xc(%edx),%edx
  8016d4:	85 d2                	test   %edx,%edx
  8016d6:	74 35                	je     80170d <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8016d8:	83 ec 04             	sub    $0x4,%esp
  8016db:	ff 75 10             	pushl  0x10(%ebp)
  8016de:	ff 75 0c             	pushl  0xc(%ebp)
  8016e1:	50                   	push   %eax
  8016e2:	ff d2                	call   *%edx
  8016e4:	83 c4 10             	add    $0x10,%esp
}
  8016e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ea:	c9                   	leave  
  8016eb:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8016ec:	a1 08 40 80 00       	mov    0x804008,%eax
  8016f1:	8b 40 48             	mov    0x48(%eax),%eax
  8016f4:	83 ec 04             	sub    $0x4,%esp
  8016f7:	53                   	push   %ebx
  8016f8:	50                   	push   %eax
  8016f9:	68 2d 2a 80 00       	push   $0x802a2d
  8016fe:	e8 37 eb ff ff       	call   80023a <cprintf>
		return -E_INVAL;
  801703:	83 c4 10             	add    $0x10,%esp
  801706:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80170b:	eb da                	jmp    8016e7 <write+0x59>
		return -E_NOT_SUPP;
  80170d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801712:	eb d3                	jmp    8016e7 <write+0x59>

00801714 <seek>:

int
seek(int fdnum, off_t offset)
{
  801714:	f3 0f 1e fb          	endbr32 
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80171e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801721:	50                   	push   %eax
  801722:	ff 75 08             	pushl  0x8(%ebp)
  801725:	e8 0b fc ff ff       	call   801335 <fd_lookup>
  80172a:	83 c4 10             	add    $0x10,%esp
  80172d:	85 c0                	test   %eax,%eax
  80172f:	78 0e                	js     80173f <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801731:	8b 55 0c             	mov    0xc(%ebp),%edx
  801734:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801737:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80173a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80173f:	c9                   	leave  
  801740:	c3                   	ret    

00801741 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801741:	f3 0f 1e fb          	endbr32 
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	53                   	push   %ebx
  801749:	83 ec 1c             	sub    $0x1c,%esp
  80174c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80174f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801752:	50                   	push   %eax
  801753:	53                   	push   %ebx
  801754:	e8 dc fb ff ff       	call   801335 <fd_lookup>
  801759:	83 c4 10             	add    $0x10,%esp
  80175c:	85 c0                	test   %eax,%eax
  80175e:	78 37                	js     801797 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801760:	83 ec 08             	sub    $0x8,%esp
  801763:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801766:	50                   	push   %eax
  801767:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80176a:	ff 30                	pushl  (%eax)
  80176c:	e8 18 fc ff ff       	call   801389 <dev_lookup>
  801771:	83 c4 10             	add    $0x10,%esp
  801774:	85 c0                	test   %eax,%eax
  801776:	78 1f                	js     801797 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801778:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80177b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80177f:	74 1b                	je     80179c <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801781:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801784:	8b 52 18             	mov    0x18(%edx),%edx
  801787:	85 d2                	test   %edx,%edx
  801789:	74 32                	je     8017bd <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80178b:	83 ec 08             	sub    $0x8,%esp
  80178e:	ff 75 0c             	pushl  0xc(%ebp)
  801791:	50                   	push   %eax
  801792:	ff d2                	call   *%edx
  801794:	83 c4 10             	add    $0x10,%esp
}
  801797:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80179a:	c9                   	leave  
  80179b:	c3                   	ret    
			thisenv->env_id, fdnum);
  80179c:	a1 08 40 80 00       	mov    0x804008,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8017a1:	8b 40 48             	mov    0x48(%eax),%eax
  8017a4:	83 ec 04             	sub    $0x4,%esp
  8017a7:	53                   	push   %ebx
  8017a8:	50                   	push   %eax
  8017a9:	68 f0 29 80 00       	push   $0x8029f0
  8017ae:	e8 87 ea ff ff       	call   80023a <cprintf>
		return -E_INVAL;
  8017b3:	83 c4 10             	add    $0x10,%esp
  8017b6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017bb:	eb da                	jmp    801797 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8017bd:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017c2:	eb d3                	jmp    801797 <ftruncate+0x56>

008017c4 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8017c4:	f3 0f 1e fb          	endbr32 
  8017c8:	55                   	push   %ebp
  8017c9:	89 e5                	mov    %esp,%ebp
  8017cb:	53                   	push   %ebx
  8017cc:	83 ec 1c             	sub    $0x1c,%esp
  8017cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017d5:	50                   	push   %eax
  8017d6:	ff 75 08             	pushl  0x8(%ebp)
  8017d9:	e8 57 fb ff ff       	call   801335 <fd_lookup>
  8017de:	83 c4 10             	add    $0x10,%esp
  8017e1:	85 c0                	test   %eax,%eax
  8017e3:	78 4b                	js     801830 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017e5:	83 ec 08             	sub    $0x8,%esp
  8017e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017eb:	50                   	push   %eax
  8017ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017ef:	ff 30                	pushl  (%eax)
  8017f1:	e8 93 fb ff ff       	call   801389 <dev_lookup>
  8017f6:	83 c4 10             	add    $0x10,%esp
  8017f9:	85 c0                	test   %eax,%eax
  8017fb:	78 33                	js     801830 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8017fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801800:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801804:	74 2f                	je     801835 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801806:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801809:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801810:	00 00 00 
	stat->st_isdir = 0;
  801813:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80181a:	00 00 00 
	stat->st_dev = dev;
  80181d:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801823:	83 ec 08             	sub    $0x8,%esp
  801826:	53                   	push   %ebx
  801827:	ff 75 f0             	pushl  -0x10(%ebp)
  80182a:	ff 50 14             	call   *0x14(%eax)
  80182d:	83 c4 10             	add    $0x10,%esp
}
  801830:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801833:	c9                   	leave  
  801834:	c3                   	ret    
		return -E_NOT_SUPP;
  801835:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80183a:	eb f4                	jmp    801830 <fstat+0x6c>

0080183c <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80183c:	f3 0f 1e fb          	endbr32 
  801840:	55                   	push   %ebp
  801841:	89 e5                	mov    %esp,%ebp
  801843:	56                   	push   %esi
  801844:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801845:	83 ec 08             	sub    $0x8,%esp
  801848:	6a 00                	push   $0x0
  80184a:	ff 75 08             	pushl  0x8(%ebp)
  80184d:	e8 fb 01 00 00       	call   801a4d <open>
  801852:	89 c3                	mov    %eax,%ebx
  801854:	83 c4 10             	add    $0x10,%esp
  801857:	85 c0                	test   %eax,%eax
  801859:	78 1b                	js     801876 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  80185b:	83 ec 08             	sub    $0x8,%esp
  80185e:	ff 75 0c             	pushl  0xc(%ebp)
  801861:	50                   	push   %eax
  801862:	e8 5d ff ff ff       	call   8017c4 <fstat>
  801867:	89 c6                	mov    %eax,%esi
	close(fd);
  801869:	89 1c 24             	mov    %ebx,(%esp)
  80186c:	e8 fd fb ff ff       	call   80146e <close>
	return r;
  801871:	83 c4 10             	add    $0x10,%esp
  801874:	89 f3                	mov    %esi,%ebx
}
  801876:	89 d8                	mov    %ebx,%eax
  801878:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80187b:	5b                   	pop    %ebx
  80187c:	5e                   	pop    %esi
  80187d:	5d                   	pop    %ebp
  80187e:	c3                   	ret    

0080187f <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80187f:	55                   	push   %ebp
  801880:	89 e5                	mov    %esp,%ebp
  801882:	56                   	push   %esi
  801883:	53                   	push   %ebx
  801884:	89 c6                	mov    %eax,%esi
  801886:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801888:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80188f:	74 27                	je     8018b8 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801891:	6a 07                	push   $0x7
  801893:	68 00 50 80 00       	push   $0x805000
  801898:	56                   	push   %esi
  801899:	ff 35 00 40 80 00    	pushl  0x804000
  80189f:	e8 42 08 00 00       	call   8020e6 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8018a4:	83 c4 0c             	add    $0xc,%esp
  8018a7:	6a 00                	push   $0x0
  8018a9:	53                   	push   %ebx
  8018aa:	6a 00                	push   $0x0
  8018ac:	e8 c7 07 00 00       	call   802078 <ipc_recv>
}
  8018b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8018b4:	5b                   	pop    %ebx
  8018b5:	5e                   	pop    %esi
  8018b6:	5d                   	pop    %ebp
  8018b7:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8018b8:	83 ec 0c             	sub    $0xc,%esp
  8018bb:	6a 01                	push   $0x1
  8018bd:	e8 89 08 00 00       	call   80214b <ipc_find_env>
  8018c2:	a3 00 40 80 00       	mov    %eax,0x804000
  8018c7:	83 c4 10             	add    $0x10,%esp
  8018ca:	eb c5                	jmp    801891 <fsipc+0x12>

008018cc <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8018cc:	f3 0f 1e fb          	endbr32 
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
  8018d3:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8018d6:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d9:	8b 40 0c             	mov    0xc(%eax),%eax
  8018dc:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8018e1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8018e4:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8018e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8018ee:	b8 02 00 00 00       	mov    $0x2,%eax
  8018f3:	e8 87 ff ff ff       	call   80187f <fsipc>
}
  8018f8:	c9                   	leave  
  8018f9:	c3                   	ret    

008018fa <devfile_flush>:
{
  8018fa:	f3 0f 1e fb          	endbr32 
  8018fe:	55                   	push   %ebp
  8018ff:	89 e5                	mov    %esp,%ebp
  801901:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801904:	8b 45 08             	mov    0x8(%ebp),%eax
  801907:	8b 40 0c             	mov    0xc(%eax),%eax
  80190a:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80190f:	ba 00 00 00 00       	mov    $0x0,%edx
  801914:	b8 06 00 00 00       	mov    $0x6,%eax
  801919:	e8 61 ff ff ff       	call   80187f <fsipc>
}
  80191e:	c9                   	leave  
  80191f:	c3                   	ret    

00801920 <devfile_stat>:
{
  801920:	f3 0f 1e fb          	endbr32 
  801924:	55                   	push   %ebp
  801925:	89 e5                	mov    %esp,%ebp
  801927:	53                   	push   %ebx
  801928:	83 ec 04             	sub    $0x4,%esp
  80192b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80192e:	8b 45 08             	mov    0x8(%ebp),%eax
  801931:	8b 40 0c             	mov    0xc(%eax),%eax
  801934:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801939:	ba 00 00 00 00       	mov    $0x0,%edx
  80193e:	b8 05 00 00 00       	mov    $0x5,%eax
  801943:	e8 37 ff ff ff       	call   80187f <fsipc>
  801948:	85 c0                	test   %eax,%eax
  80194a:	78 2c                	js     801978 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80194c:	83 ec 08             	sub    $0x8,%esp
  80194f:	68 00 50 80 00       	push   $0x805000
  801954:	53                   	push   %ebx
  801955:	e8 4a ee ff ff       	call   8007a4 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80195a:	a1 80 50 80 00       	mov    0x805080,%eax
  80195f:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801965:	a1 84 50 80 00       	mov    0x805084,%eax
  80196a:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801970:	83 c4 10             	add    $0x10,%esp
  801973:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801978:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80197b:	c9                   	leave  
  80197c:	c3                   	ret    

0080197d <devfile_write>:
{
  80197d:	f3 0f 1e fb          	endbr32 
  801981:	55                   	push   %ebp
  801982:	89 e5                	mov    %esp,%ebp
  801984:	83 ec 0c             	sub    $0xc,%esp
  801987:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80198a:	8b 55 08             	mov    0x8(%ebp),%edx
  80198d:	8b 52 0c             	mov    0xc(%edx),%edx
  801990:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801996:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80199b:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8019a0:	0f 47 c2             	cmova  %edx,%eax
  8019a3:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8019a8:	50                   	push   %eax
  8019a9:	ff 75 0c             	pushl  0xc(%ebp)
  8019ac:	68 08 50 80 00       	push   $0x805008
  8019b1:	e8 a6 ef ff ff       	call   80095c <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8019b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8019bb:	b8 04 00 00 00       	mov    $0x4,%eax
  8019c0:	e8 ba fe ff ff       	call   80187f <fsipc>
}
  8019c5:	c9                   	leave  
  8019c6:	c3                   	ret    

008019c7 <devfile_read>:
{
  8019c7:	f3 0f 1e fb          	endbr32 
  8019cb:	55                   	push   %ebp
  8019cc:	89 e5                	mov    %esp,%ebp
  8019ce:	56                   	push   %esi
  8019cf:	53                   	push   %ebx
  8019d0:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8019d3:	8b 45 08             	mov    0x8(%ebp),%eax
  8019d6:	8b 40 0c             	mov    0xc(%eax),%eax
  8019d9:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8019de:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8019e4:	ba 00 00 00 00       	mov    $0x0,%edx
  8019e9:	b8 03 00 00 00       	mov    $0x3,%eax
  8019ee:	e8 8c fe ff ff       	call   80187f <fsipc>
  8019f3:	89 c3                	mov    %eax,%ebx
  8019f5:	85 c0                	test   %eax,%eax
  8019f7:	78 1f                	js     801a18 <devfile_read+0x51>
	assert(r <= n);
  8019f9:	39 f0                	cmp    %esi,%eax
  8019fb:	77 24                	ja     801a21 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  8019fd:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801a02:	7f 33                	jg     801a37 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801a04:	83 ec 04             	sub    $0x4,%esp
  801a07:	50                   	push   %eax
  801a08:	68 00 50 80 00       	push   $0x805000
  801a0d:	ff 75 0c             	pushl  0xc(%ebp)
  801a10:	e8 47 ef ff ff       	call   80095c <memmove>
	return r;
  801a15:	83 c4 10             	add    $0x10,%esp
}
  801a18:	89 d8                	mov    %ebx,%eax
  801a1a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a1d:	5b                   	pop    %ebx
  801a1e:	5e                   	pop    %esi
  801a1f:	5d                   	pop    %ebp
  801a20:	c3                   	ret    
	assert(r <= n);
  801a21:	68 5c 2a 80 00       	push   $0x802a5c
  801a26:	68 63 2a 80 00       	push   $0x802a63
  801a2b:	6a 7c                	push   $0x7c
  801a2d:	68 78 2a 80 00       	push   $0x802a78
  801a32:	e8 1c e7 ff ff       	call   800153 <_panic>
	assert(r <= PGSIZE);
  801a37:	68 83 2a 80 00       	push   $0x802a83
  801a3c:	68 63 2a 80 00       	push   $0x802a63
  801a41:	6a 7d                	push   $0x7d
  801a43:	68 78 2a 80 00       	push   $0x802a78
  801a48:	e8 06 e7 ff ff       	call   800153 <_panic>

00801a4d <open>:
{
  801a4d:	f3 0f 1e fb          	endbr32 
  801a51:	55                   	push   %ebp
  801a52:	89 e5                	mov    %esp,%ebp
  801a54:	56                   	push   %esi
  801a55:	53                   	push   %ebx
  801a56:	83 ec 1c             	sub    $0x1c,%esp
  801a59:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801a5c:	56                   	push   %esi
  801a5d:	e8 ff ec ff ff       	call   800761 <strlen>
  801a62:	83 c4 10             	add    $0x10,%esp
  801a65:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801a6a:	7f 6c                	jg     801ad8 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801a6c:	83 ec 0c             	sub    $0xc,%esp
  801a6f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a72:	50                   	push   %eax
  801a73:	e8 67 f8 ff ff       	call   8012df <fd_alloc>
  801a78:	89 c3                	mov    %eax,%ebx
  801a7a:	83 c4 10             	add    $0x10,%esp
  801a7d:	85 c0                	test   %eax,%eax
  801a7f:	78 3c                	js     801abd <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801a81:	83 ec 08             	sub    $0x8,%esp
  801a84:	56                   	push   %esi
  801a85:	68 00 50 80 00       	push   $0x805000
  801a8a:	e8 15 ed ff ff       	call   8007a4 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801a8f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a92:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801a97:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a9a:	b8 01 00 00 00       	mov    $0x1,%eax
  801a9f:	e8 db fd ff ff       	call   80187f <fsipc>
  801aa4:	89 c3                	mov    %eax,%ebx
  801aa6:	83 c4 10             	add    $0x10,%esp
  801aa9:	85 c0                	test   %eax,%eax
  801aab:	78 19                	js     801ac6 <open+0x79>
	return fd2num(fd);
  801aad:	83 ec 0c             	sub    $0xc,%esp
  801ab0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ab3:	e8 f4 f7 ff ff       	call   8012ac <fd2num>
  801ab8:	89 c3                	mov    %eax,%ebx
  801aba:	83 c4 10             	add    $0x10,%esp
}
  801abd:	89 d8                	mov    %ebx,%eax
  801abf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ac2:	5b                   	pop    %ebx
  801ac3:	5e                   	pop    %esi
  801ac4:	5d                   	pop    %ebp
  801ac5:	c3                   	ret    
		fd_close(fd, 0);
  801ac6:	83 ec 08             	sub    $0x8,%esp
  801ac9:	6a 00                	push   $0x0
  801acb:	ff 75 f4             	pushl  -0xc(%ebp)
  801ace:	e8 10 f9 ff ff       	call   8013e3 <fd_close>
		return r;
  801ad3:	83 c4 10             	add    $0x10,%esp
  801ad6:	eb e5                	jmp    801abd <open+0x70>
		return -E_BAD_PATH;
  801ad8:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801add:	eb de                	jmp    801abd <open+0x70>

00801adf <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801adf:	f3 0f 1e fb          	endbr32 
  801ae3:	55                   	push   %ebp
  801ae4:	89 e5                	mov    %esp,%ebp
  801ae6:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801ae9:	ba 00 00 00 00       	mov    $0x0,%edx
  801aee:	b8 08 00 00 00       	mov    $0x8,%eax
  801af3:	e8 87 fd ff ff       	call   80187f <fsipc>
}
  801af8:	c9                   	leave  
  801af9:	c3                   	ret    

00801afa <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801afa:	f3 0f 1e fb          	endbr32 
  801afe:	55                   	push   %ebp
  801aff:	89 e5                	mov    %esp,%ebp
  801b01:	56                   	push   %esi
  801b02:	53                   	push   %ebx
  801b03:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801b06:	83 ec 0c             	sub    $0xc,%esp
  801b09:	ff 75 08             	pushl  0x8(%ebp)
  801b0c:	e8 af f7 ff ff       	call   8012c0 <fd2data>
  801b11:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801b13:	83 c4 08             	add    $0x8,%esp
  801b16:	68 8f 2a 80 00       	push   $0x802a8f
  801b1b:	53                   	push   %ebx
  801b1c:	e8 83 ec ff ff       	call   8007a4 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801b21:	8b 46 04             	mov    0x4(%esi),%eax
  801b24:	2b 06                	sub    (%esi),%eax
  801b26:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801b2c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801b33:	00 00 00 
	stat->st_dev = &devpipe;
  801b36:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801b3d:	30 80 00 
	return 0;
}
  801b40:	b8 00 00 00 00       	mov    $0x0,%eax
  801b45:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b48:	5b                   	pop    %ebx
  801b49:	5e                   	pop    %esi
  801b4a:	5d                   	pop    %ebp
  801b4b:	c3                   	ret    

00801b4c <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801b4c:	f3 0f 1e fb          	endbr32 
  801b50:	55                   	push   %ebp
  801b51:	89 e5                	mov    %esp,%ebp
  801b53:	53                   	push   %ebx
  801b54:	83 ec 0c             	sub    $0xc,%esp
  801b57:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801b5a:	53                   	push   %ebx
  801b5b:	6a 00                	push   $0x0
  801b5d:	e8 1c f1 ff ff       	call   800c7e <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801b62:	89 1c 24             	mov    %ebx,(%esp)
  801b65:	e8 56 f7 ff ff       	call   8012c0 <fd2data>
  801b6a:	83 c4 08             	add    $0x8,%esp
  801b6d:	50                   	push   %eax
  801b6e:	6a 00                	push   $0x0
  801b70:	e8 09 f1 ff ff       	call   800c7e <sys_page_unmap>
}
  801b75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b78:	c9                   	leave  
  801b79:	c3                   	ret    

00801b7a <_pipeisclosed>:
{
  801b7a:	55                   	push   %ebp
  801b7b:	89 e5                	mov    %esp,%ebp
  801b7d:	57                   	push   %edi
  801b7e:	56                   	push   %esi
  801b7f:	53                   	push   %ebx
  801b80:	83 ec 1c             	sub    $0x1c,%esp
  801b83:	89 c7                	mov    %eax,%edi
  801b85:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801b87:	a1 08 40 80 00       	mov    0x804008,%eax
  801b8c:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801b8f:	83 ec 0c             	sub    $0xc,%esp
  801b92:	57                   	push   %edi
  801b93:	e8 f0 05 00 00       	call   802188 <pageref>
  801b98:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801b9b:	89 34 24             	mov    %esi,(%esp)
  801b9e:	e8 e5 05 00 00       	call   802188 <pageref>
		nn = thisenv->env_runs;
  801ba3:	8b 15 08 40 80 00    	mov    0x804008,%edx
  801ba9:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801bac:	83 c4 10             	add    $0x10,%esp
  801baf:	39 cb                	cmp    %ecx,%ebx
  801bb1:	74 1b                	je     801bce <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801bb3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801bb6:	75 cf                	jne    801b87 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801bb8:	8b 42 58             	mov    0x58(%edx),%eax
  801bbb:	6a 01                	push   $0x1
  801bbd:	50                   	push   %eax
  801bbe:	53                   	push   %ebx
  801bbf:	68 96 2a 80 00       	push   $0x802a96
  801bc4:	e8 71 e6 ff ff       	call   80023a <cprintf>
  801bc9:	83 c4 10             	add    $0x10,%esp
  801bcc:	eb b9                	jmp    801b87 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801bce:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801bd1:	0f 94 c0             	sete   %al
  801bd4:	0f b6 c0             	movzbl %al,%eax
}
  801bd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bda:	5b                   	pop    %ebx
  801bdb:	5e                   	pop    %esi
  801bdc:	5f                   	pop    %edi
  801bdd:	5d                   	pop    %ebp
  801bde:	c3                   	ret    

00801bdf <devpipe_write>:
{
  801bdf:	f3 0f 1e fb          	endbr32 
  801be3:	55                   	push   %ebp
  801be4:	89 e5                	mov    %esp,%ebp
  801be6:	57                   	push   %edi
  801be7:	56                   	push   %esi
  801be8:	53                   	push   %ebx
  801be9:	83 ec 28             	sub    $0x28,%esp
  801bec:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801bef:	56                   	push   %esi
  801bf0:	e8 cb f6 ff ff       	call   8012c0 <fd2data>
  801bf5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801bf7:	83 c4 10             	add    $0x10,%esp
  801bfa:	bf 00 00 00 00       	mov    $0x0,%edi
  801bff:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801c02:	74 4f                	je     801c53 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801c04:	8b 43 04             	mov    0x4(%ebx),%eax
  801c07:	8b 0b                	mov    (%ebx),%ecx
  801c09:	8d 51 20             	lea    0x20(%ecx),%edx
  801c0c:	39 d0                	cmp    %edx,%eax
  801c0e:	72 14                	jb     801c24 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801c10:	89 da                	mov    %ebx,%edx
  801c12:	89 f0                	mov    %esi,%eax
  801c14:	e8 61 ff ff ff       	call   801b7a <_pipeisclosed>
  801c19:	85 c0                	test   %eax,%eax
  801c1b:	75 3b                	jne    801c58 <devpipe_write+0x79>
			sys_yield();
  801c1d:	e8 df ef ff ff       	call   800c01 <sys_yield>
  801c22:	eb e0                	jmp    801c04 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801c24:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801c27:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801c2b:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801c2e:	89 c2                	mov    %eax,%edx
  801c30:	c1 fa 1f             	sar    $0x1f,%edx
  801c33:	89 d1                	mov    %edx,%ecx
  801c35:	c1 e9 1b             	shr    $0x1b,%ecx
  801c38:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801c3b:	83 e2 1f             	and    $0x1f,%edx
  801c3e:	29 ca                	sub    %ecx,%edx
  801c40:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801c44:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801c48:	83 c0 01             	add    $0x1,%eax
  801c4b:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801c4e:	83 c7 01             	add    $0x1,%edi
  801c51:	eb ac                	jmp    801bff <devpipe_write+0x20>
	return i;
  801c53:	8b 45 10             	mov    0x10(%ebp),%eax
  801c56:	eb 05                	jmp    801c5d <devpipe_write+0x7e>
				return 0;
  801c58:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801c5d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c60:	5b                   	pop    %ebx
  801c61:	5e                   	pop    %esi
  801c62:	5f                   	pop    %edi
  801c63:	5d                   	pop    %ebp
  801c64:	c3                   	ret    

00801c65 <devpipe_read>:
{
  801c65:	f3 0f 1e fb          	endbr32 
  801c69:	55                   	push   %ebp
  801c6a:	89 e5                	mov    %esp,%ebp
  801c6c:	57                   	push   %edi
  801c6d:	56                   	push   %esi
  801c6e:	53                   	push   %ebx
  801c6f:	83 ec 18             	sub    $0x18,%esp
  801c72:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801c75:	57                   	push   %edi
  801c76:	e8 45 f6 ff ff       	call   8012c0 <fd2data>
  801c7b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801c7d:	83 c4 10             	add    $0x10,%esp
  801c80:	be 00 00 00 00       	mov    $0x0,%esi
  801c85:	3b 75 10             	cmp    0x10(%ebp),%esi
  801c88:	75 14                	jne    801c9e <devpipe_read+0x39>
	return i;
  801c8a:	8b 45 10             	mov    0x10(%ebp),%eax
  801c8d:	eb 02                	jmp    801c91 <devpipe_read+0x2c>
				return i;
  801c8f:	89 f0                	mov    %esi,%eax
}
  801c91:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c94:	5b                   	pop    %ebx
  801c95:	5e                   	pop    %esi
  801c96:	5f                   	pop    %edi
  801c97:	5d                   	pop    %ebp
  801c98:	c3                   	ret    
			sys_yield();
  801c99:	e8 63 ef ff ff       	call   800c01 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801c9e:	8b 03                	mov    (%ebx),%eax
  801ca0:	3b 43 04             	cmp    0x4(%ebx),%eax
  801ca3:	75 18                	jne    801cbd <devpipe_read+0x58>
			if (i > 0)
  801ca5:	85 f6                	test   %esi,%esi
  801ca7:	75 e6                	jne    801c8f <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801ca9:	89 da                	mov    %ebx,%edx
  801cab:	89 f8                	mov    %edi,%eax
  801cad:	e8 c8 fe ff ff       	call   801b7a <_pipeisclosed>
  801cb2:	85 c0                	test   %eax,%eax
  801cb4:	74 e3                	je     801c99 <devpipe_read+0x34>
				return 0;
  801cb6:	b8 00 00 00 00       	mov    $0x0,%eax
  801cbb:	eb d4                	jmp    801c91 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801cbd:	99                   	cltd   
  801cbe:	c1 ea 1b             	shr    $0x1b,%edx
  801cc1:	01 d0                	add    %edx,%eax
  801cc3:	83 e0 1f             	and    $0x1f,%eax
  801cc6:	29 d0                	sub    %edx,%eax
  801cc8:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801ccd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cd0:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801cd3:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801cd6:	83 c6 01             	add    $0x1,%esi
  801cd9:	eb aa                	jmp    801c85 <devpipe_read+0x20>

00801cdb <pipe>:
{
  801cdb:	f3 0f 1e fb          	endbr32 
  801cdf:	55                   	push   %ebp
  801ce0:	89 e5                	mov    %esp,%ebp
  801ce2:	56                   	push   %esi
  801ce3:	53                   	push   %ebx
  801ce4:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801ce7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801cea:	50                   	push   %eax
  801ceb:	e8 ef f5 ff ff       	call   8012df <fd_alloc>
  801cf0:	89 c3                	mov    %eax,%ebx
  801cf2:	83 c4 10             	add    $0x10,%esp
  801cf5:	85 c0                	test   %eax,%eax
  801cf7:	0f 88 23 01 00 00    	js     801e20 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801cfd:	83 ec 04             	sub    $0x4,%esp
  801d00:	68 07 04 00 00       	push   $0x407
  801d05:	ff 75 f4             	pushl  -0xc(%ebp)
  801d08:	6a 00                	push   $0x0
  801d0a:	e8 1d ef ff ff       	call   800c2c <sys_page_alloc>
  801d0f:	89 c3                	mov    %eax,%ebx
  801d11:	83 c4 10             	add    $0x10,%esp
  801d14:	85 c0                	test   %eax,%eax
  801d16:	0f 88 04 01 00 00    	js     801e20 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801d1c:	83 ec 0c             	sub    $0xc,%esp
  801d1f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801d22:	50                   	push   %eax
  801d23:	e8 b7 f5 ff ff       	call   8012df <fd_alloc>
  801d28:	89 c3                	mov    %eax,%ebx
  801d2a:	83 c4 10             	add    $0x10,%esp
  801d2d:	85 c0                	test   %eax,%eax
  801d2f:	0f 88 db 00 00 00    	js     801e10 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d35:	83 ec 04             	sub    $0x4,%esp
  801d38:	68 07 04 00 00       	push   $0x407
  801d3d:	ff 75 f0             	pushl  -0x10(%ebp)
  801d40:	6a 00                	push   $0x0
  801d42:	e8 e5 ee ff ff       	call   800c2c <sys_page_alloc>
  801d47:	89 c3                	mov    %eax,%ebx
  801d49:	83 c4 10             	add    $0x10,%esp
  801d4c:	85 c0                	test   %eax,%eax
  801d4e:	0f 88 bc 00 00 00    	js     801e10 <pipe+0x135>
	va = fd2data(fd0);
  801d54:	83 ec 0c             	sub    $0xc,%esp
  801d57:	ff 75 f4             	pushl  -0xc(%ebp)
  801d5a:	e8 61 f5 ff ff       	call   8012c0 <fd2data>
  801d5f:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d61:	83 c4 0c             	add    $0xc,%esp
  801d64:	68 07 04 00 00       	push   $0x407
  801d69:	50                   	push   %eax
  801d6a:	6a 00                	push   $0x0
  801d6c:	e8 bb ee ff ff       	call   800c2c <sys_page_alloc>
  801d71:	89 c3                	mov    %eax,%ebx
  801d73:	83 c4 10             	add    $0x10,%esp
  801d76:	85 c0                	test   %eax,%eax
  801d78:	0f 88 82 00 00 00    	js     801e00 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801d7e:	83 ec 0c             	sub    $0xc,%esp
  801d81:	ff 75 f0             	pushl  -0x10(%ebp)
  801d84:	e8 37 f5 ff ff       	call   8012c0 <fd2data>
  801d89:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801d90:	50                   	push   %eax
  801d91:	6a 00                	push   $0x0
  801d93:	56                   	push   %esi
  801d94:	6a 00                	push   $0x0
  801d96:	e8 b9 ee ff ff       	call   800c54 <sys_page_map>
  801d9b:	89 c3                	mov    %eax,%ebx
  801d9d:	83 c4 20             	add    $0x20,%esp
  801da0:	85 c0                	test   %eax,%eax
  801da2:	78 4e                	js     801df2 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801da4:	a1 20 30 80 00       	mov    0x803020,%eax
  801da9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801dac:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801dae:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801db1:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801db8:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801dbb:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801dbd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801dc0:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801dc7:	83 ec 0c             	sub    $0xc,%esp
  801dca:	ff 75 f4             	pushl  -0xc(%ebp)
  801dcd:	e8 da f4 ff ff       	call   8012ac <fd2num>
  801dd2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801dd5:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801dd7:	83 c4 04             	add    $0x4,%esp
  801dda:	ff 75 f0             	pushl  -0x10(%ebp)
  801ddd:	e8 ca f4 ff ff       	call   8012ac <fd2num>
  801de2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801de5:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801de8:	83 c4 10             	add    $0x10,%esp
  801deb:	bb 00 00 00 00       	mov    $0x0,%ebx
  801df0:	eb 2e                	jmp    801e20 <pipe+0x145>
	sys_page_unmap(0, va);
  801df2:	83 ec 08             	sub    $0x8,%esp
  801df5:	56                   	push   %esi
  801df6:	6a 00                	push   $0x0
  801df8:	e8 81 ee ff ff       	call   800c7e <sys_page_unmap>
  801dfd:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801e00:	83 ec 08             	sub    $0x8,%esp
  801e03:	ff 75 f0             	pushl  -0x10(%ebp)
  801e06:	6a 00                	push   $0x0
  801e08:	e8 71 ee ff ff       	call   800c7e <sys_page_unmap>
  801e0d:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801e10:	83 ec 08             	sub    $0x8,%esp
  801e13:	ff 75 f4             	pushl  -0xc(%ebp)
  801e16:	6a 00                	push   $0x0
  801e18:	e8 61 ee ff ff       	call   800c7e <sys_page_unmap>
  801e1d:	83 c4 10             	add    $0x10,%esp
}
  801e20:	89 d8                	mov    %ebx,%eax
  801e22:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e25:	5b                   	pop    %ebx
  801e26:	5e                   	pop    %esi
  801e27:	5d                   	pop    %ebp
  801e28:	c3                   	ret    

00801e29 <pipeisclosed>:
{
  801e29:	f3 0f 1e fb          	endbr32 
  801e2d:	55                   	push   %ebp
  801e2e:	89 e5                	mov    %esp,%ebp
  801e30:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801e33:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e36:	50                   	push   %eax
  801e37:	ff 75 08             	pushl  0x8(%ebp)
  801e3a:	e8 f6 f4 ff ff       	call   801335 <fd_lookup>
  801e3f:	83 c4 10             	add    $0x10,%esp
  801e42:	85 c0                	test   %eax,%eax
  801e44:	78 18                	js     801e5e <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801e46:	83 ec 0c             	sub    $0xc,%esp
  801e49:	ff 75 f4             	pushl  -0xc(%ebp)
  801e4c:	e8 6f f4 ff ff       	call   8012c0 <fd2data>
  801e51:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801e53:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801e56:	e8 1f fd ff ff       	call   801b7a <_pipeisclosed>
  801e5b:	83 c4 10             	add    $0x10,%esp
}
  801e5e:	c9                   	leave  
  801e5f:	c3                   	ret    

00801e60 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801e60:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801e64:	b8 00 00 00 00       	mov    $0x0,%eax
  801e69:	c3                   	ret    

00801e6a <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801e6a:	f3 0f 1e fb          	endbr32 
  801e6e:	55                   	push   %ebp
  801e6f:	89 e5                	mov    %esp,%ebp
  801e71:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801e74:	68 ae 2a 80 00       	push   $0x802aae
  801e79:	ff 75 0c             	pushl  0xc(%ebp)
  801e7c:	e8 23 e9 ff ff       	call   8007a4 <strcpy>
	return 0;
}
  801e81:	b8 00 00 00 00       	mov    $0x0,%eax
  801e86:	c9                   	leave  
  801e87:	c3                   	ret    

00801e88 <devcons_write>:
{
  801e88:	f3 0f 1e fb          	endbr32 
  801e8c:	55                   	push   %ebp
  801e8d:	89 e5                	mov    %esp,%ebp
  801e8f:	57                   	push   %edi
  801e90:	56                   	push   %esi
  801e91:	53                   	push   %ebx
  801e92:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801e98:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801e9d:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801ea3:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ea6:	73 31                	jae    801ed9 <devcons_write+0x51>
		m = n - tot;
  801ea8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801eab:	29 f3                	sub    %esi,%ebx
  801ead:	83 fb 7f             	cmp    $0x7f,%ebx
  801eb0:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801eb5:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801eb8:	83 ec 04             	sub    $0x4,%esp
  801ebb:	53                   	push   %ebx
  801ebc:	89 f0                	mov    %esi,%eax
  801ebe:	03 45 0c             	add    0xc(%ebp),%eax
  801ec1:	50                   	push   %eax
  801ec2:	57                   	push   %edi
  801ec3:	e8 94 ea ff ff       	call   80095c <memmove>
		sys_cputs(buf, m);
  801ec8:	83 c4 08             	add    $0x8,%esp
  801ecb:	53                   	push   %ebx
  801ecc:	57                   	push   %edi
  801ecd:	e8 8f ec ff ff       	call   800b61 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801ed2:	01 de                	add    %ebx,%esi
  801ed4:	83 c4 10             	add    $0x10,%esp
  801ed7:	eb ca                	jmp    801ea3 <devcons_write+0x1b>
}
  801ed9:	89 f0                	mov    %esi,%eax
  801edb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ede:	5b                   	pop    %ebx
  801edf:	5e                   	pop    %esi
  801ee0:	5f                   	pop    %edi
  801ee1:	5d                   	pop    %ebp
  801ee2:	c3                   	ret    

00801ee3 <devcons_read>:
{
  801ee3:	f3 0f 1e fb          	endbr32 
  801ee7:	55                   	push   %ebp
  801ee8:	89 e5                	mov    %esp,%ebp
  801eea:	83 ec 08             	sub    $0x8,%esp
  801eed:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801ef2:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801ef6:	74 21                	je     801f19 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801ef8:	e8 8e ec ff ff       	call   800b8b <sys_cgetc>
  801efd:	85 c0                	test   %eax,%eax
  801eff:	75 07                	jne    801f08 <devcons_read+0x25>
		sys_yield();
  801f01:	e8 fb ec ff ff       	call   800c01 <sys_yield>
  801f06:	eb f0                	jmp    801ef8 <devcons_read+0x15>
	if (c < 0)
  801f08:	78 0f                	js     801f19 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801f0a:	83 f8 04             	cmp    $0x4,%eax
  801f0d:	74 0c                	je     801f1b <devcons_read+0x38>
	*(char*)vbuf = c;
  801f0f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801f12:	88 02                	mov    %al,(%edx)
	return 1;
  801f14:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801f19:	c9                   	leave  
  801f1a:	c3                   	ret    
		return 0;
  801f1b:	b8 00 00 00 00       	mov    $0x0,%eax
  801f20:	eb f7                	jmp    801f19 <devcons_read+0x36>

00801f22 <cputchar>:
{
  801f22:	f3 0f 1e fb          	endbr32 
  801f26:	55                   	push   %ebp
  801f27:	89 e5                	mov    %esp,%ebp
  801f29:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801f2c:	8b 45 08             	mov    0x8(%ebp),%eax
  801f2f:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801f32:	6a 01                	push   $0x1
  801f34:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f37:	50                   	push   %eax
  801f38:	e8 24 ec ff ff       	call   800b61 <sys_cputs>
}
  801f3d:	83 c4 10             	add    $0x10,%esp
  801f40:	c9                   	leave  
  801f41:	c3                   	ret    

00801f42 <getchar>:
{
  801f42:	f3 0f 1e fb          	endbr32 
  801f46:	55                   	push   %ebp
  801f47:	89 e5                	mov    %esp,%ebp
  801f49:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801f4c:	6a 01                	push   $0x1
  801f4e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801f51:	50                   	push   %eax
  801f52:	6a 00                	push   $0x0
  801f54:	e8 5f f6 ff ff       	call   8015b8 <read>
	if (r < 0)
  801f59:	83 c4 10             	add    $0x10,%esp
  801f5c:	85 c0                	test   %eax,%eax
  801f5e:	78 06                	js     801f66 <getchar+0x24>
	if (r < 1)
  801f60:	74 06                	je     801f68 <getchar+0x26>
	return c;
  801f62:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801f66:	c9                   	leave  
  801f67:	c3                   	ret    
		return -E_EOF;
  801f68:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801f6d:	eb f7                	jmp    801f66 <getchar+0x24>

00801f6f <iscons>:
{
  801f6f:	f3 0f 1e fb          	endbr32 
  801f73:	55                   	push   %ebp
  801f74:	89 e5                	mov    %esp,%ebp
  801f76:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f79:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f7c:	50                   	push   %eax
  801f7d:	ff 75 08             	pushl  0x8(%ebp)
  801f80:	e8 b0 f3 ff ff       	call   801335 <fd_lookup>
  801f85:	83 c4 10             	add    $0x10,%esp
  801f88:	85 c0                	test   %eax,%eax
  801f8a:	78 11                	js     801f9d <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801f8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f8f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801f95:	39 10                	cmp    %edx,(%eax)
  801f97:	0f 94 c0             	sete   %al
  801f9a:	0f b6 c0             	movzbl %al,%eax
}
  801f9d:	c9                   	leave  
  801f9e:	c3                   	ret    

00801f9f <opencons>:
{
  801f9f:	f3 0f 1e fb          	endbr32 
  801fa3:	55                   	push   %ebp
  801fa4:	89 e5                	mov    %esp,%ebp
  801fa6:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801fa9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fac:	50                   	push   %eax
  801fad:	e8 2d f3 ff ff       	call   8012df <fd_alloc>
  801fb2:	83 c4 10             	add    $0x10,%esp
  801fb5:	85 c0                	test   %eax,%eax
  801fb7:	78 3a                	js     801ff3 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801fb9:	83 ec 04             	sub    $0x4,%esp
  801fbc:	68 07 04 00 00       	push   $0x407
  801fc1:	ff 75 f4             	pushl  -0xc(%ebp)
  801fc4:	6a 00                	push   $0x0
  801fc6:	e8 61 ec ff ff       	call   800c2c <sys_page_alloc>
  801fcb:	83 c4 10             	add    $0x10,%esp
  801fce:	85 c0                	test   %eax,%eax
  801fd0:	78 21                	js     801ff3 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801fd2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fd5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801fdb:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801fdd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe0:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801fe7:	83 ec 0c             	sub    $0xc,%esp
  801fea:	50                   	push   %eax
  801feb:	e8 bc f2 ff ff       	call   8012ac <fd2num>
  801ff0:	83 c4 10             	add    $0x10,%esp
}
  801ff3:	c9                   	leave  
  801ff4:	c3                   	ret    

00801ff5 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  801ff5:	f3 0f 1e fb          	endbr32 
  801ff9:	55                   	push   %ebp
  801ffa:	89 e5                	mov    %esp,%ebp
  801ffc:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  801fff:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802006:	74 1c                	je     802024 <set_pgfault_handler+0x2f>
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  802008:	8b 45 08             	mov    0x8(%ebp),%eax
  80200b:	a3 00 60 80 00       	mov    %eax,0x806000

	//Indicarle al kerne que _pgfault_upcall va a ser el manejador de pgfaults de un proceso
	sys_env_set_pgfault_upcall(0, &(_pgfault_upcall));
  802010:	83 ec 08             	sub    $0x8,%esp
  802013:	68 50 20 80 00       	push   $0x802050
  802018:	6a 00                	push   $0x0
  80201a:	e8 d4 ec ff ff       	call   800cf3 <sys_env_set_pgfault_upcall>
}
  80201f:	83 c4 10             	add    $0x10,%esp
  802022:	c9                   	leave  
  802023:	c3                   	ret    
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
  802024:	83 ec 04             	sub    $0x4,%esp
  802027:	6a 02                	push   $0x2
  802029:	68 00 f0 bf ee       	push   $0xeebff000
  80202e:	6a 00                	push   $0x0
  802030:	e8 f7 eb ff ff       	call   800c2c <sys_page_alloc>
  802035:	83 c4 10             	add    $0x10,%esp
  802038:	85 c0                	test   %eax,%eax
  80203a:	79 cc                	jns    802008 <set_pgfault_handler+0x13>
  80203c:	83 ec 04             	sub    $0x4,%esp
  80203f:	68 ba 2a 80 00       	push   $0x802aba
  802044:	6a 20                	push   $0x20
  802046:	68 d5 2a 80 00       	push   $0x802ad5
  80204b:	e8 03 e1 ff ff       	call   800153 <_panic>

00802050 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802050:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802051:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802056:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802058:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 40(%esp), %eax
  80205b:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	
  80205f:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  802063:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, (%ebx)
  802066:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 48(%esp)
  802068:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  80206c:	83 c4 08             	add    $0x8,%esp
	popal
  80206f:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  802070:	83 c4 04             	add    $0x4,%esp
	popfl
  802073:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  802074:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  802077:	c3                   	ret    

00802078 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802078:	f3 0f 1e fb          	endbr32 
  80207c:	55                   	push   %ebp
  80207d:	89 e5                	mov    %esp,%ebp
  80207f:	56                   	push   %esi
  802080:	53                   	push   %ebx
  802081:	8b 75 08             	mov    0x8(%ebp),%esi
  802084:	8b 45 0c             	mov    0xc(%ebp),%eax
  802087:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  80208a:	85 c0                	test   %eax,%eax
  80208c:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802091:	0f 44 c2             	cmove  %edx,%eax
  802094:	83 ec 0c             	sub    $0xc,%esp
  802097:	50                   	push   %eax
  802098:	e8 a6 ec ff ff       	call   800d43 <sys_ipc_recv>

	if (from_env_store != NULL)
  80209d:	83 c4 10             	add    $0x10,%esp
  8020a0:	85 f6                	test   %esi,%esi
  8020a2:	74 15                	je     8020b9 <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  8020a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8020a9:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8020ac:	74 09                	je     8020b7 <ipc_recv+0x3f>
  8020ae:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8020b4:	8b 52 74             	mov    0x74(%edx),%edx
  8020b7:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  8020b9:	85 db                	test   %ebx,%ebx
  8020bb:	74 15                	je     8020d2 <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  8020bd:	ba 00 00 00 00       	mov    $0x0,%edx
  8020c2:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8020c5:	74 09                	je     8020d0 <ipc_recv+0x58>
  8020c7:	8b 15 08 40 80 00    	mov    0x804008,%edx
  8020cd:	8b 52 78             	mov    0x78(%edx),%edx
  8020d0:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  8020d2:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8020d5:	74 08                	je     8020df <ipc_recv+0x67>
  8020d7:	a1 08 40 80 00       	mov    0x804008,%eax
  8020dc:	8b 40 70             	mov    0x70(%eax),%eax
}
  8020df:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8020e2:	5b                   	pop    %ebx
  8020e3:	5e                   	pop    %esi
  8020e4:	5d                   	pop    %ebp
  8020e5:	c3                   	ret    

008020e6 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8020e6:	f3 0f 1e fb          	endbr32 
  8020ea:	55                   	push   %ebp
  8020eb:	89 e5                	mov    %esp,%ebp
  8020ed:	57                   	push   %edi
  8020ee:	56                   	push   %esi
  8020ef:	53                   	push   %ebx
  8020f0:	83 ec 0c             	sub    $0xc,%esp
  8020f3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8020f6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8020f9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020fc:	eb 1f                	jmp    80211d <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  8020fe:	6a 00                	push   $0x0
  802100:	68 00 00 c0 ee       	push   $0xeec00000
  802105:	56                   	push   %esi
  802106:	57                   	push   %edi
  802107:	e8 0e ec ff ff       	call   800d1a <sys_ipc_try_send>
  80210c:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  80210f:	85 c0                	test   %eax,%eax
  802111:	74 30                	je     802143 <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  802113:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802116:	75 19                	jne    802131 <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  802118:	e8 e4 ea ff ff       	call   800c01 <sys_yield>
		if (pg != NULL) {
  80211d:	85 db                	test   %ebx,%ebx
  80211f:	74 dd                	je     8020fe <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  802121:	ff 75 14             	pushl  0x14(%ebp)
  802124:	53                   	push   %ebx
  802125:	56                   	push   %esi
  802126:	57                   	push   %edi
  802127:	e8 ee eb ff ff       	call   800d1a <sys_ipc_try_send>
  80212c:	83 c4 10             	add    $0x10,%esp
  80212f:	eb de                	jmp    80210f <ipc_send+0x29>
			panic("ipc_send: %d", res);
  802131:	50                   	push   %eax
  802132:	68 e3 2a 80 00       	push   $0x802ae3
  802137:	6a 3e                	push   $0x3e
  802139:	68 f0 2a 80 00       	push   $0x802af0
  80213e:	e8 10 e0 ff ff       	call   800153 <_panic>
	}
}
  802143:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802146:	5b                   	pop    %ebx
  802147:	5e                   	pop    %esi
  802148:	5f                   	pop    %edi
  802149:	5d                   	pop    %ebp
  80214a:	c3                   	ret    

0080214b <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80214b:	f3 0f 1e fb          	endbr32 
  80214f:	55                   	push   %ebp
  802150:	89 e5                	mov    %esp,%ebp
  802152:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802155:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80215a:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80215d:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  802163:	8b 52 50             	mov    0x50(%edx),%edx
  802166:	39 ca                	cmp    %ecx,%edx
  802168:	74 11                	je     80217b <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  80216a:	83 c0 01             	add    $0x1,%eax
  80216d:	3d 00 04 00 00       	cmp    $0x400,%eax
  802172:	75 e6                	jne    80215a <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802174:	b8 00 00 00 00       	mov    $0x0,%eax
  802179:	eb 0b                	jmp    802186 <ipc_find_env+0x3b>
			return envs[i].env_id;
  80217b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80217e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802183:	8b 40 48             	mov    0x48(%eax),%eax
}
  802186:	5d                   	pop    %ebp
  802187:	c3                   	ret    

00802188 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802188:	f3 0f 1e fb          	endbr32 
  80218c:	55                   	push   %ebp
  80218d:	89 e5                	mov    %esp,%ebp
  80218f:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802192:	89 c2                	mov    %eax,%edx
  802194:	c1 ea 16             	shr    $0x16,%edx
  802197:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80219e:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8021a3:	f6 c1 01             	test   $0x1,%cl
  8021a6:	74 1c                	je     8021c4 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8021a8:	c1 e8 0c             	shr    $0xc,%eax
  8021ab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8021b2:	a8 01                	test   $0x1,%al
  8021b4:	74 0e                	je     8021c4 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8021b6:	c1 e8 0c             	shr    $0xc,%eax
  8021b9:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  8021c0:	ef 
  8021c1:	0f b7 d2             	movzwl %dx,%edx
}
  8021c4:	89 d0                	mov    %edx,%eax
  8021c6:	5d                   	pop    %ebp
  8021c7:	c3                   	ret    
  8021c8:	66 90                	xchg   %ax,%ax
  8021ca:	66 90                	xchg   %ax,%ax
  8021cc:	66 90                	xchg   %ax,%ax
  8021ce:	66 90                	xchg   %ax,%ax

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
