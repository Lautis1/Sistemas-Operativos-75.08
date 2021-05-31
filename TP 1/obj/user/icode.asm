
obj/user/icode.debug:     formato del fichero elf32-i386


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
  80002c:	e8 07 01 00 00       	call   800138 <libmain>
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
  80003c:	81 ec 1c 02 00 00    	sub    $0x21c,%esp
	int fd, n, r;
	char buf[512+1];

	binaryname = "icode";
  800042:	c7 05 00 30 80 00 c0 	movl   $0x8024c0,0x803000
  800049:	24 80 00 

	cprintf("icode startup\n");
  80004c:	68 c6 24 80 00       	push   $0x8024c6
  800051:	e8 35 02 00 00       	call   80028b <cprintf>

	cprintf("icode: open /motd\n");
  800056:	c7 04 24 d5 24 80 00 	movl   $0x8024d5,(%esp)
  80005d:	e8 29 02 00 00       	call   80028b <cprintf>
	if ((fd = open("/motd", O_RDONLY)) < 0)
  800062:	83 c4 08             	add    $0x8,%esp
  800065:	6a 00                	push   $0x0
  800067:	68 e8 24 80 00       	push   $0x8024e8
  80006c:	e8 ea 14 00 00       	call   80155b <open>
  800071:	89 c6                	mov    %eax,%esi
  800073:	83 c4 10             	add    $0x10,%esp
  800076:	85 c0                	test   %eax,%eax
  800078:	78 18                	js     800092 <umain+0x5f>
		panic("icode: open /motd: %e", fd);

	cprintf("icode: read /motd\n");
  80007a:	83 ec 0c             	sub    $0xc,%esp
  80007d:	68 11 25 80 00       	push   $0x802511
  800082:	e8 04 02 00 00       	call   80028b <cprintf>
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  800087:	83 c4 10             	add    $0x10,%esp
  80008a:	8d 9d f7 fd ff ff    	lea    -0x209(%ebp),%ebx
  800090:	eb 1f                	jmp    8000b1 <umain+0x7e>
		panic("icode: open /motd: %e", fd);
  800092:	50                   	push   %eax
  800093:	68 ee 24 80 00       	push   $0x8024ee
  800098:	6a 0f                	push   $0xf
  80009a:	68 04 25 80 00       	push   $0x802504
  80009f:	e8 00 01 00 00       	call   8001a4 <_panic>
		sys_cputs(buf, n);
  8000a4:	83 ec 08             	sub    $0x8,%esp
  8000a7:	50                   	push   %eax
  8000a8:	53                   	push   %ebx
  8000a9:	e8 04 0b 00 00       	call   800bb2 <sys_cputs>
  8000ae:	83 c4 10             	add    $0x10,%esp
	while ((n = read(fd, buf, sizeof buf-1)) > 0)
  8000b1:	83 ec 04             	sub    $0x4,%esp
  8000b4:	68 00 02 00 00       	push   $0x200
  8000b9:	53                   	push   %ebx
  8000ba:	56                   	push   %esi
  8000bb:	e8 06 10 00 00       	call   8010c6 <read>
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	85 c0                	test   %eax,%eax
  8000c5:	7f dd                	jg     8000a4 <umain+0x71>

	cprintf("icode: close /motd\n");
  8000c7:	83 ec 0c             	sub    $0xc,%esp
  8000ca:	68 24 25 80 00       	push   $0x802524
  8000cf:	e8 b7 01 00 00       	call   80028b <cprintf>
	close(fd);
  8000d4:	89 34 24             	mov    %esi,(%esp)
  8000d7:	e8 a0 0e 00 00       	call   800f7c <close>

	cprintf("icode: spawn /init\n");
  8000dc:	c7 04 24 38 25 80 00 	movl   $0x802538,(%esp)
  8000e3:	e8 a3 01 00 00       	call   80028b <cprintf>
	if ((r = spawnl("/init", "init", "initarg1", "initarg2", (char*)0)) < 0)
  8000e8:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  8000ef:	68 4c 25 80 00       	push   $0x80254c
  8000f4:	68 55 25 80 00       	push   $0x802555
  8000f9:	68 5f 25 80 00       	push   $0x80255f
  8000fe:	68 5e 25 80 00       	push   $0x80255e
  800103:	e8 56 1a 00 00       	call   801b5e <spawnl>
  800108:	83 c4 20             	add    $0x20,%esp
  80010b:	85 c0                	test   %eax,%eax
  80010d:	78 17                	js     800126 <umain+0xf3>
		panic("icode: spawn /init: %e", r);

	cprintf("icode: exiting\n");
  80010f:	83 ec 0c             	sub    $0xc,%esp
  800112:	68 7b 25 80 00       	push   $0x80257b
  800117:	e8 6f 01 00 00       	call   80028b <cprintf>
}
  80011c:	83 c4 10             	add    $0x10,%esp
  80011f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800122:	5b                   	pop    %ebx
  800123:	5e                   	pop    %esi
  800124:	5d                   	pop    %ebp
  800125:	c3                   	ret    
		panic("icode: spawn /init: %e", r);
  800126:	50                   	push   %eax
  800127:	68 64 25 80 00       	push   $0x802564
  80012c:	6a 1a                	push   $0x1a
  80012e:	68 04 25 80 00       	push   $0x802504
  800133:	e8 6c 00 00 00       	call   8001a4 <_panic>

00800138 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800138:	f3 0f 1e fb          	endbr32 
  80013c:	55                   	push   %ebp
  80013d:	89 e5                	mov    %esp,%ebp
  80013f:	56                   	push   %esi
  800140:	53                   	push   %ebx
  800141:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800144:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800147:	e8 de 0a 00 00       	call   800c2a <sys_getenvid>
	if (id >= 0)
  80014c:	85 c0                	test   %eax,%eax
  80014e:	78 12                	js     800162 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800150:	25 ff 03 00 00       	and    $0x3ff,%eax
  800155:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800158:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80015d:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800162:	85 db                	test   %ebx,%ebx
  800164:	7e 07                	jle    80016d <libmain+0x35>
		binaryname = argv[0];
  800166:	8b 06                	mov    (%esi),%eax
  800168:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80016d:	83 ec 08             	sub    $0x8,%esp
  800170:	56                   	push   %esi
  800171:	53                   	push   %ebx
  800172:	e8 bc fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800177:	e8 0a 00 00 00       	call   800186 <exit>
}
  80017c:	83 c4 10             	add    $0x10,%esp
  80017f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800182:	5b                   	pop    %ebx
  800183:	5e                   	pop    %esi
  800184:	5d                   	pop    %ebp
  800185:	c3                   	ret    

00800186 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800186:	f3 0f 1e fb          	endbr32 
  80018a:	55                   	push   %ebp
  80018b:	89 e5                	mov    %esp,%ebp
  80018d:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800190:	e8 18 0e 00 00       	call   800fad <close_all>
	sys_env_destroy(0);
  800195:	83 ec 0c             	sub    $0xc,%esp
  800198:	6a 00                	push   $0x0
  80019a:	e8 65 0a 00 00       	call   800c04 <sys_env_destroy>
}
  80019f:	83 c4 10             	add    $0x10,%esp
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    

008001a4 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001a4:	f3 0f 1e fb          	endbr32 
  8001a8:	55                   	push   %ebp
  8001a9:	89 e5                	mov    %esp,%ebp
  8001ab:	56                   	push   %esi
  8001ac:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001ad:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001b0:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001b6:	e8 6f 0a 00 00       	call   800c2a <sys_getenvid>
  8001bb:	83 ec 0c             	sub    $0xc,%esp
  8001be:	ff 75 0c             	pushl  0xc(%ebp)
  8001c1:	ff 75 08             	pushl  0x8(%ebp)
  8001c4:	56                   	push   %esi
  8001c5:	50                   	push   %eax
  8001c6:	68 98 25 80 00       	push   $0x802598
  8001cb:	e8 bb 00 00 00       	call   80028b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001d0:	83 c4 18             	add    $0x18,%esp
  8001d3:	53                   	push   %ebx
  8001d4:	ff 75 10             	pushl  0x10(%ebp)
  8001d7:	e8 5a 00 00 00       	call   800236 <vcprintf>
	cprintf("\n");
  8001dc:	c7 04 24 76 2a 80 00 	movl   $0x802a76,(%esp)
  8001e3:	e8 a3 00 00 00       	call   80028b <cprintf>
  8001e8:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001eb:	cc                   	int3   
  8001ec:	eb fd                	jmp    8001eb <_panic+0x47>

008001ee <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001ee:	f3 0f 1e fb          	endbr32 
  8001f2:	55                   	push   %ebp
  8001f3:	89 e5                	mov    %esp,%ebp
  8001f5:	53                   	push   %ebx
  8001f6:	83 ec 04             	sub    $0x4,%esp
  8001f9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001fc:	8b 13                	mov    (%ebx),%edx
  8001fe:	8d 42 01             	lea    0x1(%edx),%eax
  800201:	89 03                	mov    %eax,(%ebx)
  800203:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800206:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80020a:	3d ff 00 00 00       	cmp    $0xff,%eax
  80020f:	74 09                	je     80021a <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800211:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800215:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800218:	c9                   	leave  
  800219:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80021a:	83 ec 08             	sub    $0x8,%esp
  80021d:	68 ff 00 00 00       	push   $0xff
  800222:	8d 43 08             	lea    0x8(%ebx),%eax
  800225:	50                   	push   %eax
  800226:	e8 87 09 00 00       	call   800bb2 <sys_cputs>
		b->idx = 0;
  80022b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800231:	83 c4 10             	add    $0x10,%esp
  800234:	eb db                	jmp    800211 <putch+0x23>

00800236 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800236:	f3 0f 1e fb          	endbr32 
  80023a:	55                   	push   %ebp
  80023b:	89 e5                	mov    %esp,%ebp
  80023d:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800243:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80024a:	00 00 00 
	b.cnt = 0;
  80024d:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800254:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800257:	ff 75 0c             	pushl  0xc(%ebp)
  80025a:	ff 75 08             	pushl  0x8(%ebp)
  80025d:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800263:	50                   	push   %eax
  800264:	68 ee 01 80 00       	push   $0x8001ee
  800269:	e8 80 01 00 00       	call   8003ee <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026e:	83 c4 08             	add    $0x8,%esp
  800271:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800277:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027d:	50                   	push   %eax
  80027e:	e8 2f 09 00 00       	call   800bb2 <sys_cputs>

	return b.cnt;
}
  800283:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800289:	c9                   	leave  
  80028a:	c3                   	ret    

0080028b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80028b:	f3 0f 1e fb          	endbr32 
  80028f:	55                   	push   %ebp
  800290:	89 e5                	mov    %esp,%ebp
  800292:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800295:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800298:	50                   	push   %eax
  800299:	ff 75 08             	pushl  0x8(%ebp)
  80029c:	e8 95 ff ff ff       	call   800236 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002a1:	c9                   	leave  
  8002a2:	c3                   	ret    

008002a3 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a3:	55                   	push   %ebp
  8002a4:	89 e5                	mov    %esp,%ebp
  8002a6:	57                   	push   %edi
  8002a7:	56                   	push   %esi
  8002a8:	53                   	push   %ebx
  8002a9:	83 ec 1c             	sub    $0x1c,%esp
  8002ac:	89 c7                	mov    %eax,%edi
  8002ae:	89 d6                	mov    %edx,%esi
  8002b0:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b6:	89 d1                	mov    %edx,%ecx
  8002b8:	89 c2                	mov    %eax,%edx
  8002ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002bd:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002c0:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c3:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c6:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002c9:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002d0:	39 c2                	cmp    %eax,%edx
  8002d2:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002d5:	72 3e                	jb     800315 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d7:	83 ec 0c             	sub    $0xc,%esp
  8002da:	ff 75 18             	pushl  0x18(%ebp)
  8002dd:	83 eb 01             	sub    $0x1,%ebx
  8002e0:	53                   	push   %ebx
  8002e1:	50                   	push   %eax
  8002e2:	83 ec 08             	sub    $0x8,%esp
  8002e5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e8:	ff 75 e0             	pushl  -0x20(%ebp)
  8002eb:	ff 75 dc             	pushl  -0x24(%ebp)
  8002ee:	ff 75 d8             	pushl  -0x28(%ebp)
  8002f1:	e8 6a 1f 00 00       	call   802260 <__udivdi3>
  8002f6:	83 c4 18             	add    $0x18,%esp
  8002f9:	52                   	push   %edx
  8002fa:	50                   	push   %eax
  8002fb:	89 f2                	mov    %esi,%edx
  8002fd:	89 f8                	mov    %edi,%eax
  8002ff:	e8 9f ff ff ff       	call   8002a3 <printnum>
  800304:	83 c4 20             	add    $0x20,%esp
  800307:	eb 13                	jmp    80031c <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800309:	83 ec 08             	sub    $0x8,%esp
  80030c:	56                   	push   %esi
  80030d:	ff 75 18             	pushl  0x18(%ebp)
  800310:	ff d7                	call   *%edi
  800312:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800315:	83 eb 01             	sub    $0x1,%ebx
  800318:	85 db                	test   %ebx,%ebx
  80031a:	7f ed                	jg     800309 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80031c:	83 ec 08             	sub    $0x8,%esp
  80031f:	56                   	push   %esi
  800320:	83 ec 04             	sub    $0x4,%esp
  800323:	ff 75 e4             	pushl  -0x1c(%ebp)
  800326:	ff 75 e0             	pushl  -0x20(%ebp)
  800329:	ff 75 dc             	pushl  -0x24(%ebp)
  80032c:	ff 75 d8             	pushl  -0x28(%ebp)
  80032f:	e8 3c 20 00 00       	call   802370 <__umoddi3>
  800334:	83 c4 14             	add    $0x14,%esp
  800337:	0f be 80 bb 25 80 00 	movsbl 0x8025bb(%eax),%eax
  80033e:	50                   	push   %eax
  80033f:	ff d7                	call   *%edi
}
  800341:	83 c4 10             	add    $0x10,%esp
  800344:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800347:	5b                   	pop    %ebx
  800348:	5e                   	pop    %esi
  800349:	5f                   	pop    %edi
  80034a:	5d                   	pop    %ebp
  80034b:	c3                   	ret    

0080034c <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80034c:	83 fa 01             	cmp    $0x1,%edx
  80034f:	7f 13                	jg     800364 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800351:	85 d2                	test   %edx,%edx
  800353:	74 1c                	je     800371 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800355:	8b 10                	mov    (%eax),%edx
  800357:	8d 4a 04             	lea    0x4(%edx),%ecx
  80035a:	89 08                	mov    %ecx,(%eax)
  80035c:	8b 02                	mov    (%edx),%eax
  80035e:	ba 00 00 00 00       	mov    $0x0,%edx
  800363:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800364:	8b 10                	mov    (%eax),%edx
  800366:	8d 4a 08             	lea    0x8(%edx),%ecx
  800369:	89 08                	mov    %ecx,(%eax)
  80036b:	8b 02                	mov    (%edx),%eax
  80036d:	8b 52 04             	mov    0x4(%edx),%edx
  800370:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800371:	8b 10                	mov    (%eax),%edx
  800373:	8d 4a 04             	lea    0x4(%edx),%ecx
  800376:	89 08                	mov    %ecx,(%eax)
  800378:	8b 02                	mov    (%edx),%eax
  80037a:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037f:	c3                   	ret    

00800380 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800380:	83 fa 01             	cmp    $0x1,%edx
  800383:	7f 0f                	jg     800394 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800385:	85 d2                	test   %edx,%edx
  800387:	74 18                	je     8003a1 <getint+0x21>
		return va_arg(*ap, long);
  800389:	8b 10                	mov    (%eax),%edx
  80038b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038e:	89 08                	mov    %ecx,(%eax)
  800390:	8b 02                	mov    (%edx),%eax
  800392:	99                   	cltd   
  800393:	c3                   	ret    
		return va_arg(*ap, long long);
  800394:	8b 10                	mov    (%eax),%edx
  800396:	8d 4a 08             	lea    0x8(%edx),%ecx
  800399:	89 08                	mov    %ecx,(%eax)
  80039b:	8b 02                	mov    (%edx),%eax
  80039d:	8b 52 04             	mov    0x4(%edx),%edx
  8003a0:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8003a1:	8b 10                	mov    (%eax),%edx
  8003a3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a6:	89 08                	mov    %ecx,(%eax)
  8003a8:	8b 02                	mov    (%edx),%eax
  8003aa:	99                   	cltd   
}
  8003ab:	c3                   	ret    

008003ac <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003ac:	f3 0f 1e fb          	endbr32 
  8003b0:	55                   	push   %ebp
  8003b1:	89 e5                	mov    %esp,%ebp
  8003b3:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b6:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ba:	8b 10                	mov    (%eax),%edx
  8003bc:	3b 50 04             	cmp    0x4(%eax),%edx
  8003bf:	73 0a                	jae    8003cb <sprintputch+0x1f>
		*b->buf++ = ch;
  8003c1:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003c4:	89 08                	mov    %ecx,(%eax)
  8003c6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c9:	88 02                	mov    %al,(%edx)
}
  8003cb:	5d                   	pop    %ebp
  8003cc:	c3                   	ret    

008003cd <printfmt>:
{
  8003cd:	f3 0f 1e fb          	endbr32 
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003d7:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003da:	50                   	push   %eax
  8003db:	ff 75 10             	pushl  0x10(%ebp)
  8003de:	ff 75 0c             	pushl  0xc(%ebp)
  8003e1:	ff 75 08             	pushl  0x8(%ebp)
  8003e4:	e8 05 00 00 00       	call   8003ee <vprintfmt>
}
  8003e9:	83 c4 10             	add    $0x10,%esp
  8003ec:	c9                   	leave  
  8003ed:	c3                   	ret    

008003ee <vprintfmt>:
{
  8003ee:	f3 0f 1e fb          	endbr32 
  8003f2:	55                   	push   %ebp
  8003f3:	89 e5                	mov    %esp,%ebp
  8003f5:	57                   	push   %edi
  8003f6:	56                   	push   %esi
  8003f7:	53                   	push   %ebx
  8003f8:	83 ec 2c             	sub    $0x2c,%esp
  8003fb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003fe:	8b 75 0c             	mov    0xc(%ebp),%esi
  800401:	8b 7d 10             	mov    0x10(%ebp),%edi
  800404:	e9 86 02 00 00       	jmp    80068f <vprintfmt+0x2a1>
		padc = ' ';
  800409:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80040d:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800414:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80041b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800422:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800427:	8d 47 01             	lea    0x1(%edi),%eax
  80042a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80042d:	0f b6 17             	movzbl (%edi),%edx
  800430:	8d 42 dd             	lea    -0x23(%edx),%eax
  800433:	3c 55                	cmp    $0x55,%al
  800435:	0f 87 df 02 00 00    	ja     80071a <vprintfmt+0x32c>
  80043b:	0f b6 c0             	movzbl %al,%eax
  80043e:	3e ff 24 85 00 27 80 	notrack jmp *0x802700(,%eax,4)
  800445:	00 
  800446:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800449:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80044d:	eb d8                	jmp    800427 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80044f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800452:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800456:	eb cf                	jmp    800427 <vprintfmt+0x39>
  800458:	0f b6 d2             	movzbl %dl,%edx
  80045b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80045e:	b8 00 00 00 00       	mov    $0x0,%eax
  800463:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800466:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800469:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80046d:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800470:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800473:	83 f9 09             	cmp    $0x9,%ecx
  800476:	77 52                	ja     8004ca <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  800478:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80047b:	eb e9                	jmp    800466 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80047d:	8b 45 14             	mov    0x14(%ebp),%eax
  800480:	8d 50 04             	lea    0x4(%eax),%edx
  800483:	89 55 14             	mov    %edx,0x14(%ebp)
  800486:	8b 00                	mov    (%eax),%eax
  800488:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80048b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80048e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800492:	79 93                	jns    800427 <vprintfmt+0x39>
				width = precision, precision = -1;
  800494:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800497:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80049a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004a1:	eb 84                	jmp    800427 <vprintfmt+0x39>
  8004a3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a6:	85 c0                	test   %eax,%eax
  8004a8:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ad:	0f 49 d0             	cmovns %eax,%edx
  8004b0:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004b3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004b6:	e9 6c ff ff ff       	jmp    800427 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8004bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004be:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004c5:	e9 5d ff ff ff       	jmp    800427 <vprintfmt+0x39>
  8004ca:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004cd:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004d0:	eb bc                	jmp    80048e <vprintfmt+0xa0>
			lflag++;
  8004d2:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004d5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004d8:	e9 4a ff ff ff       	jmp    800427 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8004dd:	8b 45 14             	mov    0x14(%ebp),%eax
  8004e0:	8d 50 04             	lea    0x4(%eax),%edx
  8004e3:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e6:	83 ec 08             	sub    $0x8,%esp
  8004e9:	56                   	push   %esi
  8004ea:	ff 30                	pushl  (%eax)
  8004ec:	ff d3                	call   *%ebx
			break;
  8004ee:	83 c4 10             	add    $0x10,%esp
  8004f1:	e9 96 01 00 00       	jmp    80068c <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8004f6:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f9:	8d 50 04             	lea    0x4(%eax),%edx
  8004fc:	89 55 14             	mov    %edx,0x14(%ebp)
  8004ff:	8b 00                	mov    (%eax),%eax
  800501:	99                   	cltd   
  800502:	31 d0                	xor    %edx,%eax
  800504:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800506:	83 f8 0f             	cmp    $0xf,%eax
  800509:	7f 20                	jg     80052b <vprintfmt+0x13d>
  80050b:	8b 14 85 60 28 80 00 	mov    0x802860(,%eax,4),%edx
  800512:	85 d2                	test   %edx,%edx
  800514:	74 15                	je     80052b <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  800516:	52                   	push   %edx
  800517:	68 91 29 80 00       	push   $0x802991
  80051c:	56                   	push   %esi
  80051d:	53                   	push   %ebx
  80051e:	e8 aa fe ff ff       	call   8003cd <printfmt>
  800523:	83 c4 10             	add    $0x10,%esp
  800526:	e9 61 01 00 00       	jmp    80068c <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  80052b:	50                   	push   %eax
  80052c:	68 d3 25 80 00       	push   $0x8025d3
  800531:	56                   	push   %esi
  800532:	53                   	push   %ebx
  800533:	e8 95 fe ff ff       	call   8003cd <printfmt>
  800538:	83 c4 10             	add    $0x10,%esp
  80053b:	e9 4c 01 00 00       	jmp    80068c <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  800540:	8b 45 14             	mov    0x14(%ebp),%eax
  800543:	8d 50 04             	lea    0x4(%eax),%edx
  800546:	89 55 14             	mov    %edx,0x14(%ebp)
  800549:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  80054b:	85 c9                	test   %ecx,%ecx
  80054d:	b8 cc 25 80 00       	mov    $0x8025cc,%eax
  800552:	0f 45 c1             	cmovne %ecx,%eax
  800555:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800558:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80055c:	7e 06                	jle    800564 <vprintfmt+0x176>
  80055e:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800562:	75 0d                	jne    800571 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  800564:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800567:	89 c7                	mov    %eax,%edi
  800569:	03 45 e0             	add    -0x20(%ebp),%eax
  80056c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80056f:	eb 57                	jmp    8005c8 <vprintfmt+0x1da>
  800571:	83 ec 08             	sub    $0x8,%esp
  800574:	ff 75 d8             	pushl  -0x28(%ebp)
  800577:	ff 75 cc             	pushl  -0x34(%ebp)
  80057a:	e8 4f 02 00 00       	call   8007ce <strnlen>
  80057f:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800582:	29 c2                	sub    %eax,%edx
  800584:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800587:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80058a:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80058e:	89 5d 08             	mov    %ebx,0x8(%ebp)
  800591:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800593:	85 db                	test   %ebx,%ebx
  800595:	7e 10                	jle    8005a7 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800597:	83 ec 08             	sub    $0x8,%esp
  80059a:	56                   	push   %esi
  80059b:	57                   	push   %edi
  80059c:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80059f:	83 eb 01             	sub    $0x1,%ebx
  8005a2:	83 c4 10             	add    $0x10,%esp
  8005a5:	eb ec                	jmp    800593 <vprintfmt+0x1a5>
  8005a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005aa:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005ad:	85 d2                	test   %edx,%edx
  8005af:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b4:	0f 49 c2             	cmovns %edx,%eax
  8005b7:	29 c2                	sub    %eax,%edx
  8005b9:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005bc:	eb a6                	jmp    800564 <vprintfmt+0x176>
					putch(ch, putdat);
  8005be:	83 ec 08             	sub    $0x8,%esp
  8005c1:	56                   	push   %esi
  8005c2:	52                   	push   %edx
  8005c3:	ff d3                	call   *%ebx
  8005c5:	83 c4 10             	add    $0x10,%esp
  8005c8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005cb:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005cd:	83 c7 01             	add    $0x1,%edi
  8005d0:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005d4:	0f be d0             	movsbl %al,%edx
  8005d7:	85 d2                	test   %edx,%edx
  8005d9:	74 42                	je     80061d <vprintfmt+0x22f>
  8005db:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005df:	78 06                	js     8005e7 <vprintfmt+0x1f9>
  8005e1:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005e5:	78 1e                	js     800605 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  8005e7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005eb:	74 d1                	je     8005be <vprintfmt+0x1d0>
  8005ed:	0f be c0             	movsbl %al,%eax
  8005f0:	83 e8 20             	sub    $0x20,%eax
  8005f3:	83 f8 5e             	cmp    $0x5e,%eax
  8005f6:	76 c6                	jbe    8005be <vprintfmt+0x1d0>
					putch('?', putdat);
  8005f8:	83 ec 08             	sub    $0x8,%esp
  8005fb:	56                   	push   %esi
  8005fc:	6a 3f                	push   $0x3f
  8005fe:	ff d3                	call   *%ebx
  800600:	83 c4 10             	add    $0x10,%esp
  800603:	eb c3                	jmp    8005c8 <vprintfmt+0x1da>
  800605:	89 cf                	mov    %ecx,%edi
  800607:	eb 0e                	jmp    800617 <vprintfmt+0x229>
				putch(' ', putdat);
  800609:	83 ec 08             	sub    $0x8,%esp
  80060c:	56                   	push   %esi
  80060d:	6a 20                	push   $0x20
  80060f:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800611:	83 ef 01             	sub    $0x1,%edi
  800614:	83 c4 10             	add    $0x10,%esp
  800617:	85 ff                	test   %edi,%edi
  800619:	7f ee                	jg     800609 <vprintfmt+0x21b>
  80061b:	eb 6f                	jmp    80068c <vprintfmt+0x29e>
  80061d:	89 cf                	mov    %ecx,%edi
  80061f:	eb f6                	jmp    800617 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  800621:	89 ca                	mov    %ecx,%edx
  800623:	8d 45 14             	lea    0x14(%ebp),%eax
  800626:	e8 55 fd ff ff       	call   800380 <getint>
  80062b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062e:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800631:	85 d2                	test   %edx,%edx
  800633:	78 0b                	js     800640 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  800635:	89 d1                	mov    %edx,%ecx
  800637:	89 c2                	mov    %eax,%edx
			base = 10;
  800639:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063e:	eb 32                	jmp    800672 <vprintfmt+0x284>
				putch('-', putdat);
  800640:	83 ec 08             	sub    $0x8,%esp
  800643:	56                   	push   %esi
  800644:	6a 2d                	push   $0x2d
  800646:	ff d3                	call   *%ebx
				num = -(long long) num;
  800648:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80064b:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80064e:	f7 da                	neg    %edx
  800650:	83 d1 00             	adc    $0x0,%ecx
  800653:	f7 d9                	neg    %ecx
  800655:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800658:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065d:	eb 13                	jmp    800672 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  80065f:	89 ca                	mov    %ecx,%edx
  800661:	8d 45 14             	lea    0x14(%ebp),%eax
  800664:	e8 e3 fc ff ff       	call   80034c <getuint>
  800669:	89 d1                	mov    %edx,%ecx
  80066b:	89 c2                	mov    %eax,%edx
			base = 10;
  80066d:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  800672:	83 ec 0c             	sub    $0xc,%esp
  800675:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800679:	57                   	push   %edi
  80067a:	ff 75 e0             	pushl  -0x20(%ebp)
  80067d:	50                   	push   %eax
  80067e:	51                   	push   %ecx
  80067f:	52                   	push   %edx
  800680:	89 f2                	mov    %esi,%edx
  800682:	89 d8                	mov    %ebx,%eax
  800684:	e8 1a fc ff ff       	call   8002a3 <printnum>
			break;
  800689:	83 c4 20             	add    $0x20,%esp
{
  80068c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80068f:	83 c7 01             	add    $0x1,%edi
  800692:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800696:	83 f8 25             	cmp    $0x25,%eax
  800699:	0f 84 6a fd ff ff    	je     800409 <vprintfmt+0x1b>
			if (ch == '\0')
  80069f:	85 c0                	test   %eax,%eax
  8006a1:	0f 84 93 00 00 00    	je     80073a <vprintfmt+0x34c>
			putch(ch, putdat);
  8006a7:	83 ec 08             	sub    $0x8,%esp
  8006aa:	56                   	push   %esi
  8006ab:	50                   	push   %eax
  8006ac:	ff d3                	call   *%ebx
  8006ae:	83 c4 10             	add    $0x10,%esp
  8006b1:	eb dc                	jmp    80068f <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  8006b3:	89 ca                	mov    %ecx,%edx
  8006b5:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b8:	e8 8f fc ff ff       	call   80034c <getuint>
  8006bd:	89 d1                	mov    %edx,%ecx
  8006bf:	89 c2                	mov    %eax,%edx
			base = 8;
  8006c1:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006c6:	eb aa                	jmp    800672 <vprintfmt+0x284>
			putch('0', putdat);
  8006c8:	83 ec 08             	sub    $0x8,%esp
  8006cb:	56                   	push   %esi
  8006cc:	6a 30                	push   $0x30
  8006ce:	ff d3                	call   *%ebx
			putch('x', putdat);
  8006d0:	83 c4 08             	add    $0x8,%esp
  8006d3:	56                   	push   %esi
  8006d4:	6a 78                	push   $0x78
  8006d6:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  8006d8:	8b 45 14             	mov    0x14(%ebp),%eax
  8006db:	8d 50 04             	lea    0x4(%eax),%edx
  8006de:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8006e1:	8b 10                	mov    (%eax),%edx
  8006e3:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006e8:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8006eb:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006f0:	eb 80                	jmp    800672 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8006f2:	89 ca                	mov    %ecx,%edx
  8006f4:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f7:	e8 50 fc ff ff       	call   80034c <getuint>
  8006fc:	89 d1                	mov    %edx,%ecx
  8006fe:	89 c2                	mov    %eax,%edx
			base = 16;
  800700:	b8 10 00 00 00       	mov    $0x10,%eax
  800705:	e9 68 ff ff ff       	jmp    800672 <vprintfmt+0x284>
			putch(ch, putdat);
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	56                   	push   %esi
  80070e:	6a 25                	push   $0x25
  800710:	ff d3                	call   *%ebx
			break;
  800712:	83 c4 10             	add    $0x10,%esp
  800715:	e9 72 ff ff ff       	jmp    80068c <vprintfmt+0x29e>
			putch('%', putdat);
  80071a:	83 ec 08             	sub    $0x8,%esp
  80071d:	56                   	push   %esi
  80071e:	6a 25                	push   $0x25
  800720:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800722:	83 c4 10             	add    $0x10,%esp
  800725:	89 f8                	mov    %edi,%eax
  800727:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80072b:	74 05                	je     800732 <vprintfmt+0x344>
  80072d:	83 e8 01             	sub    $0x1,%eax
  800730:	eb f5                	jmp    800727 <vprintfmt+0x339>
  800732:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800735:	e9 52 ff ff ff       	jmp    80068c <vprintfmt+0x29e>
}
  80073a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80073d:	5b                   	pop    %ebx
  80073e:	5e                   	pop    %esi
  80073f:	5f                   	pop    %edi
  800740:	5d                   	pop    %ebp
  800741:	c3                   	ret    

00800742 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800742:	f3 0f 1e fb          	endbr32 
  800746:	55                   	push   %ebp
  800747:	89 e5                	mov    %esp,%ebp
  800749:	83 ec 18             	sub    $0x18,%esp
  80074c:	8b 45 08             	mov    0x8(%ebp),%eax
  80074f:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800752:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800755:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800759:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80075c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800763:	85 c0                	test   %eax,%eax
  800765:	74 26                	je     80078d <vsnprintf+0x4b>
  800767:	85 d2                	test   %edx,%edx
  800769:	7e 22                	jle    80078d <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80076b:	ff 75 14             	pushl  0x14(%ebp)
  80076e:	ff 75 10             	pushl  0x10(%ebp)
  800771:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800774:	50                   	push   %eax
  800775:	68 ac 03 80 00       	push   $0x8003ac
  80077a:	e8 6f fc ff ff       	call   8003ee <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80077f:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800782:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800785:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800788:	83 c4 10             	add    $0x10,%esp
}
  80078b:	c9                   	leave  
  80078c:	c3                   	ret    
		return -E_INVAL;
  80078d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800792:	eb f7                	jmp    80078b <vsnprintf+0x49>

00800794 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800794:	f3 0f 1e fb          	endbr32 
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80079e:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007a1:	50                   	push   %eax
  8007a2:	ff 75 10             	pushl  0x10(%ebp)
  8007a5:	ff 75 0c             	pushl  0xc(%ebp)
  8007a8:	ff 75 08             	pushl  0x8(%ebp)
  8007ab:	e8 92 ff ff ff       	call   800742 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007b0:	c9                   	leave  
  8007b1:	c3                   	ret    

008007b2 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007b2:	f3 0f 1e fb          	endbr32 
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007bc:	b8 00 00 00 00       	mov    $0x0,%eax
  8007c1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c5:	74 05                	je     8007cc <strlen+0x1a>
		n++;
  8007c7:	83 c0 01             	add    $0x1,%eax
  8007ca:	eb f5                	jmp    8007c1 <strlen+0xf>
	return n;
}
  8007cc:	5d                   	pop    %ebp
  8007cd:	c3                   	ret    

008007ce <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007ce:	f3 0f 1e fb          	endbr32 
  8007d2:	55                   	push   %ebp
  8007d3:	89 e5                	mov    %esp,%ebp
  8007d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d8:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007db:	b8 00 00 00 00       	mov    $0x0,%eax
  8007e0:	39 d0                	cmp    %edx,%eax
  8007e2:	74 0d                	je     8007f1 <strnlen+0x23>
  8007e4:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007e8:	74 05                	je     8007ef <strnlen+0x21>
		n++;
  8007ea:	83 c0 01             	add    $0x1,%eax
  8007ed:	eb f1                	jmp    8007e0 <strnlen+0x12>
  8007ef:	89 c2                	mov    %eax,%edx
	return n;
}
  8007f1:	89 d0                	mov    %edx,%eax
  8007f3:	5d                   	pop    %ebp
  8007f4:	c3                   	ret    

008007f5 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f5:	f3 0f 1e fb          	endbr32 
  8007f9:	55                   	push   %ebp
  8007fa:	89 e5                	mov    %esp,%ebp
  8007fc:	53                   	push   %ebx
  8007fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800800:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800803:	b8 00 00 00 00       	mov    $0x0,%eax
  800808:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80080c:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80080f:	83 c0 01             	add    $0x1,%eax
  800812:	84 d2                	test   %dl,%dl
  800814:	75 f2                	jne    800808 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800816:	89 c8                	mov    %ecx,%eax
  800818:	5b                   	pop    %ebx
  800819:	5d                   	pop    %ebp
  80081a:	c3                   	ret    

0080081b <strcat>:

char *
strcat(char *dst, const char *src)
{
  80081b:	f3 0f 1e fb          	endbr32 
  80081f:	55                   	push   %ebp
  800820:	89 e5                	mov    %esp,%ebp
  800822:	53                   	push   %ebx
  800823:	83 ec 10             	sub    $0x10,%esp
  800826:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800829:	53                   	push   %ebx
  80082a:	e8 83 ff ff ff       	call   8007b2 <strlen>
  80082f:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800832:	ff 75 0c             	pushl  0xc(%ebp)
  800835:	01 d8                	add    %ebx,%eax
  800837:	50                   	push   %eax
  800838:	e8 b8 ff ff ff       	call   8007f5 <strcpy>
	return dst;
}
  80083d:	89 d8                	mov    %ebx,%eax
  80083f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800842:	c9                   	leave  
  800843:	c3                   	ret    

00800844 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800844:	f3 0f 1e fb          	endbr32 
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	56                   	push   %esi
  80084c:	53                   	push   %ebx
  80084d:	8b 75 08             	mov    0x8(%ebp),%esi
  800850:	8b 55 0c             	mov    0xc(%ebp),%edx
  800853:	89 f3                	mov    %esi,%ebx
  800855:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800858:	89 f0                	mov    %esi,%eax
  80085a:	39 d8                	cmp    %ebx,%eax
  80085c:	74 11                	je     80086f <strncpy+0x2b>
		*dst++ = *src;
  80085e:	83 c0 01             	add    $0x1,%eax
  800861:	0f b6 0a             	movzbl (%edx),%ecx
  800864:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800867:	80 f9 01             	cmp    $0x1,%cl
  80086a:	83 da ff             	sbb    $0xffffffff,%edx
  80086d:	eb eb                	jmp    80085a <strncpy+0x16>
	}
	return ret;
}
  80086f:	89 f0                	mov    %esi,%eax
  800871:	5b                   	pop    %ebx
  800872:	5e                   	pop    %esi
  800873:	5d                   	pop    %ebp
  800874:	c3                   	ret    

00800875 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800875:	f3 0f 1e fb          	endbr32 
  800879:	55                   	push   %ebp
  80087a:	89 e5                	mov    %esp,%ebp
  80087c:	56                   	push   %esi
  80087d:	53                   	push   %ebx
  80087e:	8b 75 08             	mov    0x8(%ebp),%esi
  800881:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800884:	8b 55 10             	mov    0x10(%ebp),%edx
  800887:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800889:	85 d2                	test   %edx,%edx
  80088b:	74 21                	je     8008ae <strlcpy+0x39>
  80088d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800891:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800893:	39 c2                	cmp    %eax,%edx
  800895:	74 14                	je     8008ab <strlcpy+0x36>
  800897:	0f b6 19             	movzbl (%ecx),%ebx
  80089a:	84 db                	test   %bl,%bl
  80089c:	74 0b                	je     8008a9 <strlcpy+0x34>
			*dst++ = *src++;
  80089e:	83 c1 01             	add    $0x1,%ecx
  8008a1:	83 c2 01             	add    $0x1,%edx
  8008a4:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008a7:	eb ea                	jmp    800893 <strlcpy+0x1e>
  8008a9:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008ab:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ae:	29 f0                	sub    %esi,%eax
}
  8008b0:	5b                   	pop    %ebx
  8008b1:	5e                   	pop    %esi
  8008b2:	5d                   	pop    %ebp
  8008b3:	c3                   	ret    

008008b4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b4:	f3 0f 1e fb          	endbr32 
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008be:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008c1:	0f b6 01             	movzbl (%ecx),%eax
  8008c4:	84 c0                	test   %al,%al
  8008c6:	74 0c                	je     8008d4 <strcmp+0x20>
  8008c8:	3a 02                	cmp    (%edx),%al
  8008ca:	75 08                	jne    8008d4 <strcmp+0x20>
		p++, q++;
  8008cc:	83 c1 01             	add    $0x1,%ecx
  8008cf:	83 c2 01             	add    $0x1,%edx
  8008d2:	eb ed                	jmp    8008c1 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d4:	0f b6 c0             	movzbl %al,%eax
  8008d7:	0f b6 12             	movzbl (%edx),%edx
  8008da:	29 d0                	sub    %edx,%eax
}
  8008dc:	5d                   	pop    %ebp
  8008dd:	c3                   	ret    

008008de <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008de:	f3 0f 1e fb          	endbr32 
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	53                   	push   %ebx
  8008e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008ec:	89 c3                	mov    %eax,%ebx
  8008ee:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008f1:	eb 06                	jmp    8008f9 <strncmp+0x1b>
		n--, p++, q++;
  8008f3:	83 c0 01             	add    $0x1,%eax
  8008f6:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008f9:	39 d8                	cmp    %ebx,%eax
  8008fb:	74 16                	je     800913 <strncmp+0x35>
  8008fd:	0f b6 08             	movzbl (%eax),%ecx
  800900:	84 c9                	test   %cl,%cl
  800902:	74 04                	je     800908 <strncmp+0x2a>
  800904:	3a 0a                	cmp    (%edx),%cl
  800906:	74 eb                	je     8008f3 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800908:	0f b6 00             	movzbl (%eax),%eax
  80090b:	0f b6 12             	movzbl (%edx),%edx
  80090e:	29 d0                	sub    %edx,%eax
}
  800910:	5b                   	pop    %ebx
  800911:	5d                   	pop    %ebp
  800912:	c3                   	ret    
		return 0;
  800913:	b8 00 00 00 00       	mov    $0x0,%eax
  800918:	eb f6                	jmp    800910 <strncmp+0x32>

0080091a <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80091a:	f3 0f 1e fb          	endbr32 
  80091e:	55                   	push   %ebp
  80091f:	89 e5                	mov    %esp,%ebp
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800928:	0f b6 10             	movzbl (%eax),%edx
  80092b:	84 d2                	test   %dl,%dl
  80092d:	74 09                	je     800938 <strchr+0x1e>
		if (*s == c)
  80092f:	38 ca                	cmp    %cl,%dl
  800931:	74 0a                	je     80093d <strchr+0x23>
	for (; *s; s++)
  800933:	83 c0 01             	add    $0x1,%eax
  800936:	eb f0                	jmp    800928 <strchr+0xe>
			return (char *) s;
	return 0;
  800938:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093d:	5d                   	pop    %ebp
  80093e:	c3                   	ret    

0080093f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093f:	f3 0f 1e fb          	endbr32 
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	8b 45 08             	mov    0x8(%ebp),%eax
  800949:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80094d:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800950:	38 ca                	cmp    %cl,%dl
  800952:	74 09                	je     80095d <strfind+0x1e>
  800954:	84 d2                	test   %dl,%dl
  800956:	74 05                	je     80095d <strfind+0x1e>
	for (; *s; s++)
  800958:	83 c0 01             	add    $0x1,%eax
  80095b:	eb f0                	jmp    80094d <strfind+0xe>
			break;
	return (char *) s;
}
  80095d:	5d                   	pop    %ebp
  80095e:	c3                   	ret    

0080095f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80095f:	f3 0f 1e fb          	endbr32 
  800963:	55                   	push   %ebp
  800964:	89 e5                	mov    %esp,%ebp
  800966:	57                   	push   %edi
  800967:	56                   	push   %esi
  800968:	53                   	push   %ebx
  800969:	8b 55 08             	mov    0x8(%ebp),%edx
  80096c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  80096f:	85 c9                	test   %ecx,%ecx
  800971:	74 33                	je     8009a6 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800973:	89 d0                	mov    %edx,%eax
  800975:	09 c8                	or     %ecx,%eax
  800977:	a8 03                	test   $0x3,%al
  800979:	75 23                	jne    80099e <memset+0x3f>
		c &= 0xFF;
  80097b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80097f:	89 d8                	mov    %ebx,%eax
  800981:	c1 e0 08             	shl    $0x8,%eax
  800984:	89 df                	mov    %ebx,%edi
  800986:	c1 e7 18             	shl    $0x18,%edi
  800989:	89 de                	mov    %ebx,%esi
  80098b:	c1 e6 10             	shl    $0x10,%esi
  80098e:	09 f7                	or     %esi,%edi
  800990:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800992:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800995:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800997:	89 d7                	mov    %edx,%edi
  800999:	fc                   	cld    
  80099a:	f3 ab                	rep stos %eax,%es:(%edi)
  80099c:	eb 08                	jmp    8009a6 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80099e:	89 d7                	mov    %edx,%edi
  8009a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a3:	fc                   	cld    
  8009a4:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  8009a6:	89 d0                	mov    %edx,%eax
  8009a8:	5b                   	pop    %ebx
  8009a9:	5e                   	pop    %esi
  8009aa:	5f                   	pop    %edi
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009ad:	f3 0f 1e fb          	endbr32 
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	57                   	push   %edi
  8009b5:	56                   	push   %esi
  8009b6:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009bc:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009bf:	39 c6                	cmp    %eax,%esi
  8009c1:	73 32                	jae    8009f5 <memmove+0x48>
  8009c3:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c6:	39 c2                	cmp    %eax,%edx
  8009c8:	76 2b                	jbe    8009f5 <memmove+0x48>
		s += n;
		d += n;
  8009ca:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009cd:	89 fe                	mov    %edi,%esi
  8009cf:	09 ce                	or     %ecx,%esi
  8009d1:	09 d6                	or     %edx,%esi
  8009d3:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d9:	75 0e                	jne    8009e9 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009db:	83 ef 04             	sub    $0x4,%edi
  8009de:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009e1:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009e4:	fd                   	std    
  8009e5:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e7:	eb 09                	jmp    8009f2 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009e9:	83 ef 01             	sub    $0x1,%edi
  8009ec:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009ef:	fd                   	std    
  8009f0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009f2:	fc                   	cld    
  8009f3:	eb 1a                	jmp    800a0f <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f5:	89 c2                	mov    %eax,%edx
  8009f7:	09 ca                	or     %ecx,%edx
  8009f9:	09 f2                	or     %esi,%edx
  8009fb:	f6 c2 03             	test   $0x3,%dl
  8009fe:	75 0a                	jne    800a0a <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a00:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a03:	89 c7                	mov    %eax,%edi
  800a05:	fc                   	cld    
  800a06:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a08:	eb 05                	jmp    800a0f <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a0a:	89 c7                	mov    %eax,%edi
  800a0c:	fc                   	cld    
  800a0d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a0f:	5e                   	pop    %esi
  800a10:	5f                   	pop    %edi
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a13:	f3 0f 1e fb          	endbr32 
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a1d:	ff 75 10             	pushl  0x10(%ebp)
  800a20:	ff 75 0c             	pushl  0xc(%ebp)
  800a23:	ff 75 08             	pushl  0x8(%ebp)
  800a26:	e8 82 ff ff ff       	call   8009ad <memmove>
}
  800a2b:	c9                   	leave  
  800a2c:	c3                   	ret    

00800a2d <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a2d:	f3 0f 1e fb          	endbr32 
  800a31:	55                   	push   %ebp
  800a32:	89 e5                	mov    %esp,%ebp
  800a34:	56                   	push   %esi
  800a35:	53                   	push   %ebx
  800a36:	8b 45 08             	mov    0x8(%ebp),%eax
  800a39:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a3c:	89 c6                	mov    %eax,%esi
  800a3e:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a41:	39 f0                	cmp    %esi,%eax
  800a43:	74 1c                	je     800a61 <memcmp+0x34>
		if (*s1 != *s2)
  800a45:	0f b6 08             	movzbl (%eax),%ecx
  800a48:	0f b6 1a             	movzbl (%edx),%ebx
  800a4b:	38 d9                	cmp    %bl,%cl
  800a4d:	75 08                	jne    800a57 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a4f:	83 c0 01             	add    $0x1,%eax
  800a52:	83 c2 01             	add    $0x1,%edx
  800a55:	eb ea                	jmp    800a41 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a57:	0f b6 c1             	movzbl %cl,%eax
  800a5a:	0f b6 db             	movzbl %bl,%ebx
  800a5d:	29 d8                	sub    %ebx,%eax
  800a5f:	eb 05                	jmp    800a66 <memcmp+0x39>
	}

	return 0;
  800a61:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a66:	5b                   	pop    %ebx
  800a67:	5e                   	pop    %esi
  800a68:	5d                   	pop    %ebp
  800a69:	c3                   	ret    

00800a6a <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a6a:	f3 0f 1e fb          	endbr32 
  800a6e:	55                   	push   %ebp
  800a6f:	89 e5                	mov    %esp,%ebp
  800a71:	8b 45 08             	mov    0x8(%ebp),%eax
  800a74:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a77:	89 c2                	mov    %eax,%edx
  800a79:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a7c:	39 d0                	cmp    %edx,%eax
  800a7e:	73 09                	jae    800a89 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a80:	38 08                	cmp    %cl,(%eax)
  800a82:	74 05                	je     800a89 <memfind+0x1f>
	for (; s < ends; s++)
  800a84:	83 c0 01             	add    $0x1,%eax
  800a87:	eb f3                	jmp    800a7c <memfind+0x12>
			break;
	return (void *) s;
}
  800a89:	5d                   	pop    %ebp
  800a8a:	c3                   	ret    

00800a8b <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a8b:	f3 0f 1e fb          	endbr32 
  800a8f:	55                   	push   %ebp
  800a90:	89 e5                	mov    %esp,%ebp
  800a92:	57                   	push   %edi
  800a93:	56                   	push   %esi
  800a94:	53                   	push   %ebx
  800a95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a98:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a9b:	eb 03                	jmp    800aa0 <strtol+0x15>
		s++;
  800a9d:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800aa0:	0f b6 01             	movzbl (%ecx),%eax
  800aa3:	3c 20                	cmp    $0x20,%al
  800aa5:	74 f6                	je     800a9d <strtol+0x12>
  800aa7:	3c 09                	cmp    $0x9,%al
  800aa9:	74 f2                	je     800a9d <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800aab:	3c 2b                	cmp    $0x2b,%al
  800aad:	74 2a                	je     800ad9 <strtol+0x4e>
	int neg = 0;
  800aaf:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ab4:	3c 2d                	cmp    $0x2d,%al
  800ab6:	74 2b                	je     800ae3 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab8:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800abe:	75 0f                	jne    800acf <strtol+0x44>
  800ac0:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac3:	74 28                	je     800aed <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ac5:	85 db                	test   %ebx,%ebx
  800ac7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800acc:	0f 44 d8             	cmove  %eax,%ebx
  800acf:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad4:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ad7:	eb 46                	jmp    800b1f <strtol+0x94>
		s++;
  800ad9:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800adc:	bf 00 00 00 00       	mov    $0x0,%edi
  800ae1:	eb d5                	jmp    800ab8 <strtol+0x2d>
		s++, neg = 1;
  800ae3:	83 c1 01             	add    $0x1,%ecx
  800ae6:	bf 01 00 00 00       	mov    $0x1,%edi
  800aeb:	eb cb                	jmp    800ab8 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aed:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800af1:	74 0e                	je     800b01 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800af3:	85 db                	test   %ebx,%ebx
  800af5:	75 d8                	jne    800acf <strtol+0x44>
		s++, base = 8;
  800af7:	83 c1 01             	add    $0x1,%ecx
  800afa:	bb 08 00 00 00       	mov    $0x8,%ebx
  800aff:	eb ce                	jmp    800acf <strtol+0x44>
		s += 2, base = 16;
  800b01:	83 c1 02             	add    $0x2,%ecx
  800b04:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b09:	eb c4                	jmp    800acf <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b0b:	0f be d2             	movsbl %dl,%edx
  800b0e:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b11:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b14:	7d 3a                	jge    800b50 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b16:	83 c1 01             	add    $0x1,%ecx
  800b19:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b1d:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b1f:	0f b6 11             	movzbl (%ecx),%edx
  800b22:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b25:	89 f3                	mov    %esi,%ebx
  800b27:	80 fb 09             	cmp    $0x9,%bl
  800b2a:	76 df                	jbe    800b0b <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b2c:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b2f:	89 f3                	mov    %esi,%ebx
  800b31:	80 fb 19             	cmp    $0x19,%bl
  800b34:	77 08                	ja     800b3e <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b36:	0f be d2             	movsbl %dl,%edx
  800b39:	83 ea 57             	sub    $0x57,%edx
  800b3c:	eb d3                	jmp    800b11 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b3e:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b41:	89 f3                	mov    %esi,%ebx
  800b43:	80 fb 19             	cmp    $0x19,%bl
  800b46:	77 08                	ja     800b50 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b48:	0f be d2             	movsbl %dl,%edx
  800b4b:	83 ea 37             	sub    $0x37,%edx
  800b4e:	eb c1                	jmp    800b11 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b50:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b54:	74 05                	je     800b5b <strtol+0xd0>
		*endptr = (char *) s;
  800b56:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b59:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b5b:	89 c2                	mov    %eax,%edx
  800b5d:	f7 da                	neg    %edx
  800b5f:	85 ff                	test   %edi,%edi
  800b61:	0f 45 c2             	cmovne %edx,%eax
}
  800b64:	5b                   	pop    %ebx
  800b65:	5e                   	pop    %esi
  800b66:	5f                   	pop    %edi
  800b67:	5d                   	pop    %ebp
  800b68:	c3                   	ret    

00800b69 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b69:	55                   	push   %ebp
  800b6a:	89 e5                	mov    %esp,%ebp
  800b6c:	57                   	push   %edi
  800b6d:	56                   	push   %esi
  800b6e:	53                   	push   %ebx
  800b6f:	83 ec 1c             	sub    $0x1c,%esp
  800b72:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b75:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800b78:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b7a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b7d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b80:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b83:	8b 75 14             	mov    0x14(%ebp),%esi
  800b86:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b88:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b8c:	74 04                	je     800b92 <syscall+0x29>
  800b8e:	85 c0                	test   %eax,%eax
  800b90:	7f 08                	jg     800b9a <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800b92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b95:	5b                   	pop    %ebx
  800b96:	5e                   	pop    %esi
  800b97:	5f                   	pop    %edi
  800b98:	5d                   	pop    %ebp
  800b99:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b9a:	83 ec 0c             	sub    $0xc,%esp
  800b9d:	50                   	push   %eax
  800b9e:	ff 75 e0             	pushl  -0x20(%ebp)
  800ba1:	68 bf 28 80 00       	push   $0x8028bf
  800ba6:	6a 23                	push   $0x23
  800ba8:	68 dc 28 80 00       	push   $0x8028dc
  800bad:	e8 f2 f5 ff ff       	call   8001a4 <_panic>

00800bb2 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800bb2:	f3 0f 1e fb          	endbr32 
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800bbc:	6a 00                	push   $0x0
  800bbe:	6a 00                	push   $0x0
  800bc0:	6a 00                	push   $0x0
  800bc2:	ff 75 0c             	pushl  0xc(%ebp)
  800bc5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc8:	ba 00 00 00 00       	mov    $0x0,%edx
  800bcd:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd2:	e8 92 ff ff ff       	call   800b69 <syscall>
}
  800bd7:	83 c4 10             	add    $0x10,%esp
  800bda:	c9                   	leave  
  800bdb:	c3                   	ret    

00800bdc <sys_cgetc>:

int
sys_cgetc(void)
{
  800bdc:	f3 0f 1e fb          	endbr32 
  800be0:	55                   	push   %ebp
  800be1:	89 e5                	mov    %esp,%ebp
  800be3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800be6:	6a 00                	push   $0x0
  800be8:	6a 00                	push   $0x0
  800bea:	6a 00                	push   $0x0
  800bec:	6a 00                	push   $0x0
  800bee:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf3:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf8:	b8 01 00 00 00       	mov    $0x1,%eax
  800bfd:	e8 67 ff ff ff       	call   800b69 <syscall>
}
  800c02:	c9                   	leave  
  800c03:	c3                   	ret    

00800c04 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c04:	f3 0f 1e fb          	endbr32 
  800c08:	55                   	push   %ebp
  800c09:	89 e5                	mov    %esp,%ebp
  800c0b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800c0e:	6a 00                	push   $0x0
  800c10:	6a 00                	push   $0x0
  800c12:	6a 00                	push   $0x0
  800c14:	6a 00                	push   $0x0
  800c16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c19:	ba 01 00 00 00       	mov    $0x1,%edx
  800c1e:	b8 03 00 00 00       	mov    $0x3,%eax
  800c23:	e8 41 ff ff ff       	call   800b69 <syscall>
}
  800c28:	c9                   	leave  
  800c29:	c3                   	ret    

00800c2a <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c2a:	f3 0f 1e fb          	endbr32 
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800c34:	6a 00                	push   $0x0
  800c36:	6a 00                	push   $0x0
  800c38:	6a 00                	push   $0x0
  800c3a:	6a 00                	push   $0x0
  800c3c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c41:	ba 00 00 00 00       	mov    $0x0,%edx
  800c46:	b8 02 00 00 00       	mov    $0x2,%eax
  800c4b:	e8 19 ff ff ff       	call   800b69 <syscall>
}
  800c50:	c9                   	leave  
  800c51:	c3                   	ret    

00800c52 <sys_yield>:

void
sys_yield(void)
{
  800c52:	f3 0f 1e fb          	endbr32 
  800c56:	55                   	push   %ebp
  800c57:	89 e5                	mov    %esp,%ebp
  800c59:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c5c:	6a 00                	push   $0x0
  800c5e:	6a 00                	push   $0x0
  800c60:	6a 00                	push   $0x0
  800c62:	6a 00                	push   $0x0
  800c64:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c69:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6e:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c73:	e8 f1 fe ff ff       	call   800b69 <syscall>
}
  800c78:	83 c4 10             	add    $0x10,%esp
  800c7b:	c9                   	leave  
  800c7c:	c3                   	ret    

00800c7d <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c7d:	f3 0f 1e fb          	endbr32 
  800c81:	55                   	push   %ebp
  800c82:	89 e5                	mov    %esp,%ebp
  800c84:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c87:	6a 00                	push   $0x0
  800c89:	6a 00                	push   $0x0
  800c8b:	ff 75 10             	pushl  0x10(%ebp)
  800c8e:	ff 75 0c             	pushl  0xc(%ebp)
  800c91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c94:	ba 01 00 00 00       	mov    $0x1,%edx
  800c99:	b8 04 00 00 00       	mov    $0x4,%eax
  800c9e:	e8 c6 fe ff ff       	call   800b69 <syscall>
}
  800ca3:	c9                   	leave  
  800ca4:	c3                   	ret    

00800ca5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca5:	f3 0f 1e fb          	endbr32 
  800ca9:	55                   	push   %ebp
  800caa:	89 e5                	mov    %esp,%ebp
  800cac:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800caf:	ff 75 18             	pushl  0x18(%ebp)
  800cb2:	ff 75 14             	pushl  0x14(%ebp)
  800cb5:	ff 75 10             	pushl  0x10(%ebp)
  800cb8:	ff 75 0c             	pushl  0xc(%ebp)
  800cbb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cbe:	ba 01 00 00 00       	mov    $0x1,%edx
  800cc3:	b8 05 00 00 00       	mov    $0x5,%eax
  800cc8:	e8 9c fe ff ff       	call   800b69 <syscall>
}
  800ccd:	c9                   	leave  
  800cce:	c3                   	ret    

00800ccf <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ccf:	f3 0f 1e fb          	endbr32 
  800cd3:	55                   	push   %ebp
  800cd4:	89 e5                	mov    %esp,%ebp
  800cd6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800cd9:	6a 00                	push   $0x0
  800cdb:	6a 00                	push   $0x0
  800cdd:	6a 00                	push   $0x0
  800cdf:	ff 75 0c             	pushl  0xc(%ebp)
  800ce2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce5:	ba 01 00 00 00       	mov    $0x1,%edx
  800cea:	b8 06 00 00 00       	mov    $0x6,%eax
  800cef:	e8 75 fe ff ff       	call   800b69 <syscall>
}
  800cf4:	c9                   	leave  
  800cf5:	c3                   	ret    

00800cf6 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cf6:	f3 0f 1e fb          	endbr32 
  800cfa:	55                   	push   %ebp
  800cfb:	89 e5                	mov    %esp,%ebp
  800cfd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800d00:	6a 00                	push   $0x0
  800d02:	6a 00                	push   $0x0
  800d04:	6a 00                	push   $0x0
  800d06:	ff 75 0c             	pushl  0xc(%ebp)
  800d09:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d0c:	ba 01 00 00 00       	mov    $0x1,%edx
  800d11:	b8 08 00 00 00       	mov    $0x8,%eax
  800d16:	e8 4e fe ff ff       	call   800b69 <syscall>
}
  800d1b:	c9                   	leave  
  800d1c:	c3                   	ret    

00800d1d <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d1d:	f3 0f 1e fb          	endbr32 
  800d21:	55                   	push   %ebp
  800d22:	89 e5                	mov    %esp,%ebp
  800d24:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800d27:	6a 00                	push   $0x0
  800d29:	6a 00                	push   $0x0
  800d2b:	6a 00                	push   $0x0
  800d2d:	ff 75 0c             	pushl  0xc(%ebp)
  800d30:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d33:	ba 01 00 00 00       	mov    $0x1,%edx
  800d38:	b8 09 00 00 00       	mov    $0x9,%eax
  800d3d:	e8 27 fe ff ff       	call   800b69 <syscall>
}
  800d42:	c9                   	leave  
  800d43:	c3                   	ret    

00800d44 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d44:	f3 0f 1e fb          	endbr32 
  800d48:	55                   	push   %ebp
  800d49:	89 e5                	mov    %esp,%ebp
  800d4b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d4e:	6a 00                	push   $0x0
  800d50:	6a 00                	push   $0x0
  800d52:	6a 00                	push   $0x0
  800d54:	ff 75 0c             	pushl  0xc(%ebp)
  800d57:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d5a:	ba 01 00 00 00       	mov    $0x1,%edx
  800d5f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d64:	e8 00 fe ff ff       	call   800b69 <syscall>
}
  800d69:	c9                   	leave  
  800d6a:	c3                   	ret    

00800d6b <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d6b:	f3 0f 1e fb          	endbr32 
  800d6f:	55                   	push   %ebp
  800d70:	89 e5                	mov    %esp,%ebp
  800d72:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d75:	6a 00                	push   $0x0
  800d77:	ff 75 14             	pushl  0x14(%ebp)
  800d7a:	ff 75 10             	pushl  0x10(%ebp)
  800d7d:	ff 75 0c             	pushl  0xc(%ebp)
  800d80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d83:	ba 00 00 00 00       	mov    $0x0,%edx
  800d88:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d8d:	e8 d7 fd ff ff       	call   800b69 <syscall>
}
  800d92:	c9                   	leave  
  800d93:	c3                   	ret    

00800d94 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d94:	f3 0f 1e fb          	endbr32 
  800d98:	55                   	push   %ebp
  800d99:	89 e5                	mov    %esp,%ebp
  800d9b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d9e:	6a 00                	push   $0x0
  800da0:	6a 00                	push   $0x0
  800da2:	6a 00                	push   $0x0
  800da4:	6a 00                	push   $0x0
  800da6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da9:	ba 01 00 00 00       	mov    $0x1,%edx
  800dae:	b8 0d 00 00 00       	mov    $0xd,%eax
  800db3:	e8 b1 fd ff ff       	call   800b69 <syscall>
}
  800db8:	c9                   	leave  
  800db9:	c3                   	ret    

00800dba <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dba:	f3 0f 1e fb          	endbr32 
  800dbe:	55                   	push   %ebp
  800dbf:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dc1:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc4:	05 00 00 00 30       	add    $0x30000000,%eax
  800dc9:	c1 e8 0c             	shr    $0xc,%eax
}
  800dcc:	5d                   	pop    %ebp
  800dcd:	c3                   	ret    

00800dce <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dce:	f3 0f 1e fb          	endbr32 
  800dd2:	55                   	push   %ebp
  800dd3:	89 e5                	mov    %esp,%ebp
  800dd5:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800dd8:	ff 75 08             	pushl  0x8(%ebp)
  800ddb:	e8 da ff ff ff       	call   800dba <fd2num>
  800de0:	83 c4 10             	add    $0x10,%esp
  800de3:	c1 e0 0c             	shl    $0xc,%eax
  800de6:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800deb:	c9                   	leave  
  800dec:	c3                   	ret    

00800ded <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800ded:	f3 0f 1e fb          	endbr32 
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800df9:	89 c2                	mov    %eax,%edx
  800dfb:	c1 ea 16             	shr    $0x16,%edx
  800dfe:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e05:	f6 c2 01             	test   $0x1,%dl
  800e08:	74 2d                	je     800e37 <fd_alloc+0x4a>
  800e0a:	89 c2                	mov    %eax,%edx
  800e0c:	c1 ea 0c             	shr    $0xc,%edx
  800e0f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e16:	f6 c2 01             	test   $0x1,%dl
  800e19:	74 1c                	je     800e37 <fd_alloc+0x4a>
  800e1b:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800e20:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e25:	75 d2                	jne    800df9 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e27:	8b 45 08             	mov    0x8(%ebp),%eax
  800e2a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800e30:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800e35:	eb 0a                	jmp    800e41 <fd_alloc+0x54>
			*fd_store = fd;
  800e37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3a:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e3c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e41:	5d                   	pop    %ebp
  800e42:	c3                   	ret    

00800e43 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e43:	f3 0f 1e fb          	endbr32 
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e4d:	83 f8 1f             	cmp    $0x1f,%eax
  800e50:	77 30                	ja     800e82 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e52:	c1 e0 0c             	shl    $0xc,%eax
  800e55:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e5a:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e60:	f6 c2 01             	test   $0x1,%dl
  800e63:	74 24                	je     800e89 <fd_lookup+0x46>
  800e65:	89 c2                	mov    %eax,%edx
  800e67:	c1 ea 0c             	shr    $0xc,%edx
  800e6a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e71:	f6 c2 01             	test   $0x1,%dl
  800e74:	74 1a                	je     800e90 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e76:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e79:	89 02                	mov    %eax,(%edx)
	return 0;
  800e7b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e80:	5d                   	pop    %ebp
  800e81:	c3                   	ret    
		return -E_INVAL;
  800e82:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e87:	eb f7                	jmp    800e80 <fd_lookup+0x3d>
		return -E_INVAL;
  800e89:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e8e:	eb f0                	jmp    800e80 <fd_lookup+0x3d>
  800e90:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e95:	eb e9                	jmp    800e80 <fd_lookup+0x3d>

00800e97 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e97:	f3 0f 1e fb          	endbr32 
  800e9b:	55                   	push   %ebp
  800e9c:	89 e5                	mov    %esp,%ebp
  800e9e:	83 ec 08             	sub    $0x8,%esp
  800ea1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea4:	ba 68 29 80 00       	mov    $0x802968,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ea9:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800eae:	39 08                	cmp    %ecx,(%eax)
  800eb0:	74 33                	je     800ee5 <dev_lookup+0x4e>
  800eb2:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800eb5:	8b 02                	mov    (%edx),%eax
  800eb7:	85 c0                	test   %eax,%eax
  800eb9:	75 f3                	jne    800eae <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ebb:	a1 04 40 80 00       	mov    0x804004,%eax
  800ec0:	8b 40 48             	mov    0x48(%eax),%eax
  800ec3:	83 ec 04             	sub    $0x4,%esp
  800ec6:	51                   	push   %ecx
  800ec7:	50                   	push   %eax
  800ec8:	68 ec 28 80 00       	push   $0x8028ec
  800ecd:	e8 b9 f3 ff ff       	call   80028b <cprintf>
	*dev = 0;
  800ed2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed5:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800edb:	83 c4 10             	add    $0x10,%esp
  800ede:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ee3:	c9                   	leave  
  800ee4:	c3                   	ret    
			*dev = devtab[i];
  800ee5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee8:	89 01                	mov    %eax,(%ecx)
			return 0;
  800eea:	b8 00 00 00 00       	mov    $0x0,%eax
  800eef:	eb f2                	jmp    800ee3 <dev_lookup+0x4c>

00800ef1 <fd_close>:
{
  800ef1:	f3 0f 1e fb          	endbr32 
  800ef5:	55                   	push   %ebp
  800ef6:	89 e5                	mov    %esp,%ebp
  800ef8:	57                   	push   %edi
  800ef9:	56                   	push   %esi
  800efa:	53                   	push   %ebx
  800efb:	83 ec 28             	sub    $0x28,%esp
  800efe:	8b 75 08             	mov    0x8(%ebp),%esi
  800f01:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f04:	56                   	push   %esi
  800f05:	e8 b0 fe ff ff       	call   800dba <fd2num>
  800f0a:	83 c4 08             	add    $0x8,%esp
  800f0d:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800f10:	52                   	push   %edx
  800f11:	50                   	push   %eax
  800f12:	e8 2c ff ff ff       	call   800e43 <fd_lookup>
  800f17:	89 c3                	mov    %eax,%ebx
  800f19:	83 c4 10             	add    $0x10,%esp
  800f1c:	85 c0                	test   %eax,%eax
  800f1e:	78 05                	js     800f25 <fd_close+0x34>
	    || fd != fd2)
  800f20:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f23:	74 16                	je     800f3b <fd_close+0x4a>
		return (must_exist ? r : 0);
  800f25:	89 f8                	mov    %edi,%eax
  800f27:	84 c0                	test   %al,%al
  800f29:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2e:	0f 44 d8             	cmove  %eax,%ebx
}
  800f31:	89 d8                	mov    %ebx,%eax
  800f33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f36:	5b                   	pop    %ebx
  800f37:	5e                   	pop    %esi
  800f38:	5f                   	pop    %edi
  800f39:	5d                   	pop    %ebp
  800f3a:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f3b:	83 ec 08             	sub    $0x8,%esp
  800f3e:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f41:	50                   	push   %eax
  800f42:	ff 36                	pushl  (%esi)
  800f44:	e8 4e ff ff ff       	call   800e97 <dev_lookup>
  800f49:	89 c3                	mov    %eax,%ebx
  800f4b:	83 c4 10             	add    $0x10,%esp
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	78 1a                	js     800f6c <fd_close+0x7b>
		if (dev->dev_close)
  800f52:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f55:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f58:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f5d:	85 c0                	test   %eax,%eax
  800f5f:	74 0b                	je     800f6c <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800f61:	83 ec 0c             	sub    $0xc,%esp
  800f64:	56                   	push   %esi
  800f65:	ff d0                	call   *%eax
  800f67:	89 c3                	mov    %eax,%ebx
  800f69:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f6c:	83 ec 08             	sub    $0x8,%esp
  800f6f:	56                   	push   %esi
  800f70:	6a 00                	push   $0x0
  800f72:	e8 58 fd ff ff       	call   800ccf <sys_page_unmap>
	return r;
  800f77:	83 c4 10             	add    $0x10,%esp
  800f7a:	eb b5                	jmp    800f31 <fd_close+0x40>

00800f7c <close>:

int
close(int fdnum)
{
  800f7c:	f3 0f 1e fb          	endbr32 
  800f80:	55                   	push   %ebp
  800f81:	89 e5                	mov    %esp,%ebp
  800f83:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f89:	50                   	push   %eax
  800f8a:	ff 75 08             	pushl  0x8(%ebp)
  800f8d:	e8 b1 fe ff ff       	call   800e43 <fd_lookup>
  800f92:	83 c4 10             	add    $0x10,%esp
  800f95:	85 c0                	test   %eax,%eax
  800f97:	79 02                	jns    800f9b <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800f99:	c9                   	leave  
  800f9a:	c3                   	ret    
		return fd_close(fd, 1);
  800f9b:	83 ec 08             	sub    $0x8,%esp
  800f9e:	6a 01                	push   $0x1
  800fa0:	ff 75 f4             	pushl  -0xc(%ebp)
  800fa3:	e8 49 ff ff ff       	call   800ef1 <fd_close>
  800fa8:	83 c4 10             	add    $0x10,%esp
  800fab:	eb ec                	jmp    800f99 <close+0x1d>

00800fad <close_all>:

void
close_all(void)
{
  800fad:	f3 0f 1e fb          	endbr32 
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	53                   	push   %ebx
  800fb5:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fb8:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fbd:	83 ec 0c             	sub    $0xc,%esp
  800fc0:	53                   	push   %ebx
  800fc1:	e8 b6 ff ff ff       	call   800f7c <close>
	for (i = 0; i < MAXFD; i++)
  800fc6:	83 c3 01             	add    $0x1,%ebx
  800fc9:	83 c4 10             	add    $0x10,%esp
  800fcc:	83 fb 20             	cmp    $0x20,%ebx
  800fcf:	75 ec                	jne    800fbd <close_all+0x10>
}
  800fd1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd4:	c9                   	leave  
  800fd5:	c3                   	ret    

00800fd6 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fd6:	f3 0f 1e fb          	endbr32 
  800fda:	55                   	push   %ebp
  800fdb:	89 e5                	mov    %esp,%ebp
  800fdd:	57                   	push   %edi
  800fde:	56                   	push   %esi
  800fdf:	53                   	push   %ebx
  800fe0:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fe3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fe6:	50                   	push   %eax
  800fe7:	ff 75 08             	pushl  0x8(%ebp)
  800fea:	e8 54 fe ff ff       	call   800e43 <fd_lookup>
  800fef:	89 c3                	mov    %eax,%ebx
  800ff1:	83 c4 10             	add    $0x10,%esp
  800ff4:	85 c0                	test   %eax,%eax
  800ff6:	0f 88 81 00 00 00    	js     80107d <dup+0xa7>
		return r;
	close(newfdnum);
  800ffc:	83 ec 0c             	sub    $0xc,%esp
  800fff:	ff 75 0c             	pushl  0xc(%ebp)
  801002:	e8 75 ff ff ff       	call   800f7c <close>

	newfd = INDEX2FD(newfdnum);
  801007:	8b 75 0c             	mov    0xc(%ebp),%esi
  80100a:	c1 e6 0c             	shl    $0xc,%esi
  80100d:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801013:	83 c4 04             	add    $0x4,%esp
  801016:	ff 75 e4             	pushl  -0x1c(%ebp)
  801019:	e8 b0 fd ff ff       	call   800dce <fd2data>
  80101e:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801020:	89 34 24             	mov    %esi,(%esp)
  801023:	e8 a6 fd ff ff       	call   800dce <fd2data>
  801028:	83 c4 10             	add    $0x10,%esp
  80102b:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80102d:	89 d8                	mov    %ebx,%eax
  80102f:	c1 e8 16             	shr    $0x16,%eax
  801032:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801039:	a8 01                	test   $0x1,%al
  80103b:	74 11                	je     80104e <dup+0x78>
  80103d:	89 d8                	mov    %ebx,%eax
  80103f:	c1 e8 0c             	shr    $0xc,%eax
  801042:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801049:	f6 c2 01             	test   $0x1,%dl
  80104c:	75 39                	jne    801087 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80104e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801051:	89 d0                	mov    %edx,%eax
  801053:	c1 e8 0c             	shr    $0xc,%eax
  801056:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80105d:	83 ec 0c             	sub    $0xc,%esp
  801060:	25 07 0e 00 00       	and    $0xe07,%eax
  801065:	50                   	push   %eax
  801066:	56                   	push   %esi
  801067:	6a 00                	push   $0x0
  801069:	52                   	push   %edx
  80106a:	6a 00                	push   $0x0
  80106c:	e8 34 fc ff ff       	call   800ca5 <sys_page_map>
  801071:	89 c3                	mov    %eax,%ebx
  801073:	83 c4 20             	add    $0x20,%esp
  801076:	85 c0                	test   %eax,%eax
  801078:	78 31                	js     8010ab <dup+0xd5>
		goto err;

	return newfdnum;
  80107a:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80107d:	89 d8                	mov    %ebx,%eax
  80107f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801082:	5b                   	pop    %ebx
  801083:	5e                   	pop    %esi
  801084:	5f                   	pop    %edi
  801085:	5d                   	pop    %ebp
  801086:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801087:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80108e:	83 ec 0c             	sub    $0xc,%esp
  801091:	25 07 0e 00 00       	and    $0xe07,%eax
  801096:	50                   	push   %eax
  801097:	57                   	push   %edi
  801098:	6a 00                	push   $0x0
  80109a:	53                   	push   %ebx
  80109b:	6a 00                	push   $0x0
  80109d:	e8 03 fc ff ff       	call   800ca5 <sys_page_map>
  8010a2:	89 c3                	mov    %eax,%ebx
  8010a4:	83 c4 20             	add    $0x20,%esp
  8010a7:	85 c0                	test   %eax,%eax
  8010a9:	79 a3                	jns    80104e <dup+0x78>
	sys_page_unmap(0, newfd);
  8010ab:	83 ec 08             	sub    $0x8,%esp
  8010ae:	56                   	push   %esi
  8010af:	6a 00                	push   $0x0
  8010b1:	e8 19 fc ff ff       	call   800ccf <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010b6:	83 c4 08             	add    $0x8,%esp
  8010b9:	57                   	push   %edi
  8010ba:	6a 00                	push   $0x0
  8010bc:	e8 0e fc ff ff       	call   800ccf <sys_page_unmap>
	return r;
  8010c1:	83 c4 10             	add    $0x10,%esp
  8010c4:	eb b7                	jmp    80107d <dup+0xa7>

008010c6 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010c6:	f3 0f 1e fb          	endbr32 
  8010ca:	55                   	push   %ebp
  8010cb:	89 e5                	mov    %esp,%ebp
  8010cd:	53                   	push   %ebx
  8010ce:	83 ec 1c             	sub    $0x1c,%esp
  8010d1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010d4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010d7:	50                   	push   %eax
  8010d8:	53                   	push   %ebx
  8010d9:	e8 65 fd ff ff       	call   800e43 <fd_lookup>
  8010de:	83 c4 10             	add    $0x10,%esp
  8010e1:	85 c0                	test   %eax,%eax
  8010e3:	78 3f                	js     801124 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010e5:	83 ec 08             	sub    $0x8,%esp
  8010e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010eb:	50                   	push   %eax
  8010ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ef:	ff 30                	pushl  (%eax)
  8010f1:	e8 a1 fd ff ff       	call   800e97 <dev_lookup>
  8010f6:	83 c4 10             	add    $0x10,%esp
  8010f9:	85 c0                	test   %eax,%eax
  8010fb:	78 27                	js     801124 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010fd:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801100:	8b 42 08             	mov    0x8(%edx),%eax
  801103:	83 e0 03             	and    $0x3,%eax
  801106:	83 f8 01             	cmp    $0x1,%eax
  801109:	74 1e                	je     801129 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80110b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80110e:	8b 40 08             	mov    0x8(%eax),%eax
  801111:	85 c0                	test   %eax,%eax
  801113:	74 35                	je     80114a <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801115:	83 ec 04             	sub    $0x4,%esp
  801118:	ff 75 10             	pushl  0x10(%ebp)
  80111b:	ff 75 0c             	pushl  0xc(%ebp)
  80111e:	52                   	push   %edx
  80111f:	ff d0                	call   *%eax
  801121:	83 c4 10             	add    $0x10,%esp
}
  801124:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801127:	c9                   	leave  
  801128:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801129:	a1 04 40 80 00       	mov    0x804004,%eax
  80112e:	8b 40 48             	mov    0x48(%eax),%eax
  801131:	83 ec 04             	sub    $0x4,%esp
  801134:	53                   	push   %ebx
  801135:	50                   	push   %eax
  801136:	68 2d 29 80 00       	push   $0x80292d
  80113b:	e8 4b f1 ff ff       	call   80028b <cprintf>
		return -E_INVAL;
  801140:	83 c4 10             	add    $0x10,%esp
  801143:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801148:	eb da                	jmp    801124 <read+0x5e>
		return -E_NOT_SUPP;
  80114a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80114f:	eb d3                	jmp    801124 <read+0x5e>

00801151 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801151:	f3 0f 1e fb          	endbr32 
  801155:	55                   	push   %ebp
  801156:	89 e5                	mov    %esp,%ebp
  801158:	57                   	push   %edi
  801159:	56                   	push   %esi
  80115a:	53                   	push   %ebx
  80115b:	83 ec 0c             	sub    $0xc,%esp
  80115e:	8b 7d 08             	mov    0x8(%ebp),%edi
  801161:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801164:	bb 00 00 00 00       	mov    $0x0,%ebx
  801169:	eb 02                	jmp    80116d <readn+0x1c>
  80116b:	01 c3                	add    %eax,%ebx
  80116d:	39 f3                	cmp    %esi,%ebx
  80116f:	73 21                	jae    801192 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801171:	83 ec 04             	sub    $0x4,%esp
  801174:	89 f0                	mov    %esi,%eax
  801176:	29 d8                	sub    %ebx,%eax
  801178:	50                   	push   %eax
  801179:	89 d8                	mov    %ebx,%eax
  80117b:	03 45 0c             	add    0xc(%ebp),%eax
  80117e:	50                   	push   %eax
  80117f:	57                   	push   %edi
  801180:	e8 41 ff ff ff       	call   8010c6 <read>
		if (m < 0)
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	85 c0                	test   %eax,%eax
  80118a:	78 04                	js     801190 <readn+0x3f>
			return m;
		if (m == 0)
  80118c:	75 dd                	jne    80116b <readn+0x1a>
  80118e:	eb 02                	jmp    801192 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801190:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801192:	89 d8                	mov    %ebx,%eax
  801194:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801197:	5b                   	pop    %ebx
  801198:	5e                   	pop    %esi
  801199:	5f                   	pop    %edi
  80119a:	5d                   	pop    %ebp
  80119b:	c3                   	ret    

0080119c <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80119c:	f3 0f 1e fb          	endbr32 
  8011a0:	55                   	push   %ebp
  8011a1:	89 e5                	mov    %esp,%ebp
  8011a3:	53                   	push   %ebx
  8011a4:	83 ec 1c             	sub    $0x1c,%esp
  8011a7:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ad:	50                   	push   %eax
  8011ae:	53                   	push   %ebx
  8011af:	e8 8f fc ff ff       	call   800e43 <fd_lookup>
  8011b4:	83 c4 10             	add    $0x10,%esp
  8011b7:	85 c0                	test   %eax,%eax
  8011b9:	78 3a                	js     8011f5 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011bb:	83 ec 08             	sub    $0x8,%esp
  8011be:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c1:	50                   	push   %eax
  8011c2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c5:	ff 30                	pushl  (%eax)
  8011c7:	e8 cb fc ff ff       	call   800e97 <dev_lookup>
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	78 22                	js     8011f5 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011da:	74 1e                	je     8011fa <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011df:	8b 52 0c             	mov    0xc(%edx),%edx
  8011e2:	85 d2                	test   %edx,%edx
  8011e4:	74 35                	je     80121b <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011e6:	83 ec 04             	sub    $0x4,%esp
  8011e9:	ff 75 10             	pushl  0x10(%ebp)
  8011ec:	ff 75 0c             	pushl  0xc(%ebp)
  8011ef:	50                   	push   %eax
  8011f0:	ff d2                	call   *%edx
  8011f2:	83 c4 10             	add    $0x10,%esp
}
  8011f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f8:	c9                   	leave  
  8011f9:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011fa:	a1 04 40 80 00       	mov    0x804004,%eax
  8011ff:	8b 40 48             	mov    0x48(%eax),%eax
  801202:	83 ec 04             	sub    $0x4,%esp
  801205:	53                   	push   %ebx
  801206:	50                   	push   %eax
  801207:	68 49 29 80 00       	push   $0x802949
  80120c:	e8 7a f0 ff ff       	call   80028b <cprintf>
		return -E_INVAL;
  801211:	83 c4 10             	add    $0x10,%esp
  801214:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801219:	eb da                	jmp    8011f5 <write+0x59>
		return -E_NOT_SUPP;
  80121b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801220:	eb d3                	jmp    8011f5 <write+0x59>

00801222 <seek>:

int
seek(int fdnum, off_t offset)
{
  801222:	f3 0f 1e fb          	endbr32 
  801226:	55                   	push   %ebp
  801227:	89 e5                	mov    %esp,%ebp
  801229:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80122c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122f:	50                   	push   %eax
  801230:	ff 75 08             	pushl  0x8(%ebp)
  801233:	e8 0b fc ff ff       	call   800e43 <fd_lookup>
  801238:	83 c4 10             	add    $0x10,%esp
  80123b:	85 c0                	test   %eax,%eax
  80123d:	78 0e                	js     80124d <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80123f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801242:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801245:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801248:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80124d:	c9                   	leave  
  80124e:	c3                   	ret    

0080124f <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80124f:	f3 0f 1e fb          	endbr32 
  801253:	55                   	push   %ebp
  801254:	89 e5                	mov    %esp,%ebp
  801256:	53                   	push   %ebx
  801257:	83 ec 1c             	sub    $0x1c,%esp
  80125a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80125d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801260:	50                   	push   %eax
  801261:	53                   	push   %ebx
  801262:	e8 dc fb ff ff       	call   800e43 <fd_lookup>
  801267:	83 c4 10             	add    $0x10,%esp
  80126a:	85 c0                	test   %eax,%eax
  80126c:	78 37                	js     8012a5 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126e:	83 ec 08             	sub    $0x8,%esp
  801271:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801274:	50                   	push   %eax
  801275:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801278:	ff 30                	pushl  (%eax)
  80127a:	e8 18 fc ff ff       	call   800e97 <dev_lookup>
  80127f:	83 c4 10             	add    $0x10,%esp
  801282:	85 c0                	test   %eax,%eax
  801284:	78 1f                	js     8012a5 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801286:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801289:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80128d:	74 1b                	je     8012aa <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80128f:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801292:	8b 52 18             	mov    0x18(%edx),%edx
  801295:	85 d2                	test   %edx,%edx
  801297:	74 32                	je     8012cb <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801299:	83 ec 08             	sub    $0x8,%esp
  80129c:	ff 75 0c             	pushl  0xc(%ebp)
  80129f:	50                   	push   %eax
  8012a0:	ff d2                	call   *%edx
  8012a2:	83 c4 10             	add    $0x10,%esp
}
  8012a5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a8:	c9                   	leave  
  8012a9:	c3                   	ret    
			thisenv->env_id, fdnum);
  8012aa:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012af:	8b 40 48             	mov    0x48(%eax),%eax
  8012b2:	83 ec 04             	sub    $0x4,%esp
  8012b5:	53                   	push   %ebx
  8012b6:	50                   	push   %eax
  8012b7:	68 0c 29 80 00       	push   $0x80290c
  8012bc:	e8 ca ef ff ff       	call   80028b <cprintf>
		return -E_INVAL;
  8012c1:	83 c4 10             	add    $0x10,%esp
  8012c4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c9:	eb da                	jmp    8012a5 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8012cb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012d0:	eb d3                	jmp    8012a5 <ftruncate+0x56>

008012d2 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012d2:	f3 0f 1e fb          	endbr32 
  8012d6:	55                   	push   %ebp
  8012d7:	89 e5                	mov    %esp,%ebp
  8012d9:	53                   	push   %ebx
  8012da:	83 ec 1c             	sub    $0x1c,%esp
  8012dd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012e0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e3:	50                   	push   %eax
  8012e4:	ff 75 08             	pushl  0x8(%ebp)
  8012e7:	e8 57 fb ff ff       	call   800e43 <fd_lookup>
  8012ec:	83 c4 10             	add    $0x10,%esp
  8012ef:	85 c0                	test   %eax,%eax
  8012f1:	78 4b                	js     80133e <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f3:	83 ec 08             	sub    $0x8,%esp
  8012f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f9:	50                   	push   %eax
  8012fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fd:	ff 30                	pushl  (%eax)
  8012ff:	e8 93 fb ff ff       	call   800e97 <dev_lookup>
  801304:	83 c4 10             	add    $0x10,%esp
  801307:	85 c0                	test   %eax,%eax
  801309:	78 33                	js     80133e <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80130b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80130e:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801312:	74 2f                	je     801343 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801314:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801317:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80131e:	00 00 00 
	stat->st_isdir = 0;
  801321:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801328:	00 00 00 
	stat->st_dev = dev;
  80132b:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801331:	83 ec 08             	sub    $0x8,%esp
  801334:	53                   	push   %ebx
  801335:	ff 75 f0             	pushl  -0x10(%ebp)
  801338:	ff 50 14             	call   *0x14(%eax)
  80133b:	83 c4 10             	add    $0x10,%esp
}
  80133e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801341:	c9                   	leave  
  801342:	c3                   	ret    
		return -E_NOT_SUPP;
  801343:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801348:	eb f4                	jmp    80133e <fstat+0x6c>

0080134a <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80134a:	f3 0f 1e fb          	endbr32 
  80134e:	55                   	push   %ebp
  80134f:	89 e5                	mov    %esp,%ebp
  801351:	56                   	push   %esi
  801352:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801353:	83 ec 08             	sub    $0x8,%esp
  801356:	6a 00                	push   $0x0
  801358:	ff 75 08             	pushl  0x8(%ebp)
  80135b:	e8 fb 01 00 00       	call   80155b <open>
  801360:	89 c3                	mov    %eax,%ebx
  801362:	83 c4 10             	add    $0x10,%esp
  801365:	85 c0                	test   %eax,%eax
  801367:	78 1b                	js     801384 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801369:	83 ec 08             	sub    $0x8,%esp
  80136c:	ff 75 0c             	pushl  0xc(%ebp)
  80136f:	50                   	push   %eax
  801370:	e8 5d ff ff ff       	call   8012d2 <fstat>
  801375:	89 c6                	mov    %eax,%esi
	close(fd);
  801377:	89 1c 24             	mov    %ebx,(%esp)
  80137a:	e8 fd fb ff ff       	call   800f7c <close>
	return r;
  80137f:	83 c4 10             	add    $0x10,%esp
  801382:	89 f3                	mov    %esi,%ebx
}
  801384:	89 d8                	mov    %ebx,%eax
  801386:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801389:	5b                   	pop    %ebx
  80138a:	5e                   	pop    %esi
  80138b:	5d                   	pop    %ebp
  80138c:	c3                   	ret    

0080138d <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80138d:	55                   	push   %ebp
  80138e:	89 e5                	mov    %esp,%ebp
  801390:	56                   	push   %esi
  801391:	53                   	push   %ebx
  801392:	89 c6                	mov    %eax,%esi
  801394:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801396:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80139d:	74 27                	je     8013c6 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80139f:	6a 07                	push   $0x7
  8013a1:	68 00 50 80 00       	push   $0x805000
  8013a6:	56                   	push   %esi
  8013a7:	ff 35 00 40 80 00    	pushl  0x804000
  8013ad:	e8 c7 0d 00 00       	call   802179 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013b2:	83 c4 0c             	add    $0xc,%esp
  8013b5:	6a 00                	push   $0x0
  8013b7:	53                   	push   %ebx
  8013b8:	6a 00                	push   $0x0
  8013ba:	e8 4c 0d 00 00       	call   80210b <ipc_recv>
}
  8013bf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013c2:	5b                   	pop    %ebx
  8013c3:	5e                   	pop    %esi
  8013c4:	5d                   	pop    %ebp
  8013c5:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013c6:	83 ec 0c             	sub    $0xc,%esp
  8013c9:	6a 01                	push   $0x1
  8013cb:	e8 0e 0e 00 00       	call   8021de <ipc_find_env>
  8013d0:	a3 00 40 80 00       	mov    %eax,0x804000
  8013d5:	83 c4 10             	add    $0x10,%esp
  8013d8:	eb c5                	jmp    80139f <fsipc+0x12>

008013da <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013da:	f3 0f 1e fb          	endbr32 
  8013de:	55                   	push   %ebp
  8013df:	89 e5                	mov    %esp,%ebp
  8013e1:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ea:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8013ef:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013f2:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fc:	b8 02 00 00 00       	mov    $0x2,%eax
  801401:	e8 87 ff ff ff       	call   80138d <fsipc>
}
  801406:	c9                   	leave  
  801407:	c3                   	ret    

00801408 <devfile_flush>:
{
  801408:	f3 0f 1e fb          	endbr32 
  80140c:	55                   	push   %ebp
  80140d:	89 e5                	mov    %esp,%ebp
  80140f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801412:	8b 45 08             	mov    0x8(%ebp),%eax
  801415:	8b 40 0c             	mov    0xc(%eax),%eax
  801418:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80141d:	ba 00 00 00 00       	mov    $0x0,%edx
  801422:	b8 06 00 00 00       	mov    $0x6,%eax
  801427:	e8 61 ff ff ff       	call   80138d <fsipc>
}
  80142c:	c9                   	leave  
  80142d:	c3                   	ret    

0080142e <devfile_stat>:
{
  80142e:	f3 0f 1e fb          	endbr32 
  801432:	55                   	push   %ebp
  801433:	89 e5                	mov    %esp,%ebp
  801435:	53                   	push   %ebx
  801436:	83 ec 04             	sub    $0x4,%esp
  801439:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80143c:	8b 45 08             	mov    0x8(%ebp),%eax
  80143f:	8b 40 0c             	mov    0xc(%eax),%eax
  801442:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801447:	ba 00 00 00 00       	mov    $0x0,%edx
  80144c:	b8 05 00 00 00       	mov    $0x5,%eax
  801451:	e8 37 ff ff ff       	call   80138d <fsipc>
  801456:	85 c0                	test   %eax,%eax
  801458:	78 2c                	js     801486 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80145a:	83 ec 08             	sub    $0x8,%esp
  80145d:	68 00 50 80 00       	push   $0x805000
  801462:	53                   	push   %ebx
  801463:	e8 8d f3 ff ff       	call   8007f5 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801468:	a1 80 50 80 00       	mov    0x805080,%eax
  80146d:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801473:	a1 84 50 80 00       	mov    0x805084,%eax
  801478:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80147e:	83 c4 10             	add    $0x10,%esp
  801481:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801486:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801489:	c9                   	leave  
  80148a:	c3                   	ret    

0080148b <devfile_write>:
{
  80148b:	f3 0f 1e fb          	endbr32 
  80148f:	55                   	push   %ebp
  801490:	89 e5                	mov    %esp,%ebp
  801492:	83 ec 0c             	sub    $0xc,%esp
  801495:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801498:	8b 55 08             	mov    0x8(%ebp),%edx
  80149b:	8b 52 0c             	mov    0xc(%edx),%edx
  80149e:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014a4:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014a9:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014ae:	0f 47 c2             	cmova  %edx,%eax
  8014b1:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8014b6:	50                   	push   %eax
  8014b7:	ff 75 0c             	pushl  0xc(%ebp)
  8014ba:	68 08 50 80 00       	push   $0x805008
  8014bf:	e8 e9 f4 ff ff       	call   8009ad <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8014c4:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c9:	b8 04 00 00 00       	mov    $0x4,%eax
  8014ce:	e8 ba fe ff ff       	call   80138d <fsipc>
}
  8014d3:	c9                   	leave  
  8014d4:	c3                   	ret    

008014d5 <devfile_read>:
{
  8014d5:	f3 0f 1e fb          	endbr32 
  8014d9:	55                   	push   %ebp
  8014da:	89 e5                	mov    %esp,%ebp
  8014dc:	56                   	push   %esi
  8014dd:	53                   	push   %ebx
  8014de:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e7:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8014ec:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014f2:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f7:	b8 03 00 00 00       	mov    $0x3,%eax
  8014fc:	e8 8c fe ff ff       	call   80138d <fsipc>
  801501:	89 c3                	mov    %eax,%ebx
  801503:	85 c0                	test   %eax,%eax
  801505:	78 1f                	js     801526 <devfile_read+0x51>
	assert(r <= n);
  801507:	39 f0                	cmp    %esi,%eax
  801509:	77 24                	ja     80152f <devfile_read+0x5a>
	assert(r <= PGSIZE);
  80150b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801510:	7f 33                	jg     801545 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801512:	83 ec 04             	sub    $0x4,%esp
  801515:	50                   	push   %eax
  801516:	68 00 50 80 00       	push   $0x805000
  80151b:	ff 75 0c             	pushl  0xc(%ebp)
  80151e:	e8 8a f4 ff ff       	call   8009ad <memmove>
	return r;
  801523:	83 c4 10             	add    $0x10,%esp
}
  801526:	89 d8                	mov    %ebx,%eax
  801528:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80152b:	5b                   	pop    %ebx
  80152c:	5e                   	pop    %esi
  80152d:	5d                   	pop    %ebp
  80152e:	c3                   	ret    
	assert(r <= n);
  80152f:	68 78 29 80 00       	push   $0x802978
  801534:	68 7f 29 80 00       	push   $0x80297f
  801539:	6a 7c                	push   $0x7c
  80153b:	68 94 29 80 00       	push   $0x802994
  801540:	e8 5f ec ff ff       	call   8001a4 <_panic>
	assert(r <= PGSIZE);
  801545:	68 9f 29 80 00       	push   $0x80299f
  80154a:	68 7f 29 80 00       	push   $0x80297f
  80154f:	6a 7d                	push   $0x7d
  801551:	68 94 29 80 00       	push   $0x802994
  801556:	e8 49 ec ff ff       	call   8001a4 <_panic>

0080155b <open>:
{
  80155b:	f3 0f 1e fb          	endbr32 
  80155f:	55                   	push   %ebp
  801560:	89 e5                	mov    %esp,%ebp
  801562:	56                   	push   %esi
  801563:	53                   	push   %ebx
  801564:	83 ec 1c             	sub    $0x1c,%esp
  801567:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80156a:	56                   	push   %esi
  80156b:	e8 42 f2 ff ff       	call   8007b2 <strlen>
  801570:	83 c4 10             	add    $0x10,%esp
  801573:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801578:	7f 6c                	jg     8015e6 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  80157a:	83 ec 0c             	sub    $0xc,%esp
  80157d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801580:	50                   	push   %eax
  801581:	e8 67 f8 ff ff       	call   800ded <fd_alloc>
  801586:	89 c3                	mov    %eax,%ebx
  801588:	83 c4 10             	add    $0x10,%esp
  80158b:	85 c0                	test   %eax,%eax
  80158d:	78 3c                	js     8015cb <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  80158f:	83 ec 08             	sub    $0x8,%esp
  801592:	56                   	push   %esi
  801593:	68 00 50 80 00       	push   $0x805000
  801598:	e8 58 f2 ff ff       	call   8007f5 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80159d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015a0:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015a5:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a8:	b8 01 00 00 00       	mov    $0x1,%eax
  8015ad:	e8 db fd ff ff       	call   80138d <fsipc>
  8015b2:	89 c3                	mov    %eax,%ebx
  8015b4:	83 c4 10             	add    $0x10,%esp
  8015b7:	85 c0                	test   %eax,%eax
  8015b9:	78 19                	js     8015d4 <open+0x79>
	return fd2num(fd);
  8015bb:	83 ec 0c             	sub    $0xc,%esp
  8015be:	ff 75 f4             	pushl  -0xc(%ebp)
  8015c1:	e8 f4 f7 ff ff       	call   800dba <fd2num>
  8015c6:	89 c3                	mov    %eax,%ebx
  8015c8:	83 c4 10             	add    $0x10,%esp
}
  8015cb:	89 d8                	mov    %ebx,%eax
  8015cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015d0:	5b                   	pop    %ebx
  8015d1:	5e                   	pop    %esi
  8015d2:	5d                   	pop    %ebp
  8015d3:	c3                   	ret    
		fd_close(fd, 0);
  8015d4:	83 ec 08             	sub    $0x8,%esp
  8015d7:	6a 00                	push   $0x0
  8015d9:	ff 75 f4             	pushl  -0xc(%ebp)
  8015dc:	e8 10 f9 ff ff       	call   800ef1 <fd_close>
		return r;
  8015e1:	83 c4 10             	add    $0x10,%esp
  8015e4:	eb e5                	jmp    8015cb <open+0x70>
		return -E_BAD_PATH;
  8015e6:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8015eb:	eb de                	jmp    8015cb <open+0x70>

008015ed <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015ed:	f3 0f 1e fb          	endbr32 
  8015f1:	55                   	push   %ebp
  8015f2:	89 e5                	mov    %esp,%ebp
  8015f4:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015f7:	ba 00 00 00 00       	mov    $0x0,%edx
  8015fc:	b8 08 00 00 00       	mov    $0x8,%eax
  801601:	e8 87 fd ff ff       	call   80138d <fsipc>
}
  801606:	c9                   	leave  
  801607:	c3                   	ret    

00801608 <copy_shared_pages>:
}

// Copy the mappings for shared pages into the child address space.
static int
copy_shared_pages(envid_t child)
{
  801608:	55                   	push   %ebp
  801609:	89 e5                	mov    %esp,%ebp
  80160b:	56                   	push   %esi
  80160c:	53                   	push   %ebx
  80160d:	89 c6                	mov    %eax,%esi
	// LAB 5: Your code here.
	for(uint32_t addr = UTEXT; addr < UTOP; addr +=PGSIZE){
  80160f:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801614:	eb 33                	jmp    801649 <copy_shared_pages+0x41>
		if(addr != UXSTACKTOP - PGSIZE){
			if(((uvpd[PDX(addr)] & PTE_P) != 0) && ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U|PTE_SHARE))) == 0){
				sys_page_map(0, (void*)addr, child, (void*)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  801616:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  80161d:	83 ec 0c             	sub    $0xc,%esp
  801620:	25 07 0e 00 00       	and    $0xe07,%eax
  801625:	50                   	push   %eax
  801626:	53                   	push   %ebx
  801627:	56                   	push   %esi
  801628:	53                   	push   %ebx
  801629:	6a 00                	push   $0x0
  80162b:	e8 75 f6 ff ff       	call   800ca5 <sys_page_map>
  801630:	83 c4 20             	add    $0x20,%esp
	for(uint32_t addr = UTEXT; addr < UTOP; addr +=PGSIZE){
  801633:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801639:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  80163f:	77 2f                	ja     801670 <copy_shared_pages+0x68>
		if(addr != UXSTACKTOP - PGSIZE){
  801641:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801647:	74 ea                	je     801633 <copy_shared_pages+0x2b>
			if(((uvpd[PDX(addr)] & PTE_P) != 0) && ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U|PTE_SHARE))) == 0){
  801649:	89 d8                	mov    %ebx,%eax
  80164b:	c1 e8 16             	shr    $0x16,%eax
  80164e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801655:	a8 01                	test   $0x1,%al
  801657:	74 da                	je     801633 <copy_shared_pages+0x2b>
  801659:	89 da                	mov    %ebx,%edx
  80165b:	c1 ea 0c             	shr    $0xc,%edx
  80165e:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801665:	f7 d0                	not    %eax
  801667:	a9 05 04 00 00       	test   $0x405,%eax
  80166c:	75 c5                	jne    801633 <copy_shared_pages+0x2b>
  80166e:	eb a6                	jmp    801616 <copy_shared_pages+0xe>
			}
		}
	}
	return 0;
}
  801670:	b8 00 00 00 00       	mov    $0x0,%eax
  801675:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801678:	5b                   	pop    %ebx
  801679:	5e                   	pop    %esi
  80167a:	5d                   	pop    %ebp
  80167b:	c3                   	ret    

0080167c <init_stack>:
{
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	57                   	push   %edi
  801680:	56                   	push   %esi
  801681:	53                   	push   %ebx
  801682:	83 ec 2c             	sub    $0x2c,%esp
  801685:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801688:	89 55 d0             	mov    %edx,-0x30(%ebp)
  80168b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (argc = 0; argv[argc] != 0; argc++)
  80168e:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  801693:	be 00 00 00 00       	mov    $0x0,%esi
  801698:	89 d7                	mov    %edx,%edi
  80169a:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
	for (argc = 0; argv[argc] != 0; argc++)
  8016a1:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  8016a4:	85 c0                	test   %eax,%eax
  8016a6:	74 15                	je     8016bd <init_stack+0x41>
		string_size += strlen(argv[argc]) + 1;
  8016a8:	83 ec 0c             	sub    $0xc,%esp
  8016ab:	50                   	push   %eax
  8016ac:	e8 01 f1 ff ff       	call   8007b2 <strlen>
  8016b1:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  8016b5:	83 c3 01             	add    $0x1,%ebx
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	eb dd                	jmp    80169a <init_stack+0x1e>
  8016bd:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  8016c0:	89 4d d8             	mov    %ecx,-0x28(%ebp)
	string_store = (char *) UTEMP + PGSIZE - string_size;
  8016c3:	bf 00 10 40 00       	mov    $0x401000,%edi
  8016c8:	29 f7                	sub    %esi,%edi
	argv_store = (uintptr_t *) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  8016ca:	89 fa                	mov    %edi,%edx
  8016cc:	83 e2 fc             	and    $0xfffffffc,%edx
  8016cf:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  8016d6:	29 c2                	sub    %eax,%edx
  8016d8:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	if ((void *) (argv_store - 2) < (void *) UTEMP)
  8016db:	8d 42 f8             	lea    -0x8(%edx),%eax
  8016de:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  8016e3:	0f 86 06 01 00 00    	jbe    8017ef <init_stack+0x173>
	if ((r = sys_page_alloc(0, (void *) UTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  8016e9:	83 ec 04             	sub    $0x4,%esp
  8016ec:	6a 07                	push   $0x7
  8016ee:	68 00 00 40 00       	push   $0x400000
  8016f3:	6a 00                	push   $0x0
  8016f5:	e8 83 f5 ff ff       	call   800c7d <sys_page_alloc>
  8016fa:	89 c6                	mov    %eax,%esi
  8016fc:	83 c4 10             	add    $0x10,%esp
  8016ff:	85 c0                	test   %eax,%eax
  801701:	0f 88 de 00 00 00    	js     8017e5 <init_stack+0x169>
	for (i = 0; i < argc; i++) {
  801707:	be 00 00 00 00       	mov    $0x0,%esi
  80170c:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  80170f:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801712:	39 75 e0             	cmp    %esi,-0x20(%ebp)
  801715:	7e 2f                	jle    801746 <init_stack+0xca>
		argv_store[i] = UTEMP2USTACK(string_store);
  801717:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  80171d:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801720:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801723:	83 ec 08             	sub    $0x8,%esp
  801726:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801729:	57                   	push   %edi
  80172a:	e8 c6 f0 ff ff       	call   8007f5 <strcpy>
		string_store += strlen(argv[i]) + 1;
  80172f:	83 c4 04             	add    $0x4,%esp
  801732:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801735:	e8 78 f0 ff ff       	call   8007b2 <strlen>
  80173a:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  80173e:	83 c6 01             	add    $0x1,%esi
  801741:	83 c4 10             	add    $0x10,%esp
  801744:	eb cc                	jmp    801712 <init_stack+0x96>
	argv_store[argc] = 0;
  801746:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801749:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80174c:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char *) UTEMP + PGSIZE);
  801753:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  801759:	75 5f                	jne    8017ba <init_stack+0x13e>
	argv_store[-1] = UTEMP2USTACK(argv_store);
  80175b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80175e:	8d 82 00 d0 7f ee    	lea    -0x11803000(%edx),%eax
  801764:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  801767:	89 d0                	mov    %edx,%eax
  801769:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80176c:	89 4a f8             	mov    %ecx,-0x8(%edx)
	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80176f:	2d 08 30 80 11       	sub    $0x11803008,%eax
  801774:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  801777:	89 01                	mov    %eax,(%ecx)
	if ((r = sys_page_map(0,
  801779:	83 ec 0c             	sub    $0xc,%esp
  80177c:	6a 07                	push   $0x7
  80177e:	68 00 d0 bf ee       	push   $0xeebfd000
  801783:	ff 75 d4             	pushl  -0x2c(%ebp)
  801786:	68 00 00 40 00       	push   $0x400000
  80178b:	6a 00                	push   $0x0
  80178d:	e8 13 f5 ff ff       	call   800ca5 <sys_page_map>
  801792:	89 c6                	mov    %eax,%esi
  801794:	83 c4 20             	add    $0x20,%esp
  801797:	85 c0                	test   %eax,%eax
  801799:	78 38                	js     8017d3 <init_stack+0x157>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80179b:	83 ec 08             	sub    $0x8,%esp
  80179e:	68 00 00 40 00       	push   $0x400000
  8017a3:	6a 00                	push   $0x0
  8017a5:	e8 25 f5 ff ff       	call   800ccf <sys_page_unmap>
  8017aa:	89 c6                	mov    %eax,%esi
  8017ac:	83 c4 10             	add    $0x10,%esp
  8017af:	85 c0                	test   %eax,%eax
  8017b1:	78 20                	js     8017d3 <init_stack+0x157>
	return 0;
  8017b3:	be 00 00 00 00       	mov    $0x0,%esi
  8017b8:	eb 2b                	jmp    8017e5 <init_stack+0x169>
	assert(string_store == (char *) UTEMP + PGSIZE);
  8017ba:	68 ac 29 80 00       	push   $0x8029ac
  8017bf:	68 7f 29 80 00       	push   $0x80297f
  8017c4:	68 fc 00 00 00       	push   $0xfc
  8017c9:	68 d4 29 80 00       	push   $0x8029d4
  8017ce:	e8 d1 e9 ff ff       	call   8001a4 <_panic>
	sys_page_unmap(0, UTEMP);
  8017d3:	83 ec 08             	sub    $0x8,%esp
  8017d6:	68 00 00 40 00       	push   $0x400000
  8017db:	6a 00                	push   $0x0
  8017dd:	e8 ed f4 ff ff       	call   800ccf <sys_page_unmap>
	return r;
  8017e2:	83 c4 10             	add    $0x10,%esp
}
  8017e5:	89 f0                	mov    %esi,%eax
  8017e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017ea:	5b                   	pop    %ebx
  8017eb:	5e                   	pop    %esi
  8017ec:	5f                   	pop    %edi
  8017ed:	5d                   	pop    %ebp
  8017ee:	c3                   	ret    
		return -E_NO_MEM;
  8017ef:	be fc ff ff ff       	mov    $0xfffffffc,%esi
  8017f4:	eb ef                	jmp    8017e5 <init_stack+0x169>

008017f6 <map_segment>:
{
  8017f6:	55                   	push   %ebp
  8017f7:	89 e5                	mov    %esp,%ebp
  8017f9:	57                   	push   %edi
  8017fa:	56                   	push   %esi
  8017fb:	53                   	push   %ebx
  8017fc:	83 ec 1c             	sub    $0x1c,%esp
  8017ff:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801802:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801805:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  801808:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((i = PGOFF(va))) {
  80180b:	89 d0                	mov    %edx,%eax
  80180d:	25 ff 0f 00 00       	and    $0xfff,%eax
  801812:	74 0f                	je     801823 <map_segment+0x2d>
		va -= i;
  801814:	29 c2                	sub    %eax,%edx
  801816:	89 55 e0             	mov    %edx,-0x20(%ebp)
		memsz += i;
  801819:	01 c1                	add    %eax,%ecx
  80181b:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		filesz += i;
  80181e:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801820:	29 45 10             	sub    %eax,0x10(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  801823:	bb 00 00 00 00       	mov    $0x0,%ebx
  801828:	e9 99 00 00 00       	jmp    8018c6 <map_segment+0xd0>
			if ((r = sys_page_alloc(0, UTEMP, PTE_P | PTE_U | PTE_W)) <
  80182d:	83 ec 04             	sub    $0x4,%esp
  801830:	6a 07                	push   $0x7
  801832:	68 00 00 40 00       	push   $0x400000
  801837:	6a 00                	push   $0x0
  801839:	e8 3f f4 ff ff       	call   800c7d <sys_page_alloc>
  80183e:	83 c4 10             	add    $0x10,%esp
  801841:	85 c0                	test   %eax,%eax
  801843:	0f 88 c1 00 00 00    	js     80190a <map_segment+0x114>
			if ((r = seek(fd, fileoffset + i)) < 0)
  801849:	83 ec 08             	sub    $0x8,%esp
  80184c:	89 f0                	mov    %esi,%eax
  80184e:	03 45 10             	add    0x10(%ebp),%eax
  801851:	50                   	push   %eax
  801852:	ff 75 08             	pushl  0x8(%ebp)
  801855:	e8 c8 f9 ff ff       	call   801222 <seek>
  80185a:	83 c4 10             	add    $0x10,%esp
  80185d:	85 c0                	test   %eax,%eax
  80185f:	0f 88 a5 00 00 00    	js     80190a <map_segment+0x114>
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz - i))) < 0)
  801865:	83 ec 04             	sub    $0x4,%esp
  801868:	89 f8                	mov    %edi,%eax
  80186a:	29 f0                	sub    %esi,%eax
  80186c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801871:	ba 00 10 00 00       	mov    $0x1000,%edx
  801876:	0f 47 c2             	cmova  %edx,%eax
  801879:	50                   	push   %eax
  80187a:	68 00 00 40 00       	push   $0x400000
  80187f:	ff 75 08             	pushl  0x8(%ebp)
  801882:	e8 ca f8 ff ff       	call   801151 <readn>
  801887:	83 c4 10             	add    $0x10,%esp
  80188a:	85 c0                	test   %eax,%eax
  80188c:	78 7c                	js     80190a <map_segment+0x114>
			if ((r = sys_page_map(
  80188e:	83 ec 0c             	sub    $0xc,%esp
  801891:	ff 75 14             	pushl  0x14(%ebp)
  801894:	03 75 e0             	add    -0x20(%ebp),%esi
  801897:	56                   	push   %esi
  801898:	ff 75 dc             	pushl  -0x24(%ebp)
  80189b:	68 00 00 40 00       	push   $0x400000
  8018a0:	6a 00                	push   $0x0
  8018a2:	e8 fe f3 ff ff       	call   800ca5 <sys_page_map>
  8018a7:	83 c4 20             	add    $0x20,%esp
  8018aa:	85 c0                	test   %eax,%eax
  8018ac:	78 42                	js     8018f0 <map_segment+0xfa>
			sys_page_unmap(0, UTEMP);
  8018ae:	83 ec 08             	sub    $0x8,%esp
  8018b1:	68 00 00 40 00       	push   $0x400000
  8018b6:	6a 00                	push   $0x0
  8018b8:	e8 12 f4 ff ff       	call   800ccf <sys_page_unmap>
  8018bd:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  8018c0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8018c6:	89 de                	mov    %ebx,%esi
  8018c8:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
  8018cb:	76 38                	jbe    801905 <map_segment+0x10f>
		if (i >= filesz) {
  8018cd:	39 df                	cmp    %ebx,%edi
  8018cf:	0f 87 58 ff ff ff    	ja     80182d <map_segment+0x37>
			if ((r = sys_page_alloc(child, (void *) (va + i), perm)) < 0)
  8018d5:	83 ec 04             	sub    $0x4,%esp
  8018d8:	ff 75 14             	pushl  0x14(%ebp)
  8018db:	03 75 e0             	add    -0x20(%ebp),%esi
  8018de:	56                   	push   %esi
  8018df:	ff 75 dc             	pushl  -0x24(%ebp)
  8018e2:	e8 96 f3 ff ff       	call   800c7d <sys_page_alloc>
  8018e7:	83 c4 10             	add    $0x10,%esp
  8018ea:	85 c0                	test   %eax,%eax
  8018ec:	79 d2                	jns    8018c0 <map_segment+0xca>
  8018ee:	eb 1a                	jmp    80190a <map_segment+0x114>
				panic("spawn: sys_page_map data: %e", r);
  8018f0:	50                   	push   %eax
  8018f1:	68 e0 29 80 00       	push   $0x8029e0
  8018f6:	68 3a 01 00 00       	push   $0x13a
  8018fb:	68 d4 29 80 00       	push   $0x8029d4
  801900:	e8 9f e8 ff ff       	call   8001a4 <_panic>
	return 0;
  801905:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80190a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80190d:	5b                   	pop    %ebx
  80190e:	5e                   	pop    %esi
  80190f:	5f                   	pop    %edi
  801910:	5d                   	pop    %ebp
  801911:	c3                   	ret    

00801912 <spawn>:
{
  801912:	f3 0f 1e fb          	endbr32 
  801916:	55                   	push   %ebp
  801917:	89 e5                	mov    %esp,%ebp
  801919:	57                   	push   %edi
  80191a:	56                   	push   %esi
  80191b:	53                   	push   %ebx
  80191c:	81 ec 74 02 00 00    	sub    $0x274,%esp
	if ((r = open(prog, O_RDONLY)) < 0)
  801922:	6a 00                	push   $0x0
  801924:	ff 75 08             	pushl  0x8(%ebp)
  801927:	e8 2f fc ff ff       	call   80155b <open>
  80192c:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801932:	83 c4 10             	add    $0x10,%esp
  801935:	85 c0                	test   %eax,%eax
  801937:	0f 88 0b 02 00 00    	js     801b48 <spawn+0x236>
  80193d:	89 c7                	mov    %eax,%edi
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf) ||
  80193f:	83 ec 04             	sub    $0x4,%esp
  801942:	68 00 02 00 00       	push   $0x200
  801947:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80194d:	50                   	push   %eax
  80194e:	57                   	push   %edi
  80194f:	e8 fd f7 ff ff       	call   801151 <readn>
  801954:	83 c4 10             	add    $0x10,%esp
  801957:	3d 00 02 00 00       	cmp    $0x200,%eax
  80195c:	0f 85 85 00 00 00    	jne    8019e7 <spawn+0xd5>
  801962:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801969:	45 4c 46 
  80196c:	75 79                	jne    8019e7 <spawn+0xd5>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80196e:	b8 07 00 00 00       	mov    $0x7,%eax
  801973:	cd 30                	int    $0x30
  801975:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80197b:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	if ((r = sys_exofork()) < 0)
  801981:	89 c3                	mov    %eax,%ebx
  801983:	85 c0                	test   %eax,%eax
  801985:	0f 88 b1 01 00 00    	js     801b3c <spawn+0x22a>
	child_tf = envs[ENVX(child)].env_tf;
  80198b:	89 c6                	mov    %eax,%esi
  80198d:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801993:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801996:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80199c:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  8019a2:	b9 11 00 00 00       	mov    $0x11,%ecx
  8019a7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  8019a9:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  8019af:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
  8019b5:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  8019bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8019be:	89 d8                	mov    %ebx,%eax
  8019c0:	e8 b7 fc ff ff       	call   80167c <init_stack>
  8019c5:	85 c0                	test   %eax,%eax
  8019c7:	0f 88 89 01 00 00    	js     801b56 <spawn+0x244>
	ph = (struct Proghdr *) (elf_buf + elf->e_phoff);
  8019cd:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  8019d3:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8019da:	be 00 00 00 00       	mov    $0x0,%esi
  8019df:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  8019e5:	eb 3e                	jmp    801a25 <spawn+0x113>
		close(fd);
  8019e7:	83 ec 0c             	sub    $0xc,%esp
  8019ea:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  8019f0:	e8 87 f5 ff ff       	call   800f7c <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8019f5:	83 c4 0c             	add    $0xc,%esp
  8019f8:	68 7f 45 4c 46       	push   $0x464c457f
  8019fd:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801a03:	68 fd 29 80 00       	push   $0x8029fd
  801a08:	e8 7e e8 ff ff       	call   80028b <cprintf>
		return -E_NOT_EXEC;
  801a0d:	83 c4 10             	add    $0x10,%esp
  801a10:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  801a17:	ff ff ff 
  801a1a:	e9 29 01 00 00       	jmp    801b48 <spawn+0x236>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801a1f:	83 c6 01             	add    $0x1,%esi
  801a22:	83 c3 20             	add    $0x20,%ebx
  801a25:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801a2c:	39 f0                	cmp    %esi,%eax
  801a2e:	7e 62                	jle    801a92 <spawn+0x180>
		if (ph->p_type != ELF_PROG_LOAD)
  801a30:	83 3b 01             	cmpl   $0x1,(%ebx)
  801a33:	75 ea                	jne    801a1f <spawn+0x10d>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801a35:	8b 43 18             	mov    0x18(%ebx),%eax
  801a38:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801a3b:	83 f8 01             	cmp    $0x1,%eax
  801a3e:	19 c0                	sbb    %eax,%eax
  801a40:	83 e0 fe             	and    $0xfffffffe,%eax
  801a43:	83 c0 07             	add    $0x7,%eax
		if ((r = map_segment(child,
  801a46:	8b 4b 14             	mov    0x14(%ebx),%ecx
  801a49:	8b 53 08             	mov    0x8(%ebx),%edx
  801a4c:	50                   	push   %eax
  801a4d:	ff 73 04             	pushl  0x4(%ebx)
  801a50:	ff 73 10             	pushl  0x10(%ebx)
  801a53:	57                   	push   %edi
  801a54:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801a5a:	e8 97 fd ff ff       	call   8017f6 <map_segment>
  801a5f:	83 c4 10             	add    $0x10,%esp
  801a62:	85 c0                	test   %eax,%eax
  801a64:	79 b9                	jns    801a1f <spawn+0x10d>
  801a66:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  801a68:	83 ec 0c             	sub    $0xc,%esp
  801a6b:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801a71:	e8 8e f1 ff ff       	call   800c04 <sys_env_destroy>
	close(fd);
  801a76:	83 c4 04             	add    $0x4,%esp
  801a79:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801a7f:	e8 f8 f4 ff ff       	call   800f7c <close>
	return r;
  801a84:	83 c4 10             	add    $0x10,%esp
		if ((r = map_segment(child,
  801a87:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
	return r;
  801a8d:	e9 b6 00 00 00       	jmp    801b48 <spawn+0x236>
	close(fd);
  801a92:	83 ec 0c             	sub    $0xc,%esp
  801a95:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801a9b:	e8 dc f4 ff ff       	call   800f7c <close>
	if ((r = copy_shared_pages(child)) < 0)
  801aa0:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801aa6:	e8 5d fb ff ff       	call   801608 <copy_shared_pages>
  801aab:	83 c4 10             	add    $0x10,%esp
  801aae:	85 c0                	test   %eax,%eax
  801ab0:	78 4b                	js     801afd <spawn+0x1eb>
	child_tf.tf_eflags |= FL_IOPL_3;  // devious: see user/faultio.c
  801ab2:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801ab9:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801abc:	83 ec 08             	sub    $0x8,%esp
  801abf:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801ac5:	50                   	push   %eax
  801ac6:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801acc:	e8 4c f2 ff ff       	call   800d1d <sys_env_set_trapframe>
  801ad1:	83 c4 10             	add    $0x10,%esp
  801ad4:	85 c0                	test   %eax,%eax
  801ad6:	78 3a                	js     801b12 <spawn+0x200>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801ad8:	83 ec 08             	sub    $0x8,%esp
  801adb:	6a 02                	push   $0x2
  801add:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801ae3:	e8 0e f2 ff ff       	call   800cf6 <sys_env_set_status>
  801ae8:	83 c4 10             	add    $0x10,%esp
  801aeb:	85 c0                	test   %eax,%eax
  801aed:	78 38                	js     801b27 <spawn+0x215>
	return child;
  801aef:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801af5:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801afb:	eb 4b                	jmp    801b48 <spawn+0x236>
		panic("copy_shared_pages: %e", r);
  801afd:	50                   	push   %eax
  801afe:	68 17 2a 80 00       	push   $0x802a17
  801b03:	68 8c 00 00 00       	push   $0x8c
  801b08:	68 d4 29 80 00       	push   $0x8029d4
  801b0d:	e8 92 e6 ff ff       	call   8001a4 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  801b12:	50                   	push   %eax
  801b13:	68 2d 2a 80 00       	push   $0x802a2d
  801b18:	68 90 00 00 00       	push   $0x90
  801b1d:	68 d4 29 80 00       	push   $0x8029d4
  801b22:	e8 7d e6 ff ff       	call   8001a4 <_panic>
		panic("sys_env_set_status: %e", r);
  801b27:	50                   	push   %eax
  801b28:	68 47 2a 80 00       	push   $0x802a47
  801b2d:	68 93 00 00 00       	push   $0x93
  801b32:	68 d4 29 80 00       	push   $0x8029d4
  801b37:	e8 68 e6 ff ff       	call   8001a4 <_panic>
		return r;
  801b3c:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801b42:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
}
  801b48:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801b4e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b51:	5b                   	pop    %ebx
  801b52:	5e                   	pop    %esi
  801b53:	5f                   	pop    %edi
  801b54:	5d                   	pop    %ebp
  801b55:	c3                   	ret    
		return r;
  801b56:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801b5c:	eb ea                	jmp    801b48 <spawn+0x236>

00801b5e <spawnl>:
{
  801b5e:	f3 0f 1e fb          	endbr32 
  801b62:	55                   	push   %ebp
  801b63:	89 e5                	mov    %esp,%ebp
  801b65:	57                   	push   %edi
  801b66:	56                   	push   %esi
  801b67:	53                   	push   %ebx
  801b68:	83 ec 0c             	sub    $0xc,%esp
	va_start(vl, arg0);
  801b6b:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc = 0;
  801b6e:	b8 00 00 00 00       	mov    $0x0,%eax
	while (va_arg(vl, void *) != NULL)
  801b73:	8d 4a 04             	lea    0x4(%edx),%ecx
  801b76:	83 3a 00             	cmpl   $0x0,(%edx)
  801b79:	74 07                	je     801b82 <spawnl+0x24>
		argc++;
  801b7b:	83 c0 01             	add    $0x1,%eax
	while (va_arg(vl, void *) != NULL)
  801b7e:	89 ca                	mov    %ecx,%edx
  801b80:	eb f1                	jmp    801b73 <spawnl+0x15>
	const char *argv[argc + 2];
  801b82:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  801b89:	89 d1                	mov    %edx,%ecx
  801b8b:	83 e1 f0             	and    $0xfffffff0,%ecx
  801b8e:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  801b94:	89 e6                	mov    %esp,%esi
  801b96:	29 d6                	sub    %edx,%esi
  801b98:	89 f2                	mov    %esi,%edx
  801b9a:	39 d4                	cmp    %edx,%esp
  801b9c:	74 10                	je     801bae <spawnl+0x50>
  801b9e:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  801ba4:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  801bab:	00 
  801bac:	eb ec                	jmp    801b9a <spawnl+0x3c>
  801bae:	89 ca                	mov    %ecx,%edx
  801bb0:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801bb6:	29 d4                	sub    %edx,%esp
  801bb8:	85 d2                	test   %edx,%edx
  801bba:	74 05                	je     801bc1 <spawnl+0x63>
  801bbc:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  801bc1:	8d 74 24 03          	lea    0x3(%esp),%esi
  801bc5:	89 f2                	mov    %esi,%edx
  801bc7:	c1 ea 02             	shr    $0x2,%edx
  801bca:	83 e6 fc             	and    $0xfffffffc,%esi
  801bcd:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801bcf:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801bd2:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc + 1] = NULL;
  801bd9:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801be0:	00 
	va_start(vl, arg0);
  801be1:	8d 4d 10             	lea    0x10(%ebp),%ecx
  801be4:	89 c2                	mov    %eax,%edx
	for (i = 0; i < argc; i++)
  801be6:	b8 00 00 00 00       	mov    $0x0,%eax
  801beb:	eb 0b                	jmp    801bf8 <spawnl+0x9a>
		argv[i + 1] = va_arg(vl, const char *);
  801bed:	83 c0 01             	add    $0x1,%eax
  801bf0:	8b 39                	mov    (%ecx),%edi
  801bf2:	89 3c 83             	mov    %edi,(%ebx,%eax,4)
  801bf5:	8d 49 04             	lea    0x4(%ecx),%ecx
	for (i = 0; i < argc; i++)
  801bf8:	39 d0                	cmp    %edx,%eax
  801bfa:	75 f1                	jne    801bed <spawnl+0x8f>
	return spawn(prog, argv);
  801bfc:	83 ec 08             	sub    $0x8,%esp
  801bff:	56                   	push   %esi
  801c00:	ff 75 08             	pushl  0x8(%ebp)
  801c03:	e8 0a fd ff ff       	call   801912 <spawn>
}
  801c08:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c0b:	5b                   	pop    %ebx
  801c0c:	5e                   	pop    %esi
  801c0d:	5f                   	pop    %edi
  801c0e:	5d                   	pop    %ebp
  801c0f:	c3                   	ret    

00801c10 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c10:	f3 0f 1e fb          	endbr32 
  801c14:	55                   	push   %ebp
  801c15:	89 e5                	mov    %esp,%ebp
  801c17:	56                   	push   %esi
  801c18:	53                   	push   %ebx
  801c19:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c1c:	83 ec 0c             	sub    $0xc,%esp
  801c1f:	ff 75 08             	pushl  0x8(%ebp)
  801c22:	e8 a7 f1 ff ff       	call   800dce <fd2data>
  801c27:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c29:	83 c4 08             	add    $0x8,%esp
  801c2c:	68 5e 2a 80 00       	push   $0x802a5e
  801c31:	53                   	push   %ebx
  801c32:	e8 be eb ff ff       	call   8007f5 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c37:	8b 46 04             	mov    0x4(%esi),%eax
  801c3a:	2b 06                	sub    (%esi),%eax
  801c3c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c42:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c49:	00 00 00 
	stat->st_dev = &devpipe;
  801c4c:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c53:	30 80 00 
	return 0;
}
  801c56:	b8 00 00 00 00       	mov    $0x0,%eax
  801c5b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c5e:	5b                   	pop    %ebx
  801c5f:	5e                   	pop    %esi
  801c60:	5d                   	pop    %ebp
  801c61:	c3                   	ret    

00801c62 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c62:	f3 0f 1e fb          	endbr32 
  801c66:	55                   	push   %ebp
  801c67:	89 e5                	mov    %esp,%ebp
  801c69:	53                   	push   %ebx
  801c6a:	83 ec 0c             	sub    $0xc,%esp
  801c6d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801c70:	53                   	push   %ebx
  801c71:	6a 00                	push   $0x0
  801c73:	e8 57 f0 ff ff       	call   800ccf <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801c78:	89 1c 24             	mov    %ebx,(%esp)
  801c7b:	e8 4e f1 ff ff       	call   800dce <fd2data>
  801c80:	83 c4 08             	add    $0x8,%esp
  801c83:	50                   	push   %eax
  801c84:	6a 00                	push   $0x0
  801c86:	e8 44 f0 ff ff       	call   800ccf <sys_page_unmap>
}
  801c8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c8e:	c9                   	leave  
  801c8f:	c3                   	ret    

00801c90 <_pipeisclosed>:
{
  801c90:	55                   	push   %ebp
  801c91:	89 e5                	mov    %esp,%ebp
  801c93:	57                   	push   %edi
  801c94:	56                   	push   %esi
  801c95:	53                   	push   %ebx
  801c96:	83 ec 1c             	sub    $0x1c,%esp
  801c99:	89 c7                	mov    %eax,%edi
  801c9b:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801c9d:	a1 04 40 80 00       	mov    0x804004,%eax
  801ca2:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ca5:	83 ec 0c             	sub    $0xc,%esp
  801ca8:	57                   	push   %edi
  801ca9:	e8 6d 05 00 00       	call   80221b <pageref>
  801cae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801cb1:	89 34 24             	mov    %esi,(%esp)
  801cb4:	e8 62 05 00 00       	call   80221b <pageref>
		nn = thisenv->env_runs;
  801cb9:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801cbf:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801cc2:	83 c4 10             	add    $0x10,%esp
  801cc5:	39 cb                	cmp    %ecx,%ebx
  801cc7:	74 1b                	je     801ce4 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801cc9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ccc:	75 cf                	jne    801c9d <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801cce:	8b 42 58             	mov    0x58(%edx),%eax
  801cd1:	6a 01                	push   $0x1
  801cd3:	50                   	push   %eax
  801cd4:	53                   	push   %ebx
  801cd5:	68 65 2a 80 00       	push   $0x802a65
  801cda:	e8 ac e5 ff ff       	call   80028b <cprintf>
  801cdf:	83 c4 10             	add    $0x10,%esp
  801ce2:	eb b9                	jmp    801c9d <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801ce4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801ce7:	0f 94 c0             	sete   %al
  801cea:	0f b6 c0             	movzbl %al,%eax
}
  801ced:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf0:	5b                   	pop    %ebx
  801cf1:	5e                   	pop    %esi
  801cf2:	5f                   	pop    %edi
  801cf3:	5d                   	pop    %ebp
  801cf4:	c3                   	ret    

00801cf5 <devpipe_write>:
{
  801cf5:	f3 0f 1e fb          	endbr32 
  801cf9:	55                   	push   %ebp
  801cfa:	89 e5                	mov    %esp,%ebp
  801cfc:	57                   	push   %edi
  801cfd:	56                   	push   %esi
  801cfe:	53                   	push   %ebx
  801cff:	83 ec 28             	sub    $0x28,%esp
  801d02:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801d05:	56                   	push   %esi
  801d06:	e8 c3 f0 ff ff       	call   800dce <fd2data>
  801d0b:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d0d:	83 c4 10             	add    $0x10,%esp
  801d10:	bf 00 00 00 00       	mov    $0x0,%edi
  801d15:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d18:	74 4f                	je     801d69 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d1a:	8b 43 04             	mov    0x4(%ebx),%eax
  801d1d:	8b 0b                	mov    (%ebx),%ecx
  801d1f:	8d 51 20             	lea    0x20(%ecx),%edx
  801d22:	39 d0                	cmp    %edx,%eax
  801d24:	72 14                	jb     801d3a <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801d26:	89 da                	mov    %ebx,%edx
  801d28:	89 f0                	mov    %esi,%eax
  801d2a:	e8 61 ff ff ff       	call   801c90 <_pipeisclosed>
  801d2f:	85 c0                	test   %eax,%eax
  801d31:	75 3b                	jne    801d6e <devpipe_write+0x79>
			sys_yield();
  801d33:	e8 1a ef ff ff       	call   800c52 <sys_yield>
  801d38:	eb e0                	jmp    801d1a <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d3a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d3d:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d41:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d44:	89 c2                	mov    %eax,%edx
  801d46:	c1 fa 1f             	sar    $0x1f,%edx
  801d49:	89 d1                	mov    %edx,%ecx
  801d4b:	c1 e9 1b             	shr    $0x1b,%ecx
  801d4e:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d51:	83 e2 1f             	and    $0x1f,%edx
  801d54:	29 ca                	sub    %ecx,%edx
  801d56:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d5a:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d5e:	83 c0 01             	add    $0x1,%eax
  801d61:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801d64:	83 c7 01             	add    $0x1,%edi
  801d67:	eb ac                	jmp    801d15 <devpipe_write+0x20>
	return i;
  801d69:	8b 45 10             	mov    0x10(%ebp),%eax
  801d6c:	eb 05                	jmp    801d73 <devpipe_write+0x7e>
				return 0;
  801d6e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d73:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d76:	5b                   	pop    %ebx
  801d77:	5e                   	pop    %esi
  801d78:	5f                   	pop    %edi
  801d79:	5d                   	pop    %ebp
  801d7a:	c3                   	ret    

00801d7b <devpipe_read>:
{
  801d7b:	f3 0f 1e fb          	endbr32 
  801d7f:	55                   	push   %ebp
  801d80:	89 e5                	mov    %esp,%ebp
  801d82:	57                   	push   %edi
  801d83:	56                   	push   %esi
  801d84:	53                   	push   %ebx
  801d85:	83 ec 18             	sub    $0x18,%esp
  801d88:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801d8b:	57                   	push   %edi
  801d8c:	e8 3d f0 ff ff       	call   800dce <fd2data>
  801d91:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d93:	83 c4 10             	add    $0x10,%esp
  801d96:	be 00 00 00 00       	mov    $0x0,%esi
  801d9b:	3b 75 10             	cmp    0x10(%ebp),%esi
  801d9e:	75 14                	jne    801db4 <devpipe_read+0x39>
	return i;
  801da0:	8b 45 10             	mov    0x10(%ebp),%eax
  801da3:	eb 02                	jmp    801da7 <devpipe_read+0x2c>
				return i;
  801da5:	89 f0                	mov    %esi,%eax
}
  801da7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801daa:	5b                   	pop    %ebx
  801dab:	5e                   	pop    %esi
  801dac:	5f                   	pop    %edi
  801dad:	5d                   	pop    %ebp
  801dae:	c3                   	ret    
			sys_yield();
  801daf:	e8 9e ee ff ff       	call   800c52 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801db4:	8b 03                	mov    (%ebx),%eax
  801db6:	3b 43 04             	cmp    0x4(%ebx),%eax
  801db9:	75 18                	jne    801dd3 <devpipe_read+0x58>
			if (i > 0)
  801dbb:	85 f6                	test   %esi,%esi
  801dbd:	75 e6                	jne    801da5 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801dbf:	89 da                	mov    %ebx,%edx
  801dc1:	89 f8                	mov    %edi,%eax
  801dc3:	e8 c8 fe ff ff       	call   801c90 <_pipeisclosed>
  801dc8:	85 c0                	test   %eax,%eax
  801dca:	74 e3                	je     801daf <devpipe_read+0x34>
				return 0;
  801dcc:	b8 00 00 00 00       	mov    $0x0,%eax
  801dd1:	eb d4                	jmp    801da7 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801dd3:	99                   	cltd   
  801dd4:	c1 ea 1b             	shr    $0x1b,%edx
  801dd7:	01 d0                	add    %edx,%eax
  801dd9:	83 e0 1f             	and    $0x1f,%eax
  801ddc:	29 d0                	sub    %edx,%eax
  801dde:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801de3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801de6:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801de9:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801dec:	83 c6 01             	add    $0x1,%esi
  801def:	eb aa                	jmp    801d9b <devpipe_read+0x20>

00801df1 <pipe>:
{
  801df1:	f3 0f 1e fb          	endbr32 
  801df5:	55                   	push   %ebp
  801df6:	89 e5                	mov    %esp,%ebp
  801df8:	56                   	push   %esi
  801df9:	53                   	push   %ebx
  801dfa:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801dfd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e00:	50                   	push   %eax
  801e01:	e8 e7 ef ff ff       	call   800ded <fd_alloc>
  801e06:	89 c3                	mov    %eax,%ebx
  801e08:	83 c4 10             	add    $0x10,%esp
  801e0b:	85 c0                	test   %eax,%eax
  801e0d:	0f 88 23 01 00 00    	js     801f36 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e13:	83 ec 04             	sub    $0x4,%esp
  801e16:	68 07 04 00 00       	push   $0x407
  801e1b:	ff 75 f4             	pushl  -0xc(%ebp)
  801e1e:	6a 00                	push   $0x0
  801e20:	e8 58 ee ff ff       	call   800c7d <sys_page_alloc>
  801e25:	89 c3                	mov    %eax,%ebx
  801e27:	83 c4 10             	add    $0x10,%esp
  801e2a:	85 c0                	test   %eax,%eax
  801e2c:	0f 88 04 01 00 00    	js     801f36 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801e32:	83 ec 0c             	sub    $0xc,%esp
  801e35:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e38:	50                   	push   %eax
  801e39:	e8 af ef ff ff       	call   800ded <fd_alloc>
  801e3e:	89 c3                	mov    %eax,%ebx
  801e40:	83 c4 10             	add    $0x10,%esp
  801e43:	85 c0                	test   %eax,%eax
  801e45:	0f 88 db 00 00 00    	js     801f26 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e4b:	83 ec 04             	sub    $0x4,%esp
  801e4e:	68 07 04 00 00       	push   $0x407
  801e53:	ff 75 f0             	pushl  -0x10(%ebp)
  801e56:	6a 00                	push   $0x0
  801e58:	e8 20 ee ff ff       	call   800c7d <sys_page_alloc>
  801e5d:	89 c3                	mov    %eax,%ebx
  801e5f:	83 c4 10             	add    $0x10,%esp
  801e62:	85 c0                	test   %eax,%eax
  801e64:	0f 88 bc 00 00 00    	js     801f26 <pipe+0x135>
	va = fd2data(fd0);
  801e6a:	83 ec 0c             	sub    $0xc,%esp
  801e6d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e70:	e8 59 ef ff ff       	call   800dce <fd2data>
  801e75:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e77:	83 c4 0c             	add    $0xc,%esp
  801e7a:	68 07 04 00 00       	push   $0x407
  801e7f:	50                   	push   %eax
  801e80:	6a 00                	push   $0x0
  801e82:	e8 f6 ed ff ff       	call   800c7d <sys_page_alloc>
  801e87:	89 c3                	mov    %eax,%ebx
  801e89:	83 c4 10             	add    $0x10,%esp
  801e8c:	85 c0                	test   %eax,%eax
  801e8e:	0f 88 82 00 00 00    	js     801f16 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e94:	83 ec 0c             	sub    $0xc,%esp
  801e97:	ff 75 f0             	pushl  -0x10(%ebp)
  801e9a:	e8 2f ef ff ff       	call   800dce <fd2data>
  801e9f:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ea6:	50                   	push   %eax
  801ea7:	6a 00                	push   $0x0
  801ea9:	56                   	push   %esi
  801eaa:	6a 00                	push   $0x0
  801eac:	e8 f4 ed ff ff       	call   800ca5 <sys_page_map>
  801eb1:	89 c3                	mov    %eax,%ebx
  801eb3:	83 c4 20             	add    $0x20,%esp
  801eb6:	85 c0                	test   %eax,%eax
  801eb8:	78 4e                	js     801f08 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801eba:	a1 20 30 80 00       	mov    0x803020,%eax
  801ebf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ec2:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801ec4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801ec7:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801ece:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801ed1:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801ed3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801ed6:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801edd:	83 ec 0c             	sub    $0xc,%esp
  801ee0:	ff 75 f4             	pushl  -0xc(%ebp)
  801ee3:	e8 d2 ee ff ff       	call   800dba <fd2num>
  801ee8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eeb:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801eed:	83 c4 04             	add    $0x4,%esp
  801ef0:	ff 75 f0             	pushl  -0x10(%ebp)
  801ef3:	e8 c2 ee ff ff       	call   800dba <fd2num>
  801ef8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801efb:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801efe:	83 c4 10             	add    $0x10,%esp
  801f01:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f06:	eb 2e                	jmp    801f36 <pipe+0x145>
	sys_page_unmap(0, va);
  801f08:	83 ec 08             	sub    $0x8,%esp
  801f0b:	56                   	push   %esi
  801f0c:	6a 00                	push   $0x0
  801f0e:	e8 bc ed ff ff       	call   800ccf <sys_page_unmap>
  801f13:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801f16:	83 ec 08             	sub    $0x8,%esp
  801f19:	ff 75 f0             	pushl  -0x10(%ebp)
  801f1c:	6a 00                	push   $0x0
  801f1e:	e8 ac ed ff ff       	call   800ccf <sys_page_unmap>
  801f23:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801f26:	83 ec 08             	sub    $0x8,%esp
  801f29:	ff 75 f4             	pushl  -0xc(%ebp)
  801f2c:	6a 00                	push   $0x0
  801f2e:	e8 9c ed ff ff       	call   800ccf <sys_page_unmap>
  801f33:	83 c4 10             	add    $0x10,%esp
}
  801f36:	89 d8                	mov    %ebx,%eax
  801f38:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f3b:	5b                   	pop    %ebx
  801f3c:	5e                   	pop    %esi
  801f3d:	5d                   	pop    %ebp
  801f3e:	c3                   	ret    

00801f3f <pipeisclosed>:
{
  801f3f:	f3 0f 1e fb          	endbr32 
  801f43:	55                   	push   %ebp
  801f44:	89 e5                	mov    %esp,%ebp
  801f46:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f49:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f4c:	50                   	push   %eax
  801f4d:	ff 75 08             	pushl  0x8(%ebp)
  801f50:	e8 ee ee ff ff       	call   800e43 <fd_lookup>
  801f55:	83 c4 10             	add    $0x10,%esp
  801f58:	85 c0                	test   %eax,%eax
  801f5a:	78 18                	js     801f74 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801f5c:	83 ec 0c             	sub    $0xc,%esp
  801f5f:	ff 75 f4             	pushl  -0xc(%ebp)
  801f62:	e8 67 ee ff ff       	call   800dce <fd2data>
  801f67:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801f69:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801f6c:	e8 1f fd ff ff       	call   801c90 <_pipeisclosed>
  801f71:	83 c4 10             	add    $0x10,%esp
}
  801f74:	c9                   	leave  
  801f75:	c3                   	ret    

00801f76 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801f76:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801f7a:	b8 00 00 00 00       	mov    $0x0,%eax
  801f7f:	c3                   	ret    

00801f80 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801f80:	f3 0f 1e fb          	endbr32 
  801f84:	55                   	push   %ebp
  801f85:	89 e5                	mov    %esp,%ebp
  801f87:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801f8a:	68 7d 2a 80 00       	push   $0x802a7d
  801f8f:	ff 75 0c             	pushl  0xc(%ebp)
  801f92:	e8 5e e8 ff ff       	call   8007f5 <strcpy>
	return 0;
}
  801f97:	b8 00 00 00 00       	mov    $0x0,%eax
  801f9c:	c9                   	leave  
  801f9d:	c3                   	ret    

00801f9e <devcons_write>:
{
  801f9e:	f3 0f 1e fb          	endbr32 
  801fa2:	55                   	push   %ebp
  801fa3:	89 e5                	mov    %esp,%ebp
  801fa5:	57                   	push   %edi
  801fa6:	56                   	push   %esi
  801fa7:	53                   	push   %ebx
  801fa8:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801fae:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801fb3:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801fb9:	3b 75 10             	cmp    0x10(%ebp),%esi
  801fbc:	73 31                	jae    801fef <devcons_write+0x51>
		m = n - tot;
  801fbe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801fc1:	29 f3                	sub    %esi,%ebx
  801fc3:	83 fb 7f             	cmp    $0x7f,%ebx
  801fc6:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801fcb:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801fce:	83 ec 04             	sub    $0x4,%esp
  801fd1:	53                   	push   %ebx
  801fd2:	89 f0                	mov    %esi,%eax
  801fd4:	03 45 0c             	add    0xc(%ebp),%eax
  801fd7:	50                   	push   %eax
  801fd8:	57                   	push   %edi
  801fd9:	e8 cf e9 ff ff       	call   8009ad <memmove>
		sys_cputs(buf, m);
  801fde:	83 c4 08             	add    $0x8,%esp
  801fe1:	53                   	push   %ebx
  801fe2:	57                   	push   %edi
  801fe3:	e8 ca eb ff ff       	call   800bb2 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801fe8:	01 de                	add    %ebx,%esi
  801fea:	83 c4 10             	add    $0x10,%esp
  801fed:	eb ca                	jmp    801fb9 <devcons_write+0x1b>
}
  801fef:	89 f0                	mov    %esi,%eax
  801ff1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ff4:	5b                   	pop    %ebx
  801ff5:	5e                   	pop    %esi
  801ff6:	5f                   	pop    %edi
  801ff7:	5d                   	pop    %ebp
  801ff8:	c3                   	ret    

00801ff9 <devcons_read>:
{
  801ff9:	f3 0f 1e fb          	endbr32 
  801ffd:	55                   	push   %ebp
  801ffe:	89 e5                	mov    %esp,%ebp
  802000:	83 ec 08             	sub    $0x8,%esp
  802003:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802008:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80200c:	74 21                	je     80202f <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  80200e:	e8 c9 eb ff ff       	call   800bdc <sys_cgetc>
  802013:	85 c0                	test   %eax,%eax
  802015:	75 07                	jne    80201e <devcons_read+0x25>
		sys_yield();
  802017:	e8 36 ec ff ff       	call   800c52 <sys_yield>
  80201c:	eb f0                	jmp    80200e <devcons_read+0x15>
	if (c < 0)
  80201e:	78 0f                	js     80202f <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  802020:	83 f8 04             	cmp    $0x4,%eax
  802023:	74 0c                	je     802031 <devcons_read+0x38>
	*(char*)vbuf = c;
  802025:	8b 55 0c             	mov    0xc(%ebp),%edx
  802028:	88 02                	mov    %al,(%edx)
	return 1;
  80202a:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80202f:	c9                   	leave  
  802030:	c3                   	ret    
		return 0;
  802031:	b8 00 00 00 00       	mov    $0x0,%eax
  802036:	eb f7                	jmp    80202f <devcons_read+0x36>

00802038 <cputchar>:
{
  802038:	f3 0f 1e fb          	endbr32 
  80203c:	55                   	push   %ebp
  80203d:	89 e5                	mov    %esp,%ebp
  80203f:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  802042:	8b 45 08             	mov    0x8(%ebp),%eax
  802045:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802048:	6a 01                	push   $0x1
  80204a:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80204d:	50                   	push   %eax
  80204e:	e8 5f eb ff ff       	call   800bb2 <sys_cputs>
}
  802053:	83 c4 10             	add    $0x10,%esp
  802056:	c9                   	leave  
  802057:	c3                   	ret    

00802058 <getchar>:
{
  802058:	f3 0f 1e fb          	endbr32 
  80205c:	55                   	push   %ebp
  80205d:	89 e5                	mov    %esp,%ebp
  80205f:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  802062:	6a 01                	push   $0x1
  802064:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802067:	50                   	push   %eax
  802068:	6a 00                	push   $0x0
  80206a:	e8 57 f0 ff ff       	call   8010c6 <read>
	if (r < 0)
  80206f:	83 c4 10             	add    $0x10,%esp
  802072:	85 c0                	test   %eax,%eax
  802074:	78 06                	js     80207c <getchar+0x24>
	if (r < 1)
  802076:	74 06                	je     80207e <getchar+0x26>
	return c;
  802078:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  80207c:	c9                   	leave  
  80207d:	c3                   	ret    
		return -E_EOF;
  80207e:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802083:	eb f7                	jmp    80207c <getchar+0x24>

00802085 <iscons>:
{
  802085:	f3 0f 1e fb          	endbr32 
  802089:	55                   	push   %ebp
  80208a:	89 e5                	mov    %esp,%ebp
  80208c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80208f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802092:	50                   	push   %eax
  802093:	ff 75 08             	pushl  0x8(%ebp)
  802096:	e8 a8 ed ff ff       	call   800e43 <fd_lookup>
  80209b:	83 c4 10             	add    $0x10,%esp
  80209e:	85 c0                	test   %eax,%eax
  8020a0:	78 11                	js     8020b3 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8020a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020a5:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020ab:	39 10                	cmp    %edx,(%eax)
  8020ad:	0f 94 c0             	sete   %al
  8020b0:	0f b6 c0             	movzbl %al,%eax
}
  8020b3:	c9                   	leave  
  8020b4:	c3                   	ret    

008020b5 <opencons>:
{
  8020b5:	f3 0f 1e fb          	endbr32 
  8020b9:	55                   	push   %ebp
  8020ba:	89 e5                	mov    %esp,%ebp
  8020bc:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8020bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020c2:	50                   	push   %eax
  8020c3:	e8 25 ed ff ff       	call   800ded <fd_alloc>
  8020c8:	83 c4 10             	add    $0x10,%esp
  8020cb:	85 c0                	test   %eax,%eax
  8020cd:	78 3a                	js     802109 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8020cf:	83 ec 04             	sub    $0x4,%esp
  8020d2:	68 07 04 00 00       	push   $0x407
  8020d7:	ff 75 f4             	pushl  -0xc(%ebp)
  8020da:	6a 00                	push   $0x0
  8020dc:	e8 9c eb ff ff       	call   800c7d <sys_page_alloc>
  8020e1:	83 c4 10             	add    $0x10,%esp
  8020e4:	85 c0                	test   %eax,%eax
  8020e6:	78 21                	js     802109 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8020e8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020eb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020f1:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8020f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020f6:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8020fd:	83 ec 0c             	sub    $0xc,%esp
  802100:	50                   	push   %eax
  802101:	e8 b4 ec ff ff       	call   800dba <fd2num>
  802106:	83 c4 10             	add    $0x10,%esp
}
  802109:	c9                   	leave  
  80210a:	c3                   	ret    

0080210b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80210b:	f3 0f 1e fb          	endbr32 
  80210f:	55                   	push   %ebp
  802110:	89 e5                	mov    %esp,%ebp
  802112:	56                   	push   %esi
  802113:	53                   	push   %ebx
  802114:	8b 75 08             	mov    0x8(%ebp),%esi
  802117:	8b 45 0c             	mov    0xc(%ebp),%eax
  80211a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  80211d:	85 c0                	test   %eax,%eax
  80211f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802124:	0f 44 c2             	cmove  %edx,%eax
  802127:	83 ec 0c             	sub    $0xc,%esp
  80212a:	50                   	push   %eax
  80212b:	e8 64 ec ff ff       	call   800d94 <sys_ipc_recv>

	if (from_env_store != NULL)
  802130:	83 c4 10             	add    $0x10,%esp
  802133:	85 f6                	test   %esi,%esi
  802135:	74 15                	je     80214c <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  802137:	ba 00 00 00 00       	mov    $0x0,%edx
  80213c:	83 f8 fd             	cmp    $0xfffffffd,%eax
  80213f:	74 09                	je     80214a <ipc_recv+0x3f>
  802141:	8b 15 04 40 80 00    	mov    0x804004,%edx
  802147:	8b 52 74             	mov    0x74(%edx),%edx
  80214a:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  80214c:	85 db                	test   %ebx,%ebx
  80214e:	74 15                	je     802165 <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  802150:	ba 00 00 00 00       	mov    $0x0,%edx
  802155:	83 f8 fd             	cmp    $0xfffffffd,%eax
  802158:	74 09                	je     802163 <ipc_recv+0x58>
  80215a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  802160:	8b 52 78             	mov    0x78(%edx),%edx
  802163:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  802165:	83 f8 fd             	cmp    $0xfffffffd,%eax
  802168:	74 08                	je     802172 <ipc_recv+0x67>
  80216a:	a1 04 40 80 00       	mov    0x804004,%eax
  80216f:	8b 40 70             	mov    0x70(%eax),%eax
}
  802172:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802175:	5b                   	pop    %ebx
  802176:	5e                   	pop    %esi
  802177:	5d                   	pop    %ebp
  802178:	c3                   	ret    

00802179 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802179:	f3 0f 1e fb          	endbr32 
  80217d:	55                   	push   %ebp
  80217e:	89 e5                	mov    %esp,%ebp
  802180:	57                   	push   %edi
  802181:	56                   	push   %esi
  802182:	53                   	push   %ebx
  802183:	83 ec 0c             	sub    $0xc,%esp
  802186:	8b 7d 08             	mov    0x8(%ebp),%edi
  802189:	8b 75 0c             	mov    0xc(%ebp),%esi
  80218c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80218f:	eb 1f                	jmp    8021b0 <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  802191:	6a 00                	push   $0x0
  802193:	68 00 00 c0 ee       	push   $0xeec00000
  802198:	56                   	push   %esi
  802199:	57                   	push   %edi
  80219a:	e8 cc eb ff ff       	call   800d6b <sys_ipc_try_send>
  80219f:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  8021a2:	85 c0                	test   %eax,%eax
  8021a4:	74 30                	je     8021d6 <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  8021a6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8021a9:	75 19                	jne    8021c4 <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  8021ab:	e8 a2 ea ff ff       	call   800c52 <sys_yield>
		if (pg != NULL) {
  8021b0:	85 db                	test   %ebx,%ebx
  8021b2:	74 dd                	je     802191 <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  8021b4:	ff 75 14             	pushl  0x14(%ebp)
  8021b7:	53                   	push   %ebx
  8021b8:	56                   	push   %esi
  8021b9:	57                   	push   %edi
  8021ba:	e8 ac eb ff ff       	call   800d6b <sys_ipc_try_send>
  8021bf:	83 c4 10             	add    $0x10,%esp
  8021c2:	eb de                	jmp    8021a2 <ipc_send+0x29>
			panic("ipc_send: %d", res);
  8021c4:	50                   	push   %eax
  8021c5:	68 89 2a 80 00       	push   $0x802a89
  8021ca:	6a 3e                	push   $0x3e
  8021cc:	68 96 2a 80 00       	push   $0x802a96
  8021d1:	e8 ce df ff ff       	call   8001a4 <_panic>
	}
}
  8021d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021d9:	5b                   	pop    %ebx
  8021da:	5e                   	pop    %esi
  8021db:	5f                   	pop    %edi
  8021dc:	5d                   	pop    %ebp
  8021dd:	c3                   	ret    

008021de <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8021de:	f3 0f 1e fb          	endbr32 
  8021e2:	55                   	push   %ebp
  8021e3:	89 e5                	mov    %esp,%ebp
  8021e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8021e8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8021ed:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8021f0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8021f6:	8b 52 50             	mov    0x50(%edx),%edx
  8021f9:	39 ca                	cmp    %ecx,%edx
  8021fb:	74 11                	je     80220e <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8021fd:	83 c0 01             	add    $0x1,%eax
  802200:	3d 00 04 00 00       	cmp    $0x400,%eax
  802205:	75 e6                	jne    8021ed <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802207:	b8 00 00 00 00       	mov    $0x0,%eax
  80220c:	eb 0b                	jmp    802219 <ipc_find_env+0x3b>
			return envs[i].env_id;
  80220e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802211:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802216:	8b 40 48             	mov    0x48(%eax),%eax
}
  802219:	5d                   	pop    %ebp
  80221a:	c3                   	ret    

0080221b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  80221b:	f3 0f 1e fb          	endbr32 
  80221f:	55                   	push   %ebp
  802220:	89 e5                	mov    %esp,%ebp
  802222:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802225:	89 c2                	mov    %eax,%edx
  802227:	c1 ea 16             	shr    $0x16,%edx
  80222a:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802231:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802236:	f6 c1 01             	test   $0x1,%cl
  802239:	74 1c                	je     802257 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  80223b:	c1 e8 0c             	shr    $0xc,%eax
  80223e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802245:	a8 01                	test   $0x1,%al
  802247:	74 0e                	je     802257 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802249:	c1 e8 0c             	shr    $0xc,%eax
  80224c:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802253:	ef 
  802254:	0f b7 d2             	movzwl %dx,%edx
}
  802257:	89 d0                	mov    %edx,%eax
  802259:	5d                   	pop    %ebp
  80225a:	c3                   	ret    
  80225b:	66 90                	xchg   %ax,%ax
  80225d:	66 90                	xchg   %ax,%ax
  80225f:	90                   	nop

00802260 <__udivdi3>:
  802260:	f3 0f 1e fb          	endbr32 
  802264:	55                   	push   %ebp
  802265:	57                   	push   %edi
  802266:	56                   	push   %esi
  802267:	53                   	push   %ebx
  802268:	83 ec 1c             	sub    $0x1c,%esp
  80226b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80226f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802273:	8b 74 24 34          	mov    0x34(%esp),%esi
  802277:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80227b:	85 d2                	test   %edx,%edx
  80227d:	75 19                	jne    802298 <__udivdi3+0x38>
  80227f:	39 f3                	cmp    %esi,%ebx
  802281:	76 4d                	jbe    8022d0 <__udivdi3+0x70>
  802283:	31 ff                	xor    %edi,%edi
  802285:	89 e8                	mov    %ebp,%eax
  802287:	89 f2                	mov    %esi,%edx
  802289:	f7 f3                	div    %ebx
  80228b:	89 fa                	mov    %edi,%edx
  80228d:	83 c4 1c             	add    $0x1c,%esp
  802290:	5b                   	pop    %ebx
  802291:	5e                   	pop    %esi
  802292:	5f                   	pop    %edi
  802293:	5d                   	pop    %ebp
  802294:	c3                   	ret    
  802295:	8d 76 00             	lea    0x0(%esi),%esi
  802298:	39 f2                	cmp    %esi,%edx
  80229a:	76 14                	jbe    8022b0 <__udivdi3+0x50>
  80229c:	31 ff                	xor    %edi,%edi
  80229e:	31 c0                	xor    %eax,%eax
  8022a0:	89 fa                	mov    %edi,%edx
  8022a2:	83 c4 1c             	add    $0x1c,%esp
  8022a5:	5b                   	pop    %ebx
  8022a6:	5e                   	pop    %esi
  8022a7:	5f                   	pop    %edi
  8022a8:	5d                   	pop    %ebp
  8022a9:	c3                   	ret    
  8022aa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022b0:	0f bd fa             	bsr    %edx,%edi
  8022b3:	83 f7 1f             	xor    $0x1f,%edi
  8022b6:	75 48                	jne    802300 <__udivdi3+0xa0>
  8022b8:	39 f2                	cmp    %esi,%edx
  8022ba:	72 06                	jb     8022c2 <__udivdi3+0x62>
  8022bc:	31 c0                	xor    %eax,%eax
  8022be:	39 eb                	cmp    %ebp,%ebx
  8022c0:	77 de                	ja     8022a0 <__udivdi3+0x40>
  8022c2:	b8 01 00 00 00       	mov    $0x1,%eax
  8022c7:	eb d7                	jmp    8022a0 <__udivdi3+0x40>
  8022c9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8022d0:	89 d9                	mov    %ebx,%ecx
  8022d2:	85 db                	test   %ebx,%ebx
  8022d4:	75 0b                	jne    8022e1 <__udivdi3+0x81>
  8022d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8022db:	31 d2                	xor    %edx,%edx
  8022dd:	f7 f3                	div    %ebx
  8022df:	89 c1                	mov    %eax,%ecx
  8022e1:	31 d2                	xor    %edx,%edx
  8022e3:	89 f0                	mov    %esi,%eax
  8022e5:	f7 f1                	div    %ecx
  8022e7:	89 c6                	mov    %eax,%esi
  8022e9:	89 e8                	mov    %ebp,%eax
  8022eb:	89 f7                	mov    %esi,%edi
  8022ed:	f7 f1                	div    %ecx
  8022ef:	89 fa                	mov    %edi,%edx
  8022f1:	83 c4 1c             	add    $0x1c,%esp
  8022f4:	5b                   	pop    %ebx
  8022f5:	5e                   	pop    %esi
  8022f6:	5f                   	pop    %edi
  8022f7:	5d                   	pop    %ebp
  8022f8:	c3                   	ret    
  8022f9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802300:	89 f9                	mov    %edi,%ecx
  802302:	b8 20 00 00 00       	mov    $0x20,%eax
  802307:	29 f8                	sub    %edi,%eax
  802309:	d3 e2                	shl    %cl,%edx
  80230b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80230f:	89 c1                	mov    %eax,%ecx
  802311:	89 da                	mov    %ebx,%edx
  802313:	d3 ea                	shr    %cl,%edx
  802315:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802319:	09 d1                	or     %edx,%ecx
  80231b:	89 f2                	mov    %esi,%edx
  80231d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802321:	89 f9                	mov    %edi,%ecx
  802323:	d3 e3                	shl    %cl,%ebx
  802325:	89 c1                	mov    %eax,%ecx
  802327:	d3 ea                	shr    %cl,%edx
  802329:	89 f9                	mov    %edi,%ecx
  80232b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80232f:	89 eb                	mov    %ebp,%ebx
  802331:	d3 e6                	shl    %cl,%esi
  802333:	89 c1                	mov    %eax,%ecx
  802335:	d3 eb                	shr    %cl,%ebx
  802337:	09 de                	or     %ebx,%esi
  802339:	89 f0                	mov    %esi,%eax
  80233b:	f7 74 24 08          	divl   0x8(%esp)
  80233f:	89 d6                	mov    %edx,%esi
  802341:	89 c3                	mov    %eax,%ebx
  802343:	f7 64 24 0c          	mull   0xc(%esp)
  802347:	39 d6                	cmp    %edx,%esi
  802349:	72 15                	jb     802360 <__udivdi3+0x100>
  80234b:	89 f9                	mov    %edi,%ecx
  80234d:	d3 e5                	shl    %cl,%ebp
  80234f:	39 c5                	cmp    %eax,%ebp
  802351:	73 04                	jae    802357 <__udivdi3+0xf7>
  802353:	39 d6                	cmp    %edx,%esi
  802355:	74 09                	je     802360 <__udivdi3+0x100>
  802357:	89 d8                	mov    %ebx,%eax
  802359:	31 ff                	xor    %edi,%edi
  80235b:	e9 40 ff ff ff       	jmp    8022a0 <__udivdi3+0x40>
  802360:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802363:	31 ff                	xor    %edi,%edi
  802365:	e9 36 ff ff ff       	jmp    8022a0 <__udivdi3+0x40>
  80236a:	66 90                	xchg   %ax,%ax
  80236c:	66 90                	xchg   %ax,%ax
  80236e:	66 90                	xchg   %ax,%ax

00802370 <__umoddi3>:
  802370:	f3 0f 1e fb          	endbr32 
  802374:	55                   	push   %ebp
  802375:	57                   	push   %edi
  802376:	56                   	push   %esi
  802377:	53                   	push   %ebx
  802378:	83 ec 1c             	sub    $0x1c,%esp
  80237b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80237f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802383:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802387:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80238b:	85 c0                	test   %eax,%eax
  80238d:	75 19                	jne    8023a8 <__umoddi3+0x38>
  80238f:	39 df                	cmp    %ebx,%edi
  802391:	76 5d                	jbe    8023f0 <__umoddi3+0x80>
  802393:	89 f0                	mov    %esi,%eax
  802395:	89 da                	mov    %ebx,%edx
  802397:	f7 f7                	div    %edi
  802399:	89 d0                	mov    %edx,%eax
  80239b:	31 d2                	xor    %edx,%edx
  80239d:	83 c4 1c             	add    $0x1c,%esp
  8023a0:	5b                   	pop    %ebx
  8023a1:	5e                   	pop    %esi
  8023a2:	5f                   	pop    %edi
  8023a3:	5d                   	pop    %ebp
  8023a4:	c3                   	ret    
  8023a5:	8d 76 00             	lea    0x0(%esi),%esi
  8023a8:	89 f2                	mov    %esi,%edx
  8023aa:	39 d8                	cmp    %ebx,%eax
  8023ac:	76 12                	jbe    8023c0 <__umoddi3+0x50>
  8023ae:	89 f0                	mov    %esi,%eax
  8023b0:	89 da                	mov    %ebx,%edx
  8023b2:	83 c4 1c             	add    $0x1c,%esp
  8023b5:	5b                   	pop    %ebx
  8023b6:	5e                   	pop    %esi
  8023b7:	5f                   	pop    %edi
  8023b8:	5d                   	pop    %ebp
  8023b9:	c3                   	ret    
  8023ba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8023c0:	0f bd e8             	bsr    %eax,%ebp
  8023c3:	83 f5 1f             	xor    $0x1f,%ebp
  8023c6:	75 50                	jne    802418 <__umoddi3+0xa8>
  8023c8:	39 d8                	cmp    %ebx,%eax
  8023ca:	0f 82 e0 00 00 00    	jb     8024b0 <__umoddi3+0x140>
  8023d0:	89 d9                	mov    %ebx,%ecx
  8023d2:	39 f7                	cmp    %esi,%edi
  8023d4:	0f 86 d6 00 00 00    	jbe    8024b0 <__umoddi3+0x140>
  8023da:	89 d0                	mov    %edx,%eax
  8023dc:	89 ca                	mov    %ecx,%edx
  8023de:	83 c4 1c             	add    $0x1c,%esp
  8023e1:	5b                   	pop    %ebx
  8023e2:	5e                   	pop    %esi
  8023e3:	5f                   	pop    %edi
  8023e4:	5d                   	pop    %ebp
  8023e5:	c3                   	ret    
  8023e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023ed:	8d 76 00             	lea    0x0(%esi),%esi
  8023f0:	89 fd                	mov    %edi,%ebp
  8023f2:	85 ff                	test   %edi,%edi
  8023f4:	75 0b                	jne    802401 <__umoddi3+0x91>
  8023f6:	b8 01 00 00 00       	mov    $0x1,%eax
  8023fb:	31 d2                	xor    %edx,%edx
  8023fd:	f7 f7                	div    %edi
  8023ff:	89 c5                	mov    %eax,%ebp
  802401:	89 d8                	mov    %ebx,%eax
  802403:	31 d2                	xor    %edx,%edx
  802405:	f7 f5                	div    %ebp
  802407:	89 f0                	mov    %esi,%eax
  802409:	f7 f5                	div    %ebp
  80240b:	89 d0                	mov    %edx,%eax
  80240d:	31 d2                	xor    %edx,%edx
  80240f:	eb 8c                	jmp    80239d <__umoddi3+0x2d>
  802411:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802418:	89 e9                	mov    %ebp,%ecx
  80241a:	ba 20 00 00 00       	mov    $0x20,%edx
  80241f:	29 ea                	sub    %ebp,%edx
  802421:	d3 e0                	shl    %cl,%eax
  802423:	89 44 24 08          	mov    %eax,0x8(%esp)
  802427:	89 d1                	mov    %edx,%ecx
  802429:	89 f8                	mov    %edi,%eax
  80242b:	d3 e8                	shr    %cl,%eax
  80242d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802431:	89 54 24 04          	mov    %edx,0x4(%esp)
  802435:	8b 54 24 04          	mov    0x4(%esp),%edx
  802439:	09 c1                	or     %eax,%ecx
  80243b:	89 d8                	mov    %ebx,%eax
  80243d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802441:	89 e9                	mov    %ebp,%ecx
  802443:	d3 e7                	shl    %cl,%edi
  802445:	89 d1                	mov    %edx,%ecx
  802447:	d3 e8                	shr    %cl,%eax
  802449:	89 e9                	mov    %ebp,%ecx
  80244b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80244f:	d3 e3                	shl    %cl,%ebx
  802451:	89 c7                	mov    %eax,%edi
  802453:	89 d1                	mov    %edx,%ecx
  802455:	89 f0                	mov    %esi,%eax
  802457:	d3 e8                	shr    %cl,%eax
  802459:	89 e9                	mov    %ebp,%ecx
  80245b:	89 fa                	mov    %edi,%edx
  80245d:	d3 e6                	shl    %cl,%esi
  80245f:	09 d8                	or     %ebx,%eax
  802461:	f7 74 24 08          	divl   0x8(%esp)
  802465:	89 d1                	mov    %edx,%ecx
  802467:	89 f3                	mov    %esi,%ebx
  802469:	f7 64 24 0c          	mull   0xc(%esp)
  80246d:	89 c6                	mov    %eax,%esi
  80246f:	89 d7                	mov    %edx,%edi
  802471:	39 d1                	cmp    %edx,%ecx
  802473:	72 06                	jb     80247b <__umoddi3+0x10b>
  802475:	75 10                	jne    802487 <__umoddi3+0x117>
  802477:	39 c3                	cmp    %eax,%ebx
  802479:	73 0c                	jae    802487 <__umoddi3+0x117>
  80247b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80247f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802483:	89 d7                	mov    %edx,%edi
  802485:	89 c6                	mov    %eax,%esi
  802487:	89 ca                	mov    %ecx,%edx
  802489:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80248e:	29 f3                	sub    %esi,%ebx
  802490:	19 fa                	sbb    %edi,%edx
  802492:	89 d0                	mov    %edx,%eax
  802494:	d3 e0                	shl    %cl,%eax
  802496:	89 e9                	mov    %ebp,%ecx
  802498:	d3 eb                	shr    %cl,%ebx
  80249a:	d3 ea                	shr    %cl,%edx
  80249c:	09 d8                	or     %ebx,%eax
  80249e:	83 c4 1c             	add    $0x1c,%esp
  8024a1:	5b                   	pop    %ebx
  8024a2:	5e                   	pop    %esi
  8024a3:	5f                   	pop    %edi
  8024a4:	5d                   	pop    %ebp
  8024a5:	c3                   	ret    
  8024a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024ad:	8d 76 00             	lea    0x0(%esi),%esi
  8024b0:	29 fe                	sub    %edi,%esi
  8024b2:	19 c3                	sbb    %eax,%ebx
  8024b4:	89 f2                	mov    %esi,%edx
  8024b6:	89 d9                	mov    %ebx,%ecx
  8024b8:	e9 1d ff ff ff       	jmp    8023da <__umoddi3+0x6a>
