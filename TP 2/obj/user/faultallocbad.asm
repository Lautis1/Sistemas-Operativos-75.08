
obj/user/faultallocbad.debug:     formato del fichero elf32-i386


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
  80002c:	e8 8c 00 00 00       	call   8000bd <libmain>
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
  80003a:	53                   	push   %ebx
  80003b:	83 ec 0c             	sub    $0xc,%esp
	int r;
	void *addr = (void*)utf->utf_fault_va;
  80003e:	8b 45 08             	mov    0x8(%ebp),%eax
  800041:	8b 18                	mov    (%eax),%ebx

	cprintf("fault %x\n", addr);
  800043:	53                   	push   %ebx
  800044:	68 c0 1e 80 00       	push   $0x801ec0
  800049:	e8 c2 01 00 00       	call   800210 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004e:	83 c4 0c             	add    $0xc,%esp
  800051:	6a 07                	push   $0x7
  800053:	89 d8                	mov    %ebx,%eax
  800055:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005a:	50                   	push   %eax
  80005b:	6a 00                	push   $0x0
  80005d:	e8 a0 0b 00 00       	call   800c02 <sys_page_alloc>
  800062:	83 c4 10             	add    $0x10,%esp
  800065:	85 c0                	test   %eax,%eax
  800067:	78 16                	js     80007f <handler+0x4c>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800069:	53                   	push   %ebx
  80006a:	68 0c 1f 80 00       	push   $0x801f0c
  80006f:	6a 64                	push   $0x64
  800071:	53                   	push   %ebx
  800072:	e8 a2 06 00 00       	call   800719 <snprintf>
}
  800077:	83 c4 10             	add    $0x10,%esp
  80007a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007d:	c9                   	leave  
  80007e:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007f:	83 ec 0c             	sub    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	53                   	push   %ebx
  800084:	68 e0 1e 80 00       	push   $0x801ee0
  800089:	6a 0f                	push   $0xf
  80008b:	68 ca 1e 80 00       	push   $0x801eca
  800090:	e8 94 00 00 00       	call   800129 <_panic>

00800095 <umain>:

void
umain(int argc, char **argv)
{
  800095:	f3 0f 1e fb          	endbr32 
  800099:	55                   	push   %ebp
  80009a:	89 e5                	mov    %esp,%ebp
  80009c:	83 ec 14             	sub    $0x14,%esp
	set_pgfault_handler(handler);
  80009f:	68 33 00 80 00       	push   $0x800033
  8000a4:	e8 96 0c 00 00       	call   800d3f <set_pgfault_handler>
	sys_cputs((char*)0xDEADBEEF, 4);
  8000a9:	83 c4 08             	add    $0x8,%esp
  8000ac:	6a 04                	push   $0x4
  8000ae:	68 ef be ad de       	push   $0xdeadbeef
  8000b3:	e8 7f 0a 00 00       	call   800b37 <sys_cputs>
}
  8000b8:	83 c4 10             	add    $0x10,%esp
  8000bb:	c9                   	leave  
  8000bc:	c3                   	ret    

008000bd <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000bd:	f3 0f 1e fb          	endbr32 
  8000c1:	55                   	push   %ebp
  8000c2:	89 e5                	mov    %esp,%ebp
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
  8000c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000c9:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8000cc:	e8 de 0a 00 00       	call   800baf <sys_getenvid>
	if (id >= 0)
  8000d1:	85 c0                	test   %eax,%eax
  8000d3:	78 12                	js     8000e7 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8000d5:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000da:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000dd:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000e2:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000e7:	85 db                	test   %ebx,%ebx
  8000e9:	7e 07                	jle    8000f2 <libmain+0x35>
		binaryname = argv[0];
  8000eb:	8b 06                	mov    (%esi),%eax
  8000ed:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000f2:	83 ec 08             	sub    $0x8,%esp
  8000f5:	56                   	push   %esi
  8000f6:	53                   	push   %ebx
  8000f7:	e8 99 ff ff ff       	call   800095 <umain>

	// exit gracefully
	exit();
  8000fc:	e8 0a 00 00 00       	call   80010b <exit>
}
  800101:	83 c4 10             	add    $0x10,%esp
  800104:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800107:	5b                   	pop    %ebx
  800108:	5e                   	pop    %esi
  800109:	5d                   	pop    %ebp
  80010a:	c3                   	ret    

0080010b <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80010b:	f3 0f 1e fb          	endbr32 
  80010f:	55                   	push   %ebp
  800110:	89 e5                	mov    %esp,%ebp
  800112:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800115:	e8 9b 0e 00 00       	call   800fb5 <close_all>
	sys_env_destroy(0);
  80011a:	83 ec 0c             	sub    $0xc,%esp
  80011d:	6a 00                	push   $0x0
  80011f:	e8 65 0a 00 00       	call   800b89 <sys_env_destroy>
}
  800124:	83 c4 10             	add    $0x10,%esp
  800127:	c9                   	leave  
  800128:	c3                   	ret    

00800129 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800129:	f3 0f 1e fb          	endbr32 
  80012d:	55                   	push   %ebp
  80012e:	89 e5                	mov    %esp,%ebp
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800132:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800135:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80013b:	e8 6f 0a 00 00       	call   800baf <sys_getenvid>
  800140:	83 ec 0c             	sub    $0xc,%esp
  800143:	ff 75 0c             	pushl  0xc(%ebp)
  800146:	ff 75 08             	pushl  0x8(%ebp)
  800149:	56                   	push   %esi
  80014a:	50                   	push   %eax
  80014b:	68 38 1f 80 00       	push   $0x801f38
  800150:	e8 bb 00 00 00       	call   800210 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800155:	83 c4 18             	add    $0x18,%esp
  800158:	53                   	push   %ebx
  800159:	ff 75 10             	pushl  0x10(%ebp)
  80015c:	e8 5a 00 00 00       	call   8001bb <vcprintf>
	cprintf("\n");
  800161:	c7 04 24 8b 23 80 00 	movl   $0x80238b,(%esp)
  800168:	e8 a3 00 00 00       	call   800210 <cprintf>
  80016d:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800170:	cc                   	int3   
  800171:	eb fd                	jmp    800170 <_panic+0x47>

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
  800276:	e8 e5 19 00 00       	call   801c60 <__udivdi3>
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
  8002b4:	e8 b7 1a 00 00       	call   801d70 <__umoddi3>
  8002b9:	83 c4 14             	add    $0x14,%esp
  8002bc:	0f be 80 5b 1f 80 00 	movsbl 0x801f5b(%eax),%eax
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
  8003c3:	3e ff 24 85 a0 20 80 	notrack jmp *0x8020a0(,%eax,4)
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
  800490:	8b 14 85 00 22 80 00 	mov    0x802200(,%eax,4),%edx
  800497:	85 d2                	test   %edx,%edx
  800499:	74 15                	je     8004b0 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  80049b:	52                   	push   %edx
  80049c:	68 59 23 80 00       	push   $0x802359
  8004a1:	56                   	push   %esi
  8004a2:	53                   	push   %ebx
  8004a3:	e8 aa fe ff ff       	call   800352 <printfmt>
  8004a8:	83 c4 10             	add    $0x10,%esp
  8004ab:	e9 61 01 00 00       	jmp    800611 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8004b0:	50                   	push   %eax
  8004b1:	68 73 1f 80 00       	push   $0x801f73
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
  8004d2:	b8 6c 1f 80 00       	mov    $0x801f6c,%eax
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
  800b26:	68 5f 22 80 00       	push   $0x80225f
  800b2b:	6a 23                	push   $0x23
  800b2d:	68 7c 22 80 00       	push   $0x80227c
  800b32:	e8 f2 f5 ff ff       	call   800129 <_panic>

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

00800d3f <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d3f:	f3 0f 1e fb          	endbr32 
  800d43:	55                   	push   %ebp
  800d44:	89 e5                	mov    %esp,%ebp
  800d46:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d49:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d50:	74 1c                	je     800d6e <set_pgfault_handler+0x2f>
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d52:	8b 45 08             	mov    0x8(%ebp),%eax
  800d55:	a3 08 40 80 00       	mov    %eax,0x804008

	//Indicarle al kerne que _pgfault_upcall va a ser el manejador de pgfaults de un proceso
	sys_env_set_pgfault_upcall(0, &(_pgfault_upcall));
  800d5a:	83 ec 08             	sub    $0x8,%esp
  800d5d:	68 9a 0d 80 00       	push   $0x800d9a
  800d62:	6a 00                	push   $0x0
  800d64:	e8 60 ff ff ff       	call   800cc9 <sys_env_set_pgfault_upcall>
}
  800d69:	83 c4 10             	add    $0x10,%esp
  800d6c:	c9                   	leave  
  800d6d:	c3                   	ret    
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
  800d6e:	83 ec 04             	sub    $0x4,%esp
  800d71:	6a 02                	push   $0x2
  800d73:	68 00 f0 bf ee       	push   $0xeebff000
  800d78:	6a 00                	push   $0x0
  800d7a:	e8 83 fe ff ff       	call   800c02 <sys_page_alloc>
  800d7f:	83 c4 10             	add    $0x10,%esp
  800d82:	85 c0                	test   %eax,%eax
  800d84:	79 cc                	jns    800d52 <set_pgfault_handler+0x13>
  800d86:	83 ec 04             	sub    $0x4,%esp
  800d89:	68 8a 22 80 00       	push   $0x80228a
  800d8e:	6a 20                	push   $0x20
  800d90:	68 a5 22 80 00       	push   $0x8022a5
  800d95:	e8 8f f3 ff ff       	call   800129 <_panic>

00800d9a <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800d9a:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800d9b:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800da0:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800da2:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 40(%esp), %eax
  800da5:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	
  800da9:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  800dad:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, (%ebx)
  800db0:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 48(%esp)
  800db2:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800db6:	83 c4 08             	add    $0x8,%esp
	popal
  800db9:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800dba:	83 c4 04             	add    $0x4,%esp
	popfl
  800dbd:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  800dbe:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  800dc1:	c3                   	ret    

00800dc2 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dc2:	f3 0f 1e fb          	endbr32 
  800dc6:	55                   	push   %ebp
  800dc7:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dc9:	8b 45 08             	mov    0x8(%ebp),%eax
  800dcc:	05 00 00 00 30       	add    $0x30000000,%eax
  800dd1:	c1 e8 0c             	shr    $0xc,%eax
}
  800dd4:	5d                   	pop    %ebp
  800dd5:	c3                   	ret    

00800dd6 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dd6:	f3 0f 1e fb          	endbr32 
  800dda:	55                   	push   %ebp
  800ddb:	89 e5                	mov    %esp,%ebp
  800ddd:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800de0:	ff 75 08             	pushl  0x8(%ebp)
  800de3:	e8 da ff ff ff       	call   800dc2 <fd2num>
  800de8:	83 c4 10             	add    $0x10,%esp
  800deb:	c1 e0 0c             	shl    $0xc,%eax
  800dee:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800df3:	c9                   	leave  
  800df4:	c3                   	ret    

00800df5 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800df5:	f3 0f 1e fb          	endbr32 
  800df9:	55                   	push   %ebp
  800dfa:	89 e5                	mov    %esp,%ebp
  800dfc:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e01:	89 c2                	mov    %eax,%edx
  800e03:	c1 ea 16             	shr    $0x16,%edx
  800e06:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e0d:	f6 c2 01             	test   $0x1,%dl
  800e10:	74 2d                	je     800e3f <fd_alloc+0x4a>
  800e12:	89 c2                	mov    %eax,%edx
  800e14:	c1 ea 0c             	shr    $0xc,%edx
  800e17:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e1e:	f6 c2 01             	test   $0x1,%dl
  800e21:	74 1c                	je     800e3f <fd_alloc+0x4a>
  800e23:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800e28:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e2d:	75 d2                	jne    800e01 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800e32:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800e38:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800e3d:	eb 0a                	jmp    800e49 <fd_alloc+0x54>
			*fd_store = fd;
  800e3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e42:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e44:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e49:	5d                   	pop    %ebp
  800e4a:	c3                   	ret    

00800e4b <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e4b:	f3 0f 1e fb          	endbr32 
  800e4f:	55                   	push   %ebp
  800e50:	89 e5                	mov    %esp,%ebp
  800e52:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e55:	83 f8 1f             	cmp    $0x1f,%eax
  800e58:	77 30                	ja     800e8a <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e5a:	c1 e0 0c             	shl    $0xc,%eax
  800e5d:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e62:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e68:	f6 c2 01             	test   $0x1,%dl
  800e6b:	74 24                	je     800e91 <fd_lookup+0x46>
  800e6d:	89 c2                	mov    %eax,%edx
  800e6f:	c1 ea 0c             	shr    $0xc,%edx
  800e72:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e79:	f6 c2 01             	test   $0x1,%dl
  800e7c:	74 1a                	je     800e98 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e7e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e81:	89 02                	mov    %eax,(%edx)
	return 0;
  800e83:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e88:	5d                   	pop    %ebp
  800e89:	c3                   	ret    
		return -E_INVAL;
  800e8a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e8f:	eb f7                	jmp    800e88 <fd_lookup+0x3d>
		return -E_INVAL;
  800e91:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e96:	eb f0                	jmp    800e88 <fd_lookup+0x3d>
  800e98:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e9d:	eb e9                	jmp    800e88 <fd_lookup+0x3d>

00800e9f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e9f:	f3 0f 1e fb          	endbr32 
  800ea3:	55                   	push   %ebp
  800ea4:	89 e5                	mov    %esp,%ebp
  800ea6:	83 ec 08             	sub    $0x8,%esp
  800ea9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eac:	ba 30 23 80 00       	mov    $0x802330,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800eb1:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800eb6:	39 08                	cmp    %ecx,(%eax)
  800eb8:	74 33                	je     800eed <dev_lookup+0x4e>
  800eba:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800ebd:	8b 02                	mov    (%edx),%eax
  800ebf:	85 c0                	test   %eax,%eax
  800ec1:	75 f3                	jne    800eb6 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ec3:	a1 04 40 80 00       	mov    0x804004,%eax
  800ec8:	8b 40 48             	mov    0x48(%eax),%eax
  800ecb:	83 ec 04             	sub    $0x4,%esp
  800ece:	51                   	push   %ecx
  800ecf:	50                   	push   %eax
  800ed0:	68 b4 22 80 00       	push   $0x8022b4
  800ed5:	e8 36 f3 ff ff       	call   800210 <cprintf>
	*dev = 0;
  800eda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800edd:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ee3:	83 c4 10             	add    $0x10,%esp
  800ee6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800eeb:	c9                   	leave  
  800eec:	c3                   	ret    
			*dev = devtab[i];
  800eed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ef0:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ef2:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef7:	eb f2                	jmp    800eeb <dev_lookup+0x4c>

00800ef9 <fd_close>:
{
  800ef9:	f3 0f 1e fb          	endbr32 
  800efd:	55                   	push   %ebp
  800efe:	89 e5                	mov    %esp,%ebp
  800f00:	57                   	push   %edi
  800f01:	56                   	push   %esi
  800f02:	53                   	push   %ebx
  800f03:	83 ec 28             	sub    $0x28,%esp
  800f06:	8b 75 08             	mov    0x8(%ebp),%esi
  800f09:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f0c:	56                   	push   %esi
  800f0d:	e8 b0 fe ff ff       	call   800dc2 <fd2num>
  800f12:	83 c4 08             	add    $0x8,%esp
  800f15:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800f18:	52                   	push   %edx
  800f19:	50                   	push   %eax
  800f1a:	e8 2c ff ff ff       	call   800e4b <fd_lookup>
  800f1f:	89 c3                	mov    %eax,%ebx
  800f21:	83 c4 10             	add    $0x10,%esp
  800f24:	85 c0                	test   %eax,%eax
  800f26:	78 05                	js     800f2d <fd_close+0x34>
	    || fd != fd2)
  800f28:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f2b:	74 16                	je     800f43 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800f2d:	89 f8                	mov    %edi,%eax
  800f2f:	84 c0                	test   %al,%al
  800f31:	b8 00 00 00 00       	mov    $0x0,%eax
  800f36:	0f 44 d8             	cmove  %eax,%ebx
}
  800f39:	89 d8                	mov    %ebx,%eax
  800f3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f3e:	5b                   	pop    %ebx
  800f3f:	5e                   	pop    %esi
  800f40:	5f                   	pop    %edi
  800f41:	5d                   	pop    %ebp
  800f42:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f43:	83 ec 08             	sub    $0x8,%esp
  800f46:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f49:	50                   	push   %eax
  800f4a:	ff 36                	pushl  (%esi)
  800f4c:	e8 4e ff ff ff       	call   800e9f <dev_lookup>
  800f51:	89 c3                	mov    %eax,%ebx
  800f53:	83 c4 10             	add    $0x10,%esp
  800f56:	85 c0                	test   %eax,%eax
  800f58:	78 1a                	js     800f74 <fd_close+0x7b>
		if (dev->dev_close)
  800f5a:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f5d:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f60:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f65:	85 c0                	test   %eax,%eax
  800f67:	74 0b                	je     800f74 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800f69:	83 ec 0c             	sub    $0xc,%esp
  800f6c:	56                   	push   %esi
  800f6d:	ff d0                	call   *%eax
  800f6f:	89 c3                	mov    %eax,%ebx
  800f71:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f74:	83 ec 08             	sub    $0x8,%esp
  800f77:	56                   	push   %esi
  800f78:	6a 00                	push   $0x0
  800f7a:	e8 d5 fc ff ff       	call   800c54 <sys_page_unmap>
	return r;
  800f7f:	83 c4 10             	add    $0x10,%esp
  800f82:	eb b5                	jmp    800f39 <fd_close+0x40>

00800f84 <close>:

int
close(int fdnum)
{
  800f84:	f3 0f 1e fb          	endbr32 
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f91:	50                   	push   %eax
  800f92:	ff 75 08             	pushl  0x8(%ebp)
  800f95:	e8 b1 fe ff ff       	call   800e4b <fd_lookup>
  800f9a:	83 c4 10             	add    $0x10,%esp
  800f9d:	85 c0                	test   %eax,%eax
  800f9f:	79 02                	jns    800fa3 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800fa1:	c9                   	leave  
  800fa2:	c3                   	ret    
		return fd_close(fd, 1);
  800fa3:	83 ec 08             	sub    $0x8,%esp
  800fa6:	6a 01                	push   $0x1
  800fa8:	ff 75 f4             	pushl  -0xc(%ebp)
  800fab:	e8 49 ff ff ff       	call   800ef9 <fd_close>
  800fb0:	83 c4 10             	add    $0x10,%esp
  800fb3:	eb ec                	jmp    800fa1 <close+0x1d>

00800fb5 <close_all>:

void
close_all(void)
{
  800fb5:	f3 0f 1e fb          	endbr32 
  800fb9:	55                   	push   %ebp
  800fba:	89 e5                	mov    %esp,%ebp
  800fbc:	53                   	push   %ebx
  800fbd:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fc0:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fc5:	83 ec 0c             	sub    $0xc,%esp
  800fc8:	53                   	push   %ebx
  800fc9:	e8 b6 ff ff ff       	call   800f84 <close>
	for (i = 0; i < MAXFD; i++)
  800fce:	83 c3 01             	add    $0x1,%ebx
  800fd1:	83 c4 10             	add    $0x10,%esp
  800fd4:	83 fb 20             	cmp    $0x20,%ebx
  800fd7:	75 ec                	jne    800fc5 <close_all+0x10>
}
  800fd9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fdc:	c9                   	leave  
  800fdd:	c3                   	ret    

00800fde <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fde:	f3 0f 1e fb          	endbr32 
  800fe2:	55                   	push   %ebp
  800fe3:	89 e5                	mov    %esp,%ebp
  800fe5:	57                   	push   %edi
  800fe6:	56                   	push   %esi
  800fe7:	53                   	push   %ebx
  800fe8:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800feb:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fee:	50                   	push   %eax
  800fef:	ff 75 08             	pushl  0x8(%ebp)
  800ff2:	e8 54 fe ff ff       	call   800e4b <fd_lookup>
  800ff7:	89 c3                	mov    %eax,%ebx
  800ff9:	83 c4 10             	add    $0x10,%esp
  800ffc:	85 c0                	test   %eax,%eax
  800ffe:	0f 88 81 00 00 00    	js     801085 <dup+0xa7>
		return r;
	close(newfdnum);
  801004:	83 ec 0c             	sub    $0xc,%esp
  801007:	ff 75 0c             	pushl  0xc(%ebp)
  80100a:	e8 75 ff ff ff       	call   800f84 <close>

	newfd = INDEX2FD(newfdnum);
  80100f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801012:	c1 e6 0c             	shl    $0xc,%esi
  801015:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80101b:	83 c4 04             	add    $0x4,%esp
  80101e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801021:	e8 b0 fd ff ff       	call   800dd6 <fd2data>
  801026:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801028:	89 34 24             	mov    %esi,(%esp)
  80102b:	e8 a6 fd ff ff       	call   800dd6 <fd2data>
  801030:	83 c4 10             	add    $0x10,%esp
  801033:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801035:	89 d8                	mov    %ebx,%eax
  801037:	c1 e8 16             	shr    $0x16,%eax
  80103a:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801041:	a8 01                	test   $0x1,%al
  801043:	74 11                	je     801056 <dup+0x78>
  801045:	89 d8                	mov    %ebx,%eax
  801047:	c1 e8 0c             	shr    $0xc,%eax
  80104a:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801051:	f6 c2 01             	test   $0x1,%dl
  801054:	75 39                	jne    80108f <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801056:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801059:	89 d0                	mov    %edx,%eax
  80105b:	c1 e8 0c             	shr    $0xc,%eax
  80105e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801065:	83 ec 0c             	sub    $0xc,%esp
  801068:	25 07 0e 00 00       	and    $0xe07,%eax
  80106d:	50                   	push   %eax
  80106e:	56                   	push   %esi
  80106f:	6a 00                	push   $0x0
  801071:	52                   	push   %edx
  801072:	6a 00                	push   $0x0
  801074:	e8 b1 fb ff ff       	call   800c2a <sys_page_map>
  801079:	89 c3                	mov    %eax,%ebx
  80107b:	83 c4 20             	add    $0x20,%esp
  80107e:	85 c0                	test   %eax,%eax
  801080:	78 31                	js     8010b3 <dup+0xd5>
		goto err;

	return newfdnum;
  801082:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801085:	89 d8                	mov    %ebx,%eax
  801087:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80108a:	5b                   	pop    %ebx
  80108b:	5e                   	pop    %esi
  80108c:	5f                   	pop    %edi
  80108d:	5d                   	pop    %ebp
  80108e:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80108f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801096:	83 ec 0c             	sub    $0xc,%esp
  801099:	25 07 0e 00 00       	and    $0xe07,%eax
  80109e:	50                   	push   %eax
  80109f:	57                   	push   %edi
  8010a0:	6a 00                	push   $0x0
  8010a2:	53                   	push   %ebx
  8010a3:	6a 00                	push   $0x0
  8010a5:	e8 80 fb ff ff       	call   800c2a <sys_page_map>
  8010aa:	89 c3                	mov    %eax,%ebx
  8010ac:	83 c4 20             	add    $0x20,%esp
  8010af:	85 c0                	test   %eax,%eax
  8010b1:	79 a3                	jns    801056 <dup+0x78>
	sys_page_unmap(0, newfd);
  8010b3:	83 ec 08             	sub    $0x8,%esp
  8010b6:	56                   	push   %esi
  8010b7:	6a 00                	push   $0x0
  8010b9:	e8 96 fb ff ff       	call   800c54 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010be:	83 c4 08             	add    $0x8,%esp
  8010c1:	57                   	push   %edi
  8010c2:	6a 00                	push   $0x0
  8010c4:	e8 8b fb ff ff       	call   800c54 <sys_page_unmap>
	return r;
  8010c9:	83 c4 10             	add    $0x10,%esp
  8010cc:	eb b7                	jmp    801085 <dup+0xa7>

008010ce <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010ce:	f3 0f 1e fb          	endbr32 
  8010d2:	55                   	push   %ebp
  8010d3:	89 e5                	mov    %esp,%ebp
  8010d5:	53                   	push   %ebx
  8010d6:	83 ec 1c             	sub    $0x1c,%esp
  8010d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010dc:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010df:	50                   	push   %eax
  8010e0:	53                   	push   %ebx
  8010e1:	e8 65 fd ff ff       	call   800e4b <fd_lookup>
  8010e6:	83 c4 10             	add    $0x10,%esp
  8010e9:	85 c0                	test   %eax,%eax
  8010eb:	78 3f                	js     80112c <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010ed:	83 ec 08             	sub    $0x8,%esp
  8010f0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010f3:	50                   	push   %eax
  8010f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010f7:	ff 30                	pushl  (%eax)
  8010f9:	e8 a1 fd ff ff       	call   800e9f <dev_lookup>
  8010fe:	83 c4 10             	add    $0x10,%esp
  801101:	85 c0                	test   %eax,%eax
  801103:	78 27                	js     80112c <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801105:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801108:	8b 42 08             	mov    0x8(%edx),%eax
  80110b:	83 e0 03             	and    $0x3,%eax
  80110e:	83 f8 01             	cmp    $0x1,%eax
  801111:	74 1e                	je     801131 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801113:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801116:	8b 40 08             	mov    0x8(%eax),%eax
  801119:	85 c0                	test   %eax,%eax
  80111b:	74 35                	je     801152 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80111d:	83 ec 04             	sub    $0x4,%esp
  801120:	ff 75 10             	pushl  0x10(%ebp)
  801123:	ff 75 0c             	pushl  0xc(%ebp)
  801126:	52                   	push   %edx
  801127:	ff d0                	call   *%eax
  801129:	83 c4 10             	add    $0x10,%esp
}
  80112c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80112f:	c9                   	leave  
  801130:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801131:	a1 04 40 80 00       	mov    0x804004,%eax
  801136:	8b 40 48             	mov    0x48(%eax),%eax
  801139:	83 ec 04             	sub    $0x4,%esp
  80113c:	53                   	push   %ebx
  80113d:	50                   	push   %eax
  80113e:	68 f5 22 80 00       	push   $0x8022f5
  801143:	e8 c8 f0 ff ff       	call   800210 <cprintf>
		return -E_INVAL;
  801148:	83 c4 10             	add    $0x10,%esp
  80114b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801150:	eb da                	jmp    80112c <read+0x5e>
		return -E_NOT_SUPP;
  801152:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801157:	eb d3                	jmp    80112c <read+0x5e>

00801159 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801159:	f3 0f 1e fb          	endbr32 
  80115d:	55                   	push   %ebp
  80115e:	89 e5                	mov    %esp,%ebp
  801160:	57                   	push   %edi
  801161:	56                   	push   %esi
  801162:	53                   	push   %ebx
  801163:	83 ec 0c             	sub    $0xc,%esp
  801166:	8b 7d 08             	mov    0x8(%ebp),%edi
  801169:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80116c:	bb 00 00 00 00       	mov    $0x0,%ebx
  801171:	eb 02                	jmp    801175 <readn+0x1c>
  801173:	01 c3                	add    %eax,%ebx
  801175:	39 f3                	cmp    %esi,%ebx
  801177:	73 21                	jae    80119a <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801179:	83 ec 04             	sub    $0x4,%esp
  80117c:	89 f0                	mov    %esi,%eax
  80117e:	29 d8                	sub    %ebx,%eax
  801180:	50                   	push   %eax
  801181:	89 d8                	mov    %ebx,%eax
  801183:	03 45 0c             	add    0xc(%ebp),%eax
  801186:	50                   	push   %eax
  801187:	57                   	push   %edi
  801188:	e8 41 ff ff ff       	call   8010ce <read>
		if (m < 0)
  80118d:	83 c4 10             	add    $0x10,%esp
  801190:	85 c0                	test   %eax,%eax
  801192:	78 04                	js     801198 <readn+0x3f>
			return m;
		if (m == 0)
  801194:	75 dd                	jne    801173 <readn+0x1a>
  801196:	eb 02                	jmp    80119a <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801198:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80119a:	89 d8                	mov    %ebx,%eax
  80119c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80119f:	5b                   	pop    %ebx
  8011a0:	5e                   	pop    %esi
  8011a1:	5f                   	pop    %edi
  8011a2:	5d                   	pop    %ebp
  8011a3:	c3                   	ret    

008011a4 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011a4:	f3 0f 1e fb          	endbr32 
  8011a8:	55                   	push   %ebp
  8011a9:	89 e5                	mov    %esp,%ebp
  8011ab:	53                   	push   %ebx
  8011ac:	83 ec 1c             	sub    $0x1c,%esp
  8011af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011b5:	50                   	push   %eax
  8011b6:	53                   	push   %ebx
  8011b7:	e8 8f fc ff ff       	call   800e4b <fd_lookup>
  8011bc:	83 c4 10             	add    $0x10,%esp
  8011bf:	85 c0                	test   %eax,%eax
  8011c1:	78 3a                	js     8011fd <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011c3:	83 ec 08             	sub    $0x8,%esp
  8011c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c9:	50                   	push   %eax
  8011ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011cd:	ff 30                	pushl  (%eax)
  8011cf:	e8 cb fc ff ff       	call   800e9f <dev_lookup>
  8011d4:	83 c4 10             	add    $0x10,%esp
  8011d7:	85 c0                	test   %eax,%eax
  8011d9:	78 22                	js     8011fd <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011de:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011e2:	74 1e                	je     801202 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011e7:	8b 52 0c             	mov    0xc(%edx),%edx
  8011ea:	85 d2                	test   %edx,%edx
  8011ec:	74 35                	je     801223 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011ee:	83 ec 04             	sub    $0x4,%esp
  8011f1:	ff 75 10             	pushl  0x10(%ebp)
  8011f4:	ff 75 0c             	pushl  0xc(%ebp)
  8011f7:	50                   	push   %eax
  8011f8:	ff d2                	call   *%edx
  8011fa:	83 c4 10             	add    $0x10,%esp
}
  8011fd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801200:	c9                   	leave  
  801201:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801202:	a1 04 40 80 00       	mov    0x804004,%eax
  801207:	8b 40 48             	mov    0x48(%eax),%eax
  80120a:	83 ec 04             	sub    $0x4,%esp
  80120d:	53                   	push   %ebx
  80120e:	50                   	push   %eax
  80120f:	68 11 23 80 00       	push   $0x802311
  801214:	e8 f7 ef ff ff       	call   800210 <cprintf>
		return -E_INVAL;
  801219:	83 c4 10             	add    $0x10,%esp
  80121c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801221:	eb da                	jmp    8011fd <write+0x59>
		return -E_NOT_SUPP;
  801223:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801228:	eb d3                	jmp    8011fd <write+0x59>

0080122a <seek>:

int
seek(int fdnum, off_t offset)
{
  80122a:	f3 0f 1e fb          	endbr32 
  80122e:	55                   	push   %ebp
  80122f:	89 e5                	mov    %esp,%ebp
  801231:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801234:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801237:	50                   	push   %eax
  801238:	ff 75 08             	pushl  0x8(%ebp)
  80123b:	e8 0b fc ff ff       	call   800e4b <fd_lookup>
  801240:	83 c4 10             	add    $0x10,%esp
  801243:	85 c0                	test   %eax,%eax
  801245:	78 0e                	js     801255 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801247:	8b 55 0c             	mov    0xc(%ebp),%edx
  80124a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80124d:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801250:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801255:	c9                   	leave  
  801256:	c3                   	ret    

00801257 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801257:	f3 0f 1e fb          	endbr32 
  80125b:	55                   	push   %ebp
  80125c:	89 e5                	mov    %esp,%ebp
  80125e:	53                   	push   %ebx
  80125f:	83 ec 1c             	sub    $0x1c,%esp
  801262:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801265:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801268:	50                   	push   %eax
  801269:	53                   	push   %ebx
  80126a:	e8 dc fb ff ff       	call   800e4b <fd_lookup>
  80126f:	83 c4 10             	add    $0x10,%esp
  801272:	85 c0                	test   %eax,%eax
  801274:	78 37                	js     8012ad <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801276:	83 ec 08             	sub    $0x8,%esp
  801279:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80127c:	50                   	push   %eax
  80127d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801280:	ff 30                	pushl  (%eax)
  801282:	e8 18 fc ff ff       	call   800e9f <dev_lookup>
  801287:	83 c4 10             	add    $0x10,%esp
  80128a:	85 c0                	test   %eax,%eax
  80128c:	78 1f                	js     8012ad <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80128e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801291:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801295:	74 1b                	je     8012b2 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801297:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80129a:	8b 52 18             	mov    0x18(%edx),%edx
  80129d:	85 d2                	test   %edx,%edx
  80129f:	74 32                	je     8012d3 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012a1:	83 ec 08             	sub    $0x8,%esp
  8012a4:	ff 75 0c             	pushl  0xc(%ebp)
  8012a7:	50                   	push   %eax
  8012a8:	ff d2                	call   *%edx
  8012aa:	83 c4 10             	add    $0x10,%esp
}
  8012ad:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012b0:	c9                   	leave  
  8012b1:	c3                   	ret    
			thisenv->env_id, fdnum);
  8012b2:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012b7:	8b 40 48             	mov    0x48(%eax),%eax
  8012ba:	83 ec 04             	sub    $0x4,%esp
  8012bd:	53                   	push   %ebx
  8012be:	50                   	push   %eax
  8012bf:	68 d4 22 80 00       	push   $0x8022d4
  8012c4:	e8 47 ef ff ff       	call   800210 <cprintf>
		return -E_INVAL;
  8012c9:	83 c4 10             	add    $0x10,%esp
  8012cc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012d1:	eb da                	jmp    8012ad <ftruncate+0x56>
		return -E_NOT_SUPP;
  8012d3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012d8:	eb d3                	jmp    8012ad <ftruncate+0x56>

008012da <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012da:	f3 0f 1e fb          	endbr32 
  8012de:	55                   	push   %ebp
  8012df:	89 e5                	mov    %esp,%ebp
  8012e1:	53                   	push   %ebx
  8012e2:	83 ec 1c             	sub    $0x1c,%esp
  8012e5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012e8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012eb:	50                   	push   %eax
  8012ec:	ff 75 08             	pushl  0x8(%ebp)
  8012ef:	e8 57 fb ff ff       	call   800e4b <fd_lookup>
  8012f4:	83 c4 10             	add    $0x10,%esp
  8012f7:	85 c0                	test   %eax,%eax
  8012f9:	78 4b                	js     801346 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012fb:	83 ec 08             	sub    $0x8,%esp
  8012fe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801301:	50                   	push   %eax
  801302:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801305:	ff 30                	pushl  (%eax)
  801307:	e8 93 fb ff ff       	call   800e9f <dev_lookup>
  80130c:	83 c4 10             	add    $0x10,%esp
  80130f:	85 c0                	test   %eax,%eax
  801311:	78 33                	js     801346 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801313:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801316:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80131a:	74 2f                	je     80134b <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80131c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80131f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801326:	00 00 00 
	stat->st_isdir = 0;
  801329:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801330:	00 00 00 
	stat->st_dev = dev;
  801333:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801339:	83 ec 08             	sub    $0x8,%esp
  80133c:	53                   	push   %ebx
  80133d:	ff 75 f0             	pushl  -0x10(%ebp)
  801340:	ff 50 14             	call   *0x14(%eax)
  801343:	83 c4 10             	add    $0x10,%esp
}
  801346:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801349:	c9                   	leave  
  80134a:	c3                   	ret    
		return -E_NOT_SUPP;
  80134b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801350:	eb f4                	jmp    801346 <fstat+0x6c>

00801352 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801352:	f3 0f 1e fb          	endbr32 
  801356:	55                   	push   %ebp
  801357:	89 e5                	mov    %esp,%ebp
  801359:	56                   	push   %esi
  80135a:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80135b:	83 ec 08             	sub    $0x8,%esp
  80135e:	6a 00                	push   $0x0
  801360:	ff 75 08             	pushl  0x8(%ebp)
  801363:	e8 fb 01 00 00       	call   801563 <open>
  801368:	89 c3                	mov    %eax,%ebx
  80136a:	83 c4 10             	add    $0x10,%esp
  80136d:	85 c0                	test   %eax,%eax
  80136f:	78 1b                	js     80138c <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801371:	83 ec 08             	sub    $0x8,%esp
  801374:	ff 75 0c             	pushl  0xc(%ebp)
  801377:	50                   	push   %eax
  801378:	e8 5d ff ff ff       	call   8012da <fstat>
  80137d:	89 c6                	mov    %eax,%esi
	close(fd);
  80137f:	89 1c 24             	mov    %ebx,(%esp)
  801382:	e8 fd fb ff ff       	call   800f84 <close>
	return r;
  801387:	83 c4 10             	add    $0x10,%esp
  80138a:	89 f3                	mov    %esi,%ebx
}
  80138c:	89 d8                	mov    %ebx,%eax
  80138e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801391:	5b                   	pop    %ebx
  801392:	5e                   	pop    %esi
  801393:	5d                   	pop    %ebp
  801394:	c3                   	ret    

00801395 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801395:	55                   	push   %ebp
  801396:	89 e5                	mov    %esp,%ebp
  801398:	56                   	push   %esi
  801399:	53                   	push   %ebx
  80139a:	89 c6                	mov    %eax,%esi
  80139c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80139e:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013a5:	74 27                	je     8013ce <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013a7:	6a 07                	push   $0x7
  8013a9:	68 00 50 80 00       	push   $0x805000
  8013ae:	56                   	push   %esi
  8013af:	ff 35 00 40 80 00    	pushl  0x804000
  8013b5:	e8 bf 07 00 00       	call   801b79 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013ba:	83 c4 0c             	add    $0xc,%esp
  8013bd:	6a 00                	push   $0x0
  8013bf:	53                   	push   %ebx
  8013c0:	6a 00                	push   $0x0
  8013c2:	e8 44 07 00 00       	call   801b0b <ipc_recv>
}
  8013c7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013ca:	5b                   	pop    %ebx
  8013cb:	5e                   	pop    %esi
  8013cc:	5d                   	pop    %ebp
  8013cd:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013ce:	83 ec 0c             	sub    $0xc,%esp
  8013d1:	6a 01                	push   $0x1
  8013d3:	e8 06 08 00 00       	call   801bde <ipc_find_env>
  8013d8:	a3 00 40 80 00       	mov    %eax,0x804000
  8013dd:	83 c4 10             	add    $0x10,%esp
  8013e0:	eb c5                	jmp    8013a7 <fsipc+0x12>

008013e2 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013e2:	f3 0f 1e fb          	endbr32 
  8013e6:	55                   	push   %ebp
  8013e7:	89 e5                	mov    %esp,%ebp
  8013e9:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8013ef:	8b 40 0c             	mov    0xc(%eax),%eax
  8013f2:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013f7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013fa:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801404:	b8 02 00 00 00       	mov    $0x2,%eax
  801409:	e8 87 ff ff ff       	call   801395 <fsipc>
}
  80140e:	c9                   	leave  
  80140f:	c3                   	ret    

00801410 <devfile_flush>:
{
  801410:	f3 0f 1e fb          	endbr32 
  801414:	55                   	push   %ebp
  801415:	89 e5                	mov    %esp,%ebp
  801417:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80141a:	8b 45 08             	mov    0x8(%ebp),%eax
  80141d:	8b 40 0c             	mov    0xc(%eax),%eax
  801420:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801425:	ba 00 00 00 00       	mov    $0x0,%edx
  80142a:	b8 06 00 00 00       	mov    $0x6,%eax
  80142f:	e8 61 ff ff ff       	call   801395 <fsipc>
}
  801434:	c9                   	leave  
  801435:	c3                   	ret    

00801436 <devfile_stat>:
{
  801436:	f3 0f 1e fb          	endbr32 
  80143a:	55                   	push   %ebp
  80143b:	89 e5                	mov    %esp,%ebp
  80143d:	53                   	push   %ebx
  80143e:	83 ec 04             	sub    $0x4,%esp
  801441:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801444:	8b 45 08             	mov    0x8(%ebp),%eax
  801447:	8b 40 0c             	mov    0xc(%eax),%eax
  80144a:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80144f:	ba 00 00 00 00       	mov    $0x0,%edx
  801454:	b8 05 00 00 00       	mov    $0x5,%eax
  801459:	e8 37 ff ff ff       	call   801395 <fsipc>
  80145e:	85 c0                	test   %eax,%eax
  801460:	78 2c                	js     80148e <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801462:	83 ec 08             	sub    $0x8,%esp
  801465:	68 00 50 80 00       	push   $0x805000
  80146a:	53                   	push   %ebx
  80146b:	e8 0a f3 ff ff       	call   80077a <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801470:	a1 80 50 80 00       	mov    0x805080,%eax
  801475:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  80147b:	a1 84 50 80 00       	mov    0x805084,%eax
  801480:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801486:	83 c4 10             	add    $0x10,%esp
  801489:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80148e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801491:	c9                   	leave  
  801492:	c3                   	ret    

00801493 <devfile_write>:
{
  801493:	f3 0f 1e fb          	endbr32 
  801497:	55                   	push   %ebp
  801498:	89 e5                	mov    %esp,%ebp
  80149a:	83 ec 0c             	sub    $0xc,%esp
  80149d:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8014a3:	8b 52 0c             	mov    0xc(%edx),%edx
  8014a6:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014ac:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014b1:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014b6:	0f 47 c2             	cmova  %edx,%eax
  8014b9:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8014be:	50                   	push   %eax
  8014bf:	ff 75 0c             	pushl  0xc(%ebp)
  8014c2:	68 08 50 80 00       	push   $0x805008
  8014c7:	e8 66 f4 ff ff       	call   800932 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8014cc:	ba 00 00 00 00       	mov    $0x0,%edx
  8014d1:	b8 04 00 00 00       	mov    $0x4,%eax
  8014d6:	e8 ba fe ff ff       	call   801395 <fsipc>
}
  8014db:	c9                   	leave  
  8014dc:	c3                   	ret    

008014dd <devfile_read>:
{
  8014dd:	f3 0f 1e fb          	endbr32 
  8014e1:	55                   	push   %ebp
  8014e2:	89 e5                	mov    %esp,%ebp
  8014e4:	56                   	push   %esi
  8014e5:	53                   	push   %ebx
  8014e6:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8014ec:	8b 40 0c             	mov    0xc(%eax),%eax
  8014ef:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014f4:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ff:	b8 03 00 00 00       	mov    $0x3,%eax
  801504:	e8 8c fe ff ff       	call   801395 <fsipc>
  801509:	89 c3                	mov    %eax,%ebx
  80150b:	85 c0                	test   %eax,%eax
  80150d:	78 1f                	js     80152e <devfile_read+0x51>
	assert(r <= n);
  80150f:	39 f0                	cmp    %esi,%eax
  801511:	77 24                	ja     801537 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801513:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801518:	7f 33                	jg     80154d <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80151a:	83 ec 04             	sub    $0x4,%esp
  80151d:	50                   	push   %eax
  80151e:	68 00 50 80 00       	push   $0x805000
  801523:	ff 75 0c             	pushl  0xc(%ebp)
  801526:	e8 07 f4 ff ff       	call   800932 <memmove>
	return r;
  80152b:	83 c4 10             	add    $0x10,%esp
}
  80152e:	89 d8                	mov    %ebx,%eax
  801530:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801533:	5b                   	pop    %ebx
  801534:	5e                   	pop    %esi
  801535:	5d                   	pop    %ebp
  801536:	c3                   	ret    
	assert(r <= n);
  801537:	68 40 23 80 00       	push   $0x802340
  80153c:	68 47 23 80 00       	push   $0x802347
  801541:	6a 7c                	push   $0x7c
  801543:	68 5c 23 80 00       	push   $0x80235c
  801548:	e8 dc eb ff ff       	call   800129 <_panic>
	assert(r <= PGSIZE);
  80154d:	68 67 23 80 00       	push   $0x802367
  801552:	68 47 23 80 00       	push   $0x802347
  801557:	6a 7d                	push   $0x7d
  801559:	68 5c 23 80 00       	push   $0x80235c
  80155e:	e8 c6 eb ff ff       	call   800129 <_panic>

00801563 <open>:
{
  801563:	f3 0f 1e fb          	endbr32 
  801567:	55                   	push   %ebp
  801568:	89 e5                	mov    %esp,%ebp
  80156a:	56                   	push   %esi
  80156b:	53                   	push   %ebx
  80156c:	83 ec 1c             	sub    $0x1c,%esp
  80156f:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801572:	56                   	push   %esi
  801573:	e8 bf f1 ff ff       	call   800737 <strlen>
  801578:	83 c4 10             	add    $0x10,%esp
  80157b:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801580:	7f 6c                	jg     8015ee <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801582:	83 ec 0c             	sub    $0xc,%esp
  801585:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801588:	50                   	push   %eax
  801589:	e8 67 f8 ff ff       	call   800df5 <fd_alloc>
  80158e:	89 c3                	mov    %eax,%ebx
  801590:	83 c4 10             	add    $0x10,%esp
  801593:	85 c0                	test   %eax,%eax
  801595:	78 3c                	js     8015d3 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801597:	83 ec 08             	sub    $0x8,%esp
  80159a:	56                   	push   %esi
  80159b:	68 00 50 80 00       	push   $0x805000
  8015a0:	e8 d5 f1 ff ff       	call   80077a <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015a5:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015a8:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015ad:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015b0:	b8 01 00 00 00       	mov    $0x1,%eax
  8015b5:	e8 db fd ff ff       	call   801395 <fsipc>
  8015ba:	89 c3                	mov    %eax,%ebx
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	85 c0                	test   %eax,%eax
  8015c1:	78 19                	js     8015dc <open+0x79>
	return fd2num(fd);
  8015c3:	83 ec 0c             	sub    $0xc,%esp
  8015c6:	ff 75 f4             	pushl  -0xc(%ebp)
  8015c9:	e8 f4 f7 ff ff       	call   800dc2 <fd2num>
  8015ce:	89 c3                	mov    %eax,%ebx
  8015d0:	83 c4 10             	add    $0x10,%esp
}
  8015d3:	89 d8                	mov    %ebx,%eax
  8015d5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d8:	5b                   	pop    %ebx
  8015d9:	5e                   	pop    %esi
  8015da:	5d                   	pop    %ebp
  8015db:	c3                   	ret    
		fd_close(fd, 0);
  8015dc:	83 ec 08             	sub    $0x8,%esp
  8015df:	6a 00                	push   $0x0
  8015e1:	ff 75 f4             	pushl  -0xc(%ebp)
  8015e4:	e8 10 f9 ff ff       	call   800ef9 <fd_close>
		return r;
  8015e9:	83 c4 10             	add    $0x10,%esp
  8015ec:	eb e5                	jmp    8015d3 <open+0x70>
		return -E_BAD_PATH;
  8015ee:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8015f3:	eb de                	jmp    8015d3 <open+0x70>

008015f5 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015f5:	f3 0f 1e fb          	endbr32 
  8015f9:	55                   	push   %ebp
  8015fa:	89 e5                	mov    %esp,%ebp
  8015fc:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801604:	b8 08 00 00 00       	mov    $0x8,%eax
  801609:	e8 87 fd ff ff       	call   801395 <fsipc>
}
  80160e:	c9                   	leave  
  80160f:	c3                   	ret    

00801610 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801610:	f3 0f 1e fb          	endbr32 
  801614:	55                   	push   %ebp
  801615:	89 e5                	mov    %esp,%ebp
  801617:	56                   	push   %esi
  801618:	53                   	push   %ebx
  801619:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  80161c:	83 ec 0c             	sub    $0xc,%esp
  80161f:	ff 75 08             	pushl  0x8(%ebp)
  801622:	e8 af f7 ff ff       	call   800dd6 <fd2data>
  801627:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801629:	83 c4 08             	add    $0x8,%esp
  80162c:	68 73 23 80 00       	push   $0x802373
  801631:	53                   	push   %ebx
  801632:	e8 43 f1 ff ff       	call   80077a <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801637:	8b 46 04             	mov    0x4(%esi),%eax
  80163a:	2b 06                	sub    (%esi),%eax
  80163c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801642:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801649:	00 00 00 
	stat->st_dev = &devpipe;
  80164c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801653:	30 80 00 
	return 0;
}
  801656:	b8 00 00 00 00       	mov    $0x0,%eax
  80165b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80165e:	5b                   	pop    %ebx
  80165f:	5e                   	pop    %esi
  801660:	5d                   	pop    %ebp
  801661:	c3                   	ret    

00801662 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801662:	f3 0f 1e fb          	endbr32 
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	53                   	push   %ebx
  80166a:	83 ec 0c             	sub    $0xc,%esp
  80166d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801670:	53                   	push   %ebx
  801671:	6a 00                	push   $0x0
  801673:	e8 dc f5 ff ff       	call   800c54 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801678:	89 1c 24             	mov    %ebx,(%esp)
  80167b:	e8 56 f7 ff ff       	call   800dd6 <fd2data>
  801680:	83 c4 08             	add    $0x8,%esp
  801683:	50                   	push   %eax
  801684:	6a 00                	push   $0x0
  801686:	e8 c9 f5 ff ff       	call   800c54 <sys_page_unmap>
}
  80168b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80168e:	c9                   	leave  
  80168f:	c3                   	ret    

00801690 <_pipeisclosed>:
{
  801690:	55                   	push   %ebp
  801691:	89 e5                	mov    %esp,%ebp
  801693:	57                   	push   %edi
  801694:	56                   	push   %esi
  801695:	53                   	push   %ebx
  801696:	83 ec 1c             	sub    $0x1c,%esp
  801699:	89 c7                	mov    %eax,%edi
  80169b:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80169d:	a1 04 40 80 00       	mov    0x804004,%eax
  8016a2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8016a5:	83 ec 0c             	sub    $0xc,%esp
  8016a8:	57                   	push   %edi
  8016a9:	e8 6d 05 00 00       	call   801c1b <pageref>
  8016ae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016b1:	89 34 24             	mov    %esi,(%esp)
  8016b4:	e8 62 05 00 00       	call   801c1b <pageref>
		nn = thisenv->env_runs;
  8016b9:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016bf:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016c2:	83 c4 10             	add    $0x10,%esp
  8016c5:	39 cb                	cmp    %ecx,%ebx
  8016c7:	74 1b                	je     8016e4 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8016c9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8016cc:	75 cf                	jne    80169d <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016ce:	8b 42 58             	mov    0x58(%edx),%eax
  8016d1:	6a 01                	push   $0x1
  8016d3:	50                   	push   %eax
  8016d4:	53                   	push   %ebx
  8016d5:	68 7a 23 80 00       	push   $0x80237a
  8016da:	e8 31 eb ff ff       	call   800210 <cprintf>
  8016df:	83 c4 10             	add    $0x10,%esp
  8016e2:	eb b9                	jmp    80169d <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8016e4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8016e7:	0f 94 c0             	sete   %al
  8016ea:	0f b6 c0             	movzbl %al,%eax
}
  8016ed:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016f0:	5b                   	pop    %ebx
  8016f1:	5e                   	pop    %esi
  8016f2:	5f                   	pop    %edi
  8016f3:	5d                   	pop    %ebp
  8016f4:	c3                   	ret    

008016f5 <devpipe_write>:
{
  8016f5:	f3 0f 1e fb          	endbr32 
  8016f9:	55                   	push   %ebp
  8016fa:	89 e5                	mov    %esp,%ebp
  8016fc:	57                   	push   %edi
  8016fd:	56                   	push   %esi
  8016fe:	53                   	push   %ebx
  8016ff:	83 ec 28             	sub    $0x28,%esp
  801702:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801705:	56                   	push   %esi
  801706:	e8 cb f6 ff ff       	call   800dd6 <fd2data>
  80170b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80170d:	83 c4 10             	add    $0x10,%esp
  801710:	bf 00 00 00 00       	mov    $0x0,%edi
  801715:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801718:	74 4f                	je     801769 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80171a:	8b 43 04             	mov    0x4(%ebx),%eax
  80171d:	8b 0b                	mov    (%ebx),%ecx
  80171f:	8d 51 20             	lea    0x20(%ecx),%edx
  801722:	39 d0                	cmp    %edx,%eax
  801724:	72 14                	jb     80173a <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801726:	89 da                	mov    %ebx,%edx
  801728:	89 f0                	mov    %esi,%eax
  80172a:	e8 61 ff ff ff       	call   801690 <_pipeisclosed>
  80172f:	85 c0                	test   %eax,%eax
  801731:	75 3b                	jne    80176e <devpipe_write+0x79>
			sys_yield();
  801733:	e8 9f f4 ff ff       	call   800bd7 <sys_yield>
  801738:	eb e0                	jmp    80171a <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80173a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80173d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801741:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801744:	89 c2                	mov    %eax,%edx
  801746:	c1 fa 1f             	sar    $0x1f,%edx
  801749:	89 d1                	mov    %edx,%ecx
  80174b:	c1 e9 1b             	shr    $0x1b,%ecx
  80174e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801751:	83 e2 1f             	and    $0x1f,%edx
  801754:	29 ca                	sub    %ecx,%edx
  801756:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80175a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80175e:	83 c0 01             	add    $0x1,%eax
  801761:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801764:	83 c7 01             	add    $0x1,%edi
  801767:	eb ac                	jmp    801715 <devpipe_write+0x20>
	return i;
  801769:	8b 45 10             	mov    0x10(%ebp),%eax
  80176c:	eb 05                	jmp    801773 <devpipe_write+0x7e>
				return 0;
  80176e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801773:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801776:	5b                   	pop    %ebx
  801777:	5e                   	pop    %esi
  801778:	5f                   	pop    %edi
  801779:	5d                   	pop    %ebp
  80177a:	c3                   	ret    

0080177b <devpipe_read>:
{
  80177b:	f3 0f 1e fb          	endbr32 
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  801782:	57                   	push   %edi
  801783:	56                   	push   %esi
  801784:	53                   	push   %ebx
  801785:	83 ec 18             	sub    $0x18,%esp
  801788:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80178b:	57                   	push   %edi
  80178c:	e8 45 f6 ff ff       	call   800dd6 <fd2data>
  801791:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801793:	83 c4 10             	add    $0x10,%esp
  801796:	be 00 00 00 00       	mov    $0x0,%esi
  80179b:	3b 75 10             	cmp    0x10(%ebp),%esi
  80179e:	75 14                	jne    8017b4 <devpipe_read+0x39>
	return i;
  8017a0:	8b 45 10             	mov    0x10(%ebp),%eax
  8017a3:	eb 02                	jmp    8017a7 <devpipe_read+0x2c>
				return i;
  8017a5:	89 f0                	mov    %esi,%eax
}
  8017a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017aa:	5b                   	pop    %ebx
  8017ab:	5e                   	pop    %esi
  8017ac:	5f                   	pop    %edi
  8017ad:	5d                   	pop    %ebp
  8017ae:	c3                   	ret    
			sys_yield();
  8017af:	e8 23 f4 ff ff       	call   800bd7 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8017b4:	8b 03                	mov    (%ebx),%eax
  8017b6:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017b9:	75 18                	jne    8017d3 <devpipe_read+0x58>
			if (i > 0)
  8017bb:	85 f6                	test   %esi,%esi
  8017bd:	75 e6                	jne    8017a5 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8017bf:	89 da                	mov    %ebx,%edx
  8017c1:	89 f8                	mov    %edi,%eax
  8017c3:	e8 c8 fe ff ff       	call   801690 <_pipeisclosed>
  8017c8:	85 c0                	test   %eax,%eax
  8017ca:	74 e3                	je     8017af <devpipe_read+0x34>
				return 0;
  8017cc:	b8 00 00 00 00       	mov    $0x0,%eax
  8017d1:	eb d4                	jmp    8017a7 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017d3:	99                   	cltd   
  8017d4:	c1 ea 1b             	shr    $0x1b,%edx
  8017d7:	01 d0                	add    %edx,%eax
  8017d9:	83 e0 1f             	and    $0x1f,%eax
  8017dc:	29 d0                	sub    %edx,%eax
  8017de:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8017e3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017e6:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8017e9:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8017ec:	83 c6 01             	add    $0x1,%esi
  8017ef:	eb aa                	jmp    80179b <devpipe_read+0x20>

008017f1 <pipe>:
{
  8017f1:	f3 0f 1e fb          	endbr32 
  8017f5:	55                   	push   %ebp
  8017f6:	89 e5                	mov    %esp,%ebp
  8017f8:	56                   	push   %esi
  8017f9:	53                   	push   %ebx
  8017fa:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8017fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801800:	50                   	push   %eax
  801801:	e8 ef f5 ff ff       	call   800df5 <fd_alloc>
  801806:	89 c3                	mov    %eax,%ebx
  801808:	83 c4 10             	add    $0x10,%esp
  80180b:	85 c0                	test   %eax,%eax
  80180d:	0f 88 23 01 00 00    	js     801936 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801813:	83 ec 04             	sub    $0x4,%esp
  801816:	68 07 04 00 00       	push   $0x407
  80181b:	ff 75 f4             	pushl  -0xc(%ebp)
  80181e:	6a 00                	push   $0x0
  801820:	e8 dd f3 ff ff       	call   800c02 <sys_page_alloc>
  801825:	89 c3                	mov    %eax,%ebx
  801827:	83 c4 10             	add    $0x10,%esp
  80182a:	85 c0                	test   %eax,%eax
  80182c:	0f 88 04 01 00 00    	js     801936 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801832:	83 ec 0c             	sub    $0xc,%esp
  801835:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801838:	50                   	push   %eax
  801839:	e8 b7 f5 ff ff       	call   800df5 <fd_alloc>
  80183e:	89 c3                	mov    %eax,%ebx
  801840:	83 c4 10             	add    $0x10,%esp
  801843:	85 c0                	test   %eax,%eax
  801845:	0f 88 db 00 00 00    	js     801926 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80184b:	83 ec 04             	sub    $0x4,%esp
  80184e:	68 07 04 00 00       	push   $0x407
  801853:	ff 75 f0             	pushl  -0x10(%ebp)
  801856:	6a 00                	push   $0x0
  801858:	e8 a5 f3 ff ff       	call   800c02 <sys_page_alloc>
  80185d:	89 c3                	mov    %eax,%ebx
  80185f:	83 c4 10             	add    $0x10,%esp
  801862:	85 c0                	test   %eax,%eax
  801864:	0f 88 bc 00 00 00    	js     801926 <pipe+0x135>
	va = fd2data(fd0);
  80186a:	83 ec 0c             	sub    $0xc,%esp
  80186d:	ff 75 f4             	pushl  -0xc(%ebp)
  801870:	e8 61 f5 ff ff       	call   800dd6 <fd2data>
  801875:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801877:	83 c4 0c             	add    $0xc,%esp
  80187a:	68 07 04 00 00       	push   $0x407
  80187f:	50                   	push   %eax
  801880:	6a 00                	push   $0x0
  801882:	e8 7b f3 ff ff       	call   800c02 <sys_page_alloc>
  801887:	89 c3                	mov    %eax,%ebx
  801889:	83 c4 10             	add    $0x10,%esp
  80188c:	85 c0                	test   %eax,%eax
  80188e:	0f 88 82 00 00 00    	js     801916 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801894:	83 ec 0c             	sub    $0xc,%esp
  801897:	ff 75 f0             	pushl  -0x10(%ebp)
  80189a:	e8 37 f5 ff ff       	call   800dd6 <fd2data>
  80189f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018a6:	50                   	push   %eax
  8018a7:	6a 00                	push   $0x0
  8018a9:	56                   	push   %esi
  8018aa:	6a 00                	push   $0x0
  8018ac:	e8 79 f3 ff ff       	call   800c2a <sys_page_map>
  8018b1:	89 c3                	mov    %eax,%ebx
  8018b3:	83 c4 20             	add    $0x20,%esp
  8018b6:	85 c0                	test   %eax,%eax
  8018b8:	78 4e                	js     801908 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8018ba:	a1 20 30 80 00       	mov    0x803020,%eax
  8018bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c2:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8018c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c7:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8018ce:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018d1:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8018d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8018dd:	83 ec 0c             	sub    $0xc,%esp
  8018e0:	ff 75 f4             	pushl  -0xc(%ebp)
  8018e3:	e8 da f4 ff ff       	call   800dc2 <fd2num>
  8018e8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018eb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8018ed:	83 c4 04             	add    $0x4,%esp
  8018f0:	ff 75 f0             	pushl  -0x10(%ebp)
  8018f3:	e8 ca f4 ff ff       	call   800dc2 <fd2num>
  8018f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8018fb:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8018fe:	83 c4 10             	add    $0x10,%esp
  801901:	bb 00 00 00 00       	mov    $0x0,%ebx
  801906:	eb 2e                	jmp    801936 <pipe+0x145>
	sys_page_unmap(0, va);
  801908:	83 ec 08             	sub    $0x8,%esp
  80190b:	56                   	push   %esi
  80190c:	6a 00                	push   $0x0
  80190e:	e8 41 f3 ff ff       	call   800c54 <sys_page_unmap>
  801913:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801916:	83 ec 08             	sub    $0x8,%esp
  801919:	ff 75 f0             	pushl  -0x10(%ebp)
  80191c:	6a 00                	push   $0x0
  80191e:	e8 31 f3 ff ff       	call   800c54 <sys_page_unmap>
  801923:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801926:	83 ec 08             	sub    $0x8,%esp
  801929:	ff 75 f4             	pushl  -0xc(%ebp)
  80192c:	6a 00                	push   $0x0
  80192e:	e8 21 f3 ff ff       	call   800c54 <sys_page_unmap>
  801933:	83 c4 10             	add    $0x10,%esp
}
  801936:	89 d8                	mov    %ebx,%eax
  801938:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80193b:	5b                   	pop    %ebx
  80193c:	5e                   	pop    %esi
  80193d:	5d                   	pop    %ebp
  80193e:	c3                   	ret    

0080193f <pipeisclosed>:
{
  80193f:	f3 0f 1e fb          	endbr32 
  801943:	55                   	push   %ebp
  801944:	89 e5                	mov    %esp,%ebp
  801946:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801949:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80194c:	50                   	push   %eax
  80194d:	ff 75 08             	pushl  0x8(%ebp)
  801950:	e8 f6 f4 ff ff       	call   800e4b <fd_lookup>
  801955:	83 c4 10             	add    $0x10,%esp
  801958:	85 c0                	test   %eax,%eax
  80195a:	78 18                	js     801974 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  80195c:	83 ec 0c             	sub    $0xc,%esp
  80195f:	ff 75 f4             	pushl  -0xc(%ebp)
  801962:	e8 6f f4 ff ff       	call   800dd6 <fd2data>
  801967:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801969:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80196c:	e8 1f fd ff ff       	call   801690 <_pipeisclosed>
  801971:	83 c4 10             	add    $0x10,%esp
}
  801974:	c9                   	leave  
  801975:	c3                   	ret    

00801976 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801976:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  80197a:	b8 00 00 00 00       	mov    $0x0,%eax
  80197f:	c3                   	ret    

00801980 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801980:	f3 0f 1e fb          	endbr32 
  801984:	55                   	push   %ebp
  801985:	89 e5                	mov    %esp,%ebp
  801987:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80198a:	68 92 23 80 00       	push   $0x802392
  80198f:	ff 75 0c             	pushl  0xc(%ebp)
  801992:	e8 e3 ed ff ff       	call   80077a <strcpy>
	return 0;
}
  801997:	b8 00 00 00 00       	mov    $0x0,%eax
  80199c:	c9                   	leave  
  80199d:	c3                   	ret    

0080199e <devcons_write>:
{
  80199e:	f3 0f 1e fb          	endbr32 
  8019a2:	55                   	push   %ebp
  8019a3:	89 e5                	mov    %esp,%ebp
  8019a5:	57                   	push   %edi
  8019a6:	56                   	push   %esi
  8019a7:	53                   	push   %ebx
  8019a8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8019ae:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8019b3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8019b9:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019bc:	73 31                	jae    8019ef <devcons_write+0x51>
		m = n - tot;
  8019be:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019c1:	29 f3                	sub    %esi,%ebx
  8019c3:	83 fb 7f             	cmp    $0x7f,%ebx
  8019c6:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8019cb:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8019ce:	83 ec 04             	sub    $0x4,%esp
  8019d1:	53                   	push   %ebx
  8019d2:	89 f0                	mov    %esi,%eax
  8019d4:	03 45 0c             	add    0xc(%ebp),%eax
  8019d7:	50                   	push   %eax
  8019d8:	57                   	push   %edi
  8019d9:	e8 54 ef ff ff       	call   800932 <memmove>
		sys_cputs(buf, m);
  8019de:	83 c4 08             	add    $0x8,%esp
  8019e1:	53                   	push   %ebx
  8019e2:	57                   	push   %edi
  8019e3:	e8 4f f1 ff ff       	call   800b37 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8019e8:	01 de                	add    %ebx,%esi
  8019ea:	83 c4 10             	add    $0x10,%esp
  8019ed:	eb ca                	jmp    8019b9 <devcons_write+0x1b>
}
  8019ef:	89 f0                	mov    %esi,%eax
  8019f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8019f4:	5b                   	pop    %ebx
  8019f5:	5e                   	pop    %esi
  8019f6:	5f                   	pop    %edi
  8019f7:	5d                   	pop    %ebp
  8019f8:	c3                   	ret    

008019f9 <devcons_read>:
{
  8019f9:	f3 0f 1e fb          	endbr32 
  8019fd:	55                   	push   %ebp
  8019fe:	89 e5                	mov    %esp,%ebp
  801a00:	83 ec 08             	sub    $0x8,%esp
  801a03:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801a08:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a0c:	74 21                	je     801a2f <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801a0e:	e8 4e f1 ff ff       	call   800b61 <sys_cgetc>
  801a13:	85 c0                	test   %eax,%eax
  801a15:	75 07                	jne    801a1e <devcons_read+0x25>
		sys_yield();
  801a17:	e8 bb f1 ff ff       	call   800bd7 <sys_yield>
  801a1c:	eb f0                	jmp    801a0e <devcons_read+0x15>
	if (c < 0)
  801a1e:	78 0f                	js     801a2f <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801a20:	83 f8 04             	cmp    $0x4,%eax
  801a23:	74 0c                	je     801a31 <devcons_read+0x38>
	*(char*)vbuf = c;
  801a25:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a28:	88 02                	mov    %al,(%edx)
	return 1;
  801a2a:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801a2f:	c9                   	leave  
  801a30:	c3                   	ret    
		return 0;
  801a31:	b8 00 00 00 00       	mov    $0x0,%eax
  801a36:	eb f7                	jmp    801a2f <devcons_read+0x36>

00801a38 <cputchar>:
{
  801a38:	f3 0f 1e fb          	endbr32 
  801a3c:	55                   	push   %ebp
  801a3d:	89 e5                	mov    %esp,%ebp
  801a3f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a42:	8b 45 08             	mov    0x8(%ebp),%eax
  801a45:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801a48:	6a 01                	push   $0x1
  801a4a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a4d:	50                   	push   %eax
  801a4e:	e8 e4 f0 ff ff       	call   800b37 <sys_cputs>
}
  801a53:	83 c4 10             	add    $0x10,%esp
  801a56:	c9                   	leave  
  801a57:	c3                   	ret    

00801a58 <getchar>:
{
  801a58:	f3 0f 1e fb          	endbr32 
  801a5c:	55                   	push   %ebp
  801a5d:	89 e5                	mov    %esp,%ebp
  801a5f:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801a62:	6a 01                	push   $0x1
  801a64:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a67:	50                   	push   %eax
  801a68:	6a 00                	push   $0x0
  801a6a:	e8 5f f6 ff ff       	call   8010ce <read>
	if (r < 0)
  801a6f:	83 c4 10             	add    $0x10,%esp
  801a72:	85 c0                	test   %eax,%eax
  801a74:	78 06                	js     801a7c <getchar+0x24>
	if (r < 1)
  801a76:	74 06                	je     801a7e <getchar+0x26>
	return c;
  801a78:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801a7c:	c9                   	leave  
  801a7d:	c3                   	ret    
		return -E_EOF;
  801a7e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801a83:	eb f7                	jmp    801a7c <getchar+0x24>

00801a85 <iscons>:
{
  801a85:	f3 0f 1e fb          	endbr32 
  801a89:	55                   	push   %ebp
  801a8a:	89 e5                	mov    %esp,%ebp
  801a8c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a92:	50                   	push   %eax
  801a93:	ff 75 08             	pushl  0x8(%ebp)
  801a96:	e8 b0 f3 ff ff       	call   800e4b <fd_lookup>
  801a9b:	83 c4 10             	add    $0x10,%esp
  801a9e:	85 c0                	test   %eax,%eax
  801aa0:	78 11                	js     801ab3 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801aa2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aa5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801aab:	39 10                	cmp    %edx,(%eax)
  801aad:	0f 94 c0             	sete   %al
  801ab0:	0f b6 c0             	movzbl %al,%eax
}
  801ab3:	c9                   	leave  
  801ab4:	c3                   	ret    

00801ab5 <opencons>:
{
  801ab5:	f3 0f 1e fb          	endbr32 
  801ab9:	55                   	push   %ebp
  801aba:	89 e5                	mov    %esp,%ebp
  801abc:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801abf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ac2:	50                   	push   %eax
  801ac3:	e8 2d f3 ff ff       	call   800df5 <fd_alloc>
  801ac8:	83 c4 10             	add    $0x10,%esp
  801acb:	85 c0                	test   %eax,%eax
  801acd:	78 3a                	js     801b09 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801acf:	83 ec 04             	sub    $0x4,%esp
  801ad2:	68 07 04 00 00       	push   $0x407
  801ad7:	ff 75 f4             	pushl  -0xc(%ebp)
  801ada:	6a 00                	push   $0x0
  801adc:	e8 21 f1 ff ff       	call   800c02 <sys_page_alloc>
  801ae1:	83 c4 10             	add    $0x10,%esp
  801ae4:	85 c0                	test   %eax,%eax
  801ae6:	78 21                	js     801b09 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801ae8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aeb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801af1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801af3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801af6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801afd:	83 ec 0c             	sub    $0xc,%esp
  801b00:	50                   	push   %eax
  801b01:	e8 bc f2 ff ff       	call   800dc2 <fd2num>
  801b06:	83 c4 10             	add    $0x10,%esp
}
  801b09:	c9                   	leave  
  801b0a:	c3                   	ret    

00801b0b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b0b:	f3 0f 1e fb          	endbr32 
  801b0f:	55                   	push   %ebp
  801b10:	89 e5                	mov    %esp,%ebp
  801b12:	56                   	push   %esi
  801b13:	53                   	push   %ebx
  801b14:	8b 75 08             	mov    0x8(%ebp),%esi
  801b17:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b1a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  801b1d:	85 c0                	test   %eax,%eax
  801b1f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b24:	0f 44 c2             	cmove  %edx,%eax
  801b27:	83 ec 0c             	sub    $0xc,%esp
  801b2a:	50                   	push   %eax
  801b2b:	e8 e9 f1 ff ff       	call   800d19 <sys_ipc_recv>

	if (from_env_store != NULL)
  801b30:	83 c4 10             	add    $0x10,%esp
  801b33:	85 f6                	test   %esi,%esi
  801b35:	74 15                	je     801b4c <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  801b37:	ba 00 00 00 00       	mov    $0x0,%edx
  801b3c:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801b3f:	74 09                	je     801b4a <ipc_recv+0x3f>
  801b41:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b47:	8b 52 74             	mov    0x74(%edx),%edx
  801b4a:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  801b4c:	85 db                	test   %ebx,%ebx
  801b4e:	74 15                	je     801b65 <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  801b50:	ba 00 00 00 00       	mov    $0x0,%edx
  801b55:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801b58:	74 09                	je     801b63 <ipc_recv+0x58>
  801b5a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b60:	8b 52 78             	mov    0x78(%edx),%edx
  801b63:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  801b65:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801b68:	74 08                	je     801b72 <ipc_recv+0x67>
  801b6a:	a1 04 40 80 00       	mov    0x804004,%eax
  801b6f:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b72:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b75:	5b                   	pop    %ebx
  801b76:	5e                   	pop    %esi
  801b77:	5d                   	pop    %ebp
  801b78:	c3                   	ret    

00801b79 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b79:	f3 0f 1e fb          	endbr32 
  801b7d:	55                   	push   %ebp
  801b7e:	89 e5                	mov    %esp,%ebp
  801b80:	57                   	push   %edi
  801b81:	56                   	push   %esi
  801b82:	53                   	push   %ebx
  801b83:	83 ec 0c             	sub    $0xc,%esp
  801b86:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b89:	8b 75 0c             	mov    0xc(%ebp),%esi
  801b8c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801b8f:	eb 1f                	jmp    801bb0 <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  801b91:	6a 00                	push   $0x0
  801b93:	68 00 00 c0 ee       	push   $0xeec00000
  801b98:	56                   	push   %esi
  801b99:	57                   	push   %edi
  801b9a:	e8 51 f1 ff ff       	call   800cf0 <sys_ipc_try_send>
  801b9f:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  801ba2:	85 c0                	test   %eax,%eax
  801ba4:	74 30                	je     801bd6 <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  801ba6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ba9:	75 19                	jne    801bc4 <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  801bab:	e8 27 f0 ff ff       	call   800bd7 <sys_yield>
		if (pg != NULL) {
  801bb0:	85 db                	test   %ebx,%ebx
  801bb2:	74 dd                	je     801b91 <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  801bb4:	ff 75 14             	pushl  0x14(%ebp)
  801bb7:	53                   	push   %ebx
  801bb8:	56                   	push   %esi
  801bb9:	57                   	push   %edi
  801bba:	e8 31 f1 ff ff       	call   800cf0 <sys_ipc_try_send>
  801bbf:	83 c4 10             	add    $0x10,%esp
  801bc2:	eb de                	jmp    801ba2 <ipc_send+0x29>
			panic("ipc_send: %d", res);
  801bc4:	50                   	push   %eax
  801bc5:	68 9e 23 80 00       	push   $0x80239e
  801bca:	6a 3e                	push   $0x3e
  801bcc:	68 ab 23 80 00       	push   $0x8023ab
  801bd1:	e8 53 e5 ff ff       	call   800129 <_panic>
	}
}
  801bd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bd9:	5b                   	pop    %ebx
  801bda:	5e                   	pop    %esi
  801bdb:	5f                   	pop    %edi
  801bdc:	5d                   	pop    %ebp
  801bdd:	c3                   	ret    

00801bde <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bde:	f3 0f 1e fb          	endbr32 
  801be2:	55                   	push   %ebp
  801be3:	89 e5                	mov    %esp,%ebp
  801be5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801be8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801bed:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801bf0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801bf6:	8b 52 50             	mov    0x50(%edx),%edx
  801bf9:	39 ca                	cmp    %ecx,%edx
  801bfb:	74 11                	je     801c0e <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801bfd:	83 c0 01             	add    $0x1,%eax
  801c00:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c05:	75 e6                	jne    801bed <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801c07:	b8 00 00 00 00       	mov    $0x0,%eax
  801c0c:	eb 0b                	jmp    801c19 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801c0e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c11:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c16:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c19:	5d                   	pop    %ebp
  801c1a:	c3                   	ret    

00801c1b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c1b:	f3 0f 1e fb          	endbr32 
  801c1f:	55                   	push   %ebp
  801c20:	89 e5                	mov    %esp,%ebp
  801c22:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c25:	89 c2                	mov    %eax,%edx
  801c27:	c1 ea 16             	shr    $0x16,%edx
  801c2a:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c31:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c36:	f6 c1 01             	test   $0x1,%cl
  801c39:	74 1c                	je     801c57 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801c3b:	c1 e8 0c             	shr    $0xc,%eax
  801c3e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c45:	a8 01                	test   $0x1,%al
  801c47:	74 0e                	je     801c57 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c49:	c1 e8 0c             	shr    $0xc,%eax
  801c4c:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c53:	ef 
  801c54:	0f b7 d2             	movzwl %dx,%edx
}
  801c57:	89 d0                	mov    %edx,%eax
  801c59:	5d                   	pop    %ebp
  801c5a:	c3                   	ret    
  801c5b:	66 90                	xchg   %ax,%ax
  801c5d:	66 90                	xchg   %ax,%ax
  801c5f:	90                   	nop

00801c60 <__udivdi3>:
  801c60:	f3 0f 1e fb          	endbr32 
  801c64:	55                   	push   %ebp
  801c65:	57                   	push   %edi
  801c66:	56                   	push   %esi
  801c67:	53                   	push   %ebx
  801c68:	83 ec 1c             	sub    $0x1c,%esp
  801c6b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c6f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801c73:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c77:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801c7b:	85 d2                	test   %edx,%edx
  801c7d:	75 19                	jne    801c98 <__udivdi3+0x38>
  801c7f:	39 f3                	cmp    %esi,%ebx
  801c81:	76 4d                	jbe    801cd0 <__udivdi3+0x70>
  801c83:	31 ff                	xor    %edi,%edi
  801c85:	89 e8                	mov    %ebp,%eax
  801c87:	89 f2                	mov    %esi,%edx
  801c89:	f7 f3                	div    %ebx
  801c8b:	89 fa                	mov    %edi,%edx
  801c8d:	83 c4 1c             	add    $0x1c,%esp
  801c90:	5b                   	pop    %ebx
  801c91:	5e                   	pop    %esi
  801c92:	5f                   	pop    %edi
  801c93:	5d                   	pop    %ebp
  801c94:	c3                   	ret    
  801c95:	8d 76 00             	lea    0x0(%esi),%esi
  801c98:	39 f2                	cmp    %esi,%edx
  801c9a:	76 14                	jbe    801cb0 <__udivdi3+0x50>
  801c9c:	31 ff                	xor    %edi,%edi
  801c9e:	31 c0                	xor    %eax,%eax
  801ca0:	89 fa                	mov    %edi,%edx
  801ca2:	83 c4 1c             	add    $0x1c,%esp
  801ca5:	5b                   	pop    %ebx
  801ca6:	5e                   	pop    %esi
  801ca7:	5f                   	pop    %edi
  801ca8:	5d                   	pop    %ebp
  801ca9:	c3                   	ret    
  801caa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cb0:	0f bd fa             	bsr    %edx,%edi
  801cb3:	83 f7 1f             	xor    $0x1f,%edi
  801cb6:	75 48                	jne    801d00 <__udivdi3+0xa0>
  801cb8:	39 f2                	cmp    %esi,%edx
  801cba:	72 06                	jb     801cc2 <__udivdi3+0x62>
  801cbc:	31 c0                	xor    %eax,%eax
  801cbe:	39 eb                	cmp    %ebp,%ebx
  801cc0:	77 de                	ja     801ca0 <__udivdi3+0x40>
  801cc2:	b8 01 00 00 00       	mov    $0x1,%eax
  801cc7:	eb d7                	jmp    801ca0 <__udivdi3+0x40>
  801cc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cd0:	89 d9                	mov    %ebx,%ecx
  801cd2:	85 db                	test   %ebx,%ebx
  801cd4:	75 0b                	jne    801ce1 <__udivdi3+0x81>
  801cd6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cdb:	31 d2                	xor    %edx,%edx
  801cdd:	f7 f3                	div    %ebx
  801cdf:	89 c1                	mov    %eax,%ecx
  801ce1:	31 d2                	xor    %edx,%edx
  801ce3:	89 f0                	mov    %esi,%eax
  801ce5:	f7 f1                	div    %ecx
  801ce7:	89 c6                	mov    %eax,%esi
  801ce9:	89 e8                	mov    %ebp,%eax
  801ceb:	89 f7                	mov    %esi,%edi
  801ced:	f7 f1                	div    %ecx
  801cef:	89 fa                	mov    %edi,%edx
  801cf1:	83 c4 1c             	add    $0x1c,%esp
  801cf4:	5b                   	pop    %ebx
  801cf5:	5e                   	pop    %esi
  801cf6:	5f                   	pop    %edi
  801cf7:	5d                   	pop    %ebp
  801cf8:	c3                   	ret    
  801cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d00:	89 f9                	mov    %edi,%ecx
  801d02:	b8 20 00 00 00       	mov    $0x20,%eax
  801d07:	29 f8                	sub    %edi,%eax
  801d09:	d3 e2                	shl    %cl,%edx
  801d0b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d0f:	89 c1                	mov    %eax,%ecx
  801d11:	89 da                	mov    %ebx,%edx
  801d13:	d3 ea                	shr    %cl,%edx
  801d15:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d19:	09 d1                	or     %edx,%ecx
  801d1b:	89 f2                	mov    %esi,%edx
  801d1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d21:	89 f9                	mov    %edi,%ecx
  801d23:	d3 e3                	shl    %cl,%ebx
  801d25:	89 c1                	mov    %eax,%ecx
  801d27:	d3 ea                	shr    %cl,%edx
  801d29:	89 f9                	mov    %edi,%ecx
  801d2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d2f:	89 eb                	mov    %ebp,%ebx
  801d31:	d3 e6                	shl    %cl,%esi
  801d33:	89 c1                	mov    %eax,%ecx
  801d35:	d3 eb                	shr    %cl,%ebx
  801d37:	09 de                	or     %ebx,%esi
  801d39:	89 f0                	mov    %esi,%eax
  801d3b:	f7 74 24 08          	divl   0x8(%esp)
  801d3f:	89 d6                	mov    %edx,%esi
  801d41:	89 c3                	mov    %eax,%ebx
  801d43:	f7 64 24 0c          	mull   0xc(%esp)
  801d47:	39 d6                	cmp    %edx,%esi
  801d49:	72 15                	jb     801d60 <__udivdi3+0x100>
  801d4b:	89 f9                	mov    %edi,%ecx
  801d4d:	d3 e5                	shl    %cl,%ebp
  801d4f:	39 c5                	cmp    %eax,%ebp
  801d51:	73 04                	jae    801d57 <__udivdi3+0xf7>
  801d53:	39 d6                	cmp    %edx,%esi
  801d55:	74 09                	je     801d60 <__udivdi3+0x100>
  801d57:	89 d8                	mov    %ebx,%eax
  801d59:	31 ff                	xor    %edi,%edi
  801d5b:	e9 40 ff ff ff       	jmp    801ca0 <__udivdi3+0x40>
  801d60:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801d63:	31 ff                	xor    %edi,%edi
  801d65:	e9 36 ff ff ff       	jmp    801ca0 <__udivdi3+0x40>
  801d6a:	66 90                	xchg   %ax,%ax
  801d6c:	66 90                	xchg   %ax,%ax
  801d6e:	66 90                	xchg   %ax,%ax

00801d70 <__umoddi3>:
  801d70:	f3 0f 1e fb          	endbr32 
  801d74:	55                   	push   %ebp
  801d75:	57                   	push   %edi
  801d76:	56                   	push   %esi
  801d77:	53                   	push   %ebx
  801d78:	83 ec 1c             	sub    $0x1c,%esp
  801d7b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d7f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801d83:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801d87:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d8b:	85 c0                	test   %eax,%eax
  801d8d:	75 19                	jne    801da8 <__umoddi3+0x38>
  801d8f:	39 df                	cmp    %ebx,%edi
  801d91:	76 5d                	jbe    801df0 <__umoddi3+0x80>
  801d93:	89 f0                	mov    %esi,%eax
  801d95:	89 da                	mov    %ebx,%edx
  801d97:	f7 f7                	div    %edi
  801d99:	89 d0                	mov    %edx,%eax
  801d9b:	31 d2                	xor    %edx,%edx
  801d9d:	83 c4 1c             	add    $0x1c,%esp
  801da0:	5b                   	pop    %ebx
  801da1:	5e                   	pop    %esi
  801da2:	5f                   	pop    %edi
  801da3:	5d                   	pop    %ebp
  801da4:	c3                   	ret    
  801da5:	8d 76 00             	lea    0x0(%esi),%esi
  801da8:	89 f2                	mov    %esi,%edx
  801daa:	39 d8                	cmp    %ebx,%eax
  801dac:	76 12                	jbe    801dc0 <__umoddi3+0x50>
  801dae:	89 f0                	mov    %esi,%eax
  801db0:	89 da                	mov    %ebx,%edx
  801db2:	83 c4 1c             	add    $0x1c,%esp
  801db5:	5b                   	pop    %ebx
  801db6:	5e                   	pop    %esi
  801db7:	5f                   	pop    %edi
  801db8:	5d                   	pop    %ebp
  801db9:	c3                   	ret    
  801dba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801dc0:	0f bd e8             	bsr    %eax,%ebp
  801dc3:	83 f5 1f             	xor    $0x1f,%ebp
  801dc6:	75 50                	jne    801e18 <__umoddi3+0xa8>
  801dc8:	39 d8                	cmp    %ebx,%eax
  801dca:	0f 82 e0 00 00 00    	jb     801eb0 <__umoddi3+0x140>
  801dd0:	89 d9                	mov    %ebx,%ecx
  801dd2:	39 f7                	cmp    %esi,%edi
  801dd4:	0f 86 d6 00 00 00    	jbe    801eb0 <__umoddi3+0x140>
  801dda:	89 d0                	mov    %edx,%eax
  801ddc:	89 ca                	mov    %ecx,%edx
  801dde:	83 c4 1c             	add    $0x1c,%esp
  801de1:	5b                   	pop    %ebx
  801de2:	5e                   	pop    %esi
  801de3:	5f                   	pop    %edi
  801de4:	5d                   	pop    %ebp
  801de5:	c3                   	ret    
  801de6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ded:	8d 76 00             	lea    0x0(%esi),%esi
  801df0:	89 fd                	mov    %edi,%ebp
  801df2:	85 ff                	test   %edi,%edi
  801df4:	75 0b                	jne    801e01 <__umoddi3+0x91>
  801df6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dfb:	31 d2                	xor    %edx,%edx
  801dfd:	f7 f7                	div    %edi
  801dff:	89 c5                	mov    %eax,%ebp
  801e01:	89 d8                	mov    %ebx,%eax
  801e03:	31 d2                	xor    %edx,%edx
  801e05:	f7 f5                	div    %ebp
  801e07:	89 f0                	mov    %esi,%eax
  801e09:	f7 f5                	div    %ebp
  801e0b:	89 d0                	mov    %edx,%eax
  801e0d:	31 d2                	xor    %edx,%edx
  801e0f:	eb 8c                	jmp    801d9d <__umoddi3+0x2d>
  801e11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e18:	89 e9                	mov    %ebp,%ecx
  801e1a:	ba 20 00 00 00       	mov    $0x20,%edx
  801e1f:	29 ea                	sub    %ebp,%edx
  801e21:	d3 e0                	shl    %cl,%eax
  801e23:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e27:	89 d1                	mov    %edx,%ecx
  801e29:	89 f8                	mov    %edi,%eax
  801e2b:	d3 e8                	shr    %cl,%eax
  801e2d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801e31:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e35:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e39:	09 c1                	or     %eax,%ecx
  801e3b:	89 d8                	mov    %ebx,%eax
  801e3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e41:	89 e9                	mov    %ebp,%ecx
  801e43:	d3 e7                	shl    %cl,%edi
  801e45:	89 d1                	mov    %edx,%ecx
  801e47:	d3 e8                	shr    %cl,%eax
  801e49:	89 e9                	mov    %ebp,%ecx
  801e4b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e4f:	d3 e3                	shl    %cl,%ebx
  801e51:	89 c7                	mov    %eax,%edi
  801e53:	89 d1                	mov    %edx,%ecx
  801e55:	89 f0                	mov    %esi,%eax
  801e57:	d3 e8                	shr    %cl,%eax
  801e59:	89 e9                	mov    %ebp,%ecx
  801e5b:	89 fa                	mov    %edi,%edx
  801e5d:	d3 e6                	shl    %cl,%esi
  801e5f:	09 d8                	or     %ebx,%eax
  801e61:	f7 74 24 08          	divl   0x8(%esp)
  801e65:	89 d1                	mov    %edx,%ecx
  801e67:	89 f3                	mov    %esi,%ebx
  801e69:	f7 64 24 0c          	mull   0xc(%esp)
  801e6d:	89 c6                	mov    %eax,%esi
  801e6f:	89 d7                	mov    %edx,%edi
  801e71:	39 d1                	cmp    %edx,%ecx
  801e73:	72 06                	jb     801e7b <__umoddi3+0x10b>
  801e75:	75 10                	jne    801e87 <__umoddi3+0x117>
  801e77:	39 c3                	cmp    %eax,%ebx
  801e79:	73 0c                	jae    801e87 <__umoddi3+0x117>
  801e7b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801e7f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801e83:	89 d7                	mov    %edx,%edi
  801e85:	89 c6                	mov    %eax,%esi
  801e87:	89 ca                	mov    %ecx,%edx
  801e89:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801e8e:	29 f3                	sub    %esi,%ebx
  801e90:	19 fa                	sbb    %edi,%edx
  801e92:	89 d0                	mov    %edx,%eax
  801e94:	d3 e0                	shl    %cl,%eax
  801e96:	89 e9                	mov    %ebp,%ecx
  801e98:	d3 eb                	shr    %cl,%ebx
  801e9a:	d3 ea                	shr    %cl,%edx
  801e9c:	09 d8                	or     %ebx,%eax
  801e9e:	83 c4 1c             	add    $0x1c,%esp
  801ea1:	5b                   	pop    %ebx
  801ea2:	5e                   	pop    %esi
  801ea3:	5f                   	pop    %edi
  801ea4:	5d                   	pop    %ebp
  801ea5:	c3                   	ret    
  801ea6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ead:	8d 76 00             	lea    0x0(%esi),%esi
  801eb0:	29 fe                	sub    %edi,%esi
  801eb2:	19 c3                	sbb    %eax,%ebx
  801eb4:	89 f2                	mov    %esi,%edx
  801eb6:	89 d9                	mov    %ebx,%ecx
  801eb8:	e9 1d ff ff ff       	jmp    801dda <__umoddi3+0x6a>
