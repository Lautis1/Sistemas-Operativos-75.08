
obj/user/primespipe.debug:     formato del fichero elf32-i386


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
  80002c:	e8 08 02 00 00       	call   800239 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <primeproc>:

#include <inc/lib.h>

unsigned
primeproc(int fd)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 1c             	sub    $0x1c,%esp
  800040:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int i, id, p, pfd[2], wfd, r;

	// fetch a prime from our left neighbor
top:
	if ((r = readn(fd, &p, 4)) != 4)
  800043:	8d 75 e0             	lea    -0x20(%ebp),%esi
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);

	cprintf("%d\n", p);

	// fork a right neighbor to continue the chain
	if ((i=pipe(pfd)) < 0)
  800046:	8d 7d d8             	lea    -0x28(%ebp),%edi
  800049:	eb 5e                	jmp    8000a9 <primeproc+0x76>
		panic("primeproc could not read initial prime: %d, %e", r, r >= 0 ? 0 : r);
  80004b:	83 ec 0c             	sub    $0xc,%esp
  80004e:	85 c0                	test   %eax,%eax
  800050:	ba 00 00 00 00       	mov    $0x0,%edx
  800055:	0f 4e d0             	cmovle %eax,%edx
  800058:	52                   	push   %edx
  800059:	50                   	push   %eax
  80005a:	68 80 25 80 00       	push   $0x802580
  80005f:	6a 15                	push   $0x15
  800061:	68 af 25 80 00       	push   $0x8025af
  800066:	e8 3a 02 00 00       	call   8002a5 <_panic>
		panic("pipe: %e", i);
  80006b:	50                   	push   %eax
  80006c:	68 c5 25 80 00       	push   $0x8025c5
  800071:	6a 1b                	push   $0x1b
  800073:	68 af 25 80 00       	push   $0x8025af
  800078:	e8 28 02 00 00       	call   8002a5 <_panic>
	if ((id = fork()) < 0)
		panic("fork: %e", id);
  80007d:	50                   	push   %eax
  80007e:	68 ce 25 80 00       	push   $0x8025ce
  800083:	6a 1d                	push   $0x1d
  800085:	68 af 25 80 00       	push   $0x8025af
  80008a:	e8 16 02 00 00       	call   8002a5 <_panic>
	if (id == 0) {
		close(fd);
  80008f:	83 ec 0c             	sub    $0xc,%esp
  800092:	53                   	push   %ebx
  800093:	e8 28 15 00 00       	call   8015c0 <close>
		close(pfd[1]);
  800098:	83 c4 04             	add    $0x4,%esp
  80009b:	ff 75 dc             	pushl  -0x24(%ebp)
  80009e:	e8 1d 15 00 00       	call   8015c0 <close>
		fd = pfd[0];
  8000a3:	8b 5d d8             	mov    -0x28(%ebp),%ebx
		goto top;
  8000a6:	83 c4 10             	add    $0x10,%esp
	if ((r = readn(fd, &p, 4)) != 4)
  8000a9:	83 ec 04             	sub    $0x4,%esp
  8000ac:	6a 04                	push   $0x4
  8000ae:	56                   	push   %esi
  8000af:	53                   	push   %ebx
  8000b0:	e8 e0 16 00 00       	call   801795 <readn>
  8000b5:	83 c4 10             	add    $0x10,%esp
  8000b8:	83 f8 04             	cmp    $0x4,%eax
  8000bb:	75 8e                	jne    80004b <primeproc+0x18>
	cprintf("%d\n", p);
  8000bd:	83 ec 08             	sub    $0x8,%esp
  8000c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8000c3:	68 c1 25 80 00       	push   $0x8025c1
  8000c8:	e8 bf 02 00 00       	call   80038c <cprintf>
	if ((i=pipe(pfd)) < 0)
  8000cd:	89 3c 24             	mov    %edi,(%esp)
  8000d0:	e8 58 1d 00 00       	call   801e2d <pipe>
  8000d5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8000d8:	83 c4 10             	add    $0x10,%esp
  8000db:	85 c0                	test   %eax,%eax
  8000dd:	78 8c                	js     80006b <primeproc+0x38>
	if ((id = fork()) < 0)
  8000df:	e8 79 11 00 00       	call   80125d <fork>
  8000e4:	85 c0                	test   %eax,%eax
  8000e6:	78 95                	js     80007d <primeproc+0x4a>
	if (id == 0) {
  8000e8:	74 a5                	je     80008f <primeproc+0x5c>
	}

	close(pfd[0]);
  8000ea:	83 ec 0c             	sub    $0xc,%esp
  8000ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8000f0:	e8 cb 14 00 00       	call   8015c0 <close>
	wfd = pfd[1];
  8000f5:	8b 7d dc             	mov    -0x24(%ebp),%edi
  8000f8:	83 c4 10             	add    $0x10,%esp

	// filter out multiples of our prime
	for (;;) {
		if ((r=readn(fd, &i, 4)) != 4)
  8000fb:	8d 75 e4             	lea    -0x1c(%ebp),%esi
  8000fe:	83 ec 04             	sub    $0x4,%esp
  800101:	6a 04                	push   $0x4
  800103:	56                   	push   %esi
  800104:	53                   	push   %ebx
  800105:	e8 8b 16 00 00       	call   801795 <readn>
  80010a:	83 c4 10             	add    $0x10,%esp
  80010d:	83 f8 04             	cmp    $0x4,%eax
  800110:	75 42                	jne    800154 <primeproc+0x121>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
		if (i%p)
  800112:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800115:	99                   	cltd   
  800116:	f7 7d e0             	idivl  -0x20(%ebp)
  800119:	85 d2                	test   %edx,%edx
  80011b:	74 e1                	je     8000fe <primeproc+0xcb>
			if ((r=write(wfd, &i, 4)) != 4)
  80011d:	83 ec 04             	sub    $0x4,%esp
  800120:	6a 04                	push   $0x4
  800122:	56                   	push   %esi
  800123:	57                   	push   %edi
  800124:	e8 b7 16 00 00       	call   8017e0 <write>
  800129:	83 c4 10             	add    $0x10,%esp
  80012c:	83 f8 04             	cmp    $0x4,%eax
  80012f:	74 cd                	je     8000fe <primeproc+0xcb>
				panic("primeproc %d write: %d %e", p, r, r >= 0 ? 0 : r);
  800131:	83 ec 08             	sub    $0x8,%esp
  800134:	85 c0                	test   %eax,%eax
  800136:	ba 00 00 00 00       	mov    $0x0,%edx
  80013b:	0f 4e d0             	cmovle %eax,%edx
  80013e:	52                   	push   %edx
  80013f:	50                   	push   %eax
  800140:	ff 75 e0             	pushl  -0x20(%ebp)
  800143:	68 f3 25 80 00       	push   $0x8025f3
  800148:	6a 2e                	push   $0x2e
  80014a:	68 af 25 80 00       	push   $0x8025af
  80014f:	e8 51 01 00 00       	call   8002a5 <_panic>
			panic("primeproc %d readn %d %d %e", p, fd, r, r >= 0 ? 0 : r);
  800154:	83 ec 04             	sub    $0x4,%esp
  800157:	85 c0                	test   %eax,%eax
  800159:	ba 00 00 00 00       	mov    $0x0,%edx
  80015e:	0f 4e d0             	cmovle %eax,%edx
  800161:	52                   	push   %edx
  800162:	50                   	push   %eax
  800163:	53                   	push   %ebx
  800164:	ff 75 e0             	pushl  -0x20(%ebp)
  800167:	68 d7 25 80 00       	push   $0x8025d7
  80016c:	6a 2b                	push   $0x2b
  80016e:	68 af 25 80 00       	push   $0x8025af
  800173:	e8 2d 01 00 00       	call   8002a5 <_panic>

00800178 <umain>:
	}
}

void
umain(int argc, char **argv)
{
  800178:	f3 0f 1e fb          	endbr32 
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	53                   	push   %ebx
  800180:	83 ec 20             	sub    $0x20,%esp
	int i, id, p[2], r;

	binaryname = "primespipe";
  800183:	c7 05 00 30 80 00 0d 	movl   $0x80260d,0x803000
  80018a:	26 80 00 

	if ((i=pipe(p)) < 0)
  80018d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800190:	50                   	push   %eax
  800191:	e8 97 1c 00 00       	call   801e2d <pipe>
  800196:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800199:	83 c4 10             	add    $0x10,%esp
  80019c:	85 c0                	test   %eax,%eax
  80019e:	78 21                	js     8001c1 <umain+0x49>
		panic("pipe: %e", i);

	// fork the first prime process in the chain
	if ((id=fork()) < 0)
  8001a0:	e8 b8 10 00 00       	call   80125d <fork>
  8001a5:	85 c0                	test   %eax,%eax
  8001a7:	78 2a                	js     8001d3 <umain+0x5b>
		panic("fork: %e", id);

	if (id == 0) {
  8001a9:	75 3a                	jne    8001e5 <umain+0x6d>
		close(p[1]);
  8001ab:	83 ec 0c             	sub    $0xc,%esp
  8001ae:	ff 75 f0             	pushl  -0x10(%ebp)
  8001b1:	e8 0a 14 00 00       	call   8015c0 <close>
		primeproc(p[0]);
  8001b6:	83 c4 04             	add    $0x4,%esp
  8001b9:	ff 75 ec             	pushl  -0x14(%ebp)
  8001bc:	e8 72 fe ff ff       	call   800033 <primeproc>
		panic("pipe: %e", i);
  8001c1:	50                   	push   %eax
  8001c2:	68 c5 25 80 00       	push   $0x8025c5
  8001c7:	6a 3a                	push   $0x3a
  8001c9:	68 af 25 80 00       	push   $0x8025af
  8001ce:	e8 d2 00 00 00       	call   8002a5 <_panic>
		panic("fork: %e", id);
  8001d3:	50                   	push   %eax
  8001d4:	68 ce 25 80 00       	push   $0x8025ce
  8001d9:	6a 3e                	push   $0x3e
  8001db:	68 af 25 80 00       	push   $0x8025af
  8001e0:	e8 c0 00 00 00       	call   8002a5 <_panic>
	}

	close(p[0]);
  8001e5:	83 ec 0c             	sub    $0xc,%esp
  8001e8:	ff 75 ec             	pushl  -0x14(%ebp)
  8001eb:	e8 d0 13 00 00       	call   8015c0 <close>

	// feed all the integers through
	for (i=2;; i++)
  8001f0:	c7 45 f4 02 00 00 00 	movl   $0x2,-0xc(%ebp)
  8001f7:	83 c4 10             	add    $0x10,%esp
		if ((r=write(p[1], &i, 4)) != 4)
  8001fa:	8d 5d f4             	lea    -0xc(%ebp),%ebx
  8001fd:	83 ec 04             	sub    $0x4,%esp
  800200:	6a 04                	push   $0x4
  800202:	53                   	push   %ebx
  800203:	ff 75 f0             	pushl  -0x10(%ebp)
  800206:	e8 d5 15 00 00       	call   8017e0 <write>
  80020b:	83 c4 10             	add    $0x10,%esp
  80020e:	83 f8 04             	cmp    $0x4,%eax
  800211:	75 06                	jne    800219 <umain+0xa1>
	for (i=2;; i++)
  800213:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
		if ((r=write(p[1], &i, 4)) != 4)
  800217:	eb e4                	jmp    8001fd <umain+0x85>
			panic("generator write: %d, %e", r, r >= 0 ? 0 : r);
  800219:	83 ec 0c             	sub    $0xc,%esp
  80021c:	85 c0                	test   %eax,%eax
  80021e:	ba 00 00 00 00       	mov    $0x0,%edx
  800223:	0f 4e d0             	cmovle %eax,%edx
  800226:	52                   	push   %edx
  800227:	50                   	push   %eax
  800228:	68 18 26 80 00       	push   $0x802618
  80022d:	6a 4a                	push   $0x4a
  80022f:	68 af 25 80 00       	push   $0x8025af
  800234:	e8 6c 00 00 00       	call   8002a5 <_panic>

00800239 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800239:	f3 0f 1e fb          	endbr32 
  80023d:	55                   	push   %ebp
  80023e:	89 e5                	mov    %esp,%ebp
  800240:	56                   	push   %esi
  800241:	53                   	push   %ebx
  800242:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800245:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800248:	e8 de 0a 00 00       	call   800d2b <sys_getenvid>
	if (id >= 0)
  80024d:	85 c0                	test   %eax,%eax
  80024f:	78 12                	js     800263 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800251:	25 ff 03 00 00       	and    $0x3ff,%eax
  800256:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800259:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80025e:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800263:	85 db                	test   %ebx,%ebx
  800265:	7e 07                	jle    80026e <libmain+0x35>
		binaryname = argv[0];
  800267:	8b 06                	mov    (%esi),%eax
  800269:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80026e:	83 ec 08             	sub    $0x8,%esp
  800271:	56                   	push   %esi
  800272:	53                   	push   %ebx
  800273:	e8 00 ff ff ff       	call   800178 <umain>

	// exit gracefully
	exit();
  800278:	e8 0a 00 00 00       	call   800287 <exit>
}
  80027d:	83 c4 10             	add    $0x10,%esp
  800280:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800283:	5b                   	pop    %ebx
  800284:	5e                   	pop    %esi
  800285:	5d                   	pop    %ebp
  800286:	c3                   	ret    

00800287 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800287:	f3 0f 1e fb          	endbr32 
  80028b:	55                   	push   %ebp
  80028c:	89 e5                	mov    %esp,%ebp
  80028e:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800291:	e8 5b 13 00 00       	call   8015f1 <close_all>
	sys_env_destroy(0);
  800296:	83 ec 0c             	sub    $0xc,%esp
  800299:	6a 00                	push   $0x0
  80029b:	e8 65 0a 00 00       	call   800d05 <sys_env_destroy>
}
  8002a0:	83 c4 10             	add    $0x10,%esp
  8002a3:	c9                   	leave  
  8002a4:	c3                   	ret    

008002a5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002a5:	f3 0f 1e fb          	endbr32 
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	56                   	push   %esi
  8002ad:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002ae:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002b1:	8b 35 00 30 80 00    	mov    0x803000,%esi
  8002b7:	e8 6f 0a 00 00       	call   800d2b <sys_getenvid>
  8002bc:	83 ec 0c             	sub    $0xc,%esp
  8002bf:	ff 75 0c             	pushl  0xc(%ebp)
  8002c2:	ff 75 08             	pushl  0x8(%ebp)
  8002c5:	56                   	push   %esi
  8002c6:	50                   	push   %eax
  8002c7:	68 3c 26 80 00       	push   $0x80263c
  8002cc:	e8 bb 00 00 00       	call   80038c <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8002d1:	83 c4 18             	add    $0x18,%esp
  8002d4:	53                   	push   %ebx
  8002d5:	ff 75 10             	pushl  0x10(%ebp)
  8002d8:	e8 5a 00 00 00       	call   800337 <vcprintf>
	cprintf("\n");
  8002dd:	c7 04 24 c3 25 80 00 	movl   $0x8025c3,(%esp)
  8002e4:	e8 a3 00 00 00       	call   80038c <cprintf>
  8002e9:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8002ec:	cc                   	int3   
  8002ed:	eb fd                	jmp    8002ec <_panic+0x47>

008002ef <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8002ef:	f3 0f 1e fb          	endbr32 
  8002f3:	55                   	push   %ebp
  8002f4:	89 e5                	mov    %esp,%ebp
  8002f6:	53                   	push   %ebx
  8002f7:	83 ec 04             	sub    $0x4,%esp
  8002fa:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8002fd:	8b 13                	mov    (%ebx),%edx
  8002ff:	8d 42 01             	lea    0x1(%edx),%eax
  800302:	89 03                	mov    %eax,(%ebx)
  800304:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800307:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80030b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800310:	74 09                	je     80031b <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800312:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800316:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800319:	c9                   	leave  
  80031a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80031b:	83 ec 08             	sub    $0x8,%esp
  80031e:	68 ff 00 00 00       	push   $0xff
  800323:	8d 43 08             	lea    0x8(%ebx),%eax
  800326:	50                   	push   %eax
  800327:	e8 87 09 00 00       	call   800cb3 <sys_cputs>
		b->idx = 0;
  80032c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800332:	83 c4 10             	add    $0x10,%esp
  800335:	eb db                	jmp    800312 <putch+0x23>

00800337 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800337:	f3 0f 1e fb          	endbr32 
  80033b:	55                   	push   %ebp
  80033c:	89 e5                	mov    %esp,%ebp
  80033e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800344:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80034b:	00 00 00 
	b.cnt = 0;
  80034e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800355:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800358:	ff 75 0c             	pushl  0xc(%ebp)
  80035b:	ff 75 08             	pushl  0x8(%ebp)
  80035e:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800364:	50                   	push   %eax
  800365:	68 ef 02 80 00       	push   $0x8002ef
  80036a:	e8 80 01 00 00       	call   8004ef <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80036f:	83 c4 08             	add    $0x8,%esp
  800372:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800378:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80037e:	50                   	push   %eax
  80037f:	e8 2f 09 00 00       	call   800cb3 <sys_cputs>

	return b.cnt;
}
  800384:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80038a:	c9                   	leave  
  80038b:	c3                   	ret    

0080038c <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80038c:	f3 0f 1e fb          	endbr32 
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800396:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800399:	50                   	push   %eax
  80039a:	ff 75 08             	pushl  0x8(%ebp)
  80039d:	e8 95 ff ff ff       	call   800337 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003a2:	c9                   	leave  
  8003a3:	c3                   	ret    

008003a4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003a4:	55                   	push   %ebp
  8003a5:	89 e5                	mov    %esp,%ebp
  8003a7:	57                   	push   %edi
  8003a8:	56                   	push   %esi
  8003a9:	53                   	push   %ebx
  8003aa:	83 ec 1c             	sub    $0x1c,%esp
  8003ad:	89 c7                	mov    %eax,%edi
  8003af:	89 d6                	mov    %edx,%esi
  8003b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8003b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b7:	89 d1                	mov    %edx,%ecx
  8003b9:	89 c2                	mov    %eax,%edx
  8003bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8003be:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8003c1:	8b 45 10             	mov    0x10(%ebp),%eax
  8003c4:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8003c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8003ca:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  8003d1:	39 c2                	cmp    %eax,%edx
  8003d3:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8003d6:	72 3e                	jb     800416 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8003d8:	83 ec 0c             	sub    $0xc,%esp
  8003db:	ff 75 18             	pushl  0x18(%ebp)
  8003de:	83 eb 01             	sub    $0x1,%ebx
  8003e1:	53                   	push   %ebx
  8003e2:	50                   	push   %eax
  8003e3:	83 ec 08             	sub    $0x8,%esp
  8003e6:	ff 75 e4             	pushl  -0x1c(%ebp)
  8003e9:	ff 75 e0             	pushl  -0x20(%ebp)
  8003ec:	ff 75 dc             	pushl  -0x24(%ebp)
  8003ef:	ff 75 d8             	pushl  -0x28(%ebp)
  8003f2:	e8 29 1f 00 00       	call   802320 <__udivdi3>
  8003f7:	83 c4 18             	add    $0x18,%esp
  8003fa:	52                   	push   %edx
  8003fb:	50                   	push   %eax
  8003fc:	89 f2                	mov    %esi,%edx
  8003fe:	89 f8                	mov    %edi,%eax
  800400:	e8 9f ff ff ff       	call   8003a4 <printnum>
  800405:	83 c4 20             	add    $0x20,%esp
  800408:	eb 13                	jmp    80041d <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80040a:	83 ec 08             	sub    $0x8,%esp
  80040d:	56                   	push   %esi
  80040e:	ff 75 18             	pushl  0x18(%ebp)
  800411:	ff d7                	call   *%edi
  800413:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800416:	83 eb 01             	sub    $0x1,%ebx
  800419:	85 db                	test   %ebx,%ebx
  80041b:	7f ed                	jg     80040a <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80041d:	83 ec 08             	sub    $0x8,%esp
  800420:	56                   	push   %esi
  800421:	83 ec 04             	sub    $0x4,%esp
  800424:	ff 75 e4             	pushl  -0x1c(%ebp)
  800427:	ff 75 e0             	pushl  -0x20(%ebp)
  80042a:	ff 75 dc             	pushl  -0x24(%ebp)
  80042d:	ff 75 d8             	pushl  -0x28(%ebp)
  800430:	e8 fb 1f 00 00       	call   802430 <__umoddi3>
  800435:	83 c4 14             	add    $0x14,%esp
  800438:	0f be 80 5f 26 80 00 	movsbl 0x80265f(%eax),%eax
  80043f:	50                   	push   %eax
  800440:	ff d7                	call   *%edi
}
  800442:	83 c4 10             	add    $0x10,%esp
  800445:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800448:	5b                   	pop    %ebx
  800449:	5e                   	pop    %esi
  80044a:	5f                   	pop    %edi
  80044b:	5d                   	pop    %ebp
  80044c:	c3                   	ret    

0080044d <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80044d:	83 fa 01             	cmp    $0x1,%edx
  800450:	7f 13                	jg     800465 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800452:	85 d2                	test   %edx,%edx
  800454:	74 1c                	je     800472 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800456:	8b 10                	mov    (%eax),%edx
  800458:	8d 4a 04             	lea    0x4(%edx),%ecx
  80045b:	89 08                	mov    %ecx,(%eax)
  80045d:	8b 02                	mov    (%edx),%eax
  80045f:	ba 00 00 00 00       	mov    $0x0,%edx
  800464:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800465:	8b 10                	mov    (%eax),%edx
  800467:	8d 4a 08             	lea    0x8(%edx),%ecx
  80046a:	89 08                	mov    %ecx,(%eax)
  80046c:	8b 02                	mov    (%edx),%eax
  80046e:	8b 52 04             	mov    0x4(%edx),%edx
  800471:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800472:	8b 10                	mov    (%eax),%edx
  800474:	8d 4a 04             	lea    0x4(%edx),%ecx
  800477:	89 08                	mov    %ecx,(%eax)
  800479:	8b 02                	mov    (%edx),%eax
  80047b:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800480:	c3                   	ret    

00800481 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800481:	83 fa 01             	cmp    $0x1,%edx
  800484:	7f 0f                	jg     800495 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800486:	85 d2                	test   %edx,%edx
  800488:	74 18                	je     8004a2 <getint+0x21>
		return va_arg(*ap, long);
  80048a:	8b 10                	mov    (%eax),%edx
  80048c:	8d 4a 04             	lea    0x4(%edx),%ecx
  80048f:	89 08                	mov    %ecx,(%eax)
  800491:	8b 02                	mov    (%edx),%eax
  800493:	99                   	cltd   
  800494:	c3                   	ret    
		return va_arg(*ap, long long);
  800495:	8b 10                	mov    (%eax),%edx
  800497:	8d 4a 08             	lea    0x8(%edx),%ecx
  80049a:	89 08                	mov    %ecx,(%eax)
  80049c:	8b 02                	mov    (%edx),%eax
  80049e:	8b 52 04             	mov    0x4(%edx),%edx
  8004a1:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8004a2:	8b 10                	mov    (%eax),%edx
  8004a4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004a7:	89 08                	mov    %ecx,(%eax)
  8004a9:	8b 02                	mov    (%edx),%eax
  8004ab:	99                   	cltd   
}
  8004ac:	c3                   	ret    

008004ad <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004ad:	f3 0f 1e fb          	endbr32 
  8004b1:	55                   	push   %ebp
  8004b2:	89 e5                	mov    %esp,%ebp
  8004b4:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004b7:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004bb:	8b 10                	mov    (%eax),%edx
  8004bd:	3b 50 04             	cmp    0x4(%eax),%edx
  8004c0:	73 0a                	jae    8004cc <sprintputch+0x1f>
		*b->buf++ = ch;
  8004c2:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004c5:	89 08                	mov    %ecx,(%eax)
  8004c7:	8b 45 08             	mov    0x8(%ebp),%eax
  8004ca:	88 02                	mov    %al,(%edx)
}
  8004cc:	5d                   	pop    %ebp
  8004cd:	c3                   	ret    

008004ce <printfmt>:
{
  8004ce:	f3 0f 1e fb          	endbr32 
  8004d2:	55                   	push   %ebp
  8004d3:	89 e5                	mov    %esp,%ebp
  8004d5:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8004d8:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004db:	50                   	push   %eax
  8004dc:	ff 75 10             	pushl  0x10(%ebp)
  8004df:	ff 75 0c             	pushl  0xc(%ebp)
  8004e2:	ff 75 08             	pushl  0x8(%ebp)
  8004e5:	e8 05 00 00 00       	call   8004ef <vprintfmt>
}
  8004ea:	83 c4 10             	add    $0x10,%esp
  8004ed:	c9                   	leave  
  8004ee:	c3                   	ret    

008004ef <vprintfmt>:
{
  8004ef:	f3 0f 1e fb          	endbr32 
  8004f3:	55                   	push   %ebp
  8004f4:	89 e5                	mov    %esp,%ebp
  8004f6:	57                   	push   %edi
  8004f7:	56                   	push   %esi
  8004f8:	53                   	push   %ebx
  8004f9:	83 ec 2c             	sub    $0x2c,%esp
  8004fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004ff:	8b 75 0c             	mov    0xc(%ebp),%esi
  800502:	8b 7d 10             	mov    0x10(%ebp),%edi
  800505:	e9 86 02 00 00       	jmp    800790 <vprintfmt+0x2a1>
		padc = ' ';
  80050a:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80050e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800515:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80051c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800523:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800528:	8d 47 01             	lea    0x1(%edi),%eax
  80052b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80052e:	0f b6 17             	movzbl (%edi),%edx
  800531:	8d 42 dd             	lea    -0x23(%edx),%eax
  800534:	3c 55                	cmp    $0x55,%al
  800536:	0f 87 df 02 00 00    	ja     80081b <vprintfmt+0x32c>
  80053c:	0f b6 c0             	movzbl %al,%eax
  80053f:	3e ff 24 85 a0 27 80 	notrack jmp *0x8027a0(,%eax,4)
  800546:	00 
  800547:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80054a:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80054e:	eb d8                	jmp    800528 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800550:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800553:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800557:	eb cf                	jmp    800528 <vprintfmt+0x39>
  800559:	0f b6 d2             	movzbl %dl,%edx
  80055c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80055f:	b8 00 00 00 00       	mov    $0x0,%eax
  800564:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800567:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80056a:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80056e:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800571:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800574:	83 f9 09             	cmp    $0x9,%ecx
  800577:	77 52                	ja     8005cb <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  800579:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80057c:	eb e9                	jmp    800567 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80057e:	8b 45 14             	mov    0x14(%ebp),%eax
  800581:	8d 50 04             	lea    0x4(%eax),%edx
  800584:	89 55 14             	mov    %edx,0x14(%ebp)
  800587:	8b 00                	mov    (%eax),%eax
  800589:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80058c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80058f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800593:	79 93                	jns    800528 <vprintfmt+0x39>
				width = precision, precision = -1;
  800595:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800598:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80059b:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005a2:	eb 84                	jmp    800528 <vprintfmt+0x39>
  8005a4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005a7:	85 c0                	test   %eax,%eax
  8005a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8005ae:	0f 49 d0             	cmovns %eax,%edx
  8005b1:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005b4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005b7:	e9 6c ff ff ff       	jmp    800528 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8005bf:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8005c6:	e9 5d ff ff ff       	jmp    800528 <vprintfmt+0x39>
  8005cb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8005ce:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8005d1:	eb bc                	jmp    80058f <vprintfmt+0xa0>
			lflag++;
  8005d3:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005d9:	e9 4a ff ff ff       	jmp    800528 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8005de:	8b 45 14             	mov    0x14(%ebp),%eax
  8005e1:	8d 50 04             	lea    0x4(%eax),%edx
  8005e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8005e7:	83 ec 08             	sub    $0x8,%esp
  8005ea:	56                   	push   %esi
  8005eb:	ff 30                	pushl  (%eax)
  8005ed:	ff d3                	call   *%ebx
			break;
  8005ef:	83 c4 10             	add    $0x10,%esp
  8005f2:	e9 96 01 00 00       	jmp    80078d <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8005f7:	8b 45 14             	mov    0x14(%ebp),%eax
  8005fa:	8d 50 04             	lea    0x4(%eax),%edx
  8005fd:	89 55 14             	mov    %edx,0x14(%ebp)
  800600:	8b 00                	mov    (%eax),%eax
  800602:	99                   	cltd   
  800603:	31 d0                	xor    %edx,%eax
  800605:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800607:	83 f8 0f             	cmp    $0xf,%eax
  80060a:	7f 20                	jg     80062c <vprintfmt+0x13d>
  80060c:	8b 14 85 00 29 80 00 	mov    0x802900(,%eax,4),%edx
  800613:	85 d2                	test   %edx,%edx
  800615:	74 15                	je     80062c <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  800617:	52                   	push   %edx
  800618:	68 15 2c 80 00       	push   $0x802c15
  80061d:	56                   	push   %esi
  80061e:	53                   	push   %ebx
  80061f:	e8 aa fe ff ff       	call   8004ce <printfmt>
  800624:	83 c4 10             	add    $0x10,%esp
  800627:	e9 61 01 00 00       	jmp    80078d <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  80062c:	50                   	push   %eax
  80062d:	68 77 26 80 00       	push   $0x802677
  800632:	56                   	push   %esi
  800633:	53                   	push   %ebx
  800634:	e8 95 fe ff ff       	call   8004ce <printfmt>
  800639:	83 c4 10             	add    $0x10,%esp
  80063c:	e9 4c 01 00 00       	jmp    80078d <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  800641:	8b 45 14             	mov    0x14(%ebp),%eax
  800644:	8d 50 04             	lea    0x4(%eax),%edx
  800647:	89 55 14             	mov    %edx,0x14(%ebp)
  80064a:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  80064c:	85 c9                	test   %ecx,%ecx
  80064e:	b8 70 26 80 00       	mov    $0x802670,%eax
  800653:	0f 45 c1             	cmovne %ecx,%eax
  800656:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800659:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80065d:	7e 06                	jle    800665 <vprintfmt+0x176>
  80065f:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800663:	75 0d                	jne    800672 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  800665:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800668:	89 c7                	mov    %eax,%edi
  80066a:	03 45 e0             	add    -0x20(%ebp),%eax
  80066d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800670:	eb 57                	jmp    8006c9 <vprintfmt+0x1da>
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	ff 75 d8             	pushl  -0x28(%ebp)
  800678:	ff 75 cc             	pushl  -0x34(%ebp)
  80067b:	e8 4f 02 00 00       	call   8008cf <strnlen>
  800680:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800683:	29 c2                	sub    %eax,%edx
  800685:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800688:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80068b:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80068f:	89 5d 08             	mov    %ebx,0x8(%ebp)
  800692:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800694:	85 db                	test   %ebx,%ebx
  800696:	7e 10                	jle    8006a8 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800698:	83 ec 08             	sub    $0x8,%esp
  80069b:	56                   	push   %esi
  80069c:	57                   	push   %edi
  80069d:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006a0:	83 eb 01             	sub    $0x1,%ebx
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	eb ec                	jmp    800694 <vprintfmt+0x1a5>
  8006a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8006ab:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006ae:	85 d2                	test   %edx,%edx
  8006b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8006b5:	0f 49 c2             	cmovns %edx,%eax
  8006b8:	29 c2                	sub    %eax,%edx
  8006ba:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006bd:	eb a6                	jmp    800665 <vprintfmt+0x176>
					putch(ch, putdat);
  8006bf:	83 ec 08             	sub    $0x8,%esp
  8006c2:	56                   	push   %esi
  8006c3:	52                   	push   %edx
  8006c4:	ff d3                	call   *%ebx
  8006c6:	83 c4 10             	add    $0x10,%esp
  8006c9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006cc:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8006ce:	83 c7 01             	add    $0x1,%edi
  8006d1:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006d5:	0f be d0             	movsbl %al,%edx
  8006d8:	85 d2                	test   %edx,%edx
  8006da:	74 42                	je     80071e <vprintfmt+0x22f>
  8006dc:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8006e0:	78 06                	js     8006e8 <vprintfmt+0x1f9>
  8006e2:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8006e6:	78 1e                	js     800706 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  8006e8:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8006ec:	74 d1                	je     8006bf <vprintfmt+0x1d0>
  8006ee:	0f be c0             	movsbl %al,%eax
  8006f1:	83 e8 20             	sub    $0x20,%eax
  8006f4:	83 f8 5e             	cmp    $0x5e,%eax
  8006f7:	76 c6                	jbe    8006bf <vprintfmt+0x1d0>
					putch('?', putdat);
  8006f9:	83 ec 08             	sub    $0x8,%esp
  8006fc:	56                   	push   %esi
  8006fd:	6a 3f                	push   $0x3f
  8006ff:	ff d3                	call   *%ebx
  800701:	83 c4 10             	add    $0x10,%esp
  800704:	eb c3                	jmp    8006c9 <vprintfmt+0x1da>
  800706:	89 cf                	mov    %ecx,%edi
  800708:	eb 0e                	jmp    800718 <vprintfmt+0x229>
				putch(' ', putdat);
  80070a:	83 ec 08             	sub    $0x8,%esp
  80070d:	56                   	push   %esi
  80070e:	6a 20                	push   $0x20
  800710:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800712:	83 ef 01             	sub    $0x1,%edi
  800715:	83 c4 10             	add    $0x10,%esp
  800718:	85 ff                	test   %edi,%edi
  80071a:	7f ee                	jg     80070a <vprintfmt+0x21b>
  80071c:	eb 6f                	jmp    80078d <vprintfmt+0x29e>
  80071e:	89 cf                	mov    %ecx,%edi
  800720:	eb f6                	jmp    800718 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  800722:	89 ca                	mov    %ecx,%edx
  800724:	8d 45 14             	lea    0x14(%ebp),%eax
  800727:	e8 55 fd ff ff       	call   800481 <getint>
  80072c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80072f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800732:	85 d2                	test   %edx,%edx
  800734:	78 0b                	js     800741 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  800736:	89 d1                	mov    %edx,%ecx
  800738:	89 c2                	mov    %eax,%edx
			base = 10;
  80073a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80073f:	eb 32                	jmp    800773 <vprintfmt+0x284>
				putch('-', putdat);
  800741:	83 ec 08             	sub    $0x8,%esp
  800744:	56                   	push   %esi
  800745:	6a 2d                	push   $0x2d
  800747:	ff d3                	call   *%ebx
				num = -(long long) num;
  800749:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80074c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80074f:	f7 da                	neg    %edx
  800751:	83 d1 00             	adc    $0x0,%ecx
  800754:	f7 d9                	neg    %ecx
  800756:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800759:	b8 0a 00 00 00       	mov    $0xa,%eax
  80075e:	eb 13                	jmp    800773 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800760:	89 ca                	mov    %ecx,%edx
  800762:	8d 45 14             	lea    0x14(%ebp),%eax
  800765:	e8 e3 fc ff ff       	call   80044d <getuint>
  80076a:	89 d1                	mov    %edx,%ecx
  80076c:	89 c2                	mov    %eax,%edx
			base = 10;
  80076e:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  800773:	83 ec 0c             	sub    $0xc,%esp
  800776:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80077a:	57                   	push   %edi
  80077b:	ff 75 e0             	pushl  -0x20(%ebp)
  80077e:	50                   	push   %eax
  80077f:	51                   	push   %ecx
  800780:	52                   	push   %edx
  800781:	89 f2                	mov    %esi,%edx
  800783:	89 d8                	mov    %ebx,%eax
  800785:	e8 1a fc ff ff       	call   8003a4 <printnum>
			break;
  80078a:	83 c4 20             	add    $0x20,%esp
{
  80078d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800790:	83 c7 01             	add    $0x1,%edi
  800793:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800797:	83 f8 25             	cmp    $0x25,%eax
  80079a:	0f 84 6a fd ff ff    	je     80050a <vprintfmt+0x1b>
			if (ch == '\0')
  8007a0:	85 c0                	test   %eax,%eax
  8007a2:	0f 84 93 00 00 00    	je     80083b <vprintfmt+0x34c>
			putch(ch, putdat);
  8007a8:	83 ec 08             	sub    $0x8,%esp
  8007ab:	56                   	push   %esi
  8007ac:	50                   	push   %eax
  8007ad:	ff d3                	call   *%ebx
  8007af:	83 c4 10             	add    $0x10,%esp
  8007b2:	eb dc                	jmp    800790 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  8007b4:	89 ca                	mov    %ecx,%edx
  8007b6:	8d 45 14             	lea    0x14(%ebp),%eax
  8007b9:	e8 8f fc ff ff       	call   80044d <getuint>
  8007be:	89 d1                	mov    %edx,%ecx
  8007c0:	89 c2                	mov    %eax,%edx
			base = 8;
  8007c2:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8007c7:	eb aa                	jmp    800773 <vprintfmt+0x284>
			putch('0', putdat);
  8007c9:	83 ec 08             	sub    $0x8,%esp
  8007cc:	56                   	push   %esi
  8007cd:	6a 30                	push   $0x30
  8007cf:	ff d3                	call   *%ebx
			putch('x', putdat);
  8007d1:	83 c4 08             	add    $0x8,%esp
  8007d4:	56                   	push   %esi
  8007d5:	6a 78                	push   $0x78
  8007d7:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  8007d9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007dc:	8d 50 04             	lea    0x4(%eax),%edx
  8007df:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8007e2:	8b 10                	mov    (%eax),%edx
  8007e4:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8007e9:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8007ec:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8007f1:	eb 80                	jmp    800773 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8007f3:	89 ca                	mov    %ecx,%edx
  8007f5:	8d 45 14             	lea    0x14(%ebp),%eax
  8007f8:	e8 50 fc ff ff       	call   80044d <getuint>
  8007fd:	89 d1                	mov    %edx,%ecx
  8007ff:	89 c2                	mov    %eax,%edx
			base = 16;
  800801:	b8 10 00 00 00       	mov    $0x10,%eax
  800806:	e9 68 ff ff ff       	jmp    800773 <vprintfmt+0x284>
			putch(ch, putdat);
  80080b:	83 ec 08             	sub    $0x8,%esp
  80080e:	56                   	push   %esi
  80080f:	6a 25                	push   $0x25
  800811:	ff d3                	call   *%ebx
			break;
  800813:	83 c4 10             	add    $0x10,%esp
  800816:	e9 72 ff ff ff       	jmp    80078d <vprintfmt+0x29e>
			putch('%', putdat);
  80081b:	83 ec 08             	sub    $0x8,%esp
  80081e:	56                   	push   %esi
  80081f:	6a 25                	push   $0x25
  800821:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800823:	83 c4 10             	add    $0x10,%esp
  800826:	89 f8                	mov    %edi,%eax
  800828:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80082c:	74 05                	je     800833 <vprintfmt+0x344>
  80082e:	83 e8 01             	sub    $0x1,%eax
  800831:	eb f5                	jmp    800828 <vprintfmt+0x339>
  800833:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800836:	e9 52 ff ff ff       	jmp    80078d <vprintfmt+0x29e>
}
  80083b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80083e:	5b                   	pop    %ebx
  80083f:	5e                   	pop    %esi
  800840:	5f                   	pop    %edi
  800841:	5d                   	pop    %ebp
  800842:	c3                   	ret    

00800843 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800843:	f3 0f 1e fb          	endbr32 
  800847:	55                   	push   %ebp
  800848:	89 e5                	mov    %esp,%ebp
  80084a:	83 ec 18             	sub    $0x18,%esp
  80084d:	8b 45 08             	mov    0x8(%ebp),%eax
  800850:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800853:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800856:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80085a:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80085d:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800864:	85 c0                	test   %eax,%eax
  800866:	74 26                	je     80088e <vsnprintf+0x4b>
  800868:	85 d2                	test   %edx,%edx
  80086a:	7e 22                	jle    80088e <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80086c:	ff 75 14             	pushl  0x14(%ebp)
  80086f:	ff 75 10             	pushl  0x10(%ebp)
  800872:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800875:	50                   	push   %eax
  800876:	68 ad 04 80 00       	push   $0x8004ad
  80087b:	e8 6f fc ff ff       	call   8004ef <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800880:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800883:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800886:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800889:	83 c4 10             	add    $0x10,%esp
}
  80088c:	c9                   	leave  
  80088d:	c3                   	ret    
		return -E_INVAL;
  80088e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800893:	eb f7                	jmp    80088c <vsnprintf+0x49>

00800895 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800895:	f3 0f 1e fb          	endbr32 
  800899:	55                   	push   %ebp
  80089a:	89 e5                	mov    %esp,%ebp
  80089c:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80089f:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008a2:	50                   	push   %eax
  8008a3:	ff 75 10             	pushl  0x10(%ebp)
  8008a6:	ff 75 0c             	pushl  0xc(%ebp)
  8008a9:	ff 75 08             	pushl  0x8(%ebp)
  8008ac:	e8 92 ff ff ff       	call   800843 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008b1:	c9                   	leave  
  8008b2:	c3                   	ret    

008008b3 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8008b3:	f3 0f 1e fb          	endbr32 
  8008b7:	55                   	push   %ebp
  8008b8:	89 e5                	mov    %esp,%ebp
  8008ba:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8008bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8008c2:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8008c6:	74 05                	je     8008cd <strlen+0x1a>
		n++;
  8008c8:	83 c0 01             	add    $0x1,%eax
  8008cb:	eb f5                	jmp    8008c2 <strlen+0xf>
	return n;
}
  8008cd:	5d                   	pop    %ebp
  8008ce:	c3                   	ret    

008008cf <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8008cf:	f3 0f 1e fb          	endbr32 
  8008d3:	55                   	push   %ebp
  8008d4:	89 e5                	mov    %esp,%ebp
  8008d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008d9:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8008dc:	b8 00 00 00 00       	mov    $0x0,%eax
  8008e1:	39 d0                	cmp    %edx,%eax
  8008e3:	74 0d                	je     8008f2 <strnlen+0x23>
  8008e5:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8008e9:	74 05                	je     8008f0 <strnlen+0x21>
		n++;
  8008eb:	83 c0 01             	add    $0x1,%eax
  8008ee:	eb f1                	jmp    8008e1 <strnlen+0x12>
  8008f0:	89 c2                	mov    %eax,%edx
	return n;
}
  8008f2:	89 d0                	mov    %edx,%eax
  8008f4:	5d                   	pop    %ebp
  8008f5:	c3                   	ret    

008008f6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8008f6:	f3 0f 1e fb          	endbr32 
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	53                   	push   %ebx
  8008fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800901:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800904:	b8 00 00 00 00       	mov    $0x0,%eax
  800909:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80090d:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800910:	83 c0 01             	add    $0x1,%eax
  800913:	84 d2                	test   %dl,%dl
  800915:	75 f2                	jne    800909 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800917:	89 c8                	mov    %ecx,%eax
  800919:	5b                   	pop    %ebx
  80091a:	5d                   	pop    %ebp
  80091b:	c3                   	ret    

0080091c <strcat>:

char *
strcat(char *dst, const char *src)
{
  80091c:	f3 0f 1e fb          	endbr32 
  800920:	55                   	push   %ebp
  800921:	89 e5                	mov    %esp,%ebp
  800923:	53                   	push   %ebx
  800924:	83 ec 10             	sub    $0x10,%esp
  800927:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80092a:	53                   	push   %ebx
  80092b:	e8 83 ff ff ff       	call   8008b3 <strlen>
  800930:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800933:	ff 75 0c             	pushl  0xc(%ebp)
  800936:	01 d8                	add    %ebx,%eax
  800938:	50                   	push   %eax
  800939:	e8 b8 ff ff ff       	call   8008f6 <strcpy>
	return dst;
}
  80093e:	89 d8                	mov    %ebx,%eax
  800940:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800943:	c9                   	leave  
  800944:	c3                   	ret    

00800945 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800945:	f3 0f 1e fb          	endbr32 
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	56                   	push   %esi
  80094d:	53                   	push   %ebx
  80094e:	8b 75 08             	mov    0x8(%ebp),%esi
  800951:	8b 55 0c             	mov    0xc(%ebp),%edx
  800954:	89 f3                	mov    %esi,%ebx
  800956:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800959:	89 f0                	mov    %esi,%eax
  80095b:	39 d8                	cmp    %ebx,%eax
  80095d:	74 11                	je     800970 <strncpy+0x2b>
		*dst++ = *src;
  80095f:	83 c0 01             	add    $0x1,%eax
  800962:	0f b6 0a             	movzbl (%edx),%ecx
  800965:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800968:	80 f9 01             	cmp    $0x1,%cl
  80096b:	83 da ff             	sbb    $0xffffffff,%edx
  80096e:	eb eb                	jmp    80095b <strncpy+0x16>
	}
	return ret;
}
  800970:	89 f0                	mov    %esi,%eax
  800972:	5b                   	pop    %ebx
  800973:	5e                   	pop    %esi
  800974:	5d                   	pop    %ebp
  800975:	c3                   	ret    

00800976 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800976:	f3 0f 1e fb          	endbr32 
  80097a:	55                   	push   %ebp
  80097b:	89 e5                	mov    %esp,%ebp
  80097d:	56                   	push   %esi
  80097e:	53                   	push   %ebx
  80097f:	8b 75 08             	mov    0x8(%ebp),%esi
  800982:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800985:	8b 55 10             	mov    0x10(%ebp),%edx
  800988:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80098a:	85 d2                	test   %edx,%edx
  80098c:	74 21                	je     8009af <strlcpy+0x39>
  80098e:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800992:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800994:	39 c2                	cmp    %eax,%edx
  800996:	74 14                	je     8009ac <strlcpy+0x36>
  800998:	0f b6 19             	movzbl (%ecx),%ebx
  80099b:	84 db                	test   %bl,%bl
  80099d:	74 0b                	je     8009aa <strlcpy+0x34>
			*dst++ = *src++;
  80099f:	83 c1 01             	add    $0x1,%ecx
  8009a2:	83 c2 01             	add    $0x1,%edx
  8009a5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009a8:	eb ea                	jmp    800994 <strlcpy+0x1e>
  8009aa:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8009ac:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8009af:	29 f0                	sub    %esi,%eax
}
  8009b1:	5b                   	pop    %ebx
  8009b2:	5e                   	pop    %esi
  8009b3:	5d                   	pop    %ebp
  8009b4:	c3                   	ret    

008009b5 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8009b5:	f3 0f 1e fb          	endbr32 
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8009bf:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8009c2:	0f b6 01             	movzbl (%ecx),%eax
  8009c5:	84 c0                	test   %al,%al
  8009c7:	74 0c                	je     8009d5 <strcmp+0x20>
  8009c9:	3a 02                	cmp    (%edx),%al
  8009cb:	75 08                	jne    8009d5 <strcmp+0x20>
		p++, q++;
  8009cd:	83 c1 01             	add    $0x1,%ecx
  8009d0:	83 c2 01             	add    $0x1,%edx
  8009d3:	eb ed                	jmp    8009c2 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8009d5:	0f b6 c0             	movzbl %al,%eax
  8009d8:	0f b6 12             	movzbl (%edx),%edx
  8009db:	29 d0                	sub    %edx,%eax
}
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8009df:	f3 0f 1e fb          	endbr32 
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	53                   	push   %ebx
  8009e7:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ea:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009ed:	89 c3                	mov    %eax,%ebx
  8009ef:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8009f2:	eb 06                	jmp    8009fa <strncmp+0x1b>
		n--, p++, q++;
  8009f4:	83 c0 01             	add    $0x1,%eax
  8009f7:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8009fa:	39 d8                	cmp    %ebx,%eax
  8009fc:	74 16                	je     800a14 <strncmp+0x35>
  8009fe:	0f b6 08             	movzbl (%eax),%ecx
  800a01:	84 c9                	test   %cl,%cl
  800a03:	74 04                	je     800a09 <strncmp+0x2a>
  800a05:	3a 0a                	cmp    (%edx),%cl
  800a07:	74 eb                	je     8009f4 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a09:	0f b6 00             	movzbl (%eax),%eax
  800a0c:	0f b6 12             	movzbl (%edx),%edx
  800a0f:	29 d0                	sub    %edx,%eax
}
  800a11:	5b                   	pop    %ebx
  800a12:	5d                   	pop    %ebp
  800a13:	c3                   	ret    
		return 0;
  800a14:	b8 00 00 00 00       	mov    $0x0,%eax
  800a19:	eb f6                	jmp    800a11 <strncmp+0x32>

00800a1b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800a1b:	f3 0f 1e fb          	endbr32 
  800a1f:	55                   	push   %ebp
  800a20:	89 e5                	mov    %esp,%ebp
  800a22:	8b 45 08             	mov    0x8(%ebp),%eax
  800a25:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a29:	0f b6 10             	movzbl (%eax),%edx
  800a2c:	84 d2                	test   %dl,%dl
  800a2e:	74 09                	je     800a39 <strchr+0x1e>
		if (*s == c)
  800a30:	38 ca                	cmp    %cl,%dl
  800a32:	74 0a                	je     800a3e <strchr+0x23>
	for (; *s; s++)
  800a34:	83 c0 01             	add    $0x1,%eax
  800a37:	eb f0                	jmp    800a29 <strchr+0xe>
			return (char *) s;
	return 0;
  800a39:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a3e:	5d                   	pop    %ebp
  800a3f:	c3                   	ret    

00800a40 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800a40:	f3 0f 1e fb          	endbr32 
  800a44:	55                   	push   %ebp
  800a45:	89 e5                	mov    %esp,%ebp
  800a47:	8b 45 08             	mov    0x8(%ebp),%eax
  800a4a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800a4e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800a51:	38 ca                	cmp    %cl,%dl
  800a53:	74 09                	je     800a5e <strfind+0x1e>
  800a55:	84 d2                	test   %dl,%dl
  800a57:	74 05                	je     800a5e <strfind+0x1e>
	for (; *s; s++)
  800a59:	83 c0 01             	add    $0x1,%eax
  800a5c:	eb f0                	jmp    800a4e <strfind+0xe>
			break;
	return (char *) s;
}
  800a5e:	5d                   	pop    %ebp
  800a5f:	c3                   	ret    

00800a60 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800a60:	f3 0f 1e fb          	endbr32 
  800a64:	55                   	push   %ebp
  800a65:	89 e5                	mov    %esp,%ebp
  800a67:	57                   	push   %edi
  800a68:	56                   	push   %esi
  800a69:	53                   	push   %ebx
  800a6a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a6d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800a70:	85 c9                	test   %ecx,%ecx
  800a72:	74 33                	je     800aa7 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800a74:	89 d0                	mov    %edx,%eax
  800a76:	09 c8                	or     %ecx,%eax
  800a78:	a8 03                	test   $0x3,%al
  800a7a:	75 23                	jne    800a9f <memset+0x3f>
		c &= 0xFF;
  800a7c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a80:	89 d8                	mov    %ebx,%eax
  800a82:	c1 e0 08             	shl    $0x8,%eax
  800a85:	89 df                	mov    %ebx,%edi
  800a87:	c1 e7 18             	shl    $0x18,%edi
  800a8a:	89 de                	mov    %ebx,%esi
  800a8c:	c1 e6 10             	shl    $0x10,%esi
  800a8f:	09 f7                	or     %esi,%edi
  800a91:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800a93:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800a96:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800a98:	89 d7                	mov    %edx,%edi
  800a9a:	fc                   	cld    
  800a9b:	f3 ab                	rep stos %eax,%es:(%edi)
  800a9d:	eb 08                	jmp    800aa7 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800a9f:	89 d7                	mov    %edx,%edi
  800aa1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aa4:	fc                   	cld    
  800aa5:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800aa7:	89 d0                	mov    %edx,%eax
  800aa9:	5b                   	pop    %ebx
  800aaa:	5e                   	pop    %esi
  800aab:	5f                   	pop    %edi
  800aac:	5d                   	pop    %ebp
  800aad:	c3                   	ret    

00800aae <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800aae:	f3 0f 1e fb          	endbr32 
  800ab2:	55                   	push   %ebp
  800ab3:	89 e5                	mov    %esp,%ebp
  800ab5:	57                   	push   %edi
  800ab6:	56                   	push   %esi
  800ab7:	8b 45 08             	mov    0x8(%ebp),%eax
  800aba:	8b 75 0c             	mov    0xc(%ebp),%esi
  800abd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800ac0:	39 c6                	cmp    %eax,%esi
  800ac2:	73 32                	jae    800af6 <memmove+0x48>
  800ac4:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800ac7:	39 c2                	cmp    %eax,%edx
  800ac9:	76 2b                	jbe    800af6 <memmove+0x48>
		s += n;
		d += n;
  800acb:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800ace:	89 fe                	mov    %edi,%esi
  800ad0:	09 ce                	or     %ecx,%esi
  800ad2:	09 d6                	or     %edx,%esi
  800ad4:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800ada:	75 0e                	jne    800aea <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800adc:	83 ef 04             	sub    $0x4,%edi
  800adf:	8d 72 fc             	lea    -0x4(%edx),%esi
  800ae2:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800ae5:	fd                   	std    
  800ae6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ae8:	eb 09                	jmp    800af3 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800aea:	83 ef 01             	sub    $0x1,%edi
  800aed:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800af0:	fd                   	std    
  800af1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800af3:	fc                   	cld    
  800af4:	eb 1a                	jmp    800b10 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800af6:	89 c2                	mov    %eax,%edx
  800af8:	09 ca                	or     %ecx,%edx
  800afa:	09 f2                	or     %esi,%edx
  800afc:	f6 c2 03             	test   $0x3,%dl
  800aff:	75 0a                	jne    800b0b <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b01:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800b04:	89 c7                	mov    %eax,%edi
  800b06:	fc                   	cld    
  800b07:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b09:	eb 05                	jmp    800b10 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800b0b:	89 c7                	mov    %eax,%edi
  800b0d:	fc                   	cld    
  800b0e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b10:	5e                   	pop    %esi
  800b11:	5f                   	pop    %edi
  800b12:	5d                   	pop    %ebp
  800b13:	c3                   	ret    

00800b14 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800b14:	f3 0f 1e fb          	endbr32 
  800b18:	55                   	push   %ebp
  800b19:	89 e5                	mov    %esp,%ebp
  800b1b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800b1e:	ff 75 10             	pushl  0x10(%ebp)
  800b21:	ff 75 0c             	pushl  0xc(%ebp)
  800b24:	ff 75 08             	pushl  0x8(%ebp)
  800b27:	e8 82 ff ff ff       	call   800aae <memmove>
}
  800b2c:	c9                   	leave  
  800b2d:	c3                   	ret    

00800b2e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800b2e:	f3 0f 1e fb          	endbr32 
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	56                   	push   %esi
  800b36:	53                   	push   %ebx
  800b37:	8b 45 08             	mov    0x8(%ebp),%eax
  800b3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b3d:	89 c6                	mov    %eax,%esi
  800b3f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800b42:	39 f0                	cmp    %esi,%eax
  800b44:	74 1c                	je     800b62 <memcmp+0x34>
		if (*s1 != *s2)
  800b46:	0f b6 08             	movzbl (%eax),%ecx
  800b49:	0f b6 1a             	movzbl (%edx),%ebx
  800b4c:	38 d9                	cmp    %bl,%cl
  800b4e:	75 08                	jne    800b58 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800b50:	83 c0 01             	add    $0x1,%eax
  800b53:	83 c2 01             	add    $0x1,%edx
  800b56:	eb ea                	jmp    800b42 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800b58:	0f b6 c1             	movzbl %cl,%eax
  800b5b:	0f b6 db             	movzbl %bl,%ebx
  800b5e:	29 d8                	sub    %ebx,%eax
  800b60:	eb 05                	jmp    800b67 <memcmp+0x39>
	}

	return 0;
  800b62:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b67:	5b                   	pop    %ebx
  800b68:	5e                   	pop    %esi
  800b69:	5d                   	pop    %ebp
  800b6a:	c3                   	ret    

00800b6b <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800b6b:	f3 0f 1e fb          	endbr32 
  800b6f:	55                   	push   %ebp
  800b70:	89 e5                	mov    %esp,%ebp
  800b72:	8b 45 08             	mov    0x8(%ebp),%eax
  800b75:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800b78:	89 c2                	mov    %eax,%edx
  800b7a:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800b7d:	39 d0                	cmp    %edx,%eax
  800b7f:	73 09                	jae    800b8a <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800b81:	38 08                	cmp    %cl,(%eax)
  800b83:	74 05                	je     800b8a <memfind+0x1f>
	for (; s < ends; s++)
  800b85:	83 c0 01             	add    $0x1,%eax
  800b88:	eb f3                	jmp    800b7d <memfind+0x12>
			break;
	return (void *) s;
}
  800b8a:	5d                   	pop    %ebp
  800b8b:	c3                   	ret    

00800b8c <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800b8c:	f3 0f 1e fb          	endbr32 
  800b90:	55                   	push   %ebp
  800b91:	89 e5                	mov    %esp,%ebp
  800b93:	57                   	push   %edi
  800b94:	56                   	push   %esi
  800b95:	53                   	push   %ebx
  800b96:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b99:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800b9c:	eb 03                	jmp    800ba1 <strtol+0x15>
		s++;
  800b9e:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ba1:	0f b6 01             	movzbl (%ecx),%eax
  800ba4:	3c 20                	cmp    $0x20,%al
  800ba6:	74 f6                	je     800b9e <strtol+0x12>
  800ba8:	3c 09                	cmp    $0x9,%al
  800baa:	74 f2                	je     800b9e <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800bac:	3c 2b                	cmp    $0x2b,%al
  800bae:	74 2a                	je     800bda <strtol+0x4e>
	int neg = 0;
  800bb0:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800bb5:	3c 2d                	cmp    $0x2d,%al
  800bb7:	74 2b                	je     800be4 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bb9:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800bbf:	75 0f                	jne    800bd0 <strtol+0x44>
  800bc1:	80 39 30             	cmpb   $0x30,(%ecx)
  800bc4:	74 28                	je     800bee <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800bc6:	85 db                	test   %ebx,%ebx
  800bc8:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bcd:	0f 44 d8             	cmove  %eax,%ebx
  800bd0:	b8 00 00 00 00       	mov    $0x0,%eax
  800bd5:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800bd8:	eb 46                	jmp    800c20 <strtol+0x94>
		s++;
  800bda:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800bdd:	bf 00 00 00 00       	mov    $0x0,%edi
  800be2:	eb d5                	jmp    800bb9 <strtol+0x2d>
		s++, neg = 1;
  800be4:	83 c1 01             	add    $0x1,%ecx
  800be7:	bf 01 00 00 00       	mov    $0x1,%edi
  800bec:	eb cb                	jmp    800bb9 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800bee:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800bf2:	74 0e                	je     800c02 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800bf4:	85 db                	test   %ebx,%ebx
  800bf6:	75 d8                	jne    800bd0 <strtol+0x44>
		s++, base = 8;
  800bf8:	83 c1 01             	add    $0x1,%ecx
  800bfb:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c00:	eb ce                	jmp    800bd0 <strtol+0x44>
		s += 2, base = 16;
  800c02:	83 c1 02             	add    $0x2,%ecx
  800c05:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c0a:	eb c4                	jmp    800bd0 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800c0c:	0f be d2             	movsbl %dl,%edx
  800c0f:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800c12:	3b 55 10             	cmp    0x10(%ebp),%edx
  800c15:	7d 3a                	jge    800c51 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800c17:	83 c1 01             	add    $0x1,%ecx
  800c1a:	0f af 45 10          	imul   0x10(%ebp),%eax
  800c1e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800c20:	0f b6 11             	movzbl (%ecx),%edx
  800c23:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c26:	89 f3                	mov    %esi,%ebx
  800c28:	80 fb 09             	cmp    $0x9,%bl
  800c2b:	76 df                	jbe    800c0c <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800c2d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800c30:	89 f3                	mov    %esi,%ebx
  800c32:	80 fb 19             	cmp    $0x19,%bl
  800c35:	77 08                	ja     800c3f <strtol+0xb3>
			dig = *s - 'a' + 10;
  800c37:	0f be d2             	movsbl %dl,%edx
  800c3a:	83 ea 57             	sub    $0x57,%edx
  800c3d:	eb d3                	jmp    800c12 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800c3f:	8d 72 bf             	lea    -0x41(%edx),%esi
  800c42:	89 f3                	mov    %esi,%ebx
  800c44:	80 fb 19             	cmp    $0x19,%bl
  800c47:	77 08                	ja     800c51 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800c49:	0f be d2             	movsbl %dl,%edx
  800c4c:	83 ea 37             	sub    $0x37,%edx
  800c4f:	eb c1                	jmp    800c12 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800c51:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800c55:	74 05                	je     800c5c <strtol+0xd0>
		*endptr = (char *) s;
  800c57:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c5a:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800c5c:	89 c2                	mov    %eax,%edx
  800c5e:	f7 da                	neg    %edx
  800c60:	85 ff                	test   %edi,%edi
  800c62:	0f 45 c2             	cmovne %edx,%eax
}
  800c65:	5b                   	pop    %ebx
  800c66:	5e                   	pop    %esi
  800c67:	5f                   	pop    %edi
  800c68:	5d                   	pop    %ebp
  800c69:	c3                   	ret    

00800c6a <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800c6a:	55                   	push   %ebp
  800c6b:	89 e5                	mov    %esp,%ebp
  800c6d:	57                   	push   %edi
  800c6e:	56                   	push   %esi
  800c6f:	53                   	push   %ebx
  800c70:	83 ec 1c             	sub    $0x1c,%esp
  800c73:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800c76:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800c79:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800c7b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c7e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800c81:	8b 7d 10             	mov    0x10(%ebp),%edi
  800c84:	8b 75 14             	mov    0x14(%ebp),%esi
  800c87:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800c89:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800c8d:	74 04                	je     800c93 <syscall+0x29>
  800c8f:	85 c0                	test   %eax,%eax
  800c91:	7f 08                	jg     800c9b <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800c93:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c96:	5b                   	pop    %ebx
  800c97:	5e                   	pop    %esi
  800c98:	5f                   	pop    %edi
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800c9b:	83 ec 0c             	sub    $0xc,%esp
  800c9e:	50                   	push   %eax
  800c9f:	ff 75 e0             	pushl  -0x20(%ebp)
  800ca2:	68 5f 29 80 00       	push   $0x80295f
  800ca7:	6a 23                	push   $0x23
  800ca9:	68 7c 29 80 00       	push   $0x80297c
  800cae:	e8 f2 f5 ff ff       	call   8002a5 <_panic>

00800cb3 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800cb3:	f3 0f 1e fb          	endbr32 
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800cbd:	6a 00                	push   $0x0
  800cbf:	6a 00                	push   $0x0
  800cc1:	6a 00                	push   $0x0
  800cc3:	ff 75 0c             	pushl  0xc(%ebp)
  800cc6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc9:	ba 00 00 00 00       	mov    $0x0,%edx
  800cce:	b8 00 00 00 00       	mov    $0x0,%eax
  800cd3:	e8 92 ff ff ff       	call   800c6a <syscall>
}
  800cd8:	83 c4 10             	add    $0x10,%esp
  800cdb:	c9                   	leave  
  800cdc:	c3                   	ret    

00800cdd <sys_cgetc>:

int
sys_cgetc(void)
{
  800cdd:	f3 0f 1e fb          	endbr32 
  800ce1:	55                   	push   %ebp
  800ce2:	89 e5                	mov    %esp,%ebp
  800ce4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800ce7:	6a 00                	push   $0x0
  800ce9:	6a 00                	push   $0x0
  800ceb:	6a 00                	push   $0x0
  800ced:	6a 00                	push   $0x0
  800cef:	b9 00 00 00 00       	mov    $0x0,%ecx
  800cf4:	ba 00 00 00 00       	mov    $0x0,%edx
  800cf9:	b8 01 00 00 00       	mov    $0x1,%eax
  800cfe:	e8 67 ff ff ff       	call   800c6a <syscall>
}
  800d03:	c9                   	leave  
  800d04:	c3                   	ret    

00800d05 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800d05:	f3 0f 1e fb          	endbr32 
  800d09:	55                   	push   %ebp
  800d0a:	89 e5                	mov    %esp,%ebp
  800d0c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800d0f:	6a 00                	push   $0x0
  800d11:	6a 00                	push   $0x0
  800d13:	6a 00                	push   $0x0
  800d15:	6a 00                	push   $0x0
  800d17:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d1a:	ba 01 00 00 00       	mov    $0x1,%edx
  800d1f:	b8 03 00 00 00       	mov    $0x3,%eax
  800d24:	e8 41 ff ff ff       	call   800c6a <syscall>
}
  800d29:	c9                   	leave  
  800d2a:	c3                   	ret    

00800d2b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800d2b:	f3 0f 1e fb          	endbr32 
  800d2f:	55                   	push   %ebp
  800d30:	89 e5                	mov    %esp,%ebp
  800d32:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800d35:	6a 00                	push   $0x0
  800d37:	6a 00                	push   $0x0
  800d39:	6a 00                	push   $0x0
  800d3b:	6a 00                	push   $0x0
  800d3d:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d42:	ba 00 00 00 00       	mov    $0x0,%edx
  800d47:	b8 02 00 00 00       	mov    $0x2,%eax
  800d4c:	e8 19 ff ff ff       	call   800c6a <syscall>
}
  800d51:	c9                   	leave  
  800d52:	c3                   	ret    

00800d53 <sys_yield>:

void
sys_yield(void)
{
  800d53:	f3 0f 1e fb          	endbr32 
  800d57:	55                   	push   %ebp
  800d58:	89 e5                	mov    %esp,%ebp
  800d5a:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800d5d:	6a 00                	push   $0x0
  800d5f:	6a 00                	push   $0x0
  800d61:	6a 00                	push   $0x0
  800d63:	6a 00                	push   $0x0
  800d65:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d6a:	ba 00 00 00 00       	mov    $0x0,%edx
  800d6f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800d74:	e8 f1 fe ff ff       	call   800c6a <syscall>
}
  800d79:	83 c4 10             	add    $0x10,%esp
  800d7c:	c9                   	leave  
  800d7d:	c3                   	ret    

00800d7e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800d7e:	f3 0f 1e fb          	endbr32 
  800d82:	55                   	push   %ebp
  800d83:	89 e5                	mov    %esp,%ebp
  800d85:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800d88:	6a 00                	push   $0x0
  800d8a:	6a 00                	push   $0x0
  800d8c:	ff 75 10             	pushl  0x10(%ebp)
  800d8f:	ff 75 0c             	pushl  0xc(%ebp)
  800d92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d95:	ba 01 00 00 00       	mov    $0x1,%edx
  800d9a:	b8 04 00 00 00       	mov    $0x4,%eax
  800d9f:	e8 c6 fe ff ff       	call   800c6a <syscall>
}
  800da4:	c9                   	leave  
  800da5:	c3                   	ret    

00800da6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800da6:	f3 0f 1e fb          	endbr32 
  800daa:	55                   	push   %ebp
  800dab:	89 e5                	mov    %esp,%ebp
  800dad:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800db0:	ff 75 18             	pushl  0x18(%ebp)
  800db3:	ff 75 14             	pushl  0x14(%ebp)
  800db6:	ff 75 10             	pushl  0x10(%ebp)
  800db9:	ff 75 0c             	pushl  0xc(%ebp)
  800dbc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800dbf:	ba 01 00 00 00       	mov    $0x1,%edx
  800dc4:	b8 05 00 00 00       	mov    $0x5,%eax
  800dc9:	e8 9c fe ff ff       	call   800c6a <syscall>
}
  800dce:	c9                   	leave  
  800dcf:	c3                   	ret    

00800dd0 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800dd0:	f3 0f 1e fb          	endbr32 
  800dd4:	55                   	push   %ebp
  800dd5:	89 e5                	mov    %esp,%ebp
  800dd7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800dda:	6a 00                	push   $0x0
  800ddc:	6a 00                	push   $0x0
  800dde:	6a 00                	push   $0x0
  800de0:	ff 75 0c             	pushl  0xc(%ebp)
  800de3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800de6:	ba 01 00 00 00       	mov    $0x1,%edx
  800deb:	b8 06 00 00 00       	mov    $0x6,%eax
  800df0:	e8 75 fe ff ff       	call   800c6a <syscall>
}
  800df5:	c9                   	leave  
  800df6:	c3                   	ret    

00800df7 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800df7:	f3 0f 1e fb          	endbr32 
  800dfb:	55                   	push   %ebp
  800dfc:	89 e5                	mov    %esp,%ebp
  800dfe:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800e01:	6a 00                	push   $0x0
  800e03:	6a 00                	push   $0x0
  800e05:	6a 00                	push   $0x0
  800e07:	ff 75 0c             	pushl  0xc(%ebp)
  800e0a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0d:	ba 01 00 00 00       	mov    $0x1,%edx
  800e12:	b8 08 00 00 00       	mov    $0x8,%eax
  800e17:	e8 4e fe ff ff       	call   800c6a <syscall>
}
  800e1c:	c9                   	leave  
  800e1d:	c3                   	ret    

00800e1e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800e1e:	f3 0f 1e fb          	endbr32 
  800e22:	55                   	push   %ebp
  800e23:	89 e5                	mov    %esp,%ebp
  800e25:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800e28:	6a 00                	push   $0x0
  800e2a:	6a 00                	push   $0x0
  800e2c:	6a 00                	push   $0x0
  800e2e:	ff 75 0c             	pushl  0xc(%ebp)
  800e31:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e34:	ba 01 00 00 00       	mov    $0x1,%edx
  800e39:	b8 09 00 00 00       	mov    $0x9,%eax
  800e3e:	e8 27 fe ff ff       	call   800c6a <syscall>
}
  800e43:	c9                   	leave  
  800e44:	c3                   	ret    

00800e45 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800e45:	f3 0f 1e fb          	endbr32 
  800e49:	55                   	push   %ebp
  800e4a:	89 e5                	mov    %esp,%ebp
  800e4c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800e4f:	6a 00                	push   $0x0
  800e51:	6a 00                	push   $0x0
  800e53:	6a 00                	push   $0x0
  800e55:	ff 75 0c             	pushl  0xc(%ebp)
  800e58:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5b:	ba 01 00 00 00       	mov    $0x1,%edx
  800e60:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e65:	e8 00 fe ff ff       	call   800c6a <syscall>
}
  800e6a:	c9                   	leave  
  800e6b:	c3                   	ret    

00800e6c <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800e6c:	f3 0f 1e fb          	endbr32 
  800e70:	55                   	push   %ebp
  800e71:	89 e5                	mov    %esp,%ebp
  800e73:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800e76:	6a 00                	push   $0x0
  800e78:	ff 75 14             	pushl  0x14(%ebp)
  800e7b:	ff 75 10             	pushl  0x10(%ebp)
  800e7e:	ff 75 0c             	pushl  0xc(%ebp)
  800e81:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e84:	ba 00 00 00 00       	mov    $0x0,%edx
  800e89:	b8 0c 00 00 00       	mov    $0xc,%eax
  800e8e:	e8 d7 fd ff ff       	call   800c6a <syscall>
}
  800e93:	c9                   	leave  
  800e94:	c3                   	ret    

00800e95 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800e95:	f3 0f 1e fb          	endbr32 
  800e99:	55                   	push   %ebp
  800e9a:	89 e5                	mov    %esp,%ebp
  800e9c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800e9f:	6a 00                	push   $0x0
  800ea1:	6a 00                	push   $0x0
  800ea3:	6a 00                	push   $0x0
  800ea5:	6a 00                	push   $0x0
  800ea7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eaa:	ba 01 00 00 00       	mov    $0x1,%edx
  800eaf:	b8 0d 00 00 00       	mov    $0xd,%eax
  800eb4:	e8 b1 fd ff ff       	call   800c6a <syscall>
}
  800eb9:	c9                   	leave  
  800eba:	c3                   	ret    

00800ebb <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	53                   	push   %ebx
  800ebf:	83 ec 04             	sub    $0x4,%esp
  800ec2:	89 d3                	mov    %edx,%ebx
	int r;

	// LAB 4: Your code here.

	// Page Table Entry
	pte_t pt_e = uvpt[pn];
  800ec4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Obtenemos la virtual address
	void *v_add = (void *) (pn << PTXSHIFT);
  800ecb:	c1 e3 0c             	shl    $0xc,%ebx

	if (pt_e & PTE_SHARE) {
  800ece:	f6 c6 04             	test   $0x4,%dh
  800ed1:	75 54                	jne    800f27 <duppage+0x6c>
		// Permisos compartidos
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
		if (r < 0)
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	} else if ((pt_e & PTE_W) || (pt_e & PTE_COW)) {
  800ed3:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800ed9:	0f 84 8d 00 00 00    	je     800f6c <duppage+0xb1>
		// Copy on write
		r = sys_page_map(0, v_add, envid, v_add, PTE_COW | PTE_U | PTE_P);
  800edf:	83 ec 0c             	sub    $0xc,%esp
  800ee2:	68 05 08 00 00       	push   $0x805
  800ee7:	53                   	push   %ebx
  800ee8:	50                   	push   %eax
  800ee9:	53                   	push   %ebx
  800eea:	6a 00                	push   $0x0
  800eec:	e8 b5 fe ff ff       	call   800da6 <sys_page_map>
		if (r < 0)
  800ef1:	83 c4 20             	add    $0x20,%esp
  800ef4:	85 c0                	test   %eax,%eax
  800ef6:	78 5f                	js     800f57 <duppage+0x9c>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);

		r = sys_page_map(0, v_add, 0, v_add, PTE_COW | PTE_U | PTE_P);
  800ef8:	83 ec 0c             	sub    $0xc,%esp
  800efb:	68 05 08 00 00       	push   $0x805
  800f00:	53                   	push   %ebx
  800f01:	6a 00                	push   $0x0
  800f03:	53                   	push   %ebx
  800f04:	6a 00                	push   $0x0
  800f06:	e8 9b fe ff ff       	call   800da6 <sys_page_map>
		if (r < 0)
  800f0b:	83 c4 20             	add    $0x20,%esp
  800f0e:	85 c0                	test   %eax,%eax
  800f10:	79 70                	jns    800f82 <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800f12:	50                   	push   %eax
  800f13:	68 8c 29 80 00       	push   $0x80298c
  800f18:	68 9b 00 00 00       	push   $0x9b
  800f1d:	68 fa 2a 80 00       	push   $0x802afa
  800f22:	e8 7e f3 ff ff       	call   8002a5 <_panic>
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
  800f27:	83 ec 0c             	sub    $0xc,%esp
  800f2a:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800f30:	52                   	push   %edx
  800f31:	53                   	push   %ebx
  800f32:	50                   	push   %eax
  800f33:	53                   	push   %ebx
  800f34:	6a 00                	push   $0x0
  800f36:	e8 6b fe ff ff       	call   800da6 <sys_page_map>
		if (r < 0)
  800f3b:	83 c4 20             	add    $0x20,%esp
  800f3e:	85 c0                	test   %eax,%eax
  800f40:	79 40                	jns    800f82 <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800f42:	50                   	push   %eax
  800f43:	68 8c 29 80 00       	push   $0x80298c
  800f48:	68 92 00 00 00       	push   $0x92
  800f4d:	68 fa 2a 80 00       	push   $0x802afa
  800f52:	e8 4e f3 ff ff       	call   8002a5 <_panic>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800f57:	50                   	push   %eax
  800f58:	68 8c 29 80 00       	push   $0x80298c
  800f5d:	68 97 00 00 00       	push   $0x97
  800f62:	68 fa 2a 80 00       	push   $0x802afa
  800f67:	e8 39 f3 ff ff       	call   8002a5 <_panic>
	} else {
		// En caso de lectura, compartir.
		r = sys_page_map(0, v_add, envid, v_add, PTE_U | PTE_P);
  800f6c:	83 ec 0c             	sub    $0xc,%esp
  800f6f:	6a 05                	push   $0x5
  800f71:	53                   	push   %ebx
  800f72:	50                   	push   %eax
  800f73:	53                   	push   %ebx
  800f74:	6a 00                	push   $0x0
  800f76:	e8 2b fe ff ff       	call   800da6 <sys_page_map>
		if (r < 0)
  800f7b:	83 c4 20             	add    $0x20,%esp
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	78 0a                	js     800f8c <duppage+0xd1>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	}
	return 0;
}
  800f82:	b8 00 00 00 00       	mov    $0x0,%eax
  800f87:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800f8a:	c9                   	leave  
  800f8b:	c3                   	ret    
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800f8c:	50                   	push   %eax
  800f8d:	68 8c 29 80 00       	push   $0x80298c
  800f92:	68 a0 00 00 00       	push   $0xa0
  800f97:	68 fa 2a 80 00       	push   $0x802afa
  800f9c:	e8 04 f3 ff ff       	call   8002a5 <_panic>

00800fa1 <dup_or_share>:
{
  800fa1:	55                   	push   %ebp
  800fa2:	89 e5                	mov    %esp,%ebp
  800fa4:	57                   	push   %edi
  800fa5:	56                   	push   %esi
  800fa6:	53                   	push   %ebx
  800fa7:	83 ec 0c             	sub    $0xc,%esp
  800faa:	89 c7                	mov    %eax,%edi
  800fac:	89 d6                	mov    %edx,%esi
  800fae:	89 cb                	mov    %ecx,%ebx
	if (perm & PTE_W) {
  800fb0:	f6 c1 02             	test   $0x2,%cl
  800fb3:	0f 84 90 00 00 00    	je     801049 <dup_or_share+0xa8>
		if ((r = sys_page_alloc(dstenv, va, perm)) < 0)
  800fb9:	83 ec 04             	sub    $0x4,%esp
  800fbc:	51                   	push   %ecx
  800fbd:	52                   	push   %edx
  800fbe:	50                   	push   %eax
  800fbf:	e8 ba fd ff ff       	call   800d7e <sys_page_alloc>
  800fc4:	83 c4 10             	add    $0x10,%esp
  800fc7:	85 c0                	test   %eax,%eax
  800fc9:	78 56                	js     801021 <dup_or_share+0x80>
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, perm)) < 0)
  800fcb:	83 ec 0c             	sub    $0xc,%esp
  800fce:	53                   	push   %ebx
  800fcf:	68 00 00 40 00       	push   $0x400000
  800fd4:	6a 00                	push   $0x0
  800fd6:	56                   	push   %esi
  800fd7:	57                   	push   %edi
  800fd8:	e8 c9 fd ff ff       	call   800da6 <sys_page_map>
  800fdd:	83 c4 20             	add    $0x20,%esp
  800fe0:	85 c0                	test   %eax,%eax
  800fe2:	78 51                	js     801035 <dup_or_share+0x94>
		memmove(UTEMP, va, PGSIZE);
  800fe4:	83 ec 04             	sub    $0x4,%esp
  800fe7:	68 00 10 00 00       	push   $0x1000
  800fec:	56                   	push   %esi
  800fed:	68 00 00 40 00       	push   $0x400000
  800ff2:	e8 b7 fa ff ff       	call   800aae <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800ff7:	83 c4 08             	add    $0x8,%esp
  800ffa:	68 00 00 40 00       	push   $0x400000
  800fff:	6a 00                	push   $0x0
  801001:	e8 ca fd ff ff       	call   800dd0 <sys_page_unmap>
  801006:	83 c4 10             	add    $0x10,%esp
  801009:	85 c0                	test   %eax,%eax
  80100b:	79 51                	jns    80105e <dup_or_share+0xbd>
			panic("sys_page_unmap failed at dup_or_share");
  80100d:	83 ec 04             	sub    $0x4,%esp
  801010:	68 fc 29 80 00       	push   $0x8029fc
  801015:	6a 18                	push   $0x18
  801017:	68 fa 2a 80 00       	push   $0x802afa
  80101c:	e8 84 f2 ff ff       	call   8002a5 <_panic>
			panic("sys_page_alloc failed at dup_or_share");
  801021:	83 ec 04             	sub    $0x4,%esp
  801024:	68 b0 29 80 00       	push   $0x8029b0
  801029:	6a 13                	push   $0x13
  80102b:	68 fa 2a 80 00       	push   $0x802afa
  801030:	e8 70 f2 ff ff       	call   8002a5 <_panic>
			panic("sys_page_map failed at dup_or_share");
  801035:	83 ec 04             	sub    $0x4,%esp
  801038:	68 d8 29 80 00       	push   $0x8029d8
  80103d:	6a 15                	push   $0x15
  80103f:	68 fa 2a 80 00       	push   $0x802afa
  801044:	e8 5c f2 ff ff       	call   8002a5 <_panic>
		if ((r = sys_page_map(0, va, dstenv, va, perm)) < 0)
  801049:	83 ec 0c             	sub    $0xc,%esp
  80104c:	51                   	push   %ecx
  80104d:	52                   	push   %edx
  80104e:	50                   	push   %eax
  80104f:	52                   	push   %edx
  801050:	6a 00                	push   $0x0
  801052:	e8 4f fd ff ff       	call   800da6 <sys_page_map>
  801057:	83 c4 20             	add    $0x20,%esp
  80105a:	85 c0                	test   %eax,%eax
  80105c:	78 08                	js     801066 <dup_or_share+0xc5>
}
  80105e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801061:	5b                   	pop    %ebx
  801062:	5e                   	pop    %esi
  801063:	5f                   	pop    %edi
  801064:	5d                   	pop    %ebp
  801065:	c3                   	ret    
			panic("sys_page_map failed at dup_or_share");
  801066:	83 ec 04             	sub    $0x4,%esp
  801069:	68 d8 29 80 00       	push   $0x8029d8
  80106e:	6a 1c                	push   $0x1c
  801070:	68 fa 2a 80 00       	push   $0x802afa
  801075:	e8 2b f2 ff ff       	call   8002a5 <_panic>

0080107a <pgfault>:
{
  80107a:	f3 0f 1e fb          	endbr32 
  80107e:	55                   	push   %ebp
  80107f:	89 e5                	mov    %esp,%ebp
  801081:	53                   	push   %ebx
  801082:	83 ec 04             	sub    $0x4,%esp
  801085:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801088:	8b 18                	mov    (%eax),%ebx
	pte_t pt_e = uvpt[PGNUM(addr)];
  80108a:	89 da                	mov    %ebx,%edx
  80108c:	c1 ea 0c             	shr    $0xc,%edx
  80108f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if ((err & FEC_WR) == 0)
  801096:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80109a:	74 6e                	je     80110a <pgfault+0x90>
	if ((pt_e & PTE_COW) == 0)
  80109c:	f6 c6 08             	test   $0x8,%dh
  80109f:	74 7d                	je     80111e <pgfault+0xa4>
	if ((r = sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  8010a1:	83 ec 04             	sub    $0x4,%esp
  8010a4:	6a 07                	push   $0x7
  8010a6:	68 00 f0 7f 00       	push   $0x7ff000
  8010ab:	6a 00                	push   $0x0
  8010ad:	e8 cc fc ff ff       	call   800d7e <sys_page_alloc>
  8010b2:	83 c4 10             	add    $0x10,%esp
  8010b5:	85 c0                	test   %eax,%eax
  8010b7:	78 79                	js     801132 <pgfault+0xb8>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  8010b9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  8010bf:	83 ec 04             	sub    $0x4,%esp
  8010c2:	68 00 10 00 00       	push   $0x1000
  8010c7:	53                   	push   %ebx
  8010c8:	68 00 f0 7f 00       	push   $0x7ff000
  8010cd:	e8 dc f9 ff ff       	call   800aae <memmove>
	if ((r = sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U)) <
  8010d2:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8010d9:	53                   	push   %ebx
  8010da:	6a 00                	push   $0x0
  8010dc:	68 00 f0 7f 00       	push   $0x7ff000
  8010e1:	6a 00                	push   $0x0
  8010e3:	e8 be fc ff ff       	call   800da6 <sys_page_map>
  8010e8:	83 c4 20             	add    $0x20,%esp
  8010eb:	85 c0                	test   %eax,%eax
  8010ed:	78 57                	js     801146 <pgfault+0xcc>
	if ((r = sys_page_unmap(0, (void *) PFTEMP)) < 0)
  8010ef:	83 ec 08             	sub    $0x8,%esp
  8010f2:	68 00 f0 7f 00       	push   $0x7ff000
  8010f7:	6a 00                	push   $0x0
  8010f9:	e8 d2 fc ff ff       	call   800dd0 <sys_page_unmap>
  8010fe:	83 c4 10             	add    $0x10,%esp
  801101:	85 c0                	test   %eax,%eax
  801103:	78 55                	js     80115a <pgfault+0xe0>
}
  801105:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801108:	c9                   	leave  
  801109:	c3                   	ret    
		panic("ERROR EN PGFAULT: WRITE");
  80110a:	83 ec 04             	sub    $0x4,%esp
  80110d:	68 05 2b 80 00       	push   $0x802b05
  801112:	6a 5e                	push   $0x5e
  801114:	68 fa 2a 80 00       	push   $0x802afa
  801119:	e8 87 f1 ff ff       	call   8002a5 <_panic>
		panic("ERROR EN PGFAULT: COPY-ON-WRITE");
  80111e:	83 ec 04             	sub    $0x4,%esp
  801121:	68 24 2a 80 00       	push   $0x802a24
  801126:	6a 62                	push   $0x62
  801128:	68 fa 2a 80 00       	push   $0x802afa
  80112d:	e8 73 f1 ff ff       	call   8002a5 <_panic>
		panic("pgfault failed");
  801132:	83 ec 04             	sub    $0x4,%esp
  801135:	68 1d 2b 80 00       	push   $0x802b1d
  80113a:	6a 6d                	push   $0x6d
  80113c:	68 fa 2a 80 00       	push   $0x802afa
  801141:	e8 5f f1 ff ff       	call   8002a5 <_panic>
		panic("pgfault failed");
  801146:	83 ec 04             	sub    $0x4,%esp
  801149:	68 1d 2b 80 00       	push   $0x802b1d
  80114e:	6a 72                	push   $0x72
  801150:	68 fa 2a 80 00       	push   $0x802afa
  801155:	e8 4b f1 ff ff       	call   8002a5 <_panic>
		panic("pgfault failed");
  80115a:	83 ec 04             	sub    $0x4,%esp
  80115d:	68 1d 2b 80 00       	push   $0x802b1d
  801162:	6a 74                	push   $0x74
  801164:	68 fa 2a 80 00       	push   $0x802afa
  801169:	e8 37 f1 ff ff       	call   8002a5 <_panic>

0080116e <fork_v0>:
{
  80116e:	f3 0f 1e fb          	endbr32 
  801172:	55                   	push   %ebp
  801173:	89 e5                	mov    %esp,%ebp
  801175:	57                   	push   %edi
  801176:	56                   	push   %esi
  801177:	53                   	push   %ebx
  801178:	83 ec 1c             	sub    $0x1c,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  80117b:	b8 07 00 00 00       	mov    $0x7,%eax
  801180:	cd 30                	int    $0x30
  801182:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801185:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (envid < 0)
  801188:	85 c0                	test   %eax,%eax
  80118a:	78 1d                	js     8011a9 <fork_v0+0x3b>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  80118c:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  801191:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801195:	74 26                	je     8011bd <fork_v0+0x4f>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  801197:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  80119c:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
			        (pte_t *) (PGADDR(PDX(uvpt),
  8011a2:	bf 00 00 40 ef       	mov    $0xef400000,%edi
  8011a7:	eb 4b                	jmp    8011f4 <fork_v0+0x86>
		panic("sys_exofork failed");
  8011a9:	83 ec 04             	sub    $0x4,%esp
  8011ac:	68 2c 2b 80 00       	push   $0x802b2c
  8011b1:	6a 2b                	push   $0x2b
  8011b3:	68 fa 2a 80 00       	push   $0x802afa
  8011b8:	e8 e8 f0 ff ff       	call   8002a5 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
  8011bd:	e8 69 fb ff ff       	call   800d2b <sys_getenvid>
  8011c2:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011c7:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011ca:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011cf:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8011d4:	eb 68                	jmp    80123e <fork_v0+0xd0>
				dup_or_share(envid,
  8011d6:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  8011dc:	89 da                	mov    %ebx,%edx
  8011de:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8011e1:	e8 bb fd ff ff       	call   800fa1 <dup_or_share>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  8011e6:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8011ec:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  8011f2:	74 36                	je     80122a <fork_v0+0xbc>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  8011f4:	89 d8                	mov    %ebx,%eax
  8011f6:	c1 e8 16             	shr    $0x16,%eax
  8011f9:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801200:	09 f2                	or     %esi,%edx
		if ((*pgdirentry) & PTE_P) {
  801202:	f6 02 01             	testb  $0x1,(%edx)
  801205:	74 df                	je     8011e6 <fork_v0+0x78>
			        (pte_t *) (PGADDR(PDX(uvpt),
  801207:	89 da                	mov    %ebx,%edx
  801209:	c1 ea 0a             	shr    $0xa,%edx
  80120c:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  801212:	c1 e0 0c             	shl    $0xc,%eax
  801215:	89 f9                	mov    %edi,%ecx
  801217:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
  80121d:	09 c8                	or     %ecx,%eax
  80121f:	09 d0                	or     %edx,%eax
			if ((*pgtablentry) & PTE_P)
  801221:	8b 08                	mov    (%eax),%ecx
  801223:	f6 c1 01             	test   $0x1,%cl
  801226:	74 be                	je     8011e6 <fork_v0+0x78>
  801228:	eb ac                	jmp    8011d6 <fork_v0+0x68>
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80122a:	83 ec 08             	sub    $0x8,%esp
  80122d:	6a 02                	push   $0x2
  80122f:	ff 75 e0             	pushl  -0x20(%ebp)
  801232:	e8 c0 fb ff ff       	call   800df7 <sys_env_set_status>
  801237:	83 c4 10             	add    $0x10,%esp
  80123a:	85 c0                	test   %eax,%eax
  80123c:	78 0b                	js     801249 <fork_v0+0xdb>
}
  80123e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801241:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801244:	5b                   	pop    %ebx
  801245:	5e                   	pop    %esi
  801246:	5f                   	pop    %edi
  801247:	5d                   	pop    %ebp
  801248:	c3                   	ret    
		panic("sys_env_set_status failed at fork_v0");
  801249:	83 ec 04             	sub    $0x4,%esp
  80124c:	68 44 2a 80 00       	push   $0x802a44
  801251:	6a 43                	push   $0x43
  801253:	68 fa 2a 80 00       	push   $0x802afa
  801258:	e8 48 f0 ff ff       	call   8002a5 <_panic>

0080125d <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  80125d:	f3 0f 1e fb          	endbr32 
  801261:	55                   	push   %ebp
  801262:	89 e5                	mov    %esp,%ebp
  801264:	57                   	push   %edi
  801265:	56                   	push   %esi
  801266:	53                   	push   %ebx
  801267:	83 ec 28             	sub    $0x28,%esp
	int err;

	// handle padre
	set_pgfault_handler(pgfault);
  80126a:	68 7a 10 80 00       	push   $0x80107a
  80126f:	e8 d3 0e 00 00       	call   802147 <set_pgfault_handler>
  801274:	b8 07 00 00 00       	mov    $0x7,%eax
  801279:	cd 30                	int    $0x30
  80127b:	89 45 e0             	mov    %eax,-0x20(%ebp)

	// Proceso hijo
	envid_t e_id = sys_exofork();

	if (e_id < 0)
  80127e:	83 c4 10             	add    $0x10,%esp
  801281:	85 c0                	test   %eax,%eax
  801283:	78 2f                	js     8012b4 <fork+0x57>
  801285:	89 c7                	mov    %eax,%edi
  801287:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		panic("ERROR EN FORK: sys_exofork: %e", e_id);

	if (e_id == 0) {
  80128e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801292:	0f 85 9e 00 00 00    	jne    801336 <fork+0xd9>
		// Si es hijo
		thisenv = &envs[ENVX(sys_getenvid())];
  801298:	e8 8e fa ff ff       	call   800d2b <sys_getenvid>
  80129d:	25 ff 03 00 00       	and    $0x3ff,%eax
  8012a2:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8012a5:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8012aa:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8012af:	e9 de 00 00 00       	jmp    801392 <fork+0x135>
		panic("ERROR EN FORK: sys_exofork: %e", e_id);
  8012b4:	50                   	push   %eax
  8012b5:	68 6c 2a 80 00       	push   $0x802a6c
  8012ba:	68 c2 00 00 00       	push   $0xc2
  8012bf:	68 fa 2a 80 00       	push   $0x802afa
  8012c4:	e8 dc ef ff ff       	call   8002a5 <_panic>
		// LOOP PTEs
		while (pt_x < NPTENTRIES) {
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
			pte_t pt_e = uvpt[PGNUM(dir)];
			if (dir == (UXSTACKTOP - PGSIZE)) {
				err = sys_page_alloc(e_id,
  8012c9:	83 ec 04             	sub    $0x4,%esp
  8012cc:	6a 07                	push   $0x7
  8012ce:	68 00 f0 bf ee       	push   $0xeebff000
  8012d3:	57                   	push   %edi
  8012d4:	e8 a5 fa ff ff       	call   800d7e <sys_page_alloc>
				                     (void *) dir,
				                     PTE_W | PTE_U | PTE_P);
				if (err)
  8012d9:	83 c4 10             	add    $0x10,%esp
  8012dc:	85 c0                	test   %eax,%eax
  8012de:	75 33                	jne    801313 <fork+0xb6>
  8012e0:	83 c3 01             	add    $0x1,%ebx
		while (pt_x < NPTENTRIES) {
  8012e3:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  8012e9:	74 3d                	je     801328 <fork+0xcb>
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
  8012eb:	89 d8                	mov    %ebx,%eax
  8012ed:	c1 e0 0c             	shl    $0xc,%eax
  8012f0:	09 f0                	or     %esi,%eax
			pte_t pt_e = uvpt[PGNUM(dir)];
  8012f2:	89 c2                	mov    %eax,%edx
  8012f4:	c1 ea 0c             	shr    $0xc,%edx
  8012f7:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
			if (dir == (UXSTACKTOP - PGSIZE)) {
  8012fe:	3d 00 f0 bf ee       	cmp    $0xeebff000,%eax
  801303:	74 c4                	je     8012c9 <fork+0x6c>
					      "%e",
					      err);
				pt_x++;
				continue;
			}
			if ((pt_e & PTE_P) == 0) {
  801305:	f6 c1 01             	test   $0x1,%cl
  801308:	74 d6                	je     8012e0 <fork+0x83>
				pt_x++;
				continue;
			}
			duppage(e_id, PGNUM(dir));
  80130a:	89 f8                	mov    %edi,%eax
  80130c:	e8 aa fb ff ff       	call   800ebb <duppage>
  801311:	eb cd                	jmp    8012e0 <fork+0x83>
					panic("ERROR EN FORK: sys_page_alloc: "
  801313:	50                   	push   %eax
  801314:	68 8c 2a 80 00       	push   $0x802a8c
  801319:	68 e1 00 00 00       	push   $0xe1
  80131e:	68 fa 2a 80 00       	push   $0x802afa
  801323:	e8 7d ef ff ff       	call   8002a5 <_panic>
  801328:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  80132c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
	while (pd_x < PDX(UTOP)) {
  80132f:	3d bb 03 00 00       	cmp    $0x3bb,%eax
  801334:	74 18                	je     80134e <fork+0xf1>
		pde_t pd_e = uvpd[pd_x];
  801336:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801339:	8b 04 b5 00 d0 7b ef 	mov    -0x10843000(,%esi,4),%eax
		if ((pd_e & PTE_P) == 0) {
  801340:	a8 01                	test   $0x1,%al
  801342:	74 e4                	je     801328 <fork+0xcb>
  801344:	c1 e6 16             	shl    $0x16,%esi
  801347:	bb 00 00 00 00       	mov    $0x0,%ebx
  80134c:	eb 9d                	jmp    8012eb <fork+0x8e>
			pt_x++;
		}
		pd_x++;
	}

	if ((err = sys_page_alloc(e_id,
  80134e:	83 ec 04             	sub    $0x4,%esp
  801351:	6a 07                	push   $0x7
  801353:	68 00 f0 bf ee       	push   $0xeebff000
  801358:	ff 75 e0             	pushl  -0x20(%ebp)
  80135b:	e8 1e fa ff ff       	call   800d7e <sys_page_alloc>
  801360:	83 c4 10             	add    $0x10,%esp
  801363:	85 c0                	test   %eax,%eax
  801365:	78 36                	js     80139d <fork+0x140>
	                          (void *) (UXSTACKTOP - PGSIZE),
	                          PTE_P | PTE_U | PTE_W) < 0))
		panic("Error en sys_page_alloc");


	if ((sys_env_set_pgfault_upcall(e_id, _pgfault_upcall) < 0))
  801367:	83 ec 08             	sub    $0x8,%esp
  80136a:	68 a2 21 80 00       	push   $0x8021a2
  80136f:	ff 75 e0             	pushl  -0x20(%ebp)
  801372:	e8 ce fa ff ff       	call   800e45 <sys_env_set_pgfault_upcall>
  801377:	83 c4 10             	add    $0x10,%esp
  80137a:	85 c0                	test   %eax,%eax
  80137c:	78 36                	js     8013b4 <fork+0x157>
		panic("sys_env_set_pgfault_upcall failed");

	// HIJO RUNNABLE
	if ((err = sys_env_set_status(e_id, ENV_RUNNABLE)) < 0)
  80137e:	83 ec 08             	sub    $0x8,%esp
  801381:	6a 02                	push   $0x2
  801383:	ff 75 e0             	pushl  -0x20(%ebp)
  801386:	e8 6c fa ff ff       	call   800df7 <sys_env_set_status>
  80138b:	83 c4 10             	add    $0x10,%esp
  80138e:	85 c0                	test   %eax,%eax
  801390:	78 39                	js     8013cb <fork+0x16e>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);

	return e_id;
}
  801392:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801395:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801398:	5b                   	pop    %ebx
  801399:	5e                   	pop    %esi
  80139a:	5f                   	pop    %edi
  80139b:	5d                   	pop    %ebp
  80139c:	c3                   	ret    
		panic("Error en sys_page_alloc");
  80139d:	83 ec 04             	sub    $0x4,%esp
  8013a0:	68 3f 2b 80 00       	push   $0x802b3f
  8013a5:	68 f4 00 00 00       	push   $0xf4
  8013aa:	68 fa 2a 80 00       	push   $0x802afa
  8013af:	e8 f1 ee ff ff       	call   8002a5 <_panic>
		panic("sys_env_set_pgfault_upcall failed");
  8013b4:	83 ec 04             	sub    $0x4,%esp
  8013b7:	68 b0 2a 80 00       	push   $0x802ab0
  8013bc:	68 f8 00 00 00       	push   $0xf8
  8013c1:	68 fa 2a 80 00       	push   $0x802afa
  8013c6:	e8 da ee ff ff       	call   8002a5 <_panic>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);
  8013cb:	50                   	push   %eax
  8013cc:	68 d4 2a 80 00       	push   $0x802ad4
  8013d1:	68 fc 00 00 00       	push   $0xfc
  8013d6:	68 fa 2a 80 00       	push   $0x802afa
  8013db:	e8 c5 ee ff ff       	call   8002a5 <_panic>

008013e0 <sfork>:

// Challenge!
int
sfork(void)
{
  8013e0:	f3 0f 1e fb          	endbr32 
  8013e4:	55                   	push   %ebp
  8013e5:	89 e5                	mov    %esp,%ebp
  8013e7:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  8013ea:	68 57 2b 80 00       	push   $0x802b57
  8013ef:	68 05 01 00 00       	push   $0x105
  8013f4:	68 fa 2a 80 00       	push   $0x802afa
  8013f9:	e8 a7 ee ff ff       	call   8002a5 <_panic>

008013fe <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8013fe:	f3 0f 1e fb          	endbr32 
  801402:	55                   	push   %ebp
  801403:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801405:	8b 45 08             	mov    0x8(%ebp),%eax
  801408:	05 00 00 00 30       	add    $0x30000000,%eax
  80140d:	c1 e8 0c             	shr    $0xc,%eax
}
  801410:	5d                   	pop    %ebp
  801411:	c3                   	ret    

00801412 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801412:	f3 0f 1e fb          	endbr32 
  801416:	55                   	push   %ebp
  801417:	89 e5                	mov    %esp,%ebp
  801419:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  80141c:	ff 75 08             	pushl  0x8(%ebp)
  80141f:	e8 da ff ff ff       	call   8013fe <fd2num>
  801424:	83 c4 10             	add    $0x10,%esp
  801427:	c1 e0 0c             	shl    $0xc,%eax
  80142a:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80142f:	c9                   	leave  
  801430:	c3                   	ret    

00801431 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801431:	f3 0f 1e fb          	endbr32 
  801435:	55                   	push   %ebp
  801436:	89 e5                	mov    %esp,%ebp
  801438:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80143d:	89 c2                	mov    %eax,%edx
  80143f:	c1 ea 16             	shr    $0x16,%edx
  801442:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801449:	f6 c2 01             	test   $0x1,%dl
  80144c:	74 2d                	je     80147b <fd_alloc+0x4a>
  80144e:	89 c2                	mov    %eax,%edx
  801450:	c1 ea 0c             	shr    $0xc,%edx
  801453:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80145a:	f6 c2 01             	test   $0x1,%dl
  80145d:	74 1c                	je     80147b <fd_alloc+0x4a>
  80145f:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801464:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801469:	75 d2                	jne    80143d <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80146b:	8b 45 08             	mov    0x8(%ebp),%eax
  80146e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801474:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801479:	eb 0a                	jmp    801485 <fd_alloc+0x54>
			*fd_store = fd;
  80147b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80147e:	89 01                	mov    %eax,(%ecx)
			return 0;
  801480:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801485:	5d                   	pop    %ebp
  801486:	c3                   	ret    

00801487 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801487:	f3 0f 1e fb          	endbr32 
  80148b:	55                   	push   %ebp
  80148c:	89 e5                	mov    %esp,%ebp
  80148e:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801491:	83 f8 1f             	cmp    $0x1f,%eax
  801494:	77 30                	ja     8014c6 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801496:	c1 e0 0c             	shl    $0xc,%eax
  801499:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80149e:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8014a4:	f6 c2 01             	test   $0x1,%dl
  8014a7:	74 24                	je     8014cd <fd_lookup+0x46>
  8014a9:	89 c2                	mov    %eax,%edx
  8014ab:	c1 ea 0c             	shr    $0xc,%edx
  8014ae:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014b5:	f6 c2 01             	test   $0x1,%dl
  8014b8:	74 1a                	je     8014d4 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014ba:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014bd:	89 02                	mov    %eax,(%edx)
	return 0;
  8014bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014c4:	5d                   	pop    %ebp
  8014c5:	c3                   	ret    
		return -E_INVAL;
  8014c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014cb:	eb f7                	jmp    8014c4 <fd_lookup+0x3d>
		return -E_INVAL;
  8014cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014d2:	eb f0                	jmp    8014c4 <fd_lookup+0x3d>
  8014d4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014d9:	eb e9                	jmp    8014c4 <fd_lookup+0x3d>

008014db <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014db:	f3 0f 1e fb          	endbr32 
  8014df:	55                   	push   %ebp
  8014e0:	89 e5                	mov    %esp,%ebp
  8014e2:	83 ec 08             	sub    $0x8,%esp
  8014e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014e8:	ba ec 2b 80 00       	mov    $0x802bec,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8014ed:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8014f2:	39 08                	cmp    %ecx,(%eax)
  8014f4:	74 33                	je     801529 <dev_lookup+0x4e>
  8014f6:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8014f9:	8b 02                	mov    (%edx),%eax
  8014fb:	85 c0                	test   %eax,%eax
  8014fd:	75 f3                	jne    8014f2 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8014ff:	a1 04 40 80 00       	mov    0x804004,%eax
  801504:	8b 40 48             	mov    0x48(%eax),%eax
  801507:	83 ec 04             	sub    $0x4,%esp
  80150a:	51                   	push   %ecx
  80150b:	50                   	push   %eax
  80150c:	68 70 2b 80 00       	push   $0x802b70
  801511:	e8 76 ee ff ff       	call   80038c <cprintf>
	*dev = 0;
  801516:	8b 45 0c             	mov    0xc(%ebp),%eax
  801519:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80151f:	83 c4 10             	add    $0x10,%esp
  801522:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801527:	c9                   	leave  
  801528:	c3                   	ret    
			*dev = devtab[i];
  801529:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80152c:	89 01                	mov    %eax,(%ecx)
			return 0;
  80152e:	b8 00 00 00 00       	mov    $0x0,%eax
  801533:	eb f2                	jmp    801527 <dev_lookup+0x4c>

00801535 <fd_close>:
{
  801535:	f3 0f 1e fb          	endbr32 
  801539:	55                   	push   %ebp
  80153a:	89 e5                	mov    %esp,%ebp
  80153c:	57                   	push   %edi
  80153d:	56                   	push   %esi
  80153e:	53                   	push   %ebx
  80153f:	83 ec 28             	sub    $0x28,%esp
  801542:	8b 75 08             	mov    0x8(%ebp),%esi
  801545:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801548:	56                   	push   %esi
  801549:	e8 b0 fe ff ff       	call   8013fe <fd2num>
  80154e:	83 c4 08             	add    $0x8,%esp
  801551:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801554:	52                   	push   %edx
  801555:	50                   	push   %eax
  801556:	e8 2c ff ff ff       	call   801487 <fd_lookup>
  80155b:	89 c3                	mov    %eax,%ebx
  80155d:	83 c4 10             	add    $0x10,%esp
  801560:	85 c0                	test   %eax,%eax
  801562:	78 05                	js     801569 <fd_close+0x34>
	    || fd != fd2)
  801564:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801567:	74 16                	je     80157f <fd_close+0x4a>
		return (must_exist ? r : 0);
  801569:	89 f8                	mov    %edi,%eax
  80156b:	84 c0                	test   %al,%al
  80156d:	b8 00 00 00 00       	mov    $0x0,%eax
  801572:	0f 44 d8             	cmove  %eax,%ebx
}
  801575:	89 d8                	mov    %ebx,%eax
  801577:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80157a:	5b                   	pop    %ebx
  80157b:	5e                   	pop    %esi
  80157c:	5f                   	pop    %edi
  80157d:	5d                   	pop    %ebp
  80157e:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80157f:	83 ec 08             	sub    $0x8,%esp
  801582:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801585:	50                   	push   %eax
  801586:	ff 36                	pushl  (%esi)
  801588:	e8 4e ff ff ff       	call   8014db <dev_lookup>
  80158d:	89 c3                	mov    %eax,%ebx
  80158f:	83 c4 10             	add    $0x10,%esp
  801592:	85 c0                	test   %eax,%eax
  801594:	78 1a                	js     8015b0 <fd_close+0x7b>
		if (dev->dev_close)
  801596:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801599:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80159c:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	74 0b                	je     8015b0 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8015a5:	83 ec 0c             	sub    $0xc,%esp
  8015a8:	56                   	push   %esi
  8015a9:	ff d0                	call   *%eax
  8015ab:	89 c3                	mov    %eax,%ebx
  8015ad:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8015b0:	83 ec 08             	sub    $0x8,%esp
  8015b3:	56                   	push   %esi
  8015b4:	6a 00                	push   $0x0
  8015b6:	e8 15 f8 ff ff       	call   800dd0 <sys_page_unmap>
	return r;
  8015bb:	83 c4 10             	add    $0x10,%esp
  8015be:	eb b5                	jmp    801575 <fd_close+0x40>

008015c0 <close>:

int
close(int fdnum)
{
  8015c0:	f3 0f 1e fb          	endbr32 
  8015c4:	55                   	push   %ebp
  8015c5:	89 e5                	mov    %esp,%ebp
  8015c7:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015ca:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015cd:	50                   	push   %eax
  8015ce:	ff 75 08             	pushl  0x8(%ebp)
  8015d1:	e8 b1 fe ff ff       	call   801487 <fd_lookup>
  8015d6:	83 c4 10             	add    $0x10,%esp
  8015d9:	85 c0                	test   %eax,%eax
  8015db:	79 02                	jns    8015df <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8015dd:	c9                   	leave  
  8015de:	c3                   	ret    
		return fd_close(fd, 1);
  8015df:	83 ec 08             	sub    $0x8,%esp
  8015e2:	6a 01                	push   $0x1
  8015e4:	ff 75 f4             	pushl  -0xc(%ebp)
  8015e7:	e8 49 ff ff ff       	call   801535 <fd_close>
  8015ec:	83 c4 10             	add    $0x10,%esp
  8015ef:	eb ec                	jmp    8015dd <close+0x1d>

008015f1 <close_all>:

void
close_all(void)
{
  8015f1:	f3 0f 1e fb          	endbr32 
  8015f5:	55                   	push   %ebp
  8015f6:	89 e5                	mov    %esp,%ebp
  8015f8:	53                   	push   %ebx
  8015f9:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8015fc:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801601:	83 ec 0c             	sub    $0xc,%esp
  801604:	53                   	push   %ebx
  801605:	e8 b6 ff ff ff       	call   8015c0 <close>
	for (i = 0; i < MAXFD; i++)
  80160a:	83 c3 01             	add    $0x1,%ebx
  80160d:	83 c4 10             	add    $0x10,%esp
  801610:	83 fb 20             	cmp    $0x20,%ebx
  801613:	75 ec                	jne    801601 <close_all+0x10>
}
  801615:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801618:	c9                   	leave  
  801619:	c3                   	ret    

0080161a <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80161a:	f3 0f 1e fb          	endbr32 
  80161e:	55                   	push   %ebp
  80161f:	89 e5                	mov    %esp,%ebp
  801621:	57                   	push   %edi
  801622:	56                   	push   %esi
  801623:	53                   	push   %ebx
  801624:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801627:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80162a:	50                   	push   %eax
  80162b:	ff 75 08             	pushl  0x8(%ebp)
  80162e:	e8 54 fe ff ff       	call   801487 <fd_lookup>
  801633:	89 c3                	mov    %eax,%ebx
  801635:	83 c4 10             	add    $0x10,%esp
  801638:	85 c0                	test   %eax,%eax
  80163a:	0f 88 81 00 00 00    	js     8016c1 <dup+0xa7>
		return r;
	close(newfdnum);
  801640:	83 ec 0c             	sub    $0xc,%esp
  801643:	ff 75 0c             	pushl  0xc(%ebp)
  801646:	e8 75 ff ff ff       	call   8015c0 <close>

	newfd = INDEX2FD(newfdnum);
  80164b:	8b 75 0c             	mov    0xc(%ebp),%esi
  80164e:	c1 e6 0c             	shl    $0xc,%esi
  801651:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801657:	83 c4 04             	add    $0x4,%esp
  80165a:	ff 75 e4             	pushl  -0x1c(%ebp)
  80165d:	e8 b0 fd ff ff       	call   801412 <fd2data>
  801662:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801664:	89 34 24             	mov    %esi,(%esp)
  801667:	e8 a6 fd ff ff       	call   801412 <fd2data>
  80166c:	83 c4 10             	add    $0x10,%esp
  80166f:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801671:	89 d8                	mov    %ebx,%eax
  801673:	c1 e8 16             	shr    $0x16,%eax
  801676:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80167d:	a8 01                	test   $0x1,%al
  80167f:	74 11                	je     801692 <dup+0x78>
  801681:	89 d8                	mov    %ebx,%eax
  801683:	c1 e8 0c             	shr    $0xc,%eax
  801686:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80168d:	f6 c2 01             	test   $0x1,%dl
  801690:	75 39                	jne    8016cb <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801692:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801695:	89 d0                	mov    %edx,%eax
  801697:	c1 e8 0c             	shr    $0xc,%eax
  80169a:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016a1:	83 ec 0c             	sub    $0xc,%esp
  8016a4:	25 07 0e 00 00       	and    $0xe07,%eax
  8016a9:	50                   	push   %eax
  8016aa:	56                   	push   %esi
  8016ab:	6a 00                	push   $0x0
  8016ad:	52                   	push   %edx
  8016ae:	6a 00                	push   $0x0
  8016b0:	e8 f1 f6 ff ff       	call   800da6 <sys_page_map>
  8016b5:	89 c3                	mov    %eax,%ebx
  8016b7:	83 c4 20             	add    $0x20,%esp
  8016ba:	85 c0                	test   %eax,%eax
  8016bc:	78 31                	js     8016ef <dup+0xd5>
		goto err;

	return newfdnum;
  8016be:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8016c1:	89 d8                	mov    %ebx,%eax
  8016c3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016c6:	5b                   	pop    %ebx
  8016c7:	5e                   	pop    %esi
  8016c8:	5f                   	pop    %edi
  8016c9:	5d                   	pop    %ebp
  8016ca:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016d2:	83 ec 0c             	sub    $0xc,%esp
  8016d5:	25 07 0e 00 00       	and    $0xe07,%eax
  8016da:	50                   	push   %eax
  8016db:	57                   	push   %edi
  8016dc:	6a 00                	push   $0x0
  8016de:	53                   	push   %ebx
  8016df:	6a 00                	push   $0x0
  8016e1:	e8 c0 f6 ff ff       	call   800da6 <sys_page_map>
  8016e6:	89 c3                	mov    %eax,%ebx
  8016e8:	83 c4 20             	add    $0x20,%esp
  8016eb:	85 c0                	test   %eax,%eax
  8016ed:	79 a3                	jns    801692 <dup+0x78>
	sys_page_unmap(0, newfd);
  8016ef:	83 ec 08             	sub    $0x8,%esp
  8016f2:	56                   	push   %esi
  8016f3:	6a 00                	push   $0x0
  8016f5:	e8 d6 f6 ff ff       	call   800dd0 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8016fa:	83 c4 08             	add    $0x8,%esp
  8016fd:	57                   	push   %edi
  8016fe:	6a 00                	push   $0x0
  801700:	e8 cb f6 ff ff       	call   800dd0 <sys_page_unmap>
	return r;
  801705:	83 c4 10             	add    $0x10,%esp
  801708:	eb b7                	jmp    8016c1 <dup+0xa7>

0080170a <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80170a:	f3 0f 1e fb          	endbr32 
  80170e:	55                   	push   %ebp
  80170f:	89 e5                	mov    %esp,%ebp
  801711:	53                   	push   %ebx
  801712:	83 ec 1c             	sub    $0x1c,%esp
  801715:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801718:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80171b:	50                   	push   %eax
  80171c:	53                   	push   %ebx
  80171d:	e8 65 fd ff ff       	call   801487 <fd_lookup>
  801722:	83 c4 10             	add    $0x10,%esp
  801725:	85 c0                	test   %eax,%eax
  801727:	78 3f                	js     801768 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801729:	83 ec 08             	sub    $0x8,%esp
  80172c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80172f:	50                   	push   %eax
  801730:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801733:	ff 30                	pushl  (%eax)
  801735:	e8 a1 fd ff ff       	call   8014db <dev_lookup>
  80173a:	83 c4 10             	add    $0x10,%esp
  80173d:	85 c0                	test   %eax,%eax
  80173f:	78 27                	js     801768 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801741:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801744:	8b 42 08             	mov    0x8(%edx),%eax
  801747:	83 e0 03             	and    $0x3,%eax
  80174a:	83 f8 01             	cmp    $0x1,%eax
  80174d:	74 1e                	je     80176d <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80174f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801752:	8b 40 08             	mov    0x8(%eax),%eax
  801755:	85 c0                	test   %eax,%eax
  801757:	74 35                	je     80178e <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801759:	83 ec 04             	sub    $0x4,%esp
  80175c:	ff 75 10             	pushl  0x10(%ebp)
  80175f:	ff 75 0c             	pushl  0xc(%ebp)
  801762:	52                   	push   %edx
  801763:	ff d0                	call   *%eax
  801765:	83 c4 10             	add    $0x10,%esp
}
  801768:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80176b:	c9                   	leave  
  80176c:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80176d:	a1 04 40 80 00       	mov    0x804004,%eax
  801772:	8b 40 48             	mov    0x48(%eax),%eax
  801775:	83 ec 04             	sub    $0x4,%esp
  801778:	53                   	push   %ebx
  801779:	50                   	push   %eax
  80177a:	68 b1 2b 80 00       	push   $0x802bb1
  80177f:	e8 08 ec ff ff       	call   80038c <cprintf>
		return -E_INVAL;
  801784:	83 c4 10             	add    $0x10,%esp
  801787:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80178c:	eb da                	jmp    801768 <read+0x5e>
		return -E_NOT_SUPP;
  80178e:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801793:	eb d3                	jmp    801768 <read+0x5e>

00801795 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801795:	f3 0f 1e fb          	endbr32 
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	57                   	push   %edi
  80179d:	56                   	push   %esi
  80179e:	53                   	push   %ebx
  80179f:	83 ec 0c             	sub    $0xc,%esp
  8017a2:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017a5:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017a8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017ad:	eb 02                	jmp    8017b1 <readn+0x1c>
  8017af:	01 c3                	add    %eax,%ebx
  8017b1:	39 f3                	cmp    %esi,%ebx
  8017b3:	73 21                	jae    8017d6 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017b5:	83 ec 04             	sub    $0x4,%esp
  8017b8:	89 f0                	mov    %esi,%eax
  8017ba:	29 d8                	sub    %ebx,%eax
  8017bc:	50                   	push   %eax
  8017bd:	89 d8                	mov    %ebx,%eax
  8017bf:	03 45 0c             	add    0xc(%ebp),%eax
  8017c2:	50                   	push   %eax
  8017c3:	57                   	push   %edi
  8017c4:	e8 41 ff ff ff       	call   80170a <read>
		if (m < 0)
  8017c9:	83 c4 10             	add    $0x10,%esp
  8017cc:	85 c0                	test   %eax,%eax
  8017ce:	78 04                	js     8017d4 <readn+0x3f>
			return m;
		if (m == 0)
  8017d0:	75 dd                	jne    8017af <readn+0x1a>
  8017d2:	eb 02                	jmp    8017d6 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017d4:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8017d6:	89 d8                	mov    %ebx,%eax
  8017d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017db:	5b                   	pop    %ebx
  8017dc:	5e                   	pop    %esi
  8017dd:	5f                   	pop    %edi
  8017de:	5d                   	pop    %ebp
  8017df:	c3                   	ret    

008017e0 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017e0:	f3 0f 1e fb          	endbr32 
  8017e4:	55                   	push   %ebp
  8017e5:	89 e5                	mov    %esp,%ebp
  8017e7:	53                   	push   %ebx
  8017e8:	83 ec 1c             	sub    $0x1c,%esp
  8017eb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017ee:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017f1:	50                   	push   %eax
  8017f2:	53                   	push   %ebx
  8017f3:	e8 8f fc ff ff       	call   801487 <fd_lookup>
  8017f8:	83 c4 10             	add    $0x10,%esp
  8017fb:	85 c0                	test   %eax,%eax
  8017fd:	78 3a                	js     801839 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017ff:	83 ec 08             	sub    $0x8,%esp
  801802:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801805:	50                   	push   %eax
  801806:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801809:	ff 30                	pushl  (%eax)
  80180b:	e8 cb fc ff ff       	call   8014db <dev_lookup>
  801810:	83 c4 10             	add    $0x10,%esp
  801813:	85 c0                	test   %eax,%eax
  801815:	78 22                	js     801839 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801817:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80181a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80181e:	74 1e                	je     80183e <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801820:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801823:	8b 52 0c             	mov    0xc(%edx),%edx
  801826:	85 d2                	test   %edx,%edx
  801828:	74 35                	je     80185f <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80182a:	83 ec 04             	sub    $0x4,%esp
  80182d:	ff 75 10             	pushl  0x10(%ebp)
  801830:	ff 75 0c             	pushl  0xc(%ebp)
  801833:	50                   	push   %eax
  801834:	ff d2                	call   *%edx
  801836:	83 c4 10             	add    $0x10,%esp
}
  801839:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80183c:	c9                   	leave  
  80183d:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80183e:	a1 04 40 80 00       	mov    0x804004,%eax
  801843:	8b 40 48             	mov    0x48(%eax),%eax
  801846:	83 ec 04             	sub    $0x4,%esp
  801849:	53                   	push   %ebx
  80184a:	50                   	push   %eax
  80184b:	68 cd 2b 80 00       	push   $0x802bcd
  801850:	e8 37 eb ff ff       	call   80038c <cprintf>
		return -E_INVAL;
  801855:	83 c4 10             	add    $0x10,%esp
  801858:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80185d:	eb da                	jmp    801839 <write+0x59>
		return -E_NOT_SUPP;
  80185f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801864:	eb d3                	jmp    801839 <write+0x59>

00801866 <seek>:

int
seek(int fdnum, off_t offset)
{
  801866:	f3 0f 1e fb          	endbr32 
  80186a:	55                   	push   %ebp
  80186b:	89 e5                	mov    %esp,%ebp
  80186d:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801870:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801873:	50                   	push   %eax
  801874:	ff 75 08             	pushl  0x8(%ebp)
  801877:	e8 0b fc ff ff       	call   801487 <fd_lookup>
  80187c:	83 c4 10             	add    $0x10,%esp
  80187f:	85 c0                	test   %eax,%eax
  801881:	78 0e                	js     801891 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801883:	8b 55 0c             	mov    0xc(%ebp),%edx
  801886:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801889:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80188c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801891:	c9                   	leave  
  801892:	c3                   	ret    

00801893 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801893:	f3 0f 1e fb          	endbr32 
  801897:	55                   	push   %ebp
  801898:	89 e5                	mov    %esp,%ebp
  80189a:	53                   	push   %ebx
  80189b:	83 ec 1c             	sub    $0x1c,%esp
  80189e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018a1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018a4:	50                   	push   %eax
  8018a5:	53                   	push   %ebx
  8018a6:	e8 dc fb ff ff       	call   801487 <fd_lookup>
  8018ab:	83 c4 10             	add    $0x10,%esp
  8018ae:	85 c0                	test   %eax,%eax
  8018b0:	78 37                	js     8018e9 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018b2:	83 ec 08             	sub    $0x8,%esp
  8018b5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b8:	50                   	push   %eax
  8018b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018bc:	ff 30                	pushl  (%eax)
  8018be:	e8 18 fc ff ff       	call   8014db <dev_lookup>
  8018c3:	83 c4 10             	add    $0x10,%esp
  8018c6:	85 c0                	test   %eax,%eax
  8018c8:	78 1f                	js     8018e9 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018cd:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018d1:	74 1b                	je     8018ee <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8018d3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018d6:	8b 52 18             	mov    0x18(%edx),%edx
  8018d9:	85 d2                	test   %edx,%edx
  8018db:	74 32                	je     80190f <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018dd:	83 ec 08             	sub    $0x8,%esp
  8018e0:	ff 75 0c             	pushl  0xc(%ebp)
  8018e3:	50                   	push   %eax
  8018e4:	ff d2                	call   *%edx
  8018e6:	83 c4 10             	add    $0x10,%esp
}
  8018e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018ec:	c9                   	leave  
  8018ed:	c3                   	ret    
			thisenv->env_id, fdnum);
  8018ee:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8018f3:	8b 40 48             	mov    0x48(%eax),%eax
  8018f6:	83 ec 04             	sub    $0x4,%esp
  8018f9:	53                   	push   %ebx
  8018fa:	50                   	push   %eax
  8018fb:	68 90 2b 80 00       	push   $0x802b90
  801900:	e8 87 ea ff ff       	call   80038c <cprintf>
		return -E_INVAL;
  801905:	83 c4 10             	add    $0x10,%esp
  801908:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80190d:	eb da                	jmp    8018e9 <ftruncate+0x56>
		return -E_NOT_SUPP;
  80190f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801914:	eb d3                	jmp    8018e9 <ftruncate+0x56>

00801916 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801916:	f3 0f 1e fb          	endbr32 
  80191a:	55                   	push   %ebp
  80191b:	89 e5                	mov    %esp,%ebp
  80191d:	53                   	push   %ebx
  80191e:	83 ec 1c             	sub    $0x1c,%esp
  801921:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801924:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801927:	50                   	push   %eax
  801928:	ff 75 08             	pushl  0x8(%ebp)
  80192b:	e8 57 fb ff ff       	call   801487 <fd_lookup>
  801930:	83 c4 10             	add    $0x10,%esp
  801933:	85 c0                	test   %eax,%eax
  801935:	78 4b                	js     801982 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801937:	83 ec 08             	sub    $0x8,%esp
  80193a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80193d:	50                   	push   %eax
  80193e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801941:	ff 30                	pushl  (%eax)
  801943:	e8 93 fb ff ff       	call   8014db <dev_lookup>
  801948:	83 c4 10             	add    $0x10,%esp
  80194b:	85 c0                	test   %eax,%eax
  80194d:	78 33                	js     801982 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80194f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801952:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801956:	74 2f                	je     801987 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801958:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80195b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801962:	00 00 00 
	stat->st_isdir = 0;
  801965:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80196c:	00 00 00 
	stat->st_dev = dev;
  80196f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801975:	83 ec 08             	sub    $0x8,%esp
  801978:	53                   	push   %ebx
  801979:	ff 75 f0             	pushl  -0x10(%ebp)
  80197c:	ff 50 14             	call   *0x14(%eax)
  80197f:	83 c4 10             	add    $0x10,%esp
}
  801982:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801985:	c9                   	leave  
  801986:	c3                   	ret    
		return -E_NOT_SUPP;
  801987:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80198c:	eb f4                	jmp    801982 <fstat+0x6c>

0080198e <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80198e:	f3 0f 1e fb          	endbr32 
  801992:	55                   	push   %ebp
  801993:	89 e5                	mov    %esp,%ebp
  801995:	56                   	push   %esi
  801996:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801997:	83 ec 08             	sub    $0x8,%esp
  80199a:	6a 00                	push   $0x0
  80199c:	ff 75 08             	pushl  0x8(%ebp)
  80199f:	e8 fb 01 00 00       	call   801b9f <open>
  8019a4:	89 c3                	mov    %eax,%ebx
  8019a6:	83 c4 10             	add    $0x10,%esp
  8019a9:	85 c0                	test   %eax,%eax
  8019ab:	78 1b                	js     8019c8 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8019ad:	83 ec 08             	sub    $0x8,%esp
  8019b0:	ff 75 0c             	pushl  0xc(%ebp)
  8019b3:	50                   	push   %eax
  8019b4:	e8 5d ff ff ff       	call   801916 <fstat>
  8019b9:	89 c6                	mov    %eax,%esi
	close(fd);
  8019bb:	89 1c 24             	mov    %ebx,(%esp)
  8019be:	e8 fd fb ff ff       	call   8015c0 <close>
	return r;
  8019c3:	83 c4 10             	add    $0x10,%esp
  8019c6:	89 f3                	mov    %esi,%ebx
}
  8019c8:	89 d8                	mov    %ebx,%eax
  8019ca:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019cd:	5b                   	pop    %ebx
  8019ce:	5e                   	pop    %esi
  8019cf:	5d                   	pop    %ebp
  8019d0:	c3                   	ret    

008019d1 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019d1:	55                   	push   %ebp
  8019d2:	89 e5                	mov    %esp,%ebp
  8019d4:	56                   	push   %esi
  8019d5:	53                   	push   %ebx
  8019d6:	89 c6                	mov    %eax,%esi
  8019d8:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019da:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019e1:	74 27                	je     801a0a <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8019e3:	6a 07                	push   $0x7
  8019e5:	68 00 50 80 00       	push   $0x805000
  8019ea:	56                   	push   %esi
  8019eb:	ff 35 00 40 80 00    	pushl  0x804000
  8019f1:	e8 42 08 00 00       	call   802238 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8019f6:	83 c4 0c             	add    $0xc,%esp
  8019f9:	6a 00                	push   $0x0
  8019fb:	53                   	push   %ebx
  8019fc:	6a 00                	push   $0x0
  8019fe:	e8 c7 07 00 00       	call   8021ca <ipc_recv>
}
  801a03:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a06:	5b                   	pop    %ebx
  801a07:	5e                   	pop    %esi
  801a08:	5d                   	pop    %ebp
  801a09:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a0a:	83 ec 0c             	sub    $0xc,%esp
  801a0d:	6a 01                	push   $0x1
  801a0f:	e8 89 08 00 00       	call   80229d <ipc_find_env>
  801a14:	a3 00 40 80 00       	mov    %eax,0x804000
  801a19:	83 c4 10             	add    $0x10,%esp
  801a1c:	eb c5                	jmp    8019e3 <fsipc+0x12>

00801a1e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a1e:	f3 0f 1e fb          	endbr32 
  801a22:	55                   	push   %ebp
  801a23:	89 e5                	mov    %esp,%ebp
  801a25:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a28:	8b 45 08             	mov    0x8(%ebp),%eax
  801a2b:	8b 40 0c             	mov    0xc(%eax),%eax
  801a2e:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a33:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a36:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a3b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a40:	b8 02 00 00 00       	mov    $0x2,%eax
  801a45:	e8 87 ff ff ff       	call   8019d1 <fsipc>
}
  801a4a:	c9                   	leave  
  801a4b:	c3                   	ret    

00801a4c <devfile_flush>:
{
  801a4c:	f3 0f 1e fb          	endbr32 
  801a50:	55                   	push   %ebp
  801a51:	89 e5                	mov    %esp,%ebp
  801a53:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a56:	8b 45 08             	mov    0x8(%ebp),%eax
  801a59:	8b 40 0c             	mov    0xc(%eax),%eax
  801a5c:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a61:	ba 00 00 00 00       	mov    $0x0,%edx
  801a66:	b8 06 00 00 00       	mov    $0x6,%eax
  801a6b:	e8 61 ff ff ff       	call   8019d1 <fsipc>
}
  801a70:	c9                   	leave  
  801a71:	c3                   	ret    

00801a72 <devfile_stat>:
{
  801a72:	f3 0f 1e fb          	endbr32 
  801a76:	55                   	push   %ebp
  801a77:	89 e5                	mov    %esp,%ebp
  801a79:	53                   	push   %ebx
  801a7a:	83 ec 04             	sub    $0x4,%esp
  801a7d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a80:	8b 45 08             	mov    0x8(%ebp),%eax
  801a83:	8b 40 0c             	mov    0xc(%eax),%eax
  801a86:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801a8b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a90:	b8 05 00 00 00       	mov    $0x5,%eax
  801a95:	e8 37 ff ff ff       	call   8019d1 <fsipc>
  801a9a:	85 c0                	test   %eax,%eax
  801a9c:	78 2c                	js     801aca <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801a9e:	83 ec 08             	sub    $0x8,%esp
  801aa1:	68 00 50 80 00       	push   $0x805000
  801aa6:	53                   	push   %ebx
  801aa7:	e8 4a ee ff ff       	call   8008f6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801aac:	a1 80 50 80 00       	mov    0x805080,%eax
  801ab1:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ab7:	a1 84 50 80 00       	mov    0x805084,%eax
  801abc:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801ac2:	83 c4 10             	add    $0x10,%esp
  801ac5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801aca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801acd:	c9                   	leave  
  801ace:	c3                   	ret    

00801acf <devfile_write>:
{
  801acf:	f3 0f 1e fb          	endbr32 
  801ad3:	55                   	push   %ebp
  801ad4:	89 e5                	mov    %esp,%ebp
  801ad6:	83 ec 0c             	sub    $0xc,%esp
  801ad9:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801adc:	8b 55 08             	mov    0x8(%ebp),%edx
  801adf:	8b 52 0c             	mov    0xc(%edx),%edx
  801ae2:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801ae8:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801aed:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801af2:	0f 47 c2             	cmova  %edx,%eax
  801af5:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801afa:	50                   	push   %eax
  801afb:	ff 75 0c             	pushl  0xc(%ebp)
  801afe:	68 08 50 80 00       	push   $0x805008
  801b03:	e8 a6 ef ff ff       	call   800aae <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801b08:	ba 00 00 00 00       	mov    $0x0,%edx
  801b0d:	b8 04 00 00 00       	mov    $0x4,%eax
  801b12:	e8 ba fe ff ff       	call   8019d1 <fsipc>
}
  801b17:	c9                   	leave  
  801b18:	c3                   	ret    

00801b19 <devfile_read>:
{
  801b19:	f3 0f 1e fb          	endbr32 
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	56                   	push   %esi
  801b21:	53                   	push   %ebx
  801b22:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b25:	8b 45 08             	mov    0x8(%ebp),%eax
  801b28:	8b 40 0c             	mov    0xc(%eax),%eax
  801b2b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b30:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b36:	ba 00 00 00 00       	mov    $0x0,%edx
  801b3b:	b8 03 00 00 00       	mov    $0x3,%eax
  801b40:	e8 8c fe ff ff       	call   8019d1 <fsipc>
  801b45:	89 c3                	mov    %eax,%ebx
  801b47:	85 c0                	test   %eax,%eax
  801b49:	78 1f                	js     801b6a <devfile_read+0x51>
	assert(r <= n);
  801b4b:	39 f0                	cmp    %esi,%eax
  801b4d:	77 24                	ja     801b73 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801b4f:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b54:	7f 33                	jg     801b89 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b56:	83 ec 04             	sub    $0x4,%esp
  801b59:	50                   	push   %eax
  801b5a:	68 00 50 80 00       	push   $0x805000
  801b5f:	ff 75 0c             	pushl  0xc(%ebp)
  801b62:	e8 47 ef ff ff       	call   800aae <memmove>
	return r;
  801b67:	83 c4 10             	add    $0x10,%esp
}
  801b6a:	89 d8                	mov    %ebx,%eax
  801b6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b6f:	5b                   	pop    %ebx
  801b70:	5e                   	pop    %esi
  801b71:	5d                   	pop    %ebp
  801b72:	c3                   	ret    
	assert(r <= n);
  801b73:	68 fc 2b 80 00       	push   $0x802bfc
  801b78:	68 03 2c 80 00       	push   $0x802c03
  801b7d:	6a 7c                	push   $0x7c
  801b7f:	68 18 2c 80 00       	push   $0x802c18
  801b84:	e8 1c e7 ff ff       	call   8002a5 <_panic>
	assert(r <= PGSIZE);
  801b89:	68 23 2c 80 00       	push   $0x802c23
  801b8e:	68 03 2c 80 00       	push   $0x802c03
  801b93:	6a 7d                	push   $0x7d
  801b95:	68 18 2c 80 00       	push   $0x802c18
  801b9a:	e8 06 e7 ff ff       	call   8002a5 <_panic>

00801b9f <open>:
{
  801b9f:	f3 0f 1e fb          	endbr32 
  801ba3:	55                   	push   %ebp
  801ba4:	89 e5                	mov    %esp,%ebp
  801ba6:	56                   	push   %esi
  801ba7:	53                   	push   %ebx
  801ba8:	83 ec 1c             	sub    $0x1c,%esp
  801bab:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801bae:	56                   	push   %esi
  801baf:	e8 ff ec ff ff       	call   8008b3 <strlen>
  801bb4:	83 c4 10             	add    $0x10,%esp
  801bb7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bbc:	7f 6c                	jg     801c2a <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801bbe:	83 ec 0c             	sub    $0xc,%esp
  801bc1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bc4:	50                   	push   %eax
  801bc5:	e8 67 f8 ff ff       	call   801431 <fd_alloc>
  801bca:	89 c3                	mov    %eax,%ebx
  801bcc:	83 c4 10             	add    $0x10,%esp
  801bcf:	85 c0                	test   %eax,%eax
  801bd1:	78 3c                	js     801c0f <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801bd3:	83 ec 08             	sub    $0x8,%esp
  801bd6:	56                   	push   %esi
  801bd7:	68 00 50 80 00       	push   $0x805000
  801bdc:	e8 15 ed ff ff       	call   8008f6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801be1:	8b 45 0c             	mov    0xc(%ebp),%eax
  801be4:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801be9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801bec:	b8 01 00 00 00       	mov    $0x1,%eax
  801bf1:	e8 db fd ff ff       	call   8019d1 <fsipc>
  801bf6:	89 c3                	mov    %eax,%ebx
  801bf8:	83 c4 10             	add    $0x10,%esp
  801bfb:	85 c0                	test   %eax,%eax
  801bfd:	78 19                	js     801c18 <open+0x79>
	return fd2num(fd);
  801bff:	83 ec 0c             	sub    $0xc,%esp
  801c02:	ff 75 f4             	pushl  -0xc(%ebp)
  801c05:	e8 f4 f7 ff ff       	call   8013fe <fd2num>
  801c0a:	89 c3                	mov    %eax,%ebx
  801c0c:	83 c4 10             	add    $0x10,%esp
}
  801c0f:	89 d8                	mov    %ebx,%eax
  801c11:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c14:	5b                   	pop    %ebx
  801c15:	5e                   	pop    %esi
  801c16:	5d                   	pop    %ebp
  801c17:	c3                   	ret    
		fd_close(fd, 0);
  801c18:	83 ec 08             	sub    $0x8,%esp
  801c1b:	6a 00                	push   $0x0
  801c1d:	ff 75 f4             	pushl  -0xc(%ebp)
  801c20:	e8 10 f9 ff ff       	call   801535 <fd_close>
		return r;
  801c25:	83 c4 10             	add    $0x10,%esp
  801c28:	eb e5                	jmp    801c0f <open+0x70>
		return -E_BAD_PATH;
  801c2a:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801c2f:	eb de                	jmp    801c0f <open+0x70>

00801c31 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c31:	f3 0f 1e fb          	endbr32 
  801c35:	55                   	push   %ebp
  801c36:	89 e5                	mov    %esp,%ebp
  801c38:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c3b:	ba 00 00 00 00       	mov    $0x0,%edx
  801c40:	b8 08 00 00 00       	mov    $0x8,%eax
  801c45:	e8 87 fd ff ff       	call   8019d1 <fsipc>
}
  801c4a:	c9                   	leave  
  801c4b:	c3                   	ret    

00801c4c <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c4c:	f3 0f 1e fb          	endbr32 
  801c50:	55                   	push   %ebp
  801c51:	89 e5                	mov    %esp,%ebp
  801c53:	56                   	push   %esi
  801c54:	53                   	push   %ebx
  801c55:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c58:	83 ec 0c             	sub    $0xc,%esp
  801c5b:	ff 75 08             	pushl  0x8(%ebp)
  801c5e:	e8 af f7 ff ff       	call   801412 <fd2data>
  801c63:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c65:	83 c4 08             	add    $0x8,%esp
  801c68:	68 2f 2c 80 00       	push   $0x802c2f
  801c6d:	53                   	push   %ebx
  801c6e:	e8 83 ec ff ff       	call   8008f6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c73:	8b 46 04             	mov    0x4(%esi),%eax
  801c76:	2b 06                	sub    (%esi),%eax
  801c78:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c7e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801c85:	00 00 00 
	stat->st_dev = &devpipe;
  801c88:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  801c8f:	30 80 00 
	return 0;
}
  801c92:	b8 00 00 00 00       	mov    $0x0,%eax
  801c97:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c9a:	5b                   	pop    %ebx
  801c9b:	5e                   	pop    %esi
  801c9c:	5d                   	pop    %ebp
  801c9d:	c3                   	ret    

00801c9e <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801c9e:	f3 0f 1e fb          	endbr32 
  801ca2:	55                   	push   %ebp
  801ca3:	89 e5                	mov    %esp,%ebp
  801ca5:	53                   	push   %ebx
  801ca6:	83 ec 0c             	sub    $0xc,%esp
  801ca9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cac:	53                   	push   %ebx
  801cad:	6a 00                	push   $0x0
  801caf:	e8 1c f1 ff ff       	call   800dd0 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cb4:	89 1c 24             	mov    %ebx,(%esp)
  801cb7:	e8 56 f7 ff ff       	call   801412 <fd2data>
  801cbc:	83 c4 08             	add    $0x8,%esp
  801cbf:	50                   	push   %eax
  801cc0:	6a 00                	push   $0x0
  801cc2:	e8 09 f1 ff ff       	call   800dd0 <sys_page_unmap>
}
  801cc7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801cca:	c9                   	leave  
  801ccb:	c3                   	ret    

00801ccc <_pipeisclosed>:
{
  801ccc:	55                   	push   %ebp
  801ccd:	89 e5                	mov    %esp,%ebp
  801ccf:	57                   	push   %edi
  801cd0:	56                   	push   %esi
  801cd1:	53                   	push   %ebx
  801cd2:	83 ec 1c             	sub    $0x1c,%esp
  801cd5:	89 c7                	mov    %eax,%edi
  801cd7:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801cd9:	a1 04 40 80 00       	mov    0x804004,%eax
  801cde:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801ce1:	83 ec 0c             	sub    $0xc,%esp
  801ce4:	57                   	push   %edi
  801ce5:	e8 f0 05 00 00       	call   8022da <pageref>
  801cea:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801ced:	89 34 24             	mov    %esi,(%esp)
  801cf0:	e8 e5 05 00 00       	call   8022da <pageref>
		nn = thisenv->env_runs;
  801cf5:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801cfb:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801cfe:	83 c4 10             	add    $0x10,%esp
  801d01:	39 cb                	cmp    %ecx,%ebx
  801d03:	74 1b                	je     801d20 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801d05:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d08:	75 cf                	jne    801cd9 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d0a:	8b 42 58             	mov    0x58(%edx),%eax
  801d0d:	6a 01                	push   $0x1
  801d0f:	50                   	push   %eax
  801d10:	53                   	push   %ebx
  801d11:	68 36 2c 80 00       	push   $0x802c36
  801d16:	e8 71 e6 ff ff       	call   80038c <cprintf>
  801d1b:	83 c4 10             	add    $0x10,%esp
  801d1e:	eb b9                	jmp    801cd9 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801d20:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d23:	0f 94 c0             	sete   %al
  801d26:	0f b6 c0             	movzbl %al,%eax
}
  801d29:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d2c:	5b                   	pop    %ebx
  801d2d:	5e                   	pop    %esi
  801d2e:	5f                   	pop    %edi
  801d2f:	5d                   	pop    %ebp
  801d30:	c3                   	ret    

00801d31 <devpipe_write>:
{
  801d31:	f3 0f 1e fb          	endbr32 
  801d35:	55                   	push   %ebp
  801d36:	89 e5                	mov    %esp,%ebp
  801d38:	57                   	push   %edi
  801d39:	56                   	push   %esi
  801d3a:	53                   	push   %ebx
  801d3b:	83 ec 28             	sub    $0x28,%esp
  801d3e:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801d41:	56                   	push   %esi
  801d42:	e8 cb f6 ff ff       	call   801412 <fd2data>
  801d47:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d49:	83 c4 10             	add    $0x10,%esp
  801d4c:	bf 00 00 00 00       	mov    $0x0,%edi
  801d51:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d54:	74 4f                	je     801da5 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d56:	8b 43 04             	mov    0x4(%ebx),%eax
  801d59:	8b 0b                	mov    (%ebx),%ecx
  801d5b:	8d 51 20             	lea    0x20(%ecx),%edx
  801d5e:	39 d0                	cmp    %edx,%eax
  801d60:	72 14                	jb     801d76 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801d62:	89 da                	mov    %ebx,%edx
  801d64:	89 f0                	mov    %esi,%eax
  801d66:	e8 61 ff ff ff       	call   801ccc <_pipeisclosed>
  801d6b:	85 c0                	test   %eax,%eax
  801d6d:	75 3b                	jne    801daa <devpipe_write+0x79>
			sys_yield();
  801d6f:	e8 df ef ff ff       	call   800d53 <sys_yield>
  801d74:	eb e0                	jmp    801d56 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d76:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d79:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d7d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d80:	89 c2                	mov    %eax,%edx
  801d82:	c1 fa 1f             	sar    $0x1f,%edx
  801d85:	89 d1                	mov    %edx,%ecx
  801d87:	c1 e9 1b             	shr    $0x1b,%ecx
  801d8a:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801d8d:	83 e2 1f             	and    $0x1f,%edx
  801d90:	29 ca                	sub    %ecx,%edx
  801d92:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801d96:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801d9a:	83 c0 01             	add    $0x1,%eax
  801d9d:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801da0:	83 c7 01             	add    $0x1,%edi
  801da3:	eb ac                	jmp    801d51 <devpipe_write+0x20>
	return i;
  801da5:	8b 45 10             	mov    0x10(%ebp),%eax
  801da8:	eb 05                	jmp    801daf <devpipe_write+0x7e>
				return 0;
  801daa:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801daf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801db2:	5b                   	pop    %ebx
  801db3:	5e                   	pop    %esi
  801db4:	5f                   	pop    %edi
  801db5:	5d                   	pop    %ebp
  801db6:	c3                   	ret    

00801db7 <devpipe_read>:
{
  801db7:	f3 0f 1e fb          	endbr32 
  801dbb:	55                   	push   %ebp
  801dbc:	89 e5                	mov    %esp,%ebp
  801dbe:	57                   	push   %edi
  801dbf:	56                   	push   %esi
  801dc0:	53                   	push   %ebx
  801dc1:	83 ec 18             	sub    $0x18,%esp
  801dc4:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801dc7:	57                   	push   %edi
  801dc8:	e8 45 f6 ff ff       	call   801412 <fd2data>
  801dcd:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801dcf:	83 c4 10             	add    $0x10,%esp
  801dd2:	be 00 00 00 00       	mov    $0x0,%esi
  801dd7:	3b 75 10             	cmp    0x10(%ebp),%esi
  801dda:	75 14                	jne    801df0 <devpipe_read+0x39>
	return i;
  801ddc:	8b 45 10             	mov    0x10(%ebp),%eax
  801ddf:	eb 02                	jmp    801de3 <devpipe_read+0x2c>
				return i;
  801de1:	89 f0                	mov    %esi,%eax
}
  801de3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801de6:	5b                   	pop    %ebx
  801de7:	5e                   	pop    %esi
  801de8:	5f                   	pop    %edi
  801de9:	5d                   	pop    %ebp
  801dea:	c3                   	ret    
			sys_yield();
  801deb:	e8 63 ef ff ff       	call   800d53 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801df0:	8b 03                	mov    (%ebx),%eax
  801df2:	3b 43 04             	cmp    0x4(%ebx),%eax
  801df5:	75 18                	jne    801e0f <devpipe_read+0x58>
			if (i > 0)
  801df7:	85 f6                	test   %esi,%esi
  801df9:	75 e6                	jne    801de1 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801dfb:	89 da                	mov    %ebx,%edx
  801dfd:	89 f8                	mov    %edi,%eax
  801dff:	e8 c8 fe ff ff       	call   801ccc <_pipeisclosed>
  801e04:	85 c0                	test   %eax,%eax
  801e06:	74 e3                	je     801deb <devpipe_read+0x34>
				return 0;
  801e08:	b8 00 00 00 00       	mov    $0x0,%eax
  801e0d:	eb d4                	jmp    801de3 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e0f:	99                   	cltd   
  801e10:	c1 ea 1b             	shr    $0x1b,%edx
  801e13:	01 d0                	add    %edx,%eax
  801e15:	83 e0 1f             	and    $0x1f,%eax
  801e18:	29 d0                	sub    %edx,%eax
  801e1a:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e22:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e25:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801e28:	83 c6 01             	add    $0x1,%esi
  801e2b:	eb aa                	jmp    801dd7 <devpipe_read+0x20>

00801e2d <pipe>:
{
  801e2d:	f3 0f 1e fb          	endbr32 
  801e31:	55                   	push   %ebp
  801e32:	89 e5                	mov    %esp,%ebp
  801e34:	56                   	push   %esi
  801e35:	53                   	push   %ebx
  801e36:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801e39:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e3c:	50                   	push   %eax
  801e3d:	e8 ef f5 ff ff       	call   801431 <fd_alloc>
  801e42:	89 c3                	mov    %eax,%ebx
  801e44:	83 c4 10             	add    $0x10,%esp
  801e47:	85 c0                	test   %eax,%eax
  801e49:	0f 88 23 01 00 00    	js     801f72 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e4f:	83 ec 04             	sub    $0x4,%esp
  801e52:	68 07 04 00 00       	push   $0x407
  801e57:	ff 75 f4             	pushl  -0xc(%ebp)
  801e5a:	6a 00                	push   $0x0
  801e5c:	e8 1d ef ff ff       	call   800d7e <sys_page_alloc>
  801e61:	89 c3                	mov    %eax,%ebx
  801e63:	83 c4 10             	add    $0x10,%esp
  801e66:	85 c0                	test   %eax,%eax
  801e68:	0f 88 04 01 00 00    	js     801f72 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801e6e:	83 ec 0c             	sub    $0xc,%esp
  801e71:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e74:	50                   	push   %eax
  801e75:	e8 b7 f5 ff ff       	call   801431 <fd_alloc>
  801e7a:	89 c3                	mov    %eax,%ebx
  801e7c:	83 c4 10             	add    $0x10,%esp
  801e7f:	85 c0                	test   %eax,%eax
  801e81:	0f 88 db 00 00 00    	js     801f62 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e87:	83 ec 04             	sub    $0x4,%esp
  801e8a:	68 07 04 00 00       	push   $0x407
  801e8f:	ff 75 f0             	pushl  -0x10(%ebp)
  801e92:	6a 00                	push   $0x0
  801e94:	e8 e5 ee ff ff       	call   800d7e <sys_page_alloc>
  801e99:	89 c3                	mov    %eax,%ebx
  801e9b:	83 c4 10             	add    $0x10,%esp
  801e9e:	85 c0                	test   %eax,%eax
  801ea0:	0f 88 bc 00 00 00    	js     801f62 <pipe+0x135>
	va = fd2data(fd0);
  801ea6:	83 ec 0c             	sub    $0xc,%esp
  801ea9:	ff 75 f4             	pushl  -0xc(%ebp)
  801eac:	e8 61 f5 ff ff       	call   801412 <fd2data>
  801eb1:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eb3:	83 c4 0c             	add    $0xc,%esp
  801eb6:	68 07 04 00 00       	push   $0x407
  801ebb:	50                   	push   %eax
  801ebc:	6a 00                	push   $0x0
  801ebe:	e8 bb ee ff ff       	call   800d7e <sys_page_alloc>
  801ec3:	89 c3                	mov    %eax,%ebx
  801ec5:	83 c4 10             	add    $0x10,%esp
  801ec8:	85 c0                	test   %eax,%eax
  801eca:	0f 88 82 00 00 00    	js     801f52 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ed0:	83 ec 0c             	sub    $0xc,%esp
  801ed3:	ff 75 f0             	pushl  -0x10(%ebp)
  801ed6:	e8 37 f5 ff ff       	call   801412 <fd2data>
  801edb:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801ee2:	50                   	push   %eax
  801ee3:	6a 00                	push   $0x0
  801ee5:	56                   	push   %esi
  801ee6:	6a 00                	push   $0x0
  801ee8:	e8 b9 ee ff ff       	call   800da6 <sys_page_map>
  801eed:	89 c3                	mov    %eax,%ebx
  801eef:	83 c4 20             	add    $0x20,%esp
  801ef2:	85 c0                	test   %eax,%eax
  801ef4:	78 4e                	js     801f44 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801ef6:	a1 20 30 80 00       	mov    0x803020,%eax
  801efb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801efe:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801f00:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f03:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801f0a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f0d:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801f0f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f12:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801f19:	83 ec 0c             	sub    $0xc,%esp
  801f1c:	ff 75 f4             	pushl  -0xc(%ebp)
  801f1f:	e8 da f4 ff ff       	call   8013fe <fd2num>
  801f24:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f27:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f29:	83 c4 04             	add    $0x4,%esp
  801f2c:	ff 75 f0             	pushl  -0x10(%ebp)
  801f2f:	e8 ca f4 ff ff       	call   8013fe <fd2num>
  801f34:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f37:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f3a:	83 c4 10             	add    $0x10,%esp
  801f3d:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f42:	eb 2e                	jmp    801f72 <pipe+0x145>
	sys_page_unmap(0, va);
  801f44:	83 ec 08             	sub    $0x8,%esp
  801f47:	56                   	push   %esi
  801f48:	6a 00                	push   $0x0
  801f4a:	e8 81 ee ff ff       	call   800dd0 <sys_page_unmap>
  801f4f:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801f52:	83 ec 08             	sub    $0x8,%esp
  801f55:	ff 75 f0             	pushl  -0x10(%ebp)
  801f58:	6a 00                	push   $0x0
  801f5a:	e8 71 ee ff ff       	call   800dd0 <sys_page_unmap>
  801f5f:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801f62:	83 ec 08             	sub    $0x8,%esp
  801f65:	ff 75 f4             	pushl  -0xc(%ebp)
  801f68:	6a 00                	push   $0x0
  801f6a:	e8 61 ee ff ff       	call   800dd0 <sys_page_unmap>
  801f6f:	83 c4 10             	add    $0x10,%esp
}
  801f72:	89 d8                	mov    %ebx,%eax
  801f74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f77:	5b                   	pop    %ebx
  801f78:	5e                   	pop    %esi
  801f79:	5d                   	pop    %ebp
  801f7a:	c3                   	ret    

00801f7b <pipeisclosed>:
{
  801f7b:	f3 0f 1e fb          	endbr32 
  801f7f:	55                   	push   %ebp
  801f80:	89 e5                	mov    %esp,%ebp
  801f82:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801f85:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801f88:	50                   	push   %eax
  801f89:	ff 75 08             	pushl  0x8(%ebp)
  801f8c:	e8 f6 f4 ff ff       	call   801487 <fd_lookup>
  801f91:	83 c4 10             	add    $0x10,%esp
  801f94:	85 c0                	test   %eax,%eax
  801f96:	78 18                	js     801fb0 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801f98:	83 ec 0c             	sub    $0xc,%esp
  801f9b:	ff 75 f4             	pushl  -0xc(%ebp)
  801f9e:	e8 6f f4 ff ff       	call   801412 <fd2data>
  801fa3:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801fa5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fa8:	e8 1f fd ff ff       	call   801ccc <_pipeisclosed>
  801fad:	83 c4 10             	add    $0x10,%esp
}
  801fb0:	c9                   	leave  
  801fb1:	c3                   	ret    

00801fb2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fb2:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801fb6:	b8 00 00 00 00       	mov    $0x0,%eax
  801fbb:	c3                   	ret    

00801fbc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fbc:	f3 0f 1e fb          	endbr32 
  801fc0:	55                   	push   %ebp
  801fc1:	89 e5                	mov    %esp,%ebp
  801fc3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fc6:	68 49 2c 80 00       	push   $0x802c49
  801fcb:	ff 75 0c             	pushl  0xc(%ebp)
  801fce:	e8 23 e9 ff ff       	call   8008f6 <strcpy>
	return 0;
}
  801fd3:	b8 00 00 00 00       	mov    $0x0,%eax
  801fd8:	c9                   	leave  
  801fd9:	c3                   	ret    

00801fda <devcons_write>:
{
  801fda:	f3 0f 1e fb          	endbr32 
  801fde:	55                   	push   %ebp
  801fdf:	89 e5                	mov    %esp,%ebp
  801fe1:	57                   	push   %edi
  801fe2:	56                   	push   %esi
  801fe3:	53                   	push   %ebx
  801fe4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  801fea:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  801fef:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  801ff5:	3b 75 10             	cmp    0x10(%ebp),%esi
  801ff8:	73 31                	jae    80202b <devcons_write+0x51>
		m = n - tot;
  801ffa:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ffd:	29 f3                	sub    %esi,%ebx
  801fff:	83 fb 7f             	cmp    $0x7f,%ebx
  802002:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802007:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80200a:	83 ec 04             	sub    $0x4,%esp
  80200d:	53                   	push   %ebx
  80200e:	89 f0                	mov    %esi,%eax
  802010:	03 45 0c             	add    0xc(%ebp),%eax
  802013:	50                   	push   %eax
  802014:	57                   	push   %edi
  802015:	e8 94 ea ff ff       	call   800aae <memmove>
		sys_cputs(buf, m);
  80201a:	83 c4 08             	add    $0x8,%esp
  80201d:	53                   	push   %ebx
  80201e:	57                   	push   %edi
  80201f:	e8 8f ec ff ff       	call   800cb3 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802024:	01 de                	add    %ebx,%esi
  802026:	83 c4 10             	add    $0x10,%esp
  802029:	eb ca                	jmp    801ff5 <devcons_write+0x1b>
}
  80202b:	89 f0                	mov    %esi,%eax
  80202d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802030:	5b                   	pop    %ebx
  802031:	5e                   	pop    %esi
  802032:	5f                   	pop    %edi
  802033:	5d                   	pop    %ebp
  802034:	c3                   	ret    

00802035 <devcons_read>:
{
  802035:	f3 0f 1e fb          	endbr32 
  802039:	55                   	push   %ebp
  80203a:	89 e5                	mov    %esp,%ebp
  80203c:	83 ec 08             	sub    $0x8,%esp
  80203f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802044:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802048:	74 21                	je     80206b <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  80204a:	e8 8e ec ff ff       	call   800cdd <sys_cgetc>
  80204f:	85 c0                	test   %eax,%eax
  802051:	75 07                	jne    80205a <devcons_read+0x25>
		sys_yield();
  802053:	e8 fb ec ff ff       	call   800d53 <sys_yield>
  802058:	eb f0                	jmp    80204a <devcons_read+0x15>
	if (c < 0)
  80205a:	78 0f                	js     80206b <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  80205c:	83 f8 04             	cmp    $0x4,%eax
  80205f:	74 0c                	je     80206d <devcons_read+0x38>
	*(char*)vbuf = c;
  802061:	8b 55 0c             	mov    0xc(%ebp),%edx
  802064:	88 02                	mov    %al,(%edx)
	return 1;
  802066:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80206b:	c9                   	leave  
  80206c:	c3                   	ret    
		return 0;
  80206d:	b8 00 00 00 00       	mov    $0x0,%eax
  802072:	eb f7                	jmp    80206b <devcons_read+0x36>

00802074 <cputchar>:
{
  802074:	f3 0f 1e fb          	endbr32 
  802078:	55                   	push   %ebp
  802079:	89 e5                	mov    %esp,%ebp
  80207b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80207e:	8b 45 08             	mov    0x8(%ebp),%eax
  802081:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802084:	6a 01                	push   $0x1
  802086:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802089:	50                   	push   %eax
  80208a:	e8 24 ec ff ff       	call   800cb3 <sys_cputs>
}
  80208f:	83 c4 10             	add    $0x10,%esp
  802092:	c9                   	leave  
  802093:	c3                   	ret    

00802094 <getchar>:
{
  802094:	f3 0f 1e fb          	endbr32 
  802098:	55                   	push   %ebp
  802099:	89 e5                	mov    %esp,%ebp
  80209b:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80209e:	6a 01                	push   $0x1
  8020a0:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020a3:	50                   	push   %eax
  8020a4:	6a 00                	push   $0x0
  8020a6:	e8 5f f6 ff ff       	call   80170a <read>
	if (r < 0)
  8020ab:	83 c4 10             	add    $0x10,%esp
  8020ae:	85 c0                	test   %eax,%eax
  8020b0:	78 06                	js     8020b8 <getchar+0x24>
	if (r < 1)
  8020b2:	74 06                	je     8020ba <getchar+0x26>
	return c;
  8020b4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8020b8:	c9                   	leave  
  8020b9:	c3                   	ret    
		return -E_EOF;
  8020ba:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8020bf:	eb f7                	jmp    8020b8 <getchar+0x24>

008020c1 <iscons>:
{
  8020c1:	f3 0f 1e fb          	endbr32 
  8020c5:	55                   	push   %ebp
  8020c6:	89 e5                	mov    %esp,%ebp
  8020c8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020ce:	50                   	push   %eax
  8020cf:	ff 75 08             	pushl  0x8(%ebp)
  8020d2:	e8 b0 f3 ff ff       	call   801487 <fd_lookup>
  8020d7:	83 c4 10             	add    $0x10,%esp
  8020da:	85 c0                	test   %eax,%eax
  8020dc:	78 11                	js     8020ef <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8020de:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020e1:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  8020e7:	39 10                	cmp    %edx,(%eax)
  8020e9:	0f 94 c0             	sete   %al
  8020ec:	0f b6 c0             	movzbl %al,%eax
}
  8020ef:	c9                   	leave  
  8020f0:	c3                   	ret    

008020f1 <opencons>:
{
  8020f1:	f3 0f 1e fb          	endbr32 
  8020f5:	55                   	push   %ebp
  8020f6:	89 e5                	mov    %esp,%ebp
  8020f8:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8020fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020fe:	50                   	push   %eax
  8020ff:	e8 2d f3 ff ff       	call   801431 <fd_alloc>
  802104:	83 c4 10             	add    $0x10,%esp
  802107:	85 c0                	test   %eax,%eax
  802109:	78 3a                	js     802145 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80210b:	83 ec 04             	sub    $0x4,%esp
  80210e:	68 07 04 00 00       	push   $0x407
  802113:	ff 75 f4             	pushl  -0xc(%ebp)
  802116:	6a 00                	push   $0x0
  802118:	e8 61 ec ff ff       	call   800d7e <sys_page_alloc>
  80211d:	83 c4 10             	add    $0x10,%esp
  802120:	85 c0                	test   %eax,%eax
  802122:	78 21                	js     802145 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  802124:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802127:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80212d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80212f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802132:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802139:	83 ec 0c             	sub    $0xc,%esp
  80213c:	50                   	push   %eax
  80213d:	e8 bc f2 ff ff       	call   8013fe <fd2num>
  802142:	83 c4 10             	add    $0x10,%esp
}
  802145:	c9                   	leave  
  802146:	c3                   	ret    

00802147 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802147:	f3 0f 1e fb          	endbr32 
  80214b:	55                   	push   %ebp
  80214c:	89 e5                	mov    %esp,%ebp
  80214e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802151:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802158:	74 1c                	je     802176 <set_pgfault_handler+0x2f>
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80215a:	8b 45 08             	mov    0x8(%ebp),%eax
  80215d:	a3 00 60 80 00       	mov    %eax,0x806000

	//Indicarle al kerne que _pgfault_upcall va a ser el manejador de pgfaults de un proceso
	sys_env_set_pgfault_upcall(0, &(_pgfault_upcall));
  802162:	83 ec 08             	sub    $0x8,%esp
  802165:	68 a2 21 80 00       	push   $0x8021a2
  80216a:	6a 00                	push   $0x0
  80216c:	e8 d4 ec ff ff       	call   800e45 <sys_env_set_pgfault_upcall>
}
  802171:	83 c4 10             	add    $0x10,%esp
  802174:	c9                   	leave  
  802175:	c3                   	ret    
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
  802176:	83 ec 04             	sub    $0x4,%esp
  802179:	6a 02                	push   $0x2
  80217b:	68 00 f0 bf ee       	push   $0xeebff000
  802180:	6a 00                	push   $0x0
  802182:	e8 f7 eb ff ff       	call   800d7e <sys_page_alloc>
  802187:	83 c4 10             	add    $0x10,%esp
  80218a:	85 c0                	test   %eax,%eax
  80218c:	79 cc                	jns    80215a <set_pgfault_handler+0x13>
  80218e:	83 ec 04             	sub    $0x4,%esp
  802191:	68 55 2c 80 00       	push   $0x802c55
  802196:	6a 20                	push   $0x20
  802198:	68 70 2c 80 00       	push   $0x802c70
  80219d:	e8 03 e1 ff ff       	call   8002a5 <_panic>

008021a2 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8021a2:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8021a3:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  8021a8:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8021aa:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 40(%esp), %eax
  8021ad:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	
  8021b1:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  8021b5:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, (%ebx)
  8021b8:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 48(%esp)
  8021ba:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8021be:	83 c4 08             	add    $0x8,%esp
	popal
  8021c1:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8021c2:	83 c4 04             	add    $0x4,%esp
	popfl
  8021c5:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  8021c6:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8021c9:	c3                   	ret    

008021ca <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8021ca:	f3 0f 1e fb          	endbr32 
  8021ce:	55                   	push   %ebp
  8021cf:	89 e5                	mov    %esp,%ebp
  8021d1:	56                   	push   %esi
  8021d2:	53                   	push   %ebx
  8021d3:	8b 75 08             	mov    0x8(%ebp),%esi
  8021d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8021d9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  8021dc:	85 c0                	test   %eax,%eax
  8021de:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8021e3:	0f 44 c2             	cmove  %edx,%eax
  8021e6:	83 ec 0c             	sub    $0xc,%esp
  8021e9:	50                   	push   %eax
  8021ea:	e8 a6 ec ff ff       	call   800e95 <sys_ipc_recv>

	if (from_env_store != NULL)
  8021ef:	83 c4 10             	add    $0x10,%esp
  8021f2:	85 f6                	test   %esi,%esi
  8021f4:	74 15                	je     80220b <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  8021f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8021fb:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8021fe:	74 09                	je     802209 <ipc_recv+0x3f>
  802200:	8b 15 04 40 80 00    	mov    0x804004,%edx
  802206:	8b 52 74             	mov    0x74(%edx),%edx
  802209:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  80220b:	85 db                	test   %ebx,%ebx
  80220d:	74 15                	je     802224 <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  80220f:	ba 00 00 00 00       	mov    $0x0,%edx
  802214:	83 f8 fd             	cmp    $0xfffffffd,%eax
  802217:	74 09                	je     802222 <ipc_recv+0x58>
  802219:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80221f:	8b 52 78             	mov    0x78(%edx),%edx
  802222:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  802224:	83 f8 fd             	cmp    $0xfffffffd,%eax
  802227:	74 08                	je     802231 <ipc_recv+0x67>
  802229:	a1 04 40 80 00       	mov    0x804004,%eax
  80222e:	8b 40 70             	mov    0x70(%eax),%eax
}
  802231:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802234:	5b                   	pop    %ebx
  802235:	5e                   	pop    %esi
  802236:	5d                   	pop    %ebp
  802237:	c3                   	ret    

00802238 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802238:	f3 0f 1e fb          	endbr32 
  80223c:	55                   	push   %ebp
  80223d:	89 e5                	mov    %esp,%ebp
  80223f:	57                   	push   %edi
  802240:	56                   	push   %esi
  802241:	53                   	push   %ebx
  802242:	83 ec 0c             	sub    $0xc,%esp
  802245:	8b 7d 08             	mov    0x8(%ebp),%edi
  802248:	8b 75 0c             	mov    0xc(%ebp),%esi
  80224b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80224e:	eb 1f                	jmp    80226f <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  802250:	6a 00                	push   $0x0
  802252:	68 00 00 c0 ee       	push   $0xeec00000
  802257:	56                   	push   %esi
  802258:	57                   	push   %edi
  802259:	e8 0e ec ff ff       	call   800e6c <sys_ipc_try_send>
  80225e:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  802261:	85 c0                	test   %eax,%eax
  802263:	74 30                	je     802295 <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  802265:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802268:	75 19                	jne    802283 <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  80226a:	e8 e4 ea ff ff       	call   800d53 <sys_yield>
		if (pg != NULL) {
  80226f:	85 db                	test   %ebx,%ebx
  802271:	74 dd                	je     802250 <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  802273:	ff 75 14             	pushl  0x14(%ebp)
  802276:	53                   	push   %ebx
  802277:	56                   	push   %esi
  802278:	57                   	push   %edi
  802279:	e8 ee eb ff ff       	call   800e6c <sys_ipc_try_send>
  80227e:	83 c4 10             	add    $0x10,%esp
  802281:	eb de                	jmp    802261 <ipc_send+0x29>
			panic("ipc_send: %d", res);
  802283:	50                   	push   %eax
  802284:	68 7e 2c 80 00       	push   $0x802c7e
  802289:	6a 3e                	push   $0x3e
  80228b:	68 8b 2c 80 00       	push   $0x802c8b
  802290:	e8 10 e0 ff ff       	call   8002a5 <_panic>
	}
}
  802295:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802298:	5b                   	pop    %ebx
  802299:	5e                   	pop    %esi
  80229a:	5f                   	pop    %edi
  80229b:	5d                   	pop    %ebp
  80229c:	c3                   	ret    

0080229d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80229d:	f3 0f 1e fb          	endbr32 
  8022a1:	55                   	push   %ebp
  8022a2:	89 e5                	mov    %esp,%ebp
  8022a4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8022a7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8022ac:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8022af:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8022b5:	8b 52 50             	mov    0x50(%edx),%edx
  8022b8:	39 ca                	cmp    %ecx,%edx
  8022ba:	74 11                	je     8022cd <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8022bc:	83 c0 01             	add    $0x1,%eax
  8022bf:	3d 00 04 00 00       	cmp    $0x400,%eax
  8022c4:	75 e6                	jne    8022ac <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8022c6:	b8 00 00 00 00       	mov    $0x0,%eax
  8022cb:	eb 0b                	jmp    8022d8 <ipc_find_env+0x3b>
			return envs[i].env_id;
  8022cd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8022d0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8022d5:	8b 40 48             	mov    0x48(%eax),%eax
}
  8022d8:	5d                   	pop    %ebp
  8022d9:	c3                   	ret    

008022da <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8022da:	f3 0f 1e fb          	endbr32 
  8022de:	55                   	push   %ebp
  8022df:	89 e5                	mov    %esp,%ebp
  8022e1:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8022e4:	89 c2                	mov    %eax,%edx
  8022e6:	c1 ea 16             	shr    $0x16,%edx
  8022e9:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8022f0:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8022f5:	f6 c1 01             	test   $0x1,%cl
  8022f8:	74 1c                	je     802316 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8022fa:	c1 e8 0c             	shr    $0xc,%eax
  8022fd:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802304:	a8 01                	test   $0x1,%al
  802306:	74 0e                	je     802316 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802308:	c1 e8 0c             	shr    $0xc,%eax
  80230b:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802312:	ef 
  802313:	0f b7 d2             	movzwl %dx,%edx
}
  802316:	89 d0                	mov    %edx,%eax
  802318:	5d                   	pop    %ebp
  802319:	c3                   	ret    
  80231a:	66 90                	xchg   %ax,%ax
  80231c:	66 90                	xchg   %ax,%ax
  80231e:	66 90                	xchg   %ax,%ax

00802320 <__udivdi3>:
  802320:	f3 0f 1e fb          	endbr32 
  802324:	55                   	push   %ebp
  802325:	57                   	push   %edi
  802326:	56                   	push   %esi
  802327:	53                   	push   %ebx
  802328:	83 ec 1c             	sub    $0x1c,%esp
  80232b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80232f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802333:	8b 74 24 34          	mov    0x34(%esp),%esi
  802337:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80233b:	85 d2                	test   %edx,%edx
  80233d:	75 19                	jne    802358 <__udivdi3+0x38>
  80233f:	39 f3                	cmp    %esi,%ebx
  802341:	76 4d                	jbe    802390 <__udivdi3+0x70>
  802343:	31 ff                	xor    %edi,%edi
  802345:	89 e8                	mov    %ebp,%eax
  802347:	89 f2                	mov    %esi,%edx
  802349:	f7 f3                	div    %ebx
  80234b:	89 fa                	mov    %edi,%edx
  80234d:	83 c4 1c             	add    $0x1c,%esp
  802350:	5b                   	pop    %ebx
  802351:	5e                   	pop    %esi
  802352:	5f                   	pop    %edi
  802353:	5d                   	pop    %ebp
  802354:	c3                   	ret    
  802355:	8d 76 00             	lea    0x0(%esi),%esi
  802358:	39 f2                	cmp    %esi,%edx
  80235a:	76 14                	jbe    802370 <__udivdi3+0x50>
  80235c:	31 ff                	xor    %edi,%edi
  80235e:	31 c0                	xor    %eax,%eax
  802360:	89 fa                	mov    %edi,%edx
  802362:	83 c4 1c             	add    $0x1c,%esp
  802365:	5b                   	pop    %ebx
  802366:	5e                   	pop    %esi
  802367:	5f                   	pop    %edi
  802368:	5d                   	pop    %ebp
  802369:	c3                   	ret    
  80236a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802370:	0f bd fa             	bsr    %edx,%edi
  802373:	83 f7 1f             	xor    $0x1f,%edi
  802376:	75 48                	jne    8023c0 <__udivdi3+0xa0>
  802378:	39 f2                	cmp    %esi,%edx
  80237a:	72 06                	jb     802382 <__udivdi3+0x62>
  80237c:	31 c0                	xor    %eax,%eax
  80237e:	39 eb                	cmp    %ebp,%ebx
  802380:	77 de                	ja     802360 <__udivdi3+0x40>
  802382:	b8 01 00 00 00       	mov    $0x1,%eax
  802387:	eb d7                	jmp    802360 <__udivdi3+0x40>
  802389:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802390:	89 d9                	mov    %ebx,%ecx
  802392:	85 db                	test   %ebx,%ebx
  802394:	75 0b                	jne    8023a1 <__udivdi3+0x81>
  802396:	b8 01 00 00 00       	mov    $0x1,%eax
  80239b:	31 d2                	xor    %edx,%edx
  80239d:	f7 f3                	div    %ebx
  80239f:	89 c1                	mov    %eax,%ecx
  8023a1:	31 d2                	xor    %edx,%edx
  8023a3:	89 f0                	mov    %esi,%eax
  8023a5:	f7 f1                	div    %ecx
  8023a7:	89 c6                	mov    %eax,%esi
  8023a9:	89 e8                	mov    %ebp,%eax
  8023ab:	89 f7                	mov    %esi,%edi
  8023ad:	f7 f1                	div    %ecx
  8023af:	89 fa                	mov    %edi,%edx
  8023b1:	83 c4 1c             	add    $0x1c,%esp
  8023b4:	5b                   	pop    %ebx
  8023b5:	5e                   	pop    %esi
  8023b6:	5f                   	pop    %edi
  8023b7:	5d                   	pop    %ebp
  8023b8:	c3                   	ret    
  8023b9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023c0:	89 f9                	mov    %edi,%ecx
  8023c2:	b8 20 00 00 00       	mov    $0x20,%eax
  8023c7:	29 f8                	sub    %edi,%eax
  8023c9:	d3 e2                	shl    %cl,%edx
  8023cb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8023cf:	89 c1                	mov    %eax,%ecx
  8023d1:	89 da                	mov    %ebx,%edx
  8023d3:	d3 ea                	shr    %cl,%edx
  8023d5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8023d9:	09 d1                	or     %edx,%ecx
  8023db:	89 f2                	mov    %esi,%edx
  8023dd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8023e1:	89 f9                	mov    %edi,%ecx
  8023e3:	d3 e3                	shl    %cl,%ebx
  8023e5:	89 c1                	mov    %eax,%ecx
  8023e7:	d3 ea                	shr    %cl,%edx
  8023e9:	89 f9                	mov    %edi,%ecx
  8023eb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8023ef:	89 eb                	mov    %ebp,%ebx
  8023f1:	d3 e6                	shl    %cl,%esi
  8023f3:	89 c1                	mov    %eax,%ecx
  8023f5:	d3 eb                	shr    %cl,%ebx
  8023f7:	09 de                	or     %ebx,%esi
  8023f9:	89 f0                	mov    %esi,%eax
  8023fb:	f7 74 24 08          	divl   0x8(%esp)
  8023ff:	89 d6                	mov    %edx,%esi
  802401:	89 c3                	mov    %eax,%ebx
  802403:	f7 64 24 0c          	mull   0xc(%esp)
  802407:	39 d6                	cmp    %edx,%esi
  802409:	72 15                	jb     802420 <__udivdi3+0x100>
  80240b:	89 f9                	mov    %edi,%ecx
  80240d:	d3 e5                	shl    %cl,%ebp
  80240f:	39 c5                	cmp    %eax,%ebp
  802411:	73 04                	jae    802417 <__udivdi3+0xf7>
  802413:	39 d6                	cmp    %edx,%esi
  802415:	74 09                	je     802420 <__udivdi3+0x100>
  802417:	89 d8                	mov    %ebx,%eax
  802419:	31 ff                	xor    %edi,%edi
  80241b:	e9 40 ff ff ff       	jmp    802360 <__udivdi3+0x40>
  802420:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802423:	31 ff                	xor    %edi,%edi
  802425:	e9 36 ff ff ff       	jmp    802360 <__udivdi3+0x40>
  80242a:	66 90                	xchg   %ax,%ax
  80242c:	66 90                	xchg   %ax,%ax
  80242e:	66 90                	xchg   %ax,%ax

00802430 <__umoddi3>:
  802430:	f3 0f 1e fb          	endbr32 
  802434:	55                   	push   %ebp
  802435:	57                   	push   %edi
  802436:	56                   	push   %esi
  802437:	53                   	push   %ebx
  802438:	83 ec 1c             	sub    $0x1c,%esp
  80243b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80243f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802443:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802447:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80244b:	85 c0                	test   %eax,%eax
  80244d:	75 19                	jne    802468 <__umoddi3+0x38>
  80244f:	39 df                	cmp    %ebx,%edi
  802451:	76 5d                	jbe    8024b0 <__umoddi3+0x80>
  802453:	89 f0                	mov    %esi,%eax
  802455:	89 da                	mov    %ebx,%edx
  802457:	f7 f7                	div    %edi
  802459:	89 d0                	mov    %edx,%eax
  80245b:	31 d2                	xor    %edx,%edx
  80245d:	83 c4 1c             	add    $0x1c,%esp
  802460:	5b                   	pop    %ebx
  802461:	5e                   	pop    %esi
  802462:	5f                   	pop    %edi
  802463:	5d                   	pop    %ebp
  802464:	c3                   	ret    
  802465:	8d 76 00             	lea    0x0(%esi),%esi
  802468:	89 f2                	mov    %esi,%edx
  80246a:	39 d8                	cmp    %ebx,%eax
  80246c:	76 12                	jbe    802480 <__umoddi3+0x50>
  80246e:	89 f0                	mov    %esi,%eax
  802470:	89 da                	mov    %ebx,%edx
  802472:	83 c4 1c             	add    $0x1c,%esp
  802475:	5b                   	pop    %ebx
  802476:	5e                   	pop    %esi
  802477:	5f                   	pop    %edi
  802478:	5d                   	pop    %ebp
  802479:	c3                   	ret    
  80247a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802480:	0f bd e8             	bsr    %eax,%ebp
  802483:	83 f5 1f             	xor    $0x1f,%ebp
  802486:	75 50                	jne    8024d8 <__umoddi3+0xa8>
  802488:	39 d8                	cmp    %ebx,%eax
  80248a:	0f 82 e0 00 00 00    	jb     802570 <__umoddi3+0x140>
  802490:	89 d9                	mov    %ebx,%ecx
  802492:	39 f7                	cmp    %esi,%edi
  802494:	0f 86 d6 00 00 00    	jbe    802570 <__umoddi3+0x140>
  80249a:	89 d0                	mov    %edx,%eax
  80249c:	89 ca                	mov    %ecx,%edx
  80249e:	83 c4 1c             	add    $0x1c,%esp
  8024a1:	5b                   	pop    %ebx
  8024a2:	5e                   	pop    %esi
  8024a3:	5f                   	pop    %edi
  8024a4:	5d                   	pop    %ebp
  8024a5:	c3                   	ret    
  8024a6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024ad:	8d 76 00             	lea    0x0(%esi),%esi
  8024b0:	89 fd                	mov    %edi,%ebp
  8024b2:	85 ff                	test   %edi,%edi
  8024b4:	75 0b                	jne    8024c1 <__umoddi3+0x91>
  8024b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8024bb:	31 d2                	xor    %edx,%edx
  8024bd:	f7 f7                	div    %edi
  8024bf:	89 c5                	mov    %eax,%ebp
  8024c1:	89 d8                	mov    %ebx,%eax
  8024c3:	31 d2                	xor    %edx,%edx
  8024c5:	f7 f5                	div    %ebp
  8024c7:	89 f0                	mov    %esi,%eax
  8024c9:	f7 f5                	div    %ebp
  8024cb:	89 d0                	mov    %edx,%eax
  8024cd:	31 d2                	xor    %edx,%edx
  8024cf:	eb 8c                	jmp    80245d <__umoddi3+0x2d>
  8024d1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024d8:	89 e9                	mov    %ebp,%ecx
  8024da:	ba 20 00 00 00       	mov    $0x20,%edx
  8024df:	29 ea                	sub    %ebp,%edx
  8024e1:	d3 e0                	shl    %cl,%eax
  8024e3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8024e7:	89 d1                	mov    %edx,%ecx
  8024e9:	89 f8                	mov    %edi,%eax
  8024eb:	d3 e8                	shr    %cl,%eax
  8024ed:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8024f1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8024f5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8024f9:	09 c1                	or     %eax,%ecx
  8024fb:	89 d8                	mov    %ebx,%eax
  8024fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802501:	89 e9                	mov    %ebp,%ecx
  802503:	d3 e7                	shl    %cl,%edi
  802505:	89 d1                	mov    %edx,%ecx
  802507:	d3 e8                	shr    %cl,%eax
  802509:	89 e9                	mov    %ebp,%ecx
  80250b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80250f:	d3 e3                	shl    %cl,%ebx
  802511:	89 c7                	mov    %eax,%edi
  802513:	89 d1                	mov    %edx,%ecx
  802515:	89 f0                	mov    %esi,%eax
  802517:	d3 e8                	shr    %cl,%eax
  802519:	89 e9                	mov    %ebp,%ecx
  80251b:	89 fa                	mov    %edi,%edx
  80251d:	d3 e6                	shl    %cl,%esi
  80251f:	09 d8                	or     %ebx,%eax
  802521:	f7 74 24 08          	divl   0x8(%esp)
  802525:	89 d1                	mov    %edx,%ecx
  802527:	89 f3                	mov    %esi,%ebx
  802529:	f7 64 24 0c          	mull   0xc(%esp)
  80252d:	89 c6                	mov    %eax,%esi
  80252f:	89 d7                	mov    %edx,%edi
  802531:	39 d1                	cmp    %edx,%ecx
  802533:	72 06                	jb     80253b <__umoddi3+0x10b>
  802535:	75 10                	jne    802547 <__umoddi3+0x117>
  802537:	39 c3                	cmp    %eax,%ebx
  802539:	73 0c                	jae    802547 <__umoddi3+0x117>
  80253b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80253f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802543:	89 d7                	mov    %edx,%edi
  802545:	89 c6                	mov    %eax,%esi
  802547:	89 ca                	mov    %ecx,%edx
  802549:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80254e:	29 f3                	sub    %esi,%ebx
  802550:	19 fa                	sbb    %edi,%edx
  802552:	89 d0                	mov    %edx,%eax
  802554:	d3 e0                	shl    %cl,%eax
  802556:	89 e9                	mov    %ebp,%ecx
  802558:	d3 eb                	shr    %cl,%ebx
  80255a:	d3 ea                	shr    %cl,%edx
  80255c:	09 d8                	or     %ebx,%eax
  80255e:	83 c4 1c             	add    $0x1c,%esp
  802561:	5b                   	pop    %ebx
  802562:	5e                   	pop    %esi
  802563:	5f                   	pop    %edi
  802564:	5d                   	pop    %ebp
  802565:	c3                   	ret    
  802566:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80256d:	8d 76 00             	lea    0x0(%esi),%esi
  802570:	29 fe                	sub    %edi,%esi
  802572:	19 c3                	sbb    %eax,%ebx
  802574:	89 f2                	mov    %esi,%edx
  802576:	89 d9                	mov    %ebx,%ecx
  802578:	e9 1d ff ff ff       	jmp    80249a <__umoddi3+0x6a>
