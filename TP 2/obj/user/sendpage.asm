
obj/user/sendpage.debug:     formato del fichero elf32-i386


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
  80002c:	e8 83 01 00 00       	call   8001b4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:
#define TEMP_ADDR	((char*)0xa00000)
#define TEMP_ADDR_CHILD	((char*)0xb00000)

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 18             	sub    $0x18,%esp
	envid_t who;

	if ((who = fork()) == 0) {
  80003d:	e8 4c 11 00 00       	call   80118e <fork>
  800042:	89 45 f4             	mov    %eax,-0xc(%ebp)
  800045:	85 c0                	test   %eax,%eax
  800047:	0f 84 ab 00 00 00    	je     8000f8 <umain+0xc5>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
		return;
	}

	// Parent
	sys_page_alloc(thisenv->env_id, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80004d:	a1 04 40 80 00       	mov    0x804004,%eax
  800052:	8b 40 48             	mov    0x48(%eax),%eax
  800055:	83 ec 04             	sub    $0x4,%esp
  800058:	6a 07                	push   $0x7
  80005a:	68 00 00 a0 00       	push   $0xa00000
  80005f:	50                   	push   %eax
  800060:	e8 4a 0c 00 00       	call   800caf <sys_page_alloc>
	memcpy(TEMP_ADDR, str1, strlen(str1) + 1);
  800065:	83 c4 04             	add    $0x4,%esp
  800068:	ff 35 04 30 80 00    	pushl  0x803004
  80006e:	e8 71 07 00 00       	call   8007e4 <strlen>
  800073:	83 c4 0c             	add    $0xc,%esp
  800076:	83 c0 01             	add    $0x1,%eax
  800079:	50                   	push   %eax
  80007a:	ff 35 04 30 80 00    	pushl  0x803004
  800080:	68 00 00 a0 00       	push   $0xa00000
  800085:	e8 bb 09 00 00       	call   800a45 <memcpy>
	ipc_send(who, 0, TEMP_ADDR, PTE_P | PTE_W | PTE_U);
  80008a:	6a 07                	push   $0x7
  80008c:	68 00 00 a0 00       	push   $0xa00000
  800091:	6a 00                	push   $0x0
  800093:	ff 75 f4             	pushl  -0xc(%ebp)
  800096:	e8 02 13 00 00       	call   80139d <ipc_send>

	ipc_recv(&who, TEMP_ADDR, 0);
  80009b:	83 c4 1c             	add    $0x1c,%esp
  80009e:	6a 00                	push   $0x0
  8000a0:	68 00 00 a0 00       	push   $0xa00000
  8000a5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8000a8:	50                   	push   %eax
  8000a9:	e8 81 12 00 00       	call   80132f <ipc_recv>
	cprintf("%x got message from %x: %s\n",
		thisenv->env_id, who, TEMP_ADDR);
  8000ae:	a1 04 40 80 00       	mov    0x804004,%eax
	cprintf("%x got message from %x: %s\n",
  8000b3:	8b 40 48             	mov    0x48(%eax),%eax
  8000b6:	68 00 00 a0 00       	push   $0xa00000
  8000bb:	ff 75 f4             	pushl  -0xc(%ebp)
  8000be:	50                   	push   %eax
  8000bf:	68 00 25 80 00       	push   $0x802500
  8000c4:	e8 f4 01 00 00       	call   8002bd <cprintf>
	if (strncmp(TEMP_ADDR, str2, strlen(str2)) == 0)
  8000c9:	83 c4 14             	add    $0x14,%esp
  8000cc:	ff 35 00 30 80 00    	pushl  0x803000
  8000d2:	e8 0d 07 00 00       	call   8007e4 <strlen>
  8000d7:	83 c4 0c             	add    $0xc,%esp
  8000da:	50                   	push   %eax
  8000db:	ff 35 00 30 80 00    	pushl  0x803000
  8000e1:	68 00 00 a0 00       	push   $0xa00000
  8000e6:	e8 25 08 00 00       	call   800910 <strncmp>
  8000eb:	83 c4 10             	add    $0x10,%esp
  8000ee:	85 c0                	test   %eax,%eax
  8000f0:	0f 84 a9 00 00 00    	je     80019f <umain+0x16c>
		cprintf("parent received correct message\n");
	return;
}
  8000f6:	c9                   	leave  
  8000f7:	c3                   	ret    
		ipc_recv(&who, TEMP_ADDR_CHILD, 0);
  8000f8:	83 ec 04             	sub    $0x4,%esp
  8000fb:	6a 00                	push   $0x0
  8000fd:	68 00 00 b0 00       	push   $0xb00000
  800102:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800105:	50                   	push   %eax
  800106:	e8 24 12 00 00       	call   80132f <ipc_recv>
			thisenv->env_id, who, TEMP_ADDR_CHILD);
  80010b:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("%x got message from %x: %s\n",
  800110:	8b 40 48             	mov    0x48(%eax),%eax
  800113:	68 00 00 b0 00       	push   $0xb00000
  800118:	ff 75 f4             	pushl  -0xc(%ebp)
  80011b:	50                   	push   %eax
  80011c:	68 00 25 80 00       	push   $0x802500
  800121:	e8 97 01 00 00       	call   8002bd <cprintf>
		if (strncmp(TEMP_ADDR_CHILD, str1, strlen(str1)) == 0)
  800126:	83 c4 14             	add    $0x14,%esp
  800129:	ff 35 04 30 80 00    	pushl  0x803004
  80012f:	e8 b0 06 00 00       	call   8007e4 <strlen>
  800134:	83 c4 0c             	add    $0xc,%esp
  800137:	50                   	push   %eax
  800138:	ff 35 04 30 80 00    	pushl  0x803004
  80013e:	68 00 00 b0 00       	push   $0xb00000
  800143:	e8 c8 07 00 00       	call   800910 <strncmp>
  800148:	83 c4 10             	add    $0x10,%esp
  80014b:	85 c0                	test   %eax,%eax
  80014d:	74 3e                	je     80018d <umain+0x15a>
		memcpy(TEMP_ADDR_CHILD, str2, strlen(str2) + 1);
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	ff 35 00 30 80 00    	pushl  0x803000
  800158:	e8 87 06 00 00       	call   8007e4 <strlen>
  80015d:	83 c4 0c             	add    $0xc,%esp
  800160:	83 c0 01             	add    $0x1,%eax
  800163:	50                   	push   %eax
  800164:	ff 35 00 30 80 00    	pushl  0x803000
  80016a:	68 00 00 b0 00       	push   $0xb00000
  80016f:	e8 d1 08 00 00       	call   800a45 <memcpy>
		ipc_send(who, 0, TEMP_ADDR_CHILD, PTE_P | PTE_W | PTE_U);
  800174:	6a 07                	push   $0x7
  800176:	68 00 00 b0 00       	push   $0xb00000
  80017b:	6a 00                	push   $0x0
  80017d:	ff 75 f4             	pushl  -0xc(%ebp)
  800180:	e8 18 12 00 00       	call   80139d <ipc_send>
		return;
  800185:	83 c4 20             	add    $0x20,%esp
  800188:	e9 69 ff ff ff       	jmp    8000f6 <umain+0xc3>
			cprintf("child received correct message\n");
  80018d:	83 ec 0c             	sub    $0xc,%esp
  800190:	68 1c 25 80 00       	push   $0x80251c
  800195:	e8 23 01 00 00       	call   8002bd <cprintf>
  80019a:	83 c4 10             	add    $0x10,%esp
  80019d:	eb b0                	jmp    80014f <umain+0x11c>
		cprintf("parent received correct message\n");
  80019f:	83 ec 0c             	sub    $0xc,%esp
  8001a2:	68 3c 25 80 00       	push   $0x80253c
  8001a7:	e8 11 01 00 00       	call   8002bd <cprintf>
  8001ac:	83 c4 10             	add    $0x10,%esp
  8001af:	e9 42 ff ff ff       	jmp    8000f6 <umain+0xc3>

008001b4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8001b4:	f3 0f 1e fb          	endbr32 
  8001b8:	55                   	push   %ebp
  8001b9:	89 e5                	mov    %esp,%ebp
  8001bb:	56                   	push   %esi
  8001bc:	53                   	push   %ebx
  8001bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8001c0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8001c3:	e8 94 0a 00 00       	call   800c5c <sys_getenvid>
	if (id >= 0)
  8001c8:	85 c0                	test   %eax,%eax
  8001ca:	78 12                	js     8001de <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8001cc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8001d1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8001d4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8001d9:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8001de:	85 db                	test   %ebx,%ebx
  8001e0:	7e 07                	jle    8001e9 <libmain+0x35>
		binaryname = argv[0];
  8001e2:	8b 06                	mov    (%esi),%eax
  8001e4:	a3 08 30 80 00       	mov    %eax,0x803008

	// call user main routine
	umain(argc, argv);
  8001e9:	83 ec 08             	sub    $0x8,%esp
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	e8 40 fe ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8001f3:	e8 0a 00 00 00       	call   800202 <exit>
}
  8001f8:	83 c4 10             	add    $0x10,%esp
  8001fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8001fe:	5b                   	pop    %ebx
  8001ff:	5e                   	pop    %esi
  800200:	5d                   	pop    %ebp
  800201:	c3                   	ret    

00800202 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800202:	f3 0f 1e fb          	endbr32 
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80020c:	e8 21 14 00 00       	call   801632 <close_all>
	sys_env_destroy(0);
  800211:	83 ec 0c             	sub    $0xc,%esp
  800214:	6a 00                	push   $0x0
  800216:	e8 1b 0a 00 00       	call   800c36 <sys_env_destroy>
}
  80021b:	83 c4 10             	add    $0x10,%esp
  80021e:	c9                   	leave  
  80021f:	c3                   	ret    

00800220 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800220:	f3 0f 1e fb          	endbr32 
  800224:	55                   	push   %ebp
  800225:	89 e5                	mov    %esp,%ebp
  800227:	53                   	push   %ebx
  800228:	83 ec 04             	sub    $0x4,%esp
  80022b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80022e:	8b 13                	mov    (%ebx),%edx
  800230:	8d 42 01             	lea    0x1(%edx),%eax
  800233:	89 03                	mov    %eax,(%ebx)
  800235:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800238:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80023c:	3d ff 00 00 00       	cmp    $0xff,%eax
  800241:	74 09                	je     80024c <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800243:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800247:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80024a:	c9                   	leave  
  80024b:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80024c:	83 ec 08             	sub    $0x8,%esp
  80024f:	68 ff 00 00 00       	push   $0xff
  800254:	8d 43 08             	lea    0x8(%ebx),%eax
  800257:	50                   	push   %eax
  800258:	e8 87 09 00 00       	call   800be4 <sys_cputs>
		b->idx = 0;
  80025d:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800263:	83 c4 10             	add    $0x10,%esp
  800266:	eb db                	jmp    800243 <putch+0x23>

00800268 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800268:	f3 0f 1e fb          	endbr32 
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800275:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80027c:	00 00 00 
	b.cnt = 0;
  80027f:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800286:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800289:	ff 75 0c             	pushl  0xc(%ebp)
  80028c:	ff 75 08             	pushl  0x8(%ebp)
  80028f:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800295:	50                   	push   %eax
  800296:	68 20 02 80 00       	push   $0x800220
  80029b:	e8 80 01 00 00       	call   800420 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8002a0:	83 c4 08             	add    $0x8,%esp
  8002a3:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8002a9:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8002af:	50                   	push   %eax
  8002b0:	e8 2f 09 00 00       	call   800be4 <sys_cputs>

	return b.cnt;
}
  8002b5:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8002bb:	c9                   	leave  
  8002bc:	c3                   	ret    

008002bd <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8002bd:	f3 0f 1e fb          	endbr32 
  8002c1:	55                   	push   %ebp
  8002c2:	89 e5                	mov    %esp,%ebp
  8002c4:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8002c7:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8002ca:	50                   	push   %eax
  8002cb:	ff 75 08             	pushl  0x8(%ebp)
  8002ce:	e8 95 ff ff ff       	call   800268 <vcprintf>
	va_end(ap);

	return cnt;
}
  8002d3:	c9                   	leave  
  8002d4:	c3                   	ret    

008002d5 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	57                   	push   %edi
  8002d9:	56                   	push   %esi
  8002da:	53                   	push   %ebx
  8002db:	83 ec 1c             	sub    $0x1c,%esp
  8002de:	89 c7                	mov    %eax,%edi
  8002e0:	89 d6                	mov    %edx,%esi
  8002e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8002e5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002e8:	89 d1                	mov    %edx,%ecx
  8002ea:	89 c2                	mov    %eax,%edx
  8002ec:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8002ef:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  8002f2:	8b 45 10             	mov    0x10(%ebp),%eax
  8002f5:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  8002f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8002fb:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800302:	39 c2                	cmp    %eax,%edx
  800304:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800307:	72 3e                	jb     800347 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800309:	83 ec 0c             	sub    $0xc,%esp
  80030c:	ff 75 18             	pushl  0x18(%ebp)
  80030f:	83 eb 01             	sub    $0x1,%ebx
  800312:	53                   	push   %ebx
  800313:	50                   	push   %eax
  800314:	83 ec 08             	sub    $0x8,%esp
  800317:	ff 75 e4             	pushl  -0x1c(%ebp)
  80031a:	ff 75 e0             	pushl  -0x20(%ebp)
  80031d:	ff 75 dc             	pushl  -0x24(%ebp)
  800320:	ff 75 d8             	pushl  -0x28(%ebp)
  800323:	e8 78 1f 00 00       	call   8022a0 <__udivdi3>
  800328:	83 c4 18             	add    $0x18,%esp
  80032b:	52                   	push   %edx
  80032c:	50                   	push   %eax
  80032d:	89 f2                	mov    %esi,%edx
  80032f:	89 f8                	mov    %edi,%eax
  800331:	e8 9f ff ff ff       	call   8002d5 <printnum>
  800336:	83 c4 20             	add    $0x20,%esp
  800339:	eb 13                	jmp    80034e <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80033b:	83 ec 08             	sub    $0x8,%esp
  80033e:	56                   	push   %esi
  80033f:	ff 75 18             	pushl  0x18(%ebp)
  800342:	ff d7                	call   *%edi
  800344:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800347:	83 eb 01             	sub    $0x1,%ebx
  80034a:	85 db                	test   %ebx,%ebx
  80034c:	7f ed                	jg     80033b <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80034e:	83 ec 08             	sub    $0x8,%esp
  800351:	56                   	push   %esi
  800352:	83 ec 04             	sub    $0x4,%esp
  800355:	ff 75 e4             	pushl  -0x1c(%ebp)
  800358:	ff 75 e0             	pushl  -0x20(%ebp)
  80035b:	ff 75 dc             	pushl  -0x24(%ebp)
  80035e:	ff 75 d8             	pushl  -0x28(%ebp)
  800361:	e8 4a 20 00 00       	call   8023b0 <__umoddi3>
  800366:	83 c4 14             	add    $0x14,%esp
  800369:	0f be 80 b4 25 80 00 	movsbl 0x8025b4(%eax),%eax
  800370:	50                   	push   %eax
  800371:	ff d7                	call   *%edi
}
  800373:	83 c4 10             	add    $0x10,%esp
  800376:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800379:	5b                   	pop    %ebx
  80037a:	5e                   	pop    %esi
  80037b:	5f                   	pop    %edi
  80037c:	5d                   	pop    %ebp
  80037d:	c3                   	ret    

0080037e <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80037e:	83 fa 01             	cmp    $0x1,%edx
  800381:	7f 13                	jg     800396 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800383:	85 d2                	test   %edx,%edx
  800385:	74 1c                	je     8003a3 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800387:	8b 10                	mov    (%eax),%edx
  800389:	8d 4a 04             	lea    0x4(%edx),%ecx
  80038c:	89 08                	mov    %ecx,(%eax)
  80038e:	8b 02                	mov    (%edx),%eax
  800390:	ba 00 00 00 00       	mov    $0x0,%edx
  800395:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800396:	8b 10                	mov    (%eax),%edx
  800398:	8d 4a 08             	lea    0x8(%edx),%ecx
  80039b:	89 08                	mov    %ecx,(%eax)
  80039d:	8b 02                	mov    (%edx),%eax
  80039f:	8b 52 04             	mov    0x4(%edx),%edx
  8003a2:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8003a3:	8b 10                	mov    (%eax),%edx
  8003a5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003a8:	89 08                	mov    %ecx,(%eax)
  8003aa:	8b 02                	mov    (%edx),%eax
  8003ac:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8003b1:	c3                   	ret    

008003b2 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8003b2:	83 fa 01             	cmp    $0x1,%edx
  8003b5:	7f 0f                	jg     8003c6 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8003b7:	85 d2                	test   %edx,%edx
  8003b9:	74 18                	je     8003d3 <getint+0x21>
		return va_arg(*ap, long);
  8003bb:	8b 10                	mov    (%eax),%edx
  8003bd:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003c0:	89 08                	mov    %ecx,(%eax)
  8003c2:	8b 02                	mov    (%edx),%eax
  8003c4:	99                   	cltd   
  8003c5:	c3                   	ret    
		return va_arg(*ap, long long);
  8003c6:	8b 10                	mov    (%eax),%edx
  8003c8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8003cb:	89 08                	mov    %ecx,(%eax)
  8003cd:	8b 02                	mov    (%edx),%eax
  8003cf:	8b 52 04             	mov    0x4(%edx),%edx
  8003d2:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8003d3:	8b 10                	mov    (%eax),%edx
  8003d5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8003d8:	89 08                	mov    %ecx,(%eax)
  8003da:	8b 02                	mov    (%edx),%eax
  8003dc:	99                   	cltd   
}
  8003dd:	c3                   	ret    

008003de <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8003de:	f3 0f 1e fb          	endbr32 
  8003e2:	55                   	push   %ebp
  8003e3:	89 e5                	mov    %esp,%ebp
  8003e5:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8003e8:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8003ec:	8b 10                	mov    (%eax),%edx
  8003ee:	3b 50 04             	cmp    0x4(%eax),%edx
  8003f1:	73 0a                	jae    8003fd <sprintputch+0x1f>
		*b->buf++ = ch;
  8003f3:	8d 4a 01             	lea    0x1(%edx),%ecx
  8003f6:	89 08                	mov    %ecx,(%eax)
  8003f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fb:	88 02                	mov    %al,(%edx)
}
  8003fd:	5d                   	pop    %ebp
  8003fe:	c3                   	ret    

008003ff <printfmt>:
{
  8003ff:	f3 0f 1e fb          	endbr32 
  800403:	55                   	push   %ebp
  800404:	89 e5                	mov    %esp,%ebp
  800406:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800409:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80040c:	50                   	push   %eax
  80040d:	ff 75 10             	pushl  0x10(%ebp)
  800410:	ff 75 0c             	pushl  0xc(%ebp)
  800413:	ff 75 08             	pushl  0x8(%ebp)
  800416:	e8 05 00 00 00       	call   800420 <vprintfmt>
}
  80041b:	83 c4 10             	add    $0x10,%esp
  80041e:	c9                   	leave  
  80041f:	c3                   	ret    

00800420 <vprintfmt>:
{
  800420:	f3 0f 1e fb          	endbr32 
  800424:	55                   	push   %ebp
  800425:	89 e5                	mov    %esp,%ebp
  800427:	57                   	push   %edi
  800428:	56                   	push   %esi
  800429:	53                   	push   %ebx
  80042a:	83 ec 2c             	sub    $0x2c,%esp
  80042d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800430:	8b 75 0c             	mov    0xc(%ebp),%esi
  800433:	8b 7d 10             	mov    0x10(%ebp),%edi
  800436:	e9 86 02 00 00       	jmp    8006c1 <vprintfmt+0x2a1>
		padc = ' ';
  80043b:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80043f:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800446:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80044d:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800454:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800459:	8d 47 01             	lea    0x1(%edi),%eax
  80045c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80045f:	0f b6 17             	movzbl (%edi),%edx
  800462:	8d 42 dd             	lea    -0x23(%edx),%eax
  800465:	3c 55                	cmp    $0x55,%al
  800467:	0f 87 df 02 00 00    	ja     80074c <vprintfmt+0x32c>
  80046d:	0f b6 c0             	movzbl %al,%eax
  800470:	3e ff 24 85 00 27 80 	notrack jmp *0x802700(,%eax,4)
  800477:	00 
  800478:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80047b:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80047f:	eb d8                	jmp    800459 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800481:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800484:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800488:	eb cf                	jmp    800459 <vprintfmt+0x39>
  80048a:	0f b6 d2             	movzbl %dl,%edx
  80048d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800490:	b8 00 00 00 00       	mov    $0x0,%eax
  800495:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800498:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80049b:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80049f:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8004a2:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8004a5:	83 f9 09             	cmp    $0x9,%ecx
  8004a8:	77 52                	ja     8004fc <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  8004aa:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8004ad:	eb e9                	jmp    800498 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8004af:	8b 45 14             	mov    0x14(%ebp),%eax
  8004b2:	8d 50 04             	lea    0x4(%eax),%edx
  8004b5:	89 55 14             	mov    %edx,0x14(%ebp)
  8004b8:	8b 00                	mov    (%eax),%eax
  8004ba:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004bd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8004c0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8004c4:	79 93                	jns    800459 <vprintfmt+0x39>
				width = precision, precision = -1;
  8004c6:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8004c9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8004cc:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8004d3:	eb 84                	jmp    800459 <vprintfmt+0x39>
  8004d5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004d8:	85 c0                	test   %eax,%eax
  8004da:	ba 00 00 00 00       	mov    $0x0,%edx
  8004df:	0f 49 d0             	cmovns %eax,%edx
  8004e2:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8004e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8004e8:	e9 6c ff ff ff       	jmp    800459 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8004ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  8004f0:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  8004f7:	e9 5d ff ff ff       	jmp    800459 <vprintfmt+0x39>
  8004fc:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8004ff:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800502:	eb bc                	jmp    8004c0 <vprintfmt+0xa0>
			lflag++;
  800504:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800507:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80050a:	e9 4a ff ff ff       	jmp    800459 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80050f:	8b 45 14             	mov    0x14(%ebp),%eax
  800512:	8d 50 04             	lea    0x4(%eax),%edx
  800515:	89 55 14             	mov    %edx,0x14(%ebp)
  800518:	83 ec 08             	sub    $0x8,%esp
  80051b:	56                   	push   %esi
  80051c:	ff 30                	pushl  (%eax)
  80051e:	ff d3                	call   *%ebx
			break;
  800520:	83 c4 10             	add    $0x10,%esp
  800523:	e9 96 01 00 00       	jmp    8006be <vprintfmt+0x29e>
			err = va_arg(ap, int);
  800528:	8b 45 14             	mov    0x14(%ebp),%eax
  80052b:	8d 50 04             	lea    0x4(%eax),%edx
  80052e:	89 55 14             	mov    %edx,0x14(%ebp)
  800531:	8b 00                	mov    (%eax),%eax
  800533:	99                   	cltd   
  800534:	31 d0                	xor    %edx,%eax
  800536:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800538:	83 f8 0f             	cmp    $0xf,%eax
  80053b:	7f 20                	jg     80055d <vprintfmt+0x13d>
  80053d:	8b 14 85 60 28 80 00 	mov    0x802860(,%eax,4),%edx
  800544:	85 d2                	test   %edx,%edx
  800546:	74 15                	je     80055d <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  800548:	52                   	push   %edx
  800549:	68 89 2b 80 00       	push   $0x802b89
  80054e:	56                   	push   %esi
  80054f:	53                   	push   %ebx
  800550:	e8 aa fe ff ff       	call   8003ff <printfmt>
  800555:	83 c4 10             	add    $0x10,%esp
  800558:	e9 61 01 00 00       	jmp    8006be <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  80055d:	50                   	push   %eax
  80055e:	68 cc 25 80 00       	push   $0x8025cc
  800563:	56                   	push   %esi
  800564:	53                   	push   %ebx
  800565:	e8 95 fe ff ff       	call   8003ff <printfmt>
  80056a:	83 c4 10             	add    $0x10,%esp
  80056d:	e9 4c 01 00 00       	jmp    8006be <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  800572:	8b 45 14             	mov    0x14(%ebp),%eax
  800575:	8d 50 04             	lea    0x4(%eax),%edx
  800578:	89 55 14             	mov    %edx,0x14(%ebp)
  80057b:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  80057d:	85 c9                	test   %ecx,%ecx
  80057f:	b8 c5 25 80 00       	mov    $0x8025c5,%eax
  800584:	0f 45 c1             	cmovne %ecx,%eax
  800587:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80058a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80058e:	7e 06                	jle    800596 <vprintfmt+0x176>
  800590:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800594:	75 0d                	jne    8005a3 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  800596:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800599:	89 c7                	mov    %eax,%edi
  80059b:	03 45 e0             	add    -0x20(%ebp),%eax
  80059e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005a1:	eb 57                	jmp    8005fa <vprintfmt+0x1da>
  8005a3:	83 ec 08             	sub    $0x8,%esp
  8005a6:	ff 75 d8             	pushl  -0x28(%ebp)
  8005a9:	ff 75 cc             	pushl  -0x34(%ebp)
  8005ac:	e8 4f 02 00 00       	call   800800 <strnlen>
  8005b1:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005b4:	29 c2                	sub    %eax,%edx
  8005b6:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005b9:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8005bc:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8005c0:	89 5d 08             	mov    %ebx,0x8(%ebp)
  8005c3:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8005c5:	85 db                	test   %ebx,%ebx
  8005c7:	7e 10                	jle    8005d9 <vprintfmt+0x1b9>
					putch(padc, putdat);
  8005c9:	83 ec 08             	sub    $0x8,%esp
  8005cc:	56                   	push   %esi
  8005cd:	57                   	push   %edi
  8005ce:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8005d1:	83 eb 01             	sub    $0x1,%ebx
  8005d4:	83 c4 10             	add    $0x10,%esp
  8005d7:	eb ec                	jmp    8005c5 <vprintfmt+0x1a5>
  8005d9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8005dc:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8005df:	85 d2                	test   %edx,%edx
  8005e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8005e6:	0f 49 c2             	cmovns %edx,%eax
  8005e9:	29 c2                	sub    %eax,%edx
  8005eb:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8005ee:	eb a6                	jmp    800596 <vprintfmt+0x176>
					putch(ch, putdat);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	56                   	push   %esi
  8005f4:	52                   	push   %edx
  8005f5:	ff d3                	call   *%ebx
  8005f7:	83 c4 10             	add    $0x10,%esp
  8005fa:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8005fd:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  8005ff:	83 c7 01             	add    $0x1,%edi
  800602:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800606:	0f be d0             	movsbl %al,%edx
  800609:	85 d2                	test   %edx,%edx
  80060b:	74 42                	je     80064f <vprintfmt+0x22f>
  80060d:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800611:	78 06                	js     800619 <vprintfmt+0x1f9>
  800613:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800617:	78 1e                	js     800637 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  800619:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80061d:	74 d1                	je     8005f0 <vprintfmt+0x1d0>
  80061f:	0f be c0             	movsbl %al,%eax
  800622:	83 e8 20             	sub    $0x20,%eax
  800625:	83 f8 5e             	cmp    $0x5e,%eax
  800628:	76 c6                	jbe    8005f0 <vprintfmt+0x1d0>
					putch('?', putdat);
  80062a:	83 ec 08             	sub    $0x8,%esp
  80062d:	56                   	push   %esi
  80062e:	6a 3f                	push   $0x3f
  800630:	ff d3                	call   *%ebx
  800632:	83 c4 10             	add    $0x10,%esp
  800635:	eb c3                	jmp    8005fa <vprintfmt+0x1da>
  800637:	89 cf                	mov    %ecx,%edi
  800639:	eb 0e                	jmp    800649 <vprintfmt+0x229>
				putch(' ', putdat);
  80063b:	83 ec 08             	sub    $0x8,%esp
  80063e:	56                   	push   %esi
  80063f:	6a 20                	push   $0x20
  800641:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800643:	83 ef 01             	sub    $0x1,%edi
  800646:	83 c4 10             	add    $0x10,%esp
  800649:	85 ff                	test   %edi,%edi
  80064b:	7f ee                	jg     80063b <vprintfmt+0x21b>
  80064d:	eb 6f                	jmp    8006be <vprintfmt+0x29e>
  80064f:	89 cf                	mov    %ecx,%edi
  800651:	eb f6                	jmp    800649 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  800653:	89 ca                	mov    %ecx,%edx
  800655:	8d 45 14             	lea    0x14(%ebp),%eax
  800658:	e8 55 fd ff ff       	call   8003b2 <getint>
  80065d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800660:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800663:	85 d2                	test   %edx,%edx
  800665:	78 0b                	js     800672 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  800667:	89 d1                	mov    %edx,%ecx
  800669:	89 c2                	mov    %eax,%edx
			base = 10;
  80066b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800670:	eb 32                	jmp    8006a4 <vprintfmt+0x284>
				putch('-', putdat);
  800672:	83 ec 08             	sub    $0x8,%esp
  800675:	56                   	push   %esi
  800676:	6a 2d                	push   $0x2d
  800678:	ff d3                	call   *%ebx
				num = -(long long) num;
  80067a:	8b 55 d8             	mov    -0x28(%ebp),%edx
  80067d:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800680:	f7 da                	neg    %edx
  800682:	83 d1 00             	adc    $0x0,%ecx
  800685:	f7 d9                	neg    %ecx
  800687:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80068a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80068f:	eb 13                	jmp    8006a4 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800691:	89 ca                	mov    %ecx,%edx
  800693:	8d 45 14             	lea    0x14(%ebp),%eax
  800696:	e8 e3 fc ff ff       	call   80037e <getuint>
  80069b:	89 d1                	mov    %edx,%ecx
  80069d:	89 c2                	mov    %eax,%edx
			base = 10;
  80069f:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  8006a4:	83 ec 0c             	sub    $0xc,%esp
  8006a7:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006ab:	57                   	push   %edi
  8006ac:	ff 75 e0             	pushl  -0x20(%ebp)
  8006af:	50                   	push   %eax
  8006b0:	51                   	push   %ecx
  8006b1:	52                   	push   %edx
  8006b2:	89 f2                	mov    %esi,%edx
  8006b4:	89 d8                	mov    %ebx,%eax
  8006b6:	e8 1a fc ff ff       	call   8002d5 <printnum>
			break;
  8006bb:	83 c4 20             	add    $0x20,%esp
{
  8006be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8006c1:	83 c7 01             	add    $0x1,%edi
  8006c4:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8006c8:	83 f8 25             	cmp    $0x25,%eax
  8006cb:	0f 84 6a fd ff ff    	je     80043b <vprintfmt+0x1b>
			if (ch == '\0')
  8006d1:	85 c0                	test   %eax,%eax
  8006d3:	0f 84 93 00 00 00    	je     80076c <vprintfmt+0x34c>
			putch(ch, putdat);
  8006d9:	83 ec 08             	sub    $0x8,%esp
  8006dc:	56                   	push   %esi
  8006dd:	50                   	push   %eax
  8006de:	ff d3                	call   *%ebx
  8006e0:	83 c4 10             	add    $0x10,%esp
  8006e3:	eb dc                	jmp    8006c1 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  8006e5:	89 ca                	mov    %ecx,%edx
  8006e7:	8d 45 14             	lea    0x14(%ebp),%eax
  8006ea:	e8 8f fc ff ff       	call   80037e <getuint>
  8006ef:	89 d1                	mov    %edx,%ecx
  8006f1:	89 c2                	mov    %eax,%edx
			base = 8;
  8006f3:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  8006f8:	eb aa                	jmp    8006a4 <vprintfmt+0x284>
			putch('0', putdat);
  8006fa:	83 ec 08             	sub    $0x8,%esp
  8006fd:	56                   	push   %esi
  8006fe:	6a 30                	push   $0x30
  800700:	ff d3                	call   *%ebx
			putch('x', putdat);
  800702:	83 c4 08             	add    $0x8,%esp
  800705:	56                   	push   %esi
  800706:	6a 78                	push   $0x78
  800708:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  80070a:	8b 45 14             	mov    0x14(%ebp),%eax
  80070d:	8d 50 04             	lea    0x4(%eax),%edx
  800710:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800713:	8b 10                	mov    (%eax),%edx
  800715:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80071a:	83 c4 10             	add    $0x10,%esp
			base = 16;
  80071d:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800722:	eb 80                	jmp    8006a4 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800724:	89 ca                	mov    %ecx,%edx
  800726:	8d 45 14             	lea    0x14(%ebp),%eax
  800729:	e8 50 fc ff ff       	call   80037e <getuint>
  80072e:	89 d1                	mov    %edx,%ecx
  800730:	89 c2                	mov    %eax,%edx
			base = 16;
  800732:	b8 10 00 00 00       	mov    $0x10,%eax
  800737:	e9 68 ff ff ff       	jmp    8006a4 <vprintfmt+0x284>
			putch(ch, putdat);
  80073c:	83 ec 08             	sub    $0x8,%esp
  80073f:	56                   	push   %esi
  800740:	6a 25                	push   $0x25
  800742:	ff d3                	call   *%ebx
			break;
  800744:	83 c4 10             	add    $0x10,%esp
  800747:	e9 72 ff ff ff       	jmp    8006be <vprintfmt+0x29e>
			putch('%', putdat);
  80074c:	83 ec 08             	sub    $0x8,%esp
  80074f:	56                   	push   %esi
  800750:	6a 25                	push   $0x25
  800752:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800754:	83 c4 10             	add    $0x10,%esp
  800757:	89 f8                	mov    %edi,%eax
  800759:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80075d:	74 05                	je     800764 <vprintfmt+0x344>
  80075f:	83 e8 01             	sub    $0x1,%eax
  800762:	eb f5                	jmp    800759 <vprintfmt+0x339>
  800764:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800767:	e9 52 ff ff ff       	jmp    8006be <vprintfmt+0x29e>
}
  80076c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80076f:	5b                   	pop    %ebx
  800770:	5e                   	pop    %esi
  800771:	5f                   	pop    %edi
  800772:	5d                   	pop    %ebp
  800773:	c3                   	ret    

00800774 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800774:	f3 0f 1e fb          	endbr32 
  800778:	55                   	push   %ebp
  800779:	89 e5                	mov    %esp,%ebp
  80077b:	83 ec 18             	sub    $0x18,%esp
  80077e:	8b 45 08             	mov    0x8(%ebp),%eax
  800781:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800784:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800787:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80078b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80078e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800795:	85 c0                	test   %eax,%eax
  800797:	74 26                	je     8007bf <vsnprintf+0x4b>
  800799:	85 d2                	test   %edx,%edx
  80079b:	7e 22                	jle    8007bf <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80079d:	ff 75 14             	pushl  0x14(%ebp)
  8007a0:	ff 75 10             	pushl  0x10(%ebp)
  8007a3:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8007a6:	50                   	push   %eax
  8007a7:	68 de 03 80 00       	push   $0x8003de
  8007ac:	e8 6f fc ff ff       	call   800420 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8007b1:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8007b4:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8007b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007ba:	83 c4 10             	add    $0x10,%esp
}
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    
		return -E_INVAL;
  8007bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8007c4:	eb f7                	jmp    8007bd <vsnprintf+0x49>

008007c6 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8007c6:	f3 0f 1e fb          	endbr32 
  8007ca:	55                   	push   %ebp
  8007cb:	89 e5                	mov    %esp,%ebp
  8007cd:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8007d0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8007d3:	50                   	push   %eax
  8007d4:	ff 75 10             	pushl  0x10(%ebp)
  8007d7:	ff 75 0c             	pushl  0xc(%ebp)
  8007da:	ff 75 08             	pushl  0x8(%ebp)
  8007dd:	e8 92 ff ff ff       	call   800774 <vsnprintf>
	va_end(ap);

	return rc;
}
  8007e2:	c9                   	leave  
  8007e3:	c3                   	ret    

008007e4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8007e4:	f3 0f 1e fb          	endbr32 
  8007e8:	55                   	push   %ebp
  8007e9:	89 e5                	mov    %esp,%ebp
  8007eb:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8007ee:	b8 00 00 00 00       	mov    $0x0,%eax
  8007f3:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8007f7:	74 05                	je     8007fe <strlen+0x1a>
		n++;
  8007f9:	83 c0 01             	add    $0x1,%eax
  8007fc:	eb f5                	jmp    8007f3 <strlen+0xf>
	return n;
}
  8007fe:	5d                   	pop    %ebp
  8007ff:	c3                   	ret    

00800800 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800800:	f3 0f 1e fb          	endbr32 
  800804:	55                   	push   %ebp
  800805:	89 e5                	mov    %esp,%ebp
  800807:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80080a:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80080d:	b8 00 00 00 00       	mov    $0x0,%eax
  800812:	39 d0                	cmp    %edx,%eax
  800814:	74 0d                	je     800823 <strnlen+0x23>
  800816:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80081a:	74 05                	je     800821 <strnlen+0x21>
		n++;
  80081c:	83 c0 01             	add    $0x1,%eax
  80081f:	eb f1                	jmp    800812 <strnlen+0x12>
  800821:	89 c2                	mov    %eax,%edx
	return n;
}
  800823:	89 d0                	mov    %edx,%eax
  800825:	5d                   	pop    %ebp
  800826:	c3                   	ret    

00800827 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800827:	f3 0f 1e fb          	endbr32 
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	53                   	push   %ebx
  80082f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800832:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800835:	b8 00 00 00 00       	mov    $0x0,%eax
  80083a:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  80083e:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800841:	83 c0 01             	add    $0x1,%eax
  800844:	84 d2                	test   %dl,%dl
  800846:	75 f2                	jne    80083a <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800848:	89 c8                	mov    %ecx,%eax
  80084a:	5b                   	pop    %ebx
  80084b:	5d                   	pop    %ebp
  80084c:	c3                   	ret    

0080084d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80084d:	f3 0f 1e fb          	endbr32 
  800851:	55                   	push   %ebp
  800852:	89 e5                	mov    %esp,%ebp
  800854:	53                   	push   %ebx
  800855:	83 ec 10             	sub    $0x10,%esp
  800858:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80085b:	53                   	push   %ebx
  80085c:	e8 83 ff ff ff       	call   8007e4 <strlen>
  800861:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800864:	ff 75 0c             	pushl  0xc(%ebp)
  800867:	01 d8                	add    %ebx,%eax
  800869:	50                   	push   %eax
  80086a:	e8 b8 ff ff ff       	call   800827 <strcpy>
	return dst;
}
  80086f:	89 d8                	mov    %ebx,%eax
  800871:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800874:	c9                   	leave  
  800875:	c3                   	ret    

00800876 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800876:	f3 0f 1e fb          	endbr32 
  80087a:	55                   	push   %ebp
  80087b:	89 e5                	mov    %esp,%ebp
  80087d:	56                   	push   %esi
  80087e:	53                   	push   %ebx
  80087f:	8b 75 08             	mov    0x8(%ebp),%esi
  800882:	8b 55 0c             	mov    0xc(%ebp),%edx
  800885:	89 f3                	mov    %esi,%ebx
  800887:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80088a:	89 f0                	mov    %esi,%eax
  80088c:	39 d8                	cmp    %ebx,%eax
  80088e:	74 11                	je     8008a1 <strncpy+0x2b>
		*dst++ = *src;
  800890:	83 c0 01             	add    $0x1,%eax
  800893:	0f b6 0a             	movzbl (%edx),%ecx
  800896:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800899:	80 f9 01             	cmp    $0x1,%cl
  80089c:	83 da ff             	sbb    $0xffffffff,%edx
  80089f:	eb eb                	jmp    80088c <strncpy+0x16>
	}
	return ret;
}
  8008a1:	89 f0                	mov    %esi,%eax
  8008a3:	5b                   	pop    %ebx
  8008a4:	5e                   	pop    %esi
  8008a5:	5d                   	pop    %ebp
  8008a6:	c3                   	ret    

008008a7 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  8008a7:	f3 0f 1e fb          	endbr32 
  8008ab:	55                   	push   %ebp
  8008ac:	89 e5                	mov    %esp,%ebp
  8008ae:	56                   	push   %esi
  8008af:	53                   	push   %ebx
  8008b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8008b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8008b6:	8b 55 10             	mov    0x10(%ebp),%edx
  8008b9:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  8008bb:	85 d2                	test   %edx,%edx
  8008bd:	74 21                	je     8008e0 <strlcpy+0x39>
  8008bf:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  8008c3:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  8008c5:	39 c2                	cmp    %eax,%edx
  8008c7:	74 14                	je     8008dd <strlcpy+0x36>
  8008c9:	0f b6 19             	movzbl (%ecx),%ebx
  8008cc:	84 db                	test   %bl,%bl
  8008ce:	74 0b                	je     8008db <strlcpy+0x34>
			*dst++ = *src++;
  8008d0:	83 c1 01             	add    $0x1,%ecx
  8008d3:	83 c2 01             	add    $0x1,%edx
  8008d6:	88 5a ff             	mov    %bl,-0x1(%edx)
  8008d9:	eb ea                	jmp    8008c5 <strlcpy+0x1e>
  8008db:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  8008dd:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8008e0:	29 f0                	sub    %esi,%eax
}
  8008e2:	5b                   	pop    %ebx
  8008e3:	5e                   	pop    %esi
  8008e4:	5d                   	pop    %ebp
  8008e5:	c3                   	ret    

008008e6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8008e6:	f3 0f 1e fb          	endbr32 
  8008ea:	55                   	push   %ebp
  8008eb:	89 e5                	mov    %esp,%ebp
  8008ed:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8008f0:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8008f3:	0f b6 01             	movzbl (%ecx),%eax
  8008f6:	84 c0                	test   %al,%al
  8008f8:	74 0c                	je     800906 <strcmp+0x20>
  8008fa:	3a 02                	cmp    (%edx),%al
  8008fc:	75 08                	jne    800906 <strcmp+0x20>
		p++, q++;
  8008fe:	83 c1 01             	add    $0x1,%ecx
  800901:	83 c2 01             	add    $0x1,%edx
  800904:	eb ed                	jmp    8008f3 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800906:	0f b6 c0             	movzbl %al,%eax
  800909:	0f b6 12             	movzbl (%edx),%edx
  80090c:	29 d0                	sub    %edx,%eax
}
  80090e:	5d                   	pop    %ebp
  80090f:	c3                   	ret    

00800910 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800910:	f3 0f 1e fb          	endbr32 
  800914:	55                   	push   %ebp
  800915:	89 e5                	mov    %esp,%ebp
  800917:	53                   	push   %ebx
  800918:	8b 45 08             	mov    0x8(%ebp),%eax
  80091b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80091e:	89 c3                	mov    %eax,%ebx
  800920:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800923:	eb 06                	jmp    80092b <strncmp+0x1b>
		n--, p++, q++;
  800925:	83 c0 01             	add    $0x1,%eax
  800928:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80092b:	39 d8                	cmp    %ebx,%eax
  80092d:	74 16                	je     800945 <strncmp+0x35>
  80092f:	0f b6 08             	movzbl (%eax),%ecx
  800932:	84 c9                	test   %cl,%cl
  800934:	74 04                	je     80093a <strncmp+0x2a>
  800936:	3a 0a                	cmp    (%edx),%cl
  800938:	74 eb                	je     800925 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  80093a:	0f b6 00             	movzbl (%eax),%eax
  80093d:	0f b6 12             	movzbl (%edx),%edx
  800940:	29 d0                	sub    %edx,%eax
}
  800942:	5b                   	pop    %ebx
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    
		return 0;
  800945:	b8 00 00 00 00       	mov    $0x0,%eax
  80094a:	eb f6                	jmp    800942 <strncmp+0x32>

0080094c <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  80094c:	f3 0f 1e fb          	endbr32 
  800950:	55                   	push   %ebp
  800951:	89 e5                	mov    %esp,%ebp
  800953:	8b 45 08             	mov    0x8(%ebp),%eax
  800956:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80095a:	0f b6 10             	movzbl (%eax),%edx
  80095d:	84 d2                	test   %dl,%dl
  80095f:	74 09                	je     80096a <strchr+0x1e>
		if (*s == c)
  800961:	38 ca                	cmp    %cl,%dl
  800963:	74 0a                	je     80096f <strchr+0x23>
	for (; *s; s++)
  800965:	83 c0 01             	add    $0x1,%eax
  800968:	eb f0                	jmp    80095a <strchr+0xe>
			return (char *) s;
	return 0;
  80096a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80096f:	5d                   	pop    %ebp
  800970:	c3                   	ret    

00800971 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800971:	f3 0f 1e fb          	endbr32 
  800975:	55                   	push   %ebp
  800976:	89 e5                	mov    %esp,%ebp
  800978:	8b 45 08             	mov    0x8(%ebp),%eax
  80097b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80097f:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800982:	38 ca                	cmp    %cl,%dl
  800984:	74 09                	je     80098f <strfind+0x1e>
  800986:	84 d2                	test   %dl,%dl
  800988:	74 05                	je     80098f <strfind+0x1e>
	for (; *s; s++)
  80098a:	83 c0 01             	add    $0x1,%eax
  80098d:	eb f0                	jmp    80097f <strfind+0xe>
			break;
	return (char *) s;
}
  80098f:	5d                   	pop    %ebp
  800990:	c3                   	ret    

00800991 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800991:	f3 0f 1e fb          	endbr32 
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	57                   	push   %edi
  800999:	56                   	push   %esi
  80099a:	53                   	push   %ebx
  80099b:	8b 55 08             	mov    0x8(%ebp),%edx
  80099e:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  8009a1:	85 c9                	test   %ecx,%ecx
  8009a3:	74 33                	je     8009d8 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  8009a5:	89 d0                	mov    %edx,%eax
  8009a7:	09 c8                	or     %ecx,%eax
  8009a9:	a8 03                	test   $0x3,%al
  8009ab:	75 23                	jne    8009d0 <memset+0x3f>
		c &= 0xFF;
  8009ad:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009b1:	89 d8                	mov    %ebx,%eax
  8009b3:	c1 e0 08             	shl    $0x8,%eax
  8009b6:	89 df                	mov    %ebx,%edi
  8009b8:	c1 e7 18             	shl    $0x18,%edi
  8009bb:	89 de                	mov    %ebx,%esi
  8009bd:	c1 e6 10             	shl    $0x10,%esi
  8009c0:	09 f7                	or     %esi,%edi
  8009c2:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  8009c4:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  8009c7:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  8009c9:	89 d7                	mov    %edx,%edi
  8009cb:	fc                   	cld    
  8009cc:	f3 ab                	rep stos %eax,%es:(%edi)
  8009ce:	eb 08                	jmp    8009d8 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  8009d0:	89 d7                	mov    %edx,%edi
  8009d2:	8b 45 0c             	mov    0xc(%ebp),%eax
  8009d5:	fc                   	cld    
  8009d6:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  8009d8:	89 d0                	mov    %edx,%eax
  8009da:	5b                   	pop    %ebx
  8009db:	5e                   	pop    %esi
  8009dc:	5f                   	pop    %edi
  8009dd:	5d                   	pop    %ebp
  8009de:	c3                   	ret    

008009df <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  8009df:	f3 0f 1e fb          	endbr32 
  8009e3:	55                   	push   %ebp
  8009e4:	89 e5                	mov    %esp,%ebp
  8009e6:	57                   	push   %edi
  8009e7:	56                   	push   %esi
  8009e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009eb:	8b 75 0c             	mov    0xc(%ebp),%esi
  8009ee:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  8009f1:	39 c6                	cmp    %eax,%esi
  8009f3:	73 32                	jae    800a27 <memmove+0x48>
  8009f5:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8009f8:	39 c2                	cmp    %eax,%edx
  8009fa:	76 2b                	jbe    800a27 <memmove+0x48>
		s += n;
		d += n;
  8009fc:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8009ff:	89 fe                	mov    %edi,%esi
  800a01:	09 ce                	or     %ecx,%esi
  800a03:	09 d6                	or     %edx,%esi
  800a05:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800a0b:	75 0e                	jne    800a1b <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800a0d:	83 ef 04             	sub    $0x4,%edi
  800a10:	8d 72 fc             	lea    -0x4(%edx),%esi
  800a13:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800a16:	fd                   	std    
  800a17:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a19:	eb 09                	jmp    800a24 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800a1b:	83 ef 01             	sub    $0x1,%edi
  800a1e:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800a21:	fd                   	std    
  800a22:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800a24:	fc                   	cld    
  800a25:	eb 1a                	jmp    800a41 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800a27:	89 c2                	mov    %eax,%edx
  800a29:	09 ca                	or     %ecx,%edx
  800a2b:	09 f2                	or     %esi,%edx
  800a2d:	f6 c2 03             	test   $0x3,%dl
  800a30:	75 0a                	jne    800a3c <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800a32:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800a35:	89 c7                	mov    %eax,%edi
  800a37:	fc                   	cld    
  800a38:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800a3a:	eb 05                	jmp    800a41 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800a3c:	89 c7                	mov    %eax,%edi
  800a3e:	fc                   	cld    
  800a3f:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800a41:	5e                   	pop    %esi
  800a42:	5f                   	pop    %edi
  800a43:	5d                   	pop    %ebp
  800a44:	c3                   	ret    

00800a45 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800a45:	f3 0f 1e fb          	endbr32 
  800a49:	55                   	push   %ebp
  800a4a:	89 e5                	mov    %esp,%ebp
  800a4c:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800a4f:	ff 75 10             	pushl  0x10(%ebp)
  800a52:	ff 75 0c             	pushl  0xc(%ebp)
  800a55:	ff 75 08             	pushl  0x8(%ebp)
  800a58:	e8 82 ff ff ff       	call   8009df <memmove>
}
  800a5d:	c9                   	leave  
  800a5e:	c3                   	ret    

00800a5f <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800a5f:	f3 0f 1e fb          	endbr32 
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	56                   	push   %esi
  800a67:	53                   	push   %ebx
  800a68:	8b 45 08             	mov    0x8(%ebp),%eax
  800a6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a6e:	89 c6                	mov    %eax,%esi
  800a70:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800a73:	39 f0                	cmp    %esi,%eax
  800a75:	74 1c                	je     800a93 <memcmp+0x34>
		if (*s1 != *s2)
  800a77:	0f b6 08             	movzbl (%eax),%ecx
  800a7a:	0f b6 1a             	movzbl (%edx),%ebx
  800a7d:	38 d9                	cmp    %bl,%cl
  800a7f:	75 08                	jne    800a89 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800a81:	83 c0 01             	add    $0x1,%eax
  800a84:	83 c2 01             	add    $0x1,%edx
  800a87:	eb ea                	jmp    800a73 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800a89:	0f b6 c1             	movzbl %cl,%eax
  800a8c:	0f b6 db             	movzbl %bl,%ebx
  800a8f:	29 d8                	sub    %ebx,%eax
  800a91:	eb 05                	jmp    800a98 <memcmp+0x39>
	}

	return 0;
  800a93:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a98:	5b                   	pop    %ebx
  800a99:	5e                   	pop    %esi
  800a9a:	5d                   	pop    %ebp
  800a9b:	c3                   	ret    

00800a9c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800a9c:	f3 0f 1e fb          	endbr32 
  800aa0:	55                   	push   %ebp
  800aa1:	89 e5                	mov    %esp,%ebp
  800aa3:	8b 45 08             	mov    0x8(%ebp),%eax
  800aa6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800aa9:	89 c2                	mov    %eax,%edx
  800aab:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800aae:	39 d0                	cmp    %edx,%eax
  800ab0:	73 09                	jae    800abb <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800ab2:	38 08                	cmp    %cl,(%eax)
  800ab4:	74 05                	je     800abb <memfind+0x1f>
	for (; s < ends; s++)
  800ab6:	83 c0 01             	add    $0x1,%eax
  800ab9:	eb f3                	jmp    800aae <memfind+0x12>
			break;
	return (void *) s;
}
  800abb:	5d                   	pop    %ebp
  800abc:	c3                   	ret    

00800abd <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800abd:	f3 0f 1e fb          	endbr32 
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	57                   	push   %edi
  800ac5:	56                   	push   %esi
  800ac6:	53                   	push   %ebx
  800ac7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800aca:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800acd:	eb 03                	jmp    800ad2 <strtol+0x15>
		s++;
  800acf:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ad2:	0f b6 01             	movzbl (%ecx),%eax
  800ad5:	3c 20                	cmp    $0x20,%al
  800ad7:	74 f6                	je     800acf <strtol+0x12>
  800ad9:	3c 09                	cmp    $0x9,%al
  800adb:	74 f2                	je     800acf <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800add:	3c 2b                	cmp    $0x2b,%al
  800adf:	74 2a                	je     800b0b <strtol+0x4e>
	int neg = 0;
  800ae1:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800ae6:	3c 2d                	cmp    $0x2d,%al
  800ae8:	74 2b                	je     800b15 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800aea:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800af0:	75 0f                	jne    800b01 <strtol+0x44>
  800af2:	80 39 30             	cmpb   $0x30,(%ecx)
  800af5:	74 28                	je     800b1f <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800af7:	85 db                	test   %ebx,%ebx
  800af9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800afe:	0f 44 d8             	cmove  %eax,%ebx
  800b01:	b8 00 00 00 00       	mov    $0x0,%eax
  800b06:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800b09:	eb 46                	jmp    800b51 <strtol+0x94>
		s++;
  800b0b:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800b0e:	bf 00 00 00 00       	mov    $0x0,%edi
  800b13:	eb d5                	jmp    800aea <strtol+0x2d>
		s++, neg = 1;
  800b15:	83 c1 01             	add    $0x1,%ecx
  800b18:	bf 01 00 00 00       	mov    $0x1,%edi
  800b1d:	eb cb                	jmp    800aea <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800b1f:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800b23:	74 0e                	je     800b33 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800b25:	85 db                	test   %ebx,%ebx
  800b27:	75 d8                	jne    800b01 <strtol+0x44>
		s++, base = 8;
  800b29:	83 c1 01             	add    $0x1,%ecx
  800b2c:	bb 08 00 00 00       	mov    $0x8,%ebx
  800b31:	eb ce                	jmp    800b01 <strtol+0x44>
		s += 2, base = 16;
  800b33:	83 c1 02             	add    $0x2,%ecx
  800b36:	bb 10 00 00 00       	mov    $0x10,%ebx
  800b3b:	eb c4                	jmp    800b01 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800b3d:	0f be d2             	movsbl %dl,%edx
  800b40:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800b43:	3b 55 10             	cmp    0x10(%ebp),%edx
  800b46:	7d 3a                	jge    800b82 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800b48:	83 c1 01             	add    $0x1,%ecx
  800b4b:	0f af 45 10          	imul   0x10(%ebp),%eax
  800b4f:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800b51:	0f b6 11             	movzbl (%ecx),%edx
  800b54:	8d 72 d0             	lea    -0x30(%edx),%esi
  800b57:	89 f3                	mov    %esi,%ebx
  800b59:	80 fb 09             	cmp    $0x9,%bl
  800b5c:	76 df                	jbe    800b3d <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800b5e:	8d 72 9f             	lea    -0x61(%edx),%esi
  800b61:	89 f3                	mov    %esi,%ebx
  800b63:	80 fb 19             	cmp    $0x19,%bl
  800b66:	77 08                	ja     800b70 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800b68:	0f be d2             	movsbl %dl,%edx
  800b6b:	83 ea 57             	sub    $0x57,%edx
  800b6e:	eb d3                	jmp    800b43 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800b70:	8d 72 bf             	lea    -0x41(%edx),%esi
  800b73:	89 f3                	mov    %esi,%ebx
  800b75:	80 fb 19             	cmp    $0x19,%bl
  800b78:	77 08                	ja     800b82 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800b7a:	0f be d2             	movsbl %dl,%edx
  800b7d:	83 ea 37             	sub    $0x37,%edx
  800b80:	eb c1                	jmp    800b43 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800b82:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800b86:	74 05                	je     800b8d <strtol+0xd0>
		*endptr = (char *) s;
  800b88:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b8b:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800b8d:	89 c2                	mov    %eax,%edx
  800b8f:	f7 da                	neg    %edx
  800b91:	85 ff                	test   %edi,%edi
  800b93:	0f 45 c2             	cmovne %edx,%eax
}
  800b96:	5b                   	pop    %ebx
  800b97:	5e                   	pop    %esi
  800b98:	5f                   	pop    %edi
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    

00800b9b <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	57                   	push   %edi
  800b9f:	56                   	push   %esi
  800ba0:	53                   	push   %ebx
  800ba1:	83 ec 1c             	sub    $0x1c,%esp
  800ba4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ba7:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800baa:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800bac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800baf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800bb2:	8b 7d 10             	mov    0x10(%ebp),%edi
  800bb5:	8b 75 14             	mov    0x14(%ebp),%esi
  800bb8:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800bba:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800bbe:	74 04                	je     800bc4 <syscall+0x29>
  800bc0:	85 c0                	test   %eax,%eax
  800bc2:	7f 08                	jg     800bcc <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800bc4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800bc7:	5b                   	pop    %ebx
  800bc8:	5e                   	pop    %esi
  800bc9:	5f                   	pop    %edi
  800bca:	5d                   	pop    %ebp
  800bcb:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800bcc:	83 ec 0c             	sub    $0xc,%esp
  800bcf:	50                   	push   %eax
  800bd0:	ff 75 e0             	pushl  -0x20(%ebp)
  800bd3:	68 bf 28 80 00       	push   $0x8028bf
  800bd8:	6a 23                	push   $0x23
  800bda:	68 dc 28 80 00       	push   $0x8028dc
  800bdf:	e8 a4 15 00 00       	call   802188 <_panic>

00800be4 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800be4:	f3 0f 1e fb          	endbr32 
  800be8:	55                   	push   %ebp
  800be9:	89 e5                	mov    %esp,%ebp
  800beb:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800bee:	6a 00                	push   $0x0
  800bf0:	6a 00                	push   $0x0
  800bf2:	6a 00                	push   $0x0
  800bf4:	ff 75 0c             	pushl  0xc(%ebp)
  800bf7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800bfa:	ba 00 00 00 00       	mov    $0x0,%edx
  800bff:	b8 00 00 00 00       	mov    $0x0,%eax
  800c04:	e8 92 ff ff ff       	call   800b9b <syscall>
}
  800c09:	83 c4 10             	add    $0x10,%esp
  800c0c:	c9                   	leave  
  800c0d:	c3                   	ret    

00800c0e <sys_cgetc>:

int
sys_cgetc(void)
{
  800c0e:	f3 0f 1e fb          	endbr32 
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800c18:	6a 00                	push   $0x0
  800c1a:	6a 00                	push   $0x0
  800c1c:	6a 00                	push   $0x0
  800c1e:	6a 00                	push   $0x0
  800c20:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c25:	ba 00 00 00 00       	mov    $0x0,%edx
  800c2a:	b8 01 00 00 00       	mov    $0x1,%eax
  800c2f:	e8 67 ff ff ff       	call   800b9b <syscall>
}
  800c34:	c9                   	leave  
  800c35:	c3                   	ret    

00800c36 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800c36:	f3 0f 1e fb          	endbr32 
  800c3a:	55                   	push   %ebp
  800c3b:	89 e5                	mov    %esp,%ebp
  800c3d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800c40:	6a 00                	push   $0x0
  800c42:	6a 00                	push   $0x0
  800c44:	6a 00                	push   $0x0
  800c46:	6a 00                	push   $0x0
  800c48:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c4b:	ba 01 00 00 00       	mov    $0x1,%edx
  800c50:	b8 03 00 00 00       	mov    $0x3,%eax
  800c55:	e8 41 ff ff ff       	call   800b9b <syscall>
}
  800c5a:	c9                   	leave  
  800c5b:	c3                   	ret    

00800c5c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800c5c:	f3 0f 1e fb          	endbr32 
  800c60:	55                   	push   %ebp
  800c61:	89 e5                	mov    %esp,%ebp
  800c63:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800c66:	6a 00                	push   $0x0
  800c68:	6a 00                	push   $0x0
  800c6a:	6a 00                	push   $0x0
  800c6c:	6a 00                	push   $0x0
  800c6e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c73:	ba 00 00 00 00       	mov    $0x0,%edx
  800c78:	b8 02 00 00 00       	mov    $0x2,%eax
  800c7d:	e8 19 ff ff ff       	call   800b9b <syscall>
}
  800c82:	c9                   	leave  
  800c83:	c3                   	ret    

00800c84 <sys_yield>:

void
sys_yield(void)
{
  800c84:	f3 0f 1e fb          	endbr32 
  800c88:	55                   	push   %ebp
  800c89:	89 e5                	mov    %esp,%ebp
  800c8b:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800c8e:	6a 00                	push   $0x0
  800c90:	6a 00                	push   $0x0
  800c92:	6a 00                	push   $0x0
  800c94:	6a 00                	push   $0x0
  800c96:	b9 00 00 00 00       	mov    $0x0,%ecx
  800c9b:	ba 00 00 00 00       	mov    $0x0,%edx
  800ca0:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ca5:	e8 f1 fe ff ff       	call   800b9b <syscall>
}
  800caa:	83 c4 10             	add    $0x10,%esp
  800cad:	c9                   	leave  
  800cae:	c3                   	ret    

00800caf <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800caf:	f3 0f 1e fb          	endbr32 
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800cb9:	6a 00                	push   $0x0
  800cbb:	6a 00                	push   $0x0
  800cbd:	ff 75 10             	pushl  0x10(%ebp)
  800cc0:	ff 75 0c             	pushl  0xc(%ebp)
  800cc3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cc6:	ba 01 00 00 00       	mov    $0x1,%edx
  800ccb:	b8 04 00 00 00       	mov    $0x4,%eax
  800cd0:	e8 c6 fe ff ff       	call   800b9b <syscall>
}
  800cd5:	c9                   	leave  
  800cd6:	c3                   	ret    

00800cd7 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800cd7:	f3 0f 1e fb          	endbr32 
  800cdb:	55                   	push   %ebp
  800cdc:	89 e5                	mov    %esp,%ebp
  800cde:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800ce1:	ff 75 18             	pushl  0x18(%ebp)
  800ce4:	ff 75 14             	pushl  0x14(%ebp)
  800ce7:	ff 75 10             	pushl  0x10(%ebp)
  800cea:	ff 75 0c             	pushl  0xc(%ebp)
  800ced:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cf0:	ba 01 00 00 00       	mov    $0x1,%edx
  800cf5:	b8 05 00 00 00       	mov    $0x5,%eax
  800cfa:	e8 9c fe ff ff       	call   800b9b <syscall>
}
  800cff:	c9                   	leave  
  800d00:	c3                   	ret    

00800d01 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800d01:	f3 0f 1e fb          	endbr32 
  800d05:	55                   	push   %ebp
  800d06:	89 e5                	mov    %esp,%ebp
  800d08:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800d0b:	6a 00                	push   $0x0
  800d0d:	6a 00                	push   $0x0
  800d0f:	6a 00                	push   $0x0
  800d11:	ff 75 0c             	pushl  0xc(%ebp)
  800d14:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d17:	ba 01 00 00 00       	mov    $0x1,%edx
  800d1c:	b8 06 00 00 00       	mov    $0x6,%eax
  800d21:	e8 75 fe ff ff       	call   800b9b <syscall>
}
  800d26:	c9                   	leave  
  800d27:	c3                   	ret    

00800d28 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800d28:	f3 0f 1e fb          	endbr32 
  800d2c:	55                   	push   %ebp
  800d2d:	89 e5                	mov    %esp,%ebp
  800d2f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800d32:	6a 00                	push   $0x0
  800d34:	6a 00                	push   $0x0
  800d36:	6a 00                	push   $0x0
  800d38:	ff 75 0c             	pushl  0xc(%ebp)
  800d3b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d3e:	ba 01 00 00 00       	mov    $0x1,%edx
  800d43:	b8 08 00 00 00       	mov    $0x8,%eax
  800d48:	e8 4e fe ff ff       	call   800b9b <syscall>
}
  800d4d:	c9                   	leave  
  800d4e:	c3                   	ret    

00800d4f <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800d4f:	f3 0f 1e fb          	endbr32 
  800d53:	55                   	push   %ebp
  800d54:	89 e5                	mov    %esp,%ebp
  800d56:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800d59:	6a 00                	push   $0x0
  800d5b:	6a 00                	push   $0x0
  800d5d:	6a 00                	push   $0x0
  800d5f:	ff 75 0c             	pushl  0xc(%ebp)
  800d62:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d65:	ba 01 00 00 00       	mov    $0x1,%edx
  800d6a:	b8 09 00 00 00       	mov    $0x9,%eax
  800d6f:	e8 27 fe ff ff       	call   800b9b <syscall>
}
  800d74:	c9                   	leave  
  800d75:	c3                   	ret    

00800d76 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800d76:	f3 0f 1e fb          	endbr32 
  800d7a:	55                   	push   %ebp
  800d7b:	89 e5                	mov    %esp,%ebp
  800d7d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800d80:	6a 00                	push   $0x0
  800d82:	6a 00                	push   $0x0
  800d84:	6a 00                	push   $0x0
  800d86:	ff 75 0c             	pushl  0xc(%ebp)
  800d89:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d8c:	ba 01 00 00 00       	mov    $0x1,%edx
  800d91:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d96:	e8 00 fe ff ff       	call   800b9b <syscall>
}
  800d9b:	c9                   	leave  
  800d9c:	c3                   	ret    

00800d9d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800d9d:	f3 0f 1e fb          	endbr32 
  800da1:	55                   	push   %ebp
  800da2:	89 e5                	mov    %esp,%ebp
  800da4:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800da7:	6a 00                	push   $0x0
  800da9:	ff 75 14             	pushl  0x14(%ebp)
  800dac:	ff 75 10             	pushl  0x10(%ebp)
  800daf:	ff 75 0c             	pushl  0xc(%ebp)
  800db2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db5:	ba 00 00 00 00       	mov    $0x0,%edx
  800dba:	b8 0c 00 00 00       	mov    $0xc,%eax
  800dbf:	e8 d7 fd ff ff       	call   800b9b <syscall>
}
  800dc4:	c9                   	leave  
  800dc5:	c3                   	ret    

00800dc6 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800dc6:	f3 0f 1e fb          	endbr32 
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800dd0:	6a 00                	push   $0x0
  800dd2:	6a 00                	push   $0x0
  800dd4:	6a 00                	push   $0x0
  800dd6:	6a 00                	push   $0x0
  800dd8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ddb:	ba 01 00 00 00       	mov    $0x1,%edx
  800de0:	b8 0d 00 00 00       	mov    $0xd,%eax
  800de5:	e8 b1 fd ff ff       	call   800b9b <syscall>
}
  800dea:	c9                   	leave  
  800deb:	c3                   	ret    

00800dec <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800dec:	55                   	push   %ebp
  800ded:	89 e5                	mov    %esp,%ebp
  800def:	53                   	push   %ebx
  800df0:	83 ec 04             	sub    $0x4,%esp
  800df3:	89 d3                	mov    %edx,%ebx
	int r;

	// LAB 4: Your code here.

	// Page Table Entry
	pte_t pt_e = uvpt[pn];
  800df5:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Obtenemos la virtual address
	void *v_add = (void *) (pn << PTXSHIFT);
  800dfc:	c1 e3 0c             	shl    $0xc,%ebx

	if (pt_e & PTE_SHARE) {
  800dff:	f6 c6 04             	test   $0x4,%dh
  800e02:	75 54                	jne    800e58 <duppage+0x6c>
		// Permisos compartidos
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
		if (r < 0)
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	} else if ((pt_e & PTE_W) || (pt_e & PTE_COW)) {
  800e04:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800e0a:	0f 84 8d 00 00 00    	je     800e9d <duppage+0xb1>
		// Copy on write
		r = sys_page_map(0, v_add, envid, v_add, PTE_COW | PTE_U | PTE_P);
  800e10:	83 ec 0c             	sub    $0xc,%esp
  800e13:	68 05 08 00 00       	push   $0x805
  800e18:	53                   	push   %ebx
  800e19:	50                   	push   %eax
  800e1a:	53                   	push   %ebx
  800e1b:	6a 00                	push   $0x0
  800e1d:	e8 b5 fe ff ff       	call   800cd7 <sys_page_map>
		if (r < 0)
  800e22:	83 c4 20             	add    $0x20,%esp
  800e25:	85 c0                	test   %eax,%eax
  800e27:	78 5f                	js     800e88 <duppage+0x9c>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);

		r = sys_page_map(0, v_add, 0, v_add, PTE_COW | PTE_U | PTE_P);
  800e29:	83 ec 0c             	sub    $0xc,%esp
  800e2c:	68 05 08 00 00       	push   $0x805
  800e31:	53                   	push   %ebx
  800e32:	6a 00                	push   $0x0
  800e34:	53                   	push   %ebx
  800e35:	6a 00                	push   $0x0
  800e37:	e8 9b fe ff ff       	call   800cd7 <sys_page_map>
		if (r < 0)
  800e3c:	83 c4 20             	add    $0x20,%esp
  800e3f:	85 c0                	test   %eax,%eax
  800e41:	79 70                	jns    800eb3 <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800e43:	50                   	push   %eax
  800e44:	68 ec 28 80 00       	push   $0x8028ec
  800e49:	68 9b 00 00 00       	push   $0x9b
  800e4e:	68 5a 2a 80 00       	push   $0x802a5a
  800e53:	e8 30 13 00 00       	call   802188 <_panic>
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
  800e58:	83 ec 0c             	sub    $0xc,%esp
  800e5b:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800e61:	52                   	push   %edx
  800e62:	53                   	push   %ebx
  800e63:	50                   	push   %eax
  800e64:	53                   	push   %ebx
  800e65:	6a 00                	push   $0x0
  800e67:	e8 6b fe ff ff       	call   800cd7 <sys_page_map>
		if (r < 0)
  800e6c:	83 c4 20             	add    $0x20,%esp
  800e6f:	85 c0                	test   %eax,%eax
  800e71:	79 40                	jns    800eb3 <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800e73:	50                   	push   %eax
  800e74:	68 ec 28 80 00       	push   $0x8028ec
  800e79:	68 92 00 00 00       	push   $0x92
  800e7e:	68 5a 2a 80 00       	push   $0x802a5a
  800e83:	e8 00 13 00 00       	call   802188 <_panic>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800e88:	50                   	push   %eax
  800e89:	68 ec 28 80 00       	push   $0x8028ec
  800e8e:	68 97 00 00 00       	push   $0x97
  800e93:	68 5a 2a 80 00       	push   $0x802a5a
  800e98:	e8 eb 12 00 00       	call   802188 <_panic>
	} else {
		// En caso de lectura, compartir.
		r = sys_page_map(0, v_add, envid, v_add, PTE_U | PTE_P);
  800e9d:	83 ec 0c             	sub    $0xc,%esp
  800ea0:	6a 05                	push   $0x5
  800ea2:	53                   	push   %ebx
  800ea3:	50                   	push   %eax
  800ea4:	53                   	push   %ebx
  800ea5:	6a 00                	push   $0x0
  800ea7:	e8 2b fe ff ff       	call   800cd7 <sys_page_map>
		if (r < 0)
  800eac:	83 c4 20             	add    $0x20,%esp
  800eaf:	85 c0                	test   %eax,%eax
  800eb1:	78 0a                	js     800ebd <duppage+0xd1>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	}
	return 0;
}
  800eb3:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800ebb:	c9                   	leave  
  800ebc:	c3                   	ret    
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800ebd:	50                   	push   %eax
  800ebe:	68 ec 28 80 00       	push   $0x8028ec
  800ec3:	68 a0 00 00 00       	push   $0xa0
  800ec8:	68 5a 2a 80 00       	push   $0x802a5a
  800ecd:	e8 b6 12 00 00       	call   802188 <_panic>

00800ed2 <dup_or_share>:
{
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
  800ed5:	57                   	push   %edi
  800ed6:	56                   	push   %esi
  800ed7:	53                   	push   %ebx
  800ed8:	83 ec 0c             	sub    $0xc,%esp
  800edb:	89 c7                	mov    %eax,%edi
  800edd:	89 d6                	mov    %edx,%esi
  800edf:	89 cb                	mov    %ecx,%ebx
	if (perm & PTE_W) {
  800ee1:	f6 c1 02             	test   $0x2,%cl
  800ee4:	0f 84 90 00 00 00    	je     800f7a <dup_or_share+0xa8>
		if ((r = sys_page_alloc(dstenv, va, perm)) < 0)
  800eea:	83 ec 04             	sub    $0x4,%esp
  800eed:	51                   	push   %ecx
  800eee:	52                   	push   %edx
  800eef:	50                   	push   %eax
  800ef0:	e8 ba fd ff ff       	call   800caf <sys_page_alloc>
  800ef5:	83 c4 10             	add    $0x10,%esp
  800ef8:	85 c0                	test   %eax,%eax
  800efa:	78 56                	js     800f52 <dup_or_share+0x80>
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, perm)) < 0)
  800efc:	83 ec 0c             	sub    $0xc,%esp
  800eff:	53                   	push   %ebx
  800f00:	68 00 00 40 00       	push   $0x400000
  800f05:	6a 00                	push   $0x0
  800f07:	56                   	push   %esi
  800f08:	57                   	push   %edi
  800f09:	e8 c9 fd ff ff       	call   800cd7 <sys_page_map>
  800f0e:	83 c4 20             	add    $0x20,%esp
  800f11:	85 c0                	test   %eax,%eax
  800f13:	78 51                	js     800f66 <dup_or_share+0x94>
		memmove(UTEMP, va, PGSIZE);
  800f15:	83 ec 04             	sub    $0x4,%esp
  800f18:	68 00 10 00 00       	push   $0x1000
  800f1d:	56                   	push   %esi
  800f1e:	68 00 00 40 00       	push   $0x400000
  800f23:	e8 b7 fa ff ff       	call   8009df <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  800f28:	83 c4 08             	add    $0x8,%esp
  800f2b:	68 00 00 40 00       	push   $0x400000
  800f30:	6a 00                	push   $0x0
  800f32:	e8 ca fd ff ff       	call   800d01 <sys_page_unmap>
  800f37:	83 c4 10             	add    $0x10,%esp
  800f3a:	85 c0                	test   %eax,%eax
  800f3c:	79 51                	jns    800f8f <dup_or_share+0xbd>
			panic("sys_page_unmap failed at dup_or_share");
  800f3e:	83 ec 04             	sub    $0x4,%esp
  800f41:	68 5c 29 80 00       	push   $0x80295c
  800f46:	6a 18                	push   $0x18
  800f48:	68 5a 2a 80 00       	push   $0x802a5a
  800f4d:	e8 36 12 00 00       	call   802188 <_panic>
			panic("sys_page_alloc failed at dup_or_share");
  800f52:	83 ec 04             	sub    $0x4,%esp
  800f55:	68 10 29 80 00       	push   $0x802910
  800f5a:	6a 13                	push   $0x13
  800f5c:	68 5a 2a 80 00       	push   $0x802a5a
  800f61:	e8 22 12 00 00       	call   802188 <_panic>
			panic("sys_page_map failed at dup_or_share");
  800f66:	83 ec 04             	sub    $0x4,%esp
  800f69:	68 38 29 80 00       	push   $0x802938
  800f6e:	6a 15                	push   $0x15
  800f70:	68 5a 2a 80 00       	push   $0x802a5a
  800f75:	e8 0e 12 00 00       	call   802188 <_panic>
		if ((r = sys_page_map(0, va, dstenv, va, perm)) < 0)
  800f7a:	83 ec 0c             	sub    $0xc,%esp
  800f7d:	51                   	push   %ecx
  800f7e:	52                   	push   %edx
  800f7f:	50                   	push   %eax
  800f80:	52                   	push   %edx
  800f81:	6a 00                	push   $0x0
  800f83:	e8 4f fd ff ff       	call   800cd7 <sys_page_map>
  800f88:	83 c4 20             	add    $0x20,%esp
  800f8b:	85 c0                	test   %eax,%eax
  800f8d:	78 08                	js     800f97 <dup_or_share+0xc5>
}
  800f8f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f92:	5b                   	pop    %ebx
  800f93:	5e                   	pop    %esi
  800f94:	5f                   	pop    %edi
  800f95:	5d                   	pop    %ebp
  800f96:	c3                   	ret    
			panic("sys_page_map failed at dup_or_share");
  800f97:	83 ec 04             	sub    $0x4,%esp
  800f9a:	68 38 29 80 00       	push   $0x802938
  800f9f:	6a 1c                	push   $0x1c
  800fa1:	68 5a 2a 80 00       	push   $0x802a5a
  800fa6:	e8 dd 11 00 00       	call   802188 <_panic>

00800fab <pgfault>:
{
  800fab:	f3 0f 1e fb          	endbr32 
  800faf:	55                   	push   %ebp
  800fb0:	89 e5                	mov    %esp,%ebp
  800fb2:	53                   	push   %ebx
  800fb3:	83 ec 04             	sub    $0x4,%esp
  800fb6:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  800fb9:	8b 18                	mov    (%eax),%ebx
	pte_t pt_e = uvpt[PGNUM(addr)];
  800fbb:	89 da                	mov    %ebx,%edx
  800fbd:	c1 ea 0c             	shr    $0xc,%edx
  800fc0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if ((err & FEC_WR) == 0)
  800fc7:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  800fcb:	74 6e                	je     80103b <pgfault+0x90>
	if ((pt_e & PTE_COW) == 0)
  800fcd:	f6 c6 08             	test   $0x8,%dh
  800fd0:	74 7d                	je     80104f <pgfault+0xa4>
	if ((r = sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  800fd2:	83 ec 04             	sub    $0x4,%esp
  800fd5:	6a 07                	push   $0x7
  800fd7:	68 00 f0 7f 00       	push   $0x7ff000
  800fdc:	6a 00                	push   $0x0
  800fde:	e8 cc fc ff ff       	call   800caf <sys_page_alloc>
  800fe3:	83 c4 10             	add    $0x10,%esp
  800fe6:	85 c0                	test   %eax,%eax
  800fe8:	78 79                	js     801063 <pgfault+0xb8>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  800fea:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  800ff0:	83 ec 04             	sub    $0x4,%esp
  800ff3:	68 00 10 00 00       	push   $0x1000
  800ff8:	53                   	push   %ebx
  800ff9:	68 00 f0 7f 00       	push   $0x7ff000
  800ffe:	e8 dc f9 ff ff       	call   8009df <memmove>
	if ((r = sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U)) <
  801003:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  80100a:	53                   	push   %ebx
  80100b:	6a 00                	push   $0x0
  80100d:	68 00 f0 7f 00       	push   $0x7ff000
  801012:	6a 00                	push   $0x0
  801014:	e8 be fc ff ff       	call   800cd7 <sys_page_map>
  801019:	83 c4 20             	add    $0x20,%esp
  80101c:	85 c0                	test   %eax,%eax
  80101e:	78 57                	js     801077 <pgfault+0xcc>
	if ((r = sys_page_unmap(0, (void *) PFTEMP)) < 0)
  801020:	83 ec 08             	sub    $0x8,%esp
  801023:	68 00 f0 7f 00       	push   $0x7ff000
  801028:	6a 00                	push   $0x0
  80102a:	e8 d2 fc ff ff       	call   800d01 <sys_page_unmap>
  80102f:	83 c4 10             	add    $0x10,%esp
  801032:	85 c0                	test   %eax,%eax
  801034:	78 55                	js     80108b <pgfault+0xe0>
}
  801036:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801039:	c9                   	leave  
  80103a:	c3                   	ret    
		panic("ERROR EN PGFAULT: WRITE");
  80103b:	83 ec 04             	sub    $0x4,%esp
  80103e:	68 65 2a 80 00       	push   $0x802a65
  801043:	6a 5e                	push   $0x5e
  801045:	68 5a 2a 80 00       	push   $0x802a5a
  80104a:	e8 39 11 00 00       	call   802188 <_panic>
		panic("ERROR EN PGFAULT: COPY-ON-WRITE");
  80104f:	83 ec 04             	sub    $0x4,%esp
  801052:	68 84 29 80 00       	push   $0x802984
  801057:	6a 62                	push   $0x62
  801059:	68 5a 2a 80 00       	push   $0x802a5a
  80105e:	e8 25 11 00 00       	call   802188 <_panic>
		panic("pgfault failed");
  801063:	83 ec 04             	sub    $0x4,%esp
  801066:	68 7d 2a 80 00       	push   $0x802a7d
  80106b:	6a 6d                	push   $0x6d
  80106d:	68 5a 2a 80 00       	push   $0x802a5a
  801072:	e8 11 11 00 00       	call   802188 <_panic>
		panic("pgfault failed");
  801077:	83 ec 04             	sub    $0x4,%esp
  80107a:	68 7d 2a 80 00       	push   $0x802a7d
  80107f:	6a 72                	push   $0x72
  801081:	68 5a 2a 80 00       	push   $0x802a5a
  801086:	e8 fd 10 00 00       	call   802188 <_panic>
		panic("pgfault failed");
  80108b:	83 ec 04             	sub    $0x4,%esp
  80108e:	68 7d 2a 80 00       	push   $0x802a7d
  801093:	6a 74                	push   $0x74
  801095:	68 5a 2a 80 00       	push   $0x802a5a
  80109a:	e8 e9 10 00 00       	call   802188 <_panic>

0080109f <fork_v0>:
{
  80109f:	f3 0f 1e fb          	endbr32 
  8010a3:	55                   	push   %ebp
  8010a4:	89 e5                	mov    %esp,%ebp
  8010a6:	57                   	push   %edi
  8010a7:	56                   	push   %esi
  8010a8:	53                   	push   %ebx
  8010a9:	83 ec 1c             	sub    $0x1c,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8010ac:	b8 07 00 00 00       	mov    $0x7,%eax
  8010b1:	cd 30                	int    $0x30
  8010b3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010b6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (envid < 0)
  8010b9:	85 c0                	test   %eax,%eax
  8010bb:	78 1d                	js     8010da <fork_v0+0x3b>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  8010bd:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  8010c2:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8010c6:	74 26                	je     8010ee <fork_v0+0x4f>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  8010c8:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  8010cd:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
			        (pte_t *) (PGADDR(PDX(uvpt),
  8010d3:	bf 00 00 40 ef       	mov    $0xef400000,%edi
  8010d8:	eb 4b                	jmp    801125 <fork_v0+0x86>
		panic("sys_exofork failed");
  8010da:	83 ec 04             	sub    $0x4,%esp
  8010dd:	68 8c 2a 80 00       	push   $0x802a8c
  8010e2:	6a 2b                	push   $0x2b
  8010e4:	68 5a 2a 80 00       	push   $0x802a5a
  8010e9:	e8 9a 10 00 00       	call   802188 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
  8010ee:	e8 69 fb ff ff       	call   800c5c <sys_getenvid>
  8010f3:	25 ff 03 00 00       	and    $0x3ff,%eax
  8010f8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8010fb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801100:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801105:	eb 68                	jmp    80116f <fork_v0+0xd0>
				dup_or_share(envid,
  801107:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  80110d:	89 da                	mov    %ebx,%edx
  80110f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801112:	e8 bb fd ff ff       	call   800ed2 <dup_or_share>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  801117:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  80111d:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801123:	74 36                	je     80115b <fork_v0+0xbc>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  801125:	89 d8                	mov    %ebx,%eax
  801127:	c1 e8 16             	shr    $0x16,%eax
  80112a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801131:	09 f2                	or     %esi,%edx
		if ((*pgdirentry) & PTE_P) {
  801133:	f6 02 01             	testb  $0x1,(%edx)
  801136:	74 df                	je     801117 <fork_v0+0x78>
			        (pte_t *) (PGADDR(PDX(uvpt),
  801138:	89 da                	mov    %ebx,%edx
  80113a:	c1 ea 0a             	shr    $0xa,%edx
  80113d:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  801143:	c1 e0 0c             	shl    $0xc,%eax
  801146:	89 f9                	mov    %edi,%ecx
  801148:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
  80114e:	09 c8                	or     %ecx,%eax
  801150:	09 d0                	or     %edx,%eax
			if ((*pgtablentry) & PTE_P)
  801152:	8b 08                	mov    (%eax),%ecx
  801154:	f6 c1 01             	test   $0x1,%cl
  801157:	74 be                	je     801117 <fork_v0+0x78>
  801159:	eb ac                	jmp    801107 <fork_v0+0x68>
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  80115b:	83 ec 08             	sub    $0x8,%esp
  80115e:	6a 02                	push   $0x2
  801160:	ff 75 e0             	pushl  -0x20(%ebp)
  801163:	e8 c0 fb ff ff       	call   800d28 <sys_env_set_status>
  801168:	83 c4 10             	add    $0x10,%esp
  80116b:	85 c0                	test   %eax,%eax
  80116d:	78 0b                	js     80117a <fork_v0+0xdb>
}
  80116f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801172:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801175:	5b                   	pop    %ebx
  801176:	5e                   	pop    %esi
  801177:	5f                   	pop    %edi
  801178:	5d                   	pop    %ebp
  801179:	c3                   	ret    
		panic("sys_env_set_status failed at fork_v0");
  80117a:	83 ec 04             	sub    $0x4,%esp
  80117d:	68 a4 29 80 00       	push   $0x8029a4
  801182:	6a 43                	push   $0x43
  801184:	68 5a 2a 80 00       	push   $0x802a5a
  801189:	e8 fa 0f 00 00       	call   802188 <_panic>

0080118e <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  80118e:	f3 0f 1e fb          	endbr32 
  801192:	55                   	push   %ebp
  801193:	89 e5                	mov    %esp,%ebp
  801195:	57                   	push   %edi
  801196:	56                   	push   %esi
  801197:	53                   	push   %ebx
  801198:	83 ec 28             	sub    $0x28,%esp
	int err;

	// handle padre
	set_pgfault_handler(pgfault);
  80119b:	68 ab 0f 80 00       	push   $0x800fab
  8011a0:	e8 2d 10 00 00       	call   8021d2 <set_pgfault_handler>
  8011a5:	b8 07 00 00 00       	mov    $0x7,%eax
  8011aa:	cd 30                	int    $0x30
  8011ac:	89 45 e0             	mov    %eax,-0x20(%ebp)

	// Proceso hijo
	envid_t e_id = sys_exofork();

	if (e_id < 0)
  8011af:	83 c4 10             	add    $0x10,%esp
  8011b2:	85 c0                	test   %eax,%eax
  8011b4:	78 2f                	js     8011e5 <fork+0x57>
  8011b6:	89 c7                	mov    %eax,%edi
  8011b8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		panic("ERROR EN FORK: sys_exofork: %e", e_id);

	if (e_id == 0) {
  8011bf:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8011c3:	0f 85 9e 00 00 00    	jne    801267 <fork+0xd9>
		// Si es hijo
		thisenv = &envs[ENVX(sys_getenvid())];
  8011c9:	e8 8e fa ff ff       	call   800c5c <sys_getenvid>
  8011ce:	25 ff 03 00 00       	and    $0x3ff,%eax
  8011d3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8011d6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8011db:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  8011e0:	e9 de 00 00 00       	jmp    8012c3 <fork+0x135>
		panic("ERROR EN FORK: sys_exofork: %e", e_id);
  8011e5:	50                   	push   %eax
  8011e6:	68 cc 29 80 00       	push   $0x8029cc
  8011eb:	68 c2 00 00 00       	push   $0xc2
  8011f0:	68 5a 2a 80 00       	push   $0x802a5a
  8011f5:	e8 8e 0f 00 00       	call   802188 <_panic>
		// LOOP PTEs
		while (pt_x < NPTENTRIES) {
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
			pte_t pt_e = uvpt[PGNUM(dir)];
			if (dir == (UXSTACKTOP - PGSIZE)) {
				err = sys_page_alloc(e_id,
  8011fa:	83 ec 04             	sub    $0x4,%esp
  8011fd:	6a 07                	push   $0x7
  8011ff:	68 00 f0 bf ee       	push   $0xeebff000
  801204:	57                   	push   %edi
  801205:	e8 a5 fa ff ff       	call   800caf <sys_page_alloc>
				                     (void *) dir,
				                     PTE_W | PTE_U | PTE_P);
				if (err)
  80120a:	83 c4 10             	add    $0x10,%esp
  80120d:	85 c0                	test   %eax,%eax
  80120f:	75 33                	jne    801244 <fork+0xb6>
  801211:	83 c3 01             	add    $0x1,%ebx
		while (pt_x < NPTENTRIES) {
  801214:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  80121a:	74 3d                	je     801259 <fork+0xcb>
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
  80121c:	89 d8                	mov    %ebx,%eax
  80121e:	c1 e0 0c             	shl    $0xc,%eax
  801221:	09 f0                	or     %esi,%eax
			pte_t pt_e = uvpt[PGNUM(dir)];
  801223:	89 c2                	mov    %eax,%edx
  801225:	c1 ea 0c             	shr    $0xc,%edx
  801228:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
			if (dir == (UXSTACKTOP - PGSIZE)) {
  80122f:	3d 00 f0 bf ee       	cmp    $0xeebff000,%eax
  801234:	74 c4                	je     8011fa <fork+0x6c>
					      "%e",
					      err);
				pt_x++;
				continue;
			}
			if ((pt_e & PTE_P) == 0) {
  801236:	f6 c1 01             	test   $0x1,%cl
  801239:	74 d6                	je     801211 <fork+0x83>
				pt_x++;
				continue;
			}
			duppage(e_id, PGNUM(dir));
  80123b:	89 f8                	mov    %edi,%eax
  80123d:	e8 aa fb ff ff       	call   800dec <duppage>
  801242:	eb cd                	jmp    801211 <fork+0x83>
					panic("ERROR EN FORK: sys_page_alloc: "
  801244:	50                   	push   %eax
  801245:	68 ec 29 80 00       	push   $0x8029ec
  80124a:	68 e1 00 00 00       	push   $0xe1
  80124f:	68 5a 2a 80 00       	push   $0x802a5a
  801254:	e8 2f 0f 00 00       	call   802188 <_panic>
  801259:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  80125d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
	while (pd_x < PDX(UTOP)) {
  801260:	3d bb 03 00 00       	cmp    $0x3bb,%eax
  801265:	74 18                	je     80127f <fork+0xf1>
		pde_t pd_e = uvpd[pd_x];
  801267:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  80126a:	8b 04 b5 00 d0 7b ef 	mov    -0x10843000(,%esi,4),%eax
		if ((pd_e & PTE_P) == 0) {
  801271:	a8 01                	test   $0x1,%al
  801273:	74 e4                	je     801259 <fork+0xcb>
  801275:	c1 e6 16             	shl    $0x16,%esi
  801278:	bb 00 00 00 00       	mov    $0x0,%ebx
  80127d:	eb 9d                	jmp    80121c <fork+0x8e>
			pt_x++;
		}
		pd_x++;
	}

	if ((err = sys_page_alloc(e_id,
  80127f:	83 ec 04             	sub    $0x4,%esp
  801282:	6a 07                	push   $0x7
  801284:	68 00 f0 bf ee       	push   $0xeebff000
  801289:	ff 75 e0             	pushl  -0x20(%ebp)
  80128c:	e8 1e fa ff ff       	call   800caf <sys_page_alloc>
  801291:	83 c4 10             	add    $0x10,%esp
  801294:	85 c0                	test   %eax,%eax
  801296:	78 36                	js     8012ce <fork+0x140>
	                          (void *) (UXSTACKTOP - PGSIZE),
	                          PTE_P | PTE_U | PTE_W) < 0))
		panic("Error en sys_page_alloc");


	if ((sys_env_set_pgfault_upcall(e_id, _pgfault_upcall) < 0))
  801298:	83 ec 08             	sub    $0x8,%esp
  80129b:	68 2d 22 80 00       	push   $0x80222d
  8012a0:	ff 75 e0             	pushl  -0x20(%ebp)
  8012a3:	e8 ce fa ff ff       	call   800d76 <sys_env_set_pgfault_upcall>
  8012a8:	83 c4 10             	add    $0x10,%esp
  8012ab:	85 c0                	test   %eax,%eax
  8012ad:	78 36                	js     8012e5 <fork+0x157>
		panic("sys_env_set_pgfault_upcall failed");

	// HIJO RUNNABLE
	if ((err = sys_env_set_status(e_id, ENV_RUNNABLE)) < 0)
  8012af:	83 ec 08             	sub    $0x8,%esp
  8012b2:	6a 02                	push   $0x2
  8012b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8012b7:	e8 6c fa ff ff       	call   800d28 <sys_env_set_status>
  8012bc:	83 c4 10             	add    $0x10,%esp
  8012bf:	85 c0                	test   %eax,%eax
  8012c1:	78 39                	js     8012fc <fork+0x16e>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);

	return e_id;
}
  8012c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012c9:	5b                   	pop    %ebx
  8012ca:	5e                   	pop    %esi
  8012cb:	5f                   	pop    %edi
  8012cc:	5d                   	pop    %ebp
  8012cd:	c3                   	ret    
		panic("Error en sys_page_alloc");
  8012ce:	83 ec 04             	sub    $0x4,%esp
  8012d1:	68 9f 2a 80 00       	push   $0x802a9f
  8012d6:	68 f4 00 00 00       	push   $0xf4
  8012db:	68 5a 2a 80 00       	push   $0x802a5a
  8012e0:	e8 a3 0e 00 00       	call   802188 <_panic>
		panic("sys_env_set_pgfault_upcall failed");
  8012e5:	83 ec 04             	sub    $0x4,%esp
  8012e8:	68 10 2a 80 00       	push   $0x802a10
  8012ed:	68 f8 00 00 00       	push   $0xf8
  8012f2:	68 5a 2a 80 00       	push   $0x802a5a
  8012f7:	e8 8c 0e 00 00       	call   802188 <_panic>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);
  8012fc:	50                   	push   %eax
  8012fd:	68 34 2a 80 00       	push   $0x802a34
  801302:	68 fc 00 00 00       	push   $0xfc
  801307:	68 5a 2a 80 00       	push   $0x802a5a
  80130c:	e8 77 0e 00 00       	call   802188 <_panic>

00801311 <sfork>:

// Challenge!
int
sfork(void)
{
  801311:	f3 0f 1e fb          	endbr32 
  801315:	55                   	push   %ebp
  801316:	89 e5                	mov    %esp,%ebp
  801318:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  80131b:	68 b7 2a 80 00       	push   $0x802ab7
  801320:	68 05 01 00 00       	push   $0x105
  801325:	68 5a 2a 80 00       	push   $0x802a5a
  80132a:	e8 59 0e 00 00       	call   802188 <_panic>

0080132f <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80132f:	f3 0f 1e fb          	endbr32 
  801333:	55                   	push   %ebp
  801334:	89 e5                	mov    %esp,%ebp
  801336:	56                   	push   %esi
  801337:	53                   	push   %ebx
  801338:	8b 75 08             	mov    0x8(%ebp),%esi
  80133b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80133e:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  801341:	85 c0                	test   %eax,%eax
  801343:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801348:	0f 44 c2             	cmove  %edx,%eax
  80134b:	83 ec 0c             	sub    $0xc,%esp
  80134e:	50                   	push   %eax
  80134f:	e8 72 fa ff ff       	call   800dc6 <sys_ipc_recv>

	if (from_env_store != NULL)
  801354:	83 c4 10             	add    $0x10,%esp
  801357:	85 f6                	test   %esi,%esi
  801359:	74 15                	je     801370 <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  80135b:	ba 00 00 00 00       	mov    $0x0,%edx
  801360:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801363:	74 09                	je     80136e <ipc_recv+0x3f>
  801365:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80136b:	8b 52 74             	mov    0x74(%edx),%edx
  80136e:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  801370:	85 db                	test   %ebx,%ebx
  801372:	74 15                	je     801389 <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  801374:	ba 00 00 00 00       	mov    $0x0,%edx
  801379:	83 f8 fd             	cmp    $0xfffffffd,%eax
  80137c:	74 09                	je     801387 <ipc_recv+0x58>
  80137e:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801384:	8b 52 78             	mov    0x78(%edx),%edx
  801387:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  801389:	83 f8 fd             	cmp    $0xfffffffd,%eax
  80138c:	74 08                	je     801396 <ipc_recv+0x67>
  80138e:	a1 04 40 80 00       	mov    0x804004,%eax
  801393:	8b 40 70             	mov    0x70(%eax),%eax
}
  801396:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801399:	5b                   	pop    %ebx
  80139a:	5e                   	pop    %esi
  80139b:	5d                   	pop    %ebp
  80139c:	c3                   	ret    

0080139d <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  80139d:	f3 0f 1e fb          	endbr32 
  8013a1:	55                   	push   %ebp
  8013a2:	89 e5                	mov    %esp,%ebp
  8013a4:	57                   	push   %edi
  8013a5:	56                   	push   %esi
  8013a6:	53                   	push   %ebx
  8013a7:	83 ec 0c             	sub    $0xc,%esp
  8013aa:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013ad:	8b 75 0c             	mov    0xc(%ebp),%esi
  8013b0:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8013b3:	eb 1f                	jmp    8013d4 <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  8013b5:	6a 00                	push   $0x0
  8013b7:	68 00 00 c0 ee       	push   $0xeec00000
  8013bc:	56                   	push   %esi
  8013bd:	57                   	push   %edi
  8013be:	e8 da f9 ff ff       	call   800d9d <sys_ipc_try_send>
  8013c3:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  8013c6:	85 c0                	test   %eax,%eax
  8013c8:	74 30                	je     8013fa <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  8013ca:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013cd:	75 19                	jne    8013e8 <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  8013cf:	e8 b0 f8 ff ff       	call   800c84 <sys_yield>
		if (pg != NULL) {
  8013d4:	85 db                	test   %ebx,%ebx
  8013d6:	74 dd                	je     8013b5 <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  8013d8:	ff 75 14             	pushl  0x14(%ebp)
  8013db:	53                   	push   %ebx
  8013dc:	56                   	push   %esi
  8013dd:	57                   	push   %edi
  8013de:	e8 ba f9 ff ff       	call   800d9d <sys_ipc_try_send>
  8013e3:	83 c4 10             	add    $0x10,%esp
  8013e6:	eb de                	jmp    8013c6 <ipc_send+0x29>
			panic("ipc_send: %d", res);
  8013e8:	50                   	push   %eax
  8013e9:	68 cd 2a 80 00       	push   $0x802acd
  8013ee:	6a 3e                	push   $0x3e
  8013f0:	68 da 2a 80 00       	push   $0x802ada
  8013f5:	e8 8e 0d 00 00       	call   802188 <_panic>
	}
}
  8013fa:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013fd:	5b                   	pop    %ebx
  8013fe:	5e                   	pop    %esi
  8013ff:	5f                   	pop    %edi
  801400:	5d                   	pop    %ebp
  801401:	c3                   	ret    

00801402 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801402:	f3 0f 1e fb          	endbr32 
  801406:	55                   	push   %ebp
  801407:	89 e5                	mov    %esp,%ebp
  801409:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80140c:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801411:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801414:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80141a:	8b 52 50             	mov    0x50(%edx),%edx
  80141d:	39 ca                	cmp    %ecx,%edx
  80141f:	74 11                	je     801432 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801421:	83 c0 01             	add    $0x1,%eax
  801424:	3d 00 04 00 00       	cmp    $0x400,%eax
  801429:	75 e6                	jne    801411 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  80142b:	b8 00 00 00 00       	mov    $0x0,%eax
  801430:	eb 0b                	jmp    80143d <ipc_find_env+0x3b>
			return envs[i].env_id;
  801432:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801435:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80143a:	8b 40 48             	mov    0x48(%eax),%eax
}
  80143d:	5d                   	pop    %ebp
  80143e:	c3                   	ret    

0080143f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80143f:	f3 0f 1e fb          	endbr32 
  801443:	55                   	push   %ebp
  801444:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801446:	8b 45 08             	mov    0x8(%ebp),%eax
  801449:	05 00 00 00 30       	add    $0x30000000,%eax
  80144e:	c1 e8 0c             	shr    $0xc,%eax
}
  801451:	5d                   	pop    %ebp
  801452:	c3                   	ret    

00801453 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801453:	f3 0f 1e fb          	endbr32 
  801457:	55                   	push   %ebp
  801458:	89 e5                	mov    %esp,%ebp
  80145a:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  80145d:	ff 75 08             	pushl  0x8(%ebp)
  801460:	e8 da ff ff ff       	call   80143f <fd2num>
  801465:	83 c4 10             	add    $0x10,%esp
  801468:	c1 e0 0c             	shl    $0xc,%eax
  80146b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801470:	c9                   	leave  
  801471:	c3                   	ret    

00801472 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801472:	f3 0f 1e fb          	endbr32 
  801476:	55                   	push   %ebp
  801477:	89 e5                	mov    %esp,%ebp
  801479:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80147e:	89 c2                	mov    %eax,%edx
  801480:	c1 ea 16             	shr    $0x16,%edx
  801483:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80148a:	f6 c2 01             	test   $0x1,%dl
  80148d:	74 2d                	je     8014bc <fd_alloc+0x4a>
  80148f:	89 c2                	mov    %eax,%edx
  801491:	c1 ea 0c             	shr    $0xc,%edx
  801494:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80149b:	f6 c2 01             	test   $0x1,%dl
  80149e:	74 1c                	je     8014bc <fd_alloc+0x4a>
  8014a0:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8014a5:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8014aa:	75 d2                	jne    80147e <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8014ac:	8b 45 08             	mov    0x8(%ebp),%eax
  8014af:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8014b5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8014ba:	eb 0a                	jmp    8014c6 <fd_alloc+0x54>
			*fd_store = fd;
  8014bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8014bf:	89 01                	mov    %eax,(%ecx)
			return 0;
  8014c1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014c6:	5d                   	pop    %ebp
  8014c7:	c3                   	ret    

008014c8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014c8:	f3 0f 1e fb          	endbr32 
  8014cc:	55                   	push   %ebp
  8014cd:	89 e5                	mov    %esp,%ebp
  8014cf:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014d2:	83 f8 1f             	cmp    $0x1f,%eax
  8014d5:	77 30                	ja     801507 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014d7:	c1 e0 0c             	shl    $0xc,%eax
  8014da:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014df:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8014e5:	f6 c2 01             	test   $0x1,%dl
  8014e8:	74 24                	je     80150e <fd_lookup+0x46>
  8014ea:	89 c2                	mov    %eax,%edx
  8014ec:	c1 ea 0c             	shr    $0xc,%edx
  8014ef:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014f6:	f6 c2 01             	test   $0x1,%dl
  8014f9:	74 1a                	je     801515 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014fe:	89 02                	mov    %eax,(%edx)
	return 0;
  801500:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801505:	5d                   	pop    %ebp
  801506:	c3                   	ret    
		return -E_INVAL;
  801507:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80150c:	eb f7                	jmp    801505 <fd_lookup+0x3d>
		return -E_INVAL;
  80150e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801513:	eb f0                	jmp    801505 <fd_lookup+0x3d>
  801515:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80151a:	eb e9                	jmp    801505 <fd_lookup+0x3d>

0080151c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80151c:	f3 0f 1e fb          	endbr32 
  801520:	55                   	push   %ebp
  801521:	89 e5                	mov    %esp,%ebp
  801523:	83 ec 08             	sub    $0x8,%esp
  801526:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801529:	ba 60 2b 80 00       	mov    $0x802b60,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80152e:	b8 0c 30 80 00       	mov    $0x80300c,%eax
		if (devtab[i]->dev_id == dev_id) {
  801533:	39 08                	cmp    %ecx,(%eax)
  801535:	74 33                	je     80156a <dev_lookup+0x4e>
  801537:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80153a:	8b 02                	mov    (%edx),%eax
  80153c:	85 c0                	test   %eax,%eax
  80153e:	75 f3                	jne    801533 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801540:	a1 04 40 80 00       	mov    0x804004,%eax
  801545:	8b 40 48             	mov    0x48(%eax),%eax
  801548:	83 ec 04             	sub    $0x4,%esp
  80154b:	51                   	push   %ecx
  80154c:	50                   	push   %eax
  80154d:	68 e4 2a 80 00       	push   $0x802ae4
  801552:	e8 66 ed ff ff       	call   8002bd <cprintf>
	*dev = 0;
  801557:	8b 45 0c             	mov    0xc(%ebp),%eax
  80155a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801560:	83 c4 10             	add    $0x10,%esp
  801563:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801568:	c9                   	leave  
  801569:	c3                   	ret    
			*dev = devtab[i];
  80156a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80156d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80156f:	b8 00 00 00 00       	mov    $0x0,%eax
  801574:	eb f2                	jmp    801568 <dev_lookup+0x4c>

00801576 <fd_close>:
{
  801576:	f3 0f 1e fb          	endbr32 
  80157a:	55                   	push   %ebp
  80157b:	89 e5                	mov    %esp,%ebp
  80157d:	57                   	push   %edi
  80157e:	56                   	push   %esi
  80157f:	53                   	push   %ebx
  801580:	83 ec 28             	sub    $0x28,%esp
  801583:	8b 75 08             	mov    0x8(%ebp),%esi
  801586:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801589:	56                   	push   %esi
  80158a:	e8 b0 fe ff ff       	call   80143f <fd2num>
  80158f:	83 c4 08             	add    $0x8,%esp
  801592:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801595:	52                   	push   %edx
  801596:	50                   	push   %eax
  801597:	e8 2c ff ff ff       	call   8014c8 <fd_lookup>
  80159c:	89 c3                	mov    %eax,%ebx
  80159e:	83 c4 10             	add    $0x10,%esp
  8015a1:	85 c0                	test   %eax,%eax
  8015a3:	78 05                	js     8015aa <fd_close+0x34>
	    || fd != fd2)
  8015a5:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8015a8:	74 16                	je     8015c0 <fd_close+0x4a>
		return (must_exist ? r : 0);
  8015aa:	89 f8                	mov    %edi,%eax
  8015ac:	84 c0                	test   %al,%al
  8015ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8015b3:	0f 44 d8             	cmove  %eax,%ebx
}
  8015b6:	89 d8                	mov    %ebx,%eax
  8015b8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015bb:	5b                   	pop    %ebx
  8015bc:	5e                   	pop    %esi
  8015bd:	5f                   	pop    %edi
  8015be:	5d                   	pop    %ebp
  8015bf:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8015c0:	83 ec 08             	sub    $0x8,%esp
  8015c3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8015c6:	50                   	push   %eax
  8015c7:	ff 36                	pushl  (%esi)
  8015c9:	e8 4e ff ff ff       	call   80151c <dev_lookup>
  8015ce:	89 c3                	mov    %eax,%ebx
  8015d0:	83 c4 10             	add    $0x10,%esp
  8015d3:	85 c0                	test   %eax,%eax
  8015d5:	78 1a                	js     8015f1 <fd_close+0x7b>
		if (dev->dev_close)
  8015d7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8015da:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8015dd:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8015e2:	85 c0                	test   %eax,%eax
  8015e4:	74 0b                	je     8015f1 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8015e6:	83 ec 0c             	sub    $0xc,%esp
  8015e9:	56                   	push   %esi
  8015ea:	ff d0                	call   *%eax
  8015ec:	89 c3                	mov    %eax,%ebx
  8015ee:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8015f1:	83 ec 08             	sub    $0x8,%esp
  8015f4:	56                   	push   %esi
  8015f5:	6a 00                	push   $0x0
  8015f7:	e8 05 f7 ff ff       	call   800d01 <sys_page_unmap>
	return r;
  8015fc:	83 c4 10             	add    $0x10,%esp
  8015ff:	eb b5                	jmp    8015b6 <fd_close+0x40>

00801601 <close>:

int
close(int fdnum)
{
  801601:	f3 0f 1e fb          	endbr32 
  801605:	55                   	push   %ebp
  801606:	89 e5                	mov    %esp,%ebp
  801608:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80160b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80160e:	50                   	push   %eax
  80160f:	ff 75 08             	pushl  0x8(%ebp)
  801612:	e8 b1 fe ff ff       	call   8014c8 <fd_lookup>
  801617:	83 c4 10             	add    $0x10,%esp
  80161a:	85 c0                	test   %eax,%eax
  80161c:	79 02                	jns    801620 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  80161e:	c9                   	leave  
  80161f:	c3                   	ret    
		return fd_close(fd, 1);
  801620:	83 ec 08             	sub    $0x8,%esp
  801623:	6a 01                	push   $0x1
  801625:	ff 75 f4             	pushl  -0xc(%ebp)
  801628:	e8 49 ff ff ff       	call   801576 <fd_close>
  80162d:	83 c4 10             	add    $0x10,%esp
  801630:	eb ec                	jmp    80161e <close+0x1d>

00801632 <close_all>:

void
close_all(void)
{
  801632:	f3 0f 1e fb          	endbr32 
  801636:	55                   	push   %ebp
  801637:	89 e5                	mov    %esp,%ebp
  801639:	53                   	push   %ebx
  80163a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80163d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801642:	83 ec 0c             	sub    $0xc,%esp
  801645:	53                   	push   %ebx
  801646:	e8 b6 ff ff ff       	call   801601 <close>
	for (i = 0; i < MAXFD; i++)
  80164b:	83 c3 01             	add    $0x1,%ebx
  80164e:	83 c4 10             	add    $0x10,%esp
  801651:	83 fb 20             	cmp    $0x20,%ebx
  801654:	75 ec                	jne    801642 <close_all+0x10>
}
  801656:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801659:	c9                   	leave  
  80165a:	c3                   	ret    

0080165b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80165b:	f3 0f 1e fb          	endbr32 
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
  801662:	57                   	push   %edi
  801663:	56                   	push   %esi
  801664:	53                   	push   %ebx
  801665:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801668:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80166b:	50                   	push   %eax
  80166c:	ff 75 08             	pushl  0x8(%ebp)
  80166f:	e8 54 fe ff ff       	call   8014c8 <fd_lookup>
  801674:	89 c3                	mov    %eax,%ebx
  801676:	83 c4 10             	add    $0x10,%esp
  801679:	85 c0                	test   %eax,%eax
  80167b:	0f 88 81 00 00 00    	js     801702 <dup+0xa7>
		return r;
	close(newfdnum);
  801681:	83 ec 0c             	sub    $0xc,%esp
  801684:	ff 75 0c             	pushl  0xc(%ebp)
  801687:	e8 75 ff ff ff       	call   801601 <close>

	newfd = INDEX2FD(newfdnum);
  80168c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80168f:	c1 e6 0c             	shl    $0xc,%esi
  801692:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801698:	83 c4 04             	add    $0x4,%esp
  80169b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80169e:	e8 b0 fd ff ff       	call   801453 <fd2data>
  8016a3:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8016a5:	89 34 24             	mov    %esi,(%esp)
  8016a8:	e8 a6 fd ff ff       	call   801453 <fd2data>
  8016ad:	83 c4 10             	add    $0x10,%esp
  8016b0:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8016b2:	89 d8                	mov    %ebx,%eax
  8016b4:	c1 e8 16             	shr    $0x16,%eax
  8016b7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8016be:	a8 01                	test   $0x1,%al
  8016c0:	74 11                	je     8016d3 <dup+0x78>
  8016c2:	89 d8                	mov    %ebx,%eax
  8016c4:	c1 e8 0c             	shr    $0xc,%eax
  8016c7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016ce:	f6 c2 01             	test   $0x1,%dl
  8016d1:	75 39                	jne    80170c <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016d3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016d6:	89 d0                	mov    %edx,%eax
  8016d8:	c1 e8 0c             	shr    $0xc,%eax
  8016db:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016e2:	83 ec 0c             	sub    $0xc,%esp
  8016e5:	25 07 0e 00 00       	and    $0xe07,%eax
  8016ea:	50                   	push   %eax
  8016eb:	56                   	push   %esi
  8016ec:	6a 00                	push   $0x0
  8016ee:	52                   	push   %edx
  8016ef:	6a 00                	push   $0x0
  8016f1:	e8 e1 f5 ff ff       	call   800cd7 <sys_page_map>
  8016f6:	89 c3                	mov    %eax,%ebx
  8016f8:	83 c4 20             	add    $0x20,%esp
  8016fb:	85 c0                	test   %eax,%eax
  8016fd:	78 31                	js     801730 <dup+0xd5>
		goto err;

	return newfdnum;
  8016ff:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801702:	89 d8                	mov    %ebx,%eax
  801704:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801707:	5b                   	pop    %ebx
  801708:	5e                   	pop    %esi
  801709:	5f                   	pop    %edi
  80170a:	5d                   	pop    %ebp
  80170b:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80170c:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801713:	83 ec 0c             	sub    $0xc,%esp
  801716:	25 07 0e 00 00       	and    $0xe07,%eax
  80171b:	50                   	push   %eax
  80171c:	57                   	push   %edi
  80171d:	6a 00                	push   $0x0
  80171f:	53                   	push   %ebx
  801720:	6a 00                	push   $0x0
  801722:	e8 b0 f5 ff ff       	call   800cd7 <sys_page_map>
  801727:	89 c3                	mov    %eax,%ebx
  801729:	83 c4 20             	add    $0x20,%esp
  80172c:	85 c0                	test   %eax,%eax
  80172e:	79 a3                	jns    8016d3 <dup+0x78>
	sys_page_unmap(0, newfd);
  801730:	83 ec 08             	sub    $0x8,%esp
  801733:	56                   	push   %esi
  801734:	6a 00                	push   $0x0
  801736:	e8 c6 f5 ff ff       	call   800d01 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80173b:	83 c4 08             	add    $0x8,%esp
  80173e:	57                   	push   %edi
  80173f:	6a 00                	push   $0x0
  801741:	e8 bb f5 ff ff       	call   800d01 <sys_page_unmap>
	return r;
  801746:	83 c4 10             	add    $0x10,%esp
  801749:	eb b7                	jmp    801702 <dup+0xa7>

0080174b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80174b:	f3 0f 1e fb          	endbr32 
  80174f:	55                   	push   %ebp
  801750:	89 e5                	mov    %esp,%ebp
  801752:	53                   	push   %ebx
  801753:	83 ec 1c             	sub    $0x1c,%esp
  801756:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801759:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80175c:	50                   	push   %eax
  80175d:	53                   	push   %ebx
  80175e:	e8 65 fd ff ff       	call   8014c8 <fd_lookup>
  801763:	83 c4 10             	add    $0x10,%esp
  801766:	85 c0                	test   %eax,%eax
  801768:	78 3f                	js     8017a9 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80176a:	83 ec 08             	sub    $0x8,%esp
  80176d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801770:	50                   	push   %eax
  801771:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801774:	ff 30                	pushl  (%eax)
  801776:	e8 a1 fd ff ff       	call   80151c <dev_lookup>
  80177b:	83 c4 10             	add    $0x10,%esp
  80177e:	85 c0                	test   %eax,%eax
  801780:	78 27                	js     8017a9 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801782:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801785:	8b 42 08             	mov    0x8(%edx),%eax
  801788:	83 e0 03             	and    $0x3,%eax
  80178b:	83 f8 01             	cmp    $0x1,%eax
  80178e:	74 1e                	je     8017ae <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801790:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801793:	8b 40 08             	mov    0x8(%eax),%eax
  801796:	85 c0                	test   %eax,%eax
  801798:	74 35                	je     8017cf <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80179a:	83 ec 04             	sub    $0x4,%esp
  80179d:	ff 75 10             	pushl  0x10(%ebp)
  8017a0:	ff 75 0c             	pushl  0xc(%ebp)
  8017a3:	52                   	push   %edx
  8017a4:	ff d0                	call   *%eax
  8017a6:	83 c4 10             	add    $0x10,%esp
}
  8017a9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8017ac:	c9                   	leave  
  8017ad:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8017ae:	a1 04 40 80 00       	mov    0x804004,%eax
  8017b3:	8b 40 48             	mov    0x48(%eax),%eax
  8017b6:	83 ec 04             	sub    $0x4,%esp
  8017b9:	53                   	push   %ebx
  8017ba:	50                   	push   %eax
  8017bb:	68 25 2b 80 00       	push   $0x802b25
  8017c0:	e8 f8 ea ff ff       	call   8002bd <cprintf>
		return -E_INVAL;
  8017c5:	83 c4 10             	add    $0x10,%esp
  8017c8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017cd:	eb da                	jmp    8017a9 <read+0x5e>
		return -E_NOT_SUPP;
  8017cf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017d4:	eb d3                	jmp    8017a9 <read+0x5e>

008017d6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017d6:	f3 0f 1e fb          	endbr32 
  8017da:	55                   	push   %ebp
  8017db:	89 e5                	mov    %esp,%ebp
  8017dd:	57                   	push   %edi
  8017de:	56                   	push   %esi
  8017df:	53                   	push   %ebx
  8017e0:	83 ec 0c             	sub    $0xc,%esp
  8017e3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017e6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017e9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017ee:	eb 02                	jmp    8017f2 <readn+0x1c>
  8017f0:	01 c3                	add    %eax,%ebx
  8017f2:	39 f3                	cmp    %esi,%ebx
  8017f4:	73 21                	jae    801817 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017f6:	83 ec 04             	sub    $0x4,%esp
  8017f9:	89 f0                	mov    %esi,%eax
  8017fb:	29 d8                	sub    %ebx,%eax
  8017fd:	50                   	push   %eax
  8017fe:	89 d8                	mov    %ebx,%eax
  801800:	03 45 0c             	add    0xc(%ebp),%eax
  801803:	50                   	push   %eax
  801804:	57                   	push   %edi
  801805:	e8 41 ff ff ff       	call   80174b <read>
		if (m < 0)
  80180a:	83 c4 10             	add    $0x10,%esp
  80180d:	85 c0                	test   %eax,%eax
  80180f:	78 04                	js     801815 <readn+0x3f>
			return m;
		if (m == 0)
  801811:	75 dd                	jne    8017f0 <readn+0x1a>
  801813:	eb 02                	jmp    801817 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801815:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801817:	89 d8                	mov    %ebx,%eax
  801819:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80181c:	5b                   	pop    %ebx
  80181d:	5e                   	pop    %esi
  80181e:	5f                   	pop    %edi
  80181f:	5d                   	pop    %ebp
  801820:	c3                   	ret    

00801821 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801821:	f3 0f 1e fb          	endbr32 
  801825:	55                   	push   %ebp
  801826:	89 e5                	mov    %esp,%ebp
  801828:	53                   	push   %ebx
  801829:	83 ec 1c             	sub    $0x1c,%esp
  80182c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80182f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801832:	50                   	push   %eax
  801833:	53                   	push   %ebx
  801834:	e8 8f fc ff ff       	call   8014c8 <fd_lookup>
  801839:	83 c4 10             	add    $0x10,%esp
  80183c:	85 c0                	test   %eax,%eax
  80183e:	78 3a                	js     80187a <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801840:	83 ec 08             	sub    $0x8,%esp
  801843:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801846:	50                   	push   %eax
  801847:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80184a:	ff 30                	pushl  (%eax)
  80184c:	e8 cb fc ff ff       	call   80151c <dev_lookup>
  801851:	83 c4 10             	add    $0x10,%esp
  801854:	85 c0                	test   %eax,%eax
  801856:	78 22                	js     80187a <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801858:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80185b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80185f:	74 1e                	je     80187f <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801861:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801864:	8b 52 0c             	mov    0xc(%edx),%edx
  801867:	85 d2                	test   %edx,%edx
  801869:	74 35                	je     8018a0 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80186b:	83 ec 04             	sub    $0x4,%esp
  80186e:	ff 75 10             	pushl  0x10(%ebp)
  801871:	ff 75 0c             	pushl  0xc(%ebp)
  801874:	50                   	push   %eax
  801875:	ff d2                	call   *%edx
  801877:	83 c4 10             	add    $0x10,%esp
}
  80187a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187d:	c9                   	leave  
  80187e:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80187f:	a1 04 40 80 00       	mov    0x804004,%eax
  801884:	8b 40 48             	mov    0x48(%eax),%eax
  801887:	83 ec 04             	sub    $0x4,%esp
  80188a:	53                   	push   %ebx
  80188b:	50                   	push   %eax
  80188c:	68 41 2b 80 00       	push   $0x802b41
  801891:	e8 27 ea ff ff       	call   8002bd <cprintf>
		return -E_INVAL;
  801896:	83 c4 10             	add    $0x10,%esp
  801899:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80189e:	eb da                	jmp    80187a <write+0x59>
		return -E_NOT_SUPP;
  8018a0:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8018a5:	eb d3                	jmp    80187a <write+0x59>

008018a7 <seek>:

int
seek(int fdnum, off_t offset)
{
  8018a7:	f3 0f 1e fb          	endbr32 
  8018ab:	55                   	push   %ebp
  8018ac:	89 e5                	mov    %esp,%ebp
  8018ae:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8018b1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018b4:	50                   	push   %eax
  8018b5:	ff 75 08             	pushl  0x8(%ebp)
  8018b8:	e8 0b fc ff ff       	call   8014c8 <fd_lookup>
  8018bd:	83 c4 10             	add    $0x10,%esp
  8018c0:	85 c0                	test   %eax,%eax
  8018c2:	78 0e                	js     8018d2 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8018c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018ca:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018d2:	c9                   	leave  
  8018d3:	c3                   	ret    

008018d4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018d4:	f3 0f 1e fb          	endbr32 
  8018d8:	55                   	push   %ebp
  8018d9:	89 e5                	mov    %esp,%ebp
  8018db:	53                   	push   %ebx
  8018dc:	83 ec 1c             	sub    $0x1c,%esp
  8018df:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018e5:	50                   	push   %eax
  8018e6:	53                   	push   %ebx
  8018e7:	e8 dc fb ff ff       	call   8014c8 <fd_lookup>
  8018ec:	83 c4 10             	add    $0x10,%esp
  8018ef:	85 c0                	test   %eax,%eax
  8018f1:	78 37                	js     80192a <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018f3:	83 ec 08             	sub    $0x8,%esp
  8018f6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018f9:	50                   	push   %eax
  8018fa:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018fd:	ff 30                	pushl  (%eax)
  8018ff:	e8 18 fc ff ff       	call   80151c <dev_lookup>
  801904:	83 c4 10             	add    $0x10,%esp
  801907:	85 c0                	test   %eax,%eax
  801909:	78 1f                	js     80192a <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80190b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80190e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801912:	74 1b                	je     80192f <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801914:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801917:	8b 52 18             	mov    0x18(%edx),%edx
  80191a:	85 d2                	test   %edx,%edx
  80191c:	74 32                	je     801950 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80191e:	83 ec 08             	sub    $0x8,%esp
  801921:	ff 75 0c             	pushl  0xc(%ebp)
  801924:	50                   	push   %eax
  801925:	ff d2                	call   *%edx
  801927:	83 c4 10             	add    $0x10,%esp
}
  80192a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80192d:	c9                   	leave  
  80192e:	c3                   	ret    
			thisenv->env_id, fdnum);
  80192f:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801934:	8b 40 48             	mov    0x48(%eax),%eax
  801937:	83 ec 04             	sub    $0x4,%esp
  80193a:	53                   	push   %ebx
  80193b:	50                   	push   %eax
  80193c:	68 04 2b 80 00       	push   $0x802b04
  801941:	e8 77 e9 ff ff       	call   8002bd <cprintf>
		return -E_INVAL;
  801946:	83 c4 10             	add    $0x10,%esp
  801949:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80194e:	eb da                	jmp    80192a <ftruncate+0x56>
		return -E_NOT_SUPP;
  801950:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801955:	eb d3                	jmp    80192a <ftruncate+0x56>

00801957 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801957:	f3 0f 1e fb          	endbr32 
  80195b:	55                   	push   %ebp
  80195c:	89 e5                	mov    %esp,%ebp
  80195e:	53                   	push   %ebx
  80195f:	83 ec 1c             	sub    $0x1c,%esp
  801962:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801965:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801968:	50                   	push   %eax
  801969:	ff 75 08             	pushl  0x8(%ebp)
  80196c:	e8 57 fb ff ff       	call   8014c8 <fd_lookup>
  801971:	83 c4 10             	add    $0x10,%esp
  801974:	85 c0                	test   %eax,%eax
  801976:	78 4b                	js     8019c3 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801978:	83 ec 08             	sub    $0x8,%esp
  80197b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80197e:	50                   	push   %eax
  80197f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801982:	ff 30                	pushl  (%eax)
  801984:	e8 93 fb ff ff       	call   80151c <dev_lookup>
  801989:	83 c4 10             	add    $0x10,%esp
  80198c:	85 c0                	test   %eax,%eax
  80198e:	78 33                	js     8019c3 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801990:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801993:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801997:	74 2f                	je     8019c8 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801999:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80199c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019a3:	00 00 00 
	stat->st_isdir = 0;
  8019a6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8019ad:	00 00 00 
	stat->st_dev = dev;
  8019b0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8019b6:	83 ec 08             	sub    $0x8,%esp
  8019b9:	53                   	push   %ebx
  8019ba:	ff 75 f0             	pushl  -0x10(%ebp)
  8019bd:	ff 50 14             	call   *0x14(%eax)
  8019c0:	83 c4 10             	add    $0x10,%esp
}
  8019c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019c6:	c9                   	leave  
  8019c7:	c3                   	ret    
		return -E_NOT_SUPP;
  8019c8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019cd:	eb f4                	jmp    8019c3 <fstat+0x6c>

008019cf <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019cf:	f3 0f 1e fb          	endbr32 
  8019d3:	55                   	push   %ebp
  8019d4:	89 e5                	mov    %esp,%ebp
  8019d6:	56                   	push   %esi
  8019d7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019d8:	83 ec 08             	sub    $0x8,%esp
  8019db:	6a 00                	push   $0x0
  8019dd:	ff 75 08             	pushl  0x8(%ebp)
  8019e0:	e8 fb 01 00 00       	call   801be0 <open>
  8019e5:	89 c3                	mov    %eax,%ebx
  8019e7:	83 c4 10             	add    $0x10,%esp
  8019ea:	85 c0                	test   %eax,%eax
  8019ec:	78 1b                	js     801a09 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8019ee:	83 ec 08             	sub    $0x8,%esp
  8019f1:	ff 75 0c             	pushl  0xc(%ebp)
  8019f4:	50                   	push   %eax
  8019f5:	e8 5d ff ff ff       	call   801957 <fstat>
  8019fa:	89 c6                	mov    %eax,%esi
	close(fd);
  8019fc:	89 1c 24             	mov    %ebx,(%esp)
  8019ff:	e8 fd fb ff ff       	call   801601 <close>
	return r;
  801a04:	83 c4 10             	add    $0x10,%esp
  801a07:	89 f3                	mov    %esi,%ebx
}
  801a09:	89 d8                	mov    %ebx,%eax
  801a0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a0e:	5b                   	pop    %ebx
  801a0f:	5e                   	pop    %esi
  801a10:	5d                   	pop    %ebp
  801a11:	c3                   	ret    

00801a12 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a12:	55                   	push   %ebp
  801a13:	89 e5                	mov    %esp,%ebp
  801a15:	56                   	push   %esi
  801a16:	53                   	push   %ebx
  801a17:	89 c6                	mov    %eax,%esi
  801a19:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a1b:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a22:	74 27                	je     801a4b <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a24:	6a 07                	push   $0x7
  801a26:	68 00 50 80 00       	push   $0x805000
  801a2b:	56                   	push   %esi
  801a2c:	ff 35 00 40 80 00    	pushl  0x804000
  801a32:	e8 66 f9 ff ff       	call   80139d <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a37:	83 c4 0c             	add    $0xc,%esp
  801a3a:	6a 00                	push   $0x0
  801a3c:	53                   	push   %ebx
  801a3d:	6a 00                	push   $0x0
  801a3f:	e8 eb f8 ff ff       	call   80132f <ipc_recv>
}
  801a44:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a47:	5b                   	pop    %ebx
  801a48:	5e                   	pop    %esi
  801a49:	5d                   	pop    %ebp
  801a4a:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a4b:	83 ec 0c             	sub    $0xc,%esp
  801a4e:	6a 01                	push   $0x1
  801a50:	e8 ad f9 ff ff       	call   801402 <ipc_find_env>
  801a55:	a3 00 40 80 00       	mov    %eax,0x804000
  801a5a:	83 c4 10             	add    $0x10,%esp
  801a5d:	eb c5                	jmp    801a24 <fsipc+0x12>

00801a5f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a5f:	f3 0f 1e fb          	endbr32 
  801a63:	55                   	push   %ebp
  801a64:	89 e5                	mov    %esp,%ebp
  801a66:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a69:	8b 45 08             	mov    0x8(%ebp),%eax
  801a6c:	8b 40 0c             	mov    0xc(%eax),%eax
  801a6f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a74:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a77:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a7c:	ba 00 00 00 00       	mov    $0x0,%edx
  801a81:	b8 02 00 00 00       	mov    $0x2,%eax
  801a86:	e8 87 ff ff ff       	call   801a12 <fsipc>
}
  801a8b:	c9                   	leave  
  801a8c:	c3                   	ret    

00801a8d <devfile_flush>:
{
  801a8d:	f3 0f 1e fb          	endbr32 
  801a91:	55                   	push   %ebp
  801a92:	89 e5                	mov    %esp,%ebp
  801a94:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a97:	8b 45 08             	mov    0x8(%ebp),%eax
  801a9a:	8b 40 0c             	mov    0xc(%eax),%eax
  801a9d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801aa2:	ba 00 00 00 00       	mov    $0x0,%edx
  801aa7:	b8 06 00 00 00       	mov    $0x6,%eax
  801aac:	e8 61 ff ff ff       	call   801a12 <fsipc>
}
  801ab1:	c9                   	leave  
  801ab2:	c3                   	ret    

00801ab3 <devfile_stat>:
{
  801ab3:	f3 0f 1e fb          	endbr32 
  801ab7:	55                   	push   %ebp
  801ab8:	89 e5                	mov    %esp,%ebp
  801aba:	53                   	push   %ebx
  801abb:	83 ec 04             	sub    $0x4,%esp
  801abe:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801ac1:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac4:	8b 40 0c             	mov    0xc(%eax),%eax
  801ac7:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801acc:	ba 00 00 00 00       	mov    $0x0,%edx
  801ad1:	b8 05 00 00 00       	mov    $0x5,%eax
  801ad6:	e8 37 ff ff ff       	call   801a12 <fsipc>
  801adb:	85 c0                	test   %eax,%eax
  801add:	78 2c                	js     801b0b <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801adf:	83 ec 08             	sub    $0x8,%esp
  801ae2:	68 00 50 80 00       	push   $0x805000
  801ae7:	53                   	push   %ebx
  801ae8:	e8 3a ed ff ff       	call   800827 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801aed:	a1 80 50 80 00       	mov    0x805080,%eax
  801af2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801af8:	a1 84 50 80 00       	mov    0x805084,%eax
  801afd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b03:	83 c4 10             	add    $0x10,%esp
  801b06:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b0e:	c9                   	leave  
  801b0f:	c3                   	ret    

00801b10 <devfile_write>:
{
  801b10:	f3 0f 1e fb          	endbr32 
  801b14:	55                   	push   %ebp
  801b15:	89 e5                	mov    %esp,%ebp
  801b17:	83 ec 0c             	sub    $0xc,%esp
  801b1a:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b1d:	8b 55 08             	mov    0x8(%ebp),%edx
  801b20:	8b 52 0c             	mov    0xc(%edx),%edx
  801b23:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801b29:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b2e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b33:	0f 47 c2             	cmova  %edx,%eax
  801b36:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801b3b:	50                   	push   %eax
  801b3c:	ff 75 0c             	pushl  0xc(%ebp)
  801b3f:	68 08 50 80 00       	push   $0x805008
  801b44:	e8 96 ee ff ff       	call   8009df <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801b49:	ba 00 00 00 00       	mov    $0x0,%edx
  801b4e:	b8 04 00 00 00       	mov    $0x4,%eax
  801b53:	e8 ba fe ff ff       	call   801a12 <fsipc>
}
  801b58:	c9                   	leave  
  801b59:	c3                   	ret    

00801b5a <devfile_read>:
{
  801b5a:	f3 0f 1e fb          	endbr32 
  801b5e:	55                   	push   %ebp
  801b5f:	89 e5                	mov    %esp,%ebp
  801b61:	56                   	push   %esi
  801b62:	53                   	push   %ebx
  801b63:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b66:	8b 45 08             	mov    0x8(%ebp),%eax
  801b69:	8b 40 0c             	mov    0xc(%eax),%eax
  801b6c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b71:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b77:	ba 00 00 00 00       	mov    $0x0,%edx
  801b7c:	b8 03 00 00 00       	mov    $0x3,%eax
  801b81:	e8 8c fe ff ff       	call   801a12 <fsipc>
  801b86:	89 c3                	mov    %eax,%ebx
  801b88:	85 c0                	test   %eax,%eax
  801b8a:	78 1f                	js     801bab <devfile_read+0x51>
	assert(r <= n);
  801b8c:	39 f0                	cmp    %esi,%eax
  801b8e:	77 24                	ja     801bb4 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801b90:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b95:	7f 33                	jg     801bca <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b97:	83 ec 04             	sub    $0x4,%esp
  801b9a:	50                   	push   %eax
  801b9b:	68 00 50 80 00       	push   $0x805000
  801ba0:	ff 75 0c             	pushl  0xc(%ebp)
  801ba3:	e8 37 ee ff ff       	call   8009df <memmove>
	return r;
  801ba8:	83 c4 10             	add    $0x10,%esp
}
  801bab:	89 d8                	mov    %ebx,%eax
  801bad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801bb0:	5b                   	pop    %ebx
  801bb1:	5e                   	pop    %esi
  801bb2:	5d                   	pop    %ebp
  801bb3:	c3                   	ret    
	assert(r <= n);
  801bb4:	68 70 2b 80 00       	push   $0x802b70
  801bb9:	68 77 2b 80 00       	push   $0x802b77
  801bbe:	6a 7c                	push   $0x7c
  801bc0:	68 8c 2b 80 00       	push   $0x802b8c
  801bc5:	e8 be 05 00 00       	call   802188 <_panic>
	assert(r <= PGSIZE);
  801bca:	68 97 2b 80 00       	push   $0x802b97
  801bcf:	68 77 2b 80 00       	push   $0x802b77
  801bd4:	6a 7d                	push   $0x7d
  801bd6:	68 8c 2b 80 00       	push   $0x802b8c
  801bdb:	e8 a8 05 00 00       	call   802188 <_panic>

00801be0 <open>:
{
  801be0:	f3 0f 1e fb          	endbr32 
  801be4:	55                   	push   %ebp
  801be5:	89 e5                	mov    %esp,%ebp
  801be7:	56                   	push   %esi
  801be8:	53                   	push   %ebx
  801be9:	83 ec 1c             	sub    $0x1c,%esp
  801bec:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801bef:	56                   	push   %esi
  801bf0:	e8 ef eb ff ff       	call   8007e4 <strlen>
  801bf5:	83 c4 10             	add    $0x10,%esp
  801bf8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bfd:	7f 6c                	jg     801c6b <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801bff:	83 ec 0c             	sub    $0xc,%esp
  801c02:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c05:	50                   	push   %eax
  801c06:	e8 67 f8 ff ff       	call   801472 <fd_alloc>
  801c0b:	89 c3                	mov    %eax,%ebx
  801c0d:	83 c4 10             	add    $0x10,%esp
  801c10:	85 c0                	test   %eax,%eax
  801c12:	78 3c                	js     801c50 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801c14:	83 ec 08             	sub    $0x8,%esp
  801c17:	56                   	push   %esi
  801c18:	68 00 50 80 00       	push   $0x805000
  801c1d:	e8 05 ec ff ff       	call   800827 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c22:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c25:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c2a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c2d:	b8 01 00 00 00       	mov    $0x1,%eax
  801c32:	e8 db fd ff ff       	call   801a12 <fsipc>
  801c37:	89 c3                	mov    %eax,%ebx
  801c39:	83 c4 10             	add    $0x10,%esp
  801c3c:	85 c0                	test   %eax,%eax
  801c3e:	78 19                	js     801c59 <open+0x79>
	return fd2num(fd);
  801c40:	83 ec 0c             	sub    $0xc,%esp
  801c43:	ff 75 f4             	pushl  -0xc(%ebp)
  801c46:	e8 f4 f7 ff ff       	call   80143f <fd2num>
  801c4b:	89 c3                	mov    %eax,%ebx
  801c4d:	83 c4 10             	add    $0x10,%esp
}
  801c50:	89 d8                	mov    %ebx,%eax
  801c52:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c55:	5b                   	pop    %ebx
  801c56:	5e                   	pop    %esi
  801c57:	5d                   	pop    %ebp
  801c58:	c3                   	ret    
		fd_close(fd, 0);
  801c59:	83 ec 08             	sub    $0x8,%esp
  801c5c:	6a 00                	push   $0x0
  801c5e:	ff 75 f4             	pushl  -0xc(%ebp)
  801c61:	e8 10 f9 ff ff       	call   801576 <fd_close>
		return r;
  801c66:	83 c4 10             	add    $0x10,%esp
  801c69:	eb e5                	jmp    801c50 <open+0x70>
		return -E_BAD_PATH;
  801c6b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801c70:	eb de                	jmp    801c50 <open+0x70>

00801c72 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c72:	f3 0f 1e fb          	endbr32 
  801c76:	55                   	push   %ebp
  801c77:	89 e5                	mov    %esp,%ebp
  801c79:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c7c:	ba 00 00 00 00       	mov    $0x0,%edx
  801c81:	b8 08 00 00 00       	mov    $0x8,%eax
  801c86:	e8 87 fd ff ff       	call   801a12 <fsipc>
}
  801c8b:	c9                   	leave  
  801c8c:	c3                   	ret    

00801c8d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c8d:	f3 0f 1e fb          	endbr32 
  801c91:	55                   	push   %ebp
  801c92:	89 e5                	mov    %esp,%ebp
  801c94:	56                   	push   %esi
  801c95:	53                   	push   %ebx
  801c96:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c99:	83 ec 0c             	sub    $0xc,%esp
  801c9c:	ff 75 08             	pushl  0x8(%ebp)
  801c9f:	e8 af f7 ff ff       	call   801453 <fd2data>
  801ca4:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801ca6:	83 c4 08             	add    $0x8,%esp
  801ca9:	68 a3 2b 80 00       	push   $0x802ba3
  801cae:	53                   	push   %ebx
  801caf:	e8 73 eb ff ff       	call   800827 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801cb4:	8b 46 04             	mov    0x4(%esi),%eax
  801cb7:	2b 06                	sub    (%esi),%eax
  801cb9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801cbf:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801cc6:	00 00 00 
	stat->st_dev = &devpipe;
  801cc9:	c7 83 88 00 00 00 28 	movl   $0x803028,0x88(%ebx)
  801cd0:	30 80 00 
	return 0;
}
  801cd3:	b8 00 00 00 00       	mov    $0x0,%eax
  801cd8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cdb:	5b                   	pop    %ebx
  801cdc:	5e                   	pop    %esi
  801cdd:	5d                   	pop    %ebp
  801cde:	c3                   	ret    

00801cdf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cdf:	f3 0f 1e fb          	endbr32 
  801ce3:	55                   	push   %ebp
  801ce4:	89 e5                	mov    %esp,%ebp
  801ce6:	53                   	push   %ebx
  801ce7:	83 ec 0c             	sub    $0xc,%esp
  801cea:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ced:	53                   	push   %ebx
  801cee:	6a 00                	push   $0x0
  801cf0:	e8 0c f0 ff ff       	call   800d01 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cf5:	89 1c 24             	mov    %ebx,(%esp)
  801cf8:	e8 56 f7 ff ff       	call   801453 <fd2data>
  801cfd:	83 c4 08             	add    $0x8,%esp
  801d00:	50                   	push   %eax
  801d01:	6a 00                	push   $0x0
  801d03:	e8 f9 ef ff ff       	call   800d01 <sys_page_unmap>
}
  801d08:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d0b:	c9                   	leave  
  801d0c:	c3                   	ret    

00801d0d <_pipeisclosed>:
{
  801d0d:	55                   	push   %ebp
  801d0e:	89 e5                	mov    %esp,%ebp
  801d10:	57                   	push   %edi
  801d11:	56                   	push   %esi
  801d12:	53                   	push   %ebx
  801d13:	83 ec 1c             	sub    $0x1c,%esp
  801d16:	89 c7                	mov    %eax,%edi
  801d18:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801d1a:	a1 04 40 80 00       	mov    0x804004,%eax
  801d1f:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d22:	83 ec 0c             	sub    $0xc,%esp
  801d25:	57                   	push   %edi
  801d26:	e8 2a 05 00 00       	call   802255 <pageref>
  801d2b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d2e:	89 34 24             	mov    %esi,(%esp)
  801d31:	e8 1f 05 00 00       	call   802255 <pageref>
		nn = thisenv->env_runs;
  801d36:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d3c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d3f:	83 c4 10             	add    $0x10,%esp
  801d42:	39 cb                	cmp    %ecx,%ebx
  801d44:	74 1b                	je     801d61 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801d46:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d49:	75 cf                	jne    801d1a <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d4b:	8b 42 58             	mov    0x58(%edx),%eax
  801d4e:	6a 01                	push   $0x1
  801d50:	50                   	push   %eax
  801d51:	53                   	push   %ebx
  801d52:	68 aa 2b 80 00       	push   $0x802baa
  801d57:	e8 61 e5 ff ff       	call   8002bd <cprintf>
  801d5c:	83 c4 10             	add    $0x10,%esp
  801d5f:	eb b9                	jmp    801d1a <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801d61:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d64:	0f 94 c0             	sete   %al
  801d67:	0f b6 c0             	movzbl %al,%eax
}
  801d6a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d6d:	5b                   	pop    %ebx
  801d6e:	5e                   	pop    %esi
  801d6f:	5f                   	pop    %edi
  801d70:	5d                   	pop    %ebp
  801d71:	c3                   	ret    

00801d72 <devpipe_write>:
{
  801d72:	f3 0f 1e fb          	endbr32 
  801d76:	55                   	push   %ebp
  801d77:	89 e5                	mov    %esp,%ebp
  801d79:	57                   	push   %edi
  801d7a:	56                   	push   %esi
  801d7b:	53                   	push   %ebx
  801d7c:	83 ec 28             	sub    $0x28,%esp
  801d7f:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801d82:	56                   	push   %esi
  801d83:	e8 cb f6 ff ff       	call   801453 <fd2data>
  801d88:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d8a:	83 c4 10             	add    $0x10,%esp
  801d8d:	bf 00 00 00 00       	mov    $0x0,%edi
  801d92:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d95:	74 4f                	je     801de6 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d97:	8b 43 04             	mov    0x4(%ebx),%eax
  801d9a:	8b 0b                	mov    (%ebx),%ecx
  801d9c:	8d 51 20             	lea    0x20(%ecx),%edx
  801d9f:	39 d0                	cmp    %edx,%eax
  801da1:	72 14                	jb     801db7 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801da3:	89 da                	mov    %ebx,%edx
  801da5:	89 f0                	mov    %esi,%eax
  801da7:	e8 61 ff ff ff       	call   801d0d <_pipeisclosed>
  801dac:	85 c0                	test   %eax,%eax
  801dae:	75 3b                	jne    801deb <devpipe_write+0x79>
			sys_yield();
  801db0:	e8 cf ee ff ff       	call   800c84 <sys_yield>
  801db5:	eb e0                	jmp    801d97 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801db7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801dba:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801dbe:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801dc1:	89 c2                	mov    %eax,%edx
  801dc3:	c1 fa 1f             	sar    $0x1f,%edx
  801dc6:	89 d1                	mov    %edx,%ecx
  801dc8:	c1 e9 1b             	shr    $0x1b,%ecx
  801dcb:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801dce:	83 e2 1f             	and    $0x1f,%edx
  801dd1:	29 ca                	sub    %ecx,%edx
  801dd3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801dd7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ddb:	83 c0 01             	add    $0x1,%eax
  801dde:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801de1:	83 c7 01             	add    $0x1,%edi
  801de4:	eb ac                	jmp    801d92 <devpipe_write+0x20>
	return i;
  801de6:	8b 45 10             	mov    0x10(%ebp),%eax
  801de9:	eb 05                	jmp    801df0 <devpipe_write+0x7e>
				return 0;
  801deb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801df0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801df3:	5b                   	pop    %ebx
  801df4:	5e                   	pop    %esi
  801df5:	5f                   	pop    %edi
  801df6:	5d                   	pop    %ebp
  801df7:	c3                   	ret    

00801df8 <devpipe_read>:
{
  801df8:	f3 0f 1e fb          	endbr32 
  801dfc:	55                   	push   %ebp
  801dfd:	89 e5                	mov    %esp,%ebp
  801dff:	57                   	push   %edi
  801e00:	56                   	push   %esi
  801e01:	53                   	push   %ebx
  801e02:	83 ec 18             	sub    $0x18,%esp
  801e05:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801e08:	57                   	push   %edi
  801e09:	e8 45 f6 ff ff       	call   801453 <fd2data>
  801e0e:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e10:	83 c4 10             	add    $0x10,%esp
  801e13:	be 00 00 00 00       	mov    $0x0,%esi
  801e18:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e1b:	75 14                	jne    801e31 <devpipe_read+0x39>
	return i;
  801e1d:	8b 45 10             	mov    0x10(%ebp),%eax
  801e20:	eb 02                	jmp    801e24 <devpipe_read+0x2c>
				return i;
  801e22:	89 f0                	mov    %esi,%eax
}
  801e24:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e27:	5b                   	pop    %ebx
  801e28:	5e                   	pop    %esi
  801e29:	5f                   	pop    %edi
  801e2a:	5d                   	pop    %ebp
  801e2b:	c3                   	ret    
			sys_yield();
  801e2c:	e8 53 ee ff ff       	call   800c84 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801e31:	8b 03                	mov    (%ebx),%eax
  801e33:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e36:	75 18                	jne    801e50 <devpipe_read+0x58>
			if (i > 0)
  801e38:	85 f6                	test   %esi,%esi
  801e3a:	75 e6                	jne    801e22 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801e3c:	89 da                	mov    %ebx,%edx
  801e3e:	89 f8                	mov    %edi,%eax
  801e40:	e8 c8 fe ff ff       	call   801d0d <_pipeisclosed>
  801e45:	85 c0                	test   %eax,%eax
  801e47:	74 e3                	je     801e2c <devpipe_read+0x34>
				return 0;
  801e49:	b8 00 00 00 00       	mov    $0x0,%eax
  801e4e:	eb d4                	jmp    801e24 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e50:	99                   	cltd   
  801e51:	c1 ea 1b             	shr    $0x1b,%edx
  801e54:	01 d0                	add    %edx,%eax
  801e56:	83 e0 1f             	and    $0x1f,%eax
  801e59:	29 d0                	sub    %edx,%eax
  801e5b:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e63:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e66:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801e69:	83 c6 01             	add    $0x1,%esi
  801e6c:	eb aa                	jmp    801e18 <devpipe_read+0x20>

00801e6e <pipe>:
{
  801e6e:	f3 0f 1e fb          	endbr32 
  801e72:	55                   	push   %ebp
  801e73:	89 e5                	mov    %esp,%ebp
  801e75:	56                   	push   %esi
  801e76:	53                   	push   %ebx
  801e77:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801e7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e7d:	50                   	push   %eax
  801e7e:	e8 ef f5 ff ff       	call   801472 <fd_alloc>
  801e83:	89 c3                	mov    %eax,%ebx
  801e85:	83 c4 10             	add    $0x10,%esp
  801e88:	85 c0                	test   %eax,%eax
  801e8a:	0f 88 23 01 00 00    	js     801fb3 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e90:	83 ec 04             	sub    $0x4,%esp
  801e93:	68 07 04 00 00       	push   $0x407
  801e98:	ff 75 f4             	pushl  -0xc(%ebp)
  801e9b:	6a 00                	push   $0x0
  801e9d:	e8 0d ee ff ff       	call   800caf <sys_page_alloc>
  801ea2:	89 c3                	mov    %eax,%ebx
  801ea4:	83 c4 10             	add    $0x10,%esp
  801ea7:	85 c0                	test   %eax,%eax
  801ea9:	0f 88 04 01 00 00    	js     801fb3 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801eaf:	83 ec 0c             	sub    $0xc,%esp
  801eb2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801eb5:	50                   	push   %eax
  801eb6:	e8 b7 f5 ff ff       	call   801472 <fd_alloc>
  801ebb:	89 c3                	mov    %eax,%ebx
  801ebd:	83 c4 10             	add    $0x10,%esp
  801ec0:	85 c0                	test   %eax,%eax
  801ec2:	0f 88 db 00 00 00    	js     801fa3 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ec8:	83 ec 04             	sub    $0x4,%esp
  801ecb:	68 07 04 00 00       	push   $0x407
  801ed0:	ff 75 f0             	pushl  -0x10(%ebp)
  801ed3:	6a 00                	push   $0x0
  801ed5:	e8 d5 ed ff ff       	call   800caf <sys_page_alloc>
  801eda:	89 c3                	mov    %eax,%ebx
  801edc:	83 c4 10             	add    $0x10,%esp
  801edf:	85 c0                	test   %eax,%eax
  801ee1:	0f 88 bc 00 00 00    	js     801fa3 <pipe+0x135>
	va = fd2data(fd0);
  801ee7:	83 ec 0c             	sub    $0xc,%esp
  801eea:	ff 75 f4             	pushl  -0xc(%ebp)
  801eed:	e8 61 f5 ff ff       	call   801453 <fd2data>
  801ef2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ef4:	83 c4 0c             	add    $0xc,%esp
  801ef7:	68 07 04 00 00       	push   $0x407
  801efc:	50                   	push   %eax
  801efd:	6a 00                	push   $0x0
  801eff:	e8 ab ed ff ff       	call   800caf <sys_page_alloc>
  801f04:	89 c3                	mov    %eax,%ebx
  801f06:	83 c4 10             	add    $0x10,%esp
  801f09:	85 c0                	test   %eax,%eax
  801f0b:	0f 88 82 00 00 00    	js     801f93 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f11:	83 ec 0c             	sub    $0xc,%esp
  801f14:	ff 75 f0             	pushl  -0x10(%ebp)
  801f17:	e8 37 f5 ff ff       	call   801453 <fd2data>
  801f1c:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f23:	50                   	push   %eax
  801f24:	6a 00                	push   $0x0
  801f26:	56                   	push   %esi
  801f27:	6a 00                	push   $0x0
  801f29:	e8 a9 ed ff ff       	call   800cd7 <sys_page_map>
  801f2e:	89 c3                	mov    %eax,%ebx
  801f30:	83 c4 20             	add    $0x20,%esp
  801f33:	85 c0                	test   %eax,%eax
  801f35:	78 4e                	js     801f85 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801f37:	a1 28 30 80 00       	mov    0x803028,%eax
  801f3c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f3f:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801f41:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f44:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801f4b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f4e:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801f50:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f53:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801f5a:	83 ec 0c             	sub    $0xc,%esp
  801f5d:	ff 75 f4             	pushl  -0xc(%ebp)
  801f60:	e8 da f4 ff ff       	call   80143f <fd2num>
  801f65:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f68:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f6a:	83 c4 04             	add    $0x4,%esp
  801f6d:	ff 75 f0             	pushl  -0x10(%ebp)
  801f70:	e8 ca f4 ff ff       	call   80143f <fd2num>
  801f75:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f78:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f7b:	83 c4 10             	add    $0x10,%esp
  801f7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f83:	eb 2e                	jmp    801fb3 <pipe+0x145>
	sys_page_unmap(0, va);
  801f85:	83 ec 08             	sub    $0x8,%esp
  801f88:	56                   	push   %esi
  801f89:	6a 00                	push   $0x0
  801f8b:	e8 71 ed ff ff       	call   800d01 <sys_page_unmap>
  801f90:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801f93:	83 ec 08             	sub    $0x8,%esp
  801f96:	ff 75 f0             	pushl  -0x10(%ebp)
  801f99:	6a 00                	push   $0x0
  801f9b:	e8 61 ed ff ff       	call   800d01 <sys_page_unmap>
  801fa0:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801fa3:	83 ec 08             	sub    $0x8,%esp
  801fa6:	ff 75 f4             	pushl  -0xc(%ebp)
  801fa9:	6a 00                	push   $0x0
  801fab:	e8 51 ed ff ff       	call   800d01 <sys_page_unmap>
  801fb0:	83 c4 10             	add    $0x10,%esp
}
  801fb3:	89 d8                	mov    %ebx,%eax
  801fb5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801fb8:	5b                   	pop    %ebx
  801fb9:	5e                   	pop    %esi
  801fba:	5d                   	pop    %ebp
  801fbb:	c3                   	ret    

00801fbc <pipeisclosed>:
{
  801fbc:	f3 0f 1e fb          	endbr32 
  801fc0:	55                   	push   %ebp
  801fc1:	89 e5                	mov    %esp,%ebp
  801fc3:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fc6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fc9:	50                   	push   %eax
  801fca:	ff 75 08             	pushl  0x8(%ebp)
  801fcd:	e8 f6 f4 ff ff       	call   8014c8 <fd_lookup>
  801fd2:	83 c4 10             	add    $0x10,%esp
  801fd5:	85 c0                	test   %eax,%eax
  801fd7:	78 18                	js     801ff1 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801fd9:	83 ec 0c             	sub    $0xc,%esp
  801fdc:	ff 75 f4             	pushl  -0xc(%ebp)
  801fdf:	e8 6f f4 ff ff       	call   801453 <fd2data>
  801fe4:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801fe6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fe9:	e8 1f fd ff ff       	call   801d0d <_pipeisclosed>
  801fee:	83 c4 10             	add    $0x10,%esp
}
  801ff1:	c9                   	leave  
  801ff2:	c3                   	ret    

00801ff3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801ff3:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801ff7:	b8 00 00 00 00       	mov    $0x0,%eax
  801ffc:	c3                   	ret    

00801ffd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801ffd:	f3 0f 1e fb          	endbr32 
  802001:	55                   	push   %ebp
  802002:	89 e5                	mov    %esp,%ebp
  802004:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  802007:	68 c2 2b 80 00       	push   $0x802bc2
  80200c:	ff 75 0c             	pushl  0xc(%ebp)
  80200f:	e8 13 e8 ff ff       	call   800827 <strcpy>
	return 0;
}
  802014:	b8 00 00 00 00       	mov    $0x0,%eax
  802019:	c9                   	leave  
  80201a:	c3                   	ret    

0080201b <devcons_write>:
{
  80201b:	f3 0f 1e fb          	endbr32 
  80201f:	55                   	push   %ebp
  802020:	89 e5                	mov    %esp,%ebp
  802022:	57                   	push   %edi
  802023:	56                   	push   %esi
  802024:	53                   	push   %ebx
  802025:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  80202b:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  802030:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802036:	3b 75 10             	cmp    0x10(%ebp),%esi
  802039:	73 31                	jae    80206c <devcons_write+0x51>
		m = n - tot;
  80203b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80203e:	29 f3                	sub    %esi,%ebx
  802040:	83 fb 7f             	cmp    $0x7f,%ebx
  802043:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802048:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  80204b:	83 ec 04             	sub    $0x4,%esp
  80204e:	53                   	push   %ebx
  80204f:	89 f0                	mov    %esi,%eax
  802051:	03 45 0c             	add    0xc(%ebp),%eax
  802054:	50                   	push   %eax
  802055:	57                   	push   %edi
  802056:	e8 84 e9 ff ff       	call   8009df <memmove>
		sys_cputs(buf, m);
  80205b:	83 c4 08             	add    $0x8,%esp
  80205e:	53                   	push   %ebx
  80205f:	57                   	push   %edi
  802060:	e8 7f eb ff ff       	call   800be4 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802065:	01 de                	add    %ebx,%esi
  802067:	83 c4 10             	add    $0x10,%esp
  80206a:	eb ca                	jmp    802036 <devcons_write+0x1b>
}
  80206c:	89 f0                	mov    %esi,%eax
  80206e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802071:	5b                   	pop    %ebx
  802072:	5e                   	pop    %esi
  802073:	5f                   	pop    %edi
  802074:	5d                   	pop    %ebp
  802075:	c3                   	ret    

00802076 <devcons_read>:
{
  802076:	f3 0f 1e fb          	endbr32 
  80207a:	55                   	push   %ebp
  80207b:	89 e5                	mov    %esp,%ebp
  80207d:	83 ec 08             	sub    $0x8,%esp
  802080:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802085:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802089:	74 21                	je     8020ac <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  80208b:	e8 7e eb ff ff       	call   800c0e <sys_cgetc>
  802090:	85 c0                	test   %eax,%eax
  802092:	75 07                	jne    80209b <devcons_read+0x25>
		sys_yield();
  802094:	e8 eb eb ff ff       	call   800c84 <sys_yield>
  802099:	eb f0                	jmp    80208b <devcons_read+0x15>
	if (c < 0)
  80209b:	78 0f                	js     8020ac <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  80209d:	83 f8 04             	cmp    $0x4,%eax
  8020a0:	74 0c                	je     8020ae <devcons_read+0x38>
	*(char*)vbuf = c;
  8020a2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8020a5:	88 02                	mov    %al,(%edx)
	return 1;
  8020a7:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8020ac:	c9                   	leave  
  8020ad:	c3                   	ret    
		return 0;
  8020ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8020b3:	eb f7                	jmp    8020ac <devcons_read+0x36>

008020b5 <cputchar>:
{
  8020b5:	f3 0f 1e fb          	endbr32 
  8020b9:	55                   	push   %ebp
  8020ba:	89 e5                	mov    %esp,%ebp
  8020bc:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8020bf:	8b 45 08             	mov    0x8(%ebp),%eax
  8020c2:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8020c5:	6a 01                	push   $0x1
  8020c7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020ca:	50                   	push   %eax
  8020cb:	e8 14 eb ff ff       	call   800be4 <sys_cputs>
}
  8020d0:	83 c4 10             	add    $0x10,%esp
  8020d3:	c9                   	leave  
  8020d4:	c3                   	ret    

008020d5 <getchar>:
{
  8020d5:	f3 0f 1e fb          	endbr32 
  8020d9:	55                   	push   %ebp
  8020da:	89 e5                	mov    %esp,%ebp
  8020dc:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8020df:	6a 01                	push   $0x1
  8020e1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020e4:	50                   	push   %eax
  8020e5:	6a 00                	push   $0x0
  8020e7:	e8 5f f6 ff ff       	call   80174b <read>
	if (r < 0)
  8020ec:	83 c4 10             	add    $0x10,%esp
  8020ef:	85 c0                	test   %eax,%eax
  8020f1:	78 06                	js     8020f9 <getchar+0x24>
	if (r < 1)
  8020f3:	74 06                	je     8020fb <getchar+0x26>
	return c;
  8020f5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8020f9:	c9                   	leave  
  8020fa:	c3                   	ret    
		return -E_EOF;
  8020fb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  802100:	eb f7                	jmp    8020f9 <getchar+0x24>

00802102 <iscons>:
{
  802102:	f3 0f 1e fb          	endbr32 
  802106:	55                   	push   %ebp
  802107:	89 e5                	mov    %esp,%ebp
  802109:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80210c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80210f:	50                   	push   %eax
  802110:	ff 75 08             	pushl  0x8(%ebp)
  802113:	e8 b0 f3 ff ff       	call   8014c8 <fd_lookup>
  802118:	83 c4 10             	add    $0x10,%esp
  80211b:	85 c0                	test   %eax,%eax
  80211d:	78 11                	js     802130 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80211f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802122:	8b 15 44 30 80 00    	mov    0x803044,%edx
  802128:	39 10                	cmp    %edx,(%eax)
  80212a:	0f 94 c0             	sete   %al
  80212d:	0f b6 c0             	movzbl %al,%eax
}
  802130:	c9                   	leave  
  802131:	c3                   	ret    

00802132 <opencons>:
{
  802132:	f3 0f 1e fb          	endbr32 
  802136:	55                   	push   %ebp
  802137:	89 e5                	mov    %esp,%ebp
  802139:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80213c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80213f:	50                   	push   %eax
  802140:	e8 2d f3 ff ff       	call   801472 <fd_alloc>
  802145:	83 c4 10             	add    $0x10,%esp
  802148:	85 c0                	test   %eax,%eax
  80214a:	78 3a                	js     802186 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80214c:	83 ec 04             	sub    $0x4,%esp
  80214f:	68 07 04 00 00       	push   $0x407
  802154:	ff 75 f4             	pushl  -0xc(%ebp)
  802157:	6a 00                	push   $0x0
  802159:	e8 51 eb ff ff       	call   800caf <sys_page_alloc>
  80215e:	83 c4 10             	add    $0x10,%esp
  802161:	85 c0                	test   %eax,%eax
  802163:	78 21                	js     802186 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  802165:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802168:	8b 15 44 30 80 00    	mov    0x803044,%edx
  80216e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  802170:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802173:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80217a:	83 ec 0c             	sub    $0xc,%esp
  80217d:	50                   	push   %eax
  80217e:	e8 bc f2 ff ff       	call   80143f <fd2num>
  802183:	83 c4 10             	add    $0x10,%esp
}
  802186:	c9                   	leave  
  802187:	c3                   	ret    

00802188 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  802188:	f3 0f 1e fb          	endbr32 
  80218c:	55                   	push   %ebp
  80218d:	89 e5                	mov    %esp,%ebp
  80218f:	56                   	push   %esi
  802190:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  802191:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  802194:	8b 35 08 30 80 00    	mov    0x803008,%esi
  80219a:	e8 bd ea ff ff       	call   800c5c <sys_getenvid>
  80219f:	83 ec 0c             	sub    $0xc,%esp
  8021a2:	ff 75 0c             	pushl  0xc(%ebp)
  8021a5:	ff 75 08             	pushl  0x8(%ebp)
  8021a8:	56                   	push   %esi
  8021a9:	50                   	push   %eax
  8021aa:	68 d0 2b 80 00       	push   $0x802bd0
  8021af:	e8 09 e1 ff ff       	call   8002bd <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  8021b4:	83 c4 18             	add    $0x18,%esp
  8021b7:	53                   	push   %ebx
  8021b8:	ff 75 10             	pushl  0x10(%ebp)
  8021bb:	e8 a8 e0 ff ff       	call   800268 <vcprintf>
	cprintf("\n");
  8021c0:	c7 04 24 bb 2b 80 00 	movl   $0x802bbb,(%esp)
  8021c7:	e8 f1 e0 ff ff       	call   8002bd <cprintf>
  8021cc:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8021cf:	cc                   	int3   
  8021d0:	eb fd                	jmp    8021cf <_panic+0x47>

008021d2 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  8021d2:	f3 0f 1e fb          	endbr32 
  8021d6:	55                   	push   %ebp
  8021d7:	89 e5                	mov    %esp,%ebp
  8021d9:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  8021dc:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  8021e3:	74 1c                	je     802201 <set_pgfault_handler+0x2f>
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  8021e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8021e8:	a3 00 60 80 00       	mov    %eax,0x806000

	//Indicarle al kerne que _pgfault_upcall va a ser el manejador de pgfaults de un proceso
	sys_env_set_pgfault_upcall(0, &(_pgfault_upcall));
  8021ed:	83 ec 08             	sub    $0x8,%esp
  8021f0:	68 2d 22 80 00       	push   $0x80222d
  8021f5:	6a 00                	push   $0x0
  8021f7:	e8 7a eb ff ff       	call   800d76 <sys_env_set_pgfault_upcall>
}
  8021fc:	83 c4 10             	add    $0x10,%esp
  8021ff:	c9                   	leave  
  802200:	c3                   	ret    
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
  802201:	83 ec 04             	sub    $0x4,%esp
  802204:	6a 02                	push   $0x2
  802206:	68 00 f0 bf ee       	push   $0xeebff000
  80220b:	6a 00                	push   $0x0
  80220d:	e8 9d ea ff ff       	call   800caf <sys_page_alloc>
  802212:	83 c4 10             	add    $0x10,%esp
  802215:	85 c0                	test   %eax,%eax
  802217:	79 cc                	jns    8021e5 <set_pgfault_handler+0x13>
  802219:	83 ec 04             	sub    $0x4,%esp
  80221c:	68 f3 2b 80 00       	push   $0x802bf3
  802221:	6a 20                	push   $0x20
  802223:	68 0e 2c 80 00       	push   $0x802c0e
  802228:	e8 5b ff ff ff       	call   802188 <_panic>

0080222d <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  80222d:	54                   	push   %esp
	movl _pgfault_handler, %eax
  80222e:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802233:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  802235:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 40(%esp), %eax
  802238:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	
  80223c:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  802240:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, (%ebx)
  802243:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 48(%esp)
  802245:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  802249:	83 c4 08             	add    $0x8,%esp
	popal
  80224c:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  80224d:	83 c4 04             	add    $0x4,%esp
	popfl
  802250:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  802251:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  802254:	c3                   	ret    

00802255 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802255:	f3 0f 1e fb          	endbr32 
  802259:	55                   	push   %ebp
  80225a:	89 e5                	mov    %esp,%ebp
  80225c:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80225f:	89 c2                	mov    %eax,%edx
  802261:	c1 ea 16             	shr    $0x16,%edx
  802264:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80226b:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802270:	f6 c1 01             	test   $0x1,%cl
  802273:	74 1c                	je     802291 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802275:	c1 e8 0c             	shr    $0xc,%eax
  802278:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80227f:	a8 01                	test   $0x1,%al
  802281:	74 0e                	je     802291 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802283:	c1 e8 0c             	shr    $0xc,%eax
  802286:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80228d:	ef 
  80228e:	0f b7 d2             	movzwl %dx,%edx
}
  802291:	89 d0                	mov    %edx,%eax
  802293:	5d                   	pop    %ebp
  802294:	c3                   	ret    
  802295:	66 90                	xchg   %ax,%ax
  802297:	66 90                	xchg   %ax,%ax
  802299:	66 90                	xchg   %ax,%ax
  80229b:	66 90                	xchg   %ax,%ax
  80229d:	66 90                	xchg   %ax,%ax
  80229f:	90                   	nop

008022a0 <__udivdi3>:
  8022a0:	f3 0f 1e fb          	endbr32 
  8022a4:	55                   	push   %ebp
  8022a5:	57                   	push   %edi
  8022a6:	56                   	push   %esi
  8022a7:	53                   	push   %ebx
  8022a8:	83 ec 1c             	sub    $0x1c,%esp
  8022ab:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8022af:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8022b3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8022b7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8022bb:	85 d2                	test   %edx,%edx
  8022bd:	75 19                	jne    8022d8 <__udivdi3+0x38>
  8022bf:	39 f3                	cmp    %esi,%ebx
  8022c1:	76 4d                	jbe    802310 <__udivdi3+0x70>
  8022c3:	31 ff                	xor    %edi,%edi
  8022c5:	89 e8                	mov    %ebp,%eax
  8022c7:	89 f2                	mov    %esi,%edx
  8022c9:	f7 f3                	div    %ebx
  8022cb:	89 fa                	mov    %edi,%edx
  8022cd:	83 c4 1c             	add    $0x1c,%esp
  8022d0:	5b                   	pop    %ebx
  8022d1:	5e                   	pop    %esi
  8022d2:	5f                   	pop    %edi
  8022d3:	5d                   	pop    %ebp
  8022d4:	c3                   	ret    
  8022d5:	8d 76 00             	lea    0x0(%esi),%esi
  8022d8:	39 f2                	cmp    %esi,%edx
  8022da:	76 14                	jbe    8022f0 <__udivdi3+0x50>
  8022dc:	31 ff                	xor    %edi,%edi
  8022de:	31 c0                	xor    %eax,%eax
  8022e0:	89 fa                	mov    %edi,%edx
  8022e2:	83 c4 1c             	add    $0x1c,%esp
  8022e5:	5b                   	pop    %ebx
  8022e6:	5e                   	pop    %esi
  8022e7:	5f                   	pop    %edi
  8022e8:	5d                   	pop    %ebp
  8022e9:	c3                   	ret    
  8022ea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8022f0:	0f bd fa             	bsr    %edx,%edi
  8022f3:	83 f7 1f             	xor    $0x1f,%edi
  8022f6:	75 48                	jne    802340 <__udivdi3+0xa0>
  8022f8:	39 f2                	cmp    %esi,%edx
  8022fa:	72 06                	jb     802302 <__udivdi3+0x62>
  8022fc:	31 c0                	xor    %eax,%eax
  8022fe:	39 eb                	cmp    %ebp,%ebx
  802300:	77 de                	ja     8022e0 <__udivdi3+0x40>
  802302:	b8 01 00 00 00       	mov    $0x1,%eax
  802307:	eb d7                	jmp    8022e0 <__udivdi3+0x40>
  802309:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802310:	89 d9                	mov    %ebx,%ecx
  802312:	85 db                	test   %ebx,%ebx
  802314:	75 0b                	jne    802321 <__udivdi3+0x81>
  802316:	b8 01 00 00 00       	mov    $0x1,%eax
  80231b:	31 d2                	xor    %edx,%edx
  80231d:	f7 f3                	div    %ebx
  80231f:	89 c1                	mov    %eax,%ecx
  802321:	31 d2                	xor    %edx,%edx
  802323:	89 f0                	mov    %esi,%eax
  802325:	f7 f1                	div    %ecx
  802327:	89 c6                	mov    %eax,%esi
  802329:	89 e8                	mov    %ebp,%eax
  80232b:	89 f7                	mov    %esi,%edi
  80232d:	f7 f1                	div    %ecx
  80232f:	89 fa                	mov    %edi,%edx
  802331:	83 c4 1c             	add    $0x1c,%esp
  802334:	5b                   	pop    %ebx
  802335:	5e                   	pop    %esi
  802336:	5f                   	pop    %edi
  802337:	5d                   	pop    %ebp
  802338:	c3                   	ret    
  802339:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802340:	89 f9                	mov    %edi,%ecx
  802342:	b8 20 00 00 00       	mov    $0x20,%eax
  802347:	29 f8                	sub    %edi,%eax
  802349:	d3 e2                	shl    %cl,%edx
  80234b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80234f:	89 c1                	mov    %eax,%ecx
  802351:	89 da                	mov    %ebx,%edx
  802353:	d3 ea                	shr    %cl,%edx
  802355:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802359:	09 d1                	or     %edx,%ecx
  80235b:	89 f2                	mov    %esi,%edx
  80235d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802361:	89 f9                	mov    %edi,%ecx
  802363:	d3 e3                	shl    %cl,%ebx
  802365:	89 c1                	mov    %eax,%ecx
  802367:	d3 ea                	shr    %cl,%edx
  802369:	89 f9                	mov    %edi,%ecx
  80236b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80236f:	89 eb                	mov    %ebp,%ebx
  802371:	d3 e6                	shl    %cl,%esi
  802373:	89 c1                	mov    %eax,%ecx
  802375:	d3 eb                	shr    %cl,%ebx
  802377:	09 de                	or     %ebx,%esi
  802379:	89 f0                	mov    %esi,%eax
  80237b:	f7 74 24 08          	divl   0x8(%esp)
  80237f:	89 d6                	mov    %edx,%esi
  802381:	89 c3                	mov    %eax,%ebx
  802383:	f7 64 24 0c          	mull   0xc(%esp)
  802387:	39 d6                	cmp    %edx,%esi
  802389:	72 15                	jb     8023a0 <__udivdi3+0x100>
  80238b:	89 f9                	mov    %edi,%ecx
  80238d:	d3 e5                	shl    %cl,%ebp
  80238f:	39 c5                	cmp    %eax,%ebp
  802391:	73 04                	jae    802397 <__udivdi3+0xf7>
  802393:	39 d6                	cmp    %edx,%esi
  802395:	74 09                	je     8023a0 <__udivdi3+0x100>
  802397:	89 d8                	mov    %ebx,%eax
  802399:	31 ff                	xor    %edi,%edi
  80239b:	e9 40 ff ff ff       	jmp    8022e0 <__udivdi3+0x40>
  8023a0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8023a3:	31 ff                	xor    %edi,%edi
  8023a5:	e9 36 ff ff ff       	jmp    8022e0 <__udivdi3+0x40>
  8023aa:	66 90                	xchg   %ax,%ax
  8023ac:	66 90                	xchg   %ax,%ax
  8023ae:	66 90                	xchg   %ax,%ax

008023b0 <__umoddi3>:
  8023b0:	f3 0f 1e fb          	endbr32 
  8023b4:	55                   	push   %ebp
  8023b5:	57                   	push   %edi
  8023b6:	56                   	push   %esi
  8023b7:	53                   	push   %ebx
  8023b8:	83 ec 1c             	sub    $0x1c,%esp
  8023bb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8023bf:	8b 74 24 30          	mov    0x30(%esp),%esi
  8023c3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8023c7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8023cb:	85 c0                	test   %eax,%eax
  8023cd:	75 19                	jne    8023e8 <__umoddi3+0x38>
  8023cf:	39 df                	cmp    %ebx,%edi
  8023d1:	76 5d                	jbe    802430 <__umoddi3+0x80>
  8023d3:	89 f0                	mov    %esi,%eax
  8023d5:	89 da                	mov    %ebx,%edx
  8023d7:	f7 f7                	div    %edi
  8023d9:	89 d0                	mov    %edx,%eax
  8023db:	31 d2                	xor    %edx,%edx
  8023dd:	83 c4 1c             	add    $0x1c,%esp
  8023e0:	5b                   	pop    %ebx
  8023e1:	5e                   	pop    %esi
  8023e2:	5f                   	pop    %edi
  8023e3:	5d                   	pop    %ebp
  8023e4:	c3                   	ret    
  8023e5:	8d 76 00             	lea    0x0(%esi),%esi
  8023e8:	89 f2                	mov    %esi,%edx
  8023ea:	39 d8                	cmp    %ebx,%eax
  8023ec:	76 12                	jbe    802400 <__umoddi3+0x50>
  8023ee:	89 f0                	mov    %esi,%eax
  8023f0:	89 da                	mov    %ebx,%edx
  8023f2:	83 c4 1c             	add    $0x1c,%esp
  8023f5:	5b                   	pop    %ebx
  8023f6:	5e                   	pop    %esi
  8023f7:	5f                   	pop    %edi
  8023f8:	5d                   	pop    %ebp
  8023f9:	c3                   	ret    
  8023fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802400:	0f bd e8             	bsr    %eax,%ebp
  802403:	83 f5 1f             	xor    $0x1f,%ebp
  802406:	75 50                	jne    802458 <__umoddi3+0xa8>
  802408:	39 d8                	cmp    %ebx,%eax
  80240a:	0f 82 e0 00 00 00    	jb     8024f0 <__umoddi3+0x140>
  802410:	89 d9                	mov    %ebx,%ecx
  802412:	39 f7                	cmp    %esi,%edi
  802414:	0f 86 d6 00 00 00    	jbe    8024f0 <__umoddi3+0x140>
  80241a:	89 d0                	mov    %edx,%eax
  80241c:	89 ca                	mov    %ecx,%edx
  80241e:	83 c4 1c             	add    $0x1c,%esp
  802421:	5b                   	pop    %ebx
  802422:	5e                   	pop    %esi
  802423:	5f                   	pop    %edi
  802424:	5d                   	pop    %ebp
  802425:	c3                   	ret    
  802426:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80242d:	8d 76 00             	lea    0x0(%esi),%esi
  802430:	89 fd                	mov    %edi,%ebp
  802432:	85 ff                	test   %edi,%edi
  802434:	75 0b                	jne    802441 <__umoddi3+0x91>
  802436:	b8 01 00 00 00       	mov    $0x1,%eax
  80243b:	31 d2                	xor    %edx,%edx
  80243d:	f7 f7                	div    %edi
  80243f:	89 c5                	mov    %eax,%ebp
  802441:	89 d8                	mov    %ebx,%eax
  802443:	31 d2                	xor    %edx,%edx
  802445:	f7 f5                	div    %ebp
  802447:	89 f0                	mov    %esi,%eax
  802449:	f7 f5                	div    %ebp
  80244b:	89 d0                	mov    %edx,%eax
  80244d:	31 d2                	xor    %edx,%edx
  80244f:	eb 8c                	jmp    8023dd <__umoddi3+0x2d>
  802451:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802458:	89 e9                	mov    %ebp,%ecx
  80245a:	ba 20 00 00 00       	mov    $0x20,%edx
  80245f:	29 ea                	sub    %ebp,%edx
  802461:	d3 e0                	shl    %cl,%eax
  802463:	89 44 24 08          	mov    %eax,0x8(%esp)
  802467:	89 d1                	mov    %edx,%ecx
  802469:	89 f8                	mov    %edi,%eax
  80246b:	d3 e8                	shr    %cl,%eax
  80246d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802471:	89 54 24 04          	mov    %edx,0x4(%esp)
  802475:	8b 54 24 04          	mov    0x4(%esp),%edx
  802479:	09 c1                	or     %eax,%ecx
  80247b:	89 d8                	mov    %ebx,%eax
  80247d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802481:	89 e9                	mov    %ebp,%ecx
  802483:	d3 e7                	shl    %cl,%edi
  802485:	89 d1                	mov    %edx,%ecx
  802487:	d3 e8                	shr    %cl,%eax
  802489:	89 e9                	mov    %ebp,%ecx
  80248b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80248f:	d3 e3                	shl    %cl,%ebx
  802491:	89 c7                	mov    %eax,%edi
  802493:	89 d1                	mov    %edx,%ecx
  802495:	89 f0                	mov    %esi,%eax
  802497:	d3 e8                	shr    %cl,%eax
  802499:	89 e9                	mov    %ebp,%ecx
  80249b:	89 fa                	mov    %edi,%edx
  80249d:	d3 e6                	shl    %cl,%esi
  80249f:	09 d8                	or     %ebx,%eax
  8024a1:	f7 74 24 08          	divl   0x8(%esp)
  8024a5:	89 d1                	mov    %edx,%ecx
  8024a7:	89 f3                	mov    %esi,%ebx
  8024a9:	f7 64 24 0c          	mull   0xc(%esp)
  8024ad:	89 c6                	mov    %eax,%esi
  8024af:	89 d7                	mov    %edx,%edi
  8024b1:	39 d1                	cmp    %edx,%ecx
  8024b3:	72 06                	jb     8024bb <__umoddi3+0x10b>
  8024b5:	75 10                	jne    8024c7 <__umoddi3+0x117>
  8024b7:	39 c3                	cmp    %eax,%ebx
  8024b9:	73 0c                	jae    8024c7 <__umoddi3+0x117>
  8024bb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8024bf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8024c3:	89 d7                	mov    %edx,%edi
  8024c5:	89 c6                	mov    %eax,%esi
  8024c7:	89 ca                	mov    %ecx,%edx
  8024c9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8024ce:	29 f3                	sub    %esi,%ebx
  8024d0:	19 fa                	sbb    %edi,%edx
  8024d2:	89 d0                	mov    %edx,%eax
  8024d4:	d3 e0                	shl    %cl,%eax
  8024d6:	89 e9                	mov    %ebp,%ecx
  8024d8:	d3 eb                	shr    %cl,%ebx
  8024da:	d3 ea                	shr    %cl,%edx
  8024dc:	09 d8                	or     %ebx,%eax
  8024de:	83 c4 1c             	add    $0x1c,%esp
  8024e1:	5b                   	pop    %ebx
  8024e2:	5e                   	pop    %esi
  8024e3:	5f                   	pop    %edi
  8024e4:	5d                   	pop    %ebp
  8024e5:	c3                   	ret    
  8024e6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024ed:	8d 76 00             	lea    0x0(%esi),%esi
  8024f0:	29 fe                	sub    %edi,%esi
  8024f2:	19 c3                	sbb    %eax,%ebx
  8024f4:	89 f2                	mov    %esi,%edx
  8024f6:	89 d9                	mov    %ebx,%ecx
  8024f8:	e9 1d ff ff ff       	jmp    80241a <__umoddi3+0x6a>
