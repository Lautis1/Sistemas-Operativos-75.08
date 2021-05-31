
obj/user/faultio.debug:     formato del fichero elf32-i386


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
  80002c:	e8 54 00 00 00       	call   800085 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <outb>:
		     : "memory", "cc");
}

static inline void
outb(int port, uint8_t data)
{
  800033:	89 c1                	mov    %eax,%ecx
  800035:	89 d0                	mov    %edx,%eax
	asm volatile("outb %0,%w1" : : "a" (data), "d" (port));
  800037:	89 ca                	mov    %ecx,%edx
  800039:	ee                   	out    %al,(%dx)
}
  80003a:	c3                   	ret    

0080003b <read_eflags>:

static inline uint32_t
read_eflags(void)
{
	uint32_t eflags;
	asm volatile("pushfl; popl %0" : "=r" (eflags));
  80003b:	9c                   	pushf  
  80003c:	58                   	pop    %eax
	return eflags;
}
  80003d:	c3                   	ret    

0080003e <umain>:
#include <inc/lib.h>
#include <inc/x86.h>

void
umain(int argc, char **argv)
{
  80003e:	f3 0f 1e fb          	endbr32 
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	83 ec 08             	sub    $0x8,%esp
        int x, r;
	int nsecs = 1;
	int secno = 0;
	int diskno = 1;

	if (read_eflags() & FL_IOPL_3)
  800048:	e8 ee ff ff ff       	call   80003b <read_eflags>
  80004d:	f6 c4 30             	test   $0x30,%ah
  800050:	75 21                	jne    800073 <umain+0x35>
		cprintf("eflags wrong\n");

	// this outb to select disk 1 should result in a general protection
	// fault, because user-level code shouldn't be able to use the io space.
	outb(0x1F6, 0xE0 | (1<<4));
  800052:	ba f0 00 00 00       	mov    $0xf0,%edx
  800057:	b8 f6 01 00 00       	mov    $0x1f6,%eax
  80005c:	e8 d2 ff ff ff       	call   800033 <outb>

        cprintf("%s: made it here --- bug\n");
  800061:	83 ec 0c             	sub    $0xc,%esp
  800064:	68 0e 1e 80 00       	push   $0x801e0e
  800069:	e8 20 01 00 00       	call   80018e <cprintf>
}
  80006e:	83 c4 10             	add    $0x10,%esp
  800071:	c9                   	leave  
  800072:	c3                   	ret    
		cprintf("eflags wrong\n");
  800073:	83 ec 0c             	sub    $0xc,%esp
  800076:	68 00 1e 80 00       	push   $0x801e00
  80007b:	e8 0e 01 00 00       	call   80018e <cprintf>
  800080:	83 c4 10             	add    $0x10,%esp
  800083:	eb cd                	jmp    800052 <umain+0x14>

00800085 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800085:	f3 0f 1e fb          	endbr32 
  800089:	55                   	push   %ebp
  80008a:	89 e5                	mov    %esp,%ebp
  80008c:	56                   	push   %esi
  80008d:	53                   	push   %ebx
  80008e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800091:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800094:	e8 94 0a 00 00       	call   800b2d <sys_getenvid>
	if (id >= 0)
  800099:	85 c0                	test   %eax,%eax
  80009b:	78 12                	js     8000af <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  80009d:	25 ff 03 00 00       	and    $0x3ff,%eax
  8000a2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8000a5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8000aa:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8000af:	85 db                	test   %ebx,%ebx
  8000b1:	7e 07                	jle    8000ba <libmain+0x35>
		binaryname = argv[0];
  8000b3:	8b 06                	mov    (%esi),%eax
  8000b5:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  8000ba:	83 ec 08             	sub    $0x8,%esp
  8000bd:	56                   	push   %esi
  8000be:	53                   	push   %ebx
  8000bf:	e8 7a ff ff ff       	call   80003e <umain>

	// exit gracefully
	exit();
  8000c4:	e8 0a 00 00 00       	call   8000d3 <exit>
}
  8000c9:	83 c4 10             	add    $0x10,%esp
  8000cc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000cf:	5b                   	pop    %ebx
  8000d0:	5e                   	pop    %esi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000d3:	f3 0f 1e fb          	endbr32 
  8000d7:	55                   	push   %ebp
  8000d8:	89 e5                	mov    %esp,%ebp
  8000da:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000dd:	e8 ce 0d 00 00       	call   800eb0 <close_all>
	sys_env_destroy(0);
  8000e2:	83 ec 0c             	sub    $0xc,%esp
  8000e5:	6a 00                	push   $0x0
  8000e7:	e8 1b 0a 00 00       	call   800b07 <sys_env_destroy>
}
  8000ec:	83 c4 10             	add    $0x10,%esp
  8000ef:	c9                   	leave  
  8000f0:	c3                   	ret    

008000f1 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8000f1:	f3 0f 1e fb          	endbr32 
  8000f5:	55                   	push   %ebp
  8000f6:	89 e5                	mov    %esp,%ebp
  8000f8:	53                   	push   %ebx
  8000f9:	83 ec 04             	sub    $0x4,%esp
  8000fc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8000ff:	8b 13                	mov    (%ebx),%edx
  800101:	8d 42 01             	lea    0x1(%edx),%eax
  800104:	89 03                	mov    %eax,(%ebx)
  800106:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800109:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80010d:	3d ff 00 00 00       	cmp    $0xff,%eax
  800112:	74 09                	je     80011d <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800114:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800118:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80011b:	c9                   	leave  
  80011c:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80011d:	83 ec 08             	sub    $0x8,%esp
  800120:	68 ff 00 00 00       	push   $0xff
  800125:	8d 43 08             	lea    0x8(%ebx),%eax
  800128:	50                   	push   %eax
  800129:	e8 87 09 00 00       	call   800ab5 <sys_cputs>
		b->idx = 0;
  80012e:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800134:	83 c4 10             	add    $0x10,%esp
  800137:	eb db                	jmp    800114 <putch+0x23>

00800139 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800139:	f3 0f 1e fb          	endbr32 
  80013d:	55                   	push   %ebp
  80013e:	89 e5                	mov    %esp,%ebp
  800140:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800146:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80014d:	00 00 00 
	b.cnt = 0;
  800150:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800157:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80015a:	ff 75 0c             	pushl  0xc(%ebp)
  80015d:	ff 75 08             	pushl  0x8(%ebp)
  800160:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800166:	50                   	push   %eax
  800167:	68 f1 00 80 00       	push   $0x8000f1
  80016c:	e8 80 01 00 00       	call   8002f1 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800171:	83 c4 08             	add    $0x8,%esp
  800174:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80017a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800180:	50                   	push   %eax
  800181:	e8 2f 09 00 00       	call   800ab5 <sys_cputs>

	return b.cnt;
}
  800186:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80018c:	c9                   	leave  
  80018d:	c3                   	ret    

0080018e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80018e:	f3 0f 1e fb          	endbr32 
  800192:	55                   	push   %ebp
  800193:	89 e5                	mov    %esp,%ebp
  800195:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800198:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80019b:	50                   	push   %eax
  80019c:	ff 75 08             	pushl  0x8(%ebp)
  80019f:	e8 95 ff ff ff       	call   800139 <vcprintf>
	va_end(ap);

	return cnt;
}
  8001a4:	c9                   	leave  
  8001a5:	c3                   	ret    

008001a6 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 1c             	sub    $0x1c,%esp
  8001af:	89 c7                	mov    %eax,%edi
  8001b1:	89 d6                	mov    %edx,%esi
  8001b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8001b9:	89 d1                	mov    %edx,%ecx
  8001bb:	89 c2                	mov    %eax,%edx
  8001bd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001c0:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8001c3:	8b 45 10             	mov    0x10(%ebp),%eax
  8001c6:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8001c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001cc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8001d3:	39 c2                	cmp    %eax,%edx
  8001d5:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8001d8:	72 3e                	jb     800218 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8001da:	83 ec 0c             	sub    $0xc,%esp
  8001dd:	ff 75 18             	pushl  0x18(%ebp)
  8001e0:	83 eb 01             	sub    $0x1,%ebx
  8001e3:	53                   	push   %ebx
  8001e4:	50                   	push   %eax
  8001e5:	83 ec 08             	sub    $0x8,%esp
  8001e8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8001eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8001ee:	ff 75 dc             	pushl  -0x24(%ebp)
  8001f1:	ff 75 d8             	pushl  -0x28(%ebp)
  8001f4:	e8 a7 19 00 00       	call   801ba0 <__udivdi3>
  8001f9:	83 c4 18             	add    $0x18,%esp
  8001fc:	52                   	push   %edx
  8001fd:	50                   	push   %eax
  8001fe:	89 f2                	mov    %esi,%edx
  800200:	89 f8                	mov    %edi,%eax
  800202:	e8 9f ff ff ff       	call   8001a6 <printnum>
  800207:	83 c4 20             	add    $0x20,%esp
  80020a:	eb 13                	jmp    80021f <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80020c:	83 ec 08             	sub    $0x8,%esp
  80020f:	56                   	push   %esi
  800210:	ff 75 18             	pushl  0x18(%ebp)
  800213:	ff d7                	call   *%edi
  800215:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800218:	83 eb 01             	sub    $0x1,%ebx
  80021b:	85 db                	test   %ebx,%ebx
  80021d:	7f ed                	jg     80020c <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80021f:	83 ec 08             	sub    $0x8,%esp
  800222:	56                   	push   %esi
  800223:	83 ec 04             	sub    $0x4,%esp
  800226:	ff 75 e4             	pushl  -0x1c(%ebp)
  800229:	ff 75 e0             	pushl  -0x20(%ebp)
  80022c:	ff 75 dc             	pushl  -0x24(%ebp)
  80022f:	ff 75 d8             	pushl  -0x28(%ebp)
  800232:	e8 79 1a 00 00       	call   801cb0 <__umoddi3>
  800237:	83 c4 14             	add    $0x14,%esp
  80023a:	0f be 80 32 1e 80 00 	movsbl 0x801e32(%eax),%eax
  800241:	50                   	push   %eax
  800242:	ff d7                	call   *%edi
}
  800244:	83 c4 10             	add    $0x10,%esp
  800247:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80024a:	5b                   	pop    %ebx
  80024b:	5e                   	pop    %esi
  80024c:	5f                   	pop    %edi
  80024d:	5d                   	pop    %ebp
  80024e:	c3                   	ret    

0080024f <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80024f:	83 fa 01             	cmp    $0x1,%edx
  800252:	7f 13                	jg     800267 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800254:	85 d2                	test   %edx,%edx
  800256:	74 1c                	je     800274 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800258:	8b 10                	mov    (%eax),%edx
  80025a:	8d 4a 04             	lea    0x4(%edx),%ecx
  80025d:	89 08                	mov    %ecx,(%eax)
  80025f:	8b 02                	mov    (%edx),%eax
  800261:	ba 00 00 00 00       	mov    $0x0,%edx
  800266:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800267:	8b 10                	mov    (%eax),%edx
  800269:	8d 4a 08             	lea    0x8(%edx),%ecx
  80026c:	89 08                	mov    %ecx,(%eax)
  80026e:	8b 02                	mov    (%edx),%eax
  800270:	8b 52 04             	mov    0x4(%edx),%edx
  800273:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800274:	8b 10                	mov    (%eax),%edx
  800276:	8d 4a 04             	lea    0x4(%edx),%ecx
  800279:	89 08                	mov    %ecx,(%eax)
  80027b:	8b 02                	mov    (%edx),%eax
  80027d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800282:	c3                   	ret    

00800283 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800283:	83 fa 01             	cmp    $0x1,%edx
  800286:	7f 0f                	jg     800297 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800288:	85 d2                	test   %edx,%edx
  80028a:	74 18                	je     8002a4 <getint+0x21>
		return va_arg(*ap, long);
  80028c:	8b 10                	mov    (%eax),%edx
  80028e:	8d 4a 04             	lea    0x4(%edx),%ecx
  800291:	89 08                	mov    %ecx,(%eax)
  800293:	8b 02                	mov    (%edx),%eax
  800295:	99                   	cltd   
  800296:	c3                   	ret    
		return va_arg(*ap, long long);
  800297:	8b 10                	mov    (%eax),%edx
  800299:	8d 4a 08             	lea    0x8(%edx),%ecx
  80029c:	89 08                	mov    %ecx,(%eax)
  80029e:	8b 02                	mov    (%edx),%eax
  8002a0:	8b 52 04             	mov    0x4(%edx),%edx
  8002a3:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8002a4:	8b 10                	mov    (%eax),%edx
  8002a6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8002a9:	89 08                	mov    %ecx,(%eax)
  8002ab:	8b 02                	mov    (%edx),%eax
  8002ad:	99                   	cltd   
}
  8002ae:	c3                   	ret    

008002af <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8002af:	f3 0f 1e fb          	endbr32 
  8002b3:	55                   	push   %ebp
  8002b4:	89 e5                	mov    %esp,%ebp
  8002b6:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8002b9:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8002bd:	8b 10                	mov    (%eax),%edx
  8002bf:	3b 50 04             	cmp    0x4(%eax),%edx
  8002c2:	73 0a                	jae    8002ce <sprintputch+0x1f>
		*b->buf++ = ch;
  8002c4:	8d 4a 01             	lea    0x1(%edx),%ecx
  8002c7:	89 08                	mov    %ecx,(%eax)
  8002c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8002cc:	88 02                	mov    %al,(%edx)
}
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <printfmt>:
{
  8002d0:	f3 0f 1e fb          	endbr32 
  8002d4:	55                   	push   %ebp
  8002d5:	89 e5                	mov    %esp,%ebp
  8002d7:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8002da:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8002dd:	50                   	push   %eax
  8002de:	ff 75 10             	pushl  0x10(%ebp)
  8002e1:	ff 75 0c             	pushl  0xc(%ebp)
  8002e4:	ff 75 08             	pushl  0x8(%ebp)
  8002e7:	e8 05 00 00 00       	call   8002f1 <vprintfmt>
}
  8002ec:	83 c4 10             	add    $0x10,%esp
  8002ef:	c9                   	leave  
  8002f0:	c3                   	ret    

008002f1 <vprintfmt>:
{
  8002f1:	f3 0f 1e fb          	endbr32 
  8002f5:	55                   	push   %ebp
  8002f6:	89 e5                	mov    %esp,%ebp
  8002f8:	57                   	push   %edi
  8002f9:	56                   	push   %esi
  8002fa:	53                   	push   %ebx
  8002fb:	83 ec 2c             	sub    $0x2c,%esp
  8002fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800301:	8b 75 0c             	mov    0xc(%ebp),%esi
  800304:	8b 7d 10             	mov    0x10(%ebp),%edi
  800307:	e9 86 02 00 00       	jmp    800592 <vprintfmt+0x2a1>
		padc = ' ';
  80030c:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800310:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800317:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80031e:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800325:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80032a:	8d 47 01             	lea    0x1(%edi),%eax
  80032d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800330:	0f b6 17             	movzbl (%edi),%edx
  800333:	8d 42 dd             	lea    -0x23(%edx),%eax
  800336:	3c 55                	cmp    $0x55,%al
  800338:	0f 87 df 02 00 00    	ja     80061d <vprintfmt+0x32c>
  80033e:	0f b6 c0             	movzbl %al,%eax
  800341:	3e ff 24 85 80 1f 80 	notrack jmp *0x801f80(,%eax,4)
  800348:	00 
  800349:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80034c:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800350:	eb d8                	jmp    80032a <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800352:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800355:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800359:	eb cf                	jmp    80032a <vprintfmt+0x39>
  80035b:	0f b6 d2             	movzbl %dl,%edx
  80035e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800361:	b8 00 00 00 00       	mov    $0x0,%eax
  800366:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800369:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80036c:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800370:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800373:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800376:	83 f9 09             	cmp    $0x9,%ecx
  800379:	77 52                	ja     8003cd <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  80037b:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80037e:	eb e9                	jmp    800369 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800380:	8b 45 14             	mov    0x14(%ebp),%eax
  800383:	8d 50 04             	lea    0x4(%eax),%edx
  800386:	89 55 14             	mov    %edx,0x14(%ebp)
  800389:	8b 00                	mov    (%eax),%eax
  80038b:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80038e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800391:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800395:	79 93                	jns    80032a <vprintfmt+0x39>
				width = precision, precision = -1;
  800397:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80039a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80039d:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8003a4:	eb 84                	jmp    80032a <vprintfmt+0x39>
  8003a6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8003a9:	85 c0                	test   %eax,%eax
  8003ab:	ba 00 00 00 00       	mov    $0x0,%edx
  8003b0:	0f 49 d0             	cmovns %eax,%edx
  8003b3:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8003b6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003b9:	e9 6c ff ff ff       	jmp    80032a <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8003be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8003c1:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8003c8:	e9 5d ff ff ff       	jmp    80032a <vprintfmt+0x39>
  8003cd:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003d0:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8003d3:	eb bc                	jmp    800391 <vprintfmt+0xa0>
			lflag++;
  8003d5:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8003d8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8003db:	e9 4a ff ff ff       	jmp    80032a <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8003e0:	8b 45 14             	mov    0x14(%ebp),%eax
  8003e3:	8d 50 04             	lea    0x4(%eax),%edx
  8003e6:	89 55 14             	mov    %edx,0x14(%ebp)
  8003e9:	83 ec 08             	sub    $0x8,%esp
  8003ec:	56                   	push   %esi
  8003ed:	ff 30                	pushl  (%eax)
  8003ef:	ff d3                	call   *%ebx
			break;
  8003f1:	83 c4 10             	add    $0x10,%esp
  8003f4:	e9 96 01 00 00       	jmp    80058f <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8003f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8003fc:	8d 50 04             	lea    0x4(%eax),%edx
  8003ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800402:	8b 00                	mov    (%eax),%eax
  800404:	99                   	cltd   
  800405:	31 d0                	xor    %edx,%eax
  800407:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800409:	83 f8 0f             	cmp    $0xf,%eax
  80040c:	7f 20                	jg     80042e <vprintfmt+0x13d>
  80040e:	8b 14 85 e0 20 80 00 	mov    0x8020e0(,%eax,4),%edx
  800415:	85 d2                	test   %edx,%edx
  800417:	74 15                	je     80042e <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  800419:	52                   	push   %edx
  80041a:	68 11 22 80 00       	push   $0x802211
  80041f:	56                   	push   %esi
  800420:	53                   	push   %ebx
  800421:	e8 aa fe ff ff       	call   8002d0 <printfmt>
  800426:	83 c4 10             	add    $0x10,%esp
  800429:	e9 61 01 00 00       	jmp    80058f <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  80042e:	50                   	push   %eax
  80042f:	68 4a 1e 80 00       	push   $0x801e4a
  800434:	56                   	push   %esi
  800435:	53                   	push   %ebx
  800436:	e8 95 fe ff ff       	call   8002d0 <printfmt>
  80043b:	83 c4 10             	add    $0x10,%esp
  80043e:	e9 4c 01 00 00       	jmp    80058f <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  800443:	8b 45 14             	mov    0x14(%ebp),%eax
  800446:	8d 50 04             	lea    0x4(%eax),%edx
  800449:	89 55 14             	mov    %edx,0x14(%ebp)
  80044c:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  80044e:	85 c9                	test   %ecx,%ecx
  800450:	b8 43 1e 80 00       	mov    $0x801e43,%eax
  800455:	0f 45 c1             	cmovne %ecx,%eax
  800458:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80045b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80045f:	7e 06                	jle    800467 <vprintfmt+0x176>
  800461:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800465:	75 0d                	jne    800474 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  800467:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80046a:	89 c7                	mov    %eax,%edi
  80046c:	03 45 e0             	add    -0x20(%ebp),%eax
  80046f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800472:	eb 57                	jmp    8004cb <vprintfmt+0x1da>
  800474:	83 ec 08             	sub    $0x8,%esp
  800477:	ff 75 d8             	pushl  -0x28(%ebp)
  80047a:	ff 75 cc             	pushl  -0x34(%ebp)
  80047d:	e8 4f 02 00 00       	call   8006d1 <strnlen>
  800482:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800485:	29 c2                	sub    %eax,%edx
  800487:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80048a:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80048d:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800491:	89 5d 08             	mov    %ebx,0x8(%ebp)
  800494:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800496:	85 db                	test   %ebx,%ebx
  800498:	7e 10                	jle    8004aa <vprintfmt+0x1b9>
					putch(padc, putdat);
  80049a:	83 ec 08             	sub    $0x8,%esp
  80049d:	56                   	push   %esi
  80049e:	57                   	push   %edi
  80049f:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8004a2:	83 eb 01             	sub    $0x1,%ebx
  8004a5:	83 c4 10             	add    $0x10,%esp
  8004a8:	eb ec                	jmp    800496 <vprintfmt+0x1a5>
  8004aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004ad:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8004b0:	85 d2                	test   %edx,%edx
  8004b2:	b8 00 00 00 00       	mov    $0x0,%eax
  8004b7:	0f 49 c2             	cmovns %edx,%eax
  8004ba:	29 c2                	sub    %eax,%edx
  8004bc:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8004bf:	eb a6                	jmp    800467 <vprintfmt+0x176>
					putch(ch, putdat);
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	56                   	push   %esi
  8004c5:	52                   	push   %edx
  8004c6:	ff d3                	call   *%ebx
  8004c8:	83 c4 10             	add    $0x10,%esp
  8004cb:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8004ce:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8004d0:	83 c7 01             	add    $0x1,%edi
  8004d3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8004d7:	0f be d0             	movsbl %al,%edx
  8004da:	85 d2                	test   %edx,%edx
  8004dc:	74 42                	je     800520 <vprintfmt+0x22f>
  8004de:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8004e2:	78 06                	js     8004ea <vprintfmt+0x1f9>
  8004e4:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8004e8:	78 1e                	js     800508 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  8004ea:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8004ee:	74 d1                	je     8004c1 <vprintfmt+0x1d0>
  8004f0:	0f be c0             	movsbl %al,%eax
  8004f3:	83 e8 20             	sub    $0x20,%eax
  8004f6:	83 f8 5e             	cmp    $0x5e,%eax
  8004f9:	76 c6                	jbe    8004c1 <vprintfmt+0x1d0>
					putch('?', putdat);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	56                   	push   %esi
  8004ff:	6a 3f                	push   $0x3f
  800501:	ff d3                	call   *%ebx
  800503:	83 c4 10             	add    $0x10,%esp
  800506:	eb c3                	jmp    8004cb <vprintfmt+0x1da>
  800508:	89 cf                	mov    %ecx,%edi
  80050a:	eb 0e                	jmp    80051a <vprintfmt+0x229>
				putch(' ', putdat);
  80050c:	83 ec 08             	sub    $0x8,%esp
  80050f:	56                   	push   %esi
  800510:	6a 20                	push   $0x20
  800512:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800514:	83 ef 01             	sub    $0x1,%edi
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	85 ff                	test   %edi,%edi
  80051c:	7f ee                	jg     80050c <vprintfmt+0x21b>
  80051e:	eb 6f                	jmp    80058f <vprintfmt+0x29e>
  800520:	89 cf                	mov    %ecx,%edi
  800522:	eb f6                	jmp    80051a <vprintfmt+0x229>
			num = getint(&ap, lflag);
  800524:	89 ca                	mov    %ecx,%edx
  800526:	8d 45 14             	lea    0x14(%ebp),%eax
  800529:	e8 55 fd ff ff       	call   800283 <getint>
  80052e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800531:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800534:	85 d2                	test   %edx,%edx
  800536:	78 0b                	js     800543 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  800538:	89 d1                	mov    %edx,%ecx
  80053a:	89 c2                	mov    %eax,%edx
			base = 10;
  80053c:	b8 0a 00 00 00       	mov    $0xa,%eax
  800541:	eb 32                	jmp    800575 <vprintfmt+0x284>
				putch('-', putdat);
  800543:	83 ec 08             	sub    $0x8,%esp
  800546:	56                   	push   %esi
  800547:	6a 2d                	push   $0x2d
  800549:	ff d3                	call   *%ebx
				num = -(long long) num;
  80054b:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80054e:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800551:	f7 da                	neg    %edx
  800553:	83 d1 00             	adc    $0x0,%ecx
  800556:	f7 d9                	neg    %ecx
  800558:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80055b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800560:	eb 13                	jmp    800575 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800562:	89 ca                	mov    %ecx,%edx
  800564:	8d 45 14             	lea    0x14(%ebp),%eax
  800567:	e8 e3 fc ff ff       	call   80024f <getuint>
  80056c:	89 d1                	mov    %edx,%ecx
  80056e:	89 c2                	mov    %eax,%edx
			base = 10;
  800570:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  800575:	83 ec 0c             	sub    $0xc,%esp
  800578:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80057c:	57                   	push   %edi
  80057d:	ff 75 e0             	pushl  -0x20(%ebp)
  800580:	50                   	push   %eax
  800581:	51                   	push   %ecx
  800582:	52                   	push   %edx
  800583:	89 f2                	mov    %esi,%edx
  800585:	89 d8                	mov    %ebx,%eax
  800587:	e8 1a fc ff ff       	call   8001a6 <printnum>
			break;
  80058c:	83 c4 20             	add    $0x20,%esp
{
  80058f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800592:	83 c7 01             	add    $0x1,%edi
  800595:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800599:	83 f8 25             	cmp    $0x25,%eax
  80059c:	0f 84 6a fd ff ff    	je     80030c <vprintfmt+0x1b>
			if (ch == '\0')
  8005a2:	85 c0                	test   %eax,%eax
  8005a4:	0f 84 93 00 00 00    	je     80063d <vprintfmt+0x34c>
			putch(ch, putdat);
  8005aa:	83 ec 08             	sub    $0x8,%esp
  8005ad:	56                   	push   %esi
  8005ae:	50                   	push   %eax
  8005af:	ff d3                	call   *%ebx
  8005b1:	83 c4 10             	add    $0x10,%esp
  8005b4:	eb dc                	jmp    800592 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  8005b6:	89 ca                	mov    %ecx,%edx
  8005b8:	8d 45 14             	lea    0x14(%ebp),%eax
  8005bb:	e8 8f fc ff ff       	call   80024f <getuint>
  8005c0:	89 d1                	mov    %edx,%ecx
  8005c2:	89 c2                	mov    %eax,%edx
			base = 8;
  8005c4:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8005c9:	eb aa                	jmp    800575 <vprintfmt+0x284>
			putch('0', putdat);
  8005cb:	83 ec 08             	sub    $0x8,%esp
  8005ce:	56                   	push   %esi
  8005cf:	6a 30                	push   $0x30
  8005d1:	ff d3                	call   *%ebx
			putch('x', putdat);
  8005d3:	83 c4 08             	add    $0x8,%esp
  8005d6:	56                   	push   %esi
  8005d7:	6a 78                	push   $0x78
  8005d9:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  8005db:	8b 45 14             	mov    0x14(%ebp),%eax
  8005de:	8d 50 04             	lea    0x4(%eax),%edx
  8005e1:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8005e4:	8b 10                	mov    (%eax),%edx
  8005e6:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8005eb:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8005ee:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8005f3:	eb 80                	jmp    800575 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8005f5:	89 ca                	mov    %ecx,%edx
  8005f7:	8d 45 14             	lea    0x14(%ebp),%eax
  8005fa:	e8 50 fc ff ff       	call   80024f <getuint>
  8005ff:	89 d1                	mov    %edx,%ecx
  800601:	89 c2                	mov    %eax,%edx
			base = 16;
  800603:	b8 10 00 00 00       	mov    $0x10,%eax
  800608:	e9 68 ff ff ff       	jmp    800575 <vprintfmt+0x284>
			putch(ch, putdat);
  80060d:	83 ec 08             	sub    $0x8,%esp
  800610:	56                   	push   %esi
  800611:	6a 25                	push   $0x25
  800613:	ff d3                	call   *%ebx
			break;
  800615:	83 c4 10             	add    $0x10,%esp
  800618:	e9 72 ff ff ff       	jmp    80058f <vprintfmt+0x29e>
			putch('%', putdat);
  80061d:	83 ec 08             	sub    $0x8,%esp
  800620:	56                   	push   %esi
  800621:	6a 25                	push   $0x25
  800623:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800625:	83 c4 10             	add    $0x10,%esp
  800628:	89 f8                	mov    %edi,%eax
  80062a:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80062e:	74 05                	je     800635 <vprintfmt+0x344>
  800630:	83 e8 01             	sub    $0x1,%eax
  800633:	eb f5                	jmp    80062a <vprintfmt+0x339>
  800635:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800638:	e9 52 ff ff ff       	jmp    80058f <vprintfmt+0x29e>
}
  80063d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800640:	5b                   	pop    %ebx
  800641:	5e                   	pop    %esi
  800642:	5f                   	pop    %edi
  800643:	5d                   	pop    %ebp
  800644:	c3                   	ret    

00800645 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800645:	f3 0f 1e fb          	endbr32 
  800649:	55                   	push   %ebp
  80064a:	89 e5                	mov    %esp,%ebp
  80064c:	83 ec 18             	sub    $0x18,%esp
  80064f:	8b 45 08             	mov    0x8(%ebp),%eax
  800652:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800655:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800658:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80065c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80065f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800666:	85 c0                	test   %eax,%eax
  800668:	74 26                	je     800690 <vsnprintf+0x4b>
  80066a:	85 d2                	test   %edx,%edx
  80066c:	7e 22                	jle    800690 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80066e:	ff 75 14             	pushl  0x14(%ebp)
  800671:	ff 75 10             	pushl  0x10(%ebp)
  800674:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800677:	50                   	push   %eax
  800678:	68 af 02 80 00       	push   $0x8002af
  80067d:	e8 6f fc ff ff       	call   8002f1 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800682:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800685:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800688:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068b:	83 c4 10             	add    $0x10,%esp
}
  80068e:	c9                   	leave  
  80068f:	c3                   	ret    
		return -E_INVAL;
  800690:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800695:	eb f7                	jmp    80068e <vsnprintf+0x49>

00800697 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800697:	f3 0f 1e fb          	endbr32 
  80069b:	55                   	push   %ebp
  80069c:	89 e5                	mov    %esp,%ebp
  80069e:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8006a1:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8006a4:	50                   	push   %eax
  8006a5:	ff 75 10             	pushl  0x10(%ebp)
  8006a8:	ff 75 0c             	pushl  0xc(%ebp)
  8006ab:	ff 75 08             	pushl  0x8(%ebp)
  8006ae:	e8 92 ff ff ff       	call   800645 <vsnprintf>
	va_end(ap);

	return rc;
}
  8006b3:	c9                   	leave  
  8006b4:	c3                   	ret    

008006b5 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8006b5:	f3 0f 1e fb          	endbr32 
  8006b9:	55                   	push   %ebp
  8006ba:	89 e5                	mov    %esp,%ebp
  8006bc:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8006bf:	b8 00 00 00 00       	mov    $0x0,%eax
  8006c4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8006c8:	74 05                	je     8006cf <strlen+0x1a>
		n++;
  8006ca:	83 c0 01             	add    $0x1,%eax
  8006cd:	eb f5                	jmp    8006c4 <strlen+0xf>
	return n;
}
  8006cf:	5d                   	pop    %ebp
  8006d0:	c3                   	ret    

008006d1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8006d1:	f3 0f 1e fb          	endbr32 
  8006d5:	55                   	push   %ebp
  8006d6:	89 e5                	mov    %esp,%ebp
  8006d8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8006db:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8006de:	b8 00 00 00 00       	mov    $0x0,%eax
  8006e3:	39 d0                	cmp    %edx,%eax
  8006e5:	74 0d                	je     8006f4 <strnlen+0x23>
  8006e7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8006eb:	74 05                	je     8006f2 <strnlen+0x21>
		n++;
  8006ed:	83 c0 01             	add    $0x1,%eax
  8006f0:	eb f1                	jmp    8006e3 <strnlen+0x12>
  8006f2:	89 c2                	mov    %eax,%edx
	return n;
}
  8006f4:	89 d0                	mov    %edx,%eax
  8006f6:	5d                   	pop    %ebp
  8006f7:	c3                   	ret    

008006f8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8006f8:	f3 0f 1e fb          	endbr32 
  8006fc:	55                   	push   %ebp
  8006fd:	89 e5                	mov    %esp,%ebp
  8006ff:	53                   	push   %ebx
  800700:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800703:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800706:	b8 00 00 00 00       	mov    $0x0,%eax
  80070b:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80070f:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800712:	83 c0 01             	add    $0x1,%eax
  800715:	84 d2                	test   %dl,%dl
  800717:	75 f2                	jne    80070b <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800719:	89 c8                	mov    %ecx,%eax
  80071b:	5b                   	pop    %ebx
  80071c:	5d                   	pop    %ebp
  80071d:	c3                   	ret    

0080071e <strcat>:

char *
strcat(char *dst, const char *src)
{
  80071e:	f3 0f 1e fb          	endbr32 
  800722:	55                   	push   %ebp
  800723:	89 e5                	mov    %esp,%ebp
  800725:	53                   	push   %ebx
  800726:	83 ec 10             	sub    $0x10,%esp
  800729:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80072c:	53                   	push   %ebx
  80072d:	e8 83 ff ff ff       	call   8006b5 <strlen>
  800732:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800735:	ff 75 0c             	pushl  0xc(%ebp)
  800738:	01 d8                	add    %ebx,%eax
  80073a:	50                   	push   %eax
  80073b:	e8 b8 ff ff ff       	call   8006f8 <strcpy>
	return dst;
}
  800740:	89 d8                	mov    %ebx,%eax
  800742:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800745:	c9                   	leave  
  800746:	c3                   	ret    

00800747 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800747:	f3 0f 1e fb          	endbr32 
  80074b:	55                   	push   %ebp
  80074c:	89 e5                	mov    %esp,%ebp
  80074e:	56                   	push   %esi
  80074f:	53                   	push   %ebx
  800750:	8b 75 08             	mov    0x8(%ebp),%esi
  800753:	8b 55 0c             	mov    0xc(%ebp),%edx
  800756:	89 f3                	mov    %esi,%ebx
  800758:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80075b:	89 f0                	mov    %esi,%eax
  80075d:	39 d8                	cmp    %ebx,%eax
  80075f:	74 11                	je     800772 <strncpy+0x2b>
		*dst++ = *src;
  800761:	83 c0 01             	add    $0x1,%eax
  800764:	0f b6 0a             	movzbl (%edx),%ecx
  800767:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80076a:	80 f9 01             	cmp    $0x1,%cl
  80076d:	83 da ff             	sbb    $0xffffffff,%edx
  800770:	eb eb                	jmp    80075d <strncpy+0x16>
	}
	return ret;
}
  800772:	89 f0                	mov    %esi,%eax
  800774:	5b                   	pop    %ebx
  800775:	5e                   	pop    %esi
  800776:	5d                   	pop    %ebp
  800777:	c3                   	ret    

00800778 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800778:	f3 0f 1e fb          	endbr32 
  80077c:	55                   	push   %ebp
  80077d:	89 e5                	mov    %esp,%ebp
  80077f:	56                   	push   %esi
  800780:	53                   	push   %ebx
  800781:	8b 75 08             	mov    0x8(%ebp),%esi
  800784:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800787:	8b 55 10             	mov    0x10(%ebp),%edx
  80078a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80078c:	85 d2                	test   %edx,%edx
  80078e:	74 21                	je     8007b1 <strlcpy+0x39>
  800790:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800794:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800796:	39 c2                	cmp    %eax,%edx
  800798:	74 14                	je     8007ae <strlcpy+0x36>
  80079a:	0f b6 19             	movzbl (%ecx),%ebx
  80079d:	84 db                	test   %bl,%bl
  80079f:	74 0b                	je     8007ac <strlcpy+0x34>
			*dst++ = *src++;
  8007a1:	83 c1 01             	add    $0x1,%ecx
  8007a4:	83 c2 01             	add    $0x1,%edx
  8007a7:	88 5a ff             	mov    %bl,-0x1(%edx)
  8007aa:	eb ea                	jmp    800796 <strlcpy+0x1e>
  8007ac:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8007ae:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8007b1:	29 f0                	sub    %esi,%eax
}
  8007b3:	5b                   	pop    %ebx
  8007b4:	5e                   	pop    %esi
  8007b5:	5d                   	pop    %ebp
  8007b6:	c3                   	ret    

008007b7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8007b7:	f3 0f 1e fb          	endbr32 
  8007bb:	55                   	push   %ebp
  8007bc:	89 e5                	mov    %esp,%ebp
  8007be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8007c1:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8007c4:	0f b6 01             	movzbl (%ecx),%eax
  8007c7:	84 c0                	test   %al,%al
  8007c9:	74 0c                	je     8007d7 <strcmp+0x20>
  8007cb:	3a 02                	cmp    (%edx),%al
  8007cd:	75 08                	jne    8007d7 <strcmp+0x20>
		p++, q++;
  8007cf:	83 c1 01             	add    $0x1,%ecx
  8007d2:	83 c2 01             	add    $0x1,%edx
  8007d5:	eb ed                	jmp    8007c4 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8007d7:	0f b6 c0             	movzbl %al,%eax
  8007da:	0f b6 12             	movzbl (%edx),%edx
  8007dd:	29 d0                	sub    %edx,%eax
}
  8007df:	5d                   	pop    %ebp
  8007e0:	c3                   	ret    

008007e1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8007e1:	f3 0f 1e fb          	endbr32 
  8007e5:	55                   	push   %ebp
  8007e6:	89 e5                	mov    %esp,%ebp
  8007e8:	53                   	push   %ebx
  8007e9:	8b 45 08             	mov    0x8(%ebp),%eax
  8007ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ef:	89 c3                	mov    %eax,%ebx
  8007f1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8007f4:	eb 06                	jmp    8007fc <strncmp+0x1b>
		n--, p++, q++;
  8007f6:	83 c0 01             	add    $0x1,%eax
  8007f9:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8007fc:	39 d8                	cmp    %ebx,%eax
  8007fe:	74 16                	je     800816 <strncmp+0x35>
  800800:	0f b6 08             	movzbl (%eax),%ecx
  800803:	84 c9                	test   %cl,%cl
  800805:	74 04                	je     80080b <strncmp+0x2a>
  800807:	3a 0a                	cmp    (%edx),%cl
  800809:	74 eb                	je     8007f6 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80080b:	0f b6 00             	movzbl (%eax),%eax
  80080e:	0f b6 12             	movzbl (%edx),%edx
  800811:	29 d0                	sub    %edx,%eax
}
  800813:	5b                   	pop    %ebx
  800814:	5d                   	pop    %ebp
  800815:	c3                   	ret    
		return 0;
  800816:	b8 00 00 00 00       	mov    $0x0,%eax
  80081b:	eb f6                	jmp    800813 <strncmp+0x32>

0080081d <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80081d:	f3 0f 1e fb          	endbr32 
  800821:	55                   	push   %ebp
  800822:	89 e5                	mov    %esp,%ebp
  800824:	8b 45 08             	mov    0x8(%ebp),%eax
  800827:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80082b:	0f b6 10             	movzbl (%eax),%edx
  80082e:	84 d2                	test   %dl,%dl
  800830:	74 09                	je     80083b <strchr+0x1e>
		if (*s == c)
  800832:	38 ca                	cmp    %cl,%dl
  800834:	74 0a                	je     800840 <strchr+0x23>
	for (; *s; s++)
  800836:	83 c0 01             	add    $0x1,%eax
  800839:	eb f0                	jmp    80082b <strchr+0xe>
			return (char *) s;
	return 0;
  80083b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800840:	5d                   	pop    %ebp
  800841:	c3                   	ret    

00800842 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800842:	f3 0f 1e fb          	endbr32 
  800846:	55                   	push   %ebp
  800847:	89 e5                	mov    %esp,%ebp
  800849:	8b 45 08             	mov    0x8(%ebp),%eax
  80084c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800850:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800853:	38 ca                	cmp    %cl,%dl
  800855:	74 09                	je     800860 <strfind+0x1e>
  800857:	84 d2                	test   %dl,%dl
  800859:	74 05                	je     800860 <strfind+0x1e>
	for (; *s; s++)
  80085b:	83 c0 01             	add    $0x1,%eax
  80085e:	eb f0                	jmp    800850 <strfind+0xe>
			break;
	return (char *) s;
}
  800860:	5d                   	pop    %ebp
  800861:	c3                   	ret    

00800862 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800862:	f3 0f 1e fb          	endbr32 
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	57                   	push   %edi
  80086a:	56                   	push   %esi
  80086b:	53                   	push   %ebx
  80086c:	8b 55 08             	mov    0x8(%ebp),%edx
  80086f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800872:	85 c9                	test   %ecx,%ecx
  800874:	74 33                	je     8008a9 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800876:	89 d0                	mov    %edx,%eax
  800878:	09 c8                	or     %ecx,%eax
  80087a:	a8 03                	test   $0x3,%al
  80087c:	75 23                	jne    8008a1 <memset+0x3f>
		c &= 0xFF;
  80087e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800882:	89 d8                	mov    %ebx,%eax
  800884:	c1 e0 08             	shl    $0x8,%eax
  800887:	89 df                	mov    %ebx,%edi
  800889:	c1 e7 18             	shl    $0x18,%edi
  80088c:	89 de                	mov    %ebx,%esi
  80088e:	c1 e6 10             	shl    $0x10,%esi
  800891:	09 f7                	or     %esi,%edi
  800893:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800895:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800898:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  80089a:	89 d7                	mov    %edx,%edi
  80089c:	fc                   	cld    
  80089d:	f3 ab                	rep stos %eax,%es:(%edi)
  80089f:	eb 08                	jmp    8008a9 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8008a1:	89 d7                	mov    %edx,%edi
  8008a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8008a6:	fc                   	cld    
  8008a7:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  8008a9:	89 d0                	mov    %edx,%eax
  8008ab:	5b                   	pop    %ebx
  8008ac:	5e                   	pop    %esi
  8008ad:	5f                   	pop    %edi
  8008ae:	5d                   	pop    %ebp
  8008af:	c3                   	ret    

008008b0 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8008b0:	f3 0f 1e fb          	endbr32 
  8008b4:	55                   	push   %ebp
  8008b5:	89 e5                	mov    %esp,%ebp
  8008b7:	57                   	push   %edi
  8008b8:	56                   	push   %esi
  8008b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8008bc:	8b 75 0c             	mov    0xc(%ebp),%esi
  8008bf:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8008c2:	39 c6                	cmp    %eax,%esi
  8008c4:	73 32                	jae    8008f8 <memmove+0x48>
  8008c6:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8008c9:	39 c2                	cmp    %eax,%edx
  8008cb:	76 2b                	jbe    8008f8 <memmove+0x48>
		s += n;
		d += n;
  8008cd:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008d0:	89 fe                	mov    %edi,%esi
  8008d2:	09 ce                	or     %ecx,%esi
  8008d4:	09 d6                	or     %edx,%esi
  8008d6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8008dc:	75 0e                	jne    8008ec <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8008de:	83 ef 04             	sub    $0x4,%edi
  8008e1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8008e4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8008e7:	fd                   	std    
  8008e8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8008ea:	eb 09                	jmp    8008f5 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8008ec:	83 ef 01             	sub    $0x1,%edi
  8008ef:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8008f2:	fd                   	std    
  8008f3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8008f5:	fc                   	cld    
  8008f6:	eb 1a                	jmp    800912 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8008f8:	89 c2                	mov    %eax,%edx
  8008fa:	09 ca                	or     %ecx,%edx
  8008fc:	09 f2                	or     %esi,%edx
  8008fe:	f6 c2 03             	test   $0x3,%dl
  800901:	75 0a                	jne    80090d <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800903:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800906:	89 c7                	mov    %eax,%edi
  800908:	fc                   	cld    
  800909:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80090b:	eb 05                	jmp    800912 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  80090d:	89 c7                	mov    %eax,%edi
  80090f:	fc                   	cld    
  800910:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800912:	5e                   	pop    %esi
  800913:	5f                   	pop    %edi
  800914:	5d                   	pop    %ebp
  800915:	c3                   	ret    

00800916 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800916:	f3 0f 1e fb          	endbr32 
  80091a:	55                   	push   %ebp
  80091b:	89 e5                	mov    %esp,%ebp
  80091d:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800920:	ff 75 10             	pushl  0x10(%ebp)
  800923:	ff 75 0c             	pushl  0xc(%ebp)
  800926:	ff 75 08             	pushl  0x8(%ebp)
  800929:	e8 82 ff ff ff       	call   8008b0 <memmove>
}
  80092e:	c9                   	leave  
  80092f:	c3                   	ret    

00800930 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800930:	f3 0f 1e fb          	endbr32 
  800934:	55                   	push   %ebp
  800935:	89 e5                	mov    %esp,%ebp
  800937:	56                   	push   %esi
  800938:	53                   	push   %ebx
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80093f:	89 c6                	mov    %eax,%esi
  800941:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800944:	39 f0                	cmp    %esi,%eax
  800946:	74 1c                	je     800964 <memcmp+0x34>
		if (*s1 != *s2)
  800948:	0f b6 08             	movzbl (%eax),%ecx
  80094b:	0f b6 1a             	movzbl (%edx),%ebx
  80094e:	38 d9                	cmp    %bl,%cl
  800950:	75 08                	jne    80095a <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800952:	83 c0 01             	add    $0x1,%eax
  800955:	83 c2 01             	add    $0x1,%edx
  800958:	eb ea                	jmp    800944 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  80095a:	0f b6 c1             	movzbl %cl,%eax
  80095d:	0f b6 db             	movzbl %bl,%ebx
  800960:	29 d8                	sub    %ebx,%eax
  800962:	eb 05                	jmp    800969 <memcmp+0x39>
	}

	return 0;
  800964:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800969:	5b                   	pop    %ebx
  80096a:	5e                   	pop    %esi
  80096b:	5d                   	pop    %ebp
  80096c:	c3                   	ret    

0080096d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80096d:	f3 0f 1e fb          	endbr32 
  800971:	55                   	push   %ebp
  800972:	89 e5                	mov    %esp,%ebp
  800974:	8b 45 08             	mov    0x8(%ebp),%eax
  800977:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80097a:	89 c2                	mov    %eax,%edx
  80097c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80097f:	39 d0                	cmp    %edx,%eax
  800981:	73 09                	jae    80098c <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800983:	38 08                	cmp    %cl,(%eax)
  800985:	74 05                	je     80098c <memfind+0x1f>
	for (; s < ends; s++)
  800987:	83 c0 01             	add    $0x1,%eax
  80098a:	eb f3                	jmp    80097f <memfind+0x12>
			break;
	return (void *) s;
}
  80098c:	5d                   	pop    %ebp
  80098d:	c3                   	ret    

0080098e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80098e:	f3 0f 1e fb          	endbr32 
  800992:	55                   	push   %ebp
  800993:	89 e5                	mov    %esp,%ebp
  800995:	57                   	push   %edi
  800996:	56                   	push   %esi
  800997:	53                   	push   %ebx
  800998:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80099e:	eb 03                	jmp    8009a3 <strtol+0x15>
		s++;
  8009a0:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  8009a3:	0f b6 01             	movzbl (%ecx),%eax
  8009a6:	3c 20                	cmp    $0x20,%al
  8009a8:	74 f6                	je     8009a0 <strtol+0x12>
  8009aa:	3c 09                	cmp    $0x9,%al
  8009ac:	74 f2                	je     8009a0 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  8009ae:	3c 2b                	cmp    $0x2b,%al
  8009b0:	74 2a                	je     8009dc <strtol+0x4e>
	int neg = 0;
  8009b2:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  8009b7:	3c 2d                	cmp    $0x2d,%al
  8009b9:	74 2b                	je     8009e6 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009bb:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8009c1:	75 0f                	jne    8009d2 <strtol+0x44>
  8009c3:	80 39 30             	cmpb   $0x30,(%ecx)
  8009c6:	74 28                	je     8009f0 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8009c8:	85 db                	test   %ebx,%ebx
  8009ca:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009cf:	0f 44 d8             	cmove  %eax,%ebx
  8009d2:	b8 00 00 00 00       	mov    $0x0,%eax
  8009d7:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8009da:	eb 46                	jmp    800a22 <strtol+0x94>
		s++;
  8009dc:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8009df:	bf 00 00 00 00       	mov    $0x0,%edi
  8009e4:	eb d5                	jmp    8009bb <strtol+0x2d>
		s++, neg = 1;
  8009e6:	83 c1 01             	add    $0x1,%ecx
  8009e9:	bf 01 00 00 00       	mov    $0x1,%edi
  8009ee:	eb cb                	jmp    8009bb <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8009f0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8009f4:	74 0e                	je     800a04 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8009f6:	85 db                	test   %ebx,%ebx
  8009f8:	75 d8                	jne    8009d2 <strtol+0x44>
		s++, base = 8;
  8009fa:	83 c1 01             	add    $0x1,%ecx
  8009fd:	bb 08 00 00 00       	mov    $0x8,%ebx
  800a02:	eb ce                	jmp    8009d2 <strtol+0x44>
		s += 2, base = 16;
  800a04:	83 c1 02             	add    $0x2,%ecx
  800a07:	bb 10 00 00 00       	mov    $0x10,%ebx
  800a0c:	eb c4                	jmp    8009d2 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800a0e:	0f be d2             	movsbl %dl,%edx
  800a11:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800a14:	3b 55 10             	cmp    0x10(%ebp),%edx
  800a17:	7d 3a                	jge    800a53 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800a19:	83 c1 01             	add    $0x1,%ecx
  800a1c:	0f af 45 10          	imul   0x10(%ebp),%eax
  800a20:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800a22:	0f b6 11             	movzbl (%ecx),%edx
  800a25:	8d 72 d0             	lea    -0x30(%edx),%esi
  800a28:	89 f3                	mov    %esi,%ebx
  800a2a:	80 fb 09             	cmp    $0x9,%bl
  800a2d:	76 df                	jbe    800a0e <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800a2f:	8d 72 9f             	lea    -0x61(%edx),%esi
  800a32:	89 f3                	mov    %esi,%ebx
  800a34:	80 fb 19             	cmp    $0x19,%bl
  800a37:	77 08                	ja     800a41 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800a39:	0f be d2             	movsbl %dl,%edx
  800a3c:	83 ea 57             	sub    $0x57,%edx
  800a3f:	eb d3                	jmp    800a14 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800a41:	8d 72 bf             	lea    -0x41(%edx),%esi
  800a44:	89 f3                	mov    %esi,%ebx
  800a46:	80 fb 19             	cmp    $0x19,%bl
  800a49:	77 08                	ja     800a53 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800a4b:	0f be d2             	movsbl %dl,%edx
  800a4e:	83 ea 37             	sub    $0x37,%edx
  800a51:	eb c1                	jmp    800a14 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800a53:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800a57:	74 05                	je     800a5e <strtol+0xd0>
		*endptr = (char *) s;
  800a59:	8b 75 0c             	mov    0xc(%ebp),%esi
  800a5c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800a5e:	89 c2                	mov    %eax,%edx
  800a60:	f7 da                	neg    %edx
  800a62:	85 ff                	test   %edi,%edi
  800a64:	0f 45 c2             	cmovne %edx,%eax
}
  800a67:	5b                   	pop    %ebx
  800a68:	5e                   	pop    %esi
  800a69:	5f                   	pop    %edi
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    

00800a6c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800a6c:	55                   	push   %ebp
  800a6d:	89 e5                	mov    %esp,%ebp
  800a6f:	57                   	push   %edi
  800a70:	56                   	push   %esi
  800a71:	53                   	push   %ebx
  800a72:	83 ec 1c             	sub    $0x1c,%esp
  800a75:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800a78:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800a7b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800a7d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a80:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800a83:	8b 7d 10             	mov    0x10(%ebp),%edi
  800a86:	8b 75 14             	mov    0x14(%ebp),%esi
  800a89:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800a8b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800a8f:	74 04                	je     800a95 <syscall+0x29>
  800a91:	85 c0                	test   %eax,%eax
  800a93:	7f 08                	jg     800a9d <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800a95:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5f                   	pop    %edi
  800a9b:	5d                   	pop    %ebp
  800a9c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800a9d:	83 ec 0c             	sub    $0xc,%esp
  800aa0:	50                   	push   %eax
  800aa1:	ff 75 e0             	pushl  -0x20(%ebp)
  800aa4:	68 3f 21 80 00       	push   $0x80213f
  800aa9:	6a 23                	push   $0x23
  800aab:	68 5c 21 80 00       	push   $0x80215c
  800ab0:	e8 51 0f 00 00       	call   801a06 <_panic>

00800ab5 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800ab5:	f3 0f 1e fb          	endbr32 
  800ab9:	55                   	push   %ebp
  800aba:	89 e5                	mov    %esp,%ebp
  800abc:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800abf:	6a 00                	push   $0x0
  800ac1:	6a 00                	push   $0x0
  800ac3:	6a 00                	push   $0x0
  800ac5:	ff 75 0c             	pushl  0xc(%ebp)
  800ac8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800acb:	ba 00 00 00 00       	mov    $0x0,%edx
  800ad0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ad5:	e8 92 ff ff ff       	call   800a6c <syscall>
}
  800ada:	83 c4 10             	add    $0x10,%esp
  800add:	c9                   	leave  
  800ade:	c3                   	ret    

00800adf <sys_cgetc>:

int
sys_cgetc(void)
{
  800adf:	f3 0f 1e fb          	endbr32 
  800ae3:	55                   	push   %ebp
  800ae4:	89 e5                	mov    %esp,%ebp
  800ae6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ae9:	6a 00                	push   $0x0
  800aeb:	6a 00                	push   $0x0
  800aed:	6a 00                	push   $0x0
  800aef:	6a 00                	push   $0x0
  800af1:	b9 00 00 00 00       	mov    $0x0,%ecx
  800af6:	ba 00 00 00 00       	mov    $0x0,%edx
  800afb:	b8 01 00 00 00       	mov    $0x1,%eax
  800b00:	e8 67 ff ff ff       	call   800a6c <syscall>
}
  800b05:	c9                   	leave  
  800b06:	c3                   	ret    

00800b07 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800b07:	f3 0f 1e fb          	endbr32 
  800b0b:	55                   	push   %ebp
  800b0c:	89 e5                	mov    %esp,%ebp
  800b0e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800b11:	6a 00                	push   $0x0
  800b13:	6a 00                	push   $0x0
  800b15:	6a 00                	push   $0x0
  800b17:	6a 00                	push   $0x0
  800b19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b1c:	ba 01 00 00 00       	mov    $0x1,%edx
  800b21:	b8 03 00 00 00       	mov    $0x3,%eax
  800b26:	e8 41 ff ff ff       	call   800a6c <syscall>
}
  800b2b:	c9                   	leave  
  800b2c:	c3                   	ret    

00800b2d <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800b2d:	f3 0f 1e fb          	endbr32 
  800b31:	55                   	push   %ebp
  800b32:	89 e5                	mov    %esp,%ebp
  800b34:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800b37:	6a 00                	push   $0x0
  800b39:	6a 00                	push   $0x0
  800b3b:	6a 00                	push   $0x0
  800b3d:	6a 00                	push   $0x0
  800b3f:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b44:	ba 00 00 00 00       	mov    $0x0,%edx
  800b49:	b8 02 00 00 00       	mov    $0x2,%eax
  800b4e:	e8 19 ff ff ff       	call   800a6c <syscall>
}
  800b53:	c9                   	leave  
  800b54:	c3                   	ret    

00800b55 <sys_yield>:

void
sys_yield(void)
{
  800b55:	f3 0f 1e fb          	endbr32 
  800b59:	55                   	push   %ebp
  800b5a:	89 e5                	mov    %esp,%ebp
  800b5c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800b5f:	6a 00                	push   $0x0
  800b61:	6a 00                	push   $0x0
  800b63:	6a 00                	push   $0x0
  800b65:	6a 00                	push   $0x0
  800b67:	b9 00 00 00 00       	mov    $0x0,%ecx
  800b6c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b71:	b8 0b 00 00 00       	mov    $0xb,%eax
  800b76:	e8 f1 fe ff ff       	call   800a6c <syscall>
}
  800b7b:	83 c4 10             	add    $0x10,%esp
  800b7e:	c9                   	leave  
  800b7f:	c3                   	ret    

00800b80 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800b80:	f3 0f 1e fb          	endbr32 
  800b84:	55                   	push   %ebp
  800b85:	89 e5                	mov    %esp,%ebp
  800b87:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800b8a:	6a 00                	push   $0x0
  800b8c:	6a 00                	push   $0x0
  800b8e:	ff 75 10             	pushl  0x10(%ebp)
  800b91:	ff 75 0c             	pushl  0xc(%ebp)
  800b94:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b97:	ba 01 00 00 00       	mov    $0x1,%edx
  800b9c:	b8 04 00 00 00       	mov    $0x4,%eax
  800ba1:	e8 c6 fe ff ff       	call   800a6c <syscall>
}
  800ba6:	c9                   	leave  
  800ba7:	c3                   	ret    

00800ba8 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800ba8:	f3 0f 1e fb          	endbr32 
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800bb2:	ff 75 18             	pushl  0x18(%ebp)
  800bb5:	ff 75 14             	pushl  0x14(%ebp)
  800bb8:	ff 75 10             	pushl  0x10(%ebp)
  800bbb:	ff 75 0c             	pushl  0xc(%ebp)
  800bbe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bc1:	ba 01 00 00 00       	mov    $0x1,%edx
  800bc6:	b8 05 00 00 00       	mov    $0x5,%eax
  800bcb:	e8 9c fe ff ff       	call   800a6c <syscall>
}
  800bd0:	c9                   	leave  
  800bd1:	c3                   	ret    

00800bd2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800bd2:	f3 0f 1e fb          	endbr32 
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800bdc:	6a 00                	push   $0x0
  800bde:	6a 00                	push   $0x0
  800be0:	6a 00                	push   $0x0
  800be2:	ff 75 0c             	pushl  0xc(%ebp)
  800be5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800be8:	ba 01 00 00 00       	mov    $0x1,%edx
  800bed:	b8 06 00 00 00       	mov    $0x6,%eax
  800bf2:	e8 75 fe ff ff       	call   800a6c <syscall>
}
  800bf7:	c9                   	leave  
  800bf8:	c3                   	ret    

00800bf9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800bf9:	f3 0f 1e fb          	endbr32 
  800bfd:	55                   	push   %ebp
  800bfe:	89 e5                	mov    %esp,%ebp
  800c00:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800c03:	6a 00                	push   $0x0
  800c05:	6a 00                	push   $0x0
  800c07:	6a 00                	push   $0x0
  800c09:	ff 75 0c             	pushl  0xc(%ebp)
  800c0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c0f:	ba 01 00 00 00       	mov    $0x1,%edx
  800c14:	b8 08 00 00 00       	mov    $0x8,%eax
  800c19:	e8 4e fe ff ff       	call   800a6c <syscall>
}
  800c1e:	c9                   	leave  
  800c1f:	c3                   	ret    

00800c20 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800c20:	f3 0f 1e fb          	endbr32 
  800c24:	55                   	push   %ebp
  800c25:	89 e5                	mov    %esp,%ebp
  800c27:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800c2a:	6a 00                	push   $0x0
  800c2c:	6a 00                	push   $0x0
  800c2e:	6a 00                	push   $0x0
  800c30:	ff 75 0c             	pushl  0xc(%ebp)
  800c33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c36:	ba 01 00 00 00       	mov    $0x1,%edx
  800c3b:	b8 09 00 00 00       	mov    $0x9,%eax
  800c40:	e8 27 fe ff ff       	call   800a6c <syscall>
}
  800c45:	c9                   	leave  
  800c46:	c3                   	ret    

00800c47 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800c47:	f3 0f 1e fb          	endbr32 
  800c4b:	55                   	push   %ebp
  800c4c:	89 e5                	mov    %esp,%ebp
  800c4e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800c51:	6a 00                	push   $0x0
  800c53:	6a 00                	push   $0x0
  800c55:	6a 00                	push   $0x0
  800c57:	ff 75 0c             	pushl  0xc(%ebp)
  800c5a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c5d:	ba 01 00 00 00       	mov    $0x1,%edx
  800c62:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c67:	e8 00 fe ff ff       	call   800a6c <syscall>
}
  800c6c:	c9                   	leave  
  800c6d:	c3                   	ret    

00800c6e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800c6e:	f3 0f 1e fb          	endbr32 
  800c72:	55                   	push   %ebp
  800c73:	89 e5                	mov    %esp,%ebp
  800c75:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800c78:	6a 00                	push   $0x0
  800c7a:	ff 75 14             	pushl  0x14(%ebp)
  800c7d:	ff 75 10             	pushl  0x10(%ebp)
  800c80:	ff 75 0c             	pushl  0xc(%ebp)
  800c83:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c86:	ba 00 00 00 00       	mov    $0x0,%edx
  800c8b:	b8 0c 00 00 00       	mov    $0xc,%eax
  800c90:	e8 d7 fd ff ff       	call   800a6c <syscall>
}
  800c95:	c9                   	leave  
  800c96:	c3                   	ret    

00800c97 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800c97:	f3 0f 1e fb          	endbr32 
  800c9b:	55                   	push   %ebp
  800c9c:	89 e5                	mov    %esp,%ebp
  800c9e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800ca1:	6a 00                	push   $0x0
  800ca3:	6a 00                	push   $0x0
  800ca5:	6a 00                	push   $0x0
  800ca7:	6a 00                	push   $0x0
  800ca9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cac:	ba 01 00 00 00       	mov    $0x1,%edx
  800cb1:	b8 0d 00 00 00       	mov    $0xd,%eax
  800cb6:	e8 b1 fd ff ff       	call   800a6c <syscall>
}
  800cbb:	c9                   	leave  
  800cbc:	c3                   	ret    

00800cbd <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800cbd:	f3 0f 1e fb          	endbr32 
  800cc1:	55                   	push   %ebp
  800cc2:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800cc4:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc7:	05 00 00 00 30       	add    $0x30000000,%eax
  800ccc:	c1 e8 0c             	shr    $0xc,%eax
}
  800ccf:	5d                   	pop    %ebp
  800cd0:	c3                   	ret    

00800cd1 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800cd1:	f3 0f 1e fb          	endbr32 
  800cd5:	55                   	push   %ebp
  800cd6:	89 e5                	mov    %esp,%ebp
  800cd8:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800cdb:	ff 75 08             	pushl  0x8(%ebp)
  800cde:	e8 da ff ff ff       	call   800cbd <fd2num>
  800ce3:	83 c4 10             	add    $0x10,%esp
  800ce6:	c1 e0 0c             	shl    $0xc,%eax
  800ce9:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800cee:	c9                   	leave  
  800cef:	c3                   	ret    

00800cf0 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800cf0:	f3 0f 1e fb          	endbr32 
  800cf4:	55                   	push   %ebp
  800cf5:	89 e5                	mov    %esp,%ebp
  800cf7:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800cfc:	89 c2                	mov    %eax,%edx
  800cfe:	c1 ea 16             	shr    $0x16,%edx
  800d01:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800d08:	f6 c2 01             	test   $0x1,%dl
  800d0b:	74 2d                	je     800d3a <fd_alloc+0x4a>
  800d0d:	89 c2                	mov    %eax,%edx
  800d0f:	c1 ea 0c             	shr    $0xc,%edx
  800d12:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d19:	f6 c2 01             	test   $0x1,%dl
  800d1c:	74 1c                	je     800d3a <fd_alloc+0x4a>
  800d1e:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800d23:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800d28:	75 d2                	jne    800cfc <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800d2a:	8b 45 08             	mov    0x8(%ebp),%eax
  800d2d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800d33:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800d38:	eb 0a                	jmp    800d44 <fd_alloc+0x54>
			*fd_store = fd;
  800d3a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d3d:	89 01                	mov    %eax,(%ecx)
			return 0;
  800d3f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800d46:	f3 0f 1e fb          	endbr32 
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800d50:	83 f8 1f             	cmp    $0x1f,%eax
  800d53:	77 30                	ja     800d85 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800d55:	c1 e0 0c             	shl    $0xc,%eax
  800d58:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800d5d:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  800d63:	f6 c2 01             	test   $0x1,%dl
  800d66:	74 24                	je     800d8c <fd_lookup+0x46>
  800d68:	89 c2                	mov    %eax,%edx
  800d6a:	c1 ea 0c             	shr    $0xc,%edx
  800d6d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800d74:	f6 c2 01             	test   $0x1,%dl
  800d77:	74 1a                	je     800d93 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800d79:	8b 55 0c             	mov    0xc(%ebp),%edx
  800d7c:	89 02                	mov    %eax,(%edx)
	return 0;
  800d7e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800d83:	5d                   	pop    %ebp
  800d84:	c3                   	ret    
		return -E_INVAL;
  800d85:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d8a:	eb f7                	jmp    800d83 <fd_lookup+0x3d>
		return -E_INVAL;
  800d8c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d91:	eb f0                	jmp    800d83 <fd_lookup+0x3d>
  800d93:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800d98:	eb e9                	jmp    800d83 <fd_lookup+0x3d>

00800d9a <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800d9a:	f3 0f 1e fb          	endbr32 
  800d9e:	55                   	push   %ebp
  800d9f:	89 e5                	mov    %esp,%ebp
  800da1:	83 ec 08             	sub    $0x8,%esp
  800da4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800da7:	ba e8 21 80 00       	mov    $0x8021e8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800dac:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  800db1:	39 08                	cmp    %ecx,(%eax)
  800db3:	74 33                	je     800de8 <dev_lookup+0x4e>
  800db5:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800db8:	8b 02                	mov    (%edx),%eax
  800dba:	85 c0                	test   %eax,%eax
  800dbc:	75 f3                	jne    800db1 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800dbe:	a1 04 40 80 00       	mov    0x804004,%eax
  800dc3:	8b 40 48             	mov    0x48(%eax),%eax
  800dc6:	83 ec 04             	sub    $0x4,%esp
  800dc9:	51                   	push   %ecx
  800dca:	50                   	push   %eax
  800dcb:	68 6c 21 80 00       	push   $0x80216c
  800dd0:	e8 b9 f3 ff ff       	call   80018e <cprintf>
	*dev = 0;
  800dd5:	8b 45 0c             	mov    0xc(%ebp),%eax
  800dd8:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800dde:	83 c4 10             	add    $0x10,%esp
  800de1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800de6:	c9                   	leave  
  800de7:	c3                   	ret    
			*dev = devtab[i];
  800de8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800deb:	89 01                	mov    %eax,(%ecx)
			return 0;
  800ded:	b8 00 00 00 00       	mov    $0x0,%eax
  800df2:	eb f2                	jmp    800de6 <dev_lookup+0x4c>

00800df4 <fd_close>:
{
  800df4:	f3 0f 1e fb          	endbr32 
  800df8:	55                   	push   %ebp
  800df9:	89 e5                	mov    %esp,%ebp
  800dfb:	57                   	push   %edi
  800dfc:	56                   	push   %esi
  800dfd:	53                   	push   %ebx
  800dfe:	83 ec 28             	sub    $0x28,%esp
  800e01:	8b 75 08             	mov    0x8(%ebp),%esi
  800e04:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800e07:	56                   	push   %esi
  800e08:	e8 b0 fe ff ff       	call   800cbd <fd2num>
  800e0d:	83 c4 08             	add    $0x8,%esp
  800e10:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800e13:	52                   	push   %edx
  800e14:	50                   	push   %eax
  800e15:	e8 2c ff ff ff       	call   800d46 <fd_lookup>
  800e1a:	89 c3                	mov    %eax,%ebx
  800e1c:	83 c4 10             	add    $0x10,%esp
  800e1f:	85 c0                	test   %eax,%eax
  800e21:	78 05                	js     800e28 <fd_close+0x34>
	    || fd != fd2)
  800e23:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800e26:	74 16                	je     800e3e <fd_close+0x4a>
		return (must_exist ? r : 0);
  800e28:	89 f8                	mov    %edi,%eax
  800e2a:	84 c0                	test   %al,%al
  800e2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800e31:	0f 44 d8             	cmove  %eax,%ebx
}
  800e34:	89 d8                	mov    %ebx,%eax
  800e36:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e39:	5b                   	pop    %ebx
  800e3a:	5e                   	pop    %esi
  800e3b:	5f                   	pop    %edi
  800e3c:	5d                   	pop    %ebp
  800e3d:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800e3e:	83 ec 08             	sub    $0x8,%esp
  800e41:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800e44:	50                   	push   %eax
  800e45:	ff 36                	pushl  (%esi)
  800e47:	e8 4e ff ff ff       	call   800d9a <dev_lookup>
  800e4c:	89 c3                	mov    %eax,%ebx
  800e4e:	83 c4 10             	add    $0x10,%esp
  800e51:	85 c0                	test   %eax,%eax
  800e53:	78 1a                	js     800e6f <fd_close+0x7b>
		if (dev->dev_close)
  800e55:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800e58:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800e5b:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  800e60:	85 c0                	test   %eax,%eax
  800e62:	74 0b                	je     800e6f <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  800e64:	83 ec 0c             	sub    $0xc,%esp
  800e67:	56                   	push   %esi
  800e68:	ff d0                	call   *%eax
  800e6a:	89 c3                	mov    %eax,%ebx
  800e6c:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  800e6f:	83 ec 08             	sub    $0x8,%esp
  800e72:	56                   	push   %esi
  800e73:	6a 00                	push   $0x0
  800e75:	e8 58 fd ff ff       	call   800bd2 <sys_page_unmap>
	return r;
  800e7a:	83 c4 10             	add    $0x10,%esp
  800e7d:	eb b5                	jmp    800e34 <fd_close+0x40>

00800e7f <close>:

int
close(int fdnum)
{
  800e7f:	f3 0f 1e fb          	endbr32 
  800e83:	55                   	push   %ebp
  800e84:	89 e5                	mov    %esp,%ebp
  800e86:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e89:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e8c:	50                   	push   %eax
  800e8d:	ff 75 08             	pushl  0x8(%ebp)
  800e90:	e8 b1 fe ff ff       	call   800d46 <fd_lookup>
  800e95:	83 c4 10             	add    $0x10,%esp
  800e98:	85 c0                	test   %eax,%eax
  800e9a:	79 02                	jns    800e9e <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800e9c:	c9                   	leave  
  800e9d:	c3                   	ret    
		return fd_close(fd, 1);
  800e9e:	83 ec 08             	sub    $0x8,%esp
  800ea1:	6a 01                	push   $0x1
  800ea3:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea6:	e8 49 ff ff ff       	call   800df4 <fd_close>
  800eab:	83 c4 10             	add    $0x10,%esp
  800eae:	eb ec                	jmp    800e9c <close+0x1d>

00800eb0 <close_all>:

void
close_all(void)
{
  800eb0:	f3 0f 1e fb          	endbr32 
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	53                   	push   %ebx
  800eb8:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800ebb:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800ec0:	83 ec 0c             	sub    $0xc,%esp
  800ec3:	53                   	push   %ebx
  800ec4:	e8 b6 ff ff ff       	call   800e7f <close>
	for (i = 0; i < MAXFD; i++)
  800ec9:	83 c3 01             	add    $0x1,%ebx
  800ecc:	83 c4 10             	add    $0x10,%esp
  800ecf:	83 fb 20             	cmp    $0x20,%ebx
  800ed2:	75 ec                	jne    800ec0 <close_all+0x10>
}
  800ed4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ed7:	c9                   	leave  
  800ed8:	c3                   	ret    

00800ed9 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800ed9:	f3 0f 1e fb          	endbr32 
  800edd:	55                   	push   %ebp
  800ede:	89 e5                	mov    %esp,%ebp
  800ee0:	57                   	push   %edi
  800ee1:	56                   	push   %esi
  800ee2:	53                   	push   %ebx
  800ee3:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800ee6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800ee9:	50                   	push   %eax
  800eea:	ff 75 08             	pushl  0x8(%ebp)
  800eed:	e8 54 fe ff ff       	call   800d46 <fd_lookup>
  800ef2:	89 c3                	mov    %eax,%ebx
  800ef4:	83 c4 10             	add    $0x10,%esp
  800ef7:	85 c0                	test   %eax,%eax
  800ef9:	0f 88 81 00 00 00    	js     800f80 <dup+0xa7>
		return r;
	close(newfdnum);
  800eff:	83 ec 0c             	sub    $0xc,%esp
  800f02:	ff 75 0c             	pushl  0xc(%ebp)
  800f05:	e8 75 ff ff ff       	call   800e7f <close>

	newfd = INDEX2FD(newfdnum);
  800f0a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f0d:	c1 e6 0c             	shl    $0xc,%esi
  800f10:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800f16:	83 c4 04             	add    $0x4,%esp
  800f19:	ff 75 e4             	pushl  -0x1c(%ebp)
  800f1c:	e8 b0 fd ff ff       	call   800cd1 <fd2data>
  800f21:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800f23:	89 34 24             	mov    %esi,(%esp)
  800f26:	e8 a6 fd ff ff       	call   800cd1 <fd2data>
  800f2b:	83 c4 10             	add    $0x10,%esp
  800f2e:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800f30:	89 d8                	mov    %ebx,%eax
  800f32:	c1 e8 16             	shr    $0x16,%eax
  800f35:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800f3c:	a8 01                	test   $0x1,%al
  800f3e:	74 11                	je     800f51 <dup+0x78>
  800f40:	89 d8                	mov    %ebx,%eax
  800f42:	c1 e8 0c             	shr    $0xc,%eax
  800f45:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800f4c:	f6 c2 01             	test   $0x1,%dl
  800f4f:	75 39                	jne    800f8a <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800f51:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800f54:	89 d0                	mov    %edx,%eax
  800f56:	c1 e8 0c             	shr    $0xc,%eax
  800f59:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f60:	83 ec 0c             	sub    $0xc,%esp
  800f63:	25 07 0e 00 00       	and    $0xe07,%eax
  800f68:	50                   	push   %eax
  800f69:	56                   	push   %esi
  800f6a:	6a 00                	push   $0x0
  800f6c:	52                   	push   %edx
  800f6d:	6a 00                	push   $0x0
  800f6f:	e8 34 fc ff ff       	call   800ba8 <sys_page_map>
  800f74:	89 c3                	mov    %eax,%ebx
  800f76:	83 c4 20             	add    $0x20,%esp
  800f79:	85 c0                	test   %eax,%eax
  800f7b:	78 31                	js     800fae <dup+0xd5>
		goto err;

	return newfdnum;
  800f7d:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  800f80:	89 d8                	mov    %ebx,%eax
  800f82:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f85:	5b                   	pop    %ebx
  800f86:	5e                   	pop    %esi
  800f87:	5f                   	pop    %edi
  800f88:	5d                   	pop    %ebp
  800f89:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  800f8a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  800f91:	83 ec 0c             	sub    $0xc,%esp
  800f94:	25 07 0e 00 00       	and    $0xe07,%eax
  800f99:	50                   	push   %eax
  800f9a:	57                   	push   %edi
  800f9b:	6a 00                	push   $0x0
  800f9d:	53                   	push   %ebx
  800f9e:	6a 00                	push   $0x0
  800fa0:	e8 03 fc ff ff       	call   800ba8 <sys_page_map>
  800fa5:	89 c3                	mov    %eax,%ebx
  800fa7:	83 c4 20             	add    $0x20,%esp
  800faa:	85 c0                	test   %eax,%eax
  800fac:	79 a3                	jns    800f51 <dup+0x78>
	sys_page_unmap(0, newfd);
  800fae:	83 ec 08             	sub    $0x8,%esp
  800fb1:	56                   	push   %esi
  800fb2:	6a 00                	push   $0x0
  800fb4:	e8 19 fc ff ff       	call   800bd2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800fb9:	83 c4 08             	add    $0x8,%esp
  800fbc:	57                   	push   %edi
  800fbd:	6a 00                	push   $0x0
  800fbf:	e8 0e fc ff ff       	call   800bd2 <sys_page_unmap>
	return r;
  800fc4:	83 c4 10             	add    $0x10,%esp
  800fc7:	eb b7                	jmp    800f80 <dup+0xa7>

00800fc9 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800fc9:	f3 0f 1e fb          	endbr32 
  800fcd:	55                   	push   %ebp
  800fce:	89 e5                	mov    %esp,%ebp
  800fd0:	53                   	push   %ebx
  800fd1:	83 ec 1c             	sub    $0x1c,%esp
  800fd4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800fd7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800fda:	50                   	push   %eax
  800fdb:	53                   	push   %ebx
  800fdc:	e8 65 fd ff ff       	call   800d46 <fd_lookup>
  800fe1:	83 c4 10             	add    $0x10,%esp
  800fe4:	85 c0                	test   %eax,%eax
  800fe6:	78 3f                	js     801027 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800fe8:	83 ec 08             	sub    $0x8,%esp
  800feb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fee:	50                   	push   %eax
  800fef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800ff2:	ff 30                	pushl  (%eax)
  800ff4:	e8 a1 fd ff ff       	call   800d9a <dev_lookup>
  800ff9:	83 c4 10             	add    $0x10,%esp
  800ffc:	85 c0                	test   %eax,%eax
  800ffe:	78 27                	js     801027 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801000:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801003:	8b 42 08             	mov    0x8(%edx),%eax
  801006:	83 e0 03             	and    $0x3,%eax
  801009:	83 f8 01             	cmp    $0x1,%eax
  80100c:	74 1e                	je     80102c <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80100e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801011:	8b 40 08             	mov    0x8(%eax),%eax
  801014:	85 c0                	test   %eax,%eax
  801016:	74 35                	je     80104d <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801018:	83 ec 04             	sub    $0x4,%esp
  80101b:	ff 75 10             	pushl  0x10(%ebp)
  80101e:	ff 75 0c             	pushl  0xc(%ebp)
  801021:	52                   	push   %edx
  801022:	ff d0                	call   *%eax
  801024:	83 c4 10             	add    $0x10,%esp
}
  801027:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80102a:	c9                   	leave  
  80102b:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80102c:	a1 04 40 80 00       	mov    0x804004,%eax
  801031:	8b 40 48             	mov    0x48(%eax),%eax
  801034:	83 ec 04             	sub    $0x4,%esp
  801037:	53                   	push   %ebx
  801038:	50                   	push   %eax
  801039:	68 ad 21 80 00       	push   $0x8021ad
  80103e:	e8 4b f1 ff ff       	call   80018e <cprintf>
		return -E_INVAL;
  801043:	83 c4 10             	add    $0x10,%esp
  801046:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80104b:	eb da                	jmp    801027 <read+0x5e>
		return -E_NOT_SUPP;
  80104d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801052:	eb d3                	jmp    801027 <read+0x5e>

00801054 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801054:	f3 0f 1e fb          	endbr32 
  801058:	55                   	push   %ebp
  801059:	89 e5                	mov    %esp,%ebp
  80105b:	57                   	push   %edi
  80105c:	56                   	push   %esi
  80105d:	53                   	push   %ebx
  80105e:	83 ec 0c             	sub    $0xc,%esp
  801061:	8b 7d 08             	mov    0x8(%ebp),%edi
  801064:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801067:	bb 00 00 00 00       	mov    $0x0,%ebx
  80106c:	eb 02                	jmp    801070 <readn+0x1c>
  80106e:	01 c3                	add    %eax,%ebx
  801070:	39 f3                	cmp    %esi,%ebx
  801072:	73 21                	jae    801095 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801074:	83 ec 04             	sub    $0x4,%esp
  801077:	89 f0                	mov    %esi,%eax
  801079:	29 d8                	sub    %ebx,%eax
  80107b:	50                   	push   %eax
  80107c:	89 d8                	mov    %ebx,%eax
  80107e:	03 45 0c             	add    0xc(%ebp),%eax
  801081:	50                   	push   %eax
  801082:	57                   	push   %edi
  801083:	e8 41 ff ff ff       	call   800fc9 <read>
		if (m < 0)
  801088:	83 c4 10             	add    $0x10,%esp
  80108b:	85 c0                	test   %eax,%eax
  80108d:	78 04                	js     801093 <readn+0x3f>
			return m;
		if (m == 0)
  80108f:	75 dd                	jne    80106e <readn+0x1a>
  801091:	eb 02                	jmp    801095 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801093:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801095:	89 d8                	mov    %ebx,%eax
  801097:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80109a:	5b                   	pop    %ebx
  80109b:	5e                   	pop    %esi
  80109c:	5f                   	pop    %edi
  80109d:	5d                   	pop    %ebp
  80109e:	c3                   	ret    

0080109f <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80109f:	f3 0f 1e fb          	endbr32 
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	53                   	push   %ebx
  8010a7:	83 ec 1c             	sub    $0x1c,%esp
  8010aa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8010ad:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8010b0:	50                   	push   %eax
  8010b1:	53                   	push   %ebx
  8010b2:	e8 8f fc ff ff       	call   800d46 <fd_lookup>
  8010b7:	83 c4 10             	add    $0x10,%esp
  8010ba:	85 c0                	test   %eax,%eax
  8010bc:	78 3a                	js     8010f8 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8010be:	83 ec 08             	sub    $0x8,%esp
  8010c1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8010c4:	50                   	push   %eax
  8010c5:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010c8:	ff 30                	pushl  (%eax)
  8010ca:	e8 cb fc ff ff       	call   800d9a <dev_lookup>
  8010cf:	83 c4 10             	add    $0x10,%esp
  8010d2:	85 c0                	test   %eax,%eax
  8010d4:	78 22                	js     8010f8 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8010d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8010d9:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8010dd:	74 1e                	je     8010fd <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8010df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8010e2:	8b 52 0c             	mov    0xc(%edx),%edx
  8010e5:	85 d2                	test   %edx,%edx
  8010e7:	74 35                	je     80111e <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8010e9:	83 ec 04             	sub    $0x4,%esp
  8010ec:	ff 75 10             	pushl  0x10(%ebp)
  8010ef:	ff 75 0c             	pushl  0xc(%ebp)
  8010f2:	50                   	push   %eax
  8010f3:	ff d2                	call   *%edx
  8010f5:	83 c4 10             	add    $0x10,%esp
}
  8010f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010fb:	c9                   	leave  
  8010fc:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8010fd:	a1 04 40 80 00       	mov    0x804004,%eax
  801102:	8b 40 48             	mov    0x48(%eax),%eax
  801105:	83 ec 04             	sub    $0x4,%esp
  801108:	53                   	push   %ebx
  801109:	50                   	push   %eax
  80110a:	68 c9 21 80 00       	push   $0x8021c9
  80110f:	e8 7a f0 ff ff       	call   80018e <cprintf>
		return -E_INVAL;
  801114:	83 c4 10             	add    $0x10,%esp
  801117:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80111c:	eb da                	jmp    8010f8 <write+0x59>
		return -E_NOT_SUPP;
  80111e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801123:	eb d3                	jmp    8010f8 <write+0x59>

00801125 <seek>:

int
seek(int fdnum, off_t offset)
{
  801125:	f3 0f 1e fb          	endbr32 
  801129:	55                   	push   %ebp
  80112a:	89 e5                	mov    %esp,%ebp
  80112c:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80112f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801132:	50                   	push   %eax
  801133:	ff 75 08             	pushl  0x8(%ebp)
  801136:	e8 0b fc ff ff       	call   800d46 <fd_lookup>
  80113b:	83 c4 10             	add    $0x10,%esp
  80113e:	85 c0                	test   %eax,%eax
  801140:	78 0e                	js     801150 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801142:	8b 55 0c             	mov    0xc(%ebp),%edx
  801145:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801148:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80114b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801150:	c9                   	leave  
  801151:	c3                   	ret    

00801152 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801152:	f3 0f 1e fb          	endbr32 
  801156:	55                   	push   %ebp
  801157:	89 e5                	mov    %esp,%ebp
  801159:	53                   	push   %ebx
  80115a:	83 ec 1c             	sub    $0x1c,%esp
  80115d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801160:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801163:	50                   	push   %eax
  801164:	53                   	push   %ebx
  801165:	e8 dc fb ff ff       	call   800d46 <fd_lookup>
  80116a:	83 c4 10             	add    $0x10,%esp
  80116d:	85 c0                	test   %eax,%eax
  80116f:	78 37                	js     8011a8 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801171:	83 ec 08             	sub    $0x8,%esp
  801174:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801177:	50                   	push   %eax
  801178:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80117b:	ff 30                	pushl  (%eax)
  80117d:	e8 18 fc ff ff       	call   800d9a <dev_lookup>
  801182:	83 c4 10             	add    $0x10,%esp
  801185:	85 c0                	test   %eax,%eax
  801187:	78 1f                	js     8011a8 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801189:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80118c:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801190:	74 1b                	je     8011ad <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801192:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801195:	8b 52 18             	mov    0x18(%edx),%edx
  801198:	85 d2                	test   %edx,%edx
  80119a:	74 32                	je     8011ce <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80119c:	83 ec 08             	sub    $0x8,%esp
  80119f:	ff 75 0c             	pushl  0xc(%ebp)
  8011a2:	50                   	push   %eax
  8011a3:	ff d2                	call   *%edx
  8011a5:	83 c4 10             	add    $0x10,%esp
}
  8011a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011ab:	c9                   	leave  
  8011ac:	c3                   	ret    
			thisenv->env_id, fdnum);
  8011ad:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8011b2:	8b 40 48             	mov    0x48(%eax),%eax
  8011b5:	83 ec 04             	sub    $0x4,%esp
  8011b8:	53                   	push   %ebx
  8011b9:	50                   	push   %eax
  8011ba:	68 8c 21 80 00       	push   $0x80218c
  8011bf:	e8 ca ef ff ff       	call   80018e <cprintf>
		return -E_INVAL;
  8011c4:	83 c4 10             	add    $0x10,%esp
  8011c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8011cc:	eb da                	jmp    8011a8 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8011ce:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8011d3:	eb d3                	jmp    8011a8 <ftruncate+0x56>

008011d5 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8011d5:	f3 0f 1e fb          	endbr32 
  8011d9:	55                   	push   %ebp
  8011da:	89 e5                	mov    %esp,%ebp
  8011dc:	53                   	push   %ebx
  8011dd:	83 ec 1c             	sub    $0x1c,%esp
  8011e0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8011e3:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8011e6:	50                   	push   %eax
  8011e7:	ff 75 08             	pushl  0x8(%ebp)
  8011ea:	e8 57 fb ff ff       	call   800d46 <fd_lookup>
  8011ef:	83 c4 10             	add    $0x10,%esp
  8011f2:	85 c0                	test   %eax,%eax
  8011f4:	78 4b                	js     801241 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8011f6:	83 ec 08             	sub    $0x8,%esp
  8011f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011fc:	50                   	push   %eax
  8011fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801200:	ff 30                	pushl  (%eax)
  801202:	e8 93 fb ff ff       	call   800d9a <dev_lookup>
  801207:	83 c4 10             	add    $0x10,%esp
  80120a:	85 c0                	test   %eax,%eax
  80120c:	78 33                	js     801241 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80120e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801211:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801215:	74 2f                	je     801246 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801217:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80121a:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801221:	00 00 00 
	stat->st_isdir = 0;
  801224:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80122b:	00 00 00 
	stat->st_dev = dev;
  80122e:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801234:	83 ec 08             	sub    $0x8,%esp
  801237:	53                   	push   %ebx
  801238:	ff 75 f0             	pushl  -0x10(%ebp)
  80123b:	ff 50 14             	call   *0x14(%eax)
  80123e:	83 c4 10             	add    $0x10,%esp
}
  801241:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801244:	c9                   	leave  
  801245:	c3                   	ret    
		return -E_NOT_SUPP;
  801246:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80124b:	eb f4                	jmp    801241 <fstat+0x6c>

0080124d <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80124d:	f3 0f 1e fb          	endbr32 
  801251:	55                   	push   %ebp
  801252:	89 e5                	mov    %esp,%ebp
  801254:	56                   	push   %esi
  801255:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801256:	83 ec 08             	sub    $0x8,%esp
  801259:	6a 00                	push   $0x0
  80125b:	ff 75 08             	pushl  0x8(%ebp)
  80125e:	e8 fb 01 00 00       	call   80145e <open>
  801263:	89 c3                	mov    %eax,%ebx
  801265:	83 c4 10             	add    $0x10,%esp
  801268:	85 c0                	test   %eax,%eax
  80126a:	78 1b                	js     801287 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  80126c:	83 ec 08             	sub    $0x8,%esp
  80126f:	ff 75 0c             	pushl  0xc(%ebp)
  801272:	50                   	push   %eax
  801273:	e8 5d ff ff ff       	call   8011d5 <fstat>
  801278:	89 c6                	mov    %eax,%esi
	close(fd);
  80127a:	89 1c 24             	mov    %ebx,(%esp)
  80127d:	e8 fd fb ff ff       	call   800e7f <close>
	return r;
  801282:	83 c4 10             	add    $0x10,%esp
  801285:	89 f3                	mov    %esi,%ebx
}
  801287:	89 d8                	mov    %ebx,%eax
  801289:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80128c:	5b                   	pop    %ebx
  80128d:	5e                   	pop    %esi
  80128e:	5d                   	pop    %ebp
  80128f:	c3                   	ret    

00801290 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801290:	55                   	push   %ebp
  801291:	89 e5                	mov    %esp,%ebp
  801293:	56                   	push   %esi
  801294:	53                   	push   %ebx
  801295:	89 c6                	mov    %eax,%esi
  801297:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801299:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8012a0:	74 27                	je     8012c9 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8012a2:	6a 07                	push   $0x7
  8012a4:	68 00 50 80 00       	push   $0x805000
  8012a9:	56                   	push   %esi
  8012aa:	ff 35 00 40 80 00    	pushl  0x804000
  8012b0:	e8 09 08 00 00       	call   801abe <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8012b5:	83 c4 0c             	add    $0xc,%esp
  8012b8:	6a 00                	push   $0x0
  8012ba:	53                   	push   %ebx
  8012bb:	6a 00                	push   $0x0
  8012bd:	e8 8e 07 00 00       	call   801a50 <ipc_recv>
}
  8012c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8012c5:	5b                   	pop    %ebx
  8012c6:	5e                   	pop    %esi
  8012c7:	5d                   	pop    %ebp
  8012c8:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  8012c9:	83 ec 0c             	sub    $0xc,%esp
  8012cc:	6a 01                	push   $0x1
  8012ce:	e8 50 08 00 00       	call   801b23 <ipc_find_env>
  8012d3:	a3 00 40 80 00       	mov    %eax,0x804000
  8012d8:	83 c4 10             	add    $0x10,%esp
  8012db:	eb c5                	jmp    8012a2 <fsipc+0x12>

008012dd <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  8012dd:	f3 0f 1e fb          	endbr32 
  8012e1:	55                   	push   %ebp
  8012e2:	89 e5                	mov    %esp,%ebp
  8012e4:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  8012e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8012ea:	8b 40 0c             	mov    0xc(%eax),%eax
  8012ed:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  8012f2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8012f5:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  8012fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8012ff:	b8 02 00 00 00       	mov    $0x2,%eax
  801304:	e8 87 ff ff ff       	call   801290 <fsipc>
}
  801309:	c9                   	leave  
  80130a:	c3                   	ret    

0080130b <devfile_flush>:
{
  80130b:	f3 0f 1e fb          	endbr32 
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
  801312:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801315:	8b 45 08             	mov    0x8(%ebp),%eax
  801318:	8b 40 0c             	mov    0xc(%eax),%eax
  80131b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801320:	ba 00 00 00 00       	mov    $0x0,%edx
  801325:	b8 06 00 00 00       	mov    $0x6,%eax
  80132a:	e8 61 ff ff ff       	call   801290 <fsipc>
}
  80132f:	c9                   	leave  
  801330:	c3                   	ret    

00801331 <devfile_stat>:
{
  801331:	f3 0f 1e fb          	endbr32 
  801335:	55                   	push   %ebp
  801336:	89 e5                	mov    %esp,%ebp
  801338:	53                   	push   %ebx
  801339:	83 ec 04             	sub    $0x4,%esp
  80133c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80133f:	8b 45 08             	mov    0x8(%ebp),%eax
  801342:	8b 40 0c             	mov    0xc(%eax),%eax
  801345:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80134a:	ba 00 00 00 00       	mov    $0x0,%edx
  80134f:	b8 05 00 00 00       	mov    $0x5,%eax
  801354:	e8 37 ff ff ff       	call   801290 <fsipc>
  801359:	85 c0                	test   %eax,%eax
  80135b:	78 2c                	js     801389 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80135d:	83 ec 08             	sub    $0x8,%esp
  801360:	68 00 50 80 00       	push   $0x805000
  801365:	53                   	push   %ebx
  801366:	e8 8d f3 ff ff       	call   8006f8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  80136b:	a1 80 50 80 00       	mov    0x805080,%eax
  801370:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801376:	a1 84 50 80 00       	mov    0x805084,%eax
  80137b:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801381:	83 c4 10             	add    $0x10,%esp
  801384:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801389:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80138c:	c9                   	leave  
  80138d:	c3                   	ret    

0080138e <devfile_write>:
{
  80138e:	f3 0f 1e fb          	endbr32 
  801392:	55                   	push   %ebp
  801393:	89 e5                	mov    %esp,%ebp
  801395:	83 ec 0c             	sub    $0xc,%esp
  801398:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80139b:	8b 55 08             	mov    0x8(%ebp),%edx
  80139e:	8b 52 0c             	mov    0xc(%edx),%edx
  8013a1:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8013a7:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8013ac:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8013b1:	0f 47 c2             	cmova  %edx,%eax
  8013b4:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8013b9:	50                   	push   %eax
  8013ba:	ff 75 0c             	pushl  0xc(%ebp)
  8013bd:	68 08 50 80 00       	push   $0x805008
  8013c2:	e8 e9 f4 ff ff       	call   8008b0 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8013c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8013cc:	b8 04 00 00 00       	mov    $0x4,%eax
  8013d1:	e8 ba fe ff ff       	call   801290 <fsipc>
}
  8013d6:	c9                   	leave  
  8013d7:	c3                   	ret    

008013d8 <devfile_read>:
{
  8013d8:	f3 0f 1e fb          	endbr32 
  8013dc:	55                   	push   %ebp
  8013dd:	89 e5                	mov    %esp,%ebp
  8013df:	56                   	push   %esi
  8013e0:	53                   	push   %ebx
  8013e1:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  8013e4:	8b 45 08             	mov    0x8(%ebp),%eax
  8013e7:	8b 40 0c             	mov    0xc(%eax),%eax
  8013ea:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  8013ef:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  8013f5:	ba 00 00 00 00       	mov    $0x0,%edx
  8013fa:	b8 03 00 00 00       	mov    $0x3,%eax
  8013ff:	e8 8c fe ff ff       	call   801290 <fsipc>
  801404:	89 c3                	mov    %eax,%ebx
  801406:	85 c0                	test   %eax,%eax
  801408:	78 1f                	js     801429 <devfile_read+0x51>
	assert(r <= n);
  80140a:	39 f0                	cmp    %esi,%eax
  80140c:	77 24                	ja     801432 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  80140e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801413:	7f 33                	jg     801448 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801415:	83 ec 04             	sub    $0x4,%esp
  801418:	50                   	push   %eax
  801419:	68 00 50 80 00       	push   $0x805000
  80141e:	ff 75 0c             	pushl  0xc(%ebp)
  801421:	e8 8a f4 ff ff       	call   8008b0 <memmove>
	return r;
  801426:	83 c4 10             	add    $0x10,%esp
}
  801429:	89 d8                	mov    %ebx,%eax
  80142b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80142e:	5b                   	pop    %ebx
  80142f:	5e                   	pop    %esi
  801430:	5d                   	pop    %ebp
  801431:	c3                   	ret    
	assert(r <= n);
  801432:	68 f8 21 80 00       	push   $0x8021f8
  801437:	68 ff 21 80 00       	push   $0x8021ff
  80143c:	6a 7c                	push   $0x7c
  80143e:	68 14 22 80 00       	push   $0x802214
  801443:	e8 be 05 00 00       	call   801a06 <_panic>
	assert(r <= PGSIZE);
  801448:	68 1f 22 80 00       	push   $0x80221f
  80144d:	68 ff 21 80 00       	push   $0x8021ff
  801452:	6a 7d                	push   $0x7d
  801454:	68 14 22 80 00       	push   $0x802214
  801459:	e8 a8 05 00 00       	call   801a06 <_panic>

0080145e <open>:
{
  80145e:	f3 0f 1e fb          	endbr32 
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	56                   	push   %esi
  801466:	53                   	push   %ebx
  801467:	83 ec 1c             	sub    $0x1c,%esp
  80146a:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  80146d:	56                   	push   %esi
  80146e:	e8 42 f2 ff ff       	call   8006b5 <strlen>
  801473:	83 c4 10             	add    $0x10,%esp
  801476:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  80147b:	7f 6c                	jg     8014e9 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  80147d:	83 ec 0c             	sub    $0xc,%esp
  801480:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801483:	50                   	push   %eax
  801484:	e8 67 f8 ff ff       	call   800cf0 <fd_alloc>
  801489:	89 c3                	mov    %eax,%ebx
  80148b:	83 c4 10             	add    $0x10,%esp
  80148e:	85 c0                	test   %eax,%eax
  801490:	78 3c                	js     8014ce <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801492:	83 ec 08             	sub    $0x8,%esp
  801495:	56                   	push   %esi
  801496:	68 00 50 80 00       	push   $0x805000
  80149b:	e8 58 f2 ff ff       	call   8006f8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  8014a0:	8b 45 0c             	mov    0xc(%ebp),%eax
  8014a3:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8014a8:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014ab:	b8 01 00 00 00       	mov    $0x1,%eax
  8014b0:	e8 db fd ff ff       	call   801290 <fsipc>
  8014b5:	89 c3                	mov    %eax,%ebx
  8014b7:	83 c4 10             	add    $0x10,%esp
  8014ba:	85 c0                	test   %eax,%eax
  8014bc:	78 19                	js     8014d7 <open+0x79>
	return fd2num(fd);
  8014be:	83 ec 0c             	sub    $0xc,%esp
  8014c1:	ff 75 f4             	pushl  -0xc(%ebp)
  8014c4:	e8 f4 f7 ff ff       	call   800cbd <fd2num>
  8014c9:	89 c3                	mov    %eax,%ebx
  8014cb:	83 c4 10             	add    $0x10,%esp
}
  8014ce:	89 d8                	mov    %ebx,%eax
  8014d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8014d3:	5b                   	pop    %ebx
  8014d4:	5e                   	pop    %esi
  8014d5:	5d                   	pop    %ebp
  8014d6:	c3                   	ret    
		fd_close(fd, 0);
  8014d7:	83 ec 08             	sub    $0x8,%esp
  8014da:	6a 00                	push   $0x0
  8014dc:	ff 75 f4             	pushl  -0xc(%ebp)
  8014df:	e8 10 f9 ff ff       	call   800df4 <fd_close>
		return r;
  8014e4:	83 c4 10             	add    $0x10,%esp
  8014e7:	eb e5                	jmp    8014ce <open+0x70>
		return -E_BAD_PATH;
  8014e9:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  8014ee:	eb de                	jmp    8014ce <open+0x70>

008014f0 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  8014f0:	f3 0f 1e fb          	endbr32 
  8014f4:	55                   	push   %ebp
  8014f5:	89 e5                	mov    %esp,%ebp
  8014f7:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  8014fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8014ff:	b8 08 00 00 00       	mov    $0x8,%eax
  801504:	e8 87 fd ff ff       	call   801290 <fsipc>
}
  801509:	c9                   	leave  
  80150a:	c3                   	ret    

0080150b <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  80150b:	f3 0f 1e fb          	endbr32 
  80150f:	55                   	push   %ebp
  801510:	89 e5                	mov    %esp,%ebp
  801512:	56                   	push   %esi
  801513:	53                   	push   %ebx
  801514:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801517:	83 ec 0c             	sub    $0xc,%esp
  80151a:	ff 75 08             	pushl  0x8(%ebp)
  80151d:	e8 af f7 ff ff       	call   800cd1 <fd2data>
  801522:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801524:	83 c4 08             	add    $0x8,%esp
  801527:	68 2b 22 80 00       	push   $0x80222b
  80152c:	53                   	push   %ebx
  80152d:	e8 c6 f1 ff ff       	call   8006f8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801532:	8b 46 04             	mov    0x4(%esi),%eax
  801535:	2b 06                	sub    (%esi),%eax
  801537:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  80153d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801544:	00 00 00 
	stat->st_dev = &devpipe;
  801547:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  80154e:	30 80 00 
	return 0;
}
  801551:	b8 00 00 00 00       	mov    $0x0,%eax
  801556:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801559:	5b                   	pop    %ebx
  80155a:	5e                   	pop    %esi
  80155b:	5d                   	pop    %ebp
  80155c:	c3                   	ret    

0080155d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  80155d:	f3 0f 1e fb          	endbr32 
  801561:	55                   	push   %ebp
  801562:	89 e5                	mov    %esp,%ebp
  801564:	53                   	push   %ebx
  801565:	83 ec 0c             	sub    $0xc,%esp
  801568:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80156b:	53                   	push   %ebx
  80156c:	6a 00                	push   $0x0
  80156e:	e8 5f f6 ff ff       	call   800bd2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801573:	89 1c 24             	mov    %ebx,(%esp)
  801576:	e8 56 f7 ff ff       	call   800cd1 <fd2data>
  80157b:	83 c4 08             	add    $0x8,%esp
  80157e:	50                   	push   %eax
  80157f:	6a 00                	push   $0x0
  801581:	e8 4c f6 ff ff       	call   800bd2 <sys_page_unmap>
}
  801586:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801589:	c9                   	leave  
  80158a:	c3                   	ret    

0080158b <_pipeisclosed>:
{
  80158b:	55                   	push   %ebp
  80158c:	89 e5                	mov    %esp,%ebp
  80158e:	57                   	push   %edi
  80158f:	56                   	push   %esi
  801590:	53                   	push   %ebx
  801591:	83 ec 1c             	sub    $0x1c,%esp
  801594:	89 c7                	mov    %eax,%edi
  801596:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801598:	a1 04 40 80 00       	mov    0x804004,%eax
  80159d:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8015a0:	83 ec 0c             	sub    $0xc,%esp
  8015a3:	57                   	push   %edi
  8015a4:	e8 b7 05 00 00       	call   801b60 <pageref>
  8015a9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015ac:	89 34 24             	mov    %esi,(%esp)
  8015af:	e8 ac 05 00 00       	call   801b60 <pageref>
		nn = thisenv->env_runs;
  8015b4:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8015ba:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  8015bd:	83 c4 10             	add    $0x10,%esp
  8015c0:	39 cb                	cmp    %ecx,%ebx
  8015c2:	74 1b                	je     8015df <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  8015c4:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8015c7:	75 cf                	jne    801598 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  8015c9:	8b 42 58             	mov    0x58(%edx),%eax
  8015cc:	6a 01                	push   $0x1
  8015ce:	50                   	push   %eax
  8015cf:	53                   	push   %ebx
  8015d0:	68 32 22 80 00       	push   $0x802232
  8015d5:	e8 b4 eb ff ff       	call   80018e <cprintf>
  8015da:	83 c4 10             	add    $0x10,%esp
  8015dd:	eb b9                	jmp    801598 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8015df:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8015e2:	0f 94 c0             	sete   %al
  8015e5:	0f b6 c0             	movzbl %al,%eax
}
  8015e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015eb:	5b                   	pop    %ebx
  8015ec:	5e                   	pop    %esi
  8015ed:	5f                   	pop    %edi
  8015ee:	5d                   	pop    %ebp
  8015ef:	c3                   	ret    

008015f0 <devpipe_write>:
{
  8015f0:	f3 0f 1e fb          	endbr32 
  8015f4:	55                   	push   %ebp
  8015f5:	89 e5                	mov    %esp,%ebp
  8015f7:	57                   	push   %edi
  8015f8:	56                   	push   %esi
  8015f9:	53                   	push   %ebx
  8015fa:	83 ec 28             	sub    $0x28,%esp
  8015fd:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801600:	56                   	push   %esi
  801601:	e8 cb f6 ff ff       	call   800cd1 <fd2data>
  801606:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801608:	83 c4 10             	add    $0x10,%esp
  80160b:	bf 00 00 00 00       	mov    $0x0,%edi
  801610:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801613:	74 4f                	je     801664 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801615:	8b 43 04             	mov    0x4(%ebx),%eax
  801618:	8b 0b                	mov    (%ebx),%ecx
  80161a:	8d 51 20             	lea    0x20(%ecx),%edx
  80161d:	39 d0                	cmp    %edx,%eax
  80161f:	72 14                	jb     801635 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801621:	89 da                	mov    %ebx,%edx
  801623:	89 f0                	mov    %esi,%eax
  801625:	e8 61 ff ff ff       	call   80158b <_pipeisclosed>
  80162a:	85 c0                	test   %eax,%eax
  80162c:	75 3b                	jne    801669 <devpipe_write+0x79>
			sys_yield();
  80162e:	e8 22 f5 ff ff       	call   800b55 <sys_yield>
  801633:	eb e0                	jmp    801615 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801635:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801638:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  80163c:	88 4d e7             	mov    %cl,-0x19(%ebp)
  80163f:	89 c2                	mov    %eax,%edx
  801641:	c1 fa 1f             	sar    $0x1f,%edx
  801644:	89 d1                	mov    %edx,%ecx
  801646:	c1 e9 1b             	shr    $0x1b,%ecx
  801649:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  80164c:	83 e2 1f             	and    $0x1f,%edx
  80164f:	29 ca                	sub    %ecx,%edx
  801651:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801655:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801659:	83 c0 01             	add    $0x1,%eax
  80165c:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  80165f:	83 c7 01             	add    $0x1,%edi
  801662:	eb ac                	jmp    801610 <devpipe_write+0x20>
	return i;
  801664:	8b 45 10             	mov    0x10(%ebp),%eax
  801667:	eb 05                	jmp    80166e <devpipe_write+0x7e>
				return 0;
  801669:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80166e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801671:	5b                   	pop    %ebx
  801672:	5e                   	pop    %esi
  801673:	5f                   	pop    %edi
  801674:	5d                   	pop    %ebp
  801675:	c3                   	ret    

00801676 <devpipe_read>:
{
  801676:	f3 0f 1e fb          	endbr32 
  80167a:	55                   	push   %ebp
  80167b:	89 e5                	mov    %esp,%ebp
  80167d:	57                   	push   %edi
  80167e:	56                   	push   %esi
  80167f:	53                   	push   %ebx
  801680:	83 ec 18             	sub    $0x18,%esp
  801683:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801686:	57                   	push   %edi
  801687:	e8 45 f6 ff ff       	call   800cd1 <fd2data>
  80168c:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80168e:	83 c4 10             	add    $0x10,%esp
  801691:	be 00 00 00 00       	mov    $0x0,%esi
  801696:	3b 75 10             	cmp    0x10(%ebp),%esi
  801699:	75 14                	jne    8016af <devpipe_read+0x39>
	return i;
  80169b:	8b 45 10             	mov    0x10(%ebp),%eax
  80169e:	eb 02                	jmp    8016a2 <devpipe_read+0x2c>
				return i;
  8016a0:	89 f0                	mov    %esi,%eax
}
  8016a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016a5:	5b                   	pop    %ebx
  8016a6:	5e                   	pop    %esi
  8016a7:	5f                   	pop    %edi
  8016a8:	5d                   	pop    %ebp
  8016a9:	c3                   	ret    
			sys_yield();
  8016aa:	e8 a6 f4 ff ff       	call   800b55 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  8016af:	8b 03                	mov    (%ebx),%eax
  8016b1:	3b 43 04             	cmp    0x4(%ebx),%eax
  8016b4:	75 18                	jne    8016ce <devpipe_read+0x58>
			if (i > 0)
  8016b6:	85 f6                	test   %esi,%esi
  8016b8:	75 e6                	jne    8016a0 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  8016ba:	89 da                	mov    %ebx,%edx
  8016bc:	89 f8                	mov    %edi,%eax
  8016be:	e8 c8 fe ff ff       	call   80158b <_pipeisclosed>
  8016c3:	85 c0                	test   %eax,%eax
  8016c5:	74 e3                	je     8016aa <devpipe_read+0x34>
				return 0;
  8016c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016cc:	eb d4                	jmp    8016a2 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  8016ce:	99                   	cltd   
  8016cf:	c1 ea 1b             	shr    $0x1b,%edx
  8016d2:	01 d0                	add    %edx,%eax
  8016d4:	83 e0 1f             	and    $0x1f,%eax
  8016d7:	29 d0                	sub    %edx,%eax
  8016d9:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8016de:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8016e1:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8016e4:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8016e7:	83 c6 01             	add    $0x1,%esi
  8016ea:	eb aa                	jmp    801696 <devpipe_read+0x20>

008016ec <pipe>:
{
  8016ec:	f3 0f 1e fb          	endbr32 
  8016f0:	55                   	push   %ebp
  8016f1:	89 e5                	mov    %esp,%ebp
  8016f3:	56                   	push   %esi
  8016f4:	53                   	push   %ebx
  8016f5:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8016f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8016fb:	50                   	push   %eax
  8016fc:	e8 ef f5 ff ff       	call   800cf0 <fd_alloc>
  801701:	89 c3                	mov    %eax,%ebx
  801703:	83 c4 10             	add    $0x10,%esp
  801706:	85 c0                	test   %eax,%eax
  801708:	0f 88 23 01 00 00    	js     801831 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80170e:	83 ec 04             	sub    $0x4,%esp
  801711:	68 07 04 00 00       	push   $0x407
  801716:	ff 75 f4             	pushl  -0xc(%ebp)
  801719:	6a 00                	push   $0x0
  80171b:	e8 60 f4 ff ff       	call   800b80 <sys_page_alloc>
  801720:	89 c3                	mov    %eax,%ebx
  801722:	83 c4 10             	add    $0x10,%esp
  801725:	85 c0                	test   %eax,%eax
  801727:	0f 88 04 01 00 00    	js     801831 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  80172d:	83 ec 0c             	sub    $0xc,%esp
  801730:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801733:	50                   	push   %eax
  801734:	e8 b7 f5 ff ff       	call   800cf0 <fd_alloc>
  801739:	89 c3                	mov    %eax,%ebx
  80173b:	83 c4 10             	add    $0x10,%esp
  80173e:	85 c0                	test   %eax,%eax
  801740:	0f 88 db 00 00 00    	js     801821 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801746:	83 ec 04             	sub    $0x4,%esp
  801749:	68 07 04 00 00       	push   $0x407
  80174e:	ff 75 f0             	pushl  -0x10(%ebp)
  801751:	6a 00                	push   $0x0
  801753:	e8 28 f4 ff ff       	call   800b80 <sys_page_alloc>
  801758:	89 c3                	mov    %eax,%ebx
  80175a:	83 c4 10             	add    $0x10,%esp
  80175d:	85 c0                	test   %eax,%eax
  80175f:	0f 88 bc 00 00 00    	js     801821 <pipe+0x135>
	va = fd2data(fd0);
  801765:	83 ec 0c             	sub    $0xc,%esp
  801768:	ff 75 f4             	pushl  -0xc(%ebp)
  80176b:	e8 61 f5 ff ff       	call   800cd1 <fd2data>
  801770:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801772:	83 c4 0c             	add    $0xc,%esp
  801775:	68 07 04 00 00       	push   $0x407
  80177a:	50                   	push   %eax
  80177b:	6a 00                	push   $0x0
  80177d:	e8 fe f3 ff ff       	call   800b80 <sys_page_alloc>
  801782:	89 c3                	mov    %eax,%ebx
  801784:	83 c4 10             	add    $0x10,%esp
  801787:	85 c0                	test   %eax,%eax
  801789:	0f 88 82 00 00 00    	js     801811 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80178f:	83 ec 0c             	sub    $0xc,%esp
  801792:	ff 75 f0             	pushl  -0x10(%ebp)
  801795:	e8 37 f5 ff ff       	call   800cd1 <fd2data>
  80179a:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  8017a1:	50                   	push   %eax
  8017a2:	6a 00                	push   $0x0
  8017a4:	56                   	push   %esi
  8017a5:	6a 00                	push   $0x0
  8017a7:	e8 fc f3 ff ff       	call   800ba8 <sys_page_map>
  8017ac:	89 c3                	mov    %eax,%ebx
  8017ae:	83 c4 20             	add    $0x20,%esp
  8017b1:	85 c0                	test   %eax,%eax
  8017b3:	78 4e                	js     801803 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  8017b5:	a1 20 30 80 00       	mov    0x803020,%eax
  8017ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017bd:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  8017bf:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017c2:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  8017c9:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017cc:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  8017ce:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d1:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  8017d8:	83 ec 0c             	sub    $0xc,%esp
  8017db:	ff 75 f4             	pushl  -0xc(%ebp)
  8017de:	e8 da f4 ff ff       	call   800cbd <fd2num>
  8017e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017e6:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8017e8:	83 c4 04             	add    $0x4,%esp
  8017eb:	ff 75 f0             	pushl  -0x10(%ebp)
  8017ee:	e8 ca f4 ff ff       	call   800cbd <fd2num>
  8017f3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017f6:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8017f9:	83 c4 10             	add    $0x10,%esp
  8017fc:	bb 00 00 00 00       	mov    $0x0,%ebx
  801801:	eb 2e                	jmp    801831 <pipe+0x145>
	sys_page_unmap(0, va);
  801803:	83 ec 08             	sub    $0x8,%esp
  801806:	56                   	push   %esi
  801807:	6a 00                	push   $0x0
  801809:	e8 c4 f3 ff ff       	call   800bd2 <sys_page_unmap>
  80180e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801811:	83 ec 08             	sub    $0x8,%esp
  801814:	ff 75 f0             	pushl  -0x10(%ebp)
  801817:	6a 00                	push   $0x0
  801819:	e8 b4 f3 ff ff       	call   800bd2 <sys_page_unmap>
  80181e:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801821:	83 ec 08             	sub    $0x8,%esp
  801824:	ff 75 f4             	pushl  -0xc(%ebp)
  801827:	6a 00                	push   $0x0
  801829:	e8 a4 f3 ff ff       	call   800bd2 <sys_page_unmap>
  80182e:	83 c4 10             	add    $0x10,%esp
}
  801831:	89 d8                	mov    %ebx,%eax
  801833:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801836:	5b                   	pop    %ebx
  801837:	5e                   	pop    %esi
  801838:	5d                   	pop    %ebp
  801839:	c3                   	ret    

0080183a <pipeisclosed>:
{
  80183a:	f3 0f 1e fb          	endbr32 
  80183e:	55                   	push   %ebp
  80183f:	89 e5                	mov    %esp,%ebp
  801841:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801844:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801847:	50                   	push   %eax
  801848:	ff 75 08             	pushl  0x8(%ebp)
  80184b:	e8 f6 f4 ff ff       	call   800d46 <fd_lookup>
  801850:	83 c4 10             	add    $0x10,%esp
  801853:	85 c0                	test   %eax,%eax
  801855:	78 18                	js     80186f <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801857:	83 ec 0c             	sub    $0xc,%esp
  80185a:	ff 75 f4             	pushl  -0xc(%ebp)
  80185d:	e8 6f f4 ff ff       	call   800cd1 <fd2data>
  801862:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801864:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801867:	e8 1f fd ff ff       	call   80158b <_pipeisclosed>
  80186c:	83 c4 10             	add    $0x10,%esp
}
  80186f:	c9                   	leave  
  801870:	c3                   	ret    

00801871 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801871:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801875:	b8 00 00 00 00       	mov    $0x0,%eax
  80187a:	c3                   	ret    

0080187b <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80187b:	f3 0f 1e fb          	endbr32 
  80187f:	55                   	push   %ebp
  801880:	89 e5                	mov    %esp,%ebp
  801882:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801885:	68 4a 22 80 00       	push   $0x80224a
  80188a:	ff 75 0c             	pushl  0xc(%ebp)
  80188d:	e8 66 ee ff ff       	call   8006f8 <strcpy>
	return 0;
}
  801892:	b8 00 00 00 00       	mov    $0x0,%eax
  801897:	c9                   	leave  
  801898:	c3                   	ret    

00801899 <devcons_write>:
{
  801899:	f3 0f 1e fb          	endbr32 
  80189d:	55                   	push   %ebp
  80189e:	89 e5                	mov    %esp,%ebp
  8018a0:	57                   	push   %edi
  8018a1:	56                   	push   %esi
  8018a2:	53                   	push   %ebx
  8018a3:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8018a9:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8018ae:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8018b4:	3b 75 10             	cmp    0x10(%ebp),%esi
  8018b7:	73 31                	jae    8018ea <devcons_write+0x51>
		m = n - tot;
  8018b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8018bc:	29 f3                	sub    %esi,%ebx
  8018be:	83 fb 7f             	cmp    $0x7f,%ebx
  8018c1:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8018c6:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8018c9:	83 ec 04             	sub    $0x4,%esp
  8018cc:	53                   	push   %ebx
  8018cd:	89 f0                	mov    %esi,%eax
  8018cf:	03 45 0c             	add    0xc(%ebp),%eax
  8018d2:	50                   	push   %eax
  8018d3:	57                   	push   %edi
  8018d4:	e8 d7 ef ff ff       	call   8008b0 <memmove>
		sys_cputs(buf, m);
  8018d9:	83 c4 08             	add    $0x8,%esp
  8018dc:	53                   	push   %ebx
  8018dd:	57                   	push   %edi
  8018de:	e8 d2 f1 ff ff       	call   800ab5 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8018e3:	01 de                	add    %ebx,%esi
  8018e5:	83 c4 10             	add    $0x10,%esp
  8018e8:	eb ca                	jmp    8018b4 <devcons_write+0x1b>
}
  8018ea:	89 f0                	mov    %esi,%eax
  8018ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8018ef:	5b                   	pop    %ebx
  8018f0:	5e                   	pop    %esi
  8018f1:	5f                   	pop    %edi
  8018f2:	5d                   	pop    %ebp
  8018f3:	c3                   	ret    

008018f4 <devcons_read>:
{
  8018f4:	f3 0f 1e fb          	endbr32 
  8018f8:	55                   	push   %ebp
  8018f9:	89 e5                	mov    %esp,%ebp
  8018fb:	83 ec 08             	sub    $0x8,%esp
  8018fe:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  801903:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  801907:	74 21                	je     80192a <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  801909:	e8 d1 f1 ff ff       	call   800adf <sys_cgetc>
  80190e:	85 c0                	test   %eax,%eax
  801910:	75 07                	jne    801919 <devcons_read+0x25>
		sys_yield();
  801912:	e8 3e f2 ff ff       	call   800b55 <sys_yield>
  801917:	eb f0                	jmp    801909 <devcons_read+0x15>
	if (c < 0)
  801919:	78 0f                	js     80192a <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  80191b:	83 f8 04             	cmp    $0x4,%eax
  80191e:	74 0c                	je     80192c <devcons_read+0x38>
	*(char*)vbuf = c;
  801920:	8b 55 0c             	mov    0xc(%ebp),%edx
  801923:	88 02                	mov    %al,(%edx)
	return 1;
  801925:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80192a:	c9                   	leave  
  80192b:	c3                   	ret    
		return 0;
  80192c:	b8 00 00 00 00       	mov    $0x0,%eax
  801931:	eb f7                	jmp    80192a <devcons_read+0x36>

00801933 <cputchar>:
{
  801933:	f3 0f 1e fb          	endbr32 
  801937:	55                   	push   %ebp
  801938:	89 e5                	mov    %esp,%ebp
  80193a:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80193d:	8b 45 08             	mov    0x8(%ebp),%eax
  801940:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  801943:	6a 01                	push   $0x1
  801945:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801948:	50                   	push   %eax
  801949:	e8 67 f1 ff ff       	call   800ab5 <sys_cputs>
}
  80194e:	83 c4 10             	add    $0x10,%esp
  801951:	c9                   	leave  
  801952:	c3                   	ret    

00801953 <getchar>:
{
  801953:	f3 0f 1e fb          	endbr32 
  801957:	55                   	push   %ebp
  801958:	89 e5                	mov    %esp,%ebp
  80195a:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80195d:	6a 01                	push   $0x1
  80195f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  801962:	50                   	push   %eax
  801963:	6a 00                	push   $0x0
  801965:	e8 5f f6 ff ff       	call   800fc9 <read>
	if (r < 0)
  80196a:	83 c4 10             	add    $0x10,%esp
  80196d:	85 c0                	test   %eax,%eax
  80196f:	78 06                	js     801977 <getchar+0x24>
	if (r < 1)
  801971:	74 06                	je     801979 <getchar+0x26>
	return c;
  801973:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  801977:	c9                   	leave  
  801978:	c3                   	ret    
		return -E_EOF;
  801979:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80197e:	eb f7                	jmp    801977 <getchar+0x24>

00801980 <iscons>:
{
  801980:	f3 0f 1e fb          	endbr32 
  801984:	55                   	push   %ebp
  801985:	89 e5                	mov    %esp,%ebp
  801987:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80198a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80198d:	50                   	push   %eax
  80198e:	ff 75 08             	pushl  0x8(%ebp)
  801991:	e8 b0 f3 ff ff       	call   800d46 <fd_lookup>
  801996:	83 c4 10             	add    $0x10,%esp
  801999:	85 c0                	test   %eax,%eax
  80199b:	78 11                	js     8019ae <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80199d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019a0:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019a6:	39 10                	cmp    %edx,(%eax)
  8019a8:	0f 94 c0             	sete   %al
  8019ab:	0f b6 c0             	movzbl %al,%eax
}
  8019ae:	c9                   	leave  
  8019af:	c3                   	ret    

008019b0 <opencons>:
{
  8019b0:	f3 0f 1e fb          	endbr32 
  8019b4:	55                   	push   %ebp
  8019b5:	89 e5                	mov    %esp,%ebp
  8019b7:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8019ba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019bd:	50                   	push   %eax
  8019be:	e8 2d f3 ff ff       	call   800cf0 <fd_alloc>
  8019c3:	83 c4 10             	add    $0x10,%esp
  8019c6:	85 c0                	test   %eax,%eax
  8019c8:	78 3a                	js     801a04 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8019ca:	83 ec 04             	sub    $0x4,%esp
  8019cd:	68 07 04 00 00       	push   $0x407
  8019d2:	ff 75 f4             	pushl  -0xc(%ebp)
  8019d5:	6a 00                	push   $0x0
  8019d7:	e8 a4 f1 ff ff       	call   800b80 <sys_page_alloc>
  8019dc:	83 c4 10             	add    $0x10,%esp
  8019df:	85 c0                	test   %eax,%eax
  8019e1:	78 21                	js     801a04 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8019e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019e6:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8019ec:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8019ee:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019f1:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8019f8:	83 ec 0c             	sub    $0xc,%esp
  8019fb:	50                   	push   %eax
  8019fc:	e8 bc f2 ff ff       	call   800cbd <fd2num>
  801a01:	83 c4 10             	add    $0x10,%esp
}
  801a04:	c9                   	leave  
  801a05:	c3                   	ret    

00801a06 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801a06:	f3 0f 1e fb          	endbr32 
  801a0a:	55                   	push   %ebp
  801a0b:	89 e5                	mov    %esp,%ebp
  801a0d:	56                   	push   %esi
  801a0e:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801a0f:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801a12:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801a18:	e8 10 f1 ff ff       	call   800b2d <sys_getenvid>
  801a1d:	83 ec 0c             	sub    $0xc,%esp
  801a20:	ff 75 0c             	pushl  0xc(%ebp)
  801a23:	ff 75 08             	pushl  0x8(%ebp)
  801a26:	56                   	push   %esi
  801a27:	50                   	push   %eax
  801a28:	68 58 22 80 00       	push   $0x802258
  801a2d:	e8 5c e7 ff ff       	call   80018e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801a32:	83 c4 18             	add    $0x18,%esp
  801a35:	53                   	push   %ebx
  801a36:	ff 75 10             	pushl  0x10(%ebp)
  801a39:	e8 fb e6 ff ff       	call   800139 <vcprintf>
	cprintf("\n");
  801a3e:	c7 04 24 43 22 80 00 	movl   $0x802243,(%esp)
  801a45:	e8 44 e7 ff ff       	call   80018e <cprintf>
  801a4a:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801a4d:	cc                   	int3   
  801a4e:	eb fd                	jmp    801a4d <_panic+0x47>

00801a50 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a50:	f3 0f 1e fb          	endbr32 
  801a54:	55                   	push   %ebp
  801a55:	89 e5                	mov    %esp,%ebp
  801a57:	56                   	push   %esi
  801a58:	53                   	push   %ebx
  801a59:	8b 75 08             	mov    0x8(%ebp),%esi
  801a5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a5f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  801a62:	85 c0                	test   %eax,%eax
  801a64:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a69:	0f 44 c2             	cmove  %edx,%eax
  801a6c:	83 ec 0c             	sub    $0xc,%esp
  801a6f:	50                   	push   %eax
  801a70:	e8 22 f2 ff ff       	call   800c97 <sys_ipc_recv>

	if (from_env_store != NULL)
  801a75:	83 c4 10             	add    $0x10,%esp
  801a78:	85 f6                	test   %esi,%esi
  801a7a:	74 15                	je     801a91 <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  801a7c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a81:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a84:	74 09                	je     801a8f <ipc_recv+0x3f>
  801a86:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a8c:	8b 52 74             	mov    0x74(%edx),%edx
  801a8f:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  801a91:	85 db                	test   %ebx,%ebx
  801a93:	74 15                	je     801aaa <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  801a95:	ba 00 00 00 00       	mov    $0x0,%edx
  801a9a:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a9d:	74 09                	je     801aa8 <ipc_recv+0x58>
  801a9f:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801aa5:	8b 52 78             	mov    0x78(%edx),%edx
  801aa8:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  801aaa:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801aad:	74 08                	je     801ab7 <ipc_recv+0x67>
  801aaf:	a1 04 40 80 00       	mov    0x804004,%eax
  801ab4:	8b 40 70             	mov    0x70(%eax),%eax
}
  801ab7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aba:	5b                   	pop    %ebx
  801abb:	5e                   	pop    %esi
  801abc:	5d                   	pop    %ebp
  801abd:	c3                   	ret    

00801abe <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801abe:	f3 0f 1e fb          	endbr32 
  801ac2:	55                   	push   %ebp
  801ac3:	89 e5                	mov    %esp,%ebp
  801ac5:	57                   	push   %edi
  801ac6:	56                   	push   %esi
  801ac7:	53                   	push   %ebx
  801ac8:	83 ec 0c             	sub    $0xc,%esp
  801acb:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ace:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ad1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ad4:	eb 1f                	jmp    801af5 <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  801ad6:	6a 00                	push   $0x0
  801ad8:	68 00 00 c0 ee       	push   $0xeec00000
  801add:	56                   	push   %esi
  801ade:	57                   	push   %edi
  801adf:	e8 8a f1 ff ff       	call   800c6e <sys_ipc_try_send>
  801ae4:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  801ae7:	85 c0                	test   %eax,%eax
  801ae9:	74 30                	je     801b1b <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  801aeb:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aee:	75 19                	jne    801b09 <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  801af0:	e8 60 f0 ff ff       	call   800b55 <sys_yield>
		if (pg != NULL) {
  801af5:	85 db                	test   %ebx,%ebx
  801af7:	74 dd                	je     801ad6 <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  801af9:	ff 75 14             	pushl  0x14(%ebp)
  801afc:	53                   	push   %ebx
  801afd:	56                   	push   %esi
  801afe:	57                   	push   %edi
  801aff:	e8 6a f1 ff ff       	call   800c6e <sys_ipc_try_send>
  801b04:	83 c4 10             	add    $0x10,%esp
  801b07:	eb de                	jmp    801ae7 <ipc_send+0x29>
			panic("ipc_send: %d", res);
  801b09:	50                   	push   %eax
  801b0a:	68 7b 22 80 00       	push   $0x80227b
  801b0f:	6a 3e                	push   $0x3e
  801b11:	68 88 22 80 00       	push   $0x802288
  801b16:	e8 eb fe ff ff       	call   801a06 <_panic>
	}
}
  801b1b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b1e:	5b                   	pop    %ebx
  801b1f:	5e                   	pop    %esi
  801b20:	5f                   	pop    %edi
  801b21:	5d                   	pop    %ebp
  801b22:	c3                   	ret    

00801b23 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b23:	f3 0f 1e fb          	endbr32 
  801b27:	55                   	push   %ebp
  801b28:	89 e5                	mov    %esp,%ebp
  801b2a:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b2d:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b32:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b35:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b3b:	8b 52 50             	mov    0x50(%edx),%edx
  801b3e:	39 ca                	cmp    %ecx,%edx
  801b40:	74 11                	je     801b53 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801b42:	83 c0 01             	add    $0x1,%eax
  801b45:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b4a:	75 e6                	jne    801b32 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801b4c:	b8 00 00 00 00       	mov    $0x0,%eax
  801b51:	eb 0b                	jmp    801b5e <ipc_find_env+0x3b>
			return envs[i].env_id;
  801b53:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b56:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b5b:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b5e:	5d                   	pop    %ebp
  801b5f:	c3                   	ret    

00801b60 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b60:	f3 0f 1e fb          	endbr32 
  801b64:	55                   	push   %ebp
  801b65:	89 e5                	mov    %esp,%ebp
  801b67:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b6a:	89 c2                	mov    %eax,%edx
  801b6c:	c1 ea 16             	shr    $0x16,%edx
  801b6f:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b76:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b7b:	f6 c1 01             	test   $0x1,%cl
  801b7e:	74 1c                	je     801b9c <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801b80:	c1 e8 0c             	shr    $0xc,%eax
  801b83:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b8a:	a8 01                	test   $0x1,%al
  801b8c:	74 0e                	je     801b9c <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b8e:	c1 e8 0c             	shr    $0xc,%eax
  801b91:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b98:	ef 
  801b99:	0f b7 d2             	movzwl %dx,%edx
}
  801b9c:	89 d0                	mov    %edx,%eax
  801b9e:	5d                   	pop    %ebp
  801b9f:	c3                   	ret    

00801ba0 <__udivdi3>:
  801ba0:	f3 0f 1e fb          	endbr32 
  801ba4:	55                   	push   %ebp
  801ba5:	57                   	push   %edi
  801ba6:	56                   	push   %esi
  801ba7:	53                   	push   %ebx
  801ba8:	83 ec 1c             	sub    $0x1c,%esp
  801bab:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801baf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801bb3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801bb7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801bbb:	85 d2                	test   %edx,%edx
  801bbd:	75 19                	jne    801bd8 <__udivdi3+0x38>
  801bbf:	39 f3                	cmp    %esi,%ebx
  801bc1:	76 4d                	jbe    801c10 <__udivdi3+0x70>
  801bc3:	31 ff                	xor    %edi,%edi
  801bc5:	89 e8                	mov    %ebp,%eax
  801bc7:	89 f2                	mov    %esi,%edx
  801bc9:	f7 f3                	div    %ebx
  801bcb:	89 fa                	mov    %edi,%edx
  801bcd:	83 c4 1c             	add    $0x1c,%esp
  801bd0:	5b                   	pop    %ebx
  801bd1:	5e                   	pop    %esi
  801bd2:	5f                   	pop    %edi
  801bd3:	5d                   	pop    %ebp
  801bd4:	c3                   	ret    
  801bd5:	8d 76 00             	lea    0x0(%esi),%esi
  801bd8:	39 f2                	cmp    %esi,%edx
  801bda:	76 14                	jbe    801bf0 <__udivdi3+0x50>
  801bdc:	31 ff                	xor    %edi,%edi
  801bde:	31 c0                	xor    %eax,%eax
  801be0:	89 fa                	mov    %edi,%edx
  801be2:	83 c4 1c             	add    $0x1c,%esp
  801be5:	5b                   	pop    %ebx
  801be6:	5e                   	pop    %esi
  801be7:	5f                   	pop    %edi
  801be8:	5d                   	pop    %ebp
  801be9:	c3                   	ret    
  801bea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bf0:	0f bd fa             	bsr    %edx,%edi
  801bf3:	83 f7 1f             	xor    $0x1f,%edi
  801bf6:	75 48                	jne    801c40 <__udivdi3+0xa0>
  801bf8:	39 f2                	cmp    %esi,%edx
  801bfa:	72 06                	jb     801c02 <__udivdi3+0x62>
  801bfc:	31 c0                	xor    %eax,%eax
  801bfe:	39 eb                	cmp    %ebp,%ebx
  801c00:	77 de                	ja     801be0 <__udivdi3+0x40>
  801c02:	b8 01 00 00 00       	mov    $0x1,%eax
  801c07:	eb d7                	jmp    801be0 <__udivdi3+0x40>
  801c09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c10:	89 d9                	mov    %ebx,%ecx
  801c12:	85 db                	test   %ebx,%ebx
  801c14:	75 0b                	jne    801c21 <__udivdi3+0x81>
  801c16:	b8 01 00 00 00       	mov    $0x1,%eax
  801c1b:	31 d2                	xor    %edx,%edx
  801c1d:	f7 f3                	div    %ebx
  801c1f:	89 c1                	mov    %eax,%ecx
  801c21:	31 d2                	xor    %edx,%edx
  801c23:	89 f0                	mov    %esi,%eax
  801c25:	f7 f1                	div    %ecx
  801c27:	89 c6                	mov    %eax,%esi
  801c29:	89 e8                	mov    %ebp,%eax
  801c2b:	89 f7                	mov    %esi,%edi
  801c2d:	f7 f1                	div    %ecx
  801c2f:	89 fa                	mov    %edi,%edx
  801c31:	83 c4 1c             	add    $0x1c,%esp
  801c34:	5b                   	pop    %ebx
  801c35:	5e                   	pop    %esi
  801c36:	5f                   	pop    %edi
  801c37:	5d                   	pop    %ebp
  801c38:	c3                   	ret    
  801c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c40:	89 f9                	mov    %edi,%ecx
  801c42:	b8 20 00 00 00       	mov    $0x20,%eax
  801c47:	29 f8                	sub    %edi,%eax
  801c49:	d3 e2                	shl    %cl,%edx
  801c4b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c4f:	89 c1                	mov    %eax,%ecx
  801c51:	89 da                	mov    %ebx,%edx
  801c53:	d3 ea                	shr    %cl,%edx
  801c55:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c59:	09 d1                	or     %edx,%ecx
  801c5b:	89 f2                	mov    %esi,%edx
  801c5d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c61:	89 f9                	mov    %edi,%ecx
  801c63:	d3 e3                	shl    %cl,%ebx
  801c65:	89 c1                	mov    %eax,%ecx
  801c67:	d3 ea                	shr    %cl,%edx
  801c69:	89 f9                	mov    %edi,%ecx
  801c6b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c6f:	89 eb                	mov    %ebp,%ebx
  801c71:	d3 e6                	shl    %cl,%esi
  801c73:	89 c1                	mov    %eax,%ecx
  801c75:	d3 eb                	shr    %cl,%ebx
  801c77:	09 de                	or     %ebx,%esi
  801c79:	89 f0                	mov    %esi,%eax
  801c7b:	f7 74 24 08          	divl   0x8(%esp)
  801c7f:	89 d6                	mov    %edx,%esi
  801c81:	89 c3                	mov    %eax,%ebx
  801c83:	f7 64 24 0c          	mull   0xc(%esp)
  801c87:	39 d6                	cmp    %edx,%esi
  801c89:	72 15                	jb     801ca0 <__udivdi3+0x100>
  801c8b:	89 f9                	mov    %edi,%ecx
  801c8d:	d3 e5                	shl    %cl,%ebp
  801c8f:	39 c5                	cmp    %eax,%ebp
  801c91:	73 04                	jae    801c97 <__udivdi3+0xf7>
  801c93:	39 d6                	cmp    %edx,%esi
  801c95:	74 09                	je     801ca0 <__udivdi3+0x100>
  801c97:	89 d8                	mov    %ebx,%eax
  801c99:	31 ff                	xor    %edi,%edi
  801c9b:	e9 40 ff ff ff       	jmp    801be0 <__udivdi3+0x40>
  801ca0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801ca3:	31 ff                	xor    %edi,%edi
  801ca5:	e9 36 ff ff ff       	jmp    801be0 <__udivdi3+0x40>
  801caa:	66 90                	xchg   %ax,%ax
  801cac:	66 90                	xchg   %ax,%ax
  801cae:	66 90                	xchg   %ax,%ax

00801cb0 <__umoddi3>:
  801cb0:	f3 0f 1e fb          	endbr32 
  801cb4:	55                   	push   %ebp
  801cb5:	57                   	push   %edi
  801cb6:	56                   	push   %esi
  801cb7:	53                   	push   %ebx
  801cb8:	83 ec 1c             	sub    $0x1c,%esp
  801cbb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801cbf:	8b 74 24 30          	mov    0x30(%esp),%esi
  801cc3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801cc7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ccb:	85 c0                	test   %eax,%eax
  801ccd:	75 19                	jne    801ce8 <__umoddi3+0x38>
  801ccf:	39 df                	cmp    %ebx,%edi
  801cd1:	76 5d                	jbe    801d30 <__umoddi3+0x80>
  801cd3:	89 f0                	mov    %esi,%eax
  801cd5:	89 da                	mov    %ebx,%edx
  801cd7:	f7 f7                	div    %edi
  801cd9:	89 d0                	mov    %edx,%eax
  801cdb:	31 d2                	xor    %edx,%edx
  801cdd:	83 c4 1c             	add    $0x1c,%esp
  801ce0:	5b                   	pop    %ebx
  801ce1:	5e                   	pop    %esi
  801ce2:	5f                   	pop    %edi
  801ce3:	5d                   	pop    %ebp
  801ce4:	c3                   	ret    
  801ce5:	8d 76 00             	lea    0x0(%esi),%esi
  801ce8:	89 f2                	mov    %esi,%edx
  801cea:	39 d8                	cmp    %ebx,%eax
  801cec:	76 12                	jbe    801d00 <__umoddi3+0x50>
  801cee:	89 f0                	mov    %esi,%eax
  801cf0:	89 da                	mov    %ebx,%edx
  801cf2:	83 c4 1c             	add    $0x1c,%esp
  801cf5:	5b                   	pop    %ebx
  801cf6:	5e                   	pop    %esi
  801cf7:	5f                   	pop    %edi
  801cf8:	5d                   	pop    %ebp
  801cf9:	c3                   	ret    
  801cfa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801d00:	0f bd e8             	bsr    %eax,%ebp
  801d03:	83 f5 1f             	xor    $0x1f,%ebp
  801d06:	75 50                	jne    801d58 <__umoddi3+0xa8>
  801d08:	39 d8                	cmp    %ebx,%eax
  801d0a:	0f 82 e0 00 00 00    	jb     801df0 <__umoddi3+0x140>
  801d10:	89 d9                	mov    %ebx,%ecx
  801d12:	39 f7                	cmp    %esi,%edi
  801d14:	0f 86 d6 00 00 00    	jbe    801df0 <__umoddi3+0x140>
  801d1a:	89 d0                	mov    %edx,%eax
  801d1c:	89 ca                	mov    %ecx,%edx
  801d1e:	83 c4 1c             	add    $0x1c,%esp
  801d21:	5b                   	pop    %ebx
  801d22:	5e                   	pop    %esi
  801d23:	5f                   	pop    %edi
  801d24:	5d                   	pop    %ebp
  801d25:	c3                   	ret    
  801d26:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d2d:	8d 76 00             	lea    0x0(%esi),%esi
  801d30:	89 fd                	mov    %edi,%ebp
  801d32:	85 ff                	test   %edi,%edi
  801d34:	75 0b                	jne    801d41 <__umoddi3+0x91>
  801d36:	b8 01 00 00 00       	mov    $0x1,%eax
  801d3b:	31 d2                	xor    %edx,%edx
  801d3d:	f7 f7                	div    %edi
  801d3f:	89 c5                	mov    %eax,%ebp
  801d41:	89 d8                	mov    %ebx,%eax
  801d43:	31 d2                	xor    %edx,%edx
  801d45:	f7 f5                	div    %ebp
  801d47:	89 f0                	mov    %esi,%eax
  801d49:	f7 f5                	div    %ebp
  801d4b:	89 d0                	mov    %edx,%eax
  801d4d:	31 d2                	xor    %edx,%edx
  801d4f:	eb 8c                	jmp    801cdd <__umoddi3+0x2d>
  801d51:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d58:	89 e9                	mov    %ebp,%ecx
  801d5a:	ba 20 00 00 00       	mov    $0x20,%edx
  801d5f:	29 ea                	sub    %ebp,%edx
  801d61:	d3 e0                	shl    %cl,%eax
  801d63:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d67:	89 d1                	mov    %edx,%ecx
  801d69:	89 f8                	mov    %edi,%eax
  801d6b:	d3 e8                	shr    %cl,%eax
  801d6d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d71:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d75:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d79:	09 c1                	or     %eax,%ecx
  801d7b:	89 d8                	mov    %ebx,%eax
  801d7d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d81:	89 e9                	mov    %ebp,%ecx
  801d83:	d3 e7                	shl    %cl,%edi
  801d85:	89 d1                	mov    %edx,%ecx
  801d87:	d3 e8                	shr    %cl,%eax
  801d89:	89 e9                	mov    %ebp,%ecx
  801d8b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d8f:	d3 e3                	shl    %cl,%ebx
  801d91:	89 c7                	mov    %eax,%edi
  801d93:	89 d1                	mov    %edx,%ecx
  801d95:	89 f0                	mov    %esi,%eax
  801d97:	d3 e8                	shr    %cl,%eax
  801d99:	89 e9                	mov    %ebp,%ecx
  801d9b:	89 fa                	mov    %edi,%edx
  801d9d:	d3 e6                	shl    %cl,%esi
  801d9f:	09 d8                	or     %ebx,%eax
  801da1:	f7 74 24 08          	divl   0x8(%esp)
  801da5:	89 d1                	mov    %edx,%ecx
  801da7:	89 f3                	mov    %esi,%ebx
  801da9:	f7 64 24 0c          	mull   0xc(%esp)
  801dad:	89 c6                	mov    %eax,%esi
  801daf:	89 d7                	mov    %edx,%edi
  801db1:	39 d1                	cmp    %edx,%ecx
  801db3:	72 06                	jb     801dbb <__umoddi3+0x10b>
  801db5:	75 10                	jne    801dc7 <__umoddi3+0x117>
  801db7:	39 c3                	cmp    %eax,%ebx
  801db9:	73 0c                	jae    801dc7 <__umoddi3+0x117>
  801dbb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801dbf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801dc3:	89 d7                	mov    %edx,%edi
  801dc5:	89 c6                	mov    %eax,%esi
  801dc7:	89 ca                	mov    %ecx,%edx
  801dc9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801dce:	29 f3                	sub    %esi,%ebx
  801dd0:	19 fa                	sbb    %edi,%edx
  801dd2:	89 d0                	mov    %edx,%eax
  801dd4:	d3 e0                	shl    %cl,%eax
  801dd6:	89 e9                	mov    %ebp,%ecx
  801dd8:	d3 eb                	shr    %cl,%ebx
  801dda:	d3 ea                	shr    %cl,%edx
  801ddc:	09 d8                	or     %ebx,%eax
  801dde:	83 c4 1c             	add    $0x1c,%esp
  801de1:	5b                   	pop    %ebx
  801de2:	5e                   	pop    %esi
  801de3:	5f                   	pop    %edi
  801de4:	5d                   	pop    %ebp
  801de5:	c3                   	ret    
  801de6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ded:	8d 76 00             	lea    0x0(%esi),%esi
  801df0:	29 fe                	sub    %edi,%esi
  801df2:	19 c3                	sbb    %eax,%ebx
  801df4:	89 f2                	mov    %esi,%edx
  801df6:	89 d9                	mov    %ebx,%ecx
  801df8:	e9 1d ff ff ff       	jmp    801d1a <__umoddi3+0x6a>
