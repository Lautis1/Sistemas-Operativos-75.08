
obj/user/cat.debug:     formato del fichero elf32-i386


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
  80002c:	e8 04 01 00 00       	call   800135 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <cat>:

char buf[8192];

void
cat(int f, char *s)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
	long n;
	int r;

	while ((n = read(f, buf, (long)sizeof(buf))) > 0)
  80003f:	83 ec 04             	sub    $0x4,%esp
  800042:	68 00 20 00 00       	push   $0x2000
  800047:	68 20 40 80 00       	push   $0x804020
  80004c:	56                   	push   %esi
  80004d:	e8 71 10 00 00       	call   8010c3 <read>
  800052:	89 c3                	mov    %eax,%ebx
  800054:	83 c4 10             	add    $0x10,%esp
  800057:	85 c0                	test   %eax,%eax
  800059:	7e 2f                	jle    80008a <cat+0x57>
		if ((r = write(1, buf, n)) != n)
  80005b:	83 ec 04             	sub    $0x4,%esp
  80005e:	53                   	push   %ebx
  80005f:	68 20 40 80 00       	push   $0x804020
  800064:	6a 01                	push   $0x1
  800066:	e8 2e 11 00 00       	call   801199 <write>
  80006b:	83 c4 10             	add    $0x10,%esp
  80006e:	39 c3                	cmp    %eax,%ebx
  800070:	74 cd                	je     80003f <cat+0xc>
			panic("write error copying %s: %e", s, r);
  800072:	83 ec 0c             	sub    $0xc,%esp
  800075:	50                   	push   %eax
  800076:	ff 75 0c             	pushl  0xc(%ebp)
  800079:	68 e0 1f 80 00       	push   $0x801fe0
  80007e:	6a 0d                	push   $0xd
  800080:	68 fb 1f 80 00       	push   $0x801ffb
  800085:	e8 17 01 00 00       	call   8001a1 <_panic>
	if (n < 0)
  80008a:	78 07                	js     800093 <cat+0x60>
		panic("error reading %s: %e", s, n);
}
  80008c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008f:	5b                   	pop    %ebx
  800090:	5e                   	pop    %esi
  800091:	5d                   	pop    %ebp
  800092:	c3                   	ret    
		panic("error reading %s: %e", s, n);
  800093:	83 ec 0c             	sub    $0xc,%esp
  800096:	50                   	push   %eax
  800097:	ff 75 0c             	pushl  0xc(%ebp)
  80009a:	68 06 20 80 00       	push   $0x802006
  80009f:	6a 0f                	push   $0xf
  8000a1:	68 fb 1f 80 00       	push   $0x801ffb
  8000a6:	e8 f6 00 00 00       	call   8001a1 <_panic>

008000ab <umain>:

void
umain(int argc, char **argv)
{
  8000ab:	f3 0f 1e fb          	endbr32 
  8000af:	55                   	push   %ebp
  8000b0:	89 e5                	mov    %esp,%ebp
  8000b2:	57                   	push   %edi
  8000b3:	56                   	push   %esi
  8000b4:	53                   	push   %ebx
  8000b5:	83 ec 0c             	sub    $0xc,%esp
  8000b8:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int f, i;

	binaryname = "cat";
  8000bb:	c7 05 00 30 80 00 1b 	movl   $0x80201b,0x803000
  8000c2:	20 80 00 
	if (argc == 1)
		cat(0, "<stdin>");
	else
		for (i = 1; i < argc; i++) {
  8000c5:	be 01 00 00 00       	mov    $0x1,%esi
	if (argc == 1)
  8000ca:	83 7d 08 01          	cmpl   $0x1,0x8(%ebp)
  8000ce:	75 31                	jne    800101 <umain+0x56>
		cat(0, "<stdin>");
  8000d0:	83 ec 08             	sub    $0x8,%esp
  8000d3:	68 1f 20 80 00       	push   $0x80201f
  8000d8:	6a 00                	push   $0x0
  8000da:	e8 54 ff ff ff       	call   800033 <cat>
  8000df:	83 c4 10             	add    $0x10,%esp
			else {
				cat(f, argv[i]);
				close(f);
			}
		}
}
  8000e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e5:	5b                   	pop    %ebx
  8000e6:	5e                   	pop    %esi
  8000e7:	5f                   	pop    %edi
  8000e8:	5d                   	pop    %ebp
  8000e9:	c3                   	ret    
				printf("can't open %s: %e\n", argv[i], f);
  8000ea:	83 ec 04             	sub    $0x4,%esp
  8000ed:	50                   	push   %eax
  8000ee:	ff 34 b7             	pushl  (%edi,%esi,4)
  8000f1:	68 27 20 80 00       	push   $0x802027
  8000f6:	e8 14 16 00 00       	call   80170f <printf>
  8000fb:	83 c4 10             	add    $0x10,%esp
		for (i = 1; i < argc; i++) {
  8000fe:	83 c6 01             	add    $0x1,%esi
  800101:	3b 75 08             	cmp    0x8(%ebp),%esi
  800104:	7d dc                	jge    8000e2 <umain+0x37>
			f = open(argv[i], O_RDONLY);
  800106:	83 ec 08             	sub    $0x8,%esp
  800109:	6a 00                	push   $0x0
  80010b:	ff 34 b7             	pushl  (%edi,%esi,4)
  80010e:	e8 45 14 00 00       	call   801558 <open>
  800113:	89 c3                	mov    %eax,%ebx
			if (f < 0)
  800115:	83 c4 10             	add    $0x10,%esp
  800118:	85 c0                	test   %eax,%eax
  80011a:	78 ce                	js     8000ea <umain+0x3f>
				cat(f, argv[i]);
  80011c:	83 ec 08             	sub    $0x8,%esp
  80011f:	ff 34 b7             	pushl  (%edi,%esi,4)
  800122:	50                   	push   %eax
  800123:	e8 0b ff ff ff       	call   800033 <cat>
				close(f);
  800128:	89 1c 24             	mov    %ebx,(%esp)
  80012b:	e8 49 0e 00 00       	call   800f79 <close>
  800130:	83 c4 10             	add    $0x10,%esp
  800133:	eb c9                	jmp    8000fe <umain+0x53>

00800135 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800135:	f3 0f 1e fb          	endbr32 
  800139:	55                   	push   %ebp
  80013a:	89 e5                	mov    %esp,%ebp
  80013c:	56                   	push   %esi
  80013d:	53                   	push   %ebx
  80013e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800141:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800144:	e8 de 0a 00 00       	call   800c27 <sys_getenvid>
	if (id >= 0)
  800149:	85 c0                	test   %eax,%eax
  80014b:	78 12                	js     80015f <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  80014d:	25 ff 03 00 00       	and    $0x3ff,%eax
  800152:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800155:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80015a:	a3 20 60 80 00       	mov    %eax,0x806020

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80015f:	85 db                	test   %ebx,%ebx
  800161:	7e 07                	jle    80016a <libmain+0x35>
		binaryname = argv[0];
  800163:	8b 06                	mov    (%esi),%eax
  800165:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80016a:	83 ec 08             	sub    $0x8,%esp
  80016d:	56                   	push   %esi
  80016e:	53                   	push   %ebx
  80016f:	e8 37 ff ff ff       	call   8000ab <umain>

	// exit gracefully
	exit();
  800174:	e8 0a 00 00 00       	call   800183 <exit>
}
  800179:	83 c4 10             	add    $0x10,%esp
  80017c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80017f:	5b                   	pop    %ebx
  800180:	5e                   	pop    %esi
  800181:	5d                   	pop    %ebp
  800182:	c3                   	ret    

00800183 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800183:	f3 0f 1e fb          	endbr32 
  800187:	55                   	push   %ebp
  800188:	89 e5                	mov    %esp,%ebp
  80018a:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80018d:	e8 18 0e 00 00       	call   800faa <close_all>
	sys_env_destroy(0);
  800192:	83 ec 0c             	sub    $0xc,%esp
  800195:	6a 00                	push   $0x0
  800197:	e8 65 0a 00 00       	call   800c01 <sys_env_destroy>
}
  80019c:	83 c4 10             	add    $0x10,%esp
  80019f:	c9                   	leave  
  8001a0:	c3                   	ret    

008001a1 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8001a1:	f3 0f 1e fb          	endbr32 
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	56                   	push   %esi
  8001a9:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8001aa:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8001ad:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8001b3:	e8 6f 0a 00 00       	call   800c27 <sys_getenvid>
  8001b8:	83 ec 0c             	sub    $0xc,%esp
  8001bb:	ff 75 0c             	pushl  0xc(%ebp)
  8001be:	ff 75 08             	pushl  0x8(%ebp)
  8001c1:	56                   	push   %esi
  8001c2:	50                   	push   %eax
  8001c3:	68 44 20 80 00       	push   $0x802044
  8001c8:	e8 bb 00 00 00       	call   800288 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8001cd:	83 c4 18             	add    $0x18,%esp
  8001d0:	53                   	push   %ebx
  8001d1:	ff 75 10             	pushl  0x10(%ebp)
  8001d4:	e8 5a 00 00 00       	call   800233 <vcprintf>
	cprintf("\n");
  8001d9:	c7 04 24 63 24 80 00 	movl   $0x802463,(%esp)
  8001e0:	e8 a3 00 00 00       	call   800288 <cprintf>
  8001e5:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8001e8:	cc                   	int3   
  8001e9:	eb fd                	jmp    8001e8 <_panic+0x47>

008001eb <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8001eb:	f3 0f 1e fb          	endbr32 
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	53                   	push   %ebx
  8001f3:	83 ec 04             	sub    $0x4,%esp
  8001f6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8001f9:	8b 13                	mov    (%ebx),%edx
  8001fb:	8d 42 01             	lea    0x1(%edx),%eax
  8001fe:	89 03                	mov    %eax,(%ebx)
  800200:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800203:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800207:	3d ff 00 00 00       	cmp    $0xff,%eax
  80020c:	74 09                	je     800217 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80020e:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800212:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800215:	c9                   	leave  
  800216:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800217:	83 ec 08             	sub    $0x8,%esp
  80021a:	68 ff 00 00 00       	push   $0xff
  80021f:	8d 43 08             	lea    0x8(%ebx),%eax
  800222:	50                   	push   %eax
  800223:	e8 87 09 00 00       	call   800baf <sys_cputs>
		b->idx = 0;
  800228:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80022e:	83 c4 10             	add    $0x10,%esp
  800231:	eb db                	jmp    80020e <putch+0x23>

00800233 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800233:	f3 0f 1e fb          	endbr32 
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800240:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800247:	00 00 00 
	b.cnt = 0;
  80024a:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800251:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800254:	ff 75 0c             	pushl  0xc(%ebp)
  800257:	ff 75 08             	pushl  0x8(%ebp)
  80025a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800260:	50                   	push   %eax
  800261:	68 eb 01 80 00       	push   $0x8001eb
  800266:	e8 80 01 00 00       	call   8003eb <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80026b:	83 c4 08             	add    $0x8,%esp
  80026e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800274:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80027a:	50                   	push   %eax
  80027b:	e8 2f 09 00 00       	call   800baf <sys_cputs>

	return b.cnt;
}
  800280:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800286:	c9                   	leave  
  800287:	c3                   	ret    

00800288 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800288:	f3 0f 1e fb          	endbr32 
  80028c:	55                   	push   %ebp
  80028d:	89 e5                	mov    %esp,%ebp
  80028f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800292:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800295:	50                   	push   %eax
  800296:	ff 75 08             	pushl  0x8(%ebp)
  800299:	e8 95 ff ff ff       	call   800233 <vcprintf>
	va_end(ap);

	return cnt;
}
  80029e:	c9                   	leave  
  80029f:	c3                   	ret    

008002a0 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002a0:	55                   	push   %ebp
  8002a1:	89 e5                	mov    %esp,%ebp
  8002a3:	57                   	push   %edi
  8002a4:	56                   	push   %esi
  8002a5:	53                   	push   %ebx
  8002a6:	83 ec 1c             	sub    $0x1c,%esp
  8002a9:	89 c7                	mov    %eax,%edi
  8002ab:	89 d6                	mov    %edx,%esi
  8002ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8002b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002b3:	89 d1                	mov    %edx,%ecx
  8002b5:	89 c2                	mov    %eax,%edx
  8002b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ba:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002bd:	8b 45 10             	mov    0x10(%ebp),%eax
  8002c0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002c6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8002cd:	39 c2                	cmp    %eax,%edx
  8002cf:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8002d2:	72 3e                	jb     800312 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	ff 75 18             	pushl  0x18(%ebp)
  8002da:	83 eb 01             	sub    $0x1,%ebx
  8002dd:	53                   	push   %ebx
  8002de:	50                   	push   %eax
  8002df:	83 ec 08             	sub    $0x8,%esp
  8002e2:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002e5:	ff 75 e0             	pushl  -0x20(%ebp)
  8002e8:	ff 75 dc             	pushl  -0x24(%ebp)
  8002eb:	ff 75 d8             	pushl  -0x28(%ebp)
  8002ee:	e8 8d 1a 00 00       	call   801d80 <__udivdi3>
  8002f3:	83 c4 18             	add    $0x18,%esp
  8002f6:	52                   	push   %edx
  8002f7:	50                   	push   %eax
  8002f8:	89 f2                	mov    %esi,%edx
  8002fa:	89 f8                	mov    %edi,%eax
  8002fc:	e8 9f ff ff ff       	call   8002a0 <printnum>
  800301:	83 c4 20             	add    $0x20,%esp
  800304:	eb 13                	jmp    800319 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800306:	83 ec 08             	sub    $0x8,%esp
  800309:	56                   	push   %esi
  80030a:	ff 75 18             	pushl  0x18(%ebp)
  80030d:	ff d7                	call   *%edi
  80030f:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800312:	83 eb 01             	sub    $0x1,%ebx
  800315:	85 db                	test   %ebx,%ebx
  800317:	7f ed                	jg     800306 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800319:	83 ec 08             	sub    $0x8,%esp
  80031c:	56                   	push   %esi
  80031d:	83 ec 04             	sub    $0x4,%esp
  800320:	ff 75 e4             	pushl  -0x1c(%ebp)
  800323:	ff 75 e0             	pushl  -0x20(%ebp)
  800326:	ff 75 dc             	pushl  -0x24(%ebp)
  800329:	ff 75 d8             	pushl  -0x28(%ebp)
  80032c:	e8 5f 1b 00 00       	call   801e90 <__umoddi3>
  800331:	83 c4 14             	add    $0x14,%esp
  800334:	0f be 80 67 20 80 00 	movsbl 0x802067(%eax),%eax
  80033b:	50                   	push   %eax
  80033c:	ff d7                	call   *%edi
}
  80033e:	83 c4 10             	add    $0x10,%esp
  800341:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800344:	5b                   	pop    %ebx
  800345:	5e                   	pop    %esi
  800346:	5f                   	pop    %edi
  800347:	5d                   	pop    %ebp
  800348:	c3                   	ret    

00800349 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800349:	83 fa 01             	cmp    $0x1,%edx
  80034c:	7f 13                	jg     800361 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80034e:	85 d2                	test   %edx,%edx
  800350:	74 1c                	je     80036e <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800352:	8b 10                	mov    (%eax),%edx
  800354:	8d 4a 04             	lea    0x4(%edx),%ecx
  800357:	89 08                	mov    %ecx,(%eax)
  800359:	8b 02                	mov    (%edx),%eax
  80035b:	ba 00 00 00 00       	mov    $0x0,%edx
  800360:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800361:	8b 10                	mov    (%eax),%edx
  800363:	8d 4a 08             	lea    0x8(%edx),%ecx
  800366:	89 08                	mov    %ecx,(%eax)
  800368:	8b 02                	mov    (%edx),%eax
  80036a:	8b 52 04             	mov    0x4(%edx),%edx
  80036d:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  80036e:	8b 10                	mov    (%eax),%edx
  800370:	8d 4a 04             	lea    0x4(%edx),%ecx
  800373:	89 08                	mov    %ecx,(%eax)
  800375:	8b 02                	mov    (%edx),%eax
  800377:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80037c:	c3                   	ret    

0080037d <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80037d:	83 fa 01             	cmp    $0x1,%edx
  800380:	7f 0f                	jg     800391 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800382:	85 d2                	test   %edx,%edx
  800384:	74 18                	je     80039e <getint+0x21>
		return va_arg(*ap, long);
  800386:	8b 10                	mov    (%eax),%edx
  800388:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038b:	89 08                	mov    %ecx,(%eax)
  80038d:	8b 02                	mov    (%edx),%eax
  80038f:	99                   	cltd   
  800390:	c3                   	ret    
		return va_arg(*ap, long long);
  800391:	8b 10                	mov    (%eax),%edx
  800393:	8d 4a 08             	lea    0x8(%edx),%ecx
  800396:	89 08                	mov    %ecx,(%eax)
  800398:	8b 02                	mov    (%edx),%eax
  80039a:	8b 52 04             	mov    0x4(%edx),%edx
  80039d:	c3                   	ret    
	else
		return va_arg(*ap, int);
  80039e:	8b 10                	mov    (%eax),%edx
  8003a0:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a3:	89 08                	mov    %ecx,(%eax)
  8003a5:	8b 02                	mov    (%edx),%eax
  8003a7:	99                   	cltd   
}
  8003a8:	c3                   	ret    

008003a9 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003a9:	f3 0f 1e fb          	endbr32 
  8003ad:	55                   	push   %ebp
  8003ae:	89 e5                	mov    %esp,%ebp
  8003b0:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003b3:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003b7:	8b 10                	mov    (%eax),%edx
  8003b9:	3b 50 04             	cmp    0x4(%eax),%edx
  8003bc:	73 0a                	jae    8003c8 <sprintputch+0x1f>
		*b->buf++ = ch;
  8003be:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003c1:	89 08                	mov    %ecx,(%eax)
  8003c3:	8b 45 08             	mov    0x8(%ebp),%eax
  8003c6:	88 02                	mov    %al,(%edx)
}
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <printfmt>:
{
  8003ca:	f3 0f 1e fb          	endbr32 
  8003ce:	55                   	push   %ebp
  8003cf:	89 e5                	mov    %esp,%ebp
  8003d1:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8003d4:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8003d7:	50                   	push   %eax
  8003d8:	ff 75 10             	pushl  0x10(%ebp)
  8003db:	ff 75 0c             	pushl  0xc(%ebp)
  8003de:	ff 75 08             	pushl  0x8(%ebp)
  8003e1:	e8 05 00 00 00       	call   8003eb <vprintfmt>
}
  8003e6:	83 c4 10             	add    $0x10,%esp
  8003e9:	c9                   	leave  
  8003ea:	c3                   	ret    

008003eb <vprintfmt>:
{
  8003eb:	f3 0f 1e fb          	endbr32 
  8003ef:	55                   	push   %ebp
  8003f0:	89 e5                	mov    %esp,%ebp
  8003f2:	57                   	push   %edi
  8003f3:	56                   	push   %esi
  8003f4:	53                   	push   %ebx
  8003f5:	83 ec 2c             	sub    $0x2c,%esp
  8003f8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003fb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8003fe:	8b 7d 10             	mov    0x10(%ebp),%edi
  800401:	e9 86 02 00 00       	jmp    80068c <vprintfmt+0x2a1>
		padc = ' ';
  800406:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80040a:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800411:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800418:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80041f:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800424:	8d 47 01             	lea    0x1(%edi),%eax
  800427:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80042a:	0f b6 17             	movzbl (%edi),%edx
  80042d:	8d 42 dd             	lea    -0x23(%edx),%eax
  800430:	3c 55                	cmp    $0x55,%al
  800432:	0f 87 df 02 00 00    	ja     800717 <vprintfmt+0x32c>
  800438:	0f b6 c0             	movzbl %al,%eax
  80043b:	3e ff 24 85 a0 21 80 	notrack jmp *0x8021a0(,%eax,4)
  800442:	00 
  800443:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800446:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80044a:	eb d8                	jmp    800424 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80044c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80044f:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800453:	eb cf                	jmp    800424 <vprintfmt+0x39>
  800455:	0f b6 d2             	movzbl %dl,%edx
  800458:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80045b:	b8 00 00 00 00       	mov    $0x0,%eax
  800460:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800463:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800466:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80046a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80046d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800470:	83 f9 09             	cmp    $0x9,%ecx
  800473:	77 52                	ja     8004c7 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  800475:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800478:	eb e9                	jmp    800463 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80047a:	8b 45 14             	mov    0x14(%ebp),%eax
  80047d:	8d 50 04             	lea    0x4(%eax),%edx
  800480:	89 55 14             	mov    %edx,0x14(%ebp)
  800483:	8b 00                	mov    (%eax),%eax
  800485:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800488:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80048b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80048f:	79 93                	jns    800424 <vprintfmt+0x39>
				width = precision, precision = -1;
  800491:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800494:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800497:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80049e:	eb 84                	jmp    800424 <vprintfmt+0x39>
  8004a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a3:	85 c0                	test   %eax,%eax
  8004a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8004aa:	0f 49 d0             	cmovns %eax,%edx
  8004ad:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004b0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004b3:	e9 6c ff ff ff       	jmp    800424 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8004b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004bb:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004c2:	e9 5d ff ff ff       	jmp    800424 <vprintfmt+0x39>
  8004c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ca:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8004cd:	eb bc                	jmp    80048b <vprintfmt+0xa0>
			lflag++;
  8004cf:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8004d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004d5:	e9 4a ff ff ff       	jmp    800424 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8004da:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dd:	8d 50 04             	lea    0x4(%eax),%edx
  8004e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e3:	83 ec 08             	sub    $0x8,%esp
  8004e6:	56                   	push   %esi
  8004e7:	ff 30                	pushl  (%eax)
  8004e9:	ff d3                	call   *%ebx
			break;
  8004eb:	83 c4 10             	add    $0x10,%esp
  8004ee:	e9 96 01 00 00       	jmp    800689 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8004f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8004f6:	8d 50 04             	lea    0x4(%eax),%edx
  8004f9:	89 55 14             	mov    %edx,0x14(%ebp)
  8004fc:	8b 00                	mov    (%eax),%eax
  8004fe:	99                   	cltd   
  8004ff:	31 d0                	xor    %edx,%eax
  800501:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800503:	83 f8 0f             	cmp    $0xf,%eax
  800506:	7f 20                	jg     800528 <vprintfmt+0x13d>
  800508:	8b 14 85 00 23 80 00 	mov    0x802300(,%eax,4),%edx
  80050f:	85 d2                	test   %edx,%edx
  800511:	74 15                	je     800528 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  800513:	52                   	push   %edx
  800514:	68 31 24 80 00       	push   $0x802431
  800519:	56                   	push   %esi
  80051a:	53                   	push   %ebx
  80051b:	e8 aa fe ff ff       	call   8003ca <printfmt>
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	e9 61 01 00 00       	jmp    800689 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800528:	50                   	push   %eax
  800529:	68 7f 20 80 00       	push   $0x80207f
  80052e:	56                   	push   %esi
  80052f:	53                   	push   %ebx
  800530:	e8 95 fe ff ff       	call   8003ca <printfmt>
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	e9 4c 01 00 00       	jmp    800689 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  80053d:	8b 45 14             	mov    0x14(%ebp),%eax
  800540:	8d 50 04             	lea    0x4(%eax),%edx
  800543:	89 55 14             	mov    %edx,0x14(%ebp)
  800546:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800548:	85 c9                	test   %ecx,%ecx
  80054a:	b8 78 20 80 00       	mov    $0x802078,%eax
  80054f:	0f 45 c1             	cmovne %ecx,%eax
  800552:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800555:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800559:	7e 06                	jle    800561 <vprintfmt+0x176>
  80055b:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80055f:	75 0d                	jne    80056e <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  800561:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800564:	89 c7                	mov    %eax,%edi
  800566:	03 45 e0             	add    -0x20(%ebp),%eax
  800569:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80056c:	eb 57                	jmp    8005c5 <vprintfmt+0x1da>
  80056e:	83 ec 08             	sub    $0x8,%esp
  800571:	ff 75 d8             	pushl  -0x28(%ebp)
  800574:	ff 75 cc             	pushl  -0x34(%ebp)
  800577:	e8 4f 02 00 00       	call   8007cb <strnlen>
  80057c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80057f:	29 c2                	sub    %eax,%edx
  800581:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800584:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800587:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80058b:	89 5d 08             	mov    %ebx,0x8(%ebp)
  80058e:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800590:	85 db                	test   %ebx,%ebx
  800592:	7e 10                	jle    8005a4 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800594:	83 ec 08             	sub    $0x8,%esp
  800597:	56                   	push   %esi
  800598:	57                   	push   %edi
  800599:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80059c:	83 eb 01             	sub    $0x1,%ebx
  80059f:	83 c4 10             	add    $0x10,%esp
  8005a2:	eb ec                	jmp    800590 <vprintfmt+0x1a5>
  8005a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005a7:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005aa:	85 d2                	test   %edx,%edx
  8005ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8005b1:	0f 49 c2             	cmovns %edx,%eax
  8005b4:	29 c2                	sub    %eax,%edx
  8005b6:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005b9:	eb a6                	jmp    800561 <vprintfmt+0x176>
					putch(ch, putdat);
  8005bb:	83 ec 08             	sub    $0x8,%esp
  8005be:	56                   	push   %esi
  8005bf:	52                   	push   %edx
  8005c0:	ff d3                	call   *%ebx
  8005c2:	83 c4 10             	add    $0x10,%esp
  8005c5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005c8:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ca:	83 c7 01             	add    $0x1,%edi
  8005cd:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8005d1:	0f be d0             	movsbl %al,%edx
  8005d4:	85 d2                	test   %edx,%edx
  8005d6:	74 42                	je     80061a <vprintfmt+0x22f>
  8005d8:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8005dc:	78 06                	js     8005e4 <vprintfmt+0x1f9>
  8005de:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8005e2:	78 1e                	js     800602 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  8005e4:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8005e8:	74 d1                	je     8005bb <vprintfmt+0x1d0>
  8005ea:	0f be c0             	movsbl %al,%eax
  8005ed:	83 e8 20             	sub    $0x20,%eax
  8005f0:	83 f8 5e             	cmp    $0x5e,%eax
  8005f3:	76 c6                	jbe    8005bb <vprintfmt+0x1d0>
					putch('?', putdat);
  8005f5:	83 ec 08             	sub    $0x8,%esp
  8005f8:	56                   	push   %esi
  8005f9:	6a 3f                	push   $0x3f
  8005fb:	ff d3                	call   *%ebx
  8005fd:	83 c4 10             	add    $0x10,%esp
  800600:	eb c3                	jmp    8005c5 <vprintfmt+0x1da>
  800602:	89 cf                	mov    %ecx,%edi
  800604:	eb 0e                	jmp    800614 <vprintfmt+0x229>
				putch(' ', putdat);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	56                   	push   %esi
  80060a:	6a 20                	push   $0x20
  80060c:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  80060e:	83 ef 01             	sub    $0x1,%edi
  800611:	83 c4 10             	add    $0x10,%esp
  800614:	85 ff                	test   %edi,%edi
  800616:	7f ee                	jg     800606 <vprintfmt+0x21b>
  800618:	eb 6f                	jmp    800689 <vprintfmt+0x29e>
  80061a:	89 cf                	mov    %ecx,%edi
  80061c:	eb f6                	jmp    800614 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  80061e:	89 ca                	mov    %ecx,%edx
  800620:	8d 45 14             	lea    0x14(%ebp),%eax
  800623:	e8 55 fd ff ff       	call   80037d <getint>
  800628:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80062b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  80062e:	85 d2                	test   %edx,%edx
  800630:	78 0b                	js     80063d <vprintfmt+0x252>
			num = getint(&ap, lflag);
  800632:	89 d1                	mov    %edx,%ecx
  800634:	89 c2                	mov    %eax,%edx
			base = 10;
  800636:	b8 0a 00 00 00       	mov    $0xa,%eax
  80063b:	eb 32                	jmp    80066f <vprintfmt+0x284>
				putch('-', putdat);
  80063d:	83 ec 08             	sub    $0x8,%esp
  800640:	56                   	push   %esi
  800641:	6a 2d                	push   $0x2d
  800643:	ff d3                	call   *%ebx
				num = -(long long) num;
  800645:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800648:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80064b:	f7 da                	neg    %edx
  80064d:	83 d1 00             	adc    $0x0,%ecx
  800650:	f7 d9                	neg    %ecx
  800652:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800655:	b8 0a 00 00 00       	mov    $0xa,%eax
  80065a:	eb 13                	jmp    80066f <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  80065c:	89 ca                	mov    %ecx,%edx
  80065e:	8d 45 14             	lea    0x14(%ebp),%eax
  800661:	e8 e3 fc ff ff       	call   800349 <getuint>
  800666:	89 d1                	mov    %edx,%ecx
  800668:	89 c2                	mov    %eax,%edx
			base = 10;
  80066a:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  80066f:	83 ec 0c             	sub    $0xc,%esp
  800672:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800676:	57                   	push   %edi
  800677:	ff 75 e0             	pushl  -0x20(%ebp)
  80067a:	50                   	push   %eax
  80067b:	51                   	push   %ecx
  80067c:	52                   	push   %edx
  80067d:	89 f2                	mov    %esi,%edx
  80067f:	89 d8                	mov    %ebx,%eax
  800681:	e8 1a fc ff ff       	call   8002a0 <printnum>
			break;
  800686:	83 c4 20             	add    $0x20,%esp
{
  800689:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80068c:	83 c7 01             	add    $0x1,%edi
  80068f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800693:	83 f8 25             	cmp    $0x25,%eax
  800696:	0f 84 6a fd ff ff    	je     800406 <vprintfmt+0x1b>
			if (ch == '\0')
  80069c:	85 c0                	test   %eax,%eax
  80069e:	0f 84 93 00 00 00    	je     800737 <vprintfmt+0x34c>
			putch(ch, putdat);
  8006a4:	83 ec 08             	sub    $0x8,%esp
  8006a7:	56                   	push   %esi
  8006a8:	50                   	push   %eax
  8006a9:	ff d3                	call   *%ebx
  8006ab:	83 c4 10             	add    $0x10,%esp
  8006ae:	eb dc                	jmp    80068c <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  8006b0:	89 ca                	mov    %ecx,%edx
  8006b2:	8d 45 14             	lea    0x14(%ebp),%eax
  8006b5:	e8 8f fc ff ff       	call   800349 <getuint>
  8006ba:	89 d1                	mov    %edx,%ecx
  8006bc:	89 c2                	mov    %eax,%edx
			base = 8;
  8006be:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006c3:	eb aa                	jmp    80066f <vprintfmt+0x284>
			putch('0', putdat);
  8006c5:	83 ec 08             	sub    $0x8,%esp
  8006c8:	56                   	push   %esi
  8006c9:	6a 30                	push   $0x30
  8006cb:	ff d3                	call   *%ebx
			putch('x', putdat);
  8006cd:	83 c4 08             	add    $0x8,%esp
  8006d0:	56                   	push   %esi
  8006d1:	6a 78                	push   $0x78
  8006d3:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  8006d5:	8b 45 14             	mov    0x14(%ebp),%eax
  8006d8:	8d 50 04             	lea    0x4(%eax),%edx
  8006db:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8006de:	8b 10                	mov    (%eax),%edx
  8006e0:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8006e5:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8006e8:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8006ed:	eb 80                	jmp    80066f <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8006ef:	89 ca                	mov    %ecx,%edx
  8006f1:	8d 45 14             	lea    0x14(%ebp),%eax
  8006f4:	e8 50 fc ff ff       	call   800349 <getuint>
  8006f9:	89 d1                	mov    %edx,%ecx
  8006fb:	89 c2                	mov    %eax,%edx
			base = 16;
  8006fd:	b8 10 00 00 00       	mov    $0x10,%eax
  800702:	e9 68 ff ff ff       	jmp    80066f <vprintfmt+0x284>
			putch(ch, putdat);
  800707:	83 ec 08             	sub    $0x8,%esp
  80070a:	56                   	push   %esi
  80070b:	6a 25                	push   $0x25
  80070d:	ff d3                	call   *%ebx
			break;
  80070f:	83 c4 10             	add    $0x10,%esp
  800712:	e9 72 ff ff ff       	jmp    800689 <vprintfmt+0x29e>
			putch('%', putdat);
  800717:	83 ec 08             	sub    $0x8,%esp
  80071a:	56                   	push   %esi
  80071b:	6a 25                	push   $0x25
  80071d:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  80071f:	83 c4 10             	add    $0x10,%esp
  800722:	89 f8                	mov    %edi,%eax
  800724:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800728:	74 05                	je     80072f <vprintfmt+0x344>
  80072a:	83 e8 01             	sub    $0x1,%eax
  80072d:	eb f5                	jmp    800724 <vprintfmt+0x339>
  80072f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800732:	e9 52 ff ff ff       	jmp    800689 <vprintfmt+0x29e>
}
  800737:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80073a:	5b                   	pop    %ebx
  80073b:	5e                   	pop    %esi
  80073c:	5f                   	pop    %edi
  80073d:	5d                   	pop    %ebp
  80073e:	c3                   	ret    

0080073f <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80073f:	f3 0f 1e fb          	endbr32 
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	83 ec 18             	sub    $0x18,%esp
  800749:	8b 45 08             	mov    0x8(%ebp),%eax
  80074c:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80074f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800752:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800756:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800759:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800760:	85 c0                	test   %eax,%eax
  800762:	74 26                	je     80078a <vsnprintf+0x4b>
  800764:	85 d2                	test   %edx,%edx
  800766:	7e 22                	jle    80078a <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800768:	ff 75 14             	pushl  0x14(%ebp)
  80076b:	ff 75 10             	pushl  0x10(%ebp)
  80076e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800771:	50                   	push   %eax
  800772:	68 a9 03 80 00       	push   $0x8003a9
  800777:	e8 6f fc ff ff       	call   8003eb <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80077c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80077f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800782:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800785:	83 c4 10             	add    $0x10,%esp
}
  800788:	c9                   	leave  
  800789:	c3                   	ret    
		return -E_INVAL;
  80078a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80078f:	eb f7                	jmp    800788 <vsnprintf+0x49>

00800791 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800791:	f3 0f 1e fb          	endbr32 
  800795:	55                   	push   %ebp
  800796:	89 e5                	mov    %esp,%ebp
  800798:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80079b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80079e:	50                   	push   %eax
  80079f:	ff 75 10             	pushl  0x10(%ebp)
  8007a2:	ff 75 0c             	pushl  0xc(%ebp)
  8007a5:	ff 75 08             	pushl  0x8(%ebp)
  8007a8:	e8 92 ff ff ff       	call   80073f <vsnprintf>
	va_end(ap);

	return rc;
}
  8007ad:	c9                   	leave  
  8007ae:	c3                   	ret    

008007af <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007af:	f3 0f 1e fb          	endbr32 
  8007b3:	55                   	push   %ebp
  8007b4:	89 e5                	mov    %esp,%ebp
  8007b6:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007b9:	b8 00 00 00 00       	mov    $0x0,%eax
  8007be:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007c2:	74 05                	je     8007c9 <strlen+0x1a>
		n++;
  8007c4:	83 c0 01             	add    $0x1,%eax
  8007c7:	eb f5                	jmp    8007be <strlen+0xf>
	return n;
}
  8007c9:	5d                   	pop    %ebp
  8007ca:	c3                   	ret    

008007cb <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8007cb:	f3 0f 1e fb          	endbr32 
  8007cf:	55                   	push   %ebp
  8007d0:	89 e5                	mov    %esp,%ebp
  8007d2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007d5:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8007d8:	b8 00 00 00 00       	mov    $0x0,%eax
  8007dd:	39 d0                	cmp    %edx,%eax
  8007df:	74 0d                	je     8007ee <strnlen+0x23>
  8007e1:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8007e5:	74 05                	je     8007ec <strnlen+0x21>
		n++;
  8007e7:	83 c0 01             	add    $0x1,%eax
  8007ea:	eb f1                	jmp    8007dd <strnlen+0x12>
  8007ec:	89 c2                	mov    %eax,%edx
	return n;
}
  8007ee:	89 d0                	mov    %edx,%eax
  8007f0:	5d                   	pop    %ebp
  8007f1:	c3                   	ret    

008007f2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8007f2:	f3 0f 1e fb          	endbr32 
  8007f6:	55                   	push   %ebp
  8007f7:	89 e5                	mov    %esp,%ebp
  8007f9:	53                   	push   %ebx
  8007fa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007fd:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800800:	b8 00 00 00 00       	mov    $0x0,%eax
  800805:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800809:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  80080c:	83 c0 01             	add    $0x1,%eax
  80080f:	84 d2                	test   %dl,%dl
  800811:	75 f2                	jne    800805 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800813:	89 c8                	mov    %ecx,%eax
  800815:	5b                   	pop    %ebx
  800816:	5d                   	pop    %ebp
  800817:	c3                   	ret    

00800818 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800818:	f3 0f 1e fb          	endbr32 
  80081c:	55                   	push   %ebp
  80081d:	89 e5                	mov    %esp,%ebp
  80081f:	53                   	push   %ebx
  800820:	83 ec 10             	sub    $0x10,%esp
  800823:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800826:	53                   	push   %ebx
  800827:	e8 83 ff ff ff       	call   8007af <strlen>
  80082c:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  80082f:	ff 75 0c             	pushl  0xc(%ebp)
  800832:	01 d8                	add    %ebx,%eax
  800834:	50                   	push   %eax
  800835:	e8 b8 ff ff ff       	call   8007f2 <strcpy>
	return dst;
}
  80083a:	89 d8                	mov    %ebx,%eax
  80083c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083f:	c9                   	leave  
  800840:	c3                   	ret    

00800841 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800841:	f3 0f 1e fb          	endbr32 
  800845:	55                   	push   %ebp
  800846:	89 e5                	mov    %esp,%ebp
  800848:	56                   	push   %esi
  800849:	53                   	push   %ebx
  80084a:	8b 75 08             	mov    0x8(%ebp),%esi
  80084d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800850:	89 f3                	mov    %esi,%ebx
  800852:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800855:	89 f0                	mov    %esi,%eax
  800857:	39 d8                	cmp    %ebx,%eax
  800859:	74 11                	je     80086c <strncpy+0x2b>
		*dst++ = *src;
  80085b:	83 c0 01             	add    $0x1,%eax
  80085e:	0f b6 0a             	movzbl (%edx),%ecx
  800861:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800864:	80 f9 01             	cmp    $0x1,%cl
  800867:	83 da ff             	sbb    $0xffffffff,%edx
  80086a:	eb eb                	jmp    800857 <strncpy+0x16>
	}
	return ret;
}
  80086c:	89 f0                	mov    %esi,%eax
  80086e:	5b                   	pop    %ebx
  80086f:	5e                   	pop    %esi
  800870:	5d                   	pop    %ebp
  800871:	c3                   	ret    

00800872 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800872:	f3 0f 1e fb          	endbr32 
  800876:	55                   	push   %ebp
  800877:	89 e5                	mov    %esp,%ebp
  800879:	56                   	push   %esi
  80087a:	53                   	push   %ebx
  80087b:	8b 75 08             	mov    0x8(%ebp),%esi
  80087e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800881:	8b 55 10             	mov    0x10(%ebp),%edx
  800884:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800886:	85 d2                	test   %edx,%edx
  800888:	74 21                	je     8008ab <strlcpy+0x39>
  80088a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80088e:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800890:	39 c2                	cmp    %eax,%edx
  800892:	74 14                	je     8008a8 <strlcpy+0x36>
  800894:	0f b6 19             	movzbl (%ecx),%ebx
  800897:	84 db                	test   %bl,%bl
  800899:	74 0b                	je     8008a6 <strlcpy+0x34>
			*dst++ = *src++;
  80089b:	83 c1 01             	add    $0x1,%ecx
  80089e:	83 c2 01             	add    $0x1,%edx
  8008a1:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008a4:	eb ea                	jmp    800890 <strlcpy+0x1e>
  8008a6:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008a8:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008ab:	29 f0                	sub    %esi,%eax
}
  8008ad:	5b                   	pop    %ebx
  8008ae:	5e                   	pop    %esi
  8008af:	5d                   	pop    %ebp
  8008b0:	c3                   	ret    

008008b1 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008b1:	f3 0f 1e fb          	endbr32 
  8008b5:	55                   	push   %ebp
  8008b6:	89 e5                	mov    %esp,%ebp
  8008b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008bb:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008be:	0f b6 01             	movzbl (%ecx),%eax
  8008c1:	84 c0                	test   %al,%al
  8008c3:	74 0c                	je     8008d1 <strcmp+0x20>
  8008c5:	3a 02                	cmp    (%edx),%al
  8008c7:	75 08                	jne    8008d1 <strcmp+0x20>
		p++, q++;
  8008c9:	83 c1 01             	add    $0x1,%ecx
  8008cc:	83 c2 01             	add    $0x1,%edx
  8008cf:	eb ed                	jmp    8008be <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8008d1:	0f b6 c0             	movzbl %al,%eax
  8008d4:	0f b6 12             	movzbl (%edx),%edx
  8008d7:	29 d0                	sub    %edx,%eax
}
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8008db:	f3 0f 1e fb          	endbr32 
  8008df:	55                   	push   %ebp
  8008e0:	89 e5                	mov    %esp,%ebp
  8008e2:	53                   	push   %ebx
  8008e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8008e9:	89 c3                	mov    %eax,%ebx
  8008eb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8008ee:	eb 06                	jmp    8008f6 <strncmp+0x1b>
		n--, p++, q++;
  8008f0:	83 c0 01             	add    $0x1,%eax
  8008f3:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8008f6:	39 d8                	cmp    %ebx,%eax
  8008f8:	74 16                	je     800910 <strncmp+0x35>
  8008fa:	0f b6 08             	movzbl (%eax),%ecx
  8008fd:	84 c9                	test   %cl,%cl
  8008ff:	74 04                	je     800905 <strncmp+0x2a>
  800901:	3a 0a                	cmp    (%edx),%cl
  800903:	74 eb                	je     8008f0 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800905:	0f b6 00             	movzbl (%eax),%eax
  800908:	0f b6 12             	movzbl (%edx),%edx
  80090b:	29 d0                	sub    %edx,%eax
}
  80090d:	5b                   	pop    %ebx
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    
		return 0;
  800910:	b8 00 00 00 00       	mov    $0x0,%eax
  800915:	eb f6                	jmp    80090d <strncmp+0x32>

00800917 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800917:	f3 0f 1e fb          	endbr32 
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800925:	0f b6 10             	movzbl (%eax),%edx
  800928:	84 d2                	test   %dl,%dl
  80092a:	74 09                	je     800935 <strchr+0x1e>
		if (*s == c)
  80092c:	38 ca                	cmp    %cl,%dl
  80092e:	74 0a                	je     80093a <strchr+0x23>
	for (; *s; s++)
  800930:	83 c0 01             	add    $0x1,%eax
  800933:	eb f0                	jmp    800925 <strchr+0xe>
			return (char *) s;
	return 0;
  800935:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80093a:	5d                   	pop    %ebp
  80093b:	c3                   	ret    

0080093c <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80093c:	f3 0f 1e fb          	endbr32 
  800940:	55                   	push   %ebp
  800941:	89 e5                	mov    %esp,%ebp
  800943:	8b 45 08             	mov    0x8(%ebp),%eax
  800946:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80094a:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80094d:	38 ca                	cmp    %cl,%dl
  80094f:	74 09                	je     80095a <strfind+0x1e>
  800951:	84 d2                	test   %dl,%dl
  800953:	74 05                	je     80095a <strfind+0x1e>
	for (; *s; s++)
  800955:	83 c0 01             	add    $0x1,%eax
  800958:	eb f0                	jmp    80094a <strfind+0xe>
			break;
	return (char *) s;
}
  80095a:	5d                   	pop    %ebp
  80095b:	c3                   	ret    

0080095c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80095c:	f3 0f 1e fb          	endbr32 
  800960:	55                   	push   %ebp
  800961:	89 e5                	mov    %esp,%ebp
  800963:	57                   	push   %edi
  800964:	56                   	push   %esi
  800965:	53                   	push   %ebx
  800966:	8b 55 08             	mov    0x8(%ebp),%edx
  800969:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  80096c:	85 c9                	test   %ecx,%ecx
  80096e:	74 33                	je     8009a3 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800970:	89 d0                	mov    %edx,%eax
  800972:	09 c8                	or     %ecx,%eax
  800974:	a8 03                	test   $0x3,%al
  800976:	75 23                	jne    80099b <memset+0x3f>
		c &= 0xFF;
  800978:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80097c:	89 d8                	mov    %ebx,%eax
  80097e:	c1 e0 08             	shl    $0x8,%eax
  800981:	89 df                	mov    %ebx,%edi
  800983:	c1 e7 18             	shl    $0x18,%edi
  800986:	89 de                	mov    %ebx,%esi
  800988:	c1 e6 10             	shl    $0x10,%esi
  80098b:	09 f7                	or     %esi,%edi
  80098d:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  80098f:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800992:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800994:	89 d7                	mov    %edx,%edi
  800996:	fc                   	cld    
  800997:	f3 ab                	rep stos %eax,%es:(%edi)
  800999:	eb 08                	jmp    8009a3 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80099b:	89 d7                	mov    %edx,%edi
  80099d:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009a0:	fc                   	cld    
  8009a1:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  8009a3:	89 d0                	mov    %edx,%eax
  8009a5:	5b                   	pop    %ebx
  8009a6:	5e                   	pop    %esi
  8009a7:	5f                   	pop    %edi
  8009a8:	5d                   	pop    %ebp
  8009a9:	c3                   	ret    

008009aa <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009aa:	f3 0f 1e fb          	endbr32 
  8009ae:	55                   	push   %ebp
  8009af:	89 e5                	mov    %esp,%ebp
  8009b1:	57                   	push   %edi
  8009b2:	56                   	push   %esi
  8009b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009b9:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009bc:	39 c6                	cmp    %eax,%esi
  8009be:	73 32                	jae    8009f2 <memmove+0x48>
  8009c0:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009c3:	39 c2                	cmp    %eax,%edx
  8009c5:	76 2b                	jbe    8009f2 <memmove+0x48>
		s += n;
		d += n;
  8009c7:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ca:	89 fe                	mov    %edi,%esi
  8009cc:	09 ce                	or     %ecx,%esi
  8009ce:	09 d6                	or     %edx,%esi
  8009d0:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8009d6:	75 0e                	jne    8009e6 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8009d8:	83 ef 04             	sub    $0x4,%edi
  8009db:	8d 72 fc             	lea    -0x4(%edx),%esi
  8009de:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8009e1:	fd                   	std    
  8009e2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009e4:	eb 09                	jmp    8009ef <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8009e6:	83 ef 01             	sub    $0x1,%edi
  8009e9:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8009ec:	fd                   	std    
  8009ed:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8009ef:	fc                   	cld    
  8009f0:	eb 1a                	jmp    800a0c <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009f2:	89 c2                	mov    %eax,%edx
  8009f4:	09 ca                	or     %ecx,%edx
  8009f6:	09 f2                	or     %esi,%edx
  8009f8:	f6 c2 03             	test   $0x3,%dl
  8009fb:	75 0a                	jne    800a07 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8009fd:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a00:	89 c7                	mov    %eax,%edi
  800a02:	fc                   	cld    
  800a03:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a05:	eb 05                	jmp    800a0c <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a07:	89 c7                	mov    %eax,%edi
  800a09:	fc                   	cld    
  800a0a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a0c:	5e                   	pop    %esi
  800a0d:	5f                   	pop    %edi
  800a0e:	5d                   	pop    %ebp
  800a0f:	c3                   	ret    

00800a10 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a10:	f3 0f 1e fb          	endbr32 
  800a14:	55                   	push   %ebp
  800a15:	89 e5                	mov    %esp,%ebp
  800a17:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a1a:	ff 75 10             	pushl  0x10(%ebp)
  800a1d:	ff 75 0c             	pushl  0xc(%ebp)
  800a20:	ff 75 08             	pushl  0x8(%ebp)
  800a23:	e8 82 ff ff ff       	call   8009aa <memmove>
}
  800a28:	c9                   	leave  
  800a29:	c3                   	ret    

00800a2a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a2a:	f3 0f 1e fb          	endbr32 
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	56                   	push   %esi
  800a32:	53                   	push   %ebx
  800a33:	8b 45 08             	mov    0x8(%ebp),%eax
  800a36:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a39:	89 c6                	mov    %eax,%esi
  800a3b:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a3e:	39 f0                	cmp    %esi,%eax
  800a40:	74 1c                	je     800a5e <memcmp+0x34>
		if (*s1 != *s2)
  800a42:	0f b6 08             	movzbl (%eax),%ecx
  800a45:	0f b6 1a             	movzbl (%edx),%ebx
  800a48:	38 d9                	cmp    %bl,%cl
  800a4a:	75 08                	jne    800a54 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a4c:	83 c0 01             	add    $0x1,%eax
  800a4f:	83 c2 01             	add    $0x1,%edx
  800a52:	eb ea                	jmp    800a3e <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a54:	0f b6 c1             	movzbl %cl,%eax
  800a57:	0f b6 db             	movzbl %bl,%ebx
  800a5a:	29 d8                	sub    %ebx,%eax
  800a5c:	eb 05                	jmp    800a63 <memcmp+0x39>
	}

	return 0;
  800a5e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a63:	5b                   	pop    %ebx
  800a64:	5e                   	pop    %esi
  800a65:	5d                   	pop    %ebp
  800a66:	c3                   	ret    

00800a67 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a67:	f3 0f 1e fb          	endbr32 
  800a6b:	55                   	push   %ebp
  800a6c:	89 e5                	mov    %esp,%ebp
  800a6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a71:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a74:	89 c2                	mov    %eax,%edx
  800a76:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a79:	39 d0                	cmp    %edx,%eax
  800a7b:	73 09                	jae    800a86 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a7d:	38 08                	cmp    %cl,(%eax)
  800a7f:	74 05                	je     800a86 <memfind+0x1f>
	for (; s < ends; s++)
  800a81:	83 c0 01             	add    $0x1,%eax
  800a84:	eb f3                	jmp    800a79 <memfind+0x12>
			break;
	return (void *) s;
}
  800a86:	5d                   	pop    %ebp
  800a87:	c3                   	ret    

00800a88 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a88:	f3 0f 1e fb          	endbr32 
  800a8c:	55                   	push   %ebp
  800a8d:	89 e5                	mov    %esp,%ebp
  800a8f:	57                   	push   %edi
  800a90:	56                   	push   %esi
  800a91:	53                   	push   %ebx
  800a92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a95:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a98:	eb 03                	jmp    800a9d <strtol+0x15>
		s++;
  800a9a:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a9d:	0f b6 01             	movzbl (%ecx),%eax
  800aa0:	3c 20                	cmp    $0x20,%al
  800aa2:	74 f6                	je     800a9a <strtol+0x12>
  800aa4:	3c 09                	cmp    $0x9,%al
  800aa6:	74 f2                	je     800a9a <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800aa8:	3c 2b                	cmp    $0x2b,%al
  800aaa:	74 2a                	je     800ad6 <strtol+0x4e>
	int neg = 0;
  800aac:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ab1:	3c 2d                	cmp    $0x2d,%al
  800ab3:	74 2b                	je     800ae0 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800ab5:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800abb:	75 0f                	jne    800acc <strtol+0x44>
  800abd:	80 39 30             	cmpb   $0x30,(%ecx)
  800ac0:	74 28                	je     800aea <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800ac2:	85 db                	test   %ebx,%ebx
  800ac4:	b8 0a 00 00 00       	mov    $0xa,%eax
  800ac9:	0f 44 d8             	cmove  %eax,%ebx
  800acc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad1:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800ad4:	eb 46                	jmp    800b1c <strtol+0x94>
		s++;
  800ad6:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800ad9:	bf 00 00 00 00       	mov    $0x0,%edi
  800ade:	eb d5                	jmp    800ab5 <strtol+0x2d>
		s++, neg = 1;
  800ae0:	83 c1 01             	add    $0x1,%ecx
  800ae3:	bf 01 00 00 00       	mov    $0x1,%edi
  800ae8:	eb cb                	jmp    800ab5 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aea:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800aee:	74 0e                	je     800afe <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800af0:	85 db                	test   %ebx,%ebx
  800af2:	75 d8                	jne    800acc <strtol+0x44>
		s++, base = 8;
  800af4:	83 c1 01             	add    $0x1,%ecx
  800af7:	bb 08 00 00 00       	mov    $0x8,%ebx
  800afc:	eb ce                	jmp    800acc <strtol+0x44>
		s += 2, base = 16;
  800afe:	83 c1 02             	add    $0x2,%ecx
  800b01:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b06:	eb c4                	jmp    800acc <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b08:	0f be d2             	movsbl %dl,%edx
  800b0b:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b0e:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b11:	7d 3a                	jge    800b4d <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b13:	83 c1 01             	add    $0x1,%ecx
  800b16:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b1a:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b1c:	0f b6 11             	movzbl (%ecx),%edx
  800b1f:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b22:	89 f3                	mov    %esi,%ebx
  800b24:	80 fb 09             	cmp    $0x9,%bl
  800b27:	76 df                	jbe    800b08 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b29:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b2c:	89 f3                	mov    %esi,%ebx
  800b2e:	80 fb 19             	cmp    $0x19,%bl
  800b31:	77 08                	ja     800b3b <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b33:	0f be d2             	movsbl %dl,%edx
  800b36:	83 ea 57             	sub    $0x57,%edx
  800b39:	eb d3                	jmp    800b0e <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b3b:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b3e:	89 f3                	mov    %esi,%ebx
  800b40:	80 fb 19             	cmp    $0x19,%bl
  800b43:	77 08                	ja     800b4d <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b45:	0f be d2             	movsbl %dl,%edx
  800b48:	83 ea 37             	sub    $0x37,%edx
  800b4b:	eb c1                	jmp    800b0e <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b4d:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b51:	74 05                	je     800b58 <strtol+0xd0>
		*endptr = (char *) s;
  800b53:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b56:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b58:	89 c2                	mov    %eax,%edx
  800b5a:	f7 da                	neg    %edx
  800b5c:	85 ff                	test   %edi,%edi
  800b5e:	0f 45 c2             	cmovne %edx,%eax
}
  800b61:	5b                   	pop    %ebx
  800b62:	5e                   	pop    %esi
  800b63:	5f                   	pop    %edi
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b66:	55                   	push   %ebp
  800b67:	89 e5                	mov    %esp,%ebp
  800b69:	57                   	push   %edi
  800b6a:	56                   	push   %esi
  800b6b:	53                   	push   %ebx
  800b6c:	83 ec 1c             	sub    $0x1c,%esp
  800b6f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b72:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800b75:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b77:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b7a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b7d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b80:	8b 75 14             	mov    0x14(%ebp),%esi
  800b83:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b85:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b89:	74 04                	je     800b8f <syscall+0x29>
  800b8b:	85 c0                	test   %eax,%eax
  800b8d:	7f 08                	jg     800b97 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800b8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b92:	5b                   	pop    %ebx
  800b93:	5e                   	pop    %esi
  800b94:	5f                   	pop    %edi
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b97:	83 ec 0c             	sub    $0xc,%esp
  800b9a:	50                   	push   %eax
  800b9b:	ff 75 e0             	pushl  -0x20(%ebp)
  800b9e:	68 5f 23 80 00       	push   $0x80235f
  800ba3:	6a 23                	push   $0x23
  800ba5:	68 7c 23 80 00       	push   $0x80237c
  800baa:	e8 f2 f5 ff ff       	call   8001a1 <_panic>

00800baf <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800baf:	f3 0f 1e fb          	endbr32 
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800bb9:	6a 00                	push   $0x0
  800bbb:	6a 00                	push   $0x0
  800bbd:	6a 00                	push   $0x0
  800bbf:	ff 75 0c             	pushl  0xc(%ebp)
  800bc2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc5:	ba 00 00 00 00       	mov    $0x0,%edx
  800bca:	b8 00 00 00 00       	mov    $0x0,%eax
  800bcf:	e8 92 ff ff ff       	call   800b66 <syscall>
}
  800bd4:	83 c4 10             	add    $0x10,%esp
  800bd7:	c9                   	leave  
  800bd8:	c3                   	ret    

00800bd9 <sys_cgetc>:

int
sys_cgetc(void)
{
  800bd9:	f3 0f 1e fb          	endbr32 
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800be3:	6a 00                	push   $0x0
  800be5:	6a 00                	push   $0x0
  800be7:	6a 00                	push   $0x0
  800be9:	6a 00                	push   $0x0
  800beb:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bf0:	ba 00 00 00 00       	mov    $0x0,%edx
  800bf5:	b8 01 00 00 00       	mov    $0x1,%eax
  800bfa:	e8 67 ff ff ff       	call   800b66 <syscall>
}
  800bff:	c9                   	leave  
  800c00:	c3                   	ret    

00800c01 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c01:	f3 0f 1e fb          	endbr32 
  800c05:	55                   	push   %ebp
  800c06:	89 e5                	mov    %esp,%ebp
  800c08:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800c0b:	6a 00                	push   $0x0
  800c0d:	6a 00                	push   $0x0
  800c0f:	6a 00                	push   $0x0
  800c11:	6a 00                	push   $0x0
  800c13:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c16:	ba 01 00 00 00       	mov    $0x1,%edx
  800c1b:	b8 03 00 00 00       	mov    $0x3,%eax
  800c20:	e8 41 ff ff ff       	call   800b66 <syscall>
}
  800c25:	c9                   	leave  
  800c26:	c3                   	ret    

00800c27 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c27:	f3 0f 1e fb          	endbr32 
  800c2b:	55                   	push   %ebp
  800c2c:	89 e5                	mov    %esp,%ebp
  800c2e:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800c31:	6a 00                	push   $0x0
  800c33:	6a 00                	push   $0x0
  800c35:	6a 00                	push   $0x0
  800c37:	6a 00                	push   $0x0
  800c39:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800c43:	b8 02 00 00 00       	mov    $0x2,%eax
  800c48:	e8 19 ff ff ff       	call   800b66 <syscall>
}
  800c4d:	c9                   	leave  
  800c4e:	c3                   	ret    

00800c4f <sys_yield>:

void
sys_yield(void)
{
  800c4f:	f3 0f 1e fb          	endbr32 
  800c53:	55                   	push   %ebp
  800c54:	89 e5                	mov    %esp,%ebp
  800c56:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c59:	6a 00                	push   $0x0
  800c5b:	6a 00                	push   $0x0
  800c5d:	6a 00                	push   $0x0
  800c5f:	6a 00                	push   $0x0
  800c61:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c66:	ba 00 00 00 00       	mov    $0x0,%edx
  800c6b:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c70:	e8 f1 fe ff ff       	call   800b66 <syscall>
}
  800c75:	83 c4 10             	add    $0x10,%esp
  800c78:	c9                   	leave  
  800c79:	c3                   	ret    

00800c7a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c7a:	f3 0f 1e fb          	endbr32 
  800c7e:	55                   	push   %ebp
  800c7f:	89 e5                	mov    %esp,%ebp
  800c81:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c84:	6a 00                	push   $0x0
  800c86:	6a 00                	push   $0x0
  800c88:	ff 75 10             	pushl  0x10(%ebp)
  800c8b:	ff 75 0c             	pushl  0xc(%ebp)
  800c8e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c91:	ba 01 00 00 00       	mov    $0x1,%edx
  800c96:	b8 04 00 00 00       	mov    $0x4,%eax
  800c9b:	e8 c6 fe ff ff       	call   800b66 <syscall>
}
  800ca0:	c9                   	leave  
  800ca1:	c3                   	ret    

00800ca2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ca2:	f3 0f 1e fb          	endbr32 
  800ca6:	55                   	push   %ebp
  800ca7:	89 e5                	mov    %esp,%ebp
  800ca9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800cac:	ff 75 18             	pushl  0x18(%ebp)
  800caf:	ff 75 14             	pushl  0x14(%ebp)
  800cb2:	ff 75 10             	pushl  0x10(%ebp)
  800cb5:	ff 75 0c             	pushl  0xc(%ebp)
  800cb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cbb:	ba 01 00 00 00       	mov    $0x1,%edx
  800cc0:	b8 05 00 00 00       	mov    $0x5,%eax
  800cc5:	e8 9c fe ff ff       	call   800b66 <syscall>
}
  800cca:	c9                   	leave  
  800ccb:	c3                   	ret    

00800ccc <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800ccc:	f3 0f 1e fb          	endbr32 
  800cd0:	55                   	push   %ebp
  800cd1:	89 e5                	mov    %esp,%ebp
  800cd3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800cd6:	6a 00                	push   $0x0
  800cd8:	6a 00                	push   $0x0
  800cda:	6a 00                	push   $0x0
  800cdc:	ff 75 0c             	pushl  0xc(%ebp)
  800cdf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ce2:	ba 01 00 00 00       	mov    $0x1,%edx
  800ce7:	b8 06 00 00 00       	mov    $0x6,%eax
  800cec:	e8 75 fe ff ff       	call   800b66 <syscall>
}
  800cf1:	c9                   	leave  
  800cf2:	c3                   	ret    

00800cf3 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800cf3:	f3 0f 1e fb          	endbr32 
  800cf7:	55                   	push   %ebp
  800cf8:	89 e5                	mov    %esp,%ebp
  800cfa:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800cfd:	6a 00                	push   $0x0
  800cff:	6a 00                	push   $0x0
  800d01:	6a 00                	push   $0x0
  800d03:	ff 75 0c             	pushl  0xc(%ebp)
  800d06:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d09:	ba 01 00 00 00       	mov    $0x1,%edx
  800d0e:	b8 08 00 00 00       	mov    $0x8,%eax
  800d13:	e8 4e fe ff ff       	call   800b66 <syscall>
}
  800d18:	c9                   	leave  
  800d19:	c3                   	ret    

00800d1a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d1a:	f3 0f 1e fb          	endbr32 
  800d1e:	55                   	push   %ebp
  800d1f:	89 e5                	mov    %esp,%ebp
  800d21:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800d24:	6a 00                	push   $0x0
  800d26:	6a 00                	push   $0x0
  800d28:	6a 00                	push   $0x0
  800d2a:	ff 75 0c             	pushl  0xc(%ebp)
  800d2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d30:	ba 01 00 00 00       	mov    $0x1,%edx
  800d35:	b8 09 00 00 00       	mov    $0x9,%eax
  800d3a:	e8 27 fe ff ff       	call   800b66 <syscall>
}
  800d3f:	c9                   	leave  
  800d40:	c3                   	ret    

00800d41 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d41:	f3 0f 1e fb          	endbr32 
  800d45:	55                   	push   %ebp
  800d46:	89 e5                	mov    %esp,%ebp
  800d48:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d4b:	6a 00                	push   $0x0
  800d4d:	6a 00                	push   $0x0
  800d4f:	6a 00                	push   $0x0
  800d51:	ff 75 0c             	pushl  0xc(%ebp)
  800d54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d57:	ba 01 00 00 00       	mov    $0x1,%edx
  800d5c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d61:	e8 00 fe ff ff       	call   800b66 <syscall>
}
  800d66:	c9                   	leave  
  800d67:	c3                   	ret    

00800d68 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d68:	f3 0f 1e fb          	endbr32 
  800d6c:	55                   	push   %ebp
  800d6d:	89 e5                	mov    %esp,%ebp
  800d6f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d72:	6a 00                	push   $0x0
  800d74:	ff 75 14             	pushl  0x14(%ebp)
  800d77:	ff 75 10             	pushl  0x10(%ebp)
  800d7a:	ff 75 0c             	pushl  0xc(%ebp)
  800d7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d80:	ba 00 00 00 00       	mov    $0x0,%edx
  800d85:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d8a:	e8 d7 fd ff ff       	call   800b66 <syscall>
}
  800d8f:	c9                   	leave  
  800d90:	c3                   	ret    

00800d91 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d91:	f3 0f 1e fb          	endbr32 
  800d95:	55                   	push   %ebp
  800d96:	89 e5                	mov    %esp,%ebp
  800d98:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d9b:	6a 00                	push   $0x0
  800d9d:	6a 00                	push   $0x0
  800d9f:	6a 00                	push   $0x0
  800da1:	6a 00                	push   $0x0
  800da3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da6:	ba 01 00 00 00       	mov    $0x1,%edx
  800dab:	b8 0d 00 00 00       	mov    $0xd,%eax
  800db0:	e8 b1 fd ff ff       	call   800b66 <syscall>
}
  800db5:	c9                   	leave  
  800db6:	c3                   	ret    

00800db7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800db7:	f3 0f 1e fb          	endbr32 
  800dbb:	55                   	push   %ebp
  800dbc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800dc1:	05 00 00 00 30       	add    $0x30000000,%eax
  800dc6:	c1 e8 0c             	shr    $0xc,%eax
}
  800dc9:	5d                   	pop    %ebp
  800dca:	c3                   	ret    

00800dcb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800dcb:	f3 0f 1e fb          	endbr32 
  800dcf:	55                   	push   %ebp
  800dd0:	89 e5                	mov    %esp,%ebp
  800dd2:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800dd5:	ff 75 08             	pushl  0x8(%ebp)
  800dd8:	e8 da ff ff ff       	call   800db7 <fd2num>
  800ddd:	83 c4 10             	add    $0x10,%esp
  800de0:	c1 e0 0c             	shl    $0xc,%eax
  800de3:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800de8:	c9                   	leave  
  800de9:	c3                   	ret    

00800dea <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800dea:	f3 0f 1e fb          	endbr32 
  800dee:	55                   	push   %ebp
  800def:	89 e5                	mov    %esp,%ebp
  800df1:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800df6:	89 c2                	mov    %eax,%edx
  800df8:	c1 ea 16             	shr    $0x16,%edx
  800dfb:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e02:	f6 c2 01             	test   $0x1,%dl
  800e05:	74 2d                	je     800e34 <fd_alloc+0x4a>
  800e07:	89 c2                	mov    %eax,%edx
  800e09:	c1 ea 0c             	shr    $0xc,%edx
  800e0c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e13:	f6 c2 01             	test   $0x1,%dl
  800e16:	74 1c                	je     800e34 <fd_alloc+0x4a>
  800e18:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800e1d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e22:	75 d2                	jne    800df6 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e24:	8b 45 08             	mov    0x8(%ebp),%eax
  800e27:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800e2d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800e32:	eb 0a                	jmp    800e3e <fd_alloc+0x54>
			*fd_store = fd;
  800e34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e37:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e3e:	5d                   	pop    %ebp
  800e3f:	c3                   	ret    

00800e40 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e40:	f3 0f 1e fb          	endbr32 
  800e44:	55                   	push   %ebp
  800e45:	89 e5                	mov    %esp,%ebp
  800e47:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e4a:	83 f8 1f             	cmp    $0x1f,%eax
  800e4d:	77 30                	ja     800e7f <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e4f:	c1 e0 0c             	shl    $0xc,%eax
  800e52:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e57:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e5d:	f6 c2 01             	test   $0x1,%dl
  800e60:	74 24                	je     800e86 <fd_lookup+0x46>
  800e62:	89 c2                	mov    %eax,%edx
  800e64:	c1 ea 0c             	shr    $0xc,%edx
  800e67:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e6e:	f6 c2 01             	test   $0x1,%dl
  800e71:	74 1a                	je     800e8d <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e73:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e76:	89 02                	mov    %eax,(%edx)
	return 0;
  800e78:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e7d:	5d                   	pop    %ebp
  800e7e:	c3                   	ret    
		return -E_INVAL;
  800e7f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e84:	eb f7                	jmp    800e7d <fd_lookup+0x3d>
		return -E_INVAL;
  800e86:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e8b:	eb f0                	jmp    800e7d <fd_lookup+0x3d>
  800e8d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800e92:	eb e9                	jmp    800e7d <fd_lookup+0x3d>

00800e94 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800e94:	f3 0f 1e fb          	endbr32 
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
  800e9b:	83 ec 08             	sub    $0x8,%esp
  800e9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea1:	ba 08 24 80 00       	mov    $0x802408,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ea6:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800eab:	39 08                	cmp    %ecx,(%eax)
  800ead:	74 33                	je     800ee2 <dev_lookup+0x4e>
  800eaf:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800eb2:	8b 02                	mov    (%edx),%eax
  800eb4:	85 c0                	test   %eax,%eax
  800eb6:	75 f3                	jne    800eab <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800eb8:	a1 20 60 80 00       	mov    0x806020,%eax
  800ebd:	8b 40 48             	mov    0x48(%eax),%eax
  800ec0:	83 ec 04             	sub    $0x4,%esp
  800ec3:	51                   	push   %ecx
  800ec4:	50                   	push   %eax
  800ec5:	68 8c 23 80 00       	push   $0x80238c
  800eca:	e8 b9 f3 ff ff       	call   800288 <cprintf>
	*dev = 0;
  800ecf:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ed2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ed8:	83 c4 10             	add    $0x10,%esp
  800edb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800ee0:	c9                   	leave  
  800ee1:	c3                   	ret    
			*dev = devtab[i];
  800ee2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ee5:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ee7:	b8 00 00 00 00       	mov    $0x0,%eax
  800eec:	eb f2                	jmp    800ee0 <dev_lookup+0x4c>

00800eee <fd_close>:
{
  800eee:	f3 0f 1e fb          	endbr32 
  800ef2:	55                   	push   %ebp
  800ef3:	89 e5                	mov    %esp,%ebp
  800ef5:	57                   	push   %edi
  800ef6:	56                   	push   %esi
  800ef7:	53                   	push   %ebx
  800ef8:	83 ec 28             	sub    $0x28,%esp
  800efb:	8b 75 08             	mov    0x8(%ebp),%esi
  800efe:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f01:	56                   	push   %esi
  800f02:	e8 b0 fe ff ff       	call   800db7 <fd2num>
  800f07:	83 c4 08             	add    $0x8,%esp
  800f0a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800f0d:	52                   	push   %edx
  800f0e:	50                   	push   %eax
  800f0f:	e8 2c ff ff ff       	call   800e40 <fd_lookup>
  800f14:	89 c3                	mov    %eax,%ebx
  800f16:	83 c4 10             	add    $0x10,%esp
  800f19:	85 c0                	test   %eax,%eax
  800f1b:	78 05                	js     800f22 <fd_close+0x34>
	    || fd != fd2)
  800f1d:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f20:	74 16                	je     800f38 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800f22:	89 f8                	mov    %edi,%eax
  800f24:	84 c0                	test   %al,%al
  800f26:	b8 00 00 00 00       	mov    $0x0,%eax
  800f2b:	0f 44 d8             	cmove  %eax,%ebx
}
  800f2e:	89 d8                	mov    %ebx,%eax
  800f30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f33:	5b                   	pop    %ebx
  800f34:	5e                   	pop    %esi
  800f35:	5f                   	pop    %edi
  800f36:	5d                   	pop    %ebp
  800f37:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f38:	83 ec 08             	sub    $0x8,%esp
  800f3b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f3e:	50                   	push   %eax
  800f3f:	ff 36                	pushl  (%esi)
  800f41:	e8 4e ff ff ff       	call   800e94 <dev_lookup>
  800f46:	89 c3                	mov    %eax,%ebx
  800f48:	83 c4 10             	add    $0x10,%esp
  800f4b:	85 c0                	test   %eax,%eax
  800f4d:	78 1a                	js     800f69 <fd_close+0x7b>
		if (dev->dev_close)
  800f4f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f52:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f55:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f5a:	85 c0                	test   %eax,%eax
  800f5c:	74 0b                	je     800f69 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800f5e:	83 ec 0c             	sub    $0xc,%esp
  800f61:	56                   	push   %esi
  800f62:	ff d0                	call   *%eax
  800f64:	89 c3                	mov    %eax,%ebx
  800f66:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f69:	83 ec 08             	sub    $0x8,%esp
  800f6c:	56                   	push   %esi
  800f6d:	6a 00                	push   $0x0
  800f6f:	e8 58 fd ff ff       	call   800ccc <sys_page_unmap>
	return r;
  800f74:	83 c4 10             	add    $0x10,%esp
  800f77:	eb b5                	jmp    800f2e <fd_close+0x40>

00800f79 <close>:

int
close(int fdnum)
{
  800f79:	f3 0f 1e fb          	endbr32 
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800f83:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800f86:	50                   	push   %eax
  800f87:	ff 75 08             	pushl  0x8(%ebp)
  800f8a:	e8 b1 fe ff ff       	call   800e40 <fd_lookup>
  800f8f:	83 c4 10             	add    $0x10,%esp
  800f92:	85 c0                	test   %eax,%eax
  800f94:	79 02                	jns    800f98 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800f96:	c9                   	leave  
  800f97:	c3                   	ret    
		return fd_close(fd, 1);
  800f98:	83 ec 08             	sub    $0x8,%esp
  800f9b:	6a 01                	push   $0x1
  800f9d:	ff 75 f4             	pushl  -0xc(%ebp)
  800fa0:	e8 49 ff ff ff       	call   800eee <fd_close>
  800fa5:	83 c4 10             	add    $0x10,%esp
  800fa8:	eb ec                	jmp    800f96 <close+0x1d>

00800faa <close_all>:

void
close_all(void)
{
  800faa:	f3 0f 1e fb          	endbr32 
  800fae:	55                   	push   %ebp
  800faf:	89 e5                	mov    %esp,%ebp
  800fb1:	53                   	push   %ebx
  800fb2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fb5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fba:	83 ec 0c             	sub    $0xc,%esp
  800fbd:	53                   	push   %ebx
  800fbe:	e8 b6 ff ff ff       	call   800f79 <close>
	for (i = 0; i < MAXFD; i++)
  800fc3:	83 c3 01             	add    $0x1,%ebx
  800fc6:	83 c4 10             	add    $0x10,%esp
  800fc9:	83 fb 20             	cmp    $0x20,%ebx
  800fcc:	75 ec                	jne    800fba <close_all+0x10>
}
  800fce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800fd1:	c9                   	leave  
  800fd2:	c3                   	ret    

00800fd3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800fd3:	f3 0f 1e fb          	endbr32 
  800fd7:	55                   	push   %ebp
  800fd8:	89 e5                	mov    %esp,%ebp
  800fda:	57                   	push   %edi
  800fdb:	56                   	push   %esi
  800fdc:	53                   	push   %ebx
  800fdd:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800fe0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800fe3:	50                   	push   %eax
  800fe4:	ff 75 08             	pushl  0x8(%ebp)
  800fe7:	e8 54 fe ff ff       	call   800e40 <fd_lookup>
  800fec:	89 c3                	mov    %eax,%ebx
  800fee:	83 c4 10             	add    $0x10,%esp
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	0f 88 81 00 00 00    	js     80107a <dup+0xa7>
		return r;
	close(newfdnum);
  800ff9:	83 ec 0c             	sub    $0xc,%esp
  800ffc:	ff 75 0c             	pushl  0xc(%ebp)
  800fff:	e8 75 ff ff ff       	call   800f79 <close>

	newfd = INDEX2FD(newfdnum);
  801004:	8b 75 0c             	mov    0xc(%ebp),%esi
  801007:	c1 e6 0c             	shl    $0xc,%esi
  80100a:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801010:	83 c4 04             	add    $0x4,%esp
  801013:	ff 75 e4             	pushl  -0x1c(%ebp)
  801016:	e8 b0 fd ff ff       	call   800dcb <fd2data>
  80101b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80101d:	89 34 24             	mov    %esi,(%esp)
  801020:	e8 a6 fd ff ff       	call   800dcb <fd2data>
  801025:	83 c4 10             	add    $0x10,%esp
  801028:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80102a:	89 d8                	mov    %ebx,%eax
  80102c:	c1 e8 16             	shr    $0x16,%eax
  80102f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801036:	a8 01                	test   $0x1,%al
  801038:	74 11                	je     80104b <dup+0x78>
  80103a:	89 d8                	mov    %ebx,%eax
  80103c:	c1 e8 0c             	shr    $0xc,%eax
  80103f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801046:	f6 c2 01             	test   $0x1,%dl
  801049:	75 39                	jne    801084 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80104b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80104e:	89 d0                	mov    %edx,%eax
  801050:	c1 e8 0c             	shr    $0xc,%eax
  801053:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80105a:	83 ec 0c             	sub    $0xc,%esp
  80105d:	25 07 0e 00 00       	and    $0xe07,%eax
  801062:	50                   	push   %eax
  801063:	56                   	push   %esi
  801064:	6a 00                	push   $0x0
  801066:	52                   	push   %edx
  801067:	6a 00                	push   $0x0
  801069:	e8 34 fc ff ff       	call   800ca2 <sys_page_map>
  80106e:	89 c3                	mov    %eax,%ebx
  801070:	83 c4 20             	add    $0x20,%esp
  801073:	85 c0                	test   %eax,%eax
  801075:	78 31                	js     8010a8 <dup+0xd5>
		goto err;

	return newfdnum;
  801077:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80107a:	89 d8                	mov    %ebx,%eax
  80107c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80107f:	5b                   	pop    %ebx
  801080:	5e                   	pop    %esi
  801081:	5f                   	pop    %edi
  801082:	5d                   	pop    %ebp
  801083:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801084:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80108b:	83 ec 0c             	sub    $0xc,%esp
  80108e:	25 07 0e 00 00       	and    $0xe07,%eax
  801093:	50                   	push   %eax
  801094:	57                   	push   %edi
  801095:	6a 00                	push   $0x0
  801097:	53                   	push   %ebx
  801098:	6a 00                	push   $0x0
  80109a:	e8 03 fc ff ff       	call   800ca2 <sys_page_map>
  80109f:	89 c3                	mov    %eax,%ebx
  8010a1:	83 c4 20             	add    $0x20,%esp
  8010a4:	85 c0                	test   %eax,%eax
  8010a6:	79 a3                	jns    80104b <dup+0x78>
	sys_page_unmap(0, newfd);
  8010a8:	83 ec 08             	sub    $0x8,%esp
  8010ab:	56                   	push   %esi
  8010ac:	6a 00                	push   $0x0
  8010ae:	e8 19 fc ff ff       	call   800ccc <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010b3:	83 c4 08             	add    $0x8,%esp
  8010b6:	57                   	push   %edi
  8010b7:	6a 00                	push   $0x0
  8010b9:	e8 0e fc ff ff       	call   800ccc <sys_page_unmap>
	return r;
  8010be:	83 c4 10             	add    $0x10,%esp
  8010c1:	eb b7                	jmp    80107a <dup+0xa7>

008010c3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010c3:	f3 0f 1e fb          	endbr32 
  8010c7:	55                   	push   %ebp
  8010c8:	89 e5                	mov    %esp,%ebp
  8010ca:	53                   	push   %ebx
  8010cb:	83 ec 1c             	sub    $0x1c,%esp
  8010ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010d1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010d4:	50                   	push   %eax
  8010d5:	53                   	push   %ebx
  8010d6:	e8 65 fd ff ff       	call   800e40 <fd_lookup>
  8010db:	83 c4 10             	add    $0x10,%esp
  8010de:	85 c0                	test   %eax,%eax
  8010e0:	78 3f                	js     801121 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010e2:	83 ec 08             	sub    $0x8,%esp
  8010e5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010e8:	50                   	push   %eax
  8010e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010ec:	ff 30                	pushl  (%eax)
  8010ee:	e8 a1 fd ff ff       	call   800e94 <dev_lookup>
  8010f3:	83 c4 10             	add    $0x10,%esp
  8010f6:	85 c0                	test   %eax,%eax
  8010f8:	78 27                	js     801121 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8010fa:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8010fd:	8b 42 08             	mov    0x8(%edx),%eax
  801100:	83 e0 03             	and    $0x3,%eax
  801103:	83 f8 01             	cmp    $0x1,%eax
  801106:	74 1e                	je     801126 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801108:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80110b:	8b 40 08             	mov    0x8(%eax),%eax
  80110e:	85 c0                	test   %eax,%eax
  801110:	74 35                	je     801147 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801112:	83 ec 04             	sub    $0x4,%esp
  801115:	ff 75 10             	pushl  0x10(%ebp)
  801118:	ff 75 0c             	pushl  0xc(%ebp)
  80111b:	52                   	push   %edx
  80111c:	ff d0                	call   *%eax
  80111e:	83 c4 10             	add    $0x10,%esp
}
  801121:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801124:	c9                   	leave  
  801125:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801126:	a1 20 60 80 00       	mov    0x806020,%eax
  80112b:	8b 40 48             	mov    0x48(%eax),%eax
  80112e:	83 ec 04             	sub    $0x4,%esp
  801131:	53                   	push   %ebx
  801132:	50                   	push   %eax
  801133:	68 cd 23 80 00       	push   $0x8023cd
  801138:	e8 4b f1 ff ff       	call   800288 <cprintf>
		return -E_INVAL;
  80113d:	83 c4 10             	add    $0x10,%esp
  801140:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801145:	eb da                	jmp    801121 <read+0x5e>
		return -E_NOT_SUPP;
  801147:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80114c:	eb d3                	jmp    801121 <read+0x5e>

0080114e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80114e:	f3 0f 1e fb          	endbr32 
  801152:	55                   	push   %ebp
  801153:	89 e5                	mov    %esp,%ebp
  801155:	57                   	push   %edi
  801156:	56                   	push   %esi
  801157:	53                   	push   %ebx
  801158:	83 ec 0c             	sub    $0xc,%esp
  80115b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80115e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801161:	bb 00 00 00 00       	mov    $0x0,%ebx
  801166:	eb 02                	jmp    80116a <readn+0x1c>
  801168:	01 c3                	add    %eax,%ebx
  80116a:	39 f3                	cmp    %esi,%ebx
  80116c:	73 21                	jae    80118f <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80116e:	83 ec 04             	sub    $0x4,%esp
  801171:	89 f0                	mov    %esi,%eax
  801173:	29 d8                	sub    %ebx,%eax
  801175:	50                   	push   %eax
  801176:	89 d8                	mov    %ebx,%eax
  801178:	03 45 0c             	add    0xc(%ebp),%eax
  80117b:	50                   	push   %eax
  80117c:	57                   	push   %edi
  80117d:	e8 41 ff ff ff       	call   8010c3 <read>
		if (m < 0)
  801182:	83 c4 10             	add    $0x10,%esp
  801185:	85 c0                	test   %eax,%eax
  801187:	78 04                	js     80118d <readn+0x3f>
			return m;
		if (m == 0)
  801189:	75 dd                	jne    801168 <readn+0x1a>
  80118b:	eb 02                	jmp    80118f <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80118d:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80118f:	89 d8                	mov    %ebx,%eax
  801191:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801194:	5b                   	pop    %ebx
  801195:	5e                   	pop    %esi
  801196:	5f                   	pop    %edi
  801197:	5d                   	pop    %ebp
  801198:	c3                   	ret    

00801199 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801199:	f3 0f 1e fb          	endbr32 
  80119d:	55                   	push   %ebp
  80119e:	89 e5                	mov    %esp,%ebp
  8011a0:	53                   	push   %ebx
  8011a1:	83 ec 1c             	sub    $0x1c,%esp
  8011a4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011a7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011aa:	50                   	push   %eax
  8011ab:	53                   	push   %ebx
  8011ac:	e8 8f fc ff ff       	call   800e40 <fd_lookup>
  8011b1:	83 c4 10             	add    $0x10,%esp
  8011b4:	85 c0                	test   %eax,%eax
  8011b6:	78 3a                	js     8011f2 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011b8:	83 ec 08             	sub    $0x8,%esp
  8011bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011be:	50                   	push   %eax
  8011bf:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011c2:	ff 30                	pushl  (%eax)
  8011c4:	e8 cb fc ff ff       	call   800e94 <dev_lookup>
  8011c9:	83 c4 10             	add    $0x10,%esp
  8011cc:	85 c0                	test   %eax,%eax
  8011ce:	78 22                	js     8011f2 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011d0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011d3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011d7:	74 1e                	je     8011f7 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011dc:	8b 52 0c             	mov    0xc(%edx),%edx
  8011df:	85 d2                	test   %edx,%edx
  8011e1:	74 35                	je     801218 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8011e3:	83 ec 04             	sub    $0x4,%esp
  8011e6:	ff 75 10             	pushl  0x10(%ebp)
  8011e9:	ff 75 0c             	pushl  0xc(%ebp)
  8011ec:	50                   	push   %eax
  8011ed:	ff d2                	call   *%edx
  8011ef:	83 c4 10             	add    $0x10,%esp
}
  8011f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011f5:	c9                   	leave  
  8011f6:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8011f7:	a1 20 60 80 00       	mov    0x806020,%eax
  8011fc:	8b 40 48             	mov    0x48(%eax),%eax
  8011ff:	83 ec 04             	sub    $0x4,%esp
  801202:	53                   	push   %ebx
  801203:	50                   	push   %eax
  801204:	68 e9 23 80 00       	push   $0x8023e9
  801209:	e8 7a f0 ff ff       	call   800288 <cprintf>
		return -E_INVAL;
  80120e:	83 c4 10             	add    $0x10,%esp
  801211:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801216:	eb da                	jmp    8011f2 <write+0x59>
		return -E_NOT_SUPP;
  801218:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80121d:	eb d3                	jmp    8011f2 <write+0x59>

0080121f <seek>:

int
seek(int fdnum, off_t offset)
{
  80121f:	f3 0f 1e fb          	endbr32 
  801223:	55                   	push   %ebp
  801224:	89 e5                	mov    %esp,%ebp
  801226:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801229:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80122c:	50                   	push   %eax
  80122d:	ff 75 08             	pushl  0x8(%ebp)
  801230:	e8 0b fc ff ff       	call   800e40 <fd_lookup>
  801235:	83 c4 10             	add    $0x10,%esp
  801238:	85 c0                	test   %eax,%eax
  80123a:	78 0e                	js     80124a <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80123c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80123f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801242:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801245:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80124a:	c9                   	leave  
  80124b:	c3                   	ret    

0080124c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80124c:	f3 0f 1e fb          	endbr32 
  801250:	55                   	push   %ebp
  801251:	89 e5                	mov    %esp,%ebp
  801253:	53                   	push   %ebx
  801254:	83 ec 1c             	sub    $0x1c,%esp
  801257:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80125a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80125d:	50                   	push   %eax
  80125e:	53                   	push   %ebx
  80125f:	e8 dc fb ff ff       	call   800e40 <fd_lookup>
  801264:	83 c4 10             	add    $0x10,%esp
  801267:	85 c0                	test   %eax,%eax
  801269:	78 37                	js     8012a2 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80126b:	83 ec 08             	sub    $0x8,%esp
  80126e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801271:	50                   	push   %eax
  801272:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801275:	ff 30                	pushl  (%eax)
  801277:	e8 18 fc ff ff       	call   800e94 <dev_lookup>
  80127c:	83 c4 10             	add    $0x10,%esp
  80127f:	85 c0                	test   %eax,%eax
  801281:	78 1f                	js     8012a2 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801283:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801286:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80128a:	74 1b                	je     8012a7 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  80128c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80128f:	8b 52 18             	mov    0x18(%edx),%edx
  801292:	85 d2                	test   %edx,%edx
  801294:	74 32                	je     8012c8 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801296:	83 ec 08             	sub    $0x8,%esp
  801299:	ff 75 0c             	pushl  0xc(%ebp)
  80129c:	50                   	push   %eax
  80129d:	ff d2                	call   *%edx
  80129f:	83 c4 10             	add    $0x10,%esp
}
  8012a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012a5:	c9                   	leave  
  8012a6:	c3                   	ret    
			thisenv->env_id, fdnum);
  8012a7:	a1 20 60 80 00       	mov    0x806020,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012ac:	8b 40 48             	mov    0x48(%eax),%eax
  8012af:	83 ec 04             	sub    $0x4,%esp
  8012b2:	53                   	push   %ebx
  8012b3:	50                   	push   %eax
  8012b4:	68 ac 23 80 00       	push   $0x8023ac
  8012b9:	e8 ca ef ff ff       	call   800288 <cprintf>
		return -E_INVAL;
  8012be:	83 c4 10             	add    $0x10,%esp
  8012c1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012c6:	eb da                	jmp    8012a2 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8012c8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012cd:	eb d3                	jmp    8012a2 <ftruncate+0x56>

008012cf <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012cf:	f3 0f 1e fb          	endbr32 
  8012d3:	55                   	push   %ebp
  8012d4:	89 e5                	mov    %esp,%ebp
  8012d6:	53                   	push   %ebx
  8012d7:	83 ec 1c             	sub    $0x1c,%esp
  8012da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012dd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8012e0:	50                   	push   %eax
  8012e1:	ff 75 08             	pushl  0x8(%ebp)
  8012e4:	e8 57 fb ff ff       	call   800e40 <fd_lookup>
  8012e9:	83 c4 10             	add    $0x10,%esp
  8012ec:	85 c0                	test   %eax,%eax
  8012ee:	78 4b                	js     80133b <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8012f0:	83 ec 08             	sub    $0x8,%esp
  8012f3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8012f6:	50                   	push   %eax
  8012f7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012fa:	ff 30                	pushl  (%eax)
  8012fc:	e8 93 fb ff ff       	call   800e94 <dev_lookup>
  801301:	83 c4 10             	add    $0x10,%esp
  801304:	85 c0                	test   %eax,%eax
  801306:	78 33                	js     80133b <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801308:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80130b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80130f:	74 2f                	je     801340 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801311:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801314:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80131b:	00 00 00 
	stat->st_isdir = 0;
  80131e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801325:	00 00 00 
	stat->st_dev = dev;
  801328:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80132e:	83 ec 08             	sub    $0x8,%esp
  801331:	53                   	push   %ebx
  801332:	ff 75 f0             	pushl  -0x10(%ebp)
  801335:	ff 50 14             	call   *0x14(%eax)
  801338:	83 c4 10             	add    $0x10,%esp
}
  80133b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80133e:	c9                   	leave  
  80133f:	c3                   	ret    
		return -E_NOT_SUPP;
  801340:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801345:	eb f4                	jmp    80133b <fstat+0x6c>

00801347 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801347:	f3 0f 1e fb          	endbr32 
  80134b:	55                   	push   %ebp
  80134c:	89 e5                	mov    %esp,%ebp
  80134e:	56                   	push   %esi
  80134f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801350:	83 ec 08             	sub    $0x8,%esp
  801353:	6a 00                	push   $0x0
  801355:	ff 75 08             	pushl  0x8(%ebp)
  801358:	e8 fb 01 00 00       	call   801558 <open>
  80135d:	89 c3                	mov    %eax,%ebx
  80135f:	83 c4 10             	add    $0x10,%esp
  801362:	85 c0                	test   %eax,%eax
  801364:	78 1b                	js     801381 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801366:	83 ec 08             	sub    $0x8,%esp
  801369:	ff 75 0c             	pushl  0xc(%ebp)
  80136c:	50                   	push   %eax
  80136d:	e8 5d ff ff ff       	call   8012cf <fstat>
  801372:	89 c6                	mov    %eax,%esi
	close(fd);
  801374:	89 1c 24             	mov    %ebx,(%esp)
  801377:	e8 fd fb ff ff       	call   800f79 <close>
	return r;
  80137c:	83 c4 10             	add    $0x10,%esp
  80137f:	89 f3                	mov    %esi,%ebx
}
  801381:	89 d8                	mov    %ebx,%eax
  801383:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801386:	5b                   	pop    %ebx
  801387:	5e                   	pop    %esi
  801388:	5d                   	pop    %ebp
  801389:	c3                   	ret    

0080138a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80138a:	55                   	push   %ebp
  80138b:	89 e5                	mov    %esp,%ebp
  80138d:	56                   	push   %esi
  80138e:	53                   	push   %ebx
  80138f:	89 c6                	mov    %eax,%esi
  801391:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801393:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80139a:	74 27                	je     8013c3 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80139c:	6a 07                	push   $0x7
  80139e:	68 00 70 80 00       	push   $0x807000
  8013a3:	56                   	push   %esi
  8013a4:	ff 35 00 40 80 00    	pushl  0x804000
  8013aa:	e8 e3 08 00 00       	call   801c92 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013af:	83 c4 0c             	add    $0xc,%esp
  8013b2:	6a 00                	push   $0x0
  8013b4:	53                   	push   %ebx
  8013b5:	6a 00                	push   $0x0
  8013b7:	e8 68 08 00 00       	call   801c24 <ipc_recv>
}
  8013bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013bf:	5b                   	pop    %ebx
  8013c0:	5e                   	pop    %esi
  8013c1:	5d                   	pop    %ebp
  8013c2:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013c3:	83 ec 0c             	sub    $0xc,%esp
  8013c6:	6a 01                	push   $0x1
  8013c8:	e8 2a 09 00 00       	call   801cf7 <ipc_find_env>
  8013cd:	a3 00 40 80 00       	mov    %eax,0x804000
  8013d2:	83 c4 10             	add    $0x10,%esp
  8013d5:	eb c5                	jmp    80139c <fsipc+0x12>

008013d7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013d7:	f3 0f 1e fb          	endbr32 
  8013db:	55                   	push   %ebp
  8013dc:	89 e5                	mov    %esp,%ebp
  8013de:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8013e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e4:	8b 40 0c             	mov    0xc(%eax),%eax
  8013e7:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  8013ec:	8b 45 0c             	mov    0xc(%ebp),%eax
  8013ef:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8013f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8013f9:	b8 02 00 00 00       	mov    $0x2,%eax
  8013fe:	e8 87 ff ff ff       	call   80138a <fsipc>
}
  801403:	c9                   	leave  
  801404:	c3                   	ret    

00801405 <devfile_flush>:
{
  801405:	f3 0f 1e fb          	endbr32 
  801409:	55                   	push   %ebp
  80140a:	89 e5                	mov    %esp,%ebp
  80140c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80140f:	8b 45 08             	mov    0x8(%ebp),%eax
  801412:	8b 40 0c             	mov    0xc(%eax),%eax
  801415:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  80141a:	ba 00 00 00 00       	mov    $0x0,%edx
  80141f:	b8 06 00 00 00       	mov    $0x6,%eax
  801424:	e8 61 ff ff ff       	call   80138a <fsipc>
}
  801429:	c9                   	leave  
  80142a:	c3                   	ret    

0080142b <devfile_stat>:
{
  80142b:	f3 0f 1e fb          	endbr32 
  80142f:	55                   	push   %ebp
  801430:	89 e5                	mov    %esp,%ebp
  801432:	53                   	push   %ebx
  801433:	83 ec 04             	sub    $0x4,%esp
  801436:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801439:	8b 45 08             	mov    0x8(%ebp),%eax
  80143c:	8b 40 0c             	mov    0xc(%eax),%eax
  80143f:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801444:	ba 00 00 00 00       	mov    $0x0,%edx
  801449:	b8 05 00 00 00       	mov    $0x5,%eax
  80144e:	e8 37 ff ff ff       	call   80138a <fsipc>
  801453:	85 c0                	test   %eax,%eax
  801455:	78 2c                	js     801483 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801457:	83 ec 08             	sub    $0x8,%esp
  80145a:	68 00 70 80 00       	push   $0x807000
  80145f:	53                   	push   %ebx
  801460:	e8 8d f3 ff ff       	call   8007f2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801465:	a1 80 70 80 00       	mov    0x807080,%eax
  80146a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801470:	a1 84 70 80 00       	mov    0x807084,%eax
  801475:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80147b:	83 c4 10             	add    $0x10,%esp
  80147e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801483:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801486:	c9                   	leave  
  801487:	c3                   	ret    

00801488 <devfile_write>:
{
  801488:	f3 0f 1e fb          	endbr32 
  80148c:	55                   	push   %ebp
  80148d:	89 e5                	mov    %esp,%ebp
  80148f:	83 ec 0c             	sub    $0xc,%esp
  801492:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801495:	8b 55 08             	mov    0x8(%ebp),%edx
  801498:	8b 52 0c             	mov    0xc(%edx),%edx
  80149b:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = n;
  8014a1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014a6:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014ab:	0f 47 c2             	cmova  %edx,%eax
  8014ae:	a3 04 70 80 00       	mov    %eax,0x807004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8014b3:	50                   	push   %eax
  8014b4:	ff 75 0c             	pushl  0xc(%ebp)
  8014b7:	68 08 70 80 00       	push   $0x807008
  8014bc:	e8 e9 f4 ff ff       	call   8009aa <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8014c1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014c6:	b8 04 00 00 00       	mov    $0x4,%eax
  8014cb:	e8 ba fe ff ff       	call   80138a <fsipc>
}
  8014d0:	c9                   	leave  
  8014d1:	c3                   	ret    

008014d2 <devfile_read>:
{
  8014d2:	f3 0f 1e fb          	endbr32 
  8014d6:	55                   	push   %ebp
  8014d7:	89 e5                	mov    %esp,%ebp
  8014d9:	56                   	push   %esi
  8014da:	53                   	push   %ebx
  8014db:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014de:	8b 45 08             	mov    0x8(%ebp),%eax
  8014e1:	8b 40 0c             	mov    0xc(%eax),%eax
  8014e4:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  8014e9:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8014ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8014f4:	b8 03 00 00 00       	mov    $0x3,%eax
  8014f9:	e8 8c fe ff ff       	call   80138a <fsipc>
  8014fe:	89 c3                	mov    %eax,%ebx
  801500:	85 c0                	test   %eax,%eax
  801502:	78 1f                	js     801523 <devfile_read+0x51>
	assert(r <= n);
  801504:	39 f0                	cmp    %esi,%eax
  801506:	77 24                	ja     80152c <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801508:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80150d:	7f 33                	jg     801542 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80150f:	83 ec 04             	sub    $0x4,%esp
  801512:	50                   	push   %eax
  801513:	68 00 70 80 00       	push   $0x807000
  801518:	ff 75 0c             	pushl  0xc(%ebp)
  80151b:	e8 8a f4 ff ff       	call   8009aa <memmove>
	return r;
  801520:	83 c4 10             	add    $0x10,%esp
}
  801523:	89 d8                	mov    %ebx,%eax
  801525:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801528:	5b                   	pop    %ebx
  801529:	5e                   	pop    %esi
  80152a:	5d                   	pop    %ebp
  80152b:	c3                   	ret    
	assert(r <= n);
  80152c:	68 18 24 80 00       	push   $0x802418
  801531:	68 1f 24 80 00       	push   $0x80241f
  801536:	6a 7c                	push   $0x7c
  801538:	68 34 24 80 00       	push   $0x802434
  80153d:	e8 5f ec ff ff       	call   8001a1 <_panic>
	assert(r <= PGSIZE);
  801542:	68 3f 24 80 00       	push   $0x80243f
  801547:	68 1f 24 80 00       	push   $0x80241f
  80154c:	6a 7d                	push   $0x7d
  80154e:	68 34 24 80 00       	push   $0x802434
  801553:	e8 49 ec ff ff       	call   8001a1 <_panic>

00801558 <open>:
{
  801558:	f3 0f 1e fb          	endbr32 
  80155c:	55                   	push   %ebp
  80155d:	89 e5                	mov    %esp,%ebp
  80155f:	56                   	push   %esi
  801560:	53                   	push   %ebx
  801561:	83 ec 1c             	sub    $0x1c,%esp
  801564:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801567:	56                   	push   %esi
  801568:	e8 42 f2 ff ff       	call   8007af <strlen>
  80156d:	83 c4 10             	add    $0x10,%esp
  801570:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801575:	7f 6c                	jg     8015e3 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801577:	83 ec 0c             	sub    $0xc,%esp
  80157a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80157d:	50                   	push   %eax
  80157e:	e8 67 f8 ff ff       	call   800dea <fd_alloc>
  801583:	89 c3                	mov    %eax,%ebx
  801585:	83 c4 10             	add    $0x10,%esp
  801588:	85 c0                	test   %eax,%eax
  80158a:	78 3c                	js     8015c8 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  80158c:	83 ec 08             	sub    $0x8,%esp
  80158f:	56                   	push   %esi
  801590:	68 00 70 80 00       	push   $0x807000
  801595:	e8 58 f2 ff ff       	call   8007f2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  80159a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80159d:	a3 00 74 80 00       	mov    %eax,0x807400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015a2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015a5:	b8 01 00 00 00       	mov    $0x1,%eax
  8015aa:	e8 db fd ff ff       	call   80138a <fsipc>
  8015af:	89 c3                	mov    %eax,%ebx
  8015b1:	83 c4 10             	add    $0x10,%esp
  8015b4:	85 c0                	test   %eax,%eax
  8015b6:	78 19                	js     8015d1 <open+0x79>
	return fd2num(fd);
  8015b8:	83 ec 0c             	sub    $0xc,%esp
  8015bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8015be:	e8 f4 f7 ff ff       	call   800db7 <fd2num>
  8015c3:	89 c3                	mov    %eax,%ebx
  8015c5:	83 c4 10             	add    $0x10,%esp
}
  8015c8:	89 d8                	mov    %ebx,%eax
  8015ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015cd:	5b                   	pop    %ebx
  8015ce:	5e                   	pop    %esi
  8015cf:	5d                   	pop    %ebp
  8015d0:	c3                   	ret    
		fd_close(fd, 0);
  8015d1:	83 ec 08             	sub    $0x8,%esp
  8015d4:	6a 00                	push   $0x0
  8015d6:	ff 75 f4             	pushl  -0xc(%ebp)
  8015d9:	e8 10 f9 ff ff       	call   800eee <fd_close>
		return r;
  8015de:	83 c4 10             	add    $0x10,%esp
  8015e1:	eb e5                	jmp    8015c8 <open+0x70>
		return -E_BAD_PATH;
  8015e3:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8015e8:	eb de                	jmp    8015c8 <open+0x70>

008015ea <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8015ea:	f3 0f 1e fb          	endbr32 
  8015ee:	55                   	push   %ebp
  8015ef:	89 e5                	mov    %esp,%ebp
  8015f1:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8015f4:	ba 00 00 00 00       	mov    $0x0,%edx
  8015f9:	b8 08 00 00 00       	mov    $0x8,%eax
  8015fe:	e8 87 fd ff ff       	call   80138a <fsipc>
}
  801603:	c9                   	leave  
  801604:	c3                   	ret    

00801605 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801605:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801609:	7f 01                	jg     80160c <writebuf+0x7>
  80160b:	c3                   	ret    
{
  80160c:	55                   	push   %ebp
  80160d:	89 e5                	mov    %esp,%ebp
  80160f:	53                   	push   %ebx
  801610:	83 ec 08             	sub    $0x8,%esp
  801613:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  801615:	ff 70 04             	pushl  0x4(%eax)
  801618:	8d 40 10             	lea    0x10(%eax),%eax
  80161b:	50                   	push   %eax
  80161c:	ff 33                	pushl  (%ebx)
  80161e:	e8 76 fb ff ff       	call   801199 <write>
		if (result > 0)
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	85 c0                	test   %eax,%eax
  801628:	7e 03                	jle    80162d <writebuf+0x28>
			b->result += result;
  80162a:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80162d:	39 43 04             	cmp    %eax,0x4(%ebx)
  801630:	74 0d                	je     80163f <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  801632:	85 c0                	test   %eax,%eax
  801634:	ba 00 00 00 00       	mov    $0x0,%edx
  801639:	0f 4f c2             	cmovg  %edx,%eax
  80163c:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80163f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801642:	c9                   	leave  
  801643:	c3                   	ret    

00801644 <putch>:

static void
putch(int ch, void *thunk)
{
  801644:	f3 0f 1e fb          	endbr32 
  801648:	55                   	push   %ebp
  801649:	89 e5                	mov    %esp,%ebp
  80164b:	53                   	push   %ebx
  80164c:	83 ec 04             	sub    $0x4,%esp
  80164f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  801652:	8b 53 04             	mov    0x4(%ebx),%edx
  801655:	8d 42 01             	lea    0x1(%edx),%eax
  801658:	89 43 04             	mov    %eax,0x4(%ebx)
  80165b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80165e:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  801662:	3d 00 01 00 00       	cmp    $0x100,%eax
  801667:	74 06                	je     80166f <putch+0x2b>
		writebuf(b);
		b->idx = 0;
	}
}
  801669:	83 c4 04             	add    $0x4,%esp
  80166c:	5b                   	pop    %ebx
  80166d:	5d                   	pop    %ebp
  80166e:	c3                   	ret    
		writebuf(b);
  80166f:	89 d8                	mov    %ebx,%eax
  801671:	e8 8f ff ff ff       	call   801605 <writebuf>
		b->idx = 0;
  801676:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  80167d:	eb ea                	jmp    801669 <putch+0x25>

0080167f <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  80167f:	f3 0f 1e fb          	endbr32 
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  80168c:	8b 45 08             	mov    0x8(%ebp),%eax
  80168f:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  801695:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  80169c:	00 00 00 
	b.result = 0;
  80169f:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8016a6:	00 00 00 
	b.error = 1;
  8016a9:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8016b0:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8016b3:	ff 75 10             	pushl  0x10(%ebp)
  8016b6:	ff 75 0c             	pushl  0xc(%ebp)
  8016b9:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8016bf:	50                   	push   %eax
  8016c0:	68 44 16 80 00       	push   $0x801644
  8016c5:	e8 21 ed ff ff       	call   8003eb <vprintfmt>
	if (b.idx > 0)
  8016ca:	83 c4 10             	add    $0x10,%esp
  8016cd:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  8016d4:	7f 11                	jg     8016e7 <vfprintf+0x68>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  8016d6:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  8016dc:	85 c0                	test   %eax,%eax
  8016de:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  8016e5:	c9                   	leave  
  8016e6:	c3                   	ret    
		writebuf(&b);
  8016e7:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8016ed:	e8 13 ff ff ff       	call   801605 <writebuf>
  8016f2:	eb e2                	jmp    8016d6 <vfprintf+0x57>

008016f4 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  8016f4:	f3 0f 1e fb          	endbr32 
  8016f8:	55                   	push   %ebp
  8016f9:	89 e5                	mov    %esp,%ebp
  8016fb:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8016fe:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  801701:	50                   	push   %eax
  801702:	ff 75 0c             	pushl  0xc(%ebp)
  801705:	ff 75 08             	pushl  0x8(%ebp)
  801708:	e8 72 ff ff ff       	call   80167f <vfprintf>
	va_end(ap);

	return cnt;
}
  80170d:	c9                   	leave  
  80170e:	c3                   	ret    

0080170f <printf>:

int
printf(const char *fmt, ...)
{
  80170f:	f3 0f 1e fb          	endbr32 
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801719:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  80171c:	50                   	push   %eax
  80171d:	ff 75 08             	pushl  0x8(%ebp)
  801720:	6a 01                	push   $0x1
  801722:	e8 58 ff ff ff       	call   80167f <vfprintf>
	va_end(ap);

	return cnt;
}
  801727:	c9                   	leave  
  801728:	c3                   	ret    

00801729 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801729:	f3 0f 1e fb          	endbr32 
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	56                   	push   %esi
  801731:	53                   	push   %ebx
  801732:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801735:	83 ec 0c             	sub    $0xc,%esp
  801738:	ff 75 08             	pushl  0x8(%ebp)
  80173b:	e8 8b f6 ff ff       	call   800dcb <fd2data>
  801740:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801742:	83 c4 08             	add    $0x8,%esp
  801745:	68 4b 24 80 00       	push   $0x80244b
  80174a:	53                   	push   %ebx
  80174b:	e8 a2 f0 ff ff       	call   8007f2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801750:	8b 46 04             	mov    0x4(%esi),%eax
  801753:	2b 06                	sub    (%esi),%eax
  801755:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80175b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801762:	00 00 00 
	stat->st_dev = &devpipe;
  801765:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80176c:	30 80 00 
	return 0;
}
  80176f:	b8 00 00 00 00       	mov    $0x0,%eax
  801774:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801777:	5b                   	pop    %ebx
  801778:	5e                   	pop    %esi
  801779:	5d                   	pop    %ebp
  80177a:	c3                   	ret    

0080177b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80177b:	f3 0f 1e fb          	endbr32 
  80177f:	55                   	push   %ebp
  801780:	89 e5                	mov    %esp,%ebp
  801782:	53                   	push   %ebx
  801783:	83 ec 0c             	sub    $0xc,%esp
  801786:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801789:	53                   	push   %ebx
  80178a:	6a 00                	push   $0x0
  80178c:	e8 3b f5 ff ff       	call   800ccc <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801791:	89 1c 24             	mov    %ebx,(%esp)
  801794:	e8 32 f6 ff ff       	call   800dcb <fd2data>
  801799:	83 c4 08             	add    $0x8,%esp
  80179c:	50                   	push   %eax
  80179d:	6a 00                	push   $0x0
  80179f:	e8 28 f5 ff ff       	call   800ccc <sys_page_unmap>
}
  8017a4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017a7:	c9                   	leave  
  8017a8:	c3                   	ret    

008017a9 <_pipeisclosed>:
{
  8017a9:	55                   	push   %ebp
  8017aa:	89 e5                	mov    %esp,%ebp
  8017ac:	57                   	push   %edi
  8017ad:	56                   	push   %esi
  8017ae:	53                   	push   %ebx
  8017af:	83 ec 1c             	sub    $0x1c,%esp
  8017b2:	89 c7                	mov    %eax,%edi
  8017b4:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8017b6:	a1 20 60 80 00       	mov    0x806020,%eax
  8017bb:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8017be:	83 ec 0c             	sub    $0xc,%esp
  8017c1:	57                   	push   %edi
  8017c2:	e8 6d 05 00 00       	call   801d34 <pageref>
  8017c7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8017ca:	89 34 24             	mov    %esi,(%esp)
  8017cd:	e8 62 05 00 00       	call   801d34 <pageref>
		nn = thisenv->env_runs;
  8017d2:	8b 15 20 60 80 00    	mov    0x806020,%edx
  8017d8:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8017db:	83 c4 10             	add    $0x10,%esp
  8017de:	39 cb                	cmp    %ecx,%ebx
  8017e0:	74 1b                	je     8017fd <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8017e2:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8017e5:	75 cf                	jne    8017b6 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8017e7:	8b 42 58             	mov    0x58(%edx),%eax
  8017ea:	6a 01                	push   $0x1
  8017ec:	50                   	push   %eax
  8017ed:	53                   	push   %ebx
  8017ee:	68 52 24 80 00       	push   $0x802452
  8017f3:	e8 90 ea ff ff       	call   800288 <cprintf>
  8017f8:	83 c4 10             	add    $0x10,%esp
  8017fb:	eb b9                	jmp    8017b6 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8017fd:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801800:	0f 94 c0             	sete   %al
  801803:	0f b6 c0             	movzbl %al,%eax
}
  801806:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801809:	5b                   	pop    %ebx
  80180a:	5e                   	pop    %esi
  80180b:	5f                   	pop    %edi
  80180c:	5d                   	pop    %ebp
  80180d:	c3                   	ret    

0080180e <devpipe_write>:
{
  80180e:	f3 0f 1e fb          	endbr32 
  801812:	55                   	push   %ebp
  801813:	89 e5                	mov    %esp,%ebp
  801815:	57                   	push   %edi
  801816:	56                   	push   %esi
  801817:	53                   	push   %ebx
  801818:	83 ec 28             	sub    $0x28,%esp
  80181b:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80181e:	56                   	push   %esi
  80181f:	e8 a7 f5 ff ff       	call   800dcb <fd2data>
  801824:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801826:	83 c4 10             	add    $0x10,%esp
  801829:	bf 00 00 00 00       	mov    $0x0,%edi
  80182e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801831:	74 4f                	je     801882 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801833:	8b 43 04             	mov    0x4(%ebx),%eax
  801836:	8b 0b                	mov    (%ebx),%ecx
  801838:	8d 51 20             	lea    0x20(%ecx),%edx
  80183b:	39 d0                	cmp    %edx,%eax
  80183d:	72 14                	jb     801853 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  80183f:	89 da                	mov    %ebx,%edx
  801841:	89 f0                	mov    %esi,%eax
  801843:	e8 61 ff ff ff       	call   8017a9 <_pipeisclosed>
  801848:	85 c0                	test   %eax,%eax
  80184a:	75 3b                	jne    801887 <devpipe_write+0x79>
			sys_yield();
  80184c:	e8 fe f3 ff ff       	call   800c4f <sys_yield>
  801851:	eb e0                	jmp    801833 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801853:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801856:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80185a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80185d:	89 c2                	mov    %eax,%edx
  80185f:	c1 fa 1f             	sar    $0x1f,%edx
  801862:	89 d1                	mov    %edx,%ecx
  801864:	c1 e9 1b             	shr    $0x1b,%ecx
  801867:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80186a:	83 e2 1f             	and    $0x1f,%edx
  80186d:	29 ca                	sub    %ecx,%edx
  80186f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801873:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801877:	83 c0 01             	add    $0x1,%eax
  80187a:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80187d:	83 c7 01             	add    $0x1,%edi
  801880:	eb ac                	jmp    80182e <devpipe_write+0x20>
	return i;
  801882:	8b 45 10             	mov    0x10(%ebp),%eax
  801885:	eb 05                	jmp    80188c <devpipe_write+0x7e>
				return 0;
  801887:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80188c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80188f:	5b                   	pop    %ebx
  801890:	5e                   	pop    %esi
  801891:	5f                   	pop    %edi
  801892:	5d                   	pop    %ebp
  801893:	c3                   	ret    

00801894 <devpipe_read>:
{
  801894:	f3 0f 1e fb          	endbr32 
  801898:	55                   	push   %ebp
  801899:	89 e5                	mov    %esp,%ebp
  80189b:	57                   	push   %edi
  80189c:	56                   	push   %esi
  80189d:	53                   	push   %ebx
  80189e:	83 ec 18             	sub    $0x18,%esp
  8018a1:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8018a4:	57                   	push   %edi
  8018a5:	e8 21 f5 ff ff       	call   800dcb <fd2data>
  8018aa:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8018ac:	83 c4 10             	add    $0x10,%esp
  8018af:	be 00 00 00 00       	mov    $0x0,%esi
  8018b4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018b7:	75 14                	jne    8018cd <devpipe_read+0x39>
	return i;
  8018b9:	8b 45 10             	mov    0x10(%ebp),%eax
  8018bc:	eb 02                	jmp    8018c0 <devpipe_read+0x2c>
				return i;
  8018be:	89 f0                	mov    %esi,%eax
}
  8018c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018c3:	5b                   	pop    %ebx
  8018c4:	5e                   	pop    %esi
  8018c5:	5f                   	pop    %edi
  8018c6:	5d                   	pop    %ebp
  8018c7:	c3                   	ret    
			sys_yield();
  8018c8:	e8 82 f3 ff ff       	call   800c4f <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8018cd:	8b 03                	mov    (%ebx),%eax
  8018cf:	3b 43 04             	cmp    0x4(%ebx),%eax
  8018d2:	75 18                	jne    8018ec <devpipe_read+0x58>
			if (i > 0)
  8018d4:	85 f6                	test   %esi,%esi
  8018d6:	75 e6                	jne    8018be <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8018d8:	89 da                	mov    %ebx,%edx
  8018da:	89 f8                	mov    %edi,%eax
  8018dc:	e8 c8 fe ff ff       	call   8017a9 <_pipeisclosed>
  8018e1:	85 c0                	test   %eax,%eax
  8018e3:	74 e3                	je     8018c8 <devpipe_read+0x34>
				return 0;
  8018e5:	b8 00 00 00 00       	mov    $0x0,%eax
  8018ea:	eb d4                	jmp    8018c0 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8018ec:	99                   	cltd   
  8018ed:	c1 ea 1b             	shr    $0x1b,%edx
  8018f0:	01 d0                	add    %edx,%eax
  8018f2:	83 e0 1f             	and    $0x1f,%eax
  8018f5:	29 d0                	sub    %edx,%eax
  8018f7:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8018fc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8018ff:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801902:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801905:	83 c6 01             	add    $0x1,%esi
  801908:	eb aa                	jmp    8018b4 <devpipe_read+0x20>

0080190a <pipe>:
{
  80190a:	f3 0f 1e fb          	endbr32 
  80190e:	55                   	push   %ebp
  80190f:	89 e5                	mov    %esp,%ebp
  801911:	56                   	push   %esi
  801912:	53                   	push   %ebx
  801913:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801916:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801919:	50                   	push   %eax
  80191a:	e8 cb f4 ff ff       	call   800dea <fd_alloc>
  80191f:	89 c3                	mov    %eax,%ebx
  801921:	83 c4 10             	add    $0x10,%esp
  801924:	85 c0                	test   %eax,%eax
  801926:	0f 88 23 01 00 00    	js     801a4f <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80192c:	83 ec 04             	sub    $0x4,%esp
  80192f:	68 07 04 00 00       	push   $0x407
  801934:	ff 75 f4             	pushl  -0xc(%ebp)
  801937:	6a 00                	push   $0x0
  801939:	e8 3c f3 ff ff       	call   800c7a <sys_page_alloc>
  80193e:	89 c3                	mov    %eax,%ebx
  801940:	83 c4 10             	add    $0x10,%esp
  801943:	85 c0                	test   %eax,%eax
  801945:	0f 88 04 01 00 00    	js     801a4f <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  80194b:	83 ec 0c             	sub    $0xc,%esp
  80194e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801951:	50                   	push   %eax
  801952:	e8 93 f4 ff ff       	call   800dea <fd_alloc>
  801957:	89 c3                	mov    %eax,%ebx
  801959:	83 c4 10             	add    $0x10,%esp
  80195c:	85 c0                	test   %eax,%eax
  80195e:	0f 88 db 00 00 00    	js     801a3f <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801964:	83 ec 04             	sub    $0x4,%esp
  801967:	68 07 04 00 00       	push   $0x407
  80196c:	ff 75 f0             	pushl  -0x10(%ebp)
  80196f:	6a 00                	push   $0x0
  801971:	e8 04 f3 ff ff       	call   800c7a <sys_page_alloc>
  801976:	89 c3                	mov    %eax,%ebx
  801978:	83 c4 10             	add    $0x10,%esp
  80197b:	85 c0                	test   %eax,%eax
  80197d:	0f 88 bc 00 00 00    	js     801a3f <pipe+0x135>
	va = fd2data(fd0);
  801983:	83 ec 0c             	sub    $0xc,%esp
  801986:	ff 75 f4             	pushl  -0xc(%ebp)
  801989:	e8 3d f4 ff ff       	call   800dcb <fd2data>
  80198e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801990:	83 c4 0c             	add    $0xc,%esp
  801993:	68 07 04 00 00       	push   $0x407
  801998:	50                   	push   %eax
  801999:	6a 00                	push   $0x0
  80199b:	e8 da f2 ff ff       	call   800c7a <sys_page_alloc>
  8019a0:	89 c3                	mov    %eax,%ebx
  8019a2:	83 c4 10             	add    $0x10,%esp
  8019a5:	85 c0                	test   %eax,%eax
  8019a7:	0f 88 82 00 00 00    	js     801a2f <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8019ad:	83 ec 0c             	sub    $0xc,%esp
  8019b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8019b3:	e8 13 f4 ff ff       	call   800dcb <fd2data>
  8019b8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8019bf:	50                   	push   %eax
  8019c0:	6a 00                	push   $0x0
  8019c2:	56                   	push   %esi
  8019c3:	6a 00                	push   $0x0
  8019c5:	e8 d8 f2 ff ff       	call   800ca2 <sys_page_map>
  8019ca:	89 c3                	mov    %eax,%ebx
  8019cc:	83 c4 20             	add    $0x20,%esp
  8019cf:	85 c0                	test   %eax,%eax
  8019d1:	78 4e                	js     801a21 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8019d3:	a1 20 30 80 00       	mov    0x803020,%eax
  8019d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019db:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8019dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8019e0:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8019e7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019ea:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8019ec:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ef:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8019f6:	83 ec 0c             	sub    $0xc,%esp
  8019f9:	ff 75 f4             	pushl  -0xc(%ebp)
  8019fc:	e8 b6 f3 ff ff       	call   800db7 <fd2num>
  801a01:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a04:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801a06:	83 c4 04             	add    $0x4,%esp
  801a09:	ff 75 f0             	pushl  -0x10(%ebp)
  801a0c:	e8 a6 f3 ff ff       	call   800db7 <fd2num>
  801a11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801a14:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801a17:	83 c4 10             	add    $0x10,%esp
  801a1a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a1f:	eb 2e                	jmp    801a4f <pipe+0x145>
	sys_page_unmap(0, va);
  801a21:	83 ec 08             	sub    $0x8,%esp
  801a24:	56                   	push   %esi
  801a25:	6a 00                	push   $0x0
  801a27:	e8 a0 f2 ff ff       	call   800ccc <sys_page_unmap>
  801a2c:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801a2f:	83 ec 08             	sub    $0x8,%esp
  801a32:	ff 75 f0             	pushl  -0x10(%ebp)
  801a35:	6a 00                	push   $0x0
  801a37:	e8 90 f2 ff ff       	call   800ccc <sys_page_unmap>
  801a3c:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801a3f:	83 ec 08             	sub    $0x8,%esp
  801a42:	ff 75 f4             	pushl  -0xc(%ebp)
  801a45:	6a 00                	push   $0x0
  801a47:	e8 80 f2 ff ff       	call   800ccc <sys_page_unmap>
  801a4c:	83 c4 10             	add    $0x10,%esp
}
  801a4f:	89 d8                	mov    %ebx,%eax
  801a51:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a54:	5b                   	pop    %ebx
  801a55:	5e                   	pop    %esi
  801a56:	5d                   	pop    %ebp
  801a57:	c3                   	ret    

00801a58 <pipeisclosed>:
{
  801a58:	f3 0f 1e fb          	endbr32 
  801a5c:	55                   	push   %ebp
  801a5d:	89 e5                	mov    %esp,%ebp
  801a5f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801a62:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a65:	50                   	push   %eax
  801a66:	ff 75 08             	pushl  0x8(%ebp)
  801a69:	e8 d2 f3 ff ff       	call   800e40 <fd_lookup>
  801a6e:	83 c4 10             	add    $0x10,%esp
  801a71:	85 c0                	test   %eax,%eax
  801a73:	78 18                	js     801a8d <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801a75:	83 ec 0c             	sub    $0xc,%esp
  801a78:	ff 75 f4             	pushl  -0xc(%ebp)
  801a7b:	e8 4b f3 ff ff       	call   800dcb <fd2data>
  801a80:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801a82:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801a85:	e8 1f fd ff ff       	call   8017a9 <_pipeisclosed>
  801a8a:	83 c4 10             	add    $0x10,%esp
}
  801a8d:	c9                   	leave  
  801a8e:	c3                   	ret    

00801a8f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801a8f:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801a93:	b8 00 00 00 00       	mov    $0x0,%eax
  801a98:	c3                   	ret    

00801a99 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801a99:	f3 0f 1e fb          	endbr32 
  801a9d:	55                   	push   %ebp
  801a9e:	89 e5                	mov    %esp,%ebp
  801aa0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801aa3:	68 6a 24 80 00       	push   $0x80246a
  801aa8:	ff 75 0c             	pushl  0xc(%ebp)
  801aab:	e8 42 ed ff ff       	call   8007f2 <strcpy>
	return 0;
}
  801ab0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ab5:	c9                   	leave  
  801ab6:	c3                   	ret    

00801ab7 <devcons_write>:
{
  801ab7:	f3 0f 1e fb          	endbr32 
  801abb:	55                   	push   %ebp
  801abc:	89 e5                	mov    %esp,%ebp
  801abe:	57                   	push   %edi
  801abf:	56                   	push   %esi
  801ac0:	53                   	push   %ebx
  801ac1:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801ac7:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801acc:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801ad2:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ad5:	73 31                	jae    801b08 <devcons_write+0x51>
		m = n - tot;
  801ad7:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ada:	29 f3                	sub    %esi,%ebx
  801adc:	83 fb 7f             	cmp    $0x7f,%ebx
  801adf:	b8 7f 00 00 00       	mov    $0x7f,%eax
  801ae4:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  801ae7:	83 ec 04             	sub    $0x4,%esp
  801aea:	53                   	push   %ebx
  801aeb:	89 f0                	mov    %esi,%eax
  801aed:	03 45 0c             	add    0xc(%ebp),%eax
  801af0:	50                   	push   %eax
  801af1:	57                   	push   %edi
  801af2:	e8 b3 ee ff ff       	call   8009aa <memmove>
		sys_cputs(buf, m);
  801af7:	83 c4 08             	add    $0x8,%esp
  801afa:	53                   	push   %ebx
  801afb:	57                   	push   %edi
  801afc:	e8 ae f0 ff ff       	call   800baf <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  801b01:	01 de                	add    %ebx,%esi
  801b03:	83 c4 10             	add    $0x10,%esp
  801b06:	eb ca                	jmp    801ad2 <devcons_write+0x1b>
}
  801b08:	89 f0                	mov    %esi,%eax
  801b0a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b0d:	5b                   	pop    %ebx
  801b0e:	5e                   	pop    %esi
  801b0f:	5f                   	pop    %edi
  801b10:	5d                   	pop    %ebp
  801b11:	c3                   	ret    

00801b12 <devcons_read>:
{
  801b12:	f3 0f 1e fb          	endbr32 
  801b16:	55                   	push   %ebp
  801b17:	89 e5                	mov    %esp,%ebp
  801b19:	83 ec 08             	sub    $0x8,%esp
  801b1c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801b21:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801b25:	74 21                	je     801b48 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801b27:	e8 ad f0 ff ff       	call   800bd9 <sys_cgetc>
  801b2c:	85 c0                	test   %eax,%eax
  801b2e:	75 07                	jne    801b37 <devcons_read+0x25>
		sys_yield();
  801b30:	e8 1a f1 ff ff       	call   800c4f <sys_yield>
  801b35:	eb f0                	jmp    801b27 <devcons_read+0x15>
	if (c < 0)
  801b37:	78 0f                	js     801b48 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801b39:	83 f8 04             	cmp    $0x4,%eax
  801b3c:	74 0c                	je     801b4a <devcons_read+0x38>
	*(char*)vbuf = c;
  801b3e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b41:	88 02                	mov    %al,(%edx)
	return 1;
  801b43:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801b48:	c9                   	leave  
  801b49:	c3                   	ret    
		return 0;
  801b4a:	b8 00 00 00 00       	mov    $0x0,%eax
  801b4f:	eb f7                	jmp    801b48 <devcons_read+0x36>

00801b51 <cputchar>:
{
  801b51:	f3 0f 1e fb          	endbr32 
  801b55:	55                   	push   %ebp
  801b56:	89 e5                	mov    %esp,%ebp
  801b58:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  801b5e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801b61:	6a 01                	push   $0x1
  801b63:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b66:	50                   	push   %eax
  801b67:	e8 43 f0 ff ff       	call   800baf <sys_cputs>
}
  801b6c:	83 c4 10             	add    $0x10,%esp
  801b6f:	c9                   	leave  
  801b70:	c3                   	ret    

00801b71 <getchar>:
{
  801b71:	f3 0f 1e fb          	endbr32 
  801b75:	55                   	push   %ebp
  801b76:	89 e5                	mov    %esp,%ebp
  801b78:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801b7b:	6a 01                	push   $0x1
  801b7d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801b80:	50                   	push   %eax
  801b81:	6a 00                	push   $0x0
  801b83:	e8 3b f5 ff ff       	call   8010c3 <read>
	if (r < 0)
  801b88:	83 c4 10             	add    $0x10,%esp
  801b8b:	85 c0                	test   %eax,%eax
  801b8d:	78 06                	js     801b95 <getchar+0x24>
	if (r < 1)
  801b8f:	74 06                	je     801b97 <getchar+0x26>
	return c;
  801b91:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801b95:	c9                   	leave  
  801b96:	c3                   	ret    
		return -E_EOF;
  801b97:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801b9c:	eb f7                	jmp    801b95 <getchar+0x24>

00801b9e <iscons>:
{
  801b9e:	f3 0f 1e fb          	endbr32 
  801ba2:	55                   	push   %ebp
  801ba3:	89 e5                	mov    %esp,%ebp
  801ba5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ba8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bab:	50                   	push   %eax
  801bac:	ff 75 08             	pushl  0x8(%ebp)
  801baf:	e8 8c f2 ff ff       	call   800e40 <fd_lookup>
  801bb4:	83 c4 10             	add    $0x10,%esp
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	78 11                	js     801bcc <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801bbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bbe:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801bc4:	39 10                	cmp    %edx,(%eax)
  801bc6:	0f 94 c0             	sete   %al
  801bc9:	0f b6 c0             	movzbl %al,%eax
}
  801bcc:	c9                   	leave  
  801bcd:	c3                   	ret    

00801bce <opencons>:
{
  801bce:	f3 0f 1e fb          	endbr32 
  801bd2:	55                   	push   %ebp
  801bd3:	89 e5                	mov    %esp,%ebp
  801bd5:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801bd8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bdb:	50                   	push   %eax
  801bdc:	e8 09 f2 ff ff       	call   800dea <fd_alloc>
  801be1:	83 c4 10             	add    $0x10,%esp
  801be4:	85 c0                	test   %eax,%eax
  801be6:	78 3a                	js     801c22 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801be8:	83 ec 04             	sub    $0x4,%esp
  801beb:	68 07 04 00 00       	push   $0x407
  801bf0:	ff 75 f4             	pushl  -0xc(%ebp)
  801bf3:	6a 00                	push   $0x0
  801bf5:	e8 80 f0 ff ff       	call   800c7a <sys_page_alloc>
  801bfa:	83 c4 10             	add    $0x10,%esp
  801bfd:	85 c0                	test   %eax,%eax
  801bff:	78 21                	js     801c22 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801c01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c04:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801c0a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801c0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801c0f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801c16:	83 ec 0c             	sub    $0xc,%esp
  801c19:	50                   	push   %eax
  801c1a:	e8 98 f1 ff ff       	call   800db7 <fd2num>
  801c1f:	83 c4 10             	add    $0x10,%esp
}
  801c22:	c9                   	leave  
  801c23:	c3                   	ret    

00801c24 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801c24:	f3 0f 1e fb          	endbr32 
  801c28:	55                   	push   %ebp
  801c29:	89 e5                	mov    %esp,%ebp
  801c2b:	56                   	push   %esi
  801c2c:	53                   	push   %ebx
  801c2d:	8b 75 08             	mov    0x8(%ebp),%esi
  801c30:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c33:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  801c36:	85 c0                	test   %eax,%eax
  801c38:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801c3d:	0f 44 c2             	cmove  %edx,%eax
  801c40:	83 ec 0c             	sub    $0xc,%esp
  801c43:	50                   	push   %eax
  801c44:	e8 48 f1 ff ff       	call   800d91 <sys_ipc_recv>

	if (from_env_store != NULL)
  801c49:	83 c4 10             	add    $0x10,%esp
  801c4c:	85 f6                	test   %esi,%esi
  801c4e:	74 15                	je     801c65 <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  801c50:	ba 00 00 00 00       	mov    $0x0,%edx
  801c55:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801c58:	74 09                	je     801c63 <ipc_recv+0x3f>
  801c5a:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801c60:	8b 52 74             	mov    0x74(%edx),%edx
  801c63:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  801c65:	85 db                	test   %ebx,%ebx
  801c67:	74 15                	je     801c7e <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  801c69:	ba 00 00 00 00       	mov    $0x0,%edx
  801c6e:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801c71:	74 09                	je     801c7c <ipc_recv+0x58>
  801c73:	8b 15 20 60 80 00    	mov    0x806020,%edx
  801c79:	8b 52 78             	mov    0x78(%edx),%edx
  801c7c:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  801c7e:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801c81:	74 08                	je     801c8b <ipc_recv+0x67>
  801c83:	a1 20 60 80 00       	mov    0x806020,%eax
  801c88:	8b 40 70             	mov    0x70(%eax),%eax
}
  801c8b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c8e:	5b                   	pop    %ebx
  801c8f:	5e                   	pop    %esi
  801c90:	5d                   	pop    %ebp
  801c91:	c3                   	ret    

00801c92 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801c92:	f3 0f 1e fb          	endbr32 
  801c96:	55                   	push   %ebp
  801c97:	89 e5                	mov    %esp,%ebp
  801c99:	57                   	push   %edi
  801c9a:	56                   	push   %esi
  801c9b:	53                   	push   %ebx
  801c9c:	83 ec 0c             	sub    $0xc,%esp
  801c9f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ca2:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ca5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ca8:	eb 1f                	jmp    801cc9 <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  801caa:	6a 00                	push   $0x0
  801cac:	68 00 00 c0 ee       	push   $0xeec00000
  801cb1:	56                   	push   %esi
  801cb2:	57                   	push   %edi
  801cb3:	e8 b0 f0 ff ff       	call   800d68 <sys_ipc_try_send>
  801cb8:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  801cbb:	85 c0                	test   %eax,%eax
  801cbd:	74 30                	je     801cef <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  801cbf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801cc2:	75 19                	jne    801cdd <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  801cc4:	e8 86 ef ff ff       	call   800c4f <sys_yield>
		if (pg != NULL) {
  801cc9:	85 db                	test   %ebx,%ebx
  801ccb:	74 dd                	je     801caa <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  801ccd:	ff 75 14             	pushl  0x14(%ebp)
  801cd0:	53                   	push   %ebx
  801cd1:	56                   	push   %esi
  801cd2:	57                   	push   %edi
  801cd3:	e8 90 f0 ff ff       	call   800d68 <sys_ipc_try_send>
  801cd8:	83 c4 10             	add    $0x10,%esp
  801cdb:	eb de                	jmp    801cbb <ipc_send+0x29>
			panic("ipc_send: %d", res);
  801cdd:	50                   	push   %eax
  801cde:	68 76 24 80 00       	push   $0x802476
  801ce3:	6a 3e                	push   $0x3e
  801ce5:	68 83 24 80 00       	push   $0x802483
  801cea:	e8 b2 e4 ff ff       	call   8001a1 <_panic>
	}
}
  801cef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801cf2:	5b                   	pop    %ebx
  801cf3:	5e                   	pop    %esi
  801cf4:	5f                   	pop    %edi
  801cf5:	5d                   	pop    %ebp
  801cf6:	c3                   	ret    

00801cf7 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801cf7:	f3 0f 1e fb          	endbr32 
  801cfb:	55                   	push   %ebp
  801cfc:	89 e5                	mov    %esp,%ebp
  801cfe:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801d01:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801d06:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801d09:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801d0f:	8b 52 50             	mov    0x50(%edx),%edx
  801d12:	39 ca                	cmp    %ecx,%edx
  801d14:	74 11                	je     801d27 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801d16:	83 c0 01             	add    $0x1,%eax
  801d19:	3d 00 04 00 00       	cmp    $0x400,%eax
  801d1e:	75 e6                	jne    801d06 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801d20:	b8 00 00 00 00       	mov    $0x0,%eax
  801d25:	eb 0b                	jmp    801d32 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801d27:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801d2a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801d2f:	8b 40 48             	mov    0x48(%eax),%eax
}
  801d32:	5d                   	pop    %ebp
  801d33:	c3                   	ret    

00801d34 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801d34:	f3 0f 1e fb          	endbr32 
  801d38:	55                   	push   %ebp
  801d39:	89 e5                	mov    %esp,%ebp
  801d3b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801d3e:	89 c2                	mov    %eax,%edx
  801d40:	c1 ea 16             	shr    $0x16,%edx
  801d43:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801d4a:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801d4f:	f6 c1 01             	test   $0x1,%cl
  801d52:	74 1c                	je     801d70 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801d54:	c1 e8 0c             	shr    $0xc,%eax
  801d57:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801d5e:	a8 01                	test   $0x1,%al
  801d60:	74 0e                	je     801d70 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801d62:	c1 e8 0c             	shr    $0xc,%eax
  801d65:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801d6c:	ef 
  801d6d:	0f b7 d2             	movzwl %dx,%edx
}
  801d70:	89 d0                	mov    %edx,%eax
  801d72:	5d                   	pop    %ebp
  801d73:	c3                   	ret    
  801d74:	66 90                	xchg   %ax,%ax
  801d76:	66 90                	xchg   %ax,%ax
  801d78:	66 90                	xchg   %ax,%ax
  801d7a:	66 90                	xchg   %ax,%ax
  801d7c:	66 90                	xchg   %ax,%ax
  801d7e:	66 90                	xchg   %ax,%ax

00801d80 <__udivdi3>:
  801d80:	f3 0f 1e fb          	endbr32 
  801d84:	55                   	push   %ebp
  801d85:	57                   	push   %edi
  801d86:	56                   	push   %esi
  801d87:	53                   	push   %ebx
  801d88:	83 ec 1c             	sub    $0x1c,%esp
  801d8b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801d8f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801d93:	8b 74 24 34          	mov    0x34(%esp),%esi
  801d97:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801d9b:	85 d2                	test   %edx,%edx
  801d9d:	75 19                	jne    801db8 <__udivdi3+0x38>
  801d9f:	39 f3                	cmp    %esi,%ebx
  801da1:	76 4d                	jbe    801df0 <__udivdi3+0x70>
  801da3:	31 ff                	xor    %edi,%edi
  801da5:	89 e8                	mov    %ebp,%eax
  801da7:	89 f2                	mov    %esi,%edx
  801da9:	f7 f3                	div    %ebx
  801dab:	89 fa                	mov    %edi,%edx
  801dad:	83 c4 1c             	add    $0x1c,%esp
  801db0:	5b                   	pop    %ebx
  801db1:	5e                   	pop    %esi
  801db2:	5f                   	pop    %edi
  801db3:	5d                   	pop    %ebp
  801db4:	c3                   	ret    
  801db5:	8d 76 00             	lea    0x0(%esi),%esi
  801db8:	39 f2                	cmp    %esi,%edx
  801dba:	76 14                	jbe    801dd0 <__udivdi3+0x50>
  801dbc:	31 ff                	xor    %edi,%edi
  801dbe:	31 c0                	xor    %eax,%eax
  801dc0:	89 fa                	mov    %edi,%edx
  801dc2:	83 c4 1c             	add    $0x1c,%esp
  801dc5:	5b                   	pop    %ebx
  801dc6:	5e                   	pop    %esi
  801dc7:	5f                   	pop    %edi
  801dc8:	5d                   	pop    %ebp
  801dc9:	c3                   	ret    
  801dca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801dd0:	0f bd fa             	bsr    %edx,%edi
  801dd3:	83 f7 1f             	xor    $0x1f,%edi
  801dd6:	75 48                	jne    801e20 <__udivdi3+0xa0>
  801dd8:	39 f2                	cmp    %esi,%edx
  801dda:	72 06                	jb     801de2 <__udivdi3+0x62>
  801ddc:	31 c0                	xor    %eax,%eax
  801dde:	39 eb                	cmp    %ebp,%ebx
  801de0:	77 de                	ja     801dc0 <__udivdi3+0x40>
  801de2:	b8 01 00 00 00       	mov    $0x1,%eax
  801de7:	eb d7                	jmp    801dc0 <__udivdi3+0x40>
  801de9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801df0:	89 d9                	mov    %ebx,%ecx
  801df2:	85 db                	test   %ebx,%ebx
  801df4:	75 0b                	jne    801e01 <__udivdi3+0x81>
  801df6:	b8 01 00 00 00       	mov    $0x1,%eax
  801dfb:	31 d2                	xor    %edx,%edx
  801dfd:	f7 f3                	div    %ebx
  801dff:	89 c1                	mov    %eax,%ecx
  801e01:	31 d2                	xor    %edx,%edx
  801e03:	89 f0                	mov    %esi,%eax
  801e05:	f7 f1                	div    %ecx
  801e07:	89 c6                	mov    %eax,%esi
  801e09:	89 e8                	mov    %ebp,%eax
  801e0b:	89 f7                	mov    %esi,%edi
  801e0d:	f7 f1                	div    %ecx
  801e0f:	89 fa                	mov    %edi,%edx
  801e11:	83 c4 1c             	add    $0x1c,%esp
  801e14:	5b                   	pop    %ebx
  801e15:	5e                   	pop    %esi
  801e16:	5f                   	pop    %edi
  801e17:	5d                   	pop    %ebp
  801e18:	c3                   	ret    
  801e19:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e20:	89 f9                	mov    %edi,%ecx
  801e22:	b8 20 00 00 00       	mov    $0x20,%eax
  801e27:	29 f8                	sub    %edi,%eax
  801e29:	d3 e2                	shl    %cl,%edx
  801e2b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801e2f:	89 c1                	mov    %eax,%ecx
  801e31:	89 da                	mov    %ebx,%edx
  801e33:	d3 ea                	shr    %cl,%edx
  801e35:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801e39:	09 d1                	or     %edx,%ecx
  801e3b:	89 f2                	mov    %esi,%edx
  801e3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e41:	89 f9                	mov    %edi,%ecx
  801e43:	d3 e3                	shl    %cl,%ebx
  801e45:	89 c1                	mov    %eax,%ecx
  801e47:	d3 ea                	shr    %cl,%edx
  801e49:	89 f9                	mov    %edi,%ecx
  801e4b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801e4f:	89 eb                	mov    %ebp,%ebx
  801e51:	d3 e6                	shl    %cl,%esi
  801e53:	89 c1                	mov    %eax,%ecx
  801e55:	d3 eb                	shr    %cl,%ebx
  801e57:	09 de                	or     %ebx,%esi
  801e59:	89 f0                	mov    %esi,%eax
  801e5b:	f7 74 24 08          	divl   0x8(%esp)
  801e5f:	89 d6                	mov    %edx,%esi
  801e61:	89 c3                	mov    %eax,%ebx
  801e63:	f7 64 24 0c          	mull   0xc(%esp)
  801e67:	39 d6                	cmp    %edx,%esi
  801e69:	72 15                	jb     801e80 <__udivdi3+0x100>
  801e6b:	89 f9                	mov    %edi,%ecx
  801e6d:	d3 e5                	shl    %cl,%ebp
  801e6f:	39 c5                	cmp    %eax,%ebp
  801e71:	73 04                	jae    801e77 <__udivdi3+0xf7>
  801e73:	39 d6                	cmp    %edx,%esi
  801e75:	74 09                	je     801e80 <__udivdi3+0x100>
  801e77:	89 d8                	mov    %ebx,%eax
  801e79:	31 ff                	xor    %edi,%edi
  801e7b:	e9 40 ff ff ff       	jmp    801dc0 <__udivdi3+0x40>
  801e80:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801e83:	31 ff                	xor    %edi,%edi
  801e85:	e9 36 ff ff ff       	jmp    801dc0 <__udivdi3+0x40>
  801e8a:	66 90                	xchg   %ax,%ax
  801e8c:	66 90                	xchg   %ax,%ax
  801e8e:	66 90                	xchg   %ax,%ax

00801e90 <__umoddi3>:
  801e90:	f3 0f 1e fb          	endbr32 
  801e94:	55                   	push   %ebp
  801e95:	57                   	push   %edi
  801e96:	56                   	push   %esi
  801e97:	53                   	push   %ebx
  801e98:	83 ec 1c             	sub    $0x1c,%esp
  801e9b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801e9f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801ea3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801ea7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801eab:	85 c0                	test   %eax,%eax
  801ead:	75 19                	jne    801ec8 <__umoddi3+0x38>
  801eaf:	39 df                	cmp    %ebx,%edi
  801eb1:	76 5d                	jbe    801f10 <__umoddi3+0x80>
  801eb3:	89 f0                	mov    %esi,%eax
  801eb5:	89 da                	mov    %ebx,%edx
  801eb7:	f7 f7                	div    %edi
  801eb9:	89 d0                	mov    %edx,%eax
  801ebb:	31 d2                	xor    %edx,%edx
  801ebd:	83 c4 1c             	add    $0x1c,%esp
  801ec0:	5b                   	pop    %ebx
  801ec1:	5e                   	pop    %esi
  801ec2:	5f                   	pop    %edi
  801ec3:	5d                   	pop    %ebp
  801ec4:	c3                   	ret    
  801ec5:	8d 76 00             	lea    0x0(%esi),%esi
  801ec8:	89 f2                	mov    %esi,%edx
  801eca:	39 d8                	cmp    %ebx,%eax
  801ecc:	76 12                	jbe    801ee0 <__umoddi3+0x50>
  801ece:	89 f0                	mov    %esi,%eax
  801ed0:	89 da                	mov    %ebx,%edx
  801ed2:	83 c4 1c             	add    $0x1c,%esp
  801ed5:	5b                   	pop    %ebx
  801ed6:	5e                   	pop    %esi
  801ed7:	5f                   	pop    %edi
  801ed8:	5d                   	pop    %ebp
  801ed9:	c3                   	ret    
  801eda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801ee0:	0f bd e8             	bsr    %eax,%ebp
  801ee3:	83 f5 1f             	xor    $0x1f,%ebp
  801ee6:	75 50                	jne    801f38 <__umoddi3+0xa8>
  801ee8:	39 d8                	cmp    %ebx,%eax
  801eea:	0f 82 e0 00 00 00    	jb     801fd0 <__umoddi3+0x140>
  801ef0:	89 d9                	mov    %ebx,%ecx
  801ef2:	39 f7                	cmp    %esi,%edi
  801ef4:	0f 86 d6 00 00 00    	jbe    801fd0 <__umoddi3+0x140>
  801efa:	89 d0                	mov    %edx,%eax
  801efc:	89 ca                	mov    %ecx,%edx
  801efe:	83 c4 1c             	add    $0x1c,%esp
  801f01:	5b                   	pop    %ebx
  801f02:	5e                   	pop    %esi
  801f03:	5f                   	pop    %edi
  801f04:	5d                   	pop    %ebp
  801f05:	c3                   	ret    
  801f06:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f0d:	8d 76 00             	lea    0x0(%esi),%esi
  801f10:	89 fd                	mov    %edi,%ebp
  801f12:	85 ff                	test   %edi,%edi
  801f14:	75 0b                	jne    801f21 <__umoddi3+0x91>
  801f16:	b8 01 00 00 00       	mov    $0x1,%eax
  801f1b:	31 d2                	xor    %edx,%edx
  801f1d:	f7 f7                	div    %edi
  801f1f:	89 c5                	mov    %eax,%ebp
  801f21:	89 d8                	mov    %ebx,%eax
  801f23:	31 d2                	xor    %edx,%edx
  801f25:	f7 f5                	div    %ebp
  801f27:	89 f0                	mov    %esi,%eax
  801f29:	f7 f5                	div    %ebp
  801f2b:	89 d0                	mov    %edx,%eax
  801f2d:	31 d2                	xor    %edx,%edx
  801f2f:	eb 8c                	jmp    801ebd <__umoddi3+0x2d>
  801f31:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801f38:	89 e9                	mov    %ebp,%ecx
  801f3a:	ba 20 00 00 00       	mov    $0x20,%edx
  801f3f:	29 ea                	sub    %ebp,%edx
  801f41:	d3 e0                	shl    %cl,%eax
  801f43:	89 44 24 08          	mov    %eax,0x8(%esp)
  801f47:	89 d1                	mov    %edx,%ecx
  801f49:	89 f8                	mov    %edi,%eax
  801f4b:	d3 e8                	shr    %cl,%eax
  801f4d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801f51:	89 54 24 04          	mov    %edx,0x4(%esp)
  801f55:	8b 54 24 04          	mov    0x4(%esp),%edx
  801f59:	09 c1                	or     %eax,%ecx
  801f5b:	89 d8                	mov    %ebx,%eax
  801f5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801f61:	89 e9                	mov    %ebp,%ecx
  801f63:	d3 e7                	shl    %cl,%edi
  801f65:	89 d1                	mov    %edx,%ecx
  801f67:	d3 e8                	shr    %cl,%eax
  801f69:	89 e9                	mov    %ebp,%ecx
  801f6b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801f6f:	d3 e3                	shl    %cl,%ebx
  801f71:	89 c7                	mov    %eax,%edi
  801f73:	89 d1                	mov    %edx,%ecx
  801f75:	89 f0                	mov    %esi,%eax
  801f77:	d3 e8                	shr    %cl,%eax
  801f79:	89 e9                	mov    %ebp,%ecx
  801f7b:	89 fa                	mov    %edi,%edx
  801f7d:	d3 e6                	shl    %cl,%esi
  801f7f:	09 d8                	or     %ebx,%eax
  801f81:	f7 74 24 08          	divl   0x8(%esp)
  801f85:	89 d1                	mov    %edx,%ecx
  801f87:	89 f3                	mov    %esi,%ebx
  801f89:	f7 64 24 0c          	mull   0xc(%esp)
  801f8d:	89 c6                	mov    %eax,%esi
  801f8f:	89 d7                	mov    %edx,%edi
  801f91:	39 d1                	cmp    %edx,%ecx
  801f93:	72 06                	jb     801f9b <__umoddi3+0x10b>
  801f95:	75 10                	jne    801fa7 <__umoddi3+0x117>
  801f97:	39 c3                	cmp    %eax,%ebx
  801f99:	73 0c                	jae    801fa7 <__umoddi3+0x117>
  801f9b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801f9f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801fa3:	89 d7                	mov    %edx,%edi
  801fa5:	89 c6                	mov    %eax,%esi
  801fa7:	89 ca                	mov    %ecx,%edx
  801fa9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801fae:	29 f3                	sub    %esi,%ebx
  801fb0:	19 fa                	sbb    %edi,%edx
  801fb2:	89 d0                	mov    %edx,%eax
  801fb4:	d3 e0                	shl    %cl,%eax
  801fb6:	89 e9                	mov    %ebp,%ecx
  801fb8:	d3 eb                	shr    %cl,%ebx
  801fba:	d3 ea                	shr    %cl,%edx
  801fbc:	09 d8                	or     %ebx,%eax
  801fbe:	83 c4 1c             	add    $0x1c,%esp
  801fc1:	5b                   	pop    %ebx
  801fc2:	5e                   	pop    %esi
  801fc3:	5f                   	pop    %edi
  801fc4:	5d                   	pop    %ebp
  801fc5:	c3                   	ret    
  801fc6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fcd:	8d 76 00             	lea    0x0(%esi),%esi
  801fd0:	29 fe                	sub    %edi,%esi
  801fd2:	19 c3                	sbb    %eax,%ebx
  801fd4:	89 f2                	mov    %esi,%edx
  801fd6:	89 d9                	mov    %ebx,%ecx
  801fd8:	e9 1d ff ff ff       	jmp    801efa <__umoddi3+0x6a>
