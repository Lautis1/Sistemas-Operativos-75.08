
obj/user/faultalloc.debug:     formato del fichero elf32-i386


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
  80002c:	e8 a1 00 00 00       	call   8000d2 <libmain>
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
  800044:	68 e0 1e 80 00       	push   $0x801ee0
  800049:	e8 d7 01 00 00       	call   800225 <cprintf>
	if ((r = sys_page_alloc(0, ROUNDDOWN(addr, PGSIZE),
  80004e:	83 c4 0c             	add    $0xc,%esp
  800051:	6a 07                	push   $0x7
  800053:	89 d8                	mov    %ebx,%eax
  800055:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80005a:	50                   	push   %eax
  80005b:	6a 00                	push   $0x0
  80005d:	e8 b5 0b 00 00       	call   800c17 <sys_page_alloc>
  800062:	83 c4 10             	add    $0x10,%esp
  800065:	85 c0                	test   %eax,%eax
  800067:	78 16                	js     80007f <handler+0x4c>
				PTE_P|PTE_U|PTE_W)) < 0)
		panic("allocating at %x in page fault handler: %e", addr, r);
	snprintf((char*) addr, 100, "this string was faulted in at %x", addr);
  800069:	53                   	push   %ebx
  80006a:	68 2c 1f 80 00       	push   $0x801f2c
  80006f:	6a 64                	push   $0x64
  800071:	53                   	push   %ebx
  800072:	e8 b7 06 00 00       	call   80072e <snprintf>
}
  800077:	83 c4 10             	add    $0x10,%esp
  80007a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007d:	c9                   	leave  
  80007e:	c3                   	ret    
		panic("allocating at %x in page fault handler: %e", addr, r);
  80007f:	83 ec 0c             	sub    $0xc,%esp
  800082:	50                   	push   %eax
  800083:	53                   	push   %ebx
  800084:	68 00 1f 80 00       	push   $0x801f00
  800089:	6a 0e                	push   $0xe
  80008b:	68 ea 1e 80 00       	push   $0x801eea
  800090:	e8 a9 00 00 00       	call   80013e <_panic>

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
  8000a4:	e8 ab 0c 00 00       	call   800d54 <set_pgfault_handler>
	cprintf("%s\n", (char*)0xDeadBeef);
  8000a9:	83 c4 08             	add    $0x8,%esp
  8000ac:	68 ef be ad de       	push   $0xdeadbeef
  8000b1:	68 fc 1e 80 00       	push   $0x801efc
  8000b6:	e8 6a 01 00 00       	call   800225 <cprintf>
	cprintf("%s\n", (char*)0xCafeBffe);
  8000bb:	83 c4 08             	add    $0x8,%esp
  8000be:	68 fe bf fe ca       	push   $0xcafebffe
  8000c3:	68 fc 1e 80 00       	push   $0x801efc
  8000c8:	e8 58 01 00 00       	call   800225 <cprintf>
}
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	c9                   	leave  
  8000d1:	c3                   	ret    

008000d2 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8000d2:	f3 0f 1e fb          	endbr32 
  8000d6:	55                   	push   %ebp
  8000d7:	89 e5                	mov    %esp,%ebp
  8000d9:	56                   	push   %esi
  8000da:	53                   	push   %ebx
  8000db:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8000de:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8000e1:	e8 de 0a 00 00       	call   800bc4 <sys_getenvid>
	if (id >= 0)
  8000e6:	85 c0                	test   %eax,%eax
  8000e8:	78 12                	js     8000fc <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8000ea:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000ef:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000f2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000f7:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000fc:	85 db                	test   %ebx,%ebx
  8000fe:	7e 07                	jle    800107 <libmain+0x35>
		binaryname = argv[0];
  800100:	8b 06                	mov    (%esi),%eax
  800102:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800107:	83 ec 08             	sub    $0x8,%esp
  80010a:	56                   	push   %esi
  80010b:	53                   	push   %ebx
  80010c:	e8 84 ff ff ff       	call   800095 <umain>

	// exit gracefully
	exit();
  800111:	e8 0a 00 00 00       	call   800120 <exit>
}
  800116:	83 c4 10             	add    $0x10,%esp
  800119:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80011c:	5b                   	pop    %ebx
  80011d:	5e                   	pop    %esi
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800120:	f3 0f 1e fb          	endbr32 
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80012a:	e8 9b 0e 00 00       	call   800fca <close_all>
	sys_env_destroy(0);
  80012f:	83 ec 0c             	sub    $0xc,%esp
  800132:	6a 00                	push   $0x0
  800134:	e8 65 0a 00 00       	call   800b9e <sys_env_destroy>
}
  800139:	83 c4 10             	add    $0x10,%esp
  80013c:	c9                   	leave  
  80013d:	c3                   	ret    

0080013e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80013e:	f3 0f 1e fb          	endbr32 
  800142:	55                   	push   %ebp
  800143:	89 e5                	mov    %esp,%ebp
  800145:	56                   	push   %esi
  800146:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800147:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80014a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  800150:	e8 6f 0a 00 00       	call   800bc4 <sys_getenvid>
  800155:	83 ec 0c             	sub    $0xc,%esp
  800158:	ff 75 0c             	pushl  0xc(%ebp)
  80015b:	ff 75 08             	pushl  0x8(%ebp)
  80015e:	56                   	push   %esi
  80015f:	50                   	push   %eax
  800160:	68 58 1f 80 00       	push   $0x801f58
  800165:	e8 bb 00 00 00       	call   800225 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80016a:	83 c4 18             	add    $0x18,%esp
  80016d:	53                   	push   %ebx
  80016e:	ff 75 10             	pushl  0x10(%ebp)
  800171:	e8 5a 00 00 00       	call   8001d0 <vcprintf>
	cprintf("\n");
  800176:	c7 04 24 ab 23 80 00 	movl   $0x8023ab,(%esp)
  80017d:	e8 a3 00 00 00       	call   800225 <cprintf>
  800182:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800185:	cc                   	int3   
  800186:	eb fd                	jmp    800185 <_panic+0x47>

00800188 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800188:	f3 0f 1e fb          	endbr32 
  80018c:	55                   	push   %ebp
  80018d:	89 e5                	mov    %esp,%ebp
  80018f:	53                   	push   %ebx
  800190:	83 ec 04             	sub    $0x4,%esp
  800193:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800196:	8b 13                	mov    (%ebx),%edx
  800198:	8d 42 01             	lea    0x1(%edx),%eax
  80019b:	89 03                	mov    %eax,(%ebx)
  80019d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001a0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8001a4:	3d ff 00 00 00       	cmp    $0xff,%eax
  8001a9:	74 09                	je     8001b4 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8001ab:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8001af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8001b2:	c9                   	leave  
  8001b3:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8001b4:	83 ec 08             	sub    $0x8,%esp
  8001b7:	68 ff 00 00 00       	push   $0xff
  8001bc:	8d 43 08             	lea    0x8(%ebx),%eax
  8001bf:	50                   	push   %eax
  8001c0:	e8 87 09 00 00       	call   800b4c <sys_cputs>
		b->idx = 0;
  8001c5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	eb db                	jmp    8001ab <putch+0x23>

008001d0 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8001d0:	f3 0f 1e fb          	endbr32 
  8001d4:	55                   	push   %ebp
  8001d5:	89 e5                	mov    %esp,%ebp
  8001d7:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8001dd:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8001e4:	00 00 00 
	b.cnt = 0;
  8001e7:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8001ee:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8001f1:	ff 75 0c             	pushl  0xc(%ebp)
  8001f4:	ff 75 08             	pushl  0x8(%ebp)
  8001f7:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8001fd:	50                   	push   %eax
  8001fe:	68 88 01 80 00       	push   $0x800188
  800203:	e8 80 01 00 00       	call   800388 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800208:	83 c4 08             	add    $0x8,%esp
  80020b:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800211:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800217:	50                   	push   %eax
  800218:	e8 2f 09 00 00       	call   800b4c <sys_cputs>

	return b.cnt;
}
  80021d:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800223:	c9                   	leave  
  800224:	c3                   	ret    

00800225 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800225:	f3 0f 1e fb          	endbr32 
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80022f:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800232:	50                   	push   %eax
  800233:	ff 75 08             	pushl  0x8(%ebp)
  800236:	e8 95 ff ff ff       	call   8001d0 <vcprintf>
	va_end(ap);

	return cnt;
}
  80023b:	c9                   	leave  
  80023c:	c3                   	ret    

0080023d <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
  800240:	57                   	push   %edi
  800241:	56                   	push   %esi
  800242:	53                   	push   %ebx
  800243:	83 ec 1c             	sub    $0x1c,%esp
  800246:	89 c7                	mov    %eax,%edi
  800248:	89 d6                	mov    %edx,%esi
  80024a:	8b 45 08             	mov    0x8(%ebp),%eax
  80024d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800250:	89 d1                	mov    %edx,%ecx
  800252:	89 c2                	mov    %eax,%edx
  800254:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800257:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80025a:	8b 45 10             	mov    0x10(%ebp),%eax
  80025d:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800260:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800263:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80026a:	39 c2                	cmp    %eax,%edx
  80026c:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80026f:	72 3e                	jb     8002af <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800271:	83 ec 0c             	sub    $0xc,%esp
  800274:	ff 75 18             	pushl  0x18(%ebp)
  800277:	83 eb 01             	sub    $0x1,%ebx
  80027a:	53                   	push   %ebx
  80027b:	50                   	push   %eax
  80027c:	83 ec 08             	sub    $0x8,%esp
  80027f:	ff 75 e4             	pushl  -0x1c(%ebp)
  800282:	ff 75 e0             	pushl  -0x20(%ebp)
  800285:	ff 75 dc             	pushl  -0x24(%ebp)
  800288:	ff 75 d8             	pushl  -0x28(%ebp)
  80028b:	e8 e0 19 00 00       	call   801c70 <__udivdi3>
  800290:	83 c4 18             	add    $0x18,%esp
  800293:	52                   	push   %edx
  800294:	50                   	push   %eax
  800295:	89 f2                	mov    %esi,%edx
  800297:	89 f8                	mov    %edi,%eax
  800299:	e8 9f ff ff ff       	call   80023d <printnum>
  80029e:	83 c4 20             	add    $0x20,%esp
  8002a1:	eb 13                	jmp    8002b6 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8002a3:	83 ec 08             	sub    $0x8,%esp
  8002a6:	56                   	push   %esi
  8002a7:	ff 75 18             	pushl  0x18(%ebp)
  8002aa:	ff d7                	call   *%edi
  8002ac:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8002af:	83 eb 01             	sub    $0x1,%ebx
  8002b2:	85 db                	test   %ebx,%ebx
  8002b4:	7f ed                	jg     8002a3 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8002b6:	83 ec 08             	sub    $0x8,%esp
  8002b9:	56                   	push   %esi
  8002ba:	83 ec 04             	sub    $0x4,%esp
  8002bd:	ff 75 e4             	pushl  -0x1c(%ebp)
  8002c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8002c3:	ff 75 dc             	pushl  -0x24(%ebp)
  8002c6:	ff 75 d8             	pushl  -0x28(%ebp)
  8002c9:	e8 b2 1a 00 00       	call   801d80 <__umoddi3>
  8002ce:	83 c4 14             	add    $0x14,%esp
  8002d1:	0f be 80 7b 1f 80 00 	movsbl 0x801f7b(%eax),%eax
  8002d8:	50                   	push   %eax
  8002d9:	ff d7                	call   *%edi
}
  8002db:	83 c4 10             	add    $0x10,%esp
  8002de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e1:	5b                   	pop    %ebx
  8002e2:	5e                   	pop    %esi
  8002e3:	5f                   	pop    %edi
  8002e4:	5d                   	pop    %ebp
  8002e5:	c3                   	ret    

008002e6 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8002e6:	83 fa 01             	cmp    $0x1,%edx
  8002e9:	7f 13                	jg     8002fe <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8002eb:	85 d2                	test   %edx,%edx
  8002ed:	74 1c                	je     80030b <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8002ef:	8b 10                	mov    (%eax),%edx
  8002f1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002f4:	89 08                	mov    %ecx,(%eax)
  8002f6:	8b 02                	mov    (%edx),%eax
  8002f8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002fd:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8002fe:	8b 10                	mov    (%eax),%edx
  800300:	8d 4a 08             	lea    0x8(%edx),%ecx
  800303:	89 08                	mov    %ecx,(%eax)
  800305:	8b 02                	mov    (%edx),%eax
  800307:	8b 52 04             	mov    0x4(%edx),%edx
  80030a:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  80030b:	8b 10                	mov    (%eax),%edx
  80030d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800310:	89 08                	mov    %ecx,(%eax)
  800312:	8b 02                	mov    (%edx),%eax
  800314:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800319:	c3                   	ret    

0080031a <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80031a:	83 fa 01             	cmp    $0x1,%edx
  80031d:	7f 0f                	jg     80032e <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  80031f:	85 d2                	test   %edx,%edx
  800321:	74 18                	je     80033b <getint+0x21>
		return va_arg(*ap, long);
  800323:	8b 10                	mov    (%eax),%edx
  800325:	8d 4a 04             	lea    0x4(%edx),%ecx
  800328:	89 08                	mov    %ecx,(%eax)
  80032a:	8b 02                	mov    (%edx),%eax
  80032c:	99                   	cltd   
  80032d:	c3                   	ret    
		return va_arg(*ap, long long);
  80032e:	8b 10                	mov    (%eax),%edx
  800330:	8d 4a 08             	lea    0x8(%edx),%ecx
  800333:	89 08                	mov    %ecx,(%eax)
  800335:	8b 02                	mov    (%edx),%eax
  800337:	8b 52 04             	mov    0x4(%edx),%edx
  80033a:	c3                   	ret    
	else
		return va_arg(*ap, int);
  80033b:	8b 10                	mov    (%eax),%edx
  80033d:	8d 4a 04             	lea    0x4(%edx),%ecx
  800340:	89 08                	mov    %ecx,(%eax)
  800342:	8b 02                	mov    (%edx),%eax
  800344:	99                   	cltd   
}
  800345:	c3                   	ret    

00800346 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800346:	f3 0f 1e fb          	endbr32 
  80034a:	55                   	push   %ebp
  80034b:	89 e5                	mov    %esp,%ebp
  80034d:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800350:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800354:	8b 10                	mov    (%eax),%edx
  800356:	3b 50 04             	cmp    0x4(%eax),%edx
  800359:	73 0a                	jae    800365 <sprintputch+0x1f>
		*b->buf++ = ch;
  80035b:	8d 4a 01             	lea    0x1(%edx),%ecx
  80035e:	89 08                	mov    %ecx,(%eax)
  800360:	8b 45 08             	mov    0x8(%ebp),%eax
  800363:	88 02                	mov    %al,(%edx)
}
  800365:	5d                   	pop    %ebp
  800366:	c3                   	ret    

00800367 <printfmt>:
{
  800367:	f3 0f 1e fb          	endbr32 
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
  80036e:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800371:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800374:	50                   	push   %eax
  800375:	ff 75 10             	pushl  0x10(%ebp)
  800378:	ff 75 0c             	pushl  0xc(%ebp)
  80037b:	ff 75 08             	pushl  0x8(%ebp)
  80037e:	e8 05 00 00 00       	call   800388 <vprintfmt>
}
  800383:	83 c4 10             	add    $0x10,%esp
  800386:	c9                   	leave  
  800387:	c3                   	ret    

00800388 <vprintfmt>:
{
  800388:	f3 0f 1e fb          	endbr32 
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	57                   	push   %edi
  800390:	56                   	push   %esi
  800391:	53                   	push   %ebx
  800392:	83 ec 2c             	sub    $0x2c,%esp
  800395:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800398:	8b 75 0c             	mov    0xc(%ebp),%esi
  80039b:	8b 7d 10             	mov    0x10(%ebp),%edi
  80039e:	e9 86 02 00 00       	jmp    800629 <vprintfmt+0x2a1>
		padc = ' ';
  8003a3:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8003a7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8003ae:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8003b5:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8003bc:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003c1:	8d 47 01             	lea    0x1(%edi),%eax
  8003c4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8003c7:	0f b6 17             	movzbl (%edi),%edx
  8003ca:	8d 42 dd             	lea    -0x23(%edx),%eax
  8003cd:	3c 55                	cmp    $0x55,%al
  8003cf:	0f 87 df 02 00 00    	ja     8006b4 <vprintfmt+0x32c>
  8003d5:	0f b6 c0             	movzbl %al,%eax
  8003d8:	3e ff 24 85 c0 20 80 	notrack jmp *0x8020c0(,%eax,4)
  8003df:	00 
  8003e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8003e3:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8003e7:	eb d8                	jmp    8003c1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8003ec:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8003f0:	eb cf                	jmp    8003c1 <vprintfmt+0x39>
  8003f2:	0f b6 d2             	movzbl %dl,%edx
  8003f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8003f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003fd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800400:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800403:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800407:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80040a:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80040d:	83 f9 09             	cmp    $0x9,%ecx
  800410:	77 52                	ja     800464 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  800412:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800415:	eb e9                	jmp    800400 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800417:	8b 45 14             	mov    0x14(%ebp),%eax
  80041a:	8d 50 04             	lea    0x4(%eax),%edx
  80041d:	89 55 14             	mov    %edx,0x14(%ebp)
  800420:	8b 00                	mov    (%eax),%eax
  800422:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800425:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800428:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80042c:	79 93                	jns    8003c1 <vprintfmt+0x39>
				width = precision, precision = -1;
  80042e:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800431:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800434:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80043b:	eb 84                	jmp    8003c1 <vprintfmt+0x39>
  80043d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800440:	85 c0                	test   %eax,%eax
  800442:	ba 00 00 00 00       	mov    $0x0,%edx
  800447:	0f 49 d0             	cmovns %eax,%edx
  80044a:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80044d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800450:	e9 6c ff ff ff       	jmp    8003c1 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800455:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800458:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80045f:	e9 5d ff ff ff       	jmp    8003c1 <vprintfmt+0x39>
  800464:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800467:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80046a:	eb bc                	jmp    800428 <vprintfmt+0xa0>
			lflag++;
  80046c:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80046f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800472:	e9 4a ff ff ff       	jmp    8003c1 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800477:	8b 45 14             	mov    0x14(%ebp),%eax
  80047a:	8d 50 04             	lea    0x4(%eax),%edx
  80047d:	89 55 14             	mov    %edx,0x14(%ebp)
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	56                   	push   %esi
  800484:	ff 30                	pushl  (%eax)
  800486:	ff d3                	call   *%ebx
			break;
  800488:	83 c4 10             	add    $0x10,%esp
  80048b:	e9 96 01 00 00       	jmp    800626 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  800490:	8b 45 14             	mov    0x14(%ebp),%eax
  800493:	8d 50 04             	lea    0x4(%eax),%edx
  800496:	89 55 14             	mov    %edx,0x14(%ebp)
  800499:	8b 00                	mov    (%eax),%eax
  80049b:	99                   	cltd   
  80049c:	31 d0                	xor    %edx,%eax
  80049e:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8004a0:	83 f8 0f             	cmp    $0xf,%eax
  8004a3:	7f 20                	jg     8004c5 <vprintfmt+0x13d>
  8004a5:	8b 14 85 20 22 80 00 	mov    0x802220(,%eax,4),%edx
  8004ac:	85 d2                	test   %edx,%edx
  8004ae:	74 15                	je     8004c5 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8004b0:	52                   	push   %edx
  8004b1:	68 79 23 80 00       	push   $0x802379
  8004b6:	56                   	push   %esi
  8004b7:	53                   	push   %ebx
  8004b8:	e8 aa fe ff ff       	call   800367 <printfmt>
  8004bd:	83 c4 10             	add    $0x10,%esp
  8004c0:	e9 61 01 00 00       	jmp    800626 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8004c5:	50                   	push   %eax
  8004c6:	68 93 1f 80 00       	push   $0x801f93
  8004cb:	56                   	push   %esi
  8004cc:	53                   	push   %ebx
  8004cd:	e8 95 fe ff ff       	call   800367 <printfmt>
  8004d2:	83 c4 10             	add    $0x10,%esp
  8004d5:	e9 4c 01 00 00       	jmp    800626 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8004da:	8b 45 14             	mov    0x14(%ebp),%eax
  8004dd:	8d 50 04             	lea    0x4(%eax),%edx
  8004e0:	89 55 14             	mov    %edx,0x14(%ebp)
  8004e3:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8004e5:	85 c9                	test   %ecx,%ecx
  8004e7:	b8 8c 1f 80 00       	mov    $0x801f8c,%eax
  8004ec:	0f 45 c1             	cmovne %ecx,%eax
  8004ef:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8004f2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004f6:	7e 06                	jle    8004fe <vprintfmt+0x176>
  8004f8:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8004fc:	75 0d                	jne    80050b <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  8004fe:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800501:	89 c7                	mov    %eax,%edi
  800503:	03 45 e0             	add    -0x20(%ebp),%eax
  800506:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800509:	eb 57                	jmp    800562 <vprintfmt+0x1da>
  80050b:	83 ec 08             	sub    $0x8,%esp
  80050e:	ff 75 d8             	pushl  -0x28(%ebp)
  800511:	ff 75 cc             	pushl  -0x34(%ebp)
  800514:	e8 4f 02 00 00       	call   800768 <strnlen>
  800519:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80051c:	29 c2                	sub    %eax,%edx
  80051e:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800521:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800524:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800528:	89 5d 08             	mov    %ebx,0x8(%ebp)
  80052b:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80052d:	85 db                	test   %ebx,%ebx
  80052f:	7e 10                	jle    800541 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800531:	83 ec 08             	sub    $0x8,%esp
  800534:	56                   	push   %esi
  800535:	57                   	push   %edi
  800536:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800539:	83 eb 01             	sub    $0x1,%ebx
  80053c:	83 c4 10             	add    $0x10,%esp
  80053f:	eb ec                	jmp    80052d <vprintfmt+0x1a5>
  800541:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800544:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800547:	85 d2                	test   %edx,%edx
  800549:	b8 00 00 00 00       	mov    $0x0,%eax
  80054e:	0f 49 c2             	cmovns %edx,%eax
  800551:	29 c2                	sub    %eax,%edx
  800553:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800556:	eb a6                	jmp    8004fe <vprintfmt+0x176>
					putch(ch, putdat);
  800558:	83 ec 08             	sub    $0x8,%esp
  80055b:	56                   	push   %esi
  80055c:	52                   	push   %edx
  80055d:	ff d3                	call   *%ebx
  80055f:	83 c4 10             	add    $0x10,%esp
  800562:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800565:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800567:	83 c7 01             	add    $0x1,%edi
  80056a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80056e:	0f be d0             	movsbl %al,%edx
  800571:	85 d2                	test   %edx,%edx
  800573:	74 42                	je     8005b7 <vprintfmt+0x22f>
  800575:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800579:	78 06                	js     800581 <vprintfmt+0x1f9>
  80057b:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80057f:	78 1e                	js     80059f <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  800581:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800585:	74 d1                	je     800558 <vprintfmt+0x1d0>
  800587:	0f be c0             	movsbl %al,%eax
  80058a:	83 e8 20             	sub    $0x20,%eax
  80058d:	83 f8 5e             	cmp    $0x5e,%eax
  800590:	76 c6                	jbe    800558 <vprintfmt+0x1d0>
					putch('?', putdat);
  800592:	83 ec 08             	sub    $0x8,%esp
  800595:	56                   	push   %esi
  800596:	6a 3f                	push   $0x3f
  800598:	ff d3                	call   *%ebx
  80059a:	83 c4 10             	add    $0x10,%esp
  80059d:	eb c3                	jmp    800562 <vprintfmt+0x1da>
  80059f:	89 cf                	mov    %ecx,%edi
  8005a1:	eb 0e                	jmp    8005b1 <vprintfmt+0x229>
				putch(' ', putdat);
  8005a3:	83 ec 08             	sub    $0x8,%esp
  8005a6:	56                   	push   %esi
  8005a7:	6a 20                	push   $0x20
  8005a9:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8005ab:	83 ef 01             	sub    $0x1,%edi
  8005ae:	83 c4 10             	add    $0x10,%esp
  8005b1:	85 ff                	test   %edi,%edi
  8005b3:	7f ee                	jg     8005a3 <vprintfmt+0x21b>
  8005b5:	eb 6f                	jmp    800626 <vprintfmt+0x29e>
  8005b7:	89 cf                	mov    %ecx,%edi
  8005b9:	eb f6                	jmp    8005b1 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8005bb:	89 ca                	mov    %ecx,%edx
  8005bd:	8d 45 14             	lea    0x14(%ebp),%eax
  8005c0:	e8 55 fd ff ff       	call   80031a <getint>
  8005c5:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005c8:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8005cb:	85 d2                	test   %edx,%edx
  8005cd:	78 0b                	js     8005da <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8005cf:	89 d1                	mov    %edx,%ecx
  8005d1:	89 c2                	mov    %eax,%edx
			base = 10;
  8005d3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005d8:	eb 32                	jmp    80060c <vprintfmt+0x284>
				putch('-', putdat);
  8005da:	83 ec 08             	sub    $0x8,%esp
  8005dd:	56                   	push   %esi
  8005de:	6a 2d                	push   $0x2d
  8005e0:	ff d3                	call   *%ebx
				num = -(long long) num;
  8005e2:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8005e5:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8005e8:	f7 da                	neg    %edx
  8005ea:	83 d1 00             	adc    $0x0,%ecx
  8005ed:	f7 d9                	neg    %ecx
  8005ef:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8005f2:	b8 0a 00 00 00       	mov    $0xa,%eax
  8005f7:	eb 13                	jmp    80060c <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8005f9:	89 ca                	mov    %ecx,%edx
  8005fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fe:	e8 e3 fc ff ff       	call   8002e6 <getuint>
  800603:	89 d1                	mov    %edx,%ecx
  800605:	89 c2                	mov    %eax,%edx
			base = 10;
  800607:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  80060c:	83 ec 0c             	sub    $0xc,%esp
  80060f:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800613:	57                   	push   %edi
  800614:	ff 75 e0             	pushl  -0x20(%ebp)
  800617:	50                   	push   %eax
  800618:	51                   	push   %ecx
  800619:	52                   	push   %edx
  80061a:	89 f2                	mov    %esi,%edx
  80061c:	89 d8                	mov    %ebx,%eax
  80061e:	e8 1a fc ff ff       	call   80023d <printnum>
			break;
  800623:	83 c4 20             	add    $0x20,%esp
{
  800626:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800629:	83 c7 01             	add    $0x1,%edi
  80062c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800630:	83 f8 25             	cmp    $0x25,%eax
  800633:	0f 84 6a fd ff ff    	je     8003a3 <vprintfmt+0x1b>
			if (ch == '\0')
  800639:	85 c0                	test   %eax,%eax
  80063b:	0f 84 93 00 00 00    	je     8006d4 <vprintfmt+0x34c>
			putch(ch, putdat);
  800641:	83 ec 08             	sub    $0x8,%esp
  800644:	56                   	push   %esi
  800645:	50                   	push   %eax
  800646:	ff d3                	call   *%ebx
  800648:	83 c4 10             	add    $0x10,%esp
  80064b:	eb dc                	jmp    800629 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  80064d:	89 ca                	mov    %ecx,%edx
  80064f:	8d 45 14             	lea    0x14(%ebp),%eax
  800652:	e8 8f fc ff ff       	call   8002e6 <getuint>
  800657:	89 d1                	mov    %edx,%ecx
  800659:	89 c2                	mov    %eax,%edx
			base = 8;
  80065b:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800660:	eb aa                	jmp    80060c <vprintfmt+0x284>
			putch('0', putdat);
  800662:	83 ec 08             	sub    $0x8,%esp
  800665:	56                   	push   %esi
  800666:	6a 30                	push   $0x30
  800668:	ff d3                	call   *%ebx
			putch('x', putdat);
  80066a:	83 c4 08             	add    $0x8,%esp
  80066d:	56                   	push   %esi
  80066e:	6a 78                	push   $0x78
  800670:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  800672:	8b 45 14             	mov    0x14(%ebp),%eax
  800675:	8d 50 04             	lea    0x4(%eax),%edx
  800678:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  80067b:	8b 10                	mov    (%eax),%edx
  80067d:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800682:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800685:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80068a:	eb 80                	jmp    80060c <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  80068c:	89 ca                	mov    %ecx,%edx
  80068e:	8d 45 14             	lea    0x14(%ebp),%eax
  800691:	e8 50 fc ff ff       	call   8002e6 <getuint>
  800696:	89 d1                	mov    %edx,%ecx
  800698:	89 c2                	mov    %eax,%edx
			base = 16;
  80069a:	b8 10 00 00 00       	mov    $0x10,%eax
  80069f:	e9 68 ff ff ff       	jmp    80060c <vprintfmt+0x284>
			putch(ch, putdat);
  8006a4:	83 ec 08             	sub    $0x8,%esp
  8006a7:	56                   	push   %esi
  8006a8:	6a 25                	push   $0x25
  8006aa:	ff d3                	call   *%ebx
			break;
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	e9 72 ff ff ff       	jmp    800626 <vprintfmt+0x29e>
			putch('%', putdat);
  8006b4:	83 ec 08             	sub    $0x8,%esp
  8006b7:	56                   	push   %esi
  8006b8:	6a 25                	push   $0x25
  8006ba:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8006bc:	83 c4 10             	add    $0x10,%esp
  8006bf:	89 f8                	mov    %edi,%eax
  8006c1:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8006c5:	74 05                	je     8006cc <vprintfmt+0x344>
  8006c7:	83 e8 01             	sub    $0x1,%eax
  8006ca:	eb f5                	jmp    8006c1 <vprintfmt+0x339>
  8006cc:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006cf:	e9 52 ff ff ff       	jmp    800626 <vprintfmt+0x29e>
}
  8006d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d7:	5b                   	pop    %ebx
  8006d8:	5e                   	pop    %esi
  8006d9:	5f                   	pop    %edi
  8006da:	5d                   	pop    %ebp
  8006db:	c3                   	ret    

008006dc <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8006dc:	f3 0f 1e fb          	endbr32 
  8006e0:	55                   	push   %ebp
  8006e1:	89 e5                	mov    %esp,%ebp
  8006e3:	83 ec 18             	sub    $0x18,%esp
  8006e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8006e9:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8006ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8006ef:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8006f3:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8006f6:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8006fd:	85 c0                	test   %eax,%eax
  8006ff:	74 26                	je     800727 <vsnprintf+0x4b>
  800701:	85 d2                	test   %edx,%edx
  800703:	7e 22                	jle    800727 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800705:	ff 75 14             	pushl  0x14(%ebp)
  800708:	ff 75 10             	pushl  0x10(%ebp)
  80070b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80070e:	50                   	push   %eax
  80070f:	68 46 03 80 00       	push   $0x800346
  800714:	e8 6f fc ff ff       	call   800388 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800719:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80071c:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80071f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800722:	83 c4 10             	add    $0x10,%esp
}
  800725:	c9                   	leave  
  800726:	c3                   	ret    
		return -E_INVAL;
  800727:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80072c:	eb f7                	jmp    800725 <vsnprintf+0x49>

0080072e <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80072e:	f3 0f 1e fb          	endbr32 
  800732:	55                   	push   %ebp
  800733:	89 e5                	mov    %esp,%ebp
  800735:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800738:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80073b:	50                   	push   %eax
  80073c:	ff 75 10             	pushl  0x10(%ebp)
  80073f:	ff 75 0c             	pushl  0xc(%ebp)
  800742:	ff 75 08             	pushl  0x8(%ebp)
  800745:	e8 92 ff ff ff       	call   8006dc <vsnprintf>
	va_end(ap);

	return rc;
}
  80074a:	c9                   	leave  
  80074b:	c3                   	ret    

0080074c <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80074c:	f3 0f 1e fb          	endbr32 
  800750:	55                   	push   %ebp
  800751:	89 e5                	mov    %esp,%ebp
  800753:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800756:	b8 00 00 00 00       	mov    $0x0,%eax
  80075b:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  80075f:	74 05                	je     800766 <strlen+0x1a>
		n++;
  800761:	83 c0 01             	add    $0x1,%eax
  800764:	eb f5                	jmp    80075b <strlen+0xf>
	return n;
}
  800766:	5d                   	pop    %ebp
  800767:	c3                   	ret    

00800768 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800768:	f3 0f 1e fb          	endbr32 
  80076c:	55                   	push   %ebp
  80076d:	89 e5                	mov    %esp,%ebp
  80076f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800772:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800775:	b8 00 00 00 00       	mov    $0x0,%eax
  80077a:	39 d0                	cmp    %edx,%eax
  80077c:	74 0d                	je     80078b <strnlen+0x23>
  80077e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800782:	74 05                	je     800789 <strnlen+0x21>
		n++;
  800784:	83 c0 01             	add    $0x1,%eax
  800787:	eb f1                	jmp    80077a <strnlen+0x12>
  800789:	89 c2                	mov    %eax,%edx
	return n;
}
  80078b:	89 d0                	mov    %edx,%eax
  80078d:	5d                   	pop    %ebp
  80078e:	c3                   	ret    

0080078f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  80078f:	f3 0f 1e fb          	endbr32 
  800793:	55                   	push   %ebp
  800794:	89 e5                	mov    %esp,%ebp
  800796:	53                   	push   %ebx
  800797:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80079a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80079d:	b8 00 00 00 00       	mov    $0x0,%eax
  8007a2:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8007a6:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8007a9:	83 c0 01             	add    $0x1,%eax
  8007ac:	84 d2                	test   %dl,%dl
  8007ae:	75 f2                	jne    8007a2 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8007b0:	89 c8                	mov    %ecx,%eax
  8007b2:	5b                   	pop    %ebx
  8007b3:	5d                   	pop    %ebp
  8007b4:	c3                   	ret    

008007b5 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8007b5:	f3 0f 1e fb          	endbr32 
  8007b9:	55                   	push   %ebp
  8007ba:	89 e5                	mov    %esp,%ebp
  8007bc:	53                   	push   %ebx
  8007bd:	83 ec 10             	sub    $0x10,%esp
  8007c0:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8007c3:	53                   	push   %ebx
  8007c4:	e8 83 ff ff ff       	call   80074c <strlen>
  8007c9:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8007cc:	ff 75 0c             	pushl  0xc(%ebp)
  8007cf:	01 d8                	add    %ebx,%eax
  8007d1:	50                   	push   %eax
  8007d2:	e8 b8 ff ff ff       	call   80078f <strcpy>
	return dst;
}
  8007d7:	89 d8                	mov    %ebx,%eax
  8007d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007dc:	c9                   	leave  
  8007dd:	c3                   	ret    

008007de <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8007de:	f3 0f 1e fb          	endbr32 
  8007e2:	55                   	push   %ebp
  8007e3:	89 e5                	mov    %esp,%ebp
  8007e5:	56                   	push   %esi
  8007e6:	53                   	push   %ebx
  8007e7:	8b 75 08             	mov    0x8(%ebp),%esi
  8007ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ed:	89 f3                	mov    %esi,%ebx
  8007ef:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8007f2:	89 f0                	mov    %esi,%eax
  8007f4:	39 d8                	cmp    %ebx,%eax
  8007f6:	74 11                	je     800809 <strncpy+0x2b>
		*dst++ = *src;
  8007f8:	83 c0 01             	add    $0x1,%eax
  8007fb:	0f b6 0a             	movzbl (%edx),%ecx
  8007fe:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800801:	80 f9 01             	cmp    $0x1,%cl
  800804:	83 da ff             	sbb    $0xffffffff,%edx
  800807:	eb eb                	jmp    8007f4 <strncpy+0x16>
	}
	return ret;
}
  800809:	89 f0                	mov    %esi,%eax
  80080b:	5b                   	pop    %ebx
  80080c:	5e                   	pop    %esi
  80080d:	5d                   	pop    %ebp
  80080e:	c3                   	ret    

0080080f <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80080f:	f3 0f 1e fb          	endbr32 
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	56                   	push   %esi
  800817:	53                   	push   %ebx
  800818:	8b 75 08             	mov    0x8(%ebp),%esi
  80081b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80081e:	8b 55 10             	mov    0x10(%ebp),%edx
  800821:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800823:	85 d2                	test   %edx,%edx
  800825:	74 21                	je     800848 <strlcpy+0x39>
  800827:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80082b:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80082d:	39 c2                	cmp    %eax,%edx
  80082f:	74 14                	je     800845 <strlcpy+0x36>
  800831:	0f b6 19             	movzbl (%ecx),%ebx
  800834:	84 db                	test   %bl,%bl
  800836:	74 0b                	je     800843 <strlcpy+0x34>
			*dst++ = *src++;
  800838:	83 c1 01             	add    $0x1,%ecx
  80083b:	83 c2 01             	add    $0x1,%edx
  80083e:	88 5a ff             	mov    %bl,-0x1(%edx)
  800841:	eb ea                	jmp    80082d <strlcpy+0x1e>
  800843:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800845:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800848:	29 f0                	sub    %esi,%eax
}
  80084a:	5b                   	pop    %ebx
  80084b:	5e                   	pop    %esi
  80084c:	5d                   	pop    %ebp
  80084d:	c3                   	ret    

0080084e <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80084e:	f3 0f 1e fb          	endbr32 
  800852:	55                   	push   %ebp
  800853:	89 e5                	mov    %esp,%ebp
  800855:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800858:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80085b:	0f b6 01             	movzbl (%ecx),%eax
  80085e:	84 c0                	test   %al,%al
  800860:	74 0c                	je     80086e <strcmp+0x20>
  800862:	3a 02                	cmp    (%edx),%al
  800864:	75 08                	jne    80086e <strcmp+0x20>
		p++, q++;
  800866:	83 c1 01             	add    $0x1,%ecx
  800869:	83 c2 01             	add    $0x1,%edx
  80086c:	eb ed                	jmp    80085b <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80086e:	0f b6 c0             	movzbl %al,%eax
  800871:	0f b6 12             	movzbl (%edx),%edx
  800874:	29 d0                	sub    %edx,%eax
}
  800876:	5d                   	pop    %ebp
  800877:	c3                   	ret    

00800878 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800878:	f3 0f 1e fb          	endbr32 
  80087c:	55                   	push   %ebp
  80087d:	89 e5                	mov    %esp,%ebp
  80087f:	53                   	push   %ebx
  800880:	8b 45 08             	mov    0x8(%ebp),%eax
  800883:	8b 55 0c             	mov    0xc(%ebp),%edx
  800886:	89 c3                	mov    %eax,%ebx
  800888:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80088b:	eb 06                	jmp    800893 <strncmp+0x1b>
		n--, p++, q++;
  80088d:	83 c0 01             	add    $0x1,%eax
  800890:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800893:	39 d8                	cmp    %ebx,%eax
  800895:	74 16                	je     8008ad <strncmp+0x35>
  800897:	0f b6 08             	movzbl (%eax),%ecx
  80089a:	84 c9                	test   %cl,%cl
  80089c:	74 04                	je     8008a2 <strncmp+0x2a>
  80089e:	3a 0a                	cmp    (%edx),%cl
  8008a0:	74 eb                	je     80088d <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8008a2:	0f b6 00             	movzbl (%eax),%eax
  8008a5:	0f b6 12             	movzbl (%edx),%edx
  8008a8:	29 d0                	sub    %edx,%eax
}
  8008aa:	5b                   	pop    %ebx
  8008ab:	5d                   	pop    %ebp
  8008ac:	c3                   	ret    
		return 0;
  8008ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8008b2:	eb f6                	jmp    8008aa <strncmp+0x32>

008008b4 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8008b4:	f3 0f 1e fb          	endbr32 
  8008b8:	55                   	push   %ebp
  8008b9:	89 e5                	mov    %esp,%ebp
  8008bb:	8b 45 08             	mov    0x8(%ebp),%eax
  8008be:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008c2:	0f b6 10             	movzbl (%eax),%edx
  8008c5:	84 d2                	test   %dl,%dl
  8008c7:	74 09                	je     8008d2 <strchr+0x1e>
		if (*s == c)
  8008c9:	38 ca                	cmp    %cl,%dl
  8008cb:	74 0a                	je     8008d7 <strchr+0x23>
	for (; *s; s++)
  8008cd:	83 c0 01             	add    $0x1,%eax
  8008d0:	eb f0                	jmp    8008c2 <strchr+0xe>
			return (char *) s;
	return 0;
  8008d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8008d7:	5d                   	pop    %ebp
  8008d8:	c3                   	ret    

008008d9 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8008d9:	f3 0f 1e fb          	endbr32 
  8008dd:	55                   	push   %ebp
  8008de:	89 e5                	mov    %esp,%ebp
  8008e0:	8b 45 08             	mov    0x8(%ebp),%eax
  8008e3:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8008e7:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8008ea:	38 ca                	cmp    %cl,%dl
  8008ec:	74 09                	je     8008f7 <strfind+0x1e>
  8008ee:	84 d2                	test   %dl,%dl
  8008f0:	74 05                	je     8008f7 <strfind+0x1e>
	for (; *s; s++)
  8008f2:	83 c0 01             	add    $0x1,%eax
  8008f5:	eb f0                	jmp    8008e7 <strfind+0xe>
			break;
	return (char *) s;
}
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8008f9:	f3 0f 1e fb          	endbr32 
  8008fd:	55                   	push   %ebp
  8008fe:	89 e5                	mov    %esp,%ebp
  800900:	57                   	push   %edi
  800901:	56                   	push   %esi
  800902:	53                   	push   %ebx
  800903:	8b 55 08             	mov    0x8(%ebp),%edx
  800906:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800909:	85 c9                	test   %ecx,%ecx
  80090b:	74 33                	je     800940 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80090d:	89 d0                	mov    %edx,%eax
  80090f:	09 c8                	or     %ecx,%eax
  800911:	a8 03                	test   $0x3,%al
  800913:	75 23                	jne    800938 <memset+0x3f>
		c &= 0xFF;
  800915:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800919:	89 d8                	mov    %ebx,%eax
  80091b:	c1 e0 08             	shl    $0x8,%eax
  80091e:	89 df                	mov    %ebx,%edi
  800920:	c1 e7 18             	shl    $0x18,%edi
  800923:	89 de                	mov    %ebx,%esi
  800925:	c1 e6 10             	shl    $0x10,%esi
  800928:	09 f7                	or     %esi,%edi
  80092a:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  80092c:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80092f:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800931:	89 d7                	mov    %edx,%edi
  800933:	fc                   	cld    
  800934:	f3 ab                	rep stos %eax,%es:(%edi)
  800936:	eb 08                	jmp    800940 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800938:	89 d7                	mov    %edx,%edi
  80093a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80093d:	fc                   	cld    
  80093e:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800940:	89 d0                	mov    %edx,%eax
  800942:	5b                   	pop    %ebx
  800943:	5e                   	pop    %esi
  800944:	5f                   	pop    %edi
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    

00800947 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800947:	f3 0f 1e fb          	endbr32 
  80094b:	55                   	push   %ebp
  80094c:	89 e5                	mov    %esp,%ebp
  80094e:	57                   	push   %edi
  80094f:	56                   	push   %esi
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	8b 75 0c             	mov    0xc(%ebp),%esi
  800956:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800959:	39 c6                	cmp    %eax,%esi
  80095b:	73 32                	jae    80098f <memmove+0x48>
  80095d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800960:	39 c2                	cmp    %eax,%edx
  800962:	76 2b                	jbe    80098f <memmove+0x48>
		s += n;
		d += n;
  800964:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800967:	89 fe                	mov    %edi,%esi
  800969:	09 ce                	or     %ecx,%esi
  80096b:	09 d6                	or     %edx,%esi
  80096d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800973:	75 0e                	jne    800983 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800975:	83 ef 04             	sub    $0x4,%edi
  800978:	8d 72 fc             	lea    -0x4(%edx),%esi
  80097b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  80097e:	fd                   	std    
  80097f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800981:	eb 09                	jmp    80098c <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800983:	83 ef 01             	sub    $0x1,%edi
  800986:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800989:	fd                   	std    
  80098a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80098c:	fc                   	cld    
  80098d:	eb 1a                	jmp    8009a9 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80098f:	89 c2                	mov    %eax,%edx
  800991:	09 ca                	or     %ecx,%edx
  800993:	09 f2                	or     %esi,%edx
  800995:	f6 c2 03             	test   $0x3,%dl
  800998:	75 0a                	jne    8009a4 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80099a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80099d:	89 c7                	mov    %eax,%edi
  80099f:	fc                   	cld    
  8009a0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8009a2:	eb 05                	jmp    8009a9 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8009a4:	89 c7                	mov    %eax,%edi
  8009a6:	fc                   	cld    
  8009a7:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8009a9:	5e                   	pop    %esi
  8009aa:	5f                   	pop    %edi
  8009ab:	5d                   	pop    %ebp
  8009ac:	c3                   	ret    

008009ad <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8009ad:	f3 0f 1e fb          	endbr32 
  8009b1:	55                   	push   %ebp
  8009b2:	89 e5                	mov    %esp,%ebp
  8009b4:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8009b7:	ff 75 10             	pushl  0x10(%ebp)
  8009ba:	ff 75 0c             	pushl  0xc(%ebp)
  8009bd:	ff 75 08             	pushl  0x8(%ebp)
  8009c0:	e8 82 ff ff ff       	call   800947 <memmove>
}
  8009c5:	c9                   	leave  
  8009c6:	c3                   	ret    

008009c7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8009c7:	f3 0f 1e fb          	endbr32 
  8009cb:	55                   	push   %ebp
  8009cc:	89 e5                	mov    %esp,%ebp
  8009ce:	56                   	push   %esi
  8009cf:	53                   	push   %ebx
  8009d0:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009d6:	89 c6                	mov    %eax,%esi
  8009d8:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8009db:	39 f0                	cmp    %esi,%eax
  8009dd:	74 1c                	je     8009fb <memcmp+0x34>
		if (*s1 != *s2)
  8009df:	0f b6 08             	movzbl (%eax),%ecx
  8009e2:	0f b6 1a             	movzbl (%edx),%ebx
  8009e5:	38 d9                	cmp    %bl,%cl
  8009e7:	75 08                	jne    8009f1 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8009e9:	83 c0 01             	add    $0x1,%eax
  8009ec:	83 c2 01             	add    $0x1,%edx
  8009ef:	eb ea                	jmp    8009db <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8009f1:	0f b6 c1             	movzbl %cl,%eax
  8009f4:	0f b6 db             	movzbl %bl,%ebx
  8009f7:	29 d8                	sub    %ebx,%eax
  8009f9:	eb 05                	jmp    800a00 <memcmp+0x39>
	}

	return 0;
  8009fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a00:	5b                   	pop    %ebx
  800a01:	5e                   	pop    %esi
  800a02:	5d                   	pop    %ebp
  800a03:	c3                   	ret    

00800a04 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a04:	f3 0f 1e fb          	endbr32 
  800a08:	55                   	push   %ebp
  800a09:	89 e5                	mov    %esp,%ebp
  800a0b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a0e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800a11:	89 c2                	mov    %eax,%edx
  800a13:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800a16:	39 d0                	cmp    %edx,%eax
  800a18:	73 09                	jae    800a23 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800a1a:	38 08                	cmp    %cl,(%eax)
  800a1c:	74 05                	je     800a23 <memfind+0x1f>
	for (; s < ends; s++)
  800a1e:	83 c0 01             	add    $0x1,%eax
  800a21:	eb f3                	jmp    800a16 <memfind+0x12>
			break;
	return (void *) s;
}
  800a23:	5d                   	pop    %ebp
  800a24:	c3                   	ret    

00800a25 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800a25:	f3 0f 1e fb          	endbr32 
  800a29:	55                   	push   %ebp
  800a2a:	89 e5                	mov    %esp,%ebp
  800a2c:	57                   	push   %edi
  800a2d:	56                   	push   %esi
  800a2e:	53                   	push   %ebx
  800a2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a32:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800a35:	eb 03                	jmp    800a3a <strtol+0x15>
		s++;
  800a37:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800a3a:	0f b6 01             	movzbl (%ecx),%eax
  800a3d:	3c 20                	cmp    $0x20,%al
  800a3f:	74 f6                	je     800a37 <strtol+0x12>
  800a41:	3c 09                	cmp    $0x9,%al
  800a43:	74 f2                	je     800a37 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800a45:	3c 2b                	cmp    $0x2b,%al
  800a47:	74 2a                	je     800a73 <strtol+0x4e>
	int neg = 0;
  800a49:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800a4e:	3c 2d                	cmp    $0x2d,%al
  800a50:	74 2b                	je     800a7d <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a52:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800a58:	75 0f                	jne    800a69 <strtol+0x44>
  800a5a:	80 39 30             	cmpb   $0x30,(%ecx)
  800a5d:	74 28                	je     800a87 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800a5f:	85 db                	test   %ebx,%ebx
  800a61:	b8 0a 00 00 00       	mov    $0xa,%eax
  800a66:	0f 44 d8             	cmove  %eax,%ebx
  800a69:	b8 00 00 00 00       	mov    $0x0,%eax
  800a6e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800a71:	eb 46                	jmp    800ab9 <strtol+0x94>
		s++;
  800a73:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800a76:	bf 00 00 00 00       	mov    $0x0,%edi
  800a7b:	eb d5                	jmp    800a52 <strtol+0x2d>
		s++, neg = 1;
  800a7d:	83 c1 01             	add    $0x1,%ecx
  800a80:	bf 01 00 00 00       	mov    $0x1,%edi
  800a85:	eb cb                	jmp    800a52 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800a87:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800a8b:	74 0e                	je     800a9b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800a8d:	85 db                	test   %ebx,%ebx
  800a8f:	75 d8                	jne    800a69 <strtol+0x44>
		s++, base = 8;
  800a91:	83 c1 01             	add    $0x1,%ecx
  800a94:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a99:	eb ce                	jmp    800a69 <strtol+0x44>
		s += 2, base = 16;
  800a9b:	83 c1 02             	add    $0x2,%ecx
  800a9e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800aa3:	eb c4                	jmp    800a69 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800aa5:	0f be d2             	movsbl %dl,%edx
  800aa8:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800aab:	3b 55 10             	cmp    0x10(%ebp),%edx
  800aae:	7d 3a                	jge    800aea <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800ab0:	83 c1 01             	add    $0x1,%ecx
  800ab3:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ab7:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800ab9:	0f b6 11             	movzbl (%ecx),%edx
  800abc:	8d 72 d0             	lea    -0x30(%edx),%esi
  800abf:	89 f3                	mov    %esi,%ebx
  800ac1:	80 fb 09             	cmp    $0x9,%bl
  800ac4:	76 df                	jbe    800aa5 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800ac6:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ac9:	89 f3                	mov    %esi,%ebx
  800acb:	80 fb 19             	cmp    $0x19,%bl
  800ace:	77 08                	ja     800ad8 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800ad0:	0f be d2             	movsbl %dl,%edx
  800ad3:	83 ea 57             	sub    $0x57,%edx
  800ad6:	eb d3                	jmp    800aab <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800ad8:	8d 72 bf             	lea    -0x41(%edx),%esi
  800adb:	89 f3                	mov    %esi,%ebx
  800add:	80 fb 19             	cmp    $0x19,%bl
  800ae0:	77 08                	ja     800aea <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ae2:	0f be d2             	movsbl %dl,%edx
  800ae5:	83 ea 37             	sub    $0x37,%edx
  800ae8:	eb c1                	jmp    800aab <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800aea:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800aee:	74 05                	je     800af5 <strtol+0xd0>
		*endptr = (char *) s;
  800af0:	8b 75 0c             	mov    0xc(%ebp),%esi
  800af3:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800af5:	89 c2                	mov    %eax,%edx
  800af7:	f7 da                	neg    %edx
  800af9:	85 ff                	test   %edi,%edi
  800afb:	0f 45 c2             	cmovne %edx,%eax
}
  800afe:	5b                   	pop    %ebx
  800aff:	5e                   	pop    %esi
  800b00:	5f                   	pop    %edi
  800b01:	5d                   	pop    %ebp
  800b02:	c3                   	ret    

00800b03 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b03:	55                   	push   %ebp
  800b04:	89 e5                	mov    %esp,%ebp
  800b06:	57                   	push   %edi
  800b07:	56                   	push   %esi
  800b08:	53                   	push   %ebx
  800b09:	83 ec 1c             	sub    $0x1c,%esp
  800b0c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800b0f:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800b12:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800b14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b17:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800b1a:	8b 7d 10             	mov    0x10(%ebp),%edi
  800b1d:	8b 75 14             	mov    0x14(%ebp),%esi
  800b20:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800b22:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800b26:	74 04                	je     800b2c <syscall+0x29>
  800b28:	85 c0                	test   %eax,%eax
  800b2a:	7f 08                	jg     800b34 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800b2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800b2f:	5b                   	pop    %ebx
  800b30:	5e                   	pop    %esi
  800b31:	5f                   	pop    %edi
  800b32:	5d                   	pop    %ebp
  800b33:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800b34:	83 ec 0c             	sub    $0xc,%esp
  800b37:	50                   	push   %eax
  800b38:	ff 75 e0             	pushl  -0x20(%ebp)
  800b3b:	68 7f 22 80 00       	push   $0x80227f
  800b40:	6a 23                	push   $0x23
  800b42:	68 9c 22 80 00       	push   $0x80229c
  800b47:	e8 f2 f5 ff ff       	call   80013e <_panic>

00800b4c <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800b4c:	f3 0f 1e fb          	endbr32 
  800b50:	55                   	push   %ebp
  800b51:	89 e5                	mov    %esp,%ebp
  800b53:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800b56:	6a 00                	push   $0x0
  800b58:	6a 00                	push   $0x0
  800b5a:	6a 00                	push   $0x0
  800b5c:	ff 75 0c             	pushl  0xc(%ebp)
  800b5f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b62:	ba 00 00 00 00       	mov    $0x0,%edx
  800b67:	b8 00 00 00 00       	mov    $0x0,%eax
  800b6c:	e8 92 ff ff ff       	call   800b03 <syscall>
}
  800b71:	83 c4 10             	add    $0x10,%esp
  800b74:	c9                   	leave  
  800b75:	c3                   	ret    

00800b76 <sys_cgetc>:

int
sys_cgetc(void)
{
  800b76:	f3 0f 1e fb          	endbr32 
  800b7a:	55                   	push   %ebp
  800b7b:	89 e5                	mov    %esp,%ebp
  800b7d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800b80:	6a 00                	push   $0x0
  800b82:	6a 00                	push   $0x0
  800b84:	6a 00                	push   $0x0
  800b86:	6a 00                	push   $0x0
  800b88:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b8d:	ba 00 00 00 00       	mov    $0x0,%edx
  800b92:	b8 01 00 00 00       	mov    $0x1,%eax
  800b97:	e8 67 ff ff ff       	call   800b03 <syscall>
}
  800b9c:	c9                   	leave  
  800b9d:	c3                   	ret    

00800b9e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b9e:	f3 0f 1e fb          	endbr32 
  800ba2:	55                   	push   %ebp
  800ba3:	89 e5                	mov    %esp,%ebp
  800ba5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800ba8:	6a 00                	push   $0x0
  800baa:	6a 00                	push   $0x0
  800bac:	6a 00                	push   $0x0
  800bae:	6a 00                	push   $0x0
  800bb0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bb3:	ba 01 00 00 00       	mov    $0x1,%edx
  800bb8:	b8 03 00 00 00       	mov    $0x3,%eax
  800bbd:	e8 41 ff ff ff       	call   800b03 <syscall>
}
  800bc2:	c9                   	leave  
  800bc3:	c3                   	ret    

00800bc4 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800bc4:	f3 0f 1e fb          	endbr32 
  800bc8:	55                   	push   %ebp
  800bc9:	89 e5                	mov    %esp,%ebp
  800bcb:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800bce:	6a 00                	push   $0x0
  800bd0:	6a 00                	push   $0x0
  800bd2:	6a 00                	push   $0x0
  800bd4:	6a 00                	push   $0x0
  800bd6:	b9 00 00 00 00       	mov    $0x0,%ecx
  800bdb:	ba 00 00 00 00       	mov    $0x0,%edx
  800be0:	b8 02 00 00 00       	mov    $0x2,%eax
  800be5:	e8 19 ff ff ff       	call   800b03 <syscall>
}
  800bea:	c9                   	leave  
  800beb:	c3                   	ret    

00800bec <sys_yield>:

void
sys_yield(void)
{
  800bec:	f3 0f 1e fb          	endbr32 
  800bf0:	55                   	push   %ebp
  800bf1:	89 e5                	mov    %esp,%ebp
  800bf3:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800bf6:	6a 00                	push   $0x0
  800bf8:	6a 00                	push   $0x0
  800bfa:	6a 00                	push   $0x0
  800bfc:	6a 00                	push   $0x0
  800bfe:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c03:	ba 00 00 00 00       	mov    $0x0,%edx
  800c08:	b8 0b 00 00 00       	mov    $0xb,%eax
  800c0d:	e8 f1 fe ff ff       	call   800b03 <syscall>
}
  800c12:	83 c4 10             	add    $0x10,%esp
  800c15:	c9                   	leave  
  800c16:	c3                   	ret    

00800c17 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800c17:	f3 0f 1e fb          	endbr32 
  800c1b:	55                   	push   %ebp
  800c1c:	89 e5                	mov    %esp,%ebp
  800c1e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800c21:	6a 00                	push   $0x0
  800c23:	6a 00                	push   $0x0
  800c25:	ff 75 10             	pushl  0x10(%ebp)
  800c28:	ff 75 0c             	pushl  0xc(%ebp)
  800c2b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c2e:	ba 01 00 00 00       	mov    $0x1,%edx
  800c33:	b8 04 00 00 00       	mov    $0x4,%eax
  800c38:	e8 c6 fe ff ff       	call   800b03 <syscall>
}
  800c3d:	c9                   	leave  
  800c3e:	c3                   	ret    

00800c3f <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800c3f:	f3 0f 1e fb          	endbr32 
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800c49:	ff 75 18             	pushl  0x18(%ebp)
  800c4c:	ff 75 14             	pushl  0x14(%ebp)
  800c4f:	ff 75 10             	pushl  0x10(%ebp)
  800c52:	ff 75 0c             	pushl  0xc(%ebp)
  800c55:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c58:	ba 01 00 00 00       	mov    $0x1,%edx
  800c5d:	b8 05 00 00 00       	mov    $0x5,%eax
  800c62:	e8 9c fe ff ff       	call   800b03 <syscall>
}
  800c67:	c9                   	leave  
  800c68:	c3                   	ret    

00800c69 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800c69:	f3 0f 1e fb          	endbr32 
  800c6d:	55                   	push   %ebp
  800c6e:	89 e5                	mov    %esp,%ebp
  800c70:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800c73:	6a 00                	push   $0x0
  800c75:	6a 00                	push   $0x0
  800c77:	6a 00                	push   $0x0
  800c79:	ff 75 0c             	pushl  0xc(%ebp)
  800c7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7f:	ba 01 00 00 00       	mov    $0x1,%edx
  800c84:	b8 06 00 00 00       	mov    $0x6,%eax
  800c89:	e8 75 fe ff ff       	call   800b03 <syscall>
}
  800c8e:	c9                   	leave  
  800c8f:	c3                   	ret    

00800c90 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800c90:	f3 0f 1e fb          	endbr32 
  800c94:	55                   	push   %ebp
  800c95:	89 e5                	mov    %esp,%ebp
  800c97:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c9a:	6a 00                	push   $0x0
  800c9c:	6a 00                	push   $0x0
  800c9e:	6a 00                	push   $0x0
  800ca0:	ff 75 0c             	pushl  0xc(%ebp)
  800ca3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ca6:	ba 01 00 00 00       	mov    $0x1,%edx
  800cab:	b8 08 00 00 00       	mov    $0x8,%eax
  800cb0:	e8 4e fe ff ff       	call   800b03 <syscall>
}
  800cb5:	c9                   	leave  
  800cb6:	c3                   	ret    

00800cb7 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800cb7:	f3 0f 1e fb          	endbr32 
  800cbb:	55                   	push   %ebp
  800cbc:	89 e5                	mov    %esp,%ebp
  800cbe:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800cc1:	6a 00                	push   $0x0
  800cc3:	6a 00                	push   $0x0
  800cc5:	6a 00                	push   $0x0
  800cc7:	ff 75 0c             	pushl  0xc(%ebp)
  800cca:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ccd:	ba 01 00 00 00       	mov    $0x1,%edx
  800cd2:	b8 09 00 00 00       	mov    $0x9,%eax
  800cd7:	e8 27 fe ff ff       	call   800b03 <syscall>
}
  800cdc:	c9                   	leave  
  800cdd:	c3                   	ret    

00800cde <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800cde:	f3 0f 1e fb          	endbr32 
  800ce2:	55                   	push   %ebp
  800ce3:	89 e5                	mov    %esp,%ebp
  800ce5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800ce8:	6a 00                	push   $0x0
  800cea:	6a 00                	push   $0x0
  800cec:	6a 00                	push   $0x0
  800cee:	ff 75 0c             	pushl  0xc(%ebp)
  800cf1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf4:	ba 01 00 00 00       	mov    $0x1,%edx
  800cf9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800cfe:	e8 00 fe ff ff       	call   800b03 <syscall>
}
  800d03:	c9                   	leave  
  800d04:	c3                   	ret    

00800d05 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d05:	f3 0f 1e fb          	endbr32 
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800d0f:	6a 00                	push   $0x0
  800d11:	ff 75 14             	pushl  0x14(%ebp)
  800d14:	ff 75 10             	pushl  0x10(%ebp)
  800d17:	ff 75 0c             	pushl  0xc(%ebp)
  800d1a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d1d:	ba 00 00 00 00       	mov    $0x0,%edx
  800d22:	b8 0c 00 00 00       	mov    $0xc,%eax
  800d27:	e8 d7 fd ff ff       	call   800b03 <syscall>
}
  800d2c:	c9                   	leave  
  800d2d:	c3                   	ret    

00800d2e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800d2e:	f3 0f 1e fb          	endbr32 
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800d38:	6a 00                	push   $0x0
  800d3a:	6a 00                	push   $0x0
  800d3c:	6a 00                	push   $0x0
  800d3e:	6a 00                	push   $0x0
  800d40:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d43:	ba 01 00 00 00       	mov    $0x1,%edx
  800d48:	b8 0d 00 00 00       	mov    $0xd,%eax
  800d4d:	e8 b1 fd ff ff       	call   800b03 <syscall>
}
  800d52:	c9                   	leave  
  800d53:	c3                   	ret    

00800d54 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  800d54:	f3 0f 1e fb          	endbr32 
  800d58:	55                   	push   %ebp
  800d59:	89 e5                	mov    %esp,%ebp
  800d5b:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  800d5e:	83 3d 08 40 80 00 00 	cmpl   $0x0,0x804008
  800d65:	74 1c                	je     800d83 <set_pgfault_handler+0x2f>
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  800d67:	8b 45 08             	mov    0x8(%ebp),%eax
  800d6a:	a3 08 40 80 00       	mov    %eax,0x804008

	//Indicarle al kerne que _pgfault_upcall va a ser el manejador de pgfaults de un proceso
	sys_env_set_pgfault_upcall(0, &(_pgfault_upcall));
  800d6f:	83 ec 08             	sub    $0x8,%esp
  800d72:	68 af 0d 80 00       	push   $0x800daf
  800d77:	6a 00                	push   $0x0
  800d79:	e8 60 ff ff ff       	call   800cde <sys_env_set_pgfault_upcall>
}
  800d7e:	83 c4 10             	add    $0x10,%esp
  800d81:	c9                   	leave  
  800d82:	c3                   	ret    
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
  800d83:	83 ec 04             	sub    $0x4,%esp
  800d86:	6a 02                	push   $0x2
  800d88:	68 00 f0 bf ee       	push   $0xeebff000
  800d8d:	6a 00                	push   $0x0
  800d8f:	e8 83 fe ff ff       	call   800c17 <sys_page_alloc>
  800d94:	83 c4 10             	add    $0x10,%esp
  800d97:	85 c0                	test   %eax,%eax
  800d99:	79 cc                	jns    800d67 <set_pgfault_handler+0x13>
  800d9b:	83 ec 04             	sub    $0x4,%esp
  800d9e:	68 aa 22 80 00       	push   $0x8022aa
  800da3:	6a 20                	push   $0x20
  800da5:	68 c5 22 80 00       	push   $0x8022c5
  800daa:	e8 8f f3 ff ff       	call   80013e <_panic>

00800daf <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  800daf:	54                   	push   %esp
	movl _pgfault_handler, %eax
  800db0:	a1 08 40 80 00       	mov    0x804008,%eax
	call *%eax
  800db5:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  800db7:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 40(%esp), %eax
  800dba:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	
  800dbe:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  800dc2:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, (%ebx)
  800dc5:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 48(%esp)
  800dc7:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  800dcb:	83 c4 08             	add    $0x8,%esp
	popal
  800dce:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  800dcf:	83 c4 04             	add    $0x4,%esp
	popfl
  800dd2:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  800dd3:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  800dd6:	c3                   	ret    

00800dd7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800dd7:	f3 0f 1e fb          	endbr32 
  800ddb:	55                   	push   %ebp
  800ddc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800dde:	8b 45 08             	mov    0x8(%ebp),%eax
  800de1:	05 00 00 00 30       	add    $0x30000000,%eax
  800de6:	c1 e8 0c             	shr    $0xc,%eax
}
  800de9:	5d                   	pop    %ebp
  800dea:	c3                   	ret    

00800deb <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800deb:	f3 0f 1e fb          	endbr32 
  800def:	55                   	push   %ebp
  800df0:	89 e5                	mov    %esp,%ebp
  800df2:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800df5:	ff 75 08             	pushl  0x8(%ebp)
  800df8:	e8 da ff ff ff       	call   800dd7 <fd2num>
  800dfd:	83 c4 10             	add    $0x10,%esp
  800e00:	c1 e0 0c             	shl    $0xc,%eax
  800e03:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800e08:	c9                   	leave  
  800e09:	c3                   	ret    

00800e0a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800e0a:	f3 0f 1e fb          	endbr32 
  800e0e:	55                   	push   %ebp
  800e0f:	89 e5                	mov    %esp,%ebp
  800e11:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800e16:	89 c2                	mov    %eax,%edx
  800e18:	c1 ea 16             	shr    $0x16,%edx
  800e1b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800e22:	f6 c2 01             	test   $0x1,%dl
  800e25:	74 2d                	je     800e54 <fd_alloc+0x4a>
  800e27:	89 c2                	mov    %eax,%edx
  800e29:	c1 ea 0c             	shr    $0xc,%edx
  800e2c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e33:	f6 c2 01             	test   $0x1,%dl
  800e36:	74 1c                	je     800e54 <fd_alloc+0x4a>
  800e38:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800e3d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800e42:	75 d2                	jne    800e16 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800e44:	8b 45 08             	mov    0x8(%ebp),%eax
  800e47:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800e4d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800e52:	eb 0a                	jmp    800e5e <fd_alloc+0x54>
			*fd_store = fd;
  800e54:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e57:	89 01                	mov    %eax,(%ecx)
			return 0;
  800e59:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e5e:	5d                   	pop    %ebp
  800e5f:	c3                   	ret    

00800e60 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800e60:	f3 0f 1e fb          	endbr32 
  800e64:	55                   	push   %ebp
  800e65:	89 e5                	mov    %esp,%ebp
  800e67:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800e6a:	83 f8 1f             	cmp    $0x1f,%eax
  800e6d:	77 30                	ja     800e9f <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800e6f:	c1 e0 0c             	shl    $0xc,%eax
  800e72:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800e77:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800e7d:	f6 c2 01             	test   $0x1,%dl
  800e80:	74 24                	je     800ea6 <fd_lookup+0x46>
  800e82:	89 c2                	mov    %eax,%edx
  800e84:	c1 ea 0c             	shr    $0xc,%edx
  800e87:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800e8e:	f6 c2 01             	test   $0x1,%dl
  800e91:	74 1a                	je     800ead <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800e93:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e96:	89 02                	mov    %eax,(%edx)
	return 0;
  800e98:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    
		return -E_INVAL;
  800e9f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ea4:	eb f7                	jmp    800e9d <fd_lookup+0x3d>
		return -E_INVAL;
  800ea6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eab:	eb f0                	jmp    800e9d <fd_lookup+0x3d>
  800ead:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800eb2:	eb e9                	jmp    800e9d <fd_lookup+0x3d>

00800eb4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800eb4:	f3 0f 1e fb          	endbr32 
  800eb8:	55                   	push   %ebp
  800eb9:	89 e5                	mov    %esp,%ebp
  800ebb:	83 ec 08             	sub    $0x8,%esp
  800ebe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ec1:	ba 50 23 80 00       	mov    $0x802350,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800ec6:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800ecb:	39 08                	cmp    %ecx,(%eax)
  800ecd:	74 33                	je     800f02 <dev_lookup+0x4e>
  800ecf:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800ed2:	8b 02                	mov    (%edx),%eax
  800ed4:	85 c0                	test   %eax,%eax
  800ed6:	75 f3                	jne    800ecb <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800ed8:	a1 04 40 80 00       	mov    0x804004,%eax
  800edd:	8b 40 48             	mov    0x48(%eax),%eax
  800ee0:	83 ec 04             	sub    $0x4,%esp
  800ee3:	51                   	push   %ecx
  800ee4:	50                   	push   %eax
  800ee5:	68 d4 22 80 00       	push   $0x8022d4
  800eea:	e8 36 f3 ff ff       	call   800225 <cprintf>
	*dev = 0;
  800eef:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800ef8:	83 c4 10             	add    $0x10,%esp
  800efb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800f00:	c9                   	leave  
  800f01:	c3                   	ret    
			*dev = devtab[i];
  800f02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800f05:	89 01                	mov    %eax,(%ecx)
			return 0;
  800f07:	b8 00 00 00 00       	mov    $0x0,%eax
  800f0c:	eb f2                	jmp    800f00 <dev_lookup+0x4c>

00800f0e <fd_close>:
{
  800f0e:	f3 0f 1e fb          	endbr32 
  800f12:	55                   	push   %ebp
  800f13:	89 e5                	mov    %esp,%ebp
  800f15:	57                   	push   %edi
  800f16:	56                   	push   %esi
  800f17:	53                   	push   %ebx
  800f18:	83 ec 28             	sub    $0x28,%esp
  800f1b:	8b 75 08             	mov    0x8(%ebp),%esi
  800f1e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800f21:	56                   	push   %esi
  800f22:	e8 b0 fe ff ff       	call   800dd7 <fd2num>
  800f27:	83 c4 08             	add    $0x8,%esp
  800f2a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800f2d:	52                   	push   %edx
  800f2e:	50                   	push   %eax
  800f2f:	e8 2c ff ff ff       	call   800e60 <fd_lookup>
  800f34:	89 c3                	mov    %eax,%ebx
  800f36:	83 c4 10             	add    $0x10,%esp
  800f39:	85 c0                	test   %eax,%eax
  800f3b:	78 05                	js     800f42 <fd_close+0x34>
	    || fd != fd2)
  800f3d:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800f40:	74 16                	je     800f58 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800f42:	89 f8                	mov    %edi,%eax
  800f44:	84 c0                	test   %al,%al
  800f46:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4b:	0f 44 d8             	cmove  %eax,%ebx
}
  800f4e:	89 d8                	mov    %ebx,%eax
  800f50:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f53:	5b                   	pop    %ebx
  800f54:	5e                   	pop    %esi
  800f55:	5f                   	pop    %edi
  800f56:	5d                   	pop    %ebp
  800f57:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800f58:	83 ec 08             	sub    $0x8,%esp
  800f5b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800f5e:	50                   	push   %eax
  800f5f:	ff 36                	pushl  (%esi)
  800f61:	e8 4e ff ff ff       	call   800eb4 <dev_lookup>
  800f66:	89 c3                	mov    %eax,%ebx
  800f68:	83 c4 10             	add    $0x10,%esp
  800f6b:	85 c0                	test   %eax,%eax
  800f6d:	78 1a                	js     800f89 <fd_close+0x7b>
		if (dev->dev_close)
  800f6f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800f72:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800f75:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800f7a:	85 c0                	test   %eax,%eax
  800f7c:	74 0b                	je     800f89 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800f7e:	83 ec 0c             	sub    $0xc,%esp
  800f81:	56                   	push   %esi
  800f82:	ff d0                	call   *%eax
  800f84:	89 c3                	mov    %eax,%ebx
  800f86:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800f89:	83 ec 08             	sub    $0x8,%esp
  800f8c:	56                   	push   %esi
  800f8d:	6a 00                	push   $0x0
  800f8f:	e8 d5 fc ff ff       	call   800c69 <sys_page_unmap>
	return r;
  800f94:	83 c4 10             	add    $0x10,%esp
  800f97:	eb b5                	jmp    800f4e <fd_close+0x40>

00800f99 <close>:

int
close(int fdnum)
{
  800f99:	f3 0f 1e fb          	endbr32 
  800f9d:	55                   	push   %ebp
  800f9e:	89 e5                	mov    %esp,%ebp
  800fa0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fa3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fa6:	50                   	push   %eax
  800fa7:	ff 75 08             	pushl  0x8(%ebp)
  800faa:	e8 b1 fe ff ff       	call   800e60 <fd_lookup>
  800faf:	83 c4 10             	add    $0x10,%esp
  800fb2:	85 c0                	test   %eax,%eax
  800fb4:	79 02                	jns    800fb8 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800fb6:	c9                   	leave  
  800fb7:	c3                   	ret    
		return fd_close(fd, 1);
  800fb8:	83 ec 08             	sub    $0x8,%esp
  800fbb:	6a 01                	push   $0x1
  800fbd:	ff 75 f4             	pushl  -0xc(%ebp)
  800fc0:	e8 49 ff ff ff       	call   800f0e <fd_close>
  800fc5:	83 c4 10             	add    $0x10,%esp
  800fc8:	eb ec                	jmp    800fb6 <close+0x1d>

00800fca <close_all>:

void
close_all(void)
{
  800fca:	f3 0f 1e fb          	endbr32 
  800fce:	55                   	push   %ebp
  800fcf:	89 e5                	mov    %esp,%ebp
  800fd1:	53                   	push   %ebx
  800fd2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800fd5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800fda:	83 ec 0c             	sub    $0xc,%esp
  800fdd:	53                   	push   %ebx
  800fde:	e8 b6 ff ff ff       	call   800f99 <close>
	for (i = 0; i < MAXFD; i++)
  800fe3:	83 c3 01             	add    $0x1,%ebx
  800fe6:	83 c4 10             	add    $0x10,%esp
  800fe9:	83 fb 20             	cmp    $0x20,%ebx
  800fec:	75 ec                	jne    800fda <close_all+0x10>
}
  800fee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ff1:	c9                   	leave  
  800ff2:	c3                   	ret    

00800ff3 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ff3:	f3 0f 1e fb          	endbr32 
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	57                   	push   %edi
  800ffb:	56                   	push   %esi
  800ffc:	53                   	push   %ebx
  800ffd:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801000:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801003:	50                   	push   %eax
  801004:	ff 75 08             	pushl  0x8(%ebp)
  801007:	e8 54 fe ff ff       	call   800e60 <fd_lookup>
  80100c:	89 c3                	mov    %eax,%ebx
  80100e:	83 c4 10             	add    $0x10,%esp
  801011:	85 c0                	test   %eax,%eax
  801013:	0f 88 81 00 00 00    	js     80109a <dup+0xa7>
		return r;
	close(newfdnum);
  801019:	83 ec 0c             	sub    $0xc,%esp
  80101c:	ff 75 0c             	pushl  0xc(%ebp)
  80101f:	e8 75 ff ff ff       	call   800f99 <close>

	newfd = INDEX2FD(newfdnum);
  801024:	8b 75 0c             	mov    0xc(%ebp),%esi
  801027:	c1 e6 0c             	shl    $0xc,%esi
  80102a:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801030:	83 c4 04             	add    $0x4,%esp
  801033:	ff 75 e4             	pushl  -0x1c(%ebp)
  801036:	e8 b0 fd ff ff       	call   800deb <fd2data>
  80103b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80103d:	89 34 24             	mov    %esi,(%esp)
  801040:	e8 a6 fd ff ff       	call   800deb <fd2data>
  801045:	83 c4 10             	add    $0x10,%esp
  801048:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80104a:	89 d8                	mov    %ebx,%eax
  80104c:	c1 e8 16             	shr    $0x16,%eax
  80104f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801056:	a8 01                	test   $0x1,%al
  801058:	74 11                	je     80106b <dup+0x78>
  80105a:	89 d8                	mov    %ebx,%eax
  80105c:	c1 e8 0c             	shr    $0xc,%eax
  80105f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801066:	f6 c2 01             	test   $0x1,%dl
  801069:	75 39                	jne    8010a4 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80106b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80106e:	89 d0                	mov    %edx,%eax
  801070:	c1 e8 0c             	shr    $0xc,%eax
  801073:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80107a:	83 ec 0c             	sub    $0xc,%esp
  80107d:	25 07 0e 00 00       	and    $0xe07,%eax
  801082:	50                   	push   %eax
  801083:	56                   	push   %esi
  801084:	6a 00                	push   $0x0
  801086:	52                   	push   %edx
  801087:	6a 00                	push   $0x0
  801089:	e8 b1 fb ff ff       	call   800c3f <sys_page_map>
  80108e:	89 c3                	mov    %eax,%ebx
  801090:	83 c4 20             	add    $0x20,%esp
  801093:	85 c0                	test   %eax,%eax
  801095:	78 31                	js     8010c8 <dup+0xd5>
		goto err;

	return newfdnum;
  801097:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80109a:	89 d8                	mov    %ebx,%eax
  80109c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80109f:	5b                   	pop    %ebx
  8010a0:	5e                   	pop    %esi
  8010a1:	5f                   	pop    %edi
  8010a2:	5d                   	pop    %ebp
  8010a3:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8010a4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8010ab:	83 ec 0c             	sub    $0xc,%esp
  8010ae:	25 07 0e 00 00       	and    $0xe07,%eax
  8010b3:	50                   	push   %eax
  8010b4:	57                   	push   %edi
  8010b5:	6a 00                	push   $0x0
  8010b7:	53                   	push   %ebx
  8010b8:	6a 00                	push   $0x0
  8010ba:	e8 80 fb ff ff       	call   800c3f <sys_page_map>
  8010bf:	89 c3                	mov    %eax,%ebx
  8010c1:	83 c4 20             	add    $0x20,%esp
  8010c4:	85 c0                	test   %eax,%eax
  8010c6:	79 a3                	jns    80106b <dup+0x78>
	sys_page_unmap(0, newfd);
  8010c8:	83 ec 08             	sub    $0x8,%esp
  8010cb:	56                   	push   %esi
  8010cc:	6a 00                	push   $0x0
  8010ce:	e8 96 fb ff ff       	call   800c69 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8010d3:	83 c4 08             	add    $0x8,%esp
  8010d6:	57                   	push   %edi
  8010d7:	6a 00                	push   $0x0
  8010d9:	e8 8b fb ff ff       	call   800c69 <sys_page_unmap>
	return r;
  8010de:	83 c4 10             	add    $0x10,%esp
  8010e1:	eb b7                	jmp    80109a <dup+0xa7>

008010e3 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8010e3:	f3 0f 1e fb          	endbr32 
  8010e7:	55                   	push   %ebp
  8010e8:	89 e5                	mov    %esp,%ebp
  8010ea:	53                   	push   %ebx
  8010eb:	83 ec 1c             	sub    $0x1c,%esp
  8010ee:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010f4:	50                   	push   %eax
  8010f5:	53                   	push   %ebx
  8010f6:	e8 65 fd ff ff       	call   800e60 <fd_lookup>
  8010fb:	83 c4 10             	add    $0x10,%esp
  8010fe:	85 c0                	test   %eax,%eax
  801100:	78 3f                	js     801141 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801102:	83 ec 08             	sub    $0x8,%esp
  801105:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801108:	50                   	push   %eax
  801109:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80110c:	ff 30                	pushl  (%eax)
  80110e:	e8 a1 fd ff ff       	call   800eb4 <dev_lookup>
  801113:	83 c4 10             	add    $0x10,%esp
  801116:	85 c0                	test   %eax,%eax
  801118:	78 27                	js     801141 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80111a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80111d:	8b 42 08             	mov    0x8(%edx),%eax
  801120:	83 e0 03             	and    $0x3,%eax
  801123:	83 f8 01             	cmp    $0x1,%eax
  801126:	74 1e                	je     801146 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801128:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80112b:	8b 40 08             	mov    0x8(%eax),%eax
  80112e:	85 c0                	test   %eax,%eax
  801130:	74 35                	je     801167 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801132:	83 ec 04             	sub    $0x4,%esp
  801135:	ff 75 10             	pushl  0x10(%ebp)
  801138:	ff 75 0c             	pushl  0xc(%ebp)
  80113b:	52                   	push   %edx
  80113c:	ff d0                	call   *%eax
  80113e:	83 c4 10             	add    $0x10,%esp
}
  801141:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801144:	c9                   	leave  
  801145:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801146:	a1 04 40 80 00       	mov    0x804004,%eax
  80114b:	8b 40 48             	mov    0x48(%eax),%eax
  80114e:	83 ec 04             	sub    $0x4,%esp
  801151:	53                   	push   %ebx
  801152:	50                   	push   %eax
  801153:	68 15 23 80 00       	push   $0x802315
  801158:	e8 c8 f0 ff ff       	call   800225 <cprintf>
		return -E_INVAL;
  80115d:	83 c4 10             	add    $0x10,%esp
  801160:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801165:	eb da                	jmp    801141 <read+0x5e>
		return -E_NOT_SUPP;
  801167:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80116c:	eb d3                	jmp    801141 <read+0x5e>

0080116e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80116e:	f3 0f 1e fb          	endbr32 
  801172:	55                   	push   %ebp
  801173:	89 e5                	mov    %esp,%ebp
  801175:	57                   	push   %edi
  801176:	56                   	push   %esi
  801177:	53                   	push   %ebx
  801178:	83 ec 0c             	sub    $0xc,%esp
  80117b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80117e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801181:	bb 00 00 00 00       	mov    $0x0,%ebx
  801186:	eb 02                	jmp    80118a <readn+0x1c>
  801188:	01 c3                	add    %eax,%ebx
  80118a:	39 f3                	cmp    %esi,%ebx
  80118c:	73 21                	jae    8011af <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  80118e:	83 ec 04             	sub    $0x4,%esp
  801191:	89 f0                	mov    %esi,%eax
  801193:	29 d8                	sub    %ebx,%eax
  801195:	50                   	push   %eax
  801196:	89 d8                	mov    %ebx,%eax
  801198:	03 45 0c             	add    0xc(%ebp),%eax
  80119b:	50                   	push   %eax
  80119c:	57                   	push   %edi
  80119d:	e8 41 ff ff ff       	call   8010e3 <read>
		if (m < 0)
  8011a2:	83 c4 10             	add    $0x10,%esp
  8011a5:	85 c0                	test   %eax,%eax
  8011a7:	78 04                	js     8011ad <readn+0x3f>
			return m;
		if (m == 0)
  8011a9:	75 dd                	jne    801188 <readn+0x1a>
  8011ab:	eb 02                	jmp    8011af <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8011ad:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8011af:	89 d8                	mov    %ebx,%eax
  8011b1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011b4:	5b                   	pop    %ebx
  8011b5:	5e                   	pop    %esi
  8011b6:	5f                   	pop    %edi
  8011b7:	5d                   	pop    %ebp
  8011b8:	c3                   	ret    

008011b9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8011b9:	f3 0f 1e fb          	endbr32 
  8011bd:	55                   	push   %ebp
  8011be:	89 e5                	mov    %esp,%ebp
  8011c0:	53                   	push   %ebx
  8011c1:	83 ec 1c             	sub    $0x1c,%esp
  8011c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011c7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011ca:	50                   	push   %eax
  8011cb:	53                   	push   %ebx
  8011cc:	e8 8f fc ff ff       	call   800e60 <fd_lookup>
  8011d1:	83 c4 10             	add    $0x10,%esp
  8011d4:	85 c0                	test   %eax,%eax
  8011d6:	78 3a                	js     801212 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011d8:	83 ec 08             	sub    $0x8,%esp
  8011db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011de:	50                   	push   %eax
  8011df:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011e2:	ff 30                	pushl  (%eax)
  8011e4:	e8 cb fc ff ff       	call   800eb4 <dev_lookup>
  8011e9:	83 c4 10             	add    $0x10,%esp
  8011ec:	85 c0                	test   %eax,%eax
  8011ee:	78 22                	js     801212 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8011f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8011f3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8011f7:	74 1e                	je     801217 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8011f9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8011fc:	8b 52 0c             	mov    0xc(%edx),%edx
  8011ff:	85 d2                	test   %edx,%edx
  801201:	74 35                	je     801238 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801203:	83 ec 04             	sub    $0x4,%esp
  801206:	ff 75 10             	pushl  0x10(%ebp)
  801209:	ff 75 0c             	pushl  0xc(%ebp)
  80120c:	50                   	push   %eax
  80120d:	ff d2                	call   *%edx
  80120f:	83 c4 10             	add    $0x10,%esp
}
  801212:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801215:	c9                   	leave  
  801216:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801217:	a1 04 40 80 00       	mov    0x804004,%eax
  80121c:	8b 40 48             	mov    0x48(%eax),%eax
  80121f:	83 ec 04             	sub    $0x4,%esp
  801222:	53                   	push   %ebx
  801223:	50                   	push   %eax
  801224:	68 31 23 80 00       	push   $0x802331
  801229:	e8 f7 ef ff ff       	call   800225 <cprintf>
		return -E_INVAL;
  80122e:	83 c4 10             	add    $0x10,%esp
  801231:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801236:	eb da                	jmp    801212 <write+0x59>
		return -E_NOT_SUPP;
  801238:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80123d:	eb d3                	jmp    801212 <write+0x59>

0080123f <seek>:

int
seek(int fdnum, off_t offset)
{
  80123f:	f3 0f 1e fb          	endbr32 
  801243:	55                   	push   %ebp
  801244:	89 e5                	mov    %esp,%ebp
  801246:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801249:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80124c:	50                   	push   %eax
  80124d:	ff 75 08             	pushl  0x8(%ebp)
  801250:	e8 0b fc ff ff       	call   800e60 <fd_lookup>
  801255:	83 c4 10             	add    $0x10,%esp
  801258:	85 c0                	test   %eax,%eax
  80125a:	78 0e                	js     80126a <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80125c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80125f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801262:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801265:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80126a:	c9                   	leave  
  80126b:	c3                   	ret    

0080126c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80126c:	f3 0f 1e fb          	endbr32 
  801270:	55                   	push   %ebp
  801271:	89 e5                	mov    %esp,%ebp
  801273:	53                   	push   %ebx
  801274:	83 ec 1c             	sub    $0x1c,%esp
  801277:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80127a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80127d:	50                   	push   %eax
  80127e:	53                   	push   %ebx
  80127f:	e8 dc fb ff ff       	call   800e60 <fd_lookup>
  801284:	83 c4 10             	add    $0x10,%esp
  801287:	85 c0                	test   %eax,%eax
  801289:	78 37                	js     8012c2 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80128b:	83 ec 08             	sub    $0x8,%esp
  80128e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801291:	50                   	push   %eax
  801292:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801295:	ff 30                	pushl  (%eax)
  801297:	e8 18 fc ff ff       	call   800eb4 <dev_lookup>
  80129c:	83 c4 10             	add    $0x10,%esp
  80129f:	85 c0                	test   %eax,%eax
  8012a1:	78 1f                	js     8012c2 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8012a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8012a6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8012aa:	74 1b                	je     8012c7 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8012ac:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8012af:	8b 52 18             	mov    0x18(%edx),%edx
  8012b2:	85 d2                	test   %edx,%edx
  8012b4:	74 32                	je     8012e8 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8012b6:	83 ec 08             	sub    $0x8,%esp
  8012b9:	ff 75 0c             	pushl  0xc(%ebp)
  8012bc:	50                   	push   %eax
  8012bd:	ff d2                	call   *%edx
  8012bf:	83 c4 10             	add    $0x10,%esp
}
  8012c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8012c5:	c9                   	leave  
  8012c6:	c3                   	ret    
			thisenv->env_id, fdnum);
  8012c7:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8012cc:	8b 40 48             	mov    0x48(%eax),%eax
  8012cf:	83 ec 04             	sub    $0x4,%esp
  8012d2:	53                   	push   %ebx
  8012d3:	50                   	push   %eax
  8012d4:	68 f4 22 80 00       	push   $0x8022f4
  8012d9:	e8 47 ef ff ff       	call   800225 <cprintf>
		return -E_INVAL;
  8012de:	83 c4 10             	add    $0x10,%esp
  8012e1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8012e6:	eb da                	jmp    8012c2 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8012e8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8012ed:	eb d3                	jmp    8012c2 <ftruncate+0x56>

008012ef <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8012ef:	f3 0f 1e fb          	endbr32 
  8012f3:	55                   	push   %ebp
  8012f4:	89 e5                	mov    %esp,%ebp
  8012f6:	53                   	push   %ebx
  8012f7:	83 ec 1c             	sub    $0x1c,%esp
  8012fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8012fd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801300:	50                   	push   %eax
  801301:	ff 75 08             	pushl  0x8(%ebp)
  801304:	e8 57 fb ff ff       	call   800e60 <fd_lookup>
  801309:	83 c4 10             	add    $0x10,%esp
  80130c:	85 c0                	test   %eax,%eax
  80130e:	78 4b                	js     80135b <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801310:	83 ec 08             	sub    $0x8,%esp
  801313:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801316:	50                   	push   %eax
  801317:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80131a:	ff 30                	pushl  (%eax)
  80131c:	e8 93 fb ff ff       	call   800eb4 <dev_lookup>
  801321:	83 c4 10             	add    $0x10,%esp
  801324:	85 c0                	test   %eax,%eax
  801326:	78 33                	js     80135b <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801328:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80132b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80132f:	74 2f                	je     801360 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801331:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801334:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80133b:	00 00 00 
	stat->st_isdir = 0;
  80133e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801345:	00 00 00 
	stat->st_dev = dev;
  801348:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80134e:	83 ec 08             	sub    $0x8,%esp
  801351:	53                   	push   %ebx
  801352:	ff 75 f0             	pushl  -0x10(%ebp)
  801355:	ff 50 14             	call   *0x14(%eax)
  801358:	83 c4 10             	add    $0x10,%esp
}
  80135b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80135e:	c9                   	leave  
  80135f:	c3                   	ret    
		return -E_NOT_SUPP;
  801360:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801365:	eb f4                	jmp    80135b <fstat+0x6c>

00801367 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801367:	f3 0f 1e fb          	endbr32 
  80136b:	55                   	push   %ebp
  80136c:	89 e5                	mov    %esp,%ebp
  80136e:	56                   	push   %esi
  80136f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801370:	83 ec 08             	sub    $0x8,%esp
  801373:	6a 00                	push   $0x0
  801375:	ff 75 08             	pushl  0x8(%ebp)
  801378:	e8 fb 01 00 00       	call   801578 <open>
  80137d:	89 c3                	mov    %eax,%ebx
  80137f:	83 c4 10             	add    $0x10,%esp
  801382:	85 c0                	test   %eax,%eax
  801384:	78 1b                	js     8013a1 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801386:	83 ec 08             	sub    $0x8,%esp
  801389:	ff 75 0c             	pushl  0xc(%ebp)
  80138c:	50                   	push   %eax
  80138d:	e8 5d ff ff ff       	call   8012ef <fstat>
  801392:	89 c6                	mov    %eax,%esi
	close(fd);
  801394:	89 1c 24             	mov    %ebx,(%esp)
  801397:	e8 fd fb ff ff       	call   800f99 <close>
	return r;
  80139c:	83 c4 10             	add    $0x10,%esp
  80139f:	89 f3                	mov    %esi,%ebx
}
  8013a1:	89 d8                	mov    %ebx,%eax
  8013a3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013a6:	5b                   	pop    %ebx
  8013a7:	5e                   	pop    %esi
  8013a8:	5d                   	pop    %ebp
  8013a9:	c3                   	ret    

008013aa <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8013aa:	55                   	push   %ebp
  8013ab:	89 e5                	mov    %esp,%ebp
  8013ad:	56                   	push   %esi
  8013ae:	53                   	push   %ebx
  8013af:	89 c6                	mov    %eax,%esi
  8013b1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8013b3:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8013ba:	74 27                	je     8013e3 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8013bc:	6a 07                	push   $0x7
  8013be:	68 00 50 80 00       	push   $0x805000
  8013c3:	56                   	push   %esi
  8013c4:	ff 35 00 40 80 00    	pushl  0x804000
  8013ca:	e8 bf 07 00 00       	call   801b8e <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8013cf:	83 c4 0c             	add    $0xc,%esp
  8013d2:	6a 00                	push   $0x0
  8013d4:	53                   	push   %ebx
  8013d5:	6a 00                	push   $0x0
  8013d7:	e8 44 07 00 00       	call   801b20 <ipc_recv>
}
  8013dc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8013df:	5b                   	pop    %ebx
  8013e0:	5e                   	pop    %esi
  8013e1:	5d                   	pop    %ebp
  8013e2:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8013e3:	83 ec 0c             	sub    $0xc,%esp
  8013e6:	6a 01                	push   $0x1
  8013e8:	e8 06 08 00 00       	call   801bf3 <ipc_find_env>
  8013ed:	a3 00 40 80 00       	mov    %eax,0x804000
  8013f2:	83 c4 10             	add    $0x10,%esp
  8013f5:	eb c5                	jmp    8013bc <fsipc+0x12>

008013f7 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8013f7:	f3 0f 1e fb          	endbr32 
  8013fb:	55                   	push   %ebp
  8013fc:	89 e5                	mov    %esp,%ebp
  8013fe:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801401:	8b 45 08             	mov    0x8(%ebp),%eax
  801404:	8b 40 0c             	mov    0xc(%eax),%eax
  801407:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80140c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80140f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801414:	ba 00 00 00 00       	mov    $0x0,%edx
  801419:	b8 02 00 00 00       	mov    $0x2,%eax
  80141e:	e8 87 ff ff ff       	call   8013aa <fsipc>
}
  801423:	c9                   	leave  
  801424:	c3                   	ret    

00801425 <devfile_flush>:
{
  801425:	f3 0f 1e fb          	endbr32 
  801429:	55                   	push   %ebp
  80142a:	89 e5                	mov    %esp,%ebp
  80142c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80142f:	8b 45 08             	mov    0x8(%ebp),%eax
  801432:	8b 40 0c             	mov    0xc(%eax),%eax
  801435:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80143a:	ba 00 00 00 00       	mov    $0x0,%edx
  80143f:	b8 06 00 00 00       	mov    $0x6,%eax
  801444:	e8 61 ff ff ff       	call   8013aa <fsipc>
}
  801449:	c9                   	leave  
  80144a:	c3                   	ret    

0080144b <devfile_stat>:
{
  80144b:	f3 0f 1e fb          	endbr32 
  80144f:	55                   	push   %ebp
  801450:	89 e5                	mov    %esp,%ebp
  801452:	53                   	push   %ebx
  801453:	83 ec 04             	sub    $0x4,%esp
  801456:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801459:	8b 45 08             	mov    0x8(%ebp),%eax
  80145c:	8b 40 0c             	mov    0xc(%eax),%eax
  80145f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801464:	ba 00 00 00 00       	mov    $0x0,%edx
  801469:	b8 05 00 00 00       	mov    $0x5,%eax
  80146e:	e8 37 ff ff ff       	call   8013aa <fsipc>
  801473:	85 c0                	test   %eax,%eax
  801475:	78 2c                	js     8014a3 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801477:	83 ec 08             	sub    $0x8,%esp
  80147a:	68 00 50 80 00       	push   $0x805000
  80147f:	53                   	push   %ebx
  801480:	e8 0a f3 ff ff       	call   80078f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801485:	a1 80 50 80 00       	mov    0x805080,%eax
  80148a:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801490:	a1 84 50 80 00       	mov    0x805084,%eax
  801495:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  80149b:	83 c4 10             	add    $0x10,%esp
  80149e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014a3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014a6:	c9                   	leave  
  8014a7:	c3                   	ret    

008014a8 <devfile_write>:
{
  8014a8:	f3 0f 1e fb          	endbr32 
  8014ac:	55                   	push   %ebp
  8014ad:	89 e5                	mov    %esp,%ebp
  8014af:	83 ec 0c             	sub    $0xc,%esp
  8014b2:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8014b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8014b8:	8b 52 0c             	mov    0xc(%edx),%edx
  8014bb:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8014c1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8014c6:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8014cb:	0f 47 c2             	cmova  %edx,%eax
  8014ce:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8014d3:	50                   	push   %eax
  8014d4:	ff 75 0c             	pushl  0xc(%ebp)
  8014d7:	68 08 50 80 00       	push   $0x805008
  8014dc:	e8 66 f4 ff ff       	call   800947 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8014e1:	ba 00 00 00 00       	mov    $0x0,%edx
  8014e6:	b8 04 00 00 00       	mov    $0x4,%eax
  8014eb:	e8 ba fe ff ff       	call   8013aa <fsipc>
}
  8014f0:	c9                   	leave  
  8014f1:	c3                   	ret    

008014f2 <devfile_read>:
{
  8014f2:	f3 0f 1e fb          	endbr32 
  8014f6:	55                   	push   %ebp
  8014f7:	89 e5                	mov    %esp,%ebp
  8014f9:	56                   	push   %esi
  8014fa:	53                   	push   %ebx
  8014fb:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8014fe:	8b 45 08             	mov    0x8(%ebp),%eax
  801501:	8b 40 0c             	mov    0xc(%eax),%eax
  801504:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801509:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80150f:	ba 00 00 00 00       	mov    $0x0,%edx
  801514:	b8 03 00 00 00       	mov    $0x3,%eax
  801519:	e8 8c fe ff ff       	call   8013aa <fsipc>
  80151e:	89 c3                	mov    %eax,%ebx
  801520:	85 c0                	test   %eax,%eax
  801522:	78 1f                	js     801543 <devfile_read+0x51>
	assert(r <= n);
  801524:	39 f0                	cmp    %esi,%eax
  801526:	77 24                	ja     80154c <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801528:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80152d:	7f 33                	jg     801562 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80152f:	83 ec 04             	sub    $0x4,%esp
  801532:	50                   	push   %eax
  801533:	68 00 50 80 00       	push   $0x805000
  801538:	ff 75 0c             	pushl  0xc(%ebp)
  80153b:	e8 07 f4 ff ff       	call   800947 <memmove>
	return r;
  801540:	83 c4 10             	add    $0x10,%esp
}
  801543:	89 d8                	mov    %ebx,%eax
  801545:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801548:	5b                   	pop    %ebx
  801549:	5e                   	pop    %esi
  80154a:	5d                   	pop    %ebp
  80154b:	c3                   	ret    
	assert(r <= n);
  80154c:	68 60 23 80 00       	push   $0x802360
  801551:	68 67 23 80 00       	push   $0x802367
  801556:	6a 7c                	push   $0x7c
  801558:	68 7c 23 80 00       	push   $0x80237c
  80155d:	e8 dc eb ff ff       	call   80013e <_panic>
	assert(r <= PGSIZE);
  801562:	68 87 23 80 00       	push   $0x802387
  801567:	68 67 23 80 00       	push   $0x802367
  80156c:	6a 7d                	push   $0x7d
  80156e:	68 7c 23 80 00       	push   $0x80237c
  801573:	e8 c6 eb ff ff       	call   80013e <_panic>

00801578 <open>:
{
  801578:	f3 0f 1e fb          	endbr32 
  80157c:	55                   	push   %ebp
  80157d:	89 e5                	mov    %esp,%ebp
  80157f:	56                   	push   %esi
  801580:	53                   	push   %ebx
  801581:	83 ec 1c             	sub    $0x1c,%esp
  801584:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801587:	56                   	push   %esi
  801588:	e8 bf f1 ff ff       	call   80074c <strlen>
  80158d:	83 c4 10             	add    $0x10,%esp
  801590:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801595:	7f 6c                	jg     801603 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801597:	83 ec 0c             	sub    $0xc,%esp
  80159a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80159d:	50                   	push   %eax
  80159e:	e8 67 f8 ff ff       	call   800e0a <fd_alloc>
  8015a3:	89 c3                	mov    %eax,%ebx
  8015a5:	83 c4 10             	add    $0x10,%esp
  8015a8:	85 c0                	test   %eax,%eax
  8015aa:	78 3c                	js     8015e8 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8015ac:	83 ec 08             	sub    $0x8,%esp
  8015af:	56                   	push   %esi
  8015b0:	68 00 50 80 00       	push   $0x805000
  8015b5:	e8 d5 f1 ff ff       	call   80078f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8015ba:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015bd:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8015c2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8015c5:	b8 01 00 00 00       	mov    $0x1,%eax
  8015ca:	e8 db fd ff ff       	call   8013aa <fsipc>
  8015cf:	89 c3                	mov    %eax,%ebx
  8015d1:	83 c4 10             	add    $0x10,%esp
  8015d4:	85 c0                	test   %eax,%eax
  8015d6:	78 19                	js     8015f1 <open+0x79>
	return fd2num(fd);
  8015d8:	83 ec 0c             	sub    $0xc,%esp
  8015db:	ff 75 f4             	pushl  -0xc(%ebp)
  8015de:	e8 f4 f7 ff ff       	call   800dd7 <fd2num>
  8015e3:	89 c3                	mov    %eax,%ebx
  8015e5:	83 c4 10             	add    $0x10,%esp
}
  8015e8:	89 d8                	mov    %ebx,%eax
  8015ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015ed:	5b                   	pop    %ebx
  8015ee:	5e                   	pop    %esi
  8015ef:	5d                   	pop    %ebp
  8015f0:	c3                   	ret    
		fd_close(fd, 0);
  8015f1:	83 ec 08             	sub    $0x8,%esp
  8015f4:	6a 00                	push   $0x0
  8015f6:	ff 75 f4             	pushl  -0xc(%ebp)
  8015f9:	e8 10 f9 ff ff       	call   800f0e <fd_close>
		return r;
  8015fe:	83 c4 10             	add    $0x10,%esp
  801601:	eb e5                	jmp    8015e8 <open+0x70>
		return -E_BAD_PATH;
  801603:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801608:	eb de                	jmp    8015e8 <open+0x70>

0080160a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  80160a:	f3 0f 1e fb          	endbr32 
  80160e:	55                   	push   %ebp
  80160f:	89 e5                	mov    %esp,%ebp
  801611:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801614:	ba 00 00 00 00       	mov    $0x0,%edx
  801619:	b8 08 00 00 00       	mov    $0x8,%eax
  80161e:	e8 87 fd ff ff       	call   8013aa <fsipc>
}
  801623:	c9                   	leave  
  801624:	c3                   	ret    

00801625 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801625:	f3 0f 1e fb          	endbr32 
  801629:	55                   	push   %ebp
  80162a:	89 e5                	mov    %esp,%ebp
  80162c:	56                   	push   %esi
  80162d:	53                   	push   %ebx
  80162e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801631:	83 ec 0c             	sub    $0xc,%esp
  801634:	ff 75 08             	pushl  0x8(%ebp)
  801637:	e8 af f7 ff ff       	call   800deb <fd2data>
  80163c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80163e:	83 c4 08             	add    $0x8,%esp
  801641:	68 93 23 80 00       	push   $0x802393
  801646:	53                   	push   %ebx
  801647:	e8 43 f1 ff ff       	call   80078f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80164c:	8b 46 04             	mov    0x4(%esi),%eax
  80164f:	2b 06                	sub    (%esi),%eax
  801651:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801657:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80165e:	00 00 00 
	stat->st_dev = &devpipe;
  801661:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801668:	30 80 00 
	return 0;
}
  80166b:	b8 00 00 00 00       	mov    $0x0,%eax
  801670:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801673:	5b                   	pop    %ebx
  801674:	5e                   	pop    %esi
  801675:	5d                   	pop    %ebp
  801676:	c3                   	ret    

00801677 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801677:	f3 0f 1e fb          	endbr32 
  80167b:	55                   	push   %ebp
  80167c:	89 e5                	mov    %esp,%ebp
  80167e:	53                   	push   %ebx
  80167f:	83 ec 0c             	sub    $0xc,%esp
  801682:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801685:	53                   	push   %ebx
  801686:	6a 00                	push   $0x0
  801688:	e8 dc f5 ff ff       	call   800c69 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  80168d:	89 1c 24             	mov    %ebx,(%esp)
  801690:	e8 56 f7 ff ff       	call   800deb <fd2data>
  801695:	83 c4 08             	add    $0x8,%esp
  801698:	50                   	push   %eax
  801699:	6a 00                	push   $0x0
  80169b:	e8 c9 f5 ff ff       	call   800c69 <sys_page_unmap>
}
  8016a0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016a3:	c9                   	leave  
  8016a4:	c3                   	ret    

008016a5 <_pipeisclosed>:
{
  8016a5:	55                   	push   %ebp
  8016a6:	89 e5                	mov    %esp,%ebp
  8016a8:	57                   	push   %edi
  8016a9:	56                   	push   %esi
  8016aa:	53                   	push   %ebx
  8016ab:	83 ec 1c             	sub    $0x1c,%esp
  8016ae:	89 c7                	mov    %eax,%edi
  8016b0:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8016b2:	a1 04 40 80 00       	mov    0x804004,%eax
  8016b7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8016ba:	83 ec 0c             	sub    $0xc,%esp
  8016bd:	57                   	push   %edi
  8016be:	e8 6d 05 00 00       	call   801c30 <pageref>
  8016c3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8016c6:	89 34 24             	mov    %esi,(%esp)
  8016c9:	e8 62 05 00 00       	call   801c30 <pageref>
		nn = thisenv->env_runs;
  8016ce:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8016d4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8016d7:	83 c4 10             	add    $0x10,%esp
  8016da:	39 cb                	cmp    %ecx,%ebx
  8016dc:	74 1b                	je     8016f9 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8016de:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8016e1:	75 cf                	jne    8016b2 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8016e3:	8b 42 58             	mov    0x58(%edx),%eax
  8016e6:	6a 01                	push   $0x1
  8016e8:	50                   	push   %eax
  8016e9:	53                   	push   %ebx
  8016ea:	68 9a 23 80 00       	push   $0x80239a
  8016ef:	e8 31 eb ff ff       	call   800225 <cprintf>
  8016f4:	83 c4 10             	add    $0x10,%esp
  8016f7:	eb b9                	jmp    8016b2 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8016f9:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8016fc:	0f 94 c0             	sete   %al
  8016ff:	0f b6 c0             	movzbl %al,%eax
}
  801702:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801705:	5b                   	pop    %ebx
  801706:	5e                   	pop    %esi
  801707:	5f                   	pop    %edi
  801708:	5d                   	pop    %ebp
  801709:	c3                   	ret    

0080170a <devpipe_write>:
{
  80170a:	f3 0f 1e fb          	endbr32 
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	57                   	push   %edi
  801712:	56                   	push   %esi
  801713:	53                   	push   %ebx
  801714:	83 ec 28             	sub    $0x28,%esp
  801717:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  80171a:	56                   	push   %esi
  80171b:	e8 cb f6 ff ff       	call   800deb <fd2data>
  801720:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801722:	83 c4 10             	add    $0x10,%esp
  801725:	bf 00 00 00 00       	mov    $0x0,%edi
  80172a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  80172d:	74 4f                	je     80177e <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  80172f:	8b 43 04             	mov    0x4(%ebx),%eax
  801732:	8b 0b                	mov    (%ebx),%ecx
  801734:	8d 51 20             	lea    0x20(%ecx),%edx
  801737:	39 d0                	cmp    %edx,%eax
  801739:	72 14                	jb     80174f <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  80173b:	89 da                	mov    %ebx,%edx
  80173d:	89 f0                	mov    %esi,%eax
  80173f:	e8 61 ff ff ff       	call   8016a5 <_pipeisclosed>
  801744:	85 c0                	test   %eax,%eax
  801746:	75 3b                	jne    801783 <devpipe_write+0x79>
			sys_yield();
  801748:	e8 9f f4 ff ff       	call   800bec <sys_yield>
  80174d:	eb e0                	jmp    80172f <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  80174f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801752:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801756:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801759:	89 c2                	mov    %eax,%edx
  80175b:	c1 fa 1f             	sar    $0x1f,%edx
  80175e:	89 d1                	mov    %edx,%ecx
  801760:	c1 e9 1b             	shr    $0x1b,%ecx
  801763:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801766:	83 e2 1f             	and    $0x1f,%edx
  801769:	29 ca                	sub    %ecx,%edx
  80176b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  80176f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801773:	83 c0 01             	add    $0x1,%eax
  801776:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801779:	83 c7 01             	add    $0x1,%edi
  80177c:	eb ac                	jmp    80172a <devpipe_write+0x20>
	return i;
  80177e:	8b 45 10             	mov    0x10(%ebp),%eax
  801781:	eb 05                	jmp    801788 <devpipe_write+0x7e>
				return 0;
  801783:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801788:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80178b:	5b                   	pop    %ebx
  80178c:	5e                   	pop    %esi
  80178d:	5f                   	pop    %edi
  80178e:	5d                   	pop    %ebp
  80178f:	c3                   	ret    

00801790 <devpipe_read>:
{
  801790:	f3 0f 1e fb          	endbr32 
  801794:	55                   	push   %ebp
  801795:	89 e5                	mov    %esp,%ebp
  801797:	57                   	push   %edi
  801798:	56                   	push   %esi
  801799:	53                   	push   %ebx
  80179a:	83 ec 18             	sub    $0x18,%esp
  80179d:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  8017a0:	57                   	push   %edi
  8017a1:	e8 45 f6 ff ff       	call   800deb <fd2data>
  8017a6:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8017a8:	83 c4 10             	add    $0x10,%esp
  8017ab:	be 00 00 00 00       	mov    $0x0,%esi
  8017b0:	3b 75 10             	cmp    0x10(%ebp),%esi
  8017b3:	75 14                	jne    8017c9 <devpipe_read+0x39>
	return i;
  8017b5:	8b 45 10             	mov    0x10(%ebp),%eax
  8017b8:	eb 02                	jmp    8017bc <devpipe_read+0x2c>
				return i;
  8017ba:	89 f0                	mov    %esi,%eax
}
  8017bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017bf:	5b                   	pop    %ebx
  8017c0:	5e                   	pop    %esi
  8017c1:	5f                   	pop    %edi
  8017c2:	5d                   	pop    %ebp
  8017c3:	c3                   	ret    
			sys_yield();
  8017c4:	e8 23 f4 ff ff       	call   800bec <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8017c9:	8b 03                	mov    (%ebx),%eax
  8017cb:	3b 43 04             	cmp    0x4(%ebx),%eax
  8017ce:	75 18                	jne    8017e8 <devpipe_read+0x58>
			if (i > 0)
  8017d0:	85 f6                	test   %esi,%esi
  8017d2:	75 e6                	jne    8017ba <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8017d4:	89 da                	mov    %ebx,%edx
  8017d6:	89 f8                	mov    %edi,%eax
  8017d8:	e8 c8 fe ff ff       	call   8016a5 <_pipeisclosed>
  8017dd:	85 c0                	test   %eax,%eax
  8017df:	74 e3                	je     8017c4 <devpipe_read+0x34>
				return 0;
  8017e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8017e6:	eb d4                	jmp    8017bc <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8017e8:	99                   	cltd   
  8017e9:	c1 ea 1b             	shr    $0x1b,%edx
  8017ec:	01 d0                	add    %edx,%eax
  8017ee:	83 e0 1f             	and    $0x1f,%eax
  8017f1:	29 d0                	sub    %edx,%eax
  8017f3:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8017f8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017fb:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8017fe:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801801:	83 c6 01             	add    $0x1,%esi
  801804:	eb aa                	jmp    8017b0 <devpipe_read+0x20>

00801806 <pipe>:
{
  801806:	f3 0f 1e fb          	endbr32 
  80180a:	55                   	push   %ebp
  80180b:	89 e5                	mov    %esp,%ebp
  80180d:	56                   	push   %esi
  80180e:	53                   	push   %ebx
  80180f:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801812:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801815:	50                   	push   %eax
  801816:	e8 ef f5 ff ff       	call   800e0a <fd_alloc>
  80181b:	89 c3                	mov    %eax,%ebx
  80181d:	83 c4 10             	add    $0x10,%esp
  801820:	85 c0                	test   %eax,%eax
  801822:	0f 88 23 01 00 00    	js     80194b <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801828:	83 ec 04             	sub    $0x4,%esp
  80182b:	68 07 04 00 00       	push   $0x407
  801830:	ff 75 f4             	pushl  -0xc(%ebp)
  801833:	6a 00                	push   $0x0
  801835:	e8 dd f3 ff ff       	call   800c17 <sys_page_alloc>
  80183a:	89 c3                	mov    %eax,%ebx
  80183c:	83 c4 10             	add    $0x10,%esp
  80183f:	85 c0                	test   %eax,%eax
  801841:	0f 88 04 01 00 00    	js     80194b <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801847:	83 ec 0c             	sub    $0xc,%esp
  80184a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80184d:	50                   	push   %eax
  80184e:	e8 b7 f5 ff ff       	call   800e0a <fd_alloc>
  801853:	89 c3                	mov    %eax,%ebx
  801855:	83 c4 10             	add    $0x10,%esp
  801858:	85 c0                	test   %eax,%eax
  80185a:	0f 88 db 00 00 00    	js     80193b <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801860:	83 ec 04             	sub    $0x4,%esp
  801863:	68 07 04 00 00       	push   $0x407
  801868:	ff 75 f0             	pushl  -0x10(%ebp)
  80186b:	6a 00                	push   $0x0
  80186d:	e8 a5 f3 ff ff       	call   800c17 <sys_page_alloc>
  801872:	89 c3                	mov    %eax,%ebx
  801874:	83 c4 10             	add    $0x10,%esp
  801877:	85 c0                	test   %eax,%eax
  801879:	0f 88 bc 00 00 00    	js     80193b <pipe+0x135>
	va = fd2data(fd0);
  80187f:	83 ec 0c             	sub    $0xc,%esp
  801882:	ff 75 f4             	pushl  -0xc(%ebp)
  801885:	e8 61 f5 ff ff       	call   800deb <fd2data>
  80188a:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80188c:	83 c4 0c             	add    $0xc,%esp
  80188f:	68 07 04 00 00       	push   $0x407
  801894:	50                   	push   %eax
  801895:	6a 00                	push   $0x0
  801897:	e8 7b f3 ff ff       	call   800c17 <sys_page_alloc>
  80189c:	89 c3                	mov    %eax,%ebx
  80189e:	83 c4 10             	add    $0x10,%esp
  8018a1:	85 c0                	test   %eax,%eax
  8018a3:	0f 88 82 00 00 00    	js     80192b <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8018a9:	83 ec 0c             	sub    $0xc,%esp
  8018ac:	ff 75 f0             	pushl  -0x10(%ebp)
  8018af:	e8 37 f5 ff ff       	call   800deb <fd2data>
  8018b4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8018bb:	50                   	push   %eax
  8018bc:	6a 00                	push   $0x0
  8018be:	56                   	push   %esi
  8018bf:	6a 00                	push   $0x0
  8018c1:	e8 79 f3 ff ff       	call   800c3f <sys_page_map>
  8018c6:	89 c3                	mov    %eax,%ebx
  8018c8:	83 c4 20             	add    $0x20,%esp
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	78 4e                	js     80191d <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8018cf:	a1 20 30 80 00       	mov    0x803020,%eax
  8018d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018d7:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8018d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018dc:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8018e3:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8018e6:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8018e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018eb:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8018f2:	83 ec 0c             	sub    $0xc,%esp
  8018f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8018f8:	e8 da f4 ff ff       	call   800dd7 <fd2num>
  8018fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801900:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801902:	83 c4 04             	add    $0x4,%esp
  801905:	ff 75 f0             	pushl  -0x10(%ebp)
  801908:	e8 ca f4 ff ff       	call   800dd7 <fd2num>
  80190d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801910:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801913:	83 c4 10             	add    $0x10,%esp
  801916:	bb 00 00 00 00       	mov    $0x0,%ebx
  80191b:	eb 2e                	jmp    80194b <pipe+0x145>
	sys_page_unmap(0, va);
  80191d:	83 ec 08             	sub    $0x8,%esp
  801920:	56                   	push   %esi
  801921:	6a 00                	push   $0x0
  801923:	e8 41 f3 ff ff       	call   800c69 <sys_page_unmap>
  801928:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80192b:	83 ec 08             	sub    $0x8,%esp
  80192e:	ff 75 f0             	pushl  -0x10(%ebp)
  801931:	6a 00                	push   $0x0
  801933:	e8 31 f3 ff ff       	call   800c69 <sys_page_unmap>
  801938:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  80193b:	83 ec 08             	sub    $0x8,%esp
  80193e:	ff 75 f4             	pushl  -0xc(%ebp)
  801941:	6a 00                	push   $0x0
  801943:	e8 21 f3 ff ff       	call   800c69 <sys_page_unmap>
  801948:	83 c4 10             	add    $0x10,%esp
}
  80194b:	89 d8                	mov    %ebx,%eax
  80194d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801950:	5b                   	pop    %ebx
  801951:	5e                   	pop    %esi
  801952:	5d                   	pop    %ebp
  801953:	c3                   	ret    

00801954 <pipeisclosed>:
{
  801954:	f3 0f 1e fb          	endbr32 
  801958:	55                   	push   %ebp
  801959:	89 e5                	mov    %esp,%ebp
  80195b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80195e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801961:	50                   	push   %eax
  801962:	ff 75 08             	pushl  0x8(%ebp)
  801965:	e8 f6 f4 ff ff       	call   800e60 <fd_lookup>
  80196a:	83 c4 10             	add    $0x10,%esp
  80196d:	85 c0                	test   %eax,%eax
  80196f:	78 18                	js     801989 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801971:	83 ec 0c             	sub    $0xc,%esp
  801974:	ff 75 f4             	pushl  -0xc(%ebp)
  801977:	e8 6f f4 ff ff       	call   800deb <fd2data>
  80197c:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  80197e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801981:	e8 1f fd ff ff       	call   8016a5 <_pipeisclosed>
  801986:	83 c4 10             	add    $0x10,%esp
}
  801989:	c9                   	leave  
  80198a:	c3                   	ret    

0080198b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80198b:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  80198f:	b8 00 00 00 00       	mov    $0x0,%eax
  801994:	c3                   	ret    

00801995 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801995:	f3 0f 1e fb          	endbr32 
  801999:	55                   	push   %ebp
  80199a:	89 e5                	mov    %esp,%ebp
  80199c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80199f:	68 b2 23 80 00       	push   $0x8023b2
  8019a4:	ff 75 0c             	pushl  0xc(%ebp)
  8019a7:	e8 e3 ed ff ff       	call   80078f <strcpy>
	return 0;
}
  8019ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b1:	c9                   	leave  
  8019b2:	c3                   	ret    

008019b3 <devcons_write>:
{
  8019b3:	f3 0f 1e fb          	endbr32 
  8019b7:	55                   	push   %ebp
  8019b8:	89 e5                	mov    %esp,%ebp
  8019ba:	57                   	push   %edi
  8019bb:	56                   	push   %esi
  8019bc:	53                   	push   %ebx
  8019bd:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8019c3:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8019c8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8019ce:	3b 75 10             	cmp    0x10(%ebp),%esi
  8019d1:	73 31                	jae    801a04 <devcons_write+0x51>
		m = n - tot;
  8019d3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8019d6:	29 f3                	sub    %esi,%ebx
  8019d8:	83 fb 7f             	cmp    $0x7f,%ebx
  8019db:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8019e0:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8019e3:	83 ec 04             	sub    $0x4,%esp
  8019e6:	53                   	push   %ebx
  8019e7:	89 f0                	mov    %esi,%eax
  8019e9:	03 45 0c             	add    0xc(%ebp),%eax
  8019ec:	50                   	push   %eax
  8019ed:	57                   	push   %edi
  8019ee:	e8 54 ef ff ff       	call   800947 <memmove>
		sys_cputs(buf, m);
  8019f3:	83 c4 08             	add    $0x8,%esp
  8019f6:	53                   	push   %ebx
  8019f7:	57                   	push   %edi
  8019f8:	e8 4f f1 ff ff       	call   800b4c <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8019fd:	01 de                	add    %ebx,%esi
  8019ff:	83 c4 10             	add    $0x10,%esp
  801a02:	eb ca                	jmp    8019ce <devcons_write+0x1b>
}
  801a04:	89 f0                	mov    %esi,%eax
  801a06:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a09:	5b                   	pop    %ebx
  801a0a:	5e                   	pop    %esi
  801a0b:	5f                   	pop    %edi
  801a0c:	5d                   	pop    %ebp
  801a0d:	c3                   	ret    

00801a0e <devcons_read>:
{
  801a0e:	f3 0f 1e fb          	endbr32 
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	83 ec 08             	sub    $0x8,%esp
  801a18:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801a1d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801a21:	74 21                	je     801a44 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801a23:	e8 4e f1 ff ff       	call   800b76 <sys_cgetc>
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	75 07                	jne    801a33 <devcons_read+0x25>
		sys_yield();
  801a2c:	e8 bb f1 ff ff       	call   800bec <sys_yield>
  801a31:	eb f0                	jmp    801a23 <devcons_read+0x15>
	if (c < 0)
  801a33:	78 0f                	js     801a44 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  801a35:	83 f8 04             	cmp    $0x4,%eax
  801a38:	74 0c                	je     801a46 <devcons_read+0x38>
	*(char*)vbuf = c;
  801a3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  801a3d:	88 02                	mov    %al,(%edx)
	return 1;
  801a3f:	b8 01 00 00 00       	mov    $0x1,%eax
}
  801a44:	c9                   	leave  
  801a45:	c3                   	ret    
		return 0;
  801a46:	b8 00 00 00 00       	mov    $0x0,%eax
  801a4b:	eb f7                	jmp    801a44 <devcons_read+0x36>

00801a4d <cputchar>:
{
  801a4d:	f3 0f 1e fb          	endbr32 
  801a51:	55                   	push   %ebp
  801a52:	89 e5                	mov    %esp,%ebp
  801a54:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  801a57:	8b 45 08             	mov    0x8(%ebp),%eax
  801a5a:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801a5d:	6a 01                	push   $0x1
  801a5f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a62:	50                   	push   %eax
  801a63:	e8 e4 f0 ff ff       	call   800b4c <sys_cputs>
}
  801a68:	83 c4 10             	add    $0x10,%esp
  801a6b:	c9                   	leave  
  801a6c:	c3                   	ret    

00801a6d <getchar>:
{
  801a6d:	f3 0f 1e fb          	endbr32 
  801a71:	55                   	push   %ebp
  801a72:	89 e5                	mov    %esp,%ebp
  801a74:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  801a77:	6a 01                	push   $0x1
  801a79:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801a7c:	50                   	push   %eax
  801a7d:	6a 00                	push   $0x0
  801a7f:	e8 5f f6 ff ff       	call   8010e3 <read>
	if (r < 0)
  801a84:	83 c4 10             	add    $0x10,%esp
  801a87:	85 c0                	test   %eax,%eax
  801a89:	78 06                	js     801a91 <getchar+0x24>
	if (r < 1)
  801a8b:	74 06                	je     801a93 <getchar+0x26>
	return c;
  801a8d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801a91:	c9                   	leave  
  801a92:	c3                   	ret    
		return -E_EOF;
  801a93:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  801a98:	eb f7                	jmp    801a91 <getchar+0x24>

00801a9a <iscons>:
{
  801a9a:	f3 0f 1e fb          	endbr32 
  801a9e:	55                   	push   %ebp
  801a9f:	89 e5                	mov    %esp,%ebp
  801aa1:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aa4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aa7:	50                   	push   %eax
  801aa8:	ff 75 08             	pushl  0x8(%ebp)
  801aab:	e8 b0 f3 ff ff       	call   800e60 <fd_lookup>
  801ab0:	83 c4 10             	add    $0x10,%esp
  801ab3:	85 c0                	test   %eax,%eax
  801ab5:	78 11                	js     801ac8 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801ab7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801aba:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801ac0:	39 10                	cmp    %edx,(%eax)
  801ac2:	0f 94 c0             	sete   %al
  801ac5:	0f b6 c0             	movzbl %al,%eax
}
  801ac8:	c9                   	leave  
  801ac9:	c3                   	ret    

00801aca <opencons>:
{
  801aca:	f3 0f 1e fb          	endbr32 
  801ace:	55                   	push   %ebp
  801acf:	89 e5                	mov    %esp,%ebp
  801ad1:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801ad4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ad7:	50                   	push   %eax
  801ad8:	e8 2d f3 ff ff       	call   800e0a <fd_alloc>
  801add:	83 c4 10             	add    $0x10,%esp
  801ae0:	85 c0                	test   %eax,%eax
  801ae2:	78 3a                	js     801b1e <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801ae4:	83 ec 04             	sub    $0x4,%esp
  801ae7:	68 07 04 00 00       	push   $0x407
  801aec:	ff 75 f4             	pushl  -0xc(%ebp)
  801aef:	6a 00                	push   $0x0
  801af1:	e8 21 f1 ff ff       	call   800c17 <sys_page_alloc>
  801af6:	83 c4 10             	add    $0x10,%esp
  801af9:	85 c0                	test   %eax,%eax
  801afb:	78 21                	js     801b1e <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801afd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b00:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801b06:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801b08:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b0b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801b12:	83 ec 0c             	sub    $0xc,%esp
  801b15:	50                   	push   %eax
  801b16:	e8 bc f2 ff ff       	call   800dd7 <fd2num>
  801b1b:	83 c4 10             	add    $0x10,%esp
}
  801b1e:	c9                   	leave  
  801b1f:	c3                   	ret    

00801b20 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801b20:	f3 0f 1e fb          	endbr32 
  801b24:	55                   	push   %ebp
  801b25:	89 e5                	mov    %esp,%ebp
  801b27:	56                   	push   %esi
  801b28:	53                   	push   %ebx
  801b29:	8b 75 08             	mov    0x8(%ebp),%esi
  801b2c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801b2f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  801b32:	85 c0                	test   %eax,%eax
  801b34:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801b39:	0f 44 c2             	cmove  %edx,%eax
  801b3c:	83 ec 0c             	sub    $0xc,%esp
  801b3f:	50                   	push   %eax
  801b40:	e8 e9 f1 ff ff       	call   800d2e <sys_ipc_recv>

	if (from_env_store != NULL)
  801b45:	83 c4 10             	add    $0x10,%esp
  801b48:	85 f6                	test   %esi,%esi
  801b4a:	74 15                	je     801b61 <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  801b4c:	ba 00 00 00 00       	mov    $0x0,%edx
  801b51:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801b54:	74 09                	je     801b5f <ipc_recv+0x3f>
  801b56:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b5c:	8b 52 74             	mov    0x74(%edx),%edx
  801b5f:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  801b61:	85 db                	test   %ebx,%ebx
  801b63:	74 15                	je     801b7a <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  801b65:	ba 00 00 00 00       	mov    $0x0,%edx
  801b6a:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801b6d:	74 09                	je     801b78 <ipc_recv+0x58>
  801b6f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801b75:	8b 52 78             	mov    0x78(%edx),%edx
  801b78:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  801b7a:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801b7d:	74 08                	je     801b87 <ipc_recv+0x67>
  801b7f:	a1 04 40 80 00       	mov    0x804004,%eax
  801b84:	8b 40 70             	mov    0x70(%eax),%eax
}
  801b87:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b8a:	5b                   	pop    %ebx
  801b8b:	5e                   	pop    %esi
  801b8c:	5d                   	pop    %ebp
  801b8d:	c3                   	ret    

00801b8e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801b8e:	f3 0f 1e fb          	endbr32 
  801b92:	55                   	push   %ebp
  801b93:	89 e5                	mov    %esp,%ebp
  801b95:	57                   	push   %edi
  801b96:	56                   	push   %esi
  801b97:	53                   	push   %ebx
  801b98:	83 ec 0c             	sub    $0xc,%esp
  801b9b:	8b 7d 08             	mov    0x8(%ebp),%edi
  801b9e:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ba1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ba4:	eb 1f                	jmp    801bc5 <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  801ba6:	6a 00                	push   $0x0
  801ba8:	68 00 00 c0 ee       	push   $0xeec00000
  801bad:	56                   	push   %esi
  801bae:	57                   	push   %edi
  801baf:	e8 51 f1 ff ff       	call   800d05 <sys_ipc_try_send>
  801bb4:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  801bb7:	85 c0                	test   %eax,%eax
  801bb9:	74 30                	je     801beb <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  801bbb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801bbe:	75 19                	jne    801bd9 <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  801bc0:	e8 27 f0 ff ff       	call   800bec <sys_yield>
		if (pg != NULL) {
  801bc5:	85 db                	test   %ebx,%ebx
  801bc7:	74 dd                	je     801ba6 <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  801bc9:	ff 75 14             	pushl  0x14(%ebp)
  801bcc:	53                   	push   %ebx
  801bcd:	56                   	push   %esi
  801bce:	57                   	push   %edi
  801bcf:	e8 31 f1 ff ff       	call   800d05 <sys_ipc_try_send>
  801bd4:	83 c4 10             	add    $0x10,%esp
  801bd7:	eb de                	jmp    801bb7 <ipc_send+0x29>
			panic("ipc_send: %d", res);
  801bd9:	50                   	push   %eax
  801bda:	68 be 23 80 00       	push   $0x8023be
  801bdf:	6a 3e                	push   $0x3e
  801be1:	68 cb 23 80 00       	push   $0x8023cb
  801be6:	e8 53 e5 ff ff       	call   80013e <_panic>
	}
}
  801beb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801bee:	5b                   	pop    %ebx
  801bef:	5e                   	pop    %esi
  801bf0:	5f                   	pop    %edi
  801bf1:	5d                   	pop    %ebp
  801bf2:	c3                   	ret    

00801bf3 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801bf3:	f3 0f 1e fb          	endbr32 
  801bf7:	55                   	push   %ebp
  801bf8:	89 e5                	mov    %esp,%ebp
  801bfa:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801bfd:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801c02:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801c05:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801c0b:	8b 52 50             	mov    0x50(%edx),%edx
  801c0e:	39 ca                	cmp    %ecx,%edx
  801c10:	74 11                	je     801c23 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801c12:	83 c0 01             	add    $0x1,%eax
  801c15:	3d 00 04 00 00       	cmp    $0x400,%eax
  801c1a:	75 e6                	jne    801c02 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801c1c:	b8 00 00 00 00       	mov    $0x0,%eax
  801c21:	eb 0b                	jmp    801c2e <ipc_find_env+0x3b>
			return envs[i].env_id;
  801c23:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801c26:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801c2b:	8b 40 48             	mov    0x48(%eax),%eax
}
  801c2e:	5d                   	pop    %ebp
  801c2f:	c3                   	ret    

00801c30 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801c30:	f3 0f 1e fb          	endbr32 
  801c34:	55                   	push   %ebp
  801c35:	89 e5                	mov    %esp,%ebp
  801c37:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801c3a:	89 c2                	mov    %eax,%edx
  801c3c:	c1 ea 16             	shr    $0x16,%edx
  801c3f:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801c46:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801c4b:	f6 c1 01             	test   $0x1,%cl
  801c4e:	74 1c                	je     801c6c <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801c50:	c1 e8 0c             	shr    $0xc,%eax
  801c53:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801c5a:	a8 01                	test   $0x1,%al
  801c5c:	74 0e                	je     801c6c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801c5e:	c1 e8 0c             	shr    $0xc,%eax
  801c61:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801c68:	ef 
  801c69:	0f b7 d2             	movzwl %dx,%edx
}
  801c6c:	89 d0                	mov    %edx,%eax
  801c6e:	5d                   	pop    %ebp
  801c6f:	c3                   	ret    

00801c70 <__udivdi3>:
  801c70:	f3 0f 1e fb          	endbr32 
  801c74:	55                   	push   %ebp
  801c75:	57                   	push   %edi
  801c76:	56                   	push   %esi
  801c77:	53                   	push   %ebx
  801c78:	83 ec 1c             	sub    $0x1c,%esp
  801c7b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c7f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801c83:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c87:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801c8b:	85 d2                	test   %edx,%edx
  801c8d:	75 19                	jne    801ca8 <__udivdi3+0x38>
  801c8f:	39 f3                	cmp    %esi,%ebx
  801c91:	76 4d                	jbe    801ce0 <__udivdi3+0x70>
  801c93:	31 ff                	xor    %edi,%edi
  801c95:	89 e8                	mov    %ebp,%eax
  801c97:	89 f2                	mov    %esi,%edx
  801c99:	f7 f3                	div    %ebx
  801c9b:	89 fa                	mov    %edi,%edx
  801c9d:	83 c4 1c             	add    $0x1c,%esp
  801ca0:	5b                   	pop    %ebx
  801ca1:	5e                   	pop    %esi
  801ca2:	5f                   	pop    %edi
  801ca3:	5d                   	pop    %ebp
  801ca4:	c3                   	ret    
  801ca5:	8d 76 00             	lea    0x0(%esi),%esi
  801ca8:	39 f2                	cmp    %esi,%edx
  801caa:	76 14                	jbe    801cc0 <__udivdi3+0x50>
  801cac:	31 ff                	xor    %edi,%edi
  801cae:	31 c0                	xor    %eax,%eax
  801cb0:	89 fa                	mov    %edi,%edx
  801cb2:	83 c4 1c             	add    $0x1c,%esp
  801cb5:	5b                   	pop    %ebx
  801cb6:	5e                   	pop    %esi
  801cb7:	5f                   	pop    %edi
  801cb8:	5d                   	pop    %ebp
  801cb9:	c3                   	ret    
  801cba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cc0:	0f bd fa             	bsr    %edx,%edi
  801cc3:	83 f7 1f             	xor    $0x1f,%edi
  801cc6:	75 48                	jne    801d10 <__udivdi3+0xa0>
  801cc8:	39 f2                	cmp    %esi,%edx
  801cca:	72 06                	jb     801cd2 <__udivdi3+0x62>
  801ccc:	31 c0                	xor    %eax,%eax
  801cce:	39 eb                	cmp    %ebp,%ebx
  801cd0:	77 de                	ja     801cb0 <__udivdi3+0x40>
  801cd2:	b8 01 00 00 00       	mov    $0x1,%eax
  801cd7:	eb d7                	jmp    801cb0 <__udivdi3+0x40>
  801cd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ce0:	89 d9                	mov    %ebx,%ecx
  801ce2:	85 db                	test   %ebx,%ebx
  801ce4:	75 0b                	jne    801cf1 <__udivdi3+0x81>
  801ce6:	b8 01 00 00 00       	mov    $0x1,%eax
  801ceb:	31 d2                	xor    %edx,%edx
  801ced:	f7 f3                	div    %ebx
  801cef:	89 c1                	mov    %eax,%ecx
  801cf1:	31 d2                	xor    %edx,%edx
  801cf3:	89 f0                	mov    %esi,%eax
  801cf5:	f7 f1                	div    %ecx
  801cf7:	89 c6                	mov    %eax,%esi
  801cf9:	89 e8                	mov    %ebp,%eax
  801cfb:	89 f7                	mov    %esi,%edi
  801cfd:	f7 f1                	div    %ecx
  801cff:	89 fa                	mov    %edi,%edx
  801d01:	83 c4 1c             	add    $0x1c,%esp
  801d04:	5b                   	pop    %ebx
  801d05:	5e                   	pop    %esi
  801d06:	5f                   	pop    %edi
  801d07:	5d                   	pop    %ebp
  801d08:	c3                   	ret    
  801d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d10:	89 f9                	mov    %edi,%ecx
  801d12:	b8 20 00 00 00       	mov    $0x20,%eax
  801d17:	29 f8                	sub    %edi,%eax
  801d19:	d3 e2                	shl    %cl,%edx
  801d1b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801d1f:	89 c1                	mov    %eax,%ecx
  801d21:	89 da                	mov    %ebx,%edx
  801d23:	d3 ea                	shr    %cl,%edx
  801d25:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d29:	09 d1                	or     %edx,%ecx
  801d2b:	89 f2                	mov    %esi,%edx
  801d2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d31:	89 f9                	mov    %edi,%ecx
  801d33:	d3 e3                	shl    %cl,%ebx
  801d35:	89 c1                	mov    %eax,%ecx
  801d37:	d3 ea                	shr    %cl,%edx
  801d39:	89 f9                	mov    %edi,%ecx
  801d3b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801d3f:	89 eb                	mov    %ebp,%ebx
  801d41:	d3 e6                	shl    %cl,%esi
  801d43:	89 c1                	mov    %eax,%ecx
  801d45:	d3 eb                	shr    %cl,%ebx
  801d47:	09 de                	or     %ebx,%esi
  801d49:	89 f0                	mov    %esi,%eax
  801d4b:	f7 74 24 08          	divl   0x8(%esp)
  801d4f:	89 d6                	mov    %edx,%esi
  801d51:	89 c3                	mov    %eax,%ebx
  801d53:	f7 64 24 0c          	mull   0xc(%esp)
  801d57:	39 d6                	cmp    %edx,%esi
  801d59:	72 15                	jb     801d70 <__udivdi3+0x100>
  801d5b:	89 f9                	mov    %edi,%ecx
  801d5d:	d3 e5                	shl    %cl,%ebp
  801d5f:	39 c5                	cmp    %eax,%ebp
  801d61:	73 04                	jae    801d67 <__udivdi3+0xf7>
  801d63:	39 d6                	cmp    %edx,%esi
  801d65:	74 09                	je     801d70 <__udivdi3+0x100>
  801d67:	89 d8                	mov    %ebx,%eax
  801d69:	31 ff                	xor    %edi,%edi
  801d6b:	e9 40 ff ff ff       	jmp    801cb0 <__udivdi3+0x40>
  801d70:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801d73:	31 ff                	xor    %edi,%edi
  801d75:	e9 36 ff ff ff       	jmp    801cb0 <__udivdi3+0x40>
  801d7a:	66 90                	xchg   %ax,%ax
  801d7c:	66 90                	xchg   %ax,%ax
  801d7e:	66 90                	xchg   %ax,%ax

00801d80 <__umoddi3>:
  801d80:	f3 0f 1e fb          	endbr32 
  801d84:	55                   	push   %ebp
  801d85:	57                   	push   %edi
  801d86:	56                   	push   %esi
  801d87:	53                   	push   %ebx
  801d88:	83 ec 1c             	sub    $0x1c,%esp
  801d8b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801d8f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801d93:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801d97:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801d9b:	85 c0                	test   %eax,%eax
  801d9d:	75 19                	jne    801db8 <__umoddi3+0x38>
  801d9f:	39 df                	cmp    %ebx,%edi
  801da1:	76 5d                	jbe    801e00 <__umoddi3+0x80>
  801da3:	89 f0                	mov    %esi,%eax
  801da5:	89 da                	mov    %ebx,%edx
  801da7:	f7 f7                	div    %edi
  801da9:	89 d0                	mov    %edx,%eax
  801dab:	31 d2                	xor    %edx,%edx
  801dad:	83 c4 1c             	add    $0x1c,%esp
  801db0:	5b                   	pop    %ebx
  801db1:	5e                   	pop    %esi
  801db2:	5f                   	pop    %edi
  801db3:	5d                   	pop    %ebp
  801db4:	c3                   	ret    
  801db5:	8d 76 00             	lea    0x0(%esi),%esi
  801db8:	89 f2                	mov    %esi,%edx
  801dba:	39 d8                	cmp    %ebx,%eax
  801dbc:	76 12                	jbe    801dd0 <__umoddi3+0x50>
  801dbe:	89 f0                	mov    %esi,%eax
  801dc0:	89 da                	mov    %ebx,%edx
  801dc2:	83 c4 1c             	add    $0x1c,%esp
  801dc5:	5b                   	pop    %ebx
  801dc6:	5e                   	pop    %esi
  801dc7:	5f                   	pop    %edi
  801dc8:	5d                   	pop    %ebp
  801dc9:	c3                   	ret    
  801dca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801dd0:	0f bd e8             	bsr    %eax,%ebp
  801dd3:	83 f5 1f             	xor    $0x1f,%ebp
  801dd6:	75 50                	jne    801e28 <__umoddi3+0xa8>
  801dd8:	39 d8                	cmp    %ebx,%eax
  801dda:	0f 82 e0 00 00 00    	jb     801ec0 <__umoddi3+0x140>
  801de0:	89 d9                	mov    %ebx,%ecx
  801de2:	39 f7                	cmp    %esi,%edi
  801de4:	0f 86 d6 00 00 00    	jbe    801ec0 <__umoddi3+0x140>
  801dea:	89 d0                	mov    %edx,%eax
  801dec:	89 ca                	mov    %ecx,%edx
  801dee:	83 c4 1c             	add    $0x1c,%esp
  801df1:	5b                   	pop    %ebx
  801df2:	5e                   	pop    %esi
  801df3:	5f                   	pop    %edi
  801df4:	5d                   	pop    %ebp
  801df5:	c3                   	ret    
  801df6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dfd:	8d 76 00             	lea    0x0(%esi),%esi
  801e00:	89 fd                	mov    %edi,%ebp
  801e02:	85 ff                	test   %edi,%edi
  801e04:	75 0b                	jne    801e11 <__umoddi3+0x91>
  801e06:	b8 01 00 00 00       	mov    $0x1,%eax
  801e0b:	31 d2                	xor    %edx,%edx
  801e0d:	f7 f7                	div    %edi
  801e0f:	89 c5                	mov    %eax,%ebp
  801e11:	89 d8                	mov    %ebx,%eax
  801e13:	31 d2                	xor    %edx,%edx
  801e15:	f7 f5                	div    %ebp
  801e17:	89 f0                	mov    %esi,%eax
  801e19:	f7 f5                	div    %ebp
  801e1b:	89 d0                	mov    %edx,%eax
  801e1d:	31 d2                	xor    %edx,%edx
  801e1f:	eb 8c                	jmp    801dad <__umoddi3+0x2d>
  801e21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e28:	89 e9                	mov    %ebp,%ecx
  801e2a:	ba 20 00 00 00       	mov    $0x20,%edx
  801e2f:	29 ea                	sub    %ebp,%edx
  801e31:	d3 e0                	shl    %cl,%eax
  801e33:	89 44 24 08          	mov    %eax,0x8(%esp)
  801e37:	89 d1                	mov    %edx,%ecx
  801e39:	89 f8                	mov    %edi,%eax
  801e3b:	d3 e8                	shr    %cl,%eax
  801e3d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801e41:	89 54 24 04          	mov    %edx,0x4(%esp)
  801e45:	8b 54 24 04          	mov    0x4(%esp),%edx
  801e49:	09 c1                	or     %eax,%ecx
  801e4b:	89 d8                	mov    %ebx,%eax
  801e4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801e51:	89 e9                	mov    %ebp,%ecx
  801e53:	d3 e7                	shl    %cl,%edi
  801e55:	89 d1                	mov    %edx,%ecx
  801e57:	d3 e8                	shr    %cl,%eax
  801e59:	89 e9                	mov    %ebp,%ecx
  801e5b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801e5f:	d3 e3                	shl    %cl,%ebx
  801e61:	89 c7                	mov    %eax,%edi
  801e63:	89 d1                	mov    %edx,%ecx
  801e65:	89 f0                	mov    %esi,%eax
  801e67:	d3 e8                	shr    %cl,%eax
  801e69:	89 e9                	mov    %ebp,%ecx
  801e6b:	89 fa                	mov    %edi,%edx
  801e6d:	d3 e6                	shl    %cl,%esi
  801e6f:	09 d8                	or     %ebx,%eax
  801e71:	f7 74 24 08          	divl   0x8(%esp)
  801e75:	89 d1                	mov    %edx,%ecx
  801e77:	89 f3                	mov    %esi,%ebx
  801e79:	f7 64 24 0c          	mull   0xc(%esp)
  801e7d:	89 c6                	mov    %eax,%esi
  801e7f:	89 d7                	mov    %edx,%edi
  801e81:	39 d1                	cmp    %edx,%ecx
  801e83:	72 06                	jb     801e8b <__umoddi3+0x10b>
  801e85:	75 10                	jne    801e97 <__umoddi3+0x117>
  801e87:	39 c3                	cmp    %eax,%ebx
  801e89:	73 0c                	jae    801e97 <__umoddi3+0x117>
  801e8b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801e8f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801e93:	89 d7                	mov    %edx,%edi
  801e95:	89 c6                	mov    %eax,%esi
  801e97:	89 ca                	mov    %ecx,%edx
  801e99:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801e9e:	29 f3                	sub    %esi,%ebx
  801ea0:	19 fa                	sbb    %edi,%edx
  801ea2:	89 d0                	mov    %edx,%eax
  801ea4:	d3 e0                	shl    %cl,%eax
  801ea6:	89 e9                	mov    %ebp,%ecx
  801ea8:	d3 eb                	shr    %cl,%ebx
  801eaa:	d3 ea                	shr    %cl,%edx
  801eac:	09 d8                	or     %ebx,%eax
  801eae:	83 c4 1c             	add    $0x1c,%esp
  801eb1:	5b                   	pop    %ebx
  801eb2:	5e                   	pop    %esi
  801eb3:	5f                   	pop    %edi
  801eb4:	5d                   	pop    %ebp
  801eb5:	c3                   	ret    
  801eb6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ebd:	8d 76 00             	lea    0x0(%esi),%esi
  801ec0:	29 fe                	sub    %edi,%esi
  801ec2:	19 c3                	sbb    %eax,%ebx
  801ec4:	89 f2                	mov    %esi,%edx
  801ec6:	89 d9                	mov    %ebx,%ecx
  801ec8:	e9 1d ff ff ff       	jmp    801dea <__umoddi3+0x6a>
