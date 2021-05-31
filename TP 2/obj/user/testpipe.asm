
obj/user/testpipe.debug:     formato del fichero elf32-i386


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
  80002c:	e8 a5 02 00 00       	call   8002d6 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

char *msg = "Now is the time for all good men to come to the aid of their party.";

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
  80003c:	83 ec 7c             	sub    $0x7c,%esp
	char buf[100];
	int i, pid, p[2];

	binaryname = "pipereadeof";
  80003f:	c7 05 04 30 80 00 80 	movl   $0x802680,0x803004
  800046:	26 80 00 

	if ((i = pipe(p)) < 0)
  800049:	8d 45 8c             	lea    -0x74(%ebp),%eax
  80004c:	50                   	push   %eax
  80004d:	e8 78 1e 00 00       	call   801eca <pipe>
  800052:	89 c6                	mov    %eax,%esi
  800054:	83 c4 10             	add    $0x10,%esp
  800057:	85 c0                	test   %eax,%eax
  800059:	0f 88 1b 01 00 00    	js     80017a <umain+0x147>
		panic("pipe: %e", i);

	if ((pid = fork()) < 0)
  80005f:	e8 96 12 00 00       	call   8012fa <fork>
  800064:	89 c3                	mov    %eax,%ebx
  800066:	85 c0                	test   %eax,%eax
  800068:	0f 88 1e 01 00 00    	js     80018c <umain+0x159>
		panic("fork: %e", i);

	if (pid == 0) {
  80006e:	0f 85 56 01 00 00    	jne    8001ca <umain+0x197>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[1]);
  800074:	a1 04 40 80 00       	mov    0x804004,%eax
  800079:	8b 40 48             	mov    0x48(%eax),%eax
  80007c:	83 ec 04             	sub    $0x4,%esp
  80007f:	ff 75 90             	pushl  -0x70(%ebp)
  800082:	50                   	push   %eax
  800083:	68 ae 26 80 00       	push   $0x8026ae
  800088:	e8 9c 03 00 00       	call   800429 <cprintf>
		close(p[1]);
  80008d:	83 c4 04             	add    $0x4,%esp
  800090:	ff 75 90             	pushl  -0x70(%ebp)
  800093:	e8 c5 15 00 00       	call   80165d <close>
		cprintf("[%08x] pipereadeof readn %d\n", thisenv->env_id, p[0]);
  800098:	a1 04 40 80 00       	mov    0x804004,%eax
  80009d:	8b 40 48             	mov    0x48(%eax),%eax
  8000a0:	83 c4 0c             	add    $0xc,%esp
  8000a3:	ff 75 8c             	pushl  -0x74(%ebp)
  8000a6:	50                   	push   %eax
  8000a7:	68 cb 26 80 00       	push   $0x8026cb
  8000ac:	e8 78 03 00 00       	call   800429 <cprintf>
		i = readn(p[0], buf, sizeof buf-1);
  8000b1:	83 c4 0c             	add    $0xc,%esp
  8000b4:	6a 63                	push   $0x63
  8000b6:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000b9:	50                   	push   %eax
  8000ba:	ff 75 8c             	pushl  -0x74(%ebp)
  8000bd:	e8 70 17 00 00       	call   801832 <readn>
  8000c2:	89 c6                	mov    %eax,%esi
		if (i < 0)
  8000c4:	83 c4 10             	add    $0x10,%esp
  8000c7:	85 c0                	test   %eax,%eax
  8000c9:	0f 88 cf 00 00 00    	js     80019e <umain+0x16b>
			panic("read: %e", i);
		buf[i] = 0;
  8000cf:	c6 44 05 94 00       	movb   $0x0,-0x6c(%ebp,%eax,1)
		if (strcmp(buf, msg) == 0)
  8000d4:	83 ec 08             	sub    $0x8,%esp
  8000d7:	ff 35 00 30 80 00    	pushl  0x803000
  8000dd:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8000e0:	50                   	push   %eax
  8000e1:	e8 6c 09 00 00       	call   800a52 <strcmp>
  8000e6:	83 c4 10             	add    $0x10,%esp
  8000e9:	85 c0                	test   %eax,%eax
  8000eb:	0f 85 bf 00 00 00    	jne    8001b0 <umain+0x17d>
			cprintf("\npipe read closed properly\n");
  8000f1:	83 ec 0c             	sub    $0xc,%esp
  8000f4:	68 f1 26 80 00       	push   $0x8026f1
  8000f9:	e8 2b 03 00 00       	call   800429 <cprintf>
  8000fe:	83 c4 10             	add    $0x10,%esp
		else
			cprintf("\ngot %d bytes: %s\n", i, buf);
		exit();
  800101:	e8 1e 02 00 00       	call   800324 <exit>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
			panic("write: %e", i);
		close(p[1]);
	}
	wait(pid);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	53                   	push   %ebx
  80010a:	e8 40 1f 00 00       	call   80204f <wait>

	binaryname = "pipewriteeof";
  80010f:	c7 05 04 30 80 00 47 	movl   $0x802747,0x803004
  800116:	27 80 00 
	if ((i = pipe(p)) < 0)
  800119:	8d 45 8c             	lea    -0x74(%ebp),%eax
  80011c:	89 04 24             	mov    %eax,(%esp)
  80011f:	e8 a6 1d 00 00       	call   801eca <pipe>
  800124:	89 c6                	mov    %eax,%esi
  800126:	83 c4 10             	add    $0x10,%esp
  800129:	85 c0                	test   %eax,%eax
  80012b:	0f 88 32 01 00 00    	js     800263 <umain+0x230>
		panic("pipe: %e", i);

	if ((pid = fork()) < 0)
  800131:	e8 c4 11 00 00       	call   8012fa <fork>
  800136:	89 c3                	mov    %eax,%ebx
  800138:	85 c0                	test   %eax,%eax
  80013a:	0f 88 35 01 00 00    	js     800275 <umain+0x242>
		panic("fork: %e", i);

	if (pid == 0) {
  800140:	0f 84 41 01 00 00    	je     800287 <umain+0x254>
				break;
		}
		cprintf("\npipe write closed properly\n");
		exit();
	}
	close(p[0]);
  800146:	83 ec 0c             	sub    $0xc,%esp
  800149:	ff 75 8c             	pushl  -0x74(%ebp)
  80014c:	e8 0c 15 00 00       	call   80165d <close>
	close(p[1]);
  800151:	83 c4 04             	add    $0x4,%esp
  800154:	ff 75 90             	pushl  -0x70(%ebp)
  800157:	e8 01 15 00 00       	call   80165d <close>
	wait(pid);
  80015c:	89 1c 24             	mov    %ebx,(%esp)
  80015f:	e8 eb 1e 00 00       	call   80204f <wait>

	cprintf("pipe tests passed\n");
  800164:	c7 04 24 75 27 80 00 	movl   $0x802775,(%esp)
  80016b:	e8 b9 02 00 00       	call   800429 <cprintf>
}
  800170:	83 c4 10             	add    $0x10,%esp
  800173:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800176:	5b                   	pop    %ebx
  800177:	5e                   	pop    %esi
  800178:	5d                   	pop    %ebp
  800179:	c3                   	ret    
		panic("pipe: %e", i);
  80017a:	50                   	push   %eax
  80017b:	68 8c 26 80 00       	push   $0x80268c
  800180:	6a 0e                	push   $0xe
  800182:	68 95 26 80 00       	push   $0x802695
  800187:	e8 b6 01 00 00       	call   800342 <_panic>
		panic("fork: %e", i);
  80018c:	56                   	push   %esi
  80018d:	68 a5 26 80 00       	push   $0x8026a5
  800192:	6a 11                	push   $0x11
  800194:	68 95 26 80 00       	push   $0x802695
  800199:	e8 a4 01 00 00       	call   800342 <_panic>
			panic("read: %e", i);
  80019e:	50                   	push   %eax
  80019f:	68 e8 26 80 00       	push   $0x8026e8
  8001a4:	6a 19                	push   $0x19
  8001a6:	68 95 26 80 00       	push   $0x802695
  8001ab:	e8 92 01 00 00       	call   800342 <_panic>
			cprintf("\ngot %d bytes: %s\n", i, buf);
  8001b0:	83 ec 04             	sub    $0x4,%esp
  8001b3:	8d 45 94             	lea    -0x6c(%ebp),%eax
  8001b6:	50                   	push   %eax
  8001b7:	56                   	push   %esi
  8001b8:	68 0d 27 80 00       	push   $0x80270d
  8001bd:	e8 67 02 00 00       	call   800429 <cprintf>
  8001c2:	83 c4 10             	add    $0x10,%esp
  8001c5:	e9 37 ff ff ff       	jmp    800101 <umain+0xce>
		cprintf("[%08x] pipereadeof close %d\n", thisenv->env_id, p[0]);
  8001ca:	a1 04 40 80 00       	mov    0x804004,%eax
  8001cf:	8b 40 48             	mov    0x48(%eax),%eax
  8001d2:	83 ec 04             	sub    $0x4,%esp
  8001d5:	ff 75 8c             	pushl  -0x74(%ebp)
  8001d8:	50                   	push   %eax
  8001d9:	68 ae 26 80 00       	push   $0x8026ae
  8001de:	e8 46 02 00 00       	call   800429 <cprintf>
		close(p[0]);
  8001e3:	83 c4 04             	add    $0x4,%esp
  8001e6:	ff 75 8c             	pushl  -0x74(%ebp)
  8001e9:	e8 6f 14 00 00       	call   80165d <close>
		cprintf("[%08x] pipereadeof write %d\n", thisenv->env_id, p[1]);
  8001ee:	a1 04 40 80 00       	mov    0x804004,%eax
  8001f3:	8b 40 48             	mov    0x48(%eax),%eax
  8001f6:	83 c4 0c             	add    $0xc,%esp
  8001f9:	ff 75 90             	pushl  -0x70(%ebp)
  8001fc:	50                   	push   %eax
  8001fd:	68 20 27 80 00       	push   $0x802720
  800202:	e8 22 02 00 00       	call   800429 <cprintf>
		if ((i = write(p[1], msg, strlen(msg))) != strlen(msg))
  800207:	83 c4 04             	add    $0x4,%esp
  80020a:	ff 35 00 30 80 00    	pushl  0x803000
  800210:	e8 3b 07 00 00       	call   800950 <strlen>
  800215:	83 c4 0c             	add    $0xc,%esp
  800218:	50                   	push   %eax
  800219:	ff 35 00 30 80 00    	pushl  0x803000
  80021f:	ff 75 90             	pushl  -0x70(%ebp)
  800222:	e8 56 16 00 00       	call   80187d <write>
  800227:	89 c6                	mov    %eax,%esi
  800229:	83 c4 04             	add    $0x4,%esp
  80022c:	ff 35 00 30 80 00    	pushl  0x803000
  800232:	e8 19 07 00 00       	call   800950 <strlen>
  800237:	83 c4 10             	add    $0x10,%esp
  80023a:	39 f0                	cmp    %esi,%eax
  80023c:	75 13                	jne    800251 <umain+0x21e>
		close(p[1]);
  80023e:	83 ec 0c             	sub    $0xc,%esp
  800241:	ff 75 90             	pushl  -0x70(%ebp)
  800244:	e8 14 14 00 00       	call   80165d <close>
  800249:	83 c4 10             	add    $0x10,%esp
  80024c:	e9 b5 fe ff ff       	jmp    800106 <umain+0xd3>
			panic("write: %e", i);
  800251:	56                   	push   %esi
  800252:	68 3d 27 80 00       	push   $0x80273d
  800257:	6a 25                	push   $0x25
  800259:	68 95 26 80 00       	push   $0x802695
  80025e:	e8 df 00 00 00       	call   800342 <_panic>
		panic("pipe: %e", i);
  800263:	50                   	push   %eax
  800264:	68 8c 26 80 00       	push   $0x80268c
  800269:	6a 2c                	push   $0x2c
  80026b:	68 95 26 80 00       	push   $0x802695
  800270:	e8 cd 00 00 00       	call   800342 <_panic>
		panic("fork: %e", i);
  800275:	56                   	push   %esi
  800276:	68 a5 26 80 00       	push   $0x8026a5
  80027b:	6a 2f                	push   $0x2f
  80027d:	68 95 26 80 00       	push   $0x802695
  800282:	e8 bb 00 00 00       	call   800342 <_panic>
		close(p[0]);
  800287:	83 ec 0c             	sub    $0xc,%esp
  80028a:	ff 75 8c             	pushl  -0x74(%ebp)
  80028d:	e8 cb 13 00 00       	call   80165d <close>
  800292:	83 c4 10             	add    $0x10,%esp
			cprintf(".");
  800295:	83 ec 0c             	sub    $0xc,%esp
  800298:	68 54 27 80 00       	push   $0x802754
  80029d:	e8 87 01 00 00       	call   800429 <cprintf>
			if (write(p[1], "x", 1) != 1)
  8002a2:	83 c4 0c             	add    $0xc,%esp
  8002a5:	6a 01                	push   $0x1
  8002a7:	68 56 27 80 00       	push   $0x802756
  8002ac:	ff 75 90             	pushl  -0x70(%ebp)
  8002af:	e8 c9 15 00 00       	call   80187d <write>
  8002b4:	83 c4 10             	add    $0x10,%esp
  8002b7:	83 f8 01             	cmp    $0x1,%eax
  8002ba:	74 d9                	je     800295 <umain+0x262>
		cprintf("\npipe write closed properly\n");
  8002bc:	83 ec 0c             	sub    $0xc,%esp
  8002bf:	68 58 27 80 00       	push   $0x802758
  8002c4:	e8 60 01 00 00       	call   800429 <cprintf>
		exit();
  8002c9:	e8 56 00 00 00       	call   800324 <exit>
  8002ce:	83 c4 10             	add    $0x10,%esp
  8002d1:	e9 70 fe ff ff       	jmp    800146 <umain+0x113>

008002d6 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8002d6:	f3 0f 1e fb          	endbr32 
  8002da:	55                   	push   %ebp
  8002db:	89 e5                	mov    %esp,%ebp
  8002dd:	56                   	push   %esi
  8002de:	53                   	push   %ebx
  8002df:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8002e2:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8002e5:	e8 de 0a 00 00       	call   800dc8 <sys_getenvid>
	if (id >= 0)
  8002ea:	85 c0                	test   %eax,%eax
  8002ec:	78 12                	js     800300 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8002ee:	25 ff 03 00 00       	and    $0x3ff,%eax
  8002f3:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8002f6:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002fb:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800300:	85 db                	test   %ebx,%ebx
  800302:	7e 07                	jle    80030b <libmain+0x35>
		binaryname = argv[0];
  800304:	8b 06                	mov    (%esi),%eax
  800306:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80030b:	83 ec 08             	sub    $0x8,%esp
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
  800310:	e8 1e fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800315:	e8 0a 00 00 00       	call   800324 <exit>
}
  80031a:	83 c4 10             	add    $0x10,%esp
  80031d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800320:	5b                   	pop    %ebx
  800321:	5e                   	pop    %esi
  800322:	5d                   	pop    %ebp
  800323:	c3                   	ret    

00800324 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800324:	f3 0f 1e fb          	endbr32 
  800328:	55                   	push   %ebp
  800329:	89 e5                	mov    %esp,%ebp
  80032b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80032e:	e8 5b 13 00 00       	call   80168e <close_all>
	sys_env_destroy(0);
  800333:	83 ec 0c             	sub    $0xc,%esp
  800336:	6a 00                	push   $0x0
  800338:	e8 65 0a 00 00       	call   800da2 <sys_env_destroy>
}
  80033d:	83 c4 10             	add    $0x10,%esp
  800340:	c9                   	leave  
  800341:	c3                   	ret    

00800342 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800342:	f3 0f 1e fb          	endbr32 
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	56                   	push   %esi
  80034a:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80034b:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80034e:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800354:	e8 6f 0a 00 00       	call   800dc8 <sys_getenvid>
  800359:	83 ec 0c             	sub    $0xc,%esp
  80035c:	ff 75 0c             	pushl  0xc(%ebp)
  80035f:	ff 75 08             	pushl  0x8(%ebp)
  800362:	56                   	push   %esi
  800363:	50                   	push   %eax
  800364:	68 d8 27 80 00       	push   $0x8027d8
  800369:	e8 bb 00 00 00       	call   800429 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80036e:	83 c4 18             	add    $0x18,%esp
  800371:	53                   	push   %ebx
  800372:	ff 75 10             	pushl  0x10(%ebp)
  800375:	e8 5a 00 00 00       	call   8003d4 <vcprintf>
	cprintf("\n");
  80037a:	c7 04 24 c9 26 80 00 	movl   $0x8026c9,(%esp)
  800381:	e8 a3 00 00 00       	call   800429 <cprintf>
  800386:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800389:	cc                   	int3   
  80038a:	eb fd                	jmp    800389 <_panic+0x47>

0080038c <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80038c:	f3 0f 1e fb          	endbr32 
  800390:	55                   	push   %ebp
  800391:	89 e5                	mov    %esp,%ebp
  800393:	53                   	push   %ebx
  800394:	83 ec 04             	sub    $0x4,%esp
  800397:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80039a:	8b 13                	mov    (%ebx),%edx
  80039c:	8d 42 01             	lea    0x1(%edx),%eax
  80039f:	89 03                	mov    %eax,(%ebx)
  8003a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a4:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8003a8:	3d ff 00 00 00       	cmp    $0xff,%eax
  8003ad:	74 09                	je     8003b8 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8003af:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8003b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8003b6:	c9                   	leave  
  8003b7:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8003b8:	83 ec 08             	sub    $0x8,%esp
  8003bb:	68 ff 00 00 00       	push   $0xff
  8003c0:	8d 43 08             	lea    0x8(%ebx),%eax
  8003c3:	50                   	push   %eax
  8003c4:	e8 87 09 00 00       	call   800d50 <sys_cputs>
		b->idx = 0;
  8003c9:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8003cf:	83 c4 10             	add    $0x10,%esp
  8003d2:	eb db                	jmp    8003af <putch+0x23>

008003d4 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8003d4:	f3 0f 1e fb          	endbr32 
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8003e1:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003e8:	00 00 00 
	b.cnt = 0;
  8003eb:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003f2:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003f5:	ff 75 0c             	pushl  0xc(%ebp)
  8003f8:	ff 75 08             	pushl  0x8(%ebp)
  8003fb:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800401:	50                   	push   %eax
  800402:	68 8c 03 80 00       	push   $0x80038c
  800407:	e8 80 01 00 00       	call   80058c <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80040c:	83 c4 08             	add    $0x8,%esp
  80040f:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800415:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80041b:	50                   	push   %eax
  80041c:	e8 2f 09 00 00       	call   800d50 <sys_cputs>

	return b.cnt;
}
  800421:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800427:	c9                   	leave  
  800428:	c3                   	ret    

00800429 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800429:	f3 0f 1e fb          	endbr32 
  80042d:	55                   	push   %ebp
  80042e:	89 e5                	mov    %esp,%ebp
  800430:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800433:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800436:	50                   	push   %eax
  800437:	ff 75 08             	pushl  0x8(%ebp)
  80043a:	e8 95 ff ff ff       	call   8003d4 <vcprintf>
	va_end(ap);

	return cnt;
}
  80043f:	c9                   	leave  
  800440:	c3                   	ret    

00800441 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800441:	55                   	push   %ebp
  800442:	89 e5                	mov    %esp,%ebp
  800444:	57                   	push   %edi
  800445:	56                   	push   %esi
  800446:	53                   	push   %ebx
  800447:	83 ec 1c             	sub    $0x1c,%esp
  80044a:	89 c7                	mov    %eax,%edi
  80044c:	89 d6                	mov    %edx,%esi
  80044e:	8b 45 08             	mov    0x8(%ebp),%eax
  800451:	8b 55 0c             	mov    0xc(%ebp),%edx
  800454:	89 d1                	mov    %edx,%ecx
  800456:	89 c2                	mov    %eax,%edx
  800458:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80045b:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80045e:	8b 45 10             	mov    0x10(%ebp),%eax
  800461:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800464:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800467:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80046e:	39 c2                	cmp    %eax,%edx
  800470:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800473:	72 3e                	jb     8004b3 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800475:	83 ec 0c             	sub    $0xc,%esp
  800478:	ff 75 18             	pushl  0x18(%ebp)
  80047b:	83 eb 01             	sub    $0x1,%ebx
  80047e:	53                   	push   %ebx
  80047f:	50                   	push   %eax
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	ff 75 e4             	pushl  -0x1c(%ebp)
  800486:	ff 75 e0             	pushl  -0x20(%ebp)
  800489:	ff 75 dc             	pushl  -0x24(%ebp)
  80048c:	ff 75 d8             	pushl  -0x28(%ebp)
  80048f:	e8 7c 1f 00 00       	call   802410 <__udivdi3>
  800494:	83 c4 18             	add    $0x18,%esp
  800497:	52                   	push   %edx
  800498:	50                   	push   %eax
  800499:	89 f2                	mov    %esi,%edx
  80049b:	89 f8                	mov    %edi,%eax
  80049d:	e8 9f ff ff ff       	call   800441 <printnum>
  8004a2:	83 c4 20             	add    $0x20,%esp
  8004a5:	eb 13                	jmp    8004ba <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	56                   	push   %esi
  8004ab:	ff 75 18             	pushl  0x18(%ebp)
  8004ae:	ff d7                	call   *%edi
  8004b0:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8004b3:	83 eb 01             	sub    $0x1,%ebx
  8004b6:	85 db                	test   %ebx,%ebx
  8004b8:	7f ed                	jg     8004a7 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8004ba:	83 ec 08             	sub    $0x8,%esp
  8004bd:	56                   	push   %esi
  8004be:	83 ec 04             	sub    $0x4,%esp
  8004c1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8004c4:	ff 75 e0             	pushl  -0x20(%ebp)
  8004c7:	ff 75 dc             	pushl  -0x24(%ebp)
  8004ca:	ff 75 d8             	pushl  -0x28(%ebp)
  8004cd:	e8 4e 20 00 00       	call   802520 <__umoddi3>
  8004d2:	83 c4 14             	add    $0x14,%esp
  8004d5:	0f be 80 fb 27 80 00 	movsbl 0x8027fb(%eax),%eax
  8004dc:	50                   	push   %eax
  8004dd:	ff d7                	call   *%edi
}
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004e5:	5b                   	pop    %ebx
  8004e6:	5e                   	pop    %esi
  8004e7:	5f                   	pop    %edi
  8004e8:	5d                   	pop    %ebp
  8004e9:	c3                   	ret    

008004ea <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004ea:	83 fa 01             	cmp    $0x1,%edx
  8004ed:	7f 13                	jg     800502 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8004ef:	85 d2                	test   %edx,%edx
  8004f1:	74 1c                	je     80050f <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8004f3:	8b 10                	mov    (%eax),%edx
  8004f5:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004f8:	89 08                	mov    %ecx,(%eax)
  8004fa:	8b 02                	mov    (%edx),%eax
  8004fc:	ba 00 00 00 00       	mov    $0x0,%edx
  800501:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800502:	8b 10                	mov    (%eax),%edx
  800504:	8d 4a 08             	lea    0x8(%edx),%ecx
  800507:	89 08                	mov    %ecx,(%eax)
  800509:	8b 02                	mov    (%edx),%eax
  80050b:	8b 52 04             	mov    0x4(%edx),%edx
  80050e:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  80050f:	8b 10                	mov    (%eax),%edx
  800511:	8d 4a 04             	lea    0x4(%edx),%ecx
  800514:	89 08                	mov    %ecx,(%eax)
  800516:	8b 02                	mov    (%edx),%eax
  800518:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80051d:	c3                   	ret    

0080051e <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80051e:	83 fa 01             	cmp    $0x1,%edx
  800521:	7f 0f                	jg     800532 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800523:	85 d2                	test   %edx,%edx
  800525:	74 18                	je     80053f <getint+0x21>
		return va_arg(*ap, long);
  800527:	8b 10                	mov    (%eax),%edx
  800529:	8d 4a 04             	lea    0x4(%edx),%ecx
  80052c:	89 08                	mov    %ecx,(%eax)
  80052e:	8b 02                	mov    (%edx),%eax
  800530:	99                   	cltd   
  800531:	c3                   	ret    
		return va_arg(*ap, long long);
  800532:	8b 10                	mov    (%eax),%edx
  800534:	8d 4a 08             	lea    0x8(%edx),%ecx
  800537:	89 08                	mov    %ecx,(%eax)
  800539:	8b 02                	mov    (%edx),%eax
  80053b:	8b 52 04             	mov    0x4(%edx),%edx
  80053e:	c3                   	ret    
	else
		return va_arg(*ap, int);
  80053f:	8b 10                	mov    (%eax),%edx
  800541:	8d 4a 04             	lea    0x4(%edx),%ecx
  800544:	89 08                	mov    %ecx,(%eax)
  800546:	8b 02                	mov    (%edx),%eax
  800548:	99                   	cltd   
}
  800549:	c3                   	ret    

0080054a <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80054a:	f3 0f 1e fb          	endbr32 
  80054e:	55                   	push   %ebp
  80054f:	89 e5                	mov    %esp,%ebp
  800551:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800554:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800558:	8b 10                	mov    (%eax),%edx
  80055a:	3b 50 04             	cmp    0x4(%eax),%edx
  80055d:	73 0a                	jae    800569 <sprintputch+0x1f>
		*b->buf++ = ch;
  80055f:	8d 4a 01             	lea    0x1(%edx),%ecx
  800562:	89 08                	mov    %ecx,(%eax)
  800564:	8b 45 08             	mov    0x8(%ebp),%eax
  800567:	88 02                	mov    %al,(%edx)
}
  800569:	5d                   	pop    %ebp
  80056a:	c3                   	ret    

0080056b <printfmt>:
{
  80056b:	f3 0f 1e fb          	endbr32 
  80056f:	55                   	push   %ebp
  800570:	89 e5                	mov    %esp,%ebp
  800572:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800575:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800578:	50                   	push   %eax
  800579:	ff 75 10             	pushl  0x10(%ebp)
  80057c:	ff 75 0c             	pushl  0xc(%ebp)
  80057f:	ff 75 08             	pushl  0x8(%ebp)
  800582:	e8 05 00 00 00       	call   80058c <vprintfmt>
}
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	c9                   	leave  
  80058b:	c3                   	ret    

0080058c <vprintfmt>:
{
  80058c:	f3 0f 1e fb          	endbr32 
  800590:	55                   	push   %ebp
  800591:	89 e5                	mov    %esp,%ebp
  800593:	57                   	push   %edi
  800594:	56                   	push   %esi
  800595:	53                   	push   %ebx
  800596:	83 ec 2c             	sub    $0x2c,%esp
  800599:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80059c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80059f:	8b 7d 10             	mov    0x10(%ebp),%edi
  8005a2:	e9 86 02 00 00       	jmp    80082d <vprintfmt+0x2a1>
		padc = ' ';
  8005a7:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8005ab:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8005b2:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8005b9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8005c0:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8005c5:	8d 47 01             	lea    0x1(%edi),%eax
  8005c8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8005cb:	0f b6 17             	movzbl (%edi),%edx
  8005ce:	8d 42 dd             	lea    -0x23(%edx),%eax
  8005d1:	3c 55                	cmp    $0x55,%al
  8005d3:	0f 87 df 02 00 00    	ja     8008b8 <vprintfmt+0x32c>
  8005d9:	0f b6 c0             	movzbl %al,%eax
  8005dc:	3e ff 24 85 40 29 80 	notrack jmp *0x802940(,%eax,4)
  8005e3:	00 
  8005e4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8005e7:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8005eb:	eb d8                	jmp    8005c5 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8005ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005f0:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8005f4:	eb cf                	jmp    8005c5 <vprintfmt+0x39>
  8005f6:	0f b6 d2             	movzbl %dl,%edx
  8005f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800601:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800604:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800607:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80060b:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80060e:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800611:	83 f9 09             	cmp    $0x9,%ecx
  800614:	77 52                	ja     800668 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  800616:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800619:	eb e9                	jmp    800604 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80061b:	8b 45 14             	mov    0x14(%ebp),%eax
  80061e:	8d 50 04             	lea    0x4(%eax),%edx
  800621:	89 55 14             	mov    %edx,0x14(%ebp)
  800624:	8b 00                	mov    (%eax),%eax
  800626:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800629:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80062c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800630:	79 93                	jns    8005c5 <vprintfmt+0x39>
				width = precision, precision = -1;
  800632:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800635:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800638:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80063f:	eb 84                	jmp    8005c5 <vprintfmt+0x39>
  800641:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800644:	85 c0                	test   %eax,%eax
  800646:	ba 00 00 00 00       	mov    $0x0,%edx
  80064b:	0f 49 d0             	cmovns %eax,%edx
  80064e:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800651:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800654:	e9 6c ff ff ff       	jmp    8005c5 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800659:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80065c:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800663:	e9 5d ff ff ff       	jmp    8005c5 <vprintfmt+0x39>
  800668:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80066b:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80066e:	eb bc                	jmp    80062c <vprintfmt+0xa0>
			lflag++;
  800670:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800673:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800676:	e9 4a ff ff ff       	jmp    8005c5 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80067b:	8b 45 14             	mov    0x14(%ebp),%eax
  80067e:	8d 50 04             	lea    0x4(%eax),%edx
  800681:	89 55 14             	mov    %edx,0x14(%ebp)
  800684:	83 ec 08             	sub    $0x8,%esp
  800687:	56                   	push   %esi
  800688:	ff 30                	pushl  (%eax)
  80068a:	ff d3                	call   *%ebx
			break;
  80068c:	83 c4 10             	add    $0x10,%esp
  80068f:	e9 96 01 00 00       	jmp    80082a <vprintfmt+0x29e>
			err = va_arg(ap, int);
  800694:	8b 45 14             	mov    0x14(%ebp),%eax
  800697:	8d 50 04             	lea    0x4(%eax),%edx
  80069a:	89 55 14             	mov    %edx,0x14(%ebp)
  80069d:	8b 00                	mov    (%eax),%eax
  80069f:	99                   	cltd   
  8006a0:	31 d0                	xor    %edx,%eax
  8006a2:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8006a4:	83 f8 0f             	cmp    $0xf,%eax
  8006a7:	7f 20                	jg     8006c9 <vprintfmt+0x13d>
  8006a9:	8b 14 85 a0 2a 80 00 	mov    0x802aa0(,%eax,4),%edx
  8006b0:	85 d2                	test   %edx,%edx
  8006b2:	74 15                	je     8006c9 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8006b4:	52                   	push   %edx
  8006b5:	68 b5 2d 80 00       	push   $0x802db5
  8006ba:	56                   	push   %esi
  8006bb:	53                   	push   %ebx
  8006bc:	e8 aa fe ff ff       	call   80056b <printfmt>
  8006c1:	83 c4 10             	add    $0x10,%esp
  8006c4:	e9 61 01 00 00       	jmp    80082a <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8006c9:	50                   	push   %eax
  8006ca:	68 13 28 80 00       	push   $0x802813
  8006cf:	56                   	push   %esi
  8006d0:	53                   	push   %ebx
  8006d1:	e8 95 fe ff ff       	call   80056b <printfmt>
  8006d6:	83 c4 10             	add    $0x10,%esp
  8006d9:	e9 4c 01 00 00       	jmp    80082a <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8006de:	8b 45 14             	mov    0x14(%ebp),%eax
  8006e1:	8d 50 04             	lea    0x4(%eax),%edx
  8006e4:	89 55 14             	mov    %edx,0x14(%ebp)
  8006e7:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8006e9:	85 c9                	test   %ecx,%ecx
  8006eb:	b8 0c 28 80 00       	mov    $0x80280c,%eax
  8006f0:	0f 45 c1             	cmovne %ecx,%eax
  8006f3:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8006f6:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006fa:	7e 06                	jle    800702 <vprintfmt+0x176>
  8006fc:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800700:	75 0d                	jne    80070f <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  800702:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800705:	89 c7                	mov    %eax,%edi
  800707:	03 45 e0             	add    -0x20(%ebp),%eax
  80070a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80070d:	eb 57                	jmp    800766 <vprintfmt+0x1da>
  80070f:	83 ec 08             	sub    $0x8,%esp
  800712:	ff 75 d8             	pushl  -0x28(%ebp)
  800715:	ff 75 cc             	pushl  -0x34(%ebp)
  800718:	e8 4f 02 00 00       	call   80096c <strnlen>
  80071d:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800720:	29 c2                	sub    %eax,%edx
  800722:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800725:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800728:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80072c:	89 5d 08             	mov    %ebx,0x8(%ebp)
  80072f:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800731:	85 db                	test   %ebx,%ebx
  800733:	7e 10                	jle    800745 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800735:	83 ec 08             	sub    $0x8,%esp
  800738:	56                   	push   %esi
  800739:	57                   	push   %edi
  80073a:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80073d:	83 eb 01             	sub    $0x1,%ebx
  800740:	83 c4 10             	add    $0x10,%esp
  800743:	eb ec                	jmp    800731 <vprintfmt+0x1a5>
  800745:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800748:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80074b:	85 d2                	test   %edx,%edx
  80074d:	b8 00 00 00 00       	mov    $0x0,%eax
  800752:	0f 49 c2             	cmovns %edx,%eax
  800755:	29 c2                	sub    %eax,%edx
  800757:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80075a:	eb a6                	jmp    800702 <vprintfmt+0x176>
					putch(ch, putdat);
  80075c:	83 ec 08             	sub    $0x8,%esp
  80075f:	56                   	push   %esi
  800760:	52                   	push   %edx
  800761:	ff d3                	call   *%ebx
  800763:	83 c4 10             	add    $0x10,%esp
  800766:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800769:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80076b:	83 c7 01             	add    $0x1,%edi
  80076e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800772:	0f be d0             	movsbl %al,%edx
  800775:	85 d2                	test   %edx,%edx
  800777:	74 42                	je     8007bb <vprintfmt+0x22f>
  800779:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80077d:	78 06                	js     800785 <vprintfmt+0x1f9>
  80077f:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800783:	78 1e                	js     8007a3 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  800785:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800789:	74 d1                	je     80075c <vprintfmt+0x1d0>
  80078b:	0f be c0             	movsbl %al,%eax
  80078e:	83 e8 20             	sub    $0x20,%eax
  800791:	83 f8 5e             	cmp    $0x5e,%eax
  800794:	76 c6                	jbe    80075c <vprintfmt+0x1d0>
					putch('?', putdat);
  800796:	83 ec 08             	sub    $0x8,%esp
  800799:	56                   	push   %esi
  80079a:	6a 3f                	push   $0x3f
  80079c:	ff d3                	call   *%ebx
  80079e:	83 c4 10             	add    $0x10,%esp
  8007a1:	eb c3                	jmp    800766 <vprintfmt+0x1da>
  8007a3:	89 cf                	mov    %ecx,%edi
  8007a5:	eb 0e                	jmp    8007b5 <vprintfmt+0x229>
				putch(' ', putdat);
  8007a7:	83 ec 08             	sub    $0x8,%esp
  8007aa:	56                   	push   %esi
  8007ab:	6a 20                	push   $0x20
  8007ad:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8007af:	83 ef 01             	sub    $0x1,%edi
  8007b2:	83 c4 10             	add    $0x10,%esp
  8007b5:	85 ff                	test   %edi,%edi
  8007b7:	7f ee                	jg     8007a7 <vprintfmt+0x21b>
  8007b9:	eb 6f                	jmp    80082a <vprintfmt+0x29e>
  8007bb:	89 cf                	mov    %ecx,%edi
  8007bd:	eb f6                	jmp    8007b5 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8007bf:	89 ca                	mov    %ecx,%edx
  8007c1:	8d 45 14             	lea    0x14(%ebp),%eax
  8007c4:	e8 55 fd ff ff       	call   80051e <getint>
  8007c9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007cc:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8007cf:	85 d2                	test   %edx,%edx
  8007d1:	78 0b                	js     8007de <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8007d3:	89 d1                	mov    %edx,%ecx
  8007d5:	89 c2                	mov    %eax,%edx
			base = 10;
  8007d7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007dc:	eb 32                	jmp    800810 <vprintfmt+0x284>
				putch('-', putdat);
  8007de:	83 ec 08             	sub    $0x8,%esp
  8007e1:	56                   	push   %esi
  8007e2:	6a 2d                	push   $0x2d
  8007e4:	ff d3                	call   *%ebx
				num = -(long long) num;
  8007e6:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8007e9:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8007ec:	f7 da                	neg    %edx
  8007ee:	83 d1 00             	adc    $0x0,%ecx
  8007f1:	f7 d9                	neg    %ecx
  8007f3:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8007f6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007fb:	eb 13                	jmp    800810 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8007fd:	89 ca                	mov    %ecx,%edx
  8007ff:	8d 45 14             	lea    0x14(%ebp),%eax
  800802:	e8 e3 fc ff ff       	call   8004ea <getuint>
  800807:	89 d1                	mov    %edx,%ecx
  800809:	89 c2                	mov    %eax,%edx
			base = 10;
  80080b:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  800810:	83 ec 0c             	sub    $0xc,%esp
  800813:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800817:	57                   	push   %edi
  800818:	ff 75 e0             	pushl  -0x20(%ebp)
  80081b:	50                   	push   %eax
  80081c:	51                   	push   %ecx
  80081d:	52                   	push   %edx
  80081e:	89 f2                	mov    %esi,%edx
  800820:	89 d8                	mov    %ebx,%eax
  800822:	e8 1a fc ff ff       	call   800441 <printnum>
			break;
  800827:	83 c4 20             	add    $0x20,%esp
{
  80082a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80082d:	83 c7 01             	add    $0x1,%edi
  800830:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800834:	83 f8 25             	cmp    $0x25,%eax
  800837:	0f 84 6a fd ff ff    	je     8005a7 <vprintfmt+0x1b>
			if (ch == '\0')
  80083d:	85 c0                	test   %eax,%eax
  80083f:	0f 84 93 00 00 00    	je     8008d8 <vprintfmt+0x34c>
			putch(ch, putdat);
  800845:	83 ec 08             	sub    $0x8,%esp
  800848:	56                   	push   %esi
  800849:	50                   	push   %eax
  80084a:	ff d3                	call   *%ebx
  80084c:	83 c4 10             	add    $0x10,%esp
  80084f:	eb dc                	jmp    80082d <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  800851:	89 ca                	mov    %ecx,%edx
  800853:	8d 45 14             	lea    0x14(%ebp),%eax
  800856:	e8 8f fc ff ff       	call   8004ea <getuint>
  80085b:	89 d1                	mov    %edx,%ecx
  80085d:	89 c2                	mov    %eax,%edx
			base = 8;
  80085f:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800864:	eb aa                	jmp    800810 <vprintfmt+0x284>
			putch('0', putdat);
  800866:	83 ec 08             	sub    $0x8,%esp
  800869:	56                   	push   %esi
  80086a:	6a 30                	push   $0x30
  80086c:	ff d3                	call   *%ebx
			putch('x', putdat);
  80086e:	83 c4 08             	add    $0x8,%esp
  800871:	56                   	push   %esi
  800872:	6a 78                	push   $0x78
  800874:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  800876:	8b 45 14             	mov    0x14(%ebp),%eax
  800879:	8d 50 04             	lea    0x4(%eax),%edx
  80087c:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  80087f:	8b 10                	mov    (%eax),%edx
  800881:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800886:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800889:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80088e:	eb 80                	jmp    800810 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800890:	89 ca                	mov    %ecx,%edx
  800892:	8d 45 14             	lea    0x14(%ebp),%eax
  800895:	e8 50 fc ff ff       	call   8004ea <getuint>
  80089a:	89 d1                	mov    %edx,%ecx
  80089c:	89 c2                	mov    %eax,%edx
			base = 16;
  80089e:	b8 10 00 00 00       	mov    $0x10,%eax
  8008a3:	e9 68 ff ff ff       	jmp    800810 <vprintfmt+0x284>
			putch(ch, putdat);
  8008a8:	83 ec 08             	sub    $0x8,%esp
  8008ab:	56                   	push   %esi
  8008ac:	6a 25                	push   $0x25
  8008ae:	ff d3                	call   *%ebx
			break;
  8008b0:	83 c4 10             	add    $0x10,%esp
  8008b3:	e9 72 ff ff ff       	jmp    80082a <vprintfmt+0x29e>
			putch('%', putdat);
  8008b8:	83 ec 08             	sub    $0x8,%esp
  8008bb:	56                   	push   %esi
  8008bc:	6a 25                	push   $0x25
  8008be:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008c0:	83 c4 10             	add    $0x10,%esp
  8008c3:	89 f8                	mov    %edi,%eax
  8008c5:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8008c9:	74 05                	je     8008d0 <vprintfmt+0x344>
  8008cb:	83 e8 01             	sub    $0x1,%eax
  8008ce:	eb f5                	jmp    8008c5 <vprintfmt+0x339>
  8008d0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8008d3:	e9 52 ff ff ff       	jmp    80082a <vprintfmt+0x29e>
}
  8008d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8008db:	5b                   	pop    %ebx
  8008dc:	5e                   	pop    %esi
  8008dd:	5f                   	pop    %edi
  8008de:	5d                   	pop    %ebp
  8008df:	c3                   	ret    

008008e0 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8008e0:	f3 0f 1e fb          	endbr32 
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	83 ec 18             	sub    $0x18,%esp
  8008ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8008ed:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8008f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8008f3:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8008f7:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008fa:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800901:	85 c0                	test   %eax,%eax
  800903:	74 26                	je     80092b <vsnprintf+0x4b>
  800905:	85 d2                	test   %edx,%edx
  800907:	7e 22                	jle    80092b <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800909:	ff 75 14             	pushl  0x14(%ebp)
  80090c:	ff 75 10             	pushl  0x10(%ebp)
  80090f:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800912:	50                   	push   %eax
  800913:	68 4a 05 80 00       	push   $0x80054a
  800918:	e8 6f fc ff ff       	call   80058c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80091d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800920:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800923:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800926:	83 c4 10             	add    $0x10,%esp
}
  800929:	c9                   	leave  
  80092a:	c3                   	ret    
		return -E_INVAL;
  80092b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800930:	eb f7                	jmp    800929 <vsnprintf+0x49>

00800932 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800932:	f3 0f 1e fb          	endbr32 
  800936:	55                   	push   %ebp
  800937:	89 e5                	mov    %esp,%ebp
  800939:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80093c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80093f:	50                   	push   %eax
  800940:	ff 75 10             	pushl  0x10(%ebp)
  800943:	ff 75 0c             	pushl  0xc(%ebp)
  800946:	ff 75 08             	pushl  0x8(%ebp)
  800949:	e8 92 ff ff ff       	call   8008e0 <vsnprintf>
	va_end(ap);

	return rc;
}
  80094e:	c9                   	leave  
  80094f:	c3                   	ret    

00800950 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800950:	f3 0f 1e fb          	endbr32 
  800954:	55                   	push   %ebp
  800955:	89 e5                	mov    %esp,%ebp
  800957:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80095a:	b8 00 00 00 00       	mov    $0x0,%eax
  80095f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800963:	74 05                	je     80096a <strlen+0x1a>
		n++;
  800965:	83 c0 01             	add    $0x1,%eax
  800968:	eb f5                	jmp    80095f <strlen+0xf>
	return n;
}
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80096c:	f3 0f 1e fb          	endbr32 
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800976:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800979:	b8 00 00 00 00       	mov    $0x0,%eax
  80097e:	39 d0                	cmp    %edx,%eax
  800980:	74 0d                	je     80098f <strnlen+0x23>
  800982:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800986:	74 05                	je     80098d <strnlen+0x21>
		n++;
  800988:	83 c0 01             	add    $0x1,%eax
  80098b:	eb f1                	jmp    80097e <strnlen+0x12>
  80098d:	89 c2                	mov    %eax,%edx
	return n;
}
  80098f:	89 d0                	mov    %edx,%eax
  800991:	5d                   	pop    %ebp
  800992:	c3                   	ret    

00800993 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800993:	f3 0f 1e fb          	endbr32 
  800997:	55                   	push   %ebp
  800998:	89 e5                	mov    %esp,%ebp
  80099a:	53                   	push   %ebx
  80099b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8009a6:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8009aa:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8009ad:	83 c0 01             	add    $0x1,%eax
  8009b0:	84 d2                	test   %dl,%dl
  8009b2:	75 f2                	jne    8009a6 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8009b4:	89 c8                	mov    %ecx,%eax
  8009b6:	5b                   	pop    %ebx
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009b9:	f3 0f 1e fb          	endbr32 
  8009bd:	55                   	push   %ebp
  8009be:	89 e5                	mov    %esp,%ebp
  8009c0:	53                   	push   %ebx
  8009c1:	83 ec 10             	sub    $0x10,%esp
  8009c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009c7:	53                   	push   %ebx
  8009c8:	e8 83 ff ff ff       	call   800950 <strlen>
  8009cd:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8009d0:	ff 75 0c             	pushl  0xc(%ebp)
  8009d3:	01 d8                	add    %ebx,%eax
  8009d5:	50                   	push   %eax
  8009d6:	e8 b8 ff ff ff       	call   800993 <strcpy>
	return dst;
}
  8009db:	89 d8                	mov    %ebx,%eax
  8009dd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e0:	c9                   	leave  
  8009e1:	c3                   	ret    

008009e2 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009e2:	f3 0f 1e fb          	endbr32 
  8009e6:	55                   	push   %ebp
  8009e7:	89 e5                	mov    %esp,%ebp
  8009e9:	56                   	push   %esi
  8009ea:	53                   	push   %ebx
  8009eb:	8b 75 08             	mov    0x8(%ebp),%esi
  8009ee:	8b 55 0c             	mov    0xc(%ebp),%edx
  8009f1:	89 f3                	mov    %esi,%ebx
  8009f3:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009f6:	89 f0                	mov    %esi,%eax
  8009f8:	39 d8                	cmp    %ebx,%eax
  8009fa:	74 11                	je     800a0d <strncpy+0x2b>
		*dst++ = *src;
  8009fc:	83 c0 01             	add    $0x1,%eax
  8009ff:	0f b6 0a             	movzbl (%edx),%ecx
  800a02:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a05:	80 f9 01             	cmp    $0x1,%cl
  800a08:	83 da ff             	sbb    $0xffffffff,%edx
  800a0b:	eb eb                	jmp    8009f8 <strncpy+0x16>
	}
	return ret;
}
  800a0d:	89 f0                	mov    %esi,%eax
  800a0f:	5b                   	pop    %ebx
  800a10:	5e                   	pop    %esi
  800a11:	5d                   	pop    %ebp
  800a12:	c3                   	ret    

00800a13 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a13:	f3 0f 1e fb          	endbr32 
  800a17:	55                   	push   %ebp
  800a18:	89 e5                	mov    %esp,%ebp
  800a1a:	56                   	push   %esi
  800a1b:	53                   	push   %ebx
  800a1c:	8b 75 08             	mov    0x8(%ebp),%esi
  800a1f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a22:	8b 55 10             	mov    0x10(%ebp),%edx
  800a25:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a27:	85 d2                	test   %edx,%edx
  800a29:	74 21                	je     800a4c <strlcpy+0x39>
  800a2b:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a2f:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800a31:	39 c2                	cmp    %eax,%edx
  800a33:	74 14                	je     800a49 <strlcpy+0x36>
  800a35:	0f b6 19             	movzbl (%ecx),%ebx
  800a38:	84 db                	test   %bl,%bl
  800a3a:	74 0b                	je     800a47 <strlcpy+0x34>
			*dst++ = *src++;
  800a3c:	83 c1 01             	add    $0x1,%ecx
  800a3f:	83 c2 01             	add    $0x1,%edx
  800a42:	88 5a ff             	mov    %bl,-0x1(%edx)
  800a45:	eb ea                	jmp    800a31 <strlcpy+0x1e>
  800a47:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800a49:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a4c:	29 f0                	sub    %esi,%eax
}
  800a4e:	5b                   	pop    %ebx
  800a4f:	5e                   	pop    %esi
  800a50:	5d                   	pop    %ebp
  800a51:	c3                   	ret    

00800a52 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a52:	f3 0f 1e fb          	endbr32 
  800a56:	55                   	push   %ebp
  800a57:	89 e5                	mov    %esp,%ebp
  800a59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a5c:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a5f:	0f b6 01             	movzbl (%ecx),%eax
  800a62:	84 c0                	test   %al,%al
  800a64:	74 0c                	je     800a72 <strcmp+0x20>
  800a66:	3a 02                	cmp    (%edx),%al
  800a68:	75 08                	jne    800a72 <strcmp+0x20>
		p++, q++;
  800a6a:	83 c1 01             	add    $0x1,%ecx
  800a6d:	83 c2 01             	add    $0x1,%edx
  800a70:	eb ed                	jmp    800a5f <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a72:	0f b6 c0             	movzbl %al,%eax
  800a75:	0f b6 12             	movzbl (%edx),%edx
  800a78:	29 d0                	sub    %edx,%eax
}
  800a7a:	5d                   	pop    %ebp
  800a7b:	c3                   	ret    

00800a7c <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a7c:	f3 0f 1e fb          	endbr32 
  800a80:	55                   	push   %ebp
  800a81:	89 e5                	mov    %esp,%ebp
  800a83:	53                   	push   %ebx
  800a84:	8b 45 08             	mov    0x8(%ebp),%eax
  800a87:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8a:	89 c3                	mov    %eax,%ebx
  800a8c:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a8f:	eb 06                	jmp    800a97 <strncmp+0x1b>
		n--, p++, q++;
  800a91:	83 c0 01             	add    $0x1,%eax
  800a94:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800a97:	39 d8                	cmp    %ebx,%eax
  800a99:	74 16                	je     800ab1 <strncmp+0x35>
  800a9b:	0f b6 08             	movzbl (%eax),%ecx
  800a9e:	84 c9                	test   %cl,%cl
  800aa0:	74 04                	je     800aa6 <strncmp+0x2a>
  800aa2:	3a 0a                	cmp    (%edx),%cl
  800aa4:	74 eb                	je     800a91 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aa6:	0f b6 00             	movzbl (%eax),%eax
  800aa9:	0f b6 12             	movzbl (%edx),%edx
  800aac:	29 d0                	sub    %edx,%eax
}
  800aae:	5b                   	pop    %ebx
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    
		return 0;
  800ab1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ab6:	eb f6                	jmp    800aae <strncmp+0x32>

00800ab8 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ab8:	f3 0f 1e fb          	endbr32 
  800abc:	55                   	push   %ebp
  800abd:	89 e5                	mov    %esp,%ebp
  800abf:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ac6:	0f b6 10             	movzbl (%eax),%edx
  800ac9:	84 d2                	test   %dl,%dl
  800acb:	74 09                	je     800ad6 <strchr+0x1e>
		if (*s == c)
  800acd:	38 ca                	cmp    %cl,%dl
  800acf:	74 0a                	je     800adb <strchr+0x23>
	for (; *s; s++)
  800ad1:	83 c0 01             	add    $0x1,%eax
  800ad4:	eb f0                	jmp    800ac6 <strchr+0xe>
			return (char *) s;
	return 0;
  800ad6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800adb:	5d                   	pop    %ebp
  800adc:	c3                   	ret    

00800add <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800add:	f3 0f 1e fb          	endbr32 
  800ae1:	55                   	push   %ebp
  800ae2:	89 e5                	mov    %esp,%ebp
  800ae4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aeb:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800aee:	38 ca                	cmp    %cl,%dl
  800af0:	74 09                	je     800afb <strfind+0x1e>
  800af2:	84 d2                	test   %dl,%dl
  800af4:	74 05                	je     800afb <strfind+0x1e>
	for (; *s; s++)
  800af6:	83 c0 01             	add    $0x1,%eax
  800af9:	eb f0                	jmp    800aeb <strfind+0xe>
			break;
	return (char *) s;
}
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800afd:	f3 0f 1e fb          	endbr32 
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	57                   	push   %edi
  800b05:	56                   	push   %esi
  800b06:	53                   	push   %ebx
  800b07:	8b 55 08             	mov    0x8(%ebp),%edx
  800b0a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800b0d:	85 c9                	test   %ecx,%ecx
  800b0f:	74 33                	je     800b44 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b11:	89 d0                	mov    %edx,%eax
  800b13:	09 c8                	or     %ecx,%eax
  800b15:	a8 03                	test   $0x3,%al
  800b17:	75 23                	jne    800b3c <memset+0x3f>
		c &= 0xFF;
  800b19:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b1d:	89 d8                	mov    %ebx,%eax
  800b1f:	c1 e0 08             	shl    $0x8,%eax
  800b22:	89 df                	mov    %ebx,%edi
  800b24:	c1 e7 18             	shl    $0x18,%edi
  800b27:	89 de                	mov    %ebx,%esi
  800b29:	c1 e6 10             	shl    $0x10,%esi
  800b2c:	09 f7                	or     %esi,%edi
  800b2e:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800b30:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b33:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800b35:	89 d7                	mov    %edx,%edi
  800b37:	fc                   	cld    
  800b38:	f3 ab                	rep stos %eax,%es:(%edi)
  800b3a:	eb 08                	jmp    800b44 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b3c:	89 d7                	mov    %edx,%edi
  800b3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b41:	fc                   	cld    
  800b42:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800b44:	89 d0                	mov    %edx,%eax
  800b46:	5b                   	pop    %ebx
  800b47:	5e                   	pop    %esi
  800b48:	5f                   	pop    %edi
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b4b:	f3 0f 1e fb          	endbr32 
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	57                   	push   %edi
  800b53:	56                   	push   %esi
  800b54:	8b 45 08             	mov    0x8(%ebp),%eax
  800b57:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b5a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b5d:	39 c6                	cmp    %eax,%esi
  800b5f:	73 32                	jae    800b93 <memmove+0x48>
  800b61:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b64:	39 c2                	cmp    %eax,%edx
  800b66:	76 2b                	jbe    800b93 <memmove+0x48>
		s += n;
		d += n;
  800b68:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b6b:	89 fe                	mov    %edi,%esi
  800b6d:	09 ce                	or     %ecx,%esi
  800b6f:	09 d6                	or     %edx,%esi
  800b71:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b77:	75 0e                	jne    800b87 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800b79:	83 ef 04             	sub    $0x4,%edi
  800b7c:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b7f:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800b82:	fd                   	std    
  800b83:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b85:	eb 09                	jmp    800b90 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800b87:	83 ef 01             	sub    $0x1,%edi
  800b8a:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800b8d:	fd                   	std    
  800b8e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b90:	fc                   	cld    
  800b91:	eb 1a                	jmp    800bad <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b93:	89 c2                	mov    %eax,%edx
  800b95:	09 ca                	or     %ecx,%edx
  800b97:	09 f2                	or     %esi,%edx
  800b99:	f6 c2 03             	test   $0x3,%dl
  800b9c:	75 0a                	jne    800ba8 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800b9e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800ba1:	89 c7                	mov    %eax,%edi
  800ba3:	fc                   	cld    
  800ba4:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba6:	eb 05                	jmp    800bad <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800ba8:	89 c7                	mov    %eax,%edi
  800baa:	fc                   	cld    
  800bab:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800bad:	5e                   	pop    %esi
  800bae:	5f                   	pop    %edi
  800baf:	5d                   	pop    %ebp
  800bb0:	c3                   	ret    

00800bb1 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bb1:	f3 0f 1e fb          	endbr32 
  800bb5:	55                   	push   %ebp
  800bb6:	89 e5                	mov    %esp,%ebp
  800bb8:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800bbb:	ff 75 10             	pushl  0x10(%ebp)
  800bbe:	ff 75 0c             	pushl  0xc(%ebp)
  800bc1:	ff 75 08             	pushl  0x8(%ebp)
  800bc4:	e8 82 ff ff ff       	call   800b4b <memmove>
}
  800bc9:	c9                   	leave  
  800bca:	c3                   	ret    

00800bcb <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bcb:	f3 0f 1e fb          	endbr32 
  800bcf:	55                   	push   %ebp
  800bd0:	89 e5                	mov    %esp,%ebp
  800bd2:	56                   	push   %esi
  800bd3:	53                   	push   %ebx
  800bd4:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd7:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bda:	89 c6                	mov    %eax,%esi
  800bdc:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bdf:	39 f0                	cmp    %esi,%eax
  800be1:	74 1c                	je     800bff <memcmp+0x34>
		if (*s1 != *s2)
  800be3:	0f b6 08             	movzbl (%eax),%ecx
  800be6:	0f b6 1a             	movzbl (%edx),%ebx
  800be9:	38 d9                	cmp    %bl,%cl
  800beb:	75 08                	jne    800bf5 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800bed:	83 c0 01             	add    $0x1,%eax
  800bf0:	83 c2 01             	add    $0x1,%edx
  800bf3:	eb ea                	jmp    800bdf <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800bf5:	0f b6 c1             	movzbl %cl,%eax
  800bf8:	0f b6 db             	movzbl %bl,%ebx
  800bfb:	29 d8                	sub    %ebx,%eax
  800bfd:	eb 05                	jmp    800c04 <memcmp+0x39>
	}

	return 0;
  800bff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800c04:	5b                   	pop    %ebx
  800c05:	5e                   	pop    %esi
  800c06:	5d                   	pop    %ebp
  800c07:	c3                   	ret    

00800c08 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800c08:	f3 0f 1e fb          	endbr32 
  800c0c:	55                   	push   %ebp
  800c0d:	89 e5                	mov    %esp,%ebp
  800c0f:	8b 45 08             	mov    0x8(%ebp),%eax
  800c12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800c15:	89 c2                	mov    %eax,%edx
  800c17:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800c1a:	39 d0                	cmp    %edx,%eax
  800c1c:	73 09                	jae    800c27 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c1e:	38 08                	cmp    %cl,(%eax)
  800c20:	74 05                	je     800c27 <memfind+0x1f>
	for (; s < ends; s++)
  800c22:	83 c0 01             	add    $0x1,%eax
  800c25:	eb f3                	jmp    800c1a <memfind+0x12>
			break;
	return (void *) s;
}
  800c27:	5d                   	pop    %ebp
  800c28:	c3                   	ret    

00800c29 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c29:	f3 0f 1e fb          	endbr32 
  800c2d:	55                   	push   %ebp
  800c2e:	89 e5                	mov    %esp,%ebp
  800c30:	57                   	push   %edi
  800c31:	56                   	push   %esi
  800c32:	53                   	push   %ebx
  800c33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c36:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c39:	eb 03                	jmp    800c3e <strtol+0x15>
		s++;
  800c3b:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800c3e:	0f b6 01             	movzbl (%ecx),%eax
  800c41:	3c 20                	cmp    $0x20,%al
  800c43:	74 f6                	je     800c3b <strtol+0x12>
  800c45:	3c 09                	cmp    $0x9,%al
  800c47:	74 f2                	je     800c3b <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800c49:	3c 2b                	cmp    $0x2b,%al
  800c4b:	74 2a                	je     800c77 <strtol+0x4e>
	int neg = 0;
  800c4d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800c52:	3c 2d                	cmp    $0x2d,%al
  800c54:	74 2b                	je     800c81 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c56:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c5c:	75 0f                	jne    800c6d <strtol+0x44>
  800c5e:	80 39 30             	cmpb   $0x30,(%ecx)
  800c61:	74 28                	je     800c8b <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c63:	85 db                	test   %ebx,%ebx
  800c65:	b8 0a 00 00 00       	mov    $0xa,%eax
  800c6a:	0f 44 d8             	cmove  %eax,%ebx
  800c6d:	b8 00 00 00 00       	mov    $0x0,%eax
  800c72:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800c75:	eb 46                	jmp    800cbd <strtol+0x94>
		s++;
  800c77:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800c7a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c7f:	eb d5                	jmp    800c56 <strtol+0x2d>
		s++, neg = 1;
  800c81:	83 c1 01             	add    $0x1,%ecx
  800c84:	bf 01 00 00 00       	mov    $0x1,%edi
  800c89:	eb cb                	jmp    800c56 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c8b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c8f:	74 0e                	je     800c9f <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800c91:	85 db                	test   %ebx,%ebx
  800c93:	75 d8                	jne    800c6d <strtol+0x44>
		s++, base = 8;
  800c95:	83 c1 01             	add    $0x1,%ecx
  800c98:	bb 08 00 00 00       	mov    $0x8,%ebx
  800c9d:	eb ce                	jmp    800c6d <strtol+0x44>
		s += 2, base = 16;
  800c9f:	83 c1 02             	add    $0x2,%ecx
  800ca2:	bb 10 00 00 00       	mov    $0x10,%ebx
  800ca7:	eb c4                	jmp    800c6d <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800ca9:	0f be d2             	movsbl %dl,%edx
  800cac:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800caf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cb2:	7d 3a                	jge    800cee <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800cb4:	83 c1 01             	add    $0x1,%ecx
  800cb7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cbb:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800cbd:	0f b6 11             	movzbl (%ecx),%edx
  800cc0:	8d 72 d0             	lea    -0x30(%edx),%esi
  800cc3:	89 f3                	mov    %esi,%ebx
  800cc5:	80 fb 09             	cmp    $0x9,%bl
  800cc8:	76 df                	jbe    800ca9 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800cca:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ccd:	89 f3                	mov    %esi,%ebx
  800ccf:	80 fb 19             	cmp    $0x19,%bl
  800cd2:	77 08                	ja     800cdc <strtol+0xb3>
			dig = *s - 'a' + 10;
  800cd4:	0f be d2             	movsbl %dl,%edx
  800cd7:	83 ea 57             	sub    $0x57,%edx
  800cda:	eb d3                	jmp    800caf <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800cdc:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cdf:	89 f3                	mov    %esi,%ebx
  800ce1:	80 fb 19             	cmp    $0x19,%bl
  800ce4:	77 08                	ja     800cee <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ce6:	0f be d2             	movsbl %dl,%edx
  800ce9:	83 ea 37             	sub    $0x37,%edx
  800cec:	eb c1                	jmp    800caf <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800cee:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cf2:	74 05                	je     800cf9 <strtol+0xd0>
		*endptr = (char *) s;
  800cf4:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cf7:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800cf9:	89 c2                	mov    %eax,%edx
  800cfb:	f7 da                	neg    %edx
  800cfd:	85 ff                	test   %edi,%edi
  800cff:	0f 45 c2             	cmovne %edx,%eax
}
  800d02:	5b                   	pop    %ebx
  800d03:	5e                   	pop    %esi
  800d04:	5f                   	pop    %edi
  800d05:	5d                   	pop    %ebp
  800d06:	c3                   	ret    

00800d07 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	57                   	push   %edi
  800d0b:	56                   	push   %esi
  800d0c:	53                   	push   %ebx
  800d0d:	83 ec 1c             	sub    $0x1c,%esp
  800d10:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d13:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800d16:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800d18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d1b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800d1e:	8b 7d 10             	mov    0x10(%ebp),%edi
  800d21:	8b 75 14             	mov    0x14(%ebp),%esi
  800d24:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800d26:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800d2a:	74 04                	je     800d30 <syscall+0x29>
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	7f 08                	jg     800d38 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800d30:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d33:	5b                   	pop    %ebx
  800d34:	5e                   	pop    %esi
  800d35:	5f                   	pop    %edi
  800d36:	5d                   	pop    %ebp
  800d37:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800d38:	83 ec 0c             	sub    $0xc,%esp
  800d3b:	50                   	push   %eax
  800d3c:	ff 75 e0             	pushl  -0x20(%ebp)
  800d3f:	68 ff 2a 80 00       	push   $0x802aff
  800d44:	6a 23                	push   $0x23
  800d46:	68 1c 2b 80 00       	push   $0x802b1c
  800d4b:	e8 f2 f5 ff ff       	call   800342 <_panic>

00800d50 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800d50:	f3 0f 1e fb          	endbr32 
  800d54:	55                   	push   %ebp
  800d55:	89 e5                	mov    %esp,%ebp
  800d57:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800d5a:	6a 00                	push   $0x0
  800d5c:	6a 00                	push   $0x0
  800d5e:	6a 00                	push   $0x0
  800d60:	ff 75 0c             	pushl  0xc(%ebp)
  800d63:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d66:	ba 00 00 00 00       	mov    $0x0,%edx
  800d6b:	b8 00 00 00 00       	mov    $0x0,%eax
  800d70:	e8 92 ff ff ff       	call   800d07 <syscall>
}
  800d75:	83 c4 10             	add    $0x10,%esp
  800d78:	c9                   	leave  
  800d79:	c3                   	ret    

00800d7a <sys_cgetc>:

int
sys_cgetc(void)
{
  800d7a:	f3 0f 1e fb          	endbr32 
  800d7e:	55                   	push   %ebp
  800d7f:	89 e5                	mov    %esp,%ebp
  800d81:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800d84:	6a 00                	push   $0x0
  800d86:	6a 00                	push   $0x0
  800d88:	6a 00                	push   $0x0
  800d8a:	6a 00                	push   $0x0
  800d8c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800d91:	ba 00 00 00 00       	mov    $0x0,%edx
  800d96:	b8 01 00 00 00       	mov    $0x1,%eax
  800d9b:	e8 67 ff ff ff       	call   800d07 <syscall>
}
  800da0:	c9                   	leave  
  800da1:	c3                   	ret    

00800da2 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800da2:	f3 0f 1e fb          	endbr32 
  800da6:	55                   	push   %ebp
  800da7:	89 e5                	mov    %esp,%ebp
  800da9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800dac:	6a 00                	push   $0x0
  800dae:	6a 00                	push   $0x0
  800db0:	6a 00                	push   $0x0
  800db2:	6a 00                	push   $0x0
  800db4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db7:	ba 01 00 00 00       	mov    $0x1,%edx
  800dbc:	b8 03 00 00 00       	mov    $0x3,%eax
  800dc1:	e8 41 ff ff ff       	call   800d07 <syscall>
}
  800dc6:	c9                   	leave  
  800dc7:	c3                   	ret    

00800dc8 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800dc8:	f3 0f 1e fb          	endbr32 
  800dcc:	55                   	push   %ebp
  800dcd:	89 e5                	mov    %esp,%ebp
  800dcf:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800dd2:	6a 00                	push   $0x0
  800dd4:	6a 00                	push   $0x0
  800dd6:	6a 00                	push   $0x0
  800dd8:	6a 00                	push   $0x0
  800dda:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ddf:	ba 00 00 00 00       	mov    $0x0,%edx
  800de4:	b8 02 00 00 00       	mov    $0x2,%eax
  800de9:	e8 19 ff ff ff       	call   800d07 <syscall>
}
  800dee:	c9                   	leave  
  800def:	c3                   	ret    

00800df0 <sys_yield>:

void
sys_yield(void)
{
  800df0:	f3 0f 1e fb          	endbr32 
  800df4:	55                   	push   %ebp
  800df5:	89 e5                	mov    %esp,%ebp
  800df7:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800dfa:	6a 00                	push   $0x0
  800dfc:	6a 00                	push   $0x0
  800dfe:	6a 00                	push   $0x0
  800e00:	6a 00                	push   $0x0
  800e02:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e07:	ba 00 00 00 00       	mov    $0x0,%edx
  800e0c:	b8 0b 00 00 00       	mov    $0xb,%eax
  800e11:	e8 f1 fe ff ff       	call   800d07 <syscall>
}
  800e16:	83 c4 10             	add    $0x10,%esp
  800e19:	c9                   	leave  
  800e1a:	c3                   	ret    

00800e1b <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800e1b:	f3 0f 1e fb          	endbr32 
  800e1f:	55                   	push   %ebp
  800e20:	89 e5                	mov    %esp,%ebp
  800e22:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800e25:	6a 00                	push   $0x0
  800e27:	6a 00                	push   $0x0
  800e29:	ff 75 10             	pushl  0x10(%ebp)
  800e2c:	ff 75 0c             	pushl  0xc(%ebp)
  800e2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e32:	ba 01 00 00 00       	mov    $0x1,%edx
  800e37:	b8 04 00 00 00       	mov    $0x4,%eax
  800e3c:	e8 c6 fe ff ff       	call   800d07 <syscall>
}
  800e41:	c9                   	leave  
  800e42:	c3                   	ret    

00800e43 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800e43:	f3 0f 1e fb          	endbr32 
  800e47:	55                   	push   %ebp
  800e48:	89 e5                	mov    %esp,%ebp
  800e4a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800e4d:	ff 75 18             	pushl  0x18(%ebp)
  800e50:	ff 75 14             	pushl  0x14(%ebp)
  800e53:	ff 75 10             	pushl  0x10(%ebp)
  800e56:	ff 75 0c             	pushl  0xc(%ebp)
  800e59:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5c:	ba 01 00 00 00       	mov    $0x1,%edx
  800e61:	b8 05 00 00 00       	mov    $0x5,%eax
  800e66:	e8 9c fe ff ff       	call   800d07 <syscall>
}
  800e6b:	c9                   	leave  
  800e6c:	c3                   	ret    

00800e6d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800e6d:	f3 0f 1e fb          	endbr32 
  800e71:	55                   	push   %ebp
  800e72:	89 e5                	mov    %esp,%ebp
  800e74:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800e77:	6a 00                	push   $0x0
  800e79:	6a 00                	push   $0x0
  800e7b:	6a 00                	push   $0x0
  800e7d:	ff 75 0c             	pushl  0xc(%ebp)
  800e80:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e83:	ba 01 00 00 00       	mov    $0x1,%edx
  800e88:	b8 06 00 00 00       	mov    $0x6,%eax
  800e8d:	e8 75 fe ff ff       	call   800d07 <syscall>
}
  800e92:	c9                   	leave  
  800e93:	c3                   	ret    

00800e94 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800e94:	f3 0f 1e fb          	endbr32 
  800e98:	55                   	push   %ebp
  800e99:	89 e5                	mov    %esp,%ebp
  800e9b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800e9e:	6a 00                	push   $0x0
  800ea0:	6a 00                	push   $0x0
  800ea2:	6a 00                	push   $0x0
  800ea4:	ff 75 0c             	pushl  0xc(%ebp)
  800ea7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800eaa:	ba 01 00 00 00       	mov    $0x1,%edx
  800eaf:	b8 08 00 00 00       	mov    $0x8,%eax
  800eb4:	e8 4e fe ff ff       	call   800d07 <syscall>
}
  800eb9:	c9                   	leave  
  800eba:	c3                   	ret    

00800ebb <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800ebb:	f3 0f 1e fb          	endbr32 
  800ebf:	55                   	push   %ebp
  800ec0:	89 e5                	mov    %esp,%ebp
  800ec2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800ec5:	6a 00                	push   $0x0
  800ec7:	6a 00                	push   $0x0
  800ec9:	6a 00                	push   $0x0
  800ecb:	ff 75 0c             	pushl  0xc(%ebp)
  800ece:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ed1:	ba 01 00 00 00       	mov    $0x1,%edx
  800ed6:	b8 09 00 00 00       	mov    $0x9,%eax
  800edb:	e8 27 fe ff ff       	call   800d07 <syscall>
}
  800ee0:	c9                   	leave  
  800ee1:	c3                   	ret    

00800ee2 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800ee2:	f3 0f 1e fb          	endbr32 
  800ee6:	55                   	push   %ebp
  800ee7:	89 e5                	mov    %esp,%ebp
  800ee9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800eec:	6a 00                	push   $0x0
  800eee:	6a 00                	push   $0x0
  800ef0:	6a 00                	push   $0x0
  800ef2:	ff 75 0c             	pushl  0xc(%ebp)
  800ef5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef8:	ba 01 00 00 00       	mov    $0x1,%edx
  800efd:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f02:	e8 00 fe ff ff       	call   800d07 <syscall>
}
  800f07:	c9                   	leave  
  800f08:	c3                   	ret    

00800f09 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800f09:	f3 0f 1e fb          	endbr32 
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800f13:	6a 00                	push   $0x0
  800f15:	ff 75 14             	pushl  0x14(%ebp)
  800f18:	ff 75 10             	pushl  0x10(%ebp)
  800f1b:	ff 75 0c             	pushl  0xc(%ebp)
  800f1e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f21:	ba 00 00 00 00       	mov    $0x0,%edx
  800f26:	b8 0c 00 00 00       	mov    $0xc,%eax
  800f2b:	e8 d7 fd ff ff       	call   800d07 <syscall>
}
  800f30:	c9                   	leave  
  800f31:	c3                   	ret    

00800f32 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800f32:	f3 0f 1e fb          	endbr32 
  800f36:	55                   	push   %ebp
  800f37:	89 e5                	mov    %esp,%ebp
  800f39:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800f3c:	6a 00                	push   $0x0
  800f3e:	6a 00                	push   $0x0
  800f40:	6a 00                	push   $0x0
  800f42:	6a 00                	push   $0x0
  800f44:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f47:	ba 01 00 00 00       	mov    $0x1,%edx
  800f4c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800f51:	e8 b1 fd ff ff       	call   800d07 <syscall>
}
  800f56:	c9                   	leave  
  800f57:	c3                   	ret    

00800f58 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  800f58:	55                   	push   %ebp
  800f59:	89 e5                	mov    %esp,%ebp
  800f5b:	53                   	push   %ebx
  800f5c:	83 ec 04             	sub    $0x4,%esp
  800f5f:	89 d3                	mov    %edx,%ebx
	int r;

	// LAB 4: Your code here.

	// Page Table Entry
	pte_t pt_e = uvpt[pn];
  800f61:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Obtenemos la virtual address
	void *v_add = (void *) (pn << PTXSHIFT);
  800f68:	c1 e3 0c             	shl    $0xc,%ebx

	if (pt_e & PTE_SHARE) {
  800f6b:	f6 c6 04             	test   $0x4,%dh
  800f6e:	75 54                	jne    800fc4 <duppage+0x6c>
		// Permisos compartidos
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
		if (r < 0)
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	} else if ((pt_e & PTE_W) || (pt_e & PTE_COW)) {
  800f70:	f7 c2 02 08 00 00    	test   $0x802,%edx
  800f76:	0f 84 8d 00 00 00    	je     801009 <duppage+0xb1>
		// Copy on write
		r = sys_page_map(0, v_add, envid, v_add, PTE_COW | PTE_U | PTE_P);
  800f7c:	83 ec 0c             	sub    $0xc,%esp
  800f7f:	68 05 08 00 00       	push   $0x805
  800f84:	53                   	push   %ebx
  800f85:	50                   	push   %eax
  800f86:	53                   	push   %ebx
  800f87:	6a 00                	push   $0x0
  800f89:	e8 b5 fe ff ff       	call   800e43 <sys_page_map>
		if (r < 0)
  800f8e:	83 c4 20             	add    $0x20,%esp
  800f91:	85 c0                	test   %eax,%eax
  800f93:	78 5f                	js     800ff4 <duppage+0x9c>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);

		r = sys_page_map(0, v_add, 0, v_add, PTE_COW | PTE_U | PTE_P);
  800f95:	83 ec 0c             	sub    $0xc,%esp
  800f98:	68 05 08 00 00       	push   $0x805
  800f9d:	53                   	push   %ebx
  800f9e:	6a 00                	push   $0x0
  800fa0:	53                   	push   %ebx
  800fa1:	6a 00                	push   $0x0
  800fa3:	e8 9b fe ff ff       	call   800e43 <sys_page_map>
		if (r < 0)
  800fa8:	83 c4 20             	add    $0x20,%esp
  800fab:	85 c0                	test   %eax,%eax
  800fad:	79 70                	jns    80101f <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800faf:	50                   	push   %eax
  800fb0:	68 2c 2b 80 00       	push   $0x802b2c
  800fb5:	68 9b 00 00 00       	push   $0x9b
  800fba:	68 9a 2c 80 00       	push   $0x802c9a
  800fbf:	e8 7e f3 ff ff       	call   800342 <_panic>
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
  800fc4:	83 ec 0c             	sub    $0xc,%esp
  800fc7:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  800fcd:	52                   	push   %edx
  800fce:	53                   	push   %ebx
  800fcf:	50                   	push   %eax
  800fd0:	53                   	push   %ebx
  800fd1:	6a 00                	push   $0x0
  800fd3:	e8 6b fe ff ff       	call   800e43 <sys_page_map>
		if (r < 0)
  800fd8:	83 c4 20             	add    $0x20,%esp
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	79 40                	jns    80101f <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800fdf:	50                   	push   %eax
  800fe0:	68 2c 2b 80 00       	push   $0x802b2c
  800fe5:	68 92 00 00 00       	push   $0x92
  800fea:	68 9a 2c 80 00       	push   $0x802c9a
  800fef:	e8 4e f3 ff ff       	call   800342 <_panic>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  800ff4:	50                   	push   %eax
  800ff5:	68 2c 2b 80 00       	push   $0x802b2c
  800ffa:	68 97 00 00 00       	push   $0x97
  800fff:	68 9a 2c 80 00       	push   $0x802c9a
  801004:	e8 39 f3 ff ff       	call   800342 <_panic>
	} else {
		// En caso de lectura, compartir.
		r = sys_page_map(0, v_add, envid, v_add, PTE_U | PTE_P);
  801009:	83 ec 0c             	sub    $0xc,%esp
  80100c:	6a 05                	push   $0x5
  80100e:	53                   	push   %ebx
  80100f:	50                   	push   %eax
  801010:	53                   	push   %ebx
  801011:	6a 00                	push   $0x0
  801013:	e8 2b fe ff ff       	call   800e43 <sys_page_map>
		if (r < 0)
  801018:	83 c4 20             	add    $0x20,%esp
  80101b:	85 c0                	test   %eax,%eax
  80101d:	78 0a                	js     801029 <duppage+0xd1>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	}
	return 0;
}
  80101f:	b8 00 00 00 00       	mov    $0x0,%eax
  801024:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801027:	c9                   	leave  
  801028:	c3                   	ret    
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  801029:	50                   	push   %eax
  80102a:	68 2c 2b 80 00       	push   $0x802b2c
  80102f:	68 a0 00 00 00       	push   $0xa0
  801034:	68 9a 2c 80 00       	push   $0x802c9a
  801039:	e8 04 f3 ff ff       	call   800342 <_panic>

0080103e <dup_or_share>:
{
  80103e:	55                   	push   %ebp
  80103f:	89 e5                	mov    %esp,%ebp
  801041:	57                   	push   %edi
  801042:	56                   	push   %esi
  801043:	53                   	push   %ebx
  801044:	83 ec 0c             	sub    $0xc,%esp
  801047:	89 c7                	mov    %eax,%edi
  801049:	89 d6                	mov    %edx,%esi
  80104b:	89 cb                	mov    %ecx,%ebx
	if (perm & PTE_W) {
  80104d:	f6 c1 02             	test   $0x2,%cl
  801050:	0f 84 90 00 00 00    	je     8010e6 <dup_or_share+0xa8>
		if ((r = sys_page_alloc(dstenv, va, perm)) < 0)
  801056:	83 ec 04             	sub    $0x4,%esp
  801059:	51                   	push   %ecx
  80105a:	52                   	push   %edx
  80105b:	50                   	push   %eax
  80105c:	e8 ba fd ff ff       	call   800e1b <sys_page_alloc>
  801061:	83 c4 10             	add    $0x10,%esp
  801064:	85 c0                	test   %eax,%eax
  801066:	78 56                	js     8010be <dup_or_share+0x80>
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, perm)) < 0)
  801068:	83 ec 0c             	sub    $0xc,%esp
  80106b:	53                   	push   %ebx
  80106c:	68 00 00 40 00       	push   $0x400000
  801071:	6a 00                	push   $0x0
  801073:	56                   	push   %esi
  801074:	57                   	push   %edi
  801075:	e8 c9 fd ff ff       	call   800e43 <sys_page_map>
  80107a:	83 c4 20             	add    $0x20,%esp
  80107d:	85 c0                	test   %eax,%eax
  80107f:	78 51                	js     8010d2 <dup_or_share+0x94>
		memmove(UTEMP, va, PGSIZE);
  801081:	83 ec 04             	sub    $0x4,%esp
  801084:	68 00 10 00 00       	push   $0x1000
  801089:	56                   	push   %esi
  80108a:	68 00 00 40 00       	push   $0x400000
  80108f:	e8 b7 fa ff ff       	call   800b4b <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801094:	83 c4 08             	add    $0x8,%esp
  801097:	68 00 00 40 00       	push   $0x400000
  80109c:	6a 00                	push   $0x0
  80109e:	e8 ca fd ff ff       	call   800e6d <sys_page_unmap>
  8010a3:	83 c4 10             	add    $0x10,%esp
  8010a6:	85 c0                	test   %eax,%eax
  8010a8:	79 51                	jns    8010fb <dup_or_share+0xbd>
			panic("sys_page_unmap failed at dup_or_share");
  8010aa:	83 ec 04             	sub    $0x4,%esp
  8010ad:	68 9c 2b 80 00       	push   $0x802b9c
  8010b2:	6a 18                	push   $0x18
  8010b4:	68 9a 2c 80 00       	push   $0x802c9a
  8010b9:	e8 84 f2 ff ff       	call   800342 <_panic>
			panic("sys_page_alloc failed at dup_or_share");
  8010be:	83 ec 04             	sub    $0x4,%esp
  8010c1:	68 50 2b 80 00       	push   $0x802b50
  8010c6:	6a 13                	push   $0x13
  8010c8:	68 9a 2c 80 00       	push   $0x802c9a
  8010cd:	e8 70 f2 ff ff       	call   800342 <_panic>
			panic("sys_page_map failed at dup_or_share");
  8010d2:	83 ec 04             	sub    $0x4,%esp
  8010d5:	68 78 2b 80 00       	push   $0x802b78
  8010da:	6a 15                	push   $0x15
  8010dc:	68 9a 2c 80 00       	push   $0x802c9a
  8010e1:	e8 5c f2 ff ff       	call   800342 <_panic>
		if ((r = sys_page_map(0, va, dstenv, va, perm)) < 0)
  8010e6:	83 ec 0c             	sub    $0xc,%esp
  8010e9:	51                   	push   %ecx
  8010ea:	52                   	push   %edx
  8010eb:	50                   	push   %eax
  8010ec:	52                   	push   %edx
  8010ed:	6a 00                	push   $0x0
  8010ef:	e8 4f fd ff ff       	call   800e43 <sys_page_map>
  8010f4:	83 c4 20             	add    $0x20,%esp
  8010f7:	85 c0                	test   %eax,%eax
  8010f9:	78 08                	js     801103 <dup_or_share+0xc5>
}
  8010fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010fe:	5b                   	pop    %ebx
  8010ff:	5e                   	pop    %esi
  801100:	5f                   	pop    %edi
  801101:	5d                   	pop    %ebp
  801102:	c3                   	ret    
			panic("sys_page_map failed at dup_or_share");
  801103:	83 ec 04             	sub    $0x4,%esp
  801106:	68 78 2b 80 00       	push   $0x802b78
  80110b:	6a 1c                	push   $0x1c
  80110d:	68 9a 2c 80 00       	push   $0x802c9a
  801112:	e8 2b f2 ff ff       	call   800342 <_panic>

00801117 <pgfault>:
{
  801117:	f3 0f 1e fb          	endbr32 
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	53                   	push   %ebx
  80111f:	83 ec 04             	sub    $0x4,%esp
  801122:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801125:	8b 18                	mov    (%eax),%ebx
	pte_t pt_e = uvpt[PGNUM(addr)];
  801127:	89 da                	mov    %ebx,%edx
  801129:	c1 ea 0c             	shr    $0xc,%edx
  80112c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if ((err & FEC_WR) == 0)
  801133:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801137:	74 6e                	je     8011a7 <pgfault+0x90>
	if ((pt_e & PTE_COW) == 0)
  801139:	f6 c6 08             	test   $0x8,%dh
  80113c:	74 7d                	je     8011bb <pgfault+0xa4>
	if ((r = sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  80113e:	83 ec 04             	sub    $0x4,%esp
  801141:	6a 07                	push   $0x7
  801143:	68 00 f0 7f 00       	push   $0x7ff000
  801148:	6a 00                	push   $0x0
  80114a:	e8 cc fc ff ff       	call   800e1b <sys_page_alloc>
  80114f:	83 c4 10             	add    $0x10,%esp
  801152:	85 c0                	test   %eax,%eax
  801154:	78 79                	js     8011cf <pgfault+0xb8>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  801156:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  80115c:	83 ec 04             	sub    $0x4,%esp
  80115f:	68 00 10 00 00       	push   $0x1000
  801164:	53                   	push   %ebx
  801165:	68 00 f0 7f 00       	push   $0x7ff000
  80116a:	e8 dc f9 ff ff       	call   800b4b <memmove>
	if ((r = sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U)) <
  80116f:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801176:	53                   	push   %ebx
  801177:	6a 00                	push   $0x0
  801179:	68 00 f0 7f 00       	push   $0x7ff000
  80117e:	6a 00                	push   $0x0
  801180:	e8 be fc ff ff       	call   800e43 <sys_page_map>
  801185:	83 c4 20             	add    $0x20,%esp
  801188:	85 c0                	test   %eax,%eax
  80118a:	78 57                	js     8011e3 <pgfault+0xcc>
	if ((r = sys_page_unmap(0, (void *) PFTEMP)) < 0)
  80118c:	83 ec 08             	sub    $0x8,%esp
  80118f:	68 00 f0 7f 00       	push   $0x7ff000
  801194:	6a 00                	push   $0x0
  801196:	e8 d2 fc ff ff       	call   800e6d <sys_page_unmap>
  80119b:	83 c4 10             	add    $0x10,%esp
  80119e:	85 c0                	test   %eax,%eax
  8011a0:	78 55                	js     8011f7 <pgfault+0xe0>
}
  8011a2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8011a5:	c9                   	leave  
  8011a6:	c3                   	ret    
		panic("ERROR EN PGFAULT: WRITE");
  8011a7:	83 ec 04             	sub    $0x4,%esp
  8011aa:	68 a5 2c 80 00       	push   $0x802ca5
  8011af:	6a 5e                	push   $0x5e
  8011b1:	68 9a 2c 80 00       	push   $0x802c9a
  8011b6:	e8 87 f1 ff ff       	call   800342 <_panic>
		panic("ERROR EN PGFAULT: COPY-ON-WRITE");
  8011bb:	83 ec 04             	sub    $0x4,%esp
  8011be:	68 c4 2b 80 00       	push   $0x802bc4
  8011c3:	6a 62                	push   $0x62
  8011c5:	68 9a 2c 80 00       	push   $0x802c9a
  8011ca:	e8 73 f1 ff ff       	call   800342 <_panic>
		panic("pgfault failed");
  8011cf:	83 ec 04             	sub    $0x4,%esp
  8011d2:	68 bd 2c 80 00       	push   $0x802cbd
  8011d7:	6a 6d                	push   $0x6d
  8011d9:	68 9a 2c 80 00       	push   $0x802c9a
  8011de:	e8 5f f1 ff ff       	call   800342 <_panic>
		panic("pgfault failed");
  8011e3:	83 ec 04             	sub    $0x4,%esp
  8011e6:	68 bd 2c 80 00       	push   $0x802cbd
  8011eb:	6a 72                	push   $0x72
  8011ed:	68 9a 2c 80 00       	push   $0x802c9a
  8011f2:	e8 4b f1 ff ff       	call   800342 <_panic>
		panic("pgfault failed");
  8011f7:	83 ec 04             	sub    $0x4,%esp
  8011fa:	68 bd 2c 80 00       	push   $0x802cbd
  8011ff:	6a 74                	push   $0x74
  801201:	68 9a 2c 80 00       	push   $0x802c9a
  801206:	e8 37 f1 ff ff       	call   800342 <_panic>

0080120b <fork_v0>:
{
  80120b:	f3 0f 1e fb          	endbr32 
  80120f:	55                   	push   %ebp
  801210:	89 e5                	mov    %esp,%ebp
  801212:	57                   	push   %edi
  801213:	56                   	push   %esi
  801214:	53                   	push   %ebx
  801215:	83 ec 1c             	sub    $0x1c,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801218:	b8 07 00 00 00       	mov    $0x7,%eax
  80121d:	cd 30                	int    $0x30
  80121f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801222:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (envid < 0)
  801225:	85 c0                	test   %eax,%eax
  801227:	78 1d                	js     801246 <fork_v0+0x3b>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  801229:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  80122e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801232:	74 26                	je     80125a <fork_v0+0x4f>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  801234:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  801239:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
			        (pte_t *) (PGADDR(PDX(uvpt),
  80123f:	bf 00 00 40 ef       	mov    $0xef400000,%edi
  801244:	eb 4b                	jmp    801291 <fork_v0+0x86>
		panic("sys_exofork failed");
  801246:	83 ec 04             	sub    $0x4,%esp
  801249:	68 cc 2c 80 00       	push   $0x802ccc
  80124e:	6a 2b                	push   $0x2b
  801250:	68 9a 2c 80 00       	push   $0x802c9a
  801255:	e8 e8 f0 ff ff       	call   800342 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
  80125a:	e8 69 fb ff ff       	call   800dc8 <sys_getenvid>
  80125f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801264:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801267:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80126c:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  801271:	eb 68                	jmp    8012db <fork_v0+0xd0>
				dup_or_share(envid,
  801273:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  801279:	89 da                	mov    %ebx,%edx
  80127b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80127e:	e8 bb fd ff ff       	call   80103e <dup_or_share>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  801283:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801289:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  80128f:	74 36                	je     8012c7 <fork_v0+0xbc>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  801291:	89 d8                	mov    %ebx,%eax
  801293:	c1 e8 16             	shr    $0x16,%eax
  801296:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80129d:	09 f2                	or     %esi,%edx
		if ((*pgdirentry) & PTE_P) {
  80129f:	f6 02 01             	testb  $0x1,(%edx)
  8012a2:	74 df                	je     801283 <fork_v0+0x78>
			        (pte_t *) (PGADDR(PDX(uvpt),
  8012a4:	89 da                	mov    %ebx,%edx
  8012a6:	c1 ea 0a             	shr    $0xa,%edx
  8012a9:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  8012af:	c1 e0 0c             	shl    $0xc,%eax
  8012b2:	89 f9                	mov    %edi,%ecx
  8012b4:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
  8012ba:	09 c8                	or     %ecx,%eax
  8012bc:	09 d0                	or     %edx,%eax
			if ((*pgtablentry) & PTE_P)
  8012be:	8b 08                	mov    (%eax),%ecx
  8012c0:	f6 c1 01             	test   $0x1,%cl
  8012c3:	74 be                	je     801283 <fork_v0+0x78>
  8012c5:	eb ac                	jmp    801273 <fork_v0+0x68>
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8012c7:	83 ec 08             	sub    $0x8,%esp
  8012ca:	6a 02                	push   $0x2
  8012cc:	ff 75 e0             	pushl  -0x20(%ebp)
  8012cf:	e8 c0 fb ff ff       	call   800e94 <sys_env_set_status>
  8012d4:	83 c4 10             	add    $0x10,%esp
  8012d7:	85 c0                	test   %eax,%eax
  8012d9:	78 0b                	js     8012e6 <fork_v0+0xdb>
}
  8012db:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012e1:	5b                   	pop    %ebx
  8012e2:	5e                   	pop    %esi
  8012e3:	5f                   	pop    %edi
  8012e4:	5d                   	pop    %ebp
  8012e5:	c3                   	ret    
		panic("sys_env_set_status failed at fork_v0");
  8012e6:	83 ec 04             	sub    $0x4,%esp
  8012e9:	68 e4 2b 80 00       	push   $0x802be4
  8012ee:	6a 43                	push   $0x43
  8012f0:	68 9a 2c 80 00       	push   $0x802c9a
  8012f5:	e8 48 f0 ff ff       	call   800342 <_panic>

008012fa <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  8012fa:	f3 0f 1e fb          	endbr32 
  8012fe:	55                   	push   %ebp
  8012ff:	89 e5                	mov    %esp,%ebp
  801301:	57                   	push   %edi
  801302:	56                   	push   %esi
  801303:	53                   	push   %ebx
  801304:	83 ec 28             	sub    $0x28,%esp
	int err;

	// handle padre
	set_pgfault_handler(pgfault);
  801307:	68 17 11 80 00       	push   $0x801117
  80130c:	e8 26 0f 00 00       	call   802237 <set_pgfault_handler>
  801311:	b8 07 00 00 00       	mov    $0x7,%eax
  801316:	cd 30                	int    $0x30
  801318:	89 45 e0             	mov    %eax,-0x20(%ebp)

	// Proceso hijo
	envid_t e_id = sys_exofork();

	if (e_id < 0)
  80131b:	83 c4 10             	add    $0x10,%esp
  80131e:	85 c0                	test   %eax,%eax
  801320:	78 2f                	js     801351 <fork+0x57>
  801322:	89 c7                	mov    %eax,%edi
  801324:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		panic("ERROR EN FORK: sys_exofork: %e", e_id);

	if (e_id == 0) {
  80132b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80132f:	0f 85 9e 00 00 00    	jne    8013d3 <fork+0xd9>
		// Si es hijo
		thisenv = &envs[ENVX(sys_getenvid())];
  801335:	e8 8e fa ff ff       	call   800dc8 <sys_getenvid>
  80133a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80133f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801342:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801347:	a3 04 40 80 00       	mov    %eax,0x804004
		return 0;
  80134c:	e9 de 00 00 00       	jmp    80142f <fork+0x135>
		panic("ERROR EN FORK: sys_exofork: %e", e_id);
  801351:	50                   	push   %eax
  801352:	68 0c 2c 80 00       	push   $0x802c0c
  801357:	68 c2 00 00 00       	push   $0xc2
  80135c:	68 9a 2c 80 00       	push   $0x802c9a
  801361:	e8 dc ef ff ff       	call   800342 <_panic>
		// LOOP PTEs
		while (pt_x < NPTENTRIES) {
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
			pte_t pt_e = uvpt[PGNUM(dir)];
			if (dir == (UXSTACKTOP - PGSIZE)) {
				err = sys_page_alloc(e_id,
  801366:	83 ec 04             	sub    $0x4,%esp
  801369:	6a 07                	push   $0x7
  80136b:	68 00 f0 bf ee       	push   $0xeebff000
  801370:	57                   	push   %edi
  801371:	e8 a5 fa ff ff       	call   800e1b <sys_page_alloc>
				                     (void *) dir,
				                     PTE_W | PTE_U | PTE_P);
				if (err)
  801376:	83 c4 10             	add    $0x10,%esp
  801379:	85 c0                	test   %eax,%eax
  80137b:	75 33                	jne    8013b0 <fork+0xb6>
  80137d:	83 c3 01             	add    $0x1,%ebx
		while (pt_x < NPTENTRIES) {
  801380:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801386:	74 3d                	je     8013c5 <fork+0xcb>
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
  801388:	89 d8                	mov    %ebx,%eax
  80138a:	c1 e0 0c             	shl    $0xc,%eax
  80138d:	09 f0                	or     %esi,%eax
			pte_t pt_e = uvpt[PGNUM(dir)];
  80138f:	89 c2                	mov    %eax,%edx
  801391:	c1 ea 0c             	shr    $0xc,%edx
  801394:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
			if (dir == (UXSTACKTOP - PGSIZE)) {
  80139b:	3d 00 f0 bf ee       	cmp    $0xeebff000,%eax
  8013a0:	74 c4                	je     801366 <fork+0x6c>
					      "%e",
					      err);
				pt_x++;
				continue;
			}
			if ((pt_e & PTE_P) == 0) {
  8013a2:	f6 c1 01             	test   $0x1,%cl
  8013a5:	74 d6                	je     80137d <fork+0x83>
				pt_x++;
				continue;
			}
			duppage(e_id, PGNUM(dir));
  8013a7:	89 f8                	mov    %edi,%eax
  8013a9:	e8 aa fb ff ff       	call   800f58 <duppage>
  8013ae:	eb cd                	jmp    80137d <fork+0x83>
					panic("ERROR EN FORK: sys_page_alloc: "
  8013b0:	50                   	push   %eax
  8013b1:	68 2c 2c 80 00       	push   $0x802c2c
  8013b6:	68 e1 00 00 00       	push   $0xe1
  8013bb:	68 9a 2c 80 00       	push   $0x802c9a
  8013c0:	e8 7d ef ff ff       	call   800342 <_panic>
  8013c5:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  8013c9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
	while (pd_x < PDX(UTOP)) {
  8013cc:	3d bb 03 00 00       	cmp    $0x3bb,%eax
  8013d1:	74 18                	je     8013eb <fork+0xf1>
		pde_t pd_e = uvpd[pd_x];
  8013d3:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8013d6:	8b 04 b5 00 d0 7b ef 	mov    -0x10843000(,%esi,4),%eax
		if ((pd_e & PTE_P) == 0) {
  8013dd:	a8 01                	test   $0x1,%al
  8013df:	74 e4                	je     8013c5 <fork+0xcb>
  8013e1:	c1 e6 16             	shl    $0x16,%esi
  8013e4:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013e9:	eb 9d                	jmp    801388 <fork+0x8e>
			pt_x++;
		}
		pd_x++;
	}

	if ((err = sys_page_alloc(e_id,
  8013eb:	83 ec 04             	sub    $0x4,%esp
  8013ee:	6a 07                	push   $0x7
  8013f0:	68 00 f0 bf ee       	push   $0xeebff000
  8013f5:	ff 75 e0             	pushl  -0x20(%ebp)
  8013f8:	e8 1e fa ff ff       	call   800e1b <sys_page_alloc>
  8013fd:	83 c4 10             	add    $0x10,%esp
  801400:	85 c0                	test   %eax,%eax
  801402:	78 36                	js     80143a <fork+0x140>
	                          (void *) (UXSTACKTOP - PGSIZE),
	                          PTE_P | PTE_U | PTE_W) < 0))
		panic("Error en sys_page_alloc");


	if ((sys_env_set_pgfault_upcall(e_id, _pgfault_upcall) < 0))
  801404:	83 ec 08             	sub    $0x8,%esp
  801407:	68 92 22 80 00       	push   $0x802292
  80140c:	ff 75 e0             	pushl  -0x20(%ebp)
  80140f:	e8 ce fa ff ff       	call   800ee2 <sys_env_set_pgfault_upcall>
  801414:	83 c4 10             	add    $0x10,%esp
  801417:	85 c0                	test   %eax,%eax
  801419:	78 36                	js     801451 <fork+0x157>
		panic("sys_env_set_pgfault_upcall failed");

	// HIJO RUNNABLE
	if ((err = sys_env_set_status(e_id, ENV_RUNNABLE)) < 0)
  80141b:	83 ec 08             	sub    $0x8,%esp
  80141e:	6a 02                	push   $0x2
  801420:	ff 75 e0             	pushl  -0x20(%ebp)
  801423:	e8 6c fa ff ff       	call   800e94 <sys_env_set_status>
  801428:	83 c4 10             	add    $0x10,%esp
  80142b:	85 c0                	test   %eax,%eax
  80142d:	78 39                	js     801468 <fork+0x16e>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);

	return e_id;
}
  80142f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801432:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801435:	5b                   	pop    %ebx
  801436:	5e                   	pop    %esi
  801437:	5f                   	pop    %edi
  801438:	5d                   	pop    %ebp
  801439:	c3                   	ret    
		panic("Error en sys_page_alloc");
  80143a:	83 ec 04             	sub    $0x4,%esp
  80143d:	68 df 2c 80 00       	push   $0x802cdf
  801442:	68 f4 00 00 00       	push   $0xf4
  801447:	68 9a 2c 80 00       	push   $0x802c9a
  80144c:	e8 f1 ee ff ff       	call   800342 <_panic>
		panic("sys_env_set_pgfault_upcall failed");
  801451:	83 ec 04             	sub    $0x4,%esp
  801454:	68 50 2c 80 00       	push   $0x802c50
  801459:	68 f8 00 00 00       	push   $0xf8
  80145e:	68 9a 2c 80 00       	push   $0x802c9a
  801463:	e8 da ee ff ff       	call   800342 <_panic>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);
  801468:	50                   	push   %eax
  801469:	68 74 2c 80 00       	push   $0x802c74
  80146e:	68 fc 00 00 00       	push   $0xfc
  801473:	68 9a 2c 80 00       	push   $0x802c9a
  801478:	e8 c5 ee ff ff       	call   800342 <_panic>

0080147d <sfork>:

// Challenge!
int
sfork(void)
{
  80147d:	f3 0f 1e fb          	endbr32 
  801481:	55                   	push   %ebp
  801482:	89 e5                	mov    %esp,%ebp
  801484:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801487:	68 f7 2c 80 00       	push   $0x802cf7
  80148c:	68 05 01 00 00       	push   $0x105
  801491:	68 9a 2c 80 00       	push   $0x802c9a
  801496:	e8 a7 ee ff ff       	call   800342 <_panic>

0080149b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80149b:	f3 0f 1e fb          	endbr32 
  80149f:	55                   	push   %ebp
  8014a0:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8014a2:	8b 45 08             	mov    0x8(%ebp),%eax
  8014a5:	05 00 00 00 30       	add    $0x30000000,%eax
  8014aa:	c1 e8 0c             	shr    $0xc,%eax
}
  8014ad:	5d                   	pop    %ebp
  8014ae:	c3                   	ret    

008014af <fd2data>:

char*
fd2data(struct Fd *fd)
{
  8014af:	f3 0f 1e fb          	endbr32 
  8014b3:	55                   	push   %ebp
  8014b4:	89 e5                	mov    %esp,%ebp
  8014b6:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  8014b9:	ff 75 08             	pushl  0x8(%ebp)
  8014bc:	e8 da ff ff ff       	call   80149b <fd2num>
  8014c1:	83 c4 10             	add    $0x10,%esp
  8014c4:	c1 e0 0c             	shl    $0xc,%eax
  8014c7:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8014cc:	c9                   	leave  
  8014cd:	c3                   	ret    

008014ce <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8014ce:	f3 0f 1e fb          	endbr32 
  8014d2:	55                   	push   %ebp
  8014d3:	89 e5                	mov    %esp,%ebp
  8014d5:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8014da:	89 c2                	mov    %eax,%edx
  8014dc:	c1 ea 16             	shr    $0x16,%edx
  8014df:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8014e6:	f6 c2 01             	test   $0x1,%dl
  8014e9:	74 2d                	je     801518 <fd_alloc+0x4a>
  8014eb:	89 c2                	mov    %eax,%edx
  8014ed:	c1 ea 0c             	shr    $0xc,%edx
  8014f0:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014f7:	f6 c2 01             	test   $0x1,%dl
  8014fa:	74 1c                	je     801518 <fd_alloc+0x4a>
  8014fc:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801501:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801506:	75 d2                	jne    8014da <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801508:	8b 45 08             	mov    0x8(%ebp),%eax
  80150b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801511:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801516:	eb 0a                	jmp    801522 <fd_alloc+0x54>
			*fd_store = fd;
  801518:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80151b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80151d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801522:	5d                   	pop    %ebp
  801523:	c3                   	ret    

00801524 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801524:	f3 0f 1e fb          	endbr32 
  801528:	55                   	push   %ebp
  801529:	89 e5                	mov    %esp,%ebp
  80152b:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80152e:	83 f8 1f             	cmp    $0x1f,%eax
  801531:	77 30                	ja     801563 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801533:	c1 e0 0c             	shl    $0xc,%eax
  801536:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80153b:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801541:	f6 c2 01             	test   $0x1,%dl
  801544:	74 24                	je     80156a <fd_lookup+0x46>
  801546:	89 c2                	mov    %eax,%edx
  801548:	c1 ea 0c             	shr    $0xc,%edx
  80154b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801552:	f6 c2 01             	test   $0x1,%dl
  801555:	74 1a                	je     801571 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801557:	8b 55 0c             	mov    0xc(%ebp),%edx
  80155a:	89 02                	mov    %eax,(%edx)
	return 0;
  80155c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801561:	5d                   	pop    %ebp
  801562:	c3                   	ret    
		return -E_INVAL;
  801563:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801568:	eb f7                	jmp    801561 <fd_lookup+0x3d>
		return -E_INVAL;
  80156a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80156f:	eb f0                	jmp    801561 <fd_lookup+0x3d>
  801571:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801576:	eb e9                	jmp    801561 <fd_lookup+0x3d>

00801578 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801578:	f3 0f 1e fb          	endbr32 
  80157c:	55                   	push   %ebp
  80157d:	89 e5                	mov    %esp,%ebp
  80157f:	83 ec 08             	sub    $0x8,%esp
  801582:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801585:	ba 8c 2d 80 00       	mov    $0x802d8c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80158a:	b8 08 30 80 00       	mov    $0x803008,%eax
		if (devtab[i]->dev_id == dev_id) {
  80158f:	39 08                	cmp    %ecx,(%eax)
  801591:	74 33                	je     8015c6 <dev_lookup+0x4e>
  801593:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801596:	8b 02                	mov    (%edx),%eax
  801598:	85 c0                	test   %eax,%eax
  80159a:	75 f3                	jne    80158f <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80159c:	a1 04 40 80 00       	mov    0x804004,%eax
  8015a1:	8b 40 48             	mov    0x48(%eax),%eax
  8015a4:	83 ec 04             	sub    $0x4,%esp
  8015a7:	51                   	push   %ecx
  8015a8:	50                   	push   %eax
  8015a9:	68 10 2d 80 00       	push   $0x802d10
  8015ae:	e8 76 ee ff ff       	call   800429 <cprintf>
	*dev = 0;
  8015b3:	8b 45 0c             	mov    0xc(%ebp),%eax
  8015b6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  8015bc:	83 c4 10             	add    $0x10,%esp
  8015bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8015c4:	c9                   	leave  
  8015c5:	c3                   	ret    
			*dev = devtab[i];
  8015c6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8015c9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8015cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8015d0:	eb f2                	jmp    8015c4 <dev_lookup+0x4c>

008015d2 <fd_close>:
{
  8015d2:	f3 0f 1e fb          	endbr32 
  8015d6:	55                   	push   %ebp
  8015d7:	89 e5                	mov    %esp,%ebp
  8015d9:	57                   	push   %edi
  8015da:	56                   	push   %esi
  8015db:	53                   	push   %ebx
  8015dc:	83 ec 28             	sub    $0x28,%esp
  8015df:	8b 75 08             	mov    0x8(%ebp),%esi
  8015e2:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8015e5:	56                   	push   %esi
  8015e6:	e8 b0 fe ff ff       	call   80149b <fd2num>
  8015eb:	83 c4 08             	add    $0x8,%esp
  8015ee:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8015f1:	52                   	push   %edx
  8015f2:	50                   	push   %eax
  8015f3:	e8 2c ff ff ff       	call   801524 <fd_lookup>
  8015f8:	89 c3                	mov    %eax,%ebx
  8015fa:	83 c4 10             	add    $0x10,%esp
  8015fd:	85 c0                	test   %eax,%eax
  8015ff:	78 05                	js     801606 <fd_close+0x34>
	    || fd != fd2)
  801601:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801604:	74 16                	je     80161c <fd_close+0x4a>
		return (must_exist ? r : 0);
  801606:	89 f8                	mov    %edi,%eax
  801608:	84 c0                	test   %al,%al
  80160a:	b8 00 00 00 00       	mov    $0x0,%eax
  80160f:	0f 44 d8             	cmove  %eax,%ebx
}
  801612:	89 d8                	mov    %ebx,%eax
  801614:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801617:	5b                   	pop    %ebx
  801618:	5e                   	pop    %esi
  801619:	5f                   	pop    %edi
  80161a:	5d                   	pop    %ebp
  80161b:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80161c:	83 ec 08             	sub    $0x8,%esp
  80161f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801622:	50                   	push   %eax
  801623:	ff 36                	pushl  (%esi)
  801625:	e8 4e ff ff ff       	call   801578 <dev_lookup>
  80162a:	89 c3                	mov    %eax,%ebx
  80162c:	83 c4 10             	add    $0x10,%esp
  80162f:	85 c0                	test   %eax,%eax
  801631:	78 1a                	js     80164d <fd_close+0x7b>
		if (dev->dev_close)
  801633:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801636:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801639:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80163e:	85 c0                	test   %eax,%eax
  801640:	74 0b                	je     80164d <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801642:	83 ec 0c             	sub    $0xc,%esp
  801645:	56                   	push   %esi
  801646:	ff d0                	call   *%eax
  801648:	89 c3                	mov    %eax,%ebx
  80164a:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80164d:	83 ec 08             	sub    $0x8,%esp
  801650:	56                   	push   %esi
  801651:	6a 00                	push   $0x0
  801653:	e8 15 f8 ff ff       	call   800e6d <sys_page_unmap>
	return r;
  801658:	83 c4 10             	add    $0x10,%esp
  80165b:	eb b5                	jmp    801612 <fd_close+0x40>

0080165d <close>:

int
close(int fdnum)
{
  80165d:	f3 0f 1e fb          	endbr32 
  801661:	55                   	push   %ebp
  801662:	89 e5                	mov    %esp,%ebp
  801664:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801667:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80166a:	50                   	push   %eax
  80166b:	ff 75 08             	pushl  0x8(%ebp)
  80166e:	e8 b1 fe ff ff       	call   801524 <fd_lookup>
  801673:	83 c4 10             	add    $0x10,%esp
  801676:	85 c0                	test   %eax,%eax
  801678:	79 02                	jns    80167c <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  80167a:	c9                   	leave  
  80167b:	c3                   	ret    
		return fd_close(fd, 1);
  80167c:	83 ec 08             	sub    $0x8,%esp
  80167f:	6a 01                	push   $0x1
  801681:	ff 75 f4             	pushl  -0xc(%ebp)
  801684:	e8 49 ff ff ff       	call   8015d2 <fd_close>
  801689:	83 c4 10             	add    $0x10,%esp
  80168c:	eb ec                	jmp    80167a <close+0x1d>

0080168e <close_all>:

void
close_all(void)
{
  80168e:	f3 0f 1e fb          	endbr32 
  801692:	55                   	push   %ebp
  801693:	89 e5                	mov    %esp,%ebp
  801695:	53                   	push   %ebx
  801696:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801699:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80169e:	83 ec 0c             	sub    $0xc,%esp
  8016a1:	53                   	push   %ebx
  8016a2:	e8 b6 ff ff ff       	call   80165d <close>
	for (i = 0; i < MAXFD; i++)
  8016a7:	83 c3 01             	add    $0x1,%ebx
  8016aa:	83 c4 10             	add    $0x10,%esp
  8016ad:	83 fb 20             	cmp    $0x20,%ebx
  8016b0:	75 ec                	jne    80169e <close_all+0x10>
}
  8016b2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016b5:	c9                   	leave  
  8016b6:	c3                   	ret    

008016b7 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  8016b7:	f3 0f 1e fb          	endbr32 
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	57                   	push   %edi
  8016bf:	56                   	push   %esi
  8016c0:	53                   	push   %ebx
  8016c1:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8016c4:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8016c7:	50                   	push   %eax
  8016c8:	ff 75 08             	pushl  0x8(%ebp)
  8016cb:	e8 54 fe ff ff       	call   801524 <fd_lookup>
  8016d0:	89 c3                	mov    %eax,%ebx
  8016d2:	83 c4 10             	add    $0x10,%esp
  8016d5:	85 c0                	test   %eax,%eax
  8016d7:	0f 88 81 00 00 00    	js     80175e <dup+0xa7>
		return r;
	close(newfdnum);
  8016dd:	83 ec 0c             	sub    $0xc,%esp
  8016e0:	ff 75 0c             	pushl  0xc(%ebp)
  8016e3:	e8 75 ff ff ff       	call   80165d <close>

	newfd = INDEX2FD(newfdnum);
  8016e8:	8b 75 0c             	mov    0xc(%ebp),%esi
  8016eb:	c1 e6 0c             	shl    $0xc,%esi
  8016ee:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8016f4:	83 c4 04             	add    $0x4,%esp
  8016f7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8016fa:	e8 b0 fd ff ff       	call   8014af <fd2data>
  8016ff:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801701:	89 34 24             	mov    %esi,(%esp)
  801704:	e8 a6 fd ff ff       	call   8014af <fd2data>
  801709:	83 c4 10             	add    $0x10,%esp
  80170c:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80170e:	89 d8                	mov    %ebx,%eax
  801710:	c1 e8 16             	shr    $0x16,%eax
  801713:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80171a:	a8 01                	test   $0x1,%al
  80171c:	74 11                	je     80172f <dup+0x78>
  80171e:	89 d8                	mov    %ebx,%eax
  801720:	c1 e8 0c             	shr    $0xc,%eax
  801723:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80172a:	f6 c2 01             	test   $0x1,%dl
  80172d:	75 39                	jne    801768 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80172f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801732:	89 d0                	mov    %edx,%eax
  801734:	c1 e8 0c             	shr    $0xc,%eax
  801737:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80173e:	83 ec 0c             	sub    $0xc,%esp
  801741:	25 07 0e 00 00       	and    $0xe07,%eax
  801746:	50                   	push   %eax
  801747:	56                   	push   %esi
  801748:	6a 00                	push   $0x0
  80174a:	52                   	push   %edx
  80174b:	6a 00                	push   $0x0
  80174d:	e8 f1 f6 ff ff       	call   800e43 <sys_page_map>
  801752:	89 c3                	mov    %eax,%ebx
  801754:	83 c4 20             	add    $0x20,%esp
  801757:	85 c0                	test   %eax,%eax
  801759:	78 31                	js     80178c <dup+0xd5>
		goto err;

	return newfdnum;
  80175b:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80175e:	89 d8                	mov    %ebx,%eax
  801760:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801763:	5b                   	pop    %ebx
  801764:	5e                   	pop    %esi
  801765:	5f                   	pop    %edi
  801766:	5d                   	pop    %ebp
  801767:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801768:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80176f:	83 ec 0c             	sub    $0xc,%esp
  801772:	25 07 0e 00 00       	and    $0xe07,%eax
  801777:	50                   	push   %eax
  801778:	57                   	push   %edi
  801779:	6a 00                	push   $0x0
  80177b:	53                   	push   %ebx
  80177c:	6a 00                	push   $0x0
  80177e:	e8 c0 f6 ff ff       	call   800e43 <sys_page_map>
  801783:	89 c3                	mov    %eax,%ebx
  801785:	83 c4 20             	add    $0x20,%esp
  801788:	85 c0                	test   %eax,%eax
  80178a:	79 a3                	jns    80172f <dup+0x78>
	sys_page_unmap(0, newfd);
  80178c:	83 ec 08             	sub    $0x8,%esp
  80178f:	56                   	push   %esi
  801790:	6a 00                	push   $0x0
  801792:	e8 d6 f6 ff ff       	call   800e6d <sys_page_unmap>
	sys_page_unmap(0, nva);
  801797:	83 c4 08             	add    $0x8,%esp
  80179a:	57                   	push   %edi
  80179b:	6a 00                	push   $0x0
  80179d:	e8 cb f6 ff ff       	call   800e6d <sys_page_unmap>
	return r;
  8017a2:	83 c4 10             	add    $0x10,%esp
  8017a5:	eb b7                	jmp    80175e <dup+0xa7>

008017a7 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  8017a7:	f3 0f 1e fb          	endbr32 
  8017ab:	55                   	push   %ebp
  8017ac:	89 e5                	mov    %esp,%ebp
  8017ae:	53                   	push   %ebx
  8017af:	83 ec 1c             	sub    $0x1c,%esp
  8017b2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8017b5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8017b8:	50                   	push   %eax
  8017b9:	53                   	push   %ebx
  8017ba:	e8 65 fd ff ff       	call   801524 <fd_lookup>
  8017bf:	83 c4 10             	add    $0x10,%esp
  8017c2:	85 c0                	test   %eax,%eax
  8017c4:	78 3f                	js     801805 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8017c6:	83 ec 08             	sub    $0x8,%esp
  8017c9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017cc:	50                   	push   %eax
  8017cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8017d0:	ff 30                	pushl  (%eax)
  8017d2:	e8 a1 fd ff ff       	call   801578 <dev_lookup>
  8017d7:	83 c4 10             	add    $0x10,%esp
  8017da:	85 c0                	test   %eax,%eax
  8017dc:	78 27                	js     801805 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8017de:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8017e1:	8b 42 08             	mov    0x8(%edx),%eax
  8017e4:	83 e0 03             	and    $0x3,%eax
  8017e7:	83 f8 01             	cmp    $0x1,%eax
  8017ea:	74 1e                	je     80180a <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8017ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8017ef:	8b 40 08             	mov    0x8(%eax),%eax
  8017f2:	85 c0                	test   %eax,%eax
  8017f4:	74 35                	je     80182b <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8017f6:	83 ec 04             	sub    $0x4,%esp
  8017f9:	ff 75 10             	pushl  0x10(%ebp)
  8017fc:	ff 75 0c             	pushl  0xc(%ebp)
  8017ff:	52                   	push   %edx
  801800:	ff d0                	call   *%eax
  801802:	83 c4 10             	add    $0x10,%esp
}
  801805:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801808:	c9                   	leave  
  801809:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80180a:	a1 04 40 80 00       	mov    0x804004,%eax
  80180f:	8b 40 48             	mov    0x48(%eax),%eax
  801812:	83 ec 04             	sub    $0x4,%esp
  801815:	53                   	push   %ebx
  801816:	50                   	push   %eax
  801817:	68 51 2d 80 00       	push   $0x802d51
  80181c:	e8 08 ec ff ff       	call   800429 <cprintf>
		return -E_INVAL;
  801821:	83 c4 10             	add    $0x10,%esp
  801824:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801829:	eb da                	jmp    801805 <read+0x5e>
		return -E_NOT_SUPP;
  80182b:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801830:	eb d3                	jmp    801805 <read+0x5e>

00801832 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801832:	f3 0f 1e fb          	endbr32 
  801836:	55                   	push   %ebp
  801837:	89 e5                	mov    %esp,%ebp
  801839:	57                   	push   %edi
  80183a:	56                   	push   %esi
  80183b:	53                   	push   %ebx
  80183c:	83 ec 0c             	sub    $0xc,%esp
  80183f:	8b 7d 08             	mov    0x8(%ebp),%edi
  801842:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801845:	bb 00 00 00 00       	mov    $0x0,%ebx
  80184a:	eb 02                	jmp    80184e <readn+0x1c>
  80184c:	01 c3                	add    %eax,%ebx
  80184e:	39 f3                	cmp    %esi,%ebx
  801850:	73 21                	jae    801873 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801852:	83 ec 04             	sub    $0x4,%esp
  801855:	89 f0                	mov    %esi,%eax
  801857:	29 d8                	sub    %ebx,%eax
  801859:	50                   	push   %eax
  80185a:	89 d8                	mov    %ebx,%eax
  80185c:	03 45 0c             	add    0xc(%ebp),%eax
  80185f:	50                   	push   %eax
  801860:	57                   	push   %edi
  801861:	e8 41 ff ff ff       	call   8017a7 <read>
		if (m < 0)
  801866:	83 c4 10             	add    $0x10,%esp
  801869:	85 c0                	test   %eax,%eax
  80186b:	78 04                	js     801871 <readn+0x3f>
			return m;
		if (m == 0)
  80186d:	75 dd                	jne    80184c <readn+0x1a>
  80186f:	eb 02                	jmp    801873 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801871:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801873:	89 d8                	mov    %ebx,%eax
  801875:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801878:	5b                   	pop    %ebx
  801879:	5e                   	pop    %esi
  80187a:	5f                   	pop    %edi
  80187b:	5d                   	pop    %ebp
  80187c:	c3                   	ret    

0080187d <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80187d:	f3 0f 1e fb          	endbr32 
  801881:	55                   	push   %ebp
  801882:	89 e5                	mov    %esp,%ebp
  801884:	53                   	push   %ebx
  801885:	83 ec 1c             	sub    $0x1c,%esp
  801888:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80188b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80188e:	50                   	push   %eax
  80188f:	53                   	push   %ebx
  801890:	e8 8f fc ff ff       	call   801524 <fd_lookup>
  801895:	83 c4 10             	add    $0x10,%esp
  801898:	85 c0                	test   %eax,%eax
  80189a:	78 3a                	js     8018d6 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80189c:	83 ec 08             	sub    $0x8,%esp
  80189f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018a2:	50                   	push   %eax
  8018a3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018a6:	ff 30                	pushl  (%eax)
  8018a8:	e8 cb fc ff ff       	call   801578 <dev_lookup>
  8018ad:	83 c4 10             	add    $0x10,%esp
  8018b0:	85 c0                	test   %eax,%eax
  8018b2:	78 22                	js     8018d6 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018b4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018b7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018bb:	74 1e                	je     8018db <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  8018bd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018c0:	8b 52 0c             	mov    0xc(%edx),%edx
  8018c3:	85 d2                	test   %edx,%edx
  8018c5:	74 35                	je     8018fc <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  8018c7:	83 ec 04             	sub    $0x4,%esp
  8018ca:	ff 75 10             	pushl  0x10(%ebp)
  8018cd:	ff 75 0c             	pushl  0xc(%ebp)
  8018d0:	50                   	push   %eax
  8018d1:	ff d2                	call   *%edx
  8018d3:	83 c4 10             	add    $0x10,%esp
}
  8018d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8018d9:	c9                   	leave  
  8018da:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  8018db:	a1 04 40 80 00       	mov    0x804004,%eax
  8018e0:	8b 40 48             	mov    0x48(%eax),%eax
  8018e3:	83 ec 04             	sub    $0x4,%esp
  8018e6:	53                   	push   %ebx
  8018e7:	50                   	push   %eax
  8018e8:	68 6d 2d 80 00       	push   $0x802d6d
  8018ed:	e8 37 eb ff ff       	call   800429 <cprintf>
		return -E_INVAL;
  8018f2:	83 c4 10             	add    $0x10,%esp
  8018f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8018fa:	eb da                	jmp    8018d6 <write+0x59>
		return -E_NOT_SUPP;
  8018fc:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801901:	eb d3                	jmp    8018d6 <write+0x59>

00801903 <seek>:

int
seek(int fdnum, off_t offset)
{
  801903:	f3 0f 1e fb          	endbr32 
  801907:	55                   	push   %ebp
  801908:	89 e5                	mov    %esp,%ebp
  80190a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80190d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801910:	50                   	push   %eax
  801911:	ff 75 08             	pushl  0x8(%ebp)
  801914:	e8 0b fc ff ff       	call   801524 <fd_lookup>
  801919:	83 c4 10             	add    $0x10,%esp
  80191c:	85 c0                	test   %eax,%eax
  80191e:	78 0e                	js     80192e <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801920:	8b 55 0c             	mov    0xc(%ebp),%edx
  801923:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801926:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801929:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80192e:	c9                   	leave  
  80192f:	c3                   	ret    

00801930 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801930:	f3 0f 1e fb          	endbr32 
  801934:	55                   	push   %ebp
  801935:	89 e5                	mov    %esp,%ebp
  801937:	53                   	push   %ebx
  801938:	83 ec 1c             	sub    $0x1c,%esp
  80193b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80193e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801941:	50                   	push   %eax
  801942:	53                   	push   %ebx
  801943:	e8 dc fb ff ff       	call   801524 <fd_lookup>
  801948:	83 c4 10             	add    $0x10,%esp
  80194b:	85 c0                	test   %eax,%eax
  80194d:	78 37                	js     801986 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80194f:	83 ec 08             	sub    $0x8,%esp
  801952:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801955:	50                   	push   %eax
  801956:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801959:	ff 30                	pushl  (%eax)
  80195b:	e8 18 fc ff ff       	call   801578 <dev_lookup>
  801960:	83 c4 10             	add    $0x10,%esp
  801963:	85 c0                	test   %eax,%eax
  801965:	78 1f                	js     801986 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801967:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80196a:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80196e:	74 1b                	je     80198b <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801970:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801973:	8b 52 18             	mov    0x18(%edx),%edx
  801976:	85 d2                	test   %edx,%edx
  801978:	74 32                	je     8019ac <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80197a:	83 ec 08             	sub    $0x8,%esp
  80197d:	ff 75 0c             	pushl  0xc(%ebp)
  801980:	50                   	push   %eax
  801981:	ff d2                	call   *%edx
  801983:	83 c4 10             	add    $0x10,%esp
}
  801986:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801989:	c9                   	leave  
  80198a:	c3                   	ret    
			thisenv->env_id, fdnum);
  80198b:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801990:	8b 40 48             	mov    0x48(%eax),%eax
  801993:	83 ec 04             	sub    $0x4,%esp
  801996:	53                   	push   %ebx
  801997:	50                   	push   %eax
  801998:	68 30 2d 80 00       	push   $0x802d30
  80199d:	e8 87 ea ff ff       	call   800429 <cprintf>
		return -E_INVAL;
  8019a2:	83 c4 10             	add    $0x10,%esp
  8019a5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8019aa:	eb da                	jmp    801986 <ftruncate+0x56>
		return -E_NOT_SUPP;
  8019ac:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019b1:	eb d3                	jmp    801986 <ftruncate+0x56>

008019b3 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  8019b3:	f3 0f 1e fb          	endbr32 
  8019b7:	55                   	push   %ebp
  8019b8:	89 e5                	mov    %esp,%ebp
  8019ba:	53                   	push   %ebx
  8019bb:	83 ec 1c             	sub    $0x1c,%esp
  8019be:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8019c1:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8019c4:	50                   	push   %eax
  8019c5:	ff 75 08             	pushl  0x8(%ebp)
  8019c8:	e8 57 fb ff ff       	call   801524 <fd_lookup>
  8019cd:	83 c4 10             	add    $0x10,%esp
  8019d0:	85 c0                	test   %eax,%eax
  8019d2:	78 4b                	js     801a1f <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019d4:	83 ec 08             	sub    $0x8,%esp
  8019d7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019da:	50                   	push   %eax
  8019db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019de:	ff 30                	pushl  (%eax)
  8019e0:	e8 93 fb ff ff       	call   801578 <dev_lookup>
  8019e5:	83 c4 10             	add    $0x10,%esp
  8019e8:	85 c0                	test   %eax,%eax
  8019ea:	78 33                	js     801a1f <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  8019ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019ef:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8019f3:	74 2f                	je     801a24 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8019f5:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8019f8:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8019ff:	00 00 00 
	stat->st_isdir = 0;
  801a02:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801a09:	00 00 00 
	stat->st_dev = dev;
  801a0c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801a12:	83 ec 08             	sub    $0x8,%esp
  801a15:	53                   	push   %ebx
  801a16:	ff 75 f0             	pushl  -0x10(%ebp)
  801a19:	ff 50 14             	call   *0x14(%eax)
  801a1c:	83 c4 10             	add    $0x10,%esp
}
  801a1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801a22:	c9                   	leave  
  801a23:	c3                   	ret    
		return -E_NOT_SUPP;
  801a24:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a29:	eb f4                	jmp    801a1f <fstat+0x6c>

00801a2b <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801a2b:	f3 0f 1e fb          	endbr32 
  801a2f:	55                   	push   %ebp
  801a30:	89 e5                	mov    %esp,%ebp
  801a32:	56                   	push   %esi
  801a33:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801a34:	83 ec 08             	sub    $0x8,%esp
  801a37:	6a 00                	push   $0x0
  801a39:	ff 75 08             	pushl  0x8(%ebp)
  801a3c:	e8 fb 01 00 00       	call   801c3c <open>
  801a41:	89 c3                	mov    %eax,%ebx
  801a43:	83 c4 10             	add    $0x10,%esp
  801a46:	85 c0                	test   %eax,%eax
  801a48:	78 1b                	js     801a65 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801a4a:	83 ec 08             	sub    $0x8,%esp
  801a4d:	ff 75 0c             	pushl  0xc(%ebp)
  801a50:	50                   	push   %eax
  801a51:	e8 5d ff ff ff       	call   8019b3 <fstat>
  801a56:	89 c6                	mov    %eax,%esi
	close(fd);
  801a58:	89 1c 24             	mov    %ebx,(%esp)
  801a5b:	e8 fd fb ff ff       	call   80165d <close>
	return r;
  801a60:	83 c4 10             	add    $0x10,%esp
  801a63:	89 f3                	mov    %esi,%ebx
}
  801a65:	89 d8                	mov    %ebx,%eax
  801a67:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6a:	5b                   	pop    %ebx
  801a6b:	5e                   	pop    %esi
  801a6c:	5d                   	pop    %ebp
  801a6d:	c3                   	ret    

00801a6e <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801a6e:	55                   	push   %ebp
  801a6f:	89 e5                	mov    %esp,%ebp
  801a71:	56                   	push   %esi
  801a72:	53                   	push   %ebx
  801a73:	89 c6                	mov    %eax,%esi
  801a75:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801a77:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  801a7e:	74 27                	je     801aa7 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a80:	6a 07                	push   $0x7
  801a82:	68 00 50 80 00       	push   $0x805000
  801a87:	56                   	push   %esi
  801a88:	ff 35 00 40 80 00    	pushl  0x804000
  801a8e:	e8 95 08 00 00       	call   802328 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a93:	83 c4 0c             	add    $0xc,%esp
  801a96:	6a 00                	push   $0x0
  801a98:	53                   	push   %ebx
  801a99:	6a 00                	push   $0x0
  801a9b:	e8 1a 08 00 00       	call   8022ba <ipc_recv>
}
  801aa0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801aa3:	5b                   	pop    %ebx
  801aa4:	5e                   	pop    %esi
  801aa5:	5d                   	pop    %ebp
  801aa6:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801aa7:	83 ec 0c             	sub    $0xc,%esp
  801aaa:	6a 01                	push   $0x1
  801aac:	e8 dc 08 00 00       	call   80238d <ipc_find_env>
  801ab1:	a3 00 40 80 00       	mov    %eax,0x804000
  801ab6:	83 c4 10             	add    $0x10,%esp
  801ab9:	eb c5                	jmp    801a80 <fsipc+0x12>

00801abb <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801abb:	f3 0f 1e fb          	endbr32 
  801abf:	55                   	push   %ebp
  801ac0:	89 e5                	mov    %esp,%ebp
  801ac2:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801ac5:	8b 45 08             	mov    0x8(%ebp),%eax
  801ac8:	8b 40 0c             	mov    0xc(%eax),%eax
  801acb:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801ad0:	8b 45 0c             	mov    0xc(%ebp),%eax
  801ad3:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801ad8:	ba 00 00 00 00       	mov    $0x0,%edx
  801add:	b8 02 00 00 00       	mov    $0x2,%eax
  801ae2:	e8 87 ff ff ff       	call   801a6e <fsipc>
}
  801ae7:	c9                   	leave  
  801ae8:	c3                   	ret    

00801ae9 <devfile_flush>:
{
  801ae9:	f3 0f 1e fb          	endbr32 
  801aed:	55                   	push   %ebp
  801aee:	89 e5                	mov    %esp,%ebp
  801af0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801af3:	8b 45 08             	mov    0x8(%ebp),%eax
  801af6:	8b 40 0c             	mov    0xc(%eax),%eax
  801af9:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801afe:	ba 00 00 00 00       	mov    $0x0,%edx
  801b03:	b8 06 00 00 00       	mov    $0x6,%eax
  801b08:	e8 61 ff ff ff       	call   801a6e <fsipc>
}
  801b0d:	c9                   	leave  
  801b0e:	c3                   	ret    

00801b0f <devfile_stat>:
{
  801b0f:	f3 0f 1e fb          	endbr32 
  801b13:	55                   	push   %ebp
  801b14:	89 e5                	mov    %esp,%ebp
  801b16:	53                   	push   %ebx
  801b17:	83 ec 04             	sub    $0x4,%esp
  801b1a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801b1d:	8b 45 08             	mov    0x8(%ebp),%eax
  801b20:	8b 40 0c             	mov    0xc(%eax),%eax
  801b23:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801b28:	ba 00 00 00 00       	mov    $0x0,%edx
  801b2d:	b8 05 00 00 00       	mov    $0x5,%eax
  801b32:	e8 37 ff ff ff       	call   801a6e <fsipc>
  801b37:	85 c0                	test   %eax,%eax
  801b39:	78 2c                	js     801b67 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801b3b:	83 ec 08             	sub    $0x8,%esp
  801b3e:	68 00 50 80 00       	push   $0x805000
  801b43:	53                   	push   %ebx
  801b44:	e8 4a ee ff ff       	call   800993 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801b49:	a1 80 50 80 00       	mov    0x805080,%eax
  801b4e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801b54:	a1 84 50 80 00       	mov    0x805084,%eax
  801b59:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801b5f:	83 c4 10             	add    $0x10,%esp
  801b62:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b67:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b6a:	c9                   	leave  
  801b6b:	c3                   	ret    

00801b6c <devfile_write>:
{
  801b6c:	f3 0f 1e fb          	endbr32 
  801b70:	55                   	push   %ebp
  801b71:	89 e5                	mov    %esp,%ebp
  801b73:	83 ec 0c             	sub    $0xc,%esp
  801b76:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801b79:	8b 55 08             	mov    0x8(%ebp),%edx
  801b7c:	8b 52 0c             	mov    0xc(%edx),%edx
  801b7f:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801b85:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b8a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b8f:	0f 47 c2             	cmova  %edx,%eax
  801b92:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801b97:	50                   	push   %eax
  801b98:	ff 75 0c             	pushl  0xc(%ebp)
  801b9b:	68 08 50 80 00       	push   $0x805008
  801ba0:	e8 a6 ef ff ff       	call   800b4b <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801ba5:	ba 00 00 00 00       	mov    $0x0,%edx
  801baa:	b8 04 00 00 00       	mov    $0x4,%eax
  801baf:	e8 ba fe ff ff       	call   801a6e <fsipc>
}
  801bb4:	c9                   	leave  
  801bb5:	c3                   	ret    

00801bb6 <devfile_read>:
{
  801bb6:	f3 0f 1e fb          	endbr32 
  801bba:	55                   	push   %ebp
  801bbb:	89 e5                	mov    %esp,%ebp
  801bbd:	56                   	push   %esi
  801bbe:	53                   	push   %ebx
  801bbf:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801bc2:	8b 45 08             	mov    0x8(%ebp),%eax
  801bc5:	8b 40 0c             	mov    0xc(%eax),%eax
  801bc8:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801bcd:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801bd3:	ba 00 00 00 00       	mov    $0x0,%edx
  801bd8:	b8 03 00 00 00       	mov    $0x3,%eax
  801bdd:	e8 8c fe ff ff       	call   801a6e <fsipc>
  801be2:	89 c3                	mov    %eax,%ebx
  801be4:	85 c0                	test   %eax,%eax
  801be6:	78 1f                	js     801c07 <devfile_read+0x51>
	assert(r <= n);
  801be8:	39 f0                	cmp    %esi,%eax
  801bea:	77 24                	ja     801c10 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801bec:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801bf1:	7f 33                	jg     801c26 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801bf3:	83 ec 04             	sub    $0x4,%esp
  801bf6:	50                   	push   %eax
  801bf7:	68 00 50 80 00       	push   $0x805000
  801bfc:	ff 75 0c             	pushl  0xc(%ebp)
  801bff:	e8 47 ef ff ff       	call   800b4b <memmove>
	return r;
  801c04:	83 c4 10             	add    $0x10,%esp
}
  801c07:	89 d8                	mov    %ebx,%eax
  801c09:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c0c:	5b                   	pop    %ebx
  801c0d:	5e                   	pop    %esi
  801c0e:	5d                   	pop    %ebp
  801c0f:	c3                   	ret    
	assert(r <= n);
  801c10:	68 9c 2d 80 00       	push   $0x802d9c
  801c15:	68 a3 2d 80 00       	push   $0x802da3
  801c1a:	6a 7c                	push   $0x7c
  801c1c:	68 b8 2d 80 00       	push   $0x802db8
  801c21:	e8 1c e7 ff ff       	call   800342 <_panic>
	assert(r <= PGSIZE);
  801c26:	68 c3 2d 80 00       	push   $0x802dc3
  801c2b:	68 a3 2d 80 00       	push   $0x802da3
  801c30:	6a 7d                	push   $0x7d
  801c32:	68 b8 2d 80 00       	push   $0x802db8
  801c37:	e8 06 e7 ff ff       	call   800342 <_panic>

00801c3c <open>:
{
  801c3c:	f3 0f 1e fb          	endbr32 
  801c40:	55                   	push   %ebp
  801c41:	89 e5                	mov    %esp,%ebp
  801c43:	56                   	push   %esi
  801c44:	53                   	push   %ebx
  801c45:	83 ec 1c             	sub    $0x1c,%esp
  801c48:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801c4b:	56                   	push   %esi
  801c4c:	e8 ff ec ff ff       	call   800950 <strlen>
  801c51:	83 c4 10             	add    $0x10,%esp
  801c54:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801c59:	7f 6c                	jg     801cc7 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801c5b:	83 ec 0c             	sub    $0xc,%esp
  801c5e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801c61:	50                   	push   %eax
  801c62:	e8 67 f8 ff ff       	call   8014ce <fd_alloc>
  801c67:	89 c3                	mov    %eax,%ebx
  801c69:	83 c4 10             	add    $0x10,%esp
  801c6c:	85 c0                	test   %eax,%eax
  801c6e:	78 3c                	js     801cac <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801c70:	83 ec 08             	sub    $0x8,%esp
  801c73:	56                   	push   %esi
  801c74:	68 00 50 80 00       	push   $0x805000
  801c79:	e8 15 ed ff ff       	call   800993 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801c7e:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c81:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c86:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c89:	b8 01 00 00 00       	mov    $0x1,%eax
  801c8e:	e8 db fd ff ff       	call   801a6e <fsipc>
  801c93:	89 c3                	mov    %eax,%ebx
  801c95:	83 c4 10             	add    $0x10,%esp
  801c98:	85 c0                	test   %eax,%eax
  801c9a:	78 19                	js     801cb5 <open+0x79>
	return fd2num(fd);
  801c9c:	83 ec 0c             	sub    $0xc,%esp
  801c9f:	ff 75 f4             	pushl  -0xc(%ebp)
  801ca2:	e8 f4 f7 ff ff       	call   80149b <fd2num>
  801ca7:	89 c3                	mov    %eax,%ebx
  801ca9:	83 c4 10             	add    $0x10,%esp
}
  801cac:	89 d8                	mov    %ebx,%eax
  801cae:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb1:	5b                   	pop    %ebx
  801cb2:	5e                   	pop    %esi
  801cb3:	5d                   	pop    %ebp
  801cb4:	c3                   	ret    
		fd_close(fd, 0);
  801cb5:	83 ec 08             	sub    $0x8,%esp
  801cb8:	6a 00                	push   $0x0
  801cba:	ff 75 f4             	pushl  -0xc(%ebp)
  801cbd:	e8 10 f9 ff ff       	call   8015d2 <fd_close>
		return r;
  801cc2:	83 c4 10             	add    $0x10,%esp
  801cc5:	eb e5                	jmp    801cac <open+0x70>
		return -E_BAD_PATH;
  801cc7:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801ccc:	eb de                	jmp    801cac <open+0x70>

00801cce <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801cce:	f3 0f 1e fb          	endbr32 
  801cd2:	55                   	push   %ebp
  801cd3:	89 e5                	mov    %esp,%ebp
  801cd5:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801cd8:	ba 00 00 00 00       	mov    $0x0,%edx
  801cdd:	b8 08 00 00 00       	mov    $0x8,%eax
  801ce2:	e8 87 fd ff ff       	call   801a6e <fsipc>
}
  801ce7:	c9                   	leave  
  801ce8:	c3                   	ret    

00801ce9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801ce9:	f3 0f 1e fb          	endbr32 
  801ced:	55                   	push   %ebp
  801cee:	89 e5                	mov    %esp,%ebp
  801cf0:	56                   	push   %esi
  801cf1:	53                   	push   %ebx
  801cf2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801cf5:	83 ec 0c             	sub    $0xc,%esp
  801cf8:	ff 75 08             	pushl  0x8(%ebp)
  801cfb:	e8 af f7 ff ff       	call   8014af <fd2data>
  801d00:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801d02:	83 c4 08             	add    $0x8,%esp
  801d05:	68 cf 2d 80 00       	push   $0x802dcf
  801d0a:	53                   	push   %ebx
  801d0b:	e8 83 ec ff ff       	call   800993 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801d10:	8b 46 04             	mov    0x4(%esi),%eax
  801d13:	2b 06                	sub    (%esi),%eax
  801d15:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801d1b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801d22:	00 00 00 
	stat->st_dev = &devpipe;
  801d25:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801d2c:	30 80 00 
	return 0;
}
  801d2f:	b8 00 00 00 00       	mov    $0x0,%eax
  801d34:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d37:	5b                   	pop    %ebx
  801d38:	5e                   	pop    %esi
  801d39:	5d                   	pop    %ebp
  801d3a:	c3                   	ret    

00801d3b <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801d3b:	f3 0f 1e fb          	endbr32 
  801d3f:	55                   	push   %ebp
  801d40:	89 e5                	mov    %esp,%ebp
  801d42:	53                   	push   %ebx
  801d43:	83 ec 0c             	sub    $0xc,%esp
  801d46:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801d49:	53                   	push   %ebx
  801d4a:	6a 00                	push   $0x0
  801d4c:	e8 1c f1 ff ff       	call   800e6d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801d51:	89 1c 24             	mov    %ebx,(%esp)
  801d54:	e8 56 f7 ff ff       	call   8014af <fd2data>
  801d59:	83 c4 08             	add    $0x8,%esp
  801d5c:	50                   	push   %eax
  801d5d:	6a 00                	push   $0x0
  801d5f:	e8 09 f1 ff ff       	call   800e6d <sys_page_unmap>
}
  801d64:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d67:	c9                   	leave  
  801d68:	c3                   	ret    

00801d69 <_pipeisclosed>:
{
  801d69:	55                   	push   %ebp
  801d6a:	89 e5                	mov    %esp,%ebp
  801d6c:	57                   	push   %edi
  801d6d:	56                   	push   %esi
  801d6e:	53                   	push   %ebx
  801d6f:	83 ec 1c             	sub    $0x1c,%esp
  801d72:	89 c7                	mov    %eax,%edi
  801d74:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801d76:	a1 04 40 80 00       	mov    0x804004,%eax
  801d7b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801d7e:	83 ec 0c             	sub    $0xc,%esp
  801d81:	57                   	push   %edi
  801d82:	e8 43 06 00 00       	call   8023ca <pageref>
  801d87:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d8a:	89 34 24             	mov    %esi,(%esp)
  801d8d:	e8 38 06 00 00       	call   8023ca <pageref>
		nn = thisenv->env_runs;
  801d92:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d98:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d9b:	83 c4 10             	add    $0x10,%esp
  801d9e:	39 cb                	cmp    %ecx,%ebx
  801da0:	74 1b                	je     801dbd <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801da2:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801da5:	75 cf                	jne    801d76 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801da7:	8b 42 58             	mov    0x58(%edx),%eax
  801daa:	6a 01                	push   $0x1
  801dac:	50                   	push   %eax
  801dad:	53                   	push   %ebx
  801dae:	68 d6 2d 80 00       	push   $0x802dd6
  801db3:	e8 71 e6 ff ff       	call   800429 <cprintf>
  801db8:	83 c4 10             	add    $0x10,%esp
  801dbb:	eb b9                	jmp    801d76 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801dbd:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801dc0:	0f 94 c0             	sete   %al
  801dc3:	0f b6 c0             	movzbl %al,%eax
}
  801dc6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dc9:	5b                   	pop    %ebx
  801dca:	5e                   	pop    %esi
  801dcb:	5f                   	pop    %edi
  801dcc:	5d                   	pop    %ebp
  801dcd:	c3                   	ret    

00801dce <devpipe_write>:
{
  801dce:	f3 0f 1e fb          	endbr32 
  801dd2:	55                   	push   %ebp
  801dd3:	89 e5                	mov    %esp,%ebp
  801dd5:	57                   	push   %edi
  801dd6:	56                   	push   %esi
  801dd7:	53                   	push   %ebx
  801dd8:	83 ec 28             	sub    $0x28,%esp
  801ddb:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801dde:	56                   	push   %esi
  801ddf:	e8 cb f6 ff ff       	call   8014af <fd2data>
  801de4:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801de6:	83 c4 10             	add    $0x10,%esp
  801de9:	bf 00 00 00 00       	mov    $0x0,%edi
  801dee:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801df1:	74 4f                	je     801e42 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801df3:	8b 43 04             	mov    0x4(%ebx),%eax
  801df6:	8b 0b                	mov    (%ebx),%ecx
  801df8:	8d 51 20             	lea    0x20(%ecx),%edx
  801dfb:	39 d0                	cmp    %edx,%eax
  801dfd:	72 14                	jb     801e13 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801dff:	89 da                	mov    %ebx,%edx
  801e01:	89 f0                	mov    %esi,%eax
  801e03:	e8 61 ff ff ff       	call   801d69 <_pipeisclosed>
  801e08:	85 c0                	test   %eax,%eax
  801e0a:	75 3b                	jne    801e47 <devpipe_write+0x79>
			sys_yield();
  801e0c:	e8 df ef ff ff       	call   800df0 <sys_yield>
  801e11:	eb e0                	jmp    801df3 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801e13:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e16:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801e1a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801e1d:	89 c2                	mov    %eax,%edx
  801e1f:	c1 fa 1f             	sar    $0x1f,%edx
  801e22:	89 d1                	mov    %edx,%ecx
  801e24:	c1 e9 1b             	shr    $0x1b,%ecx
  801e27:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801e2a:	83 e2 1f             	and    $0x1f,%edx
  801e2d:	29 ca                	sub    %ecx,%edx
  801e2f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801e33:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801e37:	83 c0 01             	add    $0x1,%eax
  801e3a:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801e3d:	83 c7 01             	add    $0x1,%edi
  801e40:	eb ac                	jmp    801dee <devpipe_write+0x20>
	return i;
  801e42:	8b 45 10             	mov    0x10(%ebp),%eax
  801e45:	eb 05                	jmp    801e4c <devpipe_write+0x7e>
				return 0;
  801e47:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801e4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e4f:	5b                   	pop    %ebx
  801e50:	5e                   	pop    %esi
  801e51:	5f                   	pop    %edi
  801e52:	5d                   	pop    %ebp
  801e53:	c3                   	ret    

00801e54 <devpipe_read>:
{
  801e54:	f3 0f 1e fb          	endbr32 
  801e58:	55                   	push   %ebp
  801e59:	89 e5                	mov    %esp,%ebp
  801e5b:	57                   	push   %edi
  801e5c:	56                   	push   %esi
  801e5d:	53                   	push   %ebx
  801e5e:	83 ec 18             	sub    $0x18,%esp
  801e61:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801e64:	57                   	push   %edi
  801e65:	e8 45 f6 ff ff       	call   8014af <fd2data>
  801e6a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801e6c:	83 c4 10             	add    $0x10,%esp
  801e6f:	be 00 00 00 00       	mov    $0x0,%esi
  801e74:	3b 75 10             	cmp    0x10(%ebp),%esi
  801e77:	75 14                	jne    801e8d <devpipe_read+0x39>
	return i;
  801e79:	8b 45 10             	mov    0x10(%ebp),%eax
  801e7c:	eb 02                	jmp    801e80 <devpipe_read+0x2c>
				return i;
  801e7e:	89 f0                	mov    %esi,%eax
}
  801e80:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e83:	5b                   	pop    %ebx
  801e84:	5e                   	pop    %esi
  801e85:	5f                   	pop    %edi
  801e86:	5d                   	pop    %ebp
  801e87:	c3                   	ret    
			sys_yield();
  801e88:	e8 63 ef ff ff       	call   800df0 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801e8d:	8b 03                	mov    (%ebx),%eax
  801e8f:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e92:	75 18                	jne    801eac <devpipe_read+0x58>
			if (i > 0)
  801e94:	85 f6                	test   %esi,%esi
  801e96:	75 e6                	jne    801e7e <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801e98:	89 da                	mov    %ebx,%edx
  801e9a:	89 f8                	mov    %edi,%eax
  801e9c:	e8 c8 fe ff ff       	call   801d69 <_pipeisclosed>
  801ea1:	85 c0                	test   %eax,%eax
  801ea3:	74 e3                	je     801e88 <devpipe_read+0x34>
				return 0;
  801ea5:	b8 00 00 00 00       	mov    $0x0,%eax
  801eaa:	eb d4                	jmp    801e80 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801eac:	99                   	cltd   
  801ead:	c1 ea 1b             	shr    $0x1b,%edx
  801eb0:	01 d0                	add    %edx,%eax
  801eb2:	83 e0 1f             	and    $0x1f,%eax
  801eb5:	29 d0                	sub    %edx,%eax
  801eb7:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801ebc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801ebf:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801ec2:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801ec5:	83 c6 01             	add    $0x1,%esi
  801ec8:	eb aa                	jmp    801e74 <devpipe_read+0x20>

00801eca <pipe>:
{
  801eca:	f3 0f 1e fb          	endbr32 
  801ece:	55                   	push   %ebp
  801ecf:	89 e5                	mov    %esp,%ebp
  801ed1:	56                   	push   %esi
  801ed2:	53                   	push   %ebx
  801ed3:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801ed6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ed9:	50                   	push   %eax
  801eda:	e8 ef f5 ff ff       	call   8014ce <fd_alloc>
  801edf:	89 c3                	mov    %eax,%ebx
  801ee1:	83 c4 10             	add    $0x10,%esp
  801ee4:	85 c0                	test   %eax,%eax
  801ee6:	0f 88 23 01 00 00    	js     80200f <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eec:	83 ec 04             	sub    $0x4,%esp
  801eef:	68 07 04 00 00       	push   $0x407
  801ef4:	ff 75 f4             	pushl  -0xc(%ebp)
  801ef7:	6a 00                	push   $0x0
  801ef9:	e8 1d ef ff ff       	call   800e1b <sys_page_alloc>
  801efe:	89 c3                	mov    %eax,%ebx
  801f00:	83 c4 10             	add    $0x10,%esp
  801f03:	85 c0                	test   %eax,%eax
  801f05:	0f 88 04 01 00 00    	js     80200f <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801f0b:	83 ec 0c             	sub    $0xc,%esp
  801f0e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801f11:	50                   	push   %eax
  801f12:	e8 b7 f5 ff ff       	call   8014ce <fd_alloc>
  801f17:	89 c3                	mov    %eax,%ebx
  801f19:	83 c4 10             	add    $0x10,%esp
  801f1c:	85 c0                	test   %eax,%eax
  801f1e:	0f 88 db 00 00 00    	js     801fff <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f24:	83 ec 04             	sub    $0x4,%esp
  801f27:	68 07 04 00 00       	push   $0x407
  801f2c:	ff 75 f0             	pushl  -0x10(%ebp)
  801f2f:	6a 00                	push   $0x0
  801f31:	e8 e5 ee ff ff       	call   800e1b <sys_page_alloc>
  801f36:	89 c3                	mov    %eax,%ebx
  801f38:	83 c4 10             	add    $0x10,%esp
  801f3b:	85 c0                	test   %eax,%eax
  801f3d:	0f 88 bc 00 00 00    	js     801fff <pipe+0x135>
	va = fd2data(fd0);
  801f43:	83 ec 0c             	sub    $0xc,%esp
  801f46:	ff 75 f4             	pushl  -0xc(%ebp)
  801f49:	e8 61 f5 ff ff       	call   8014af <fd2data>
  801f4e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f50:	83 c4 0c             	add    $0xc,%esp
  801f53:	68 07 04 00 00       	push   $0x407
  801f58:	50                   	push   %eax
  801f59:	6a 00                	push   $0x0
  801f5b:	e8 bb ee ff ff       	call   800e1b <sys_page_alloc>
  801f60:	89 c3                	mov    %eax,%ebx
  801f62:	83 c4 10             	add    $0x10,%esp
  801f65:	85 c0                	test   %eax,%eax
  801f67:	0f 88 82 00 00 00    	js     801fef <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801f6d:	83 ec 0c             	sub    $0xc,%esp
  801f70:	ff 75 f0             	pushl  -0x10(%ebp)
  801f73:	e8 37 f5 ff ff       	call   8014af <fd2data>
  801f78:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801f7f:	50                   	push   %eax
  801f80:	6a 00                	push   $0x0
  801f82:	56                   	push   %esi
  801f83:	6a 00                	push   $0x0
  801f85:	e8 b9 ee ff ff       	call   800e43 <sys_page_map>
  801f8a:	89 c3                	mov    %eax,%ebx
  801f8c:	83 c4 20             	add    $0x20,%esp
  801f8f:	85 c0                	test   %eax,%eax
  801f91:	78 4e                	js     801fe1 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801f93:	a1 24 30 80 00       	mov    0x803024,%eax
  801f98:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f9b:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801f9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801fa0:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801fa7:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801faa:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801fac:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801faf:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801fb6:	83 ec 0c             	sub    $0xc,%esp
  801fb9:	ff 75 f4             	pushl  -0xc(%ebp)
  801fbc:	e8 da f4 ff ff       	call   80149b <fd2num>
  801fc1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fc4:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801fc6:	83 c4 04             	add    $0x4,%esp
  801fc9:	ff 75 f0             	pushl  -0x10(%ebp)
  801fcc:	e8 ca f4 ff ff       	call   80149b <fd2num>
  801fd1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801fd4:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801fd7:	83 c4 10             	add    $0x10,%esp
  801fda:	bb 00 00 00 00       	mov    $0x0,%ebx
  801fdf:	eb 2e                	jmp    80200f <pipe+0x145>
	sys_page_unmap(0, va);
  801fe1:	83 ec 08             	sub    $0x8,%esp
  801fe4:	56                   	push   %esi
  801fe5:	6a 00                	push   $0x0
  801fe7:	e8 81 ee ff ff       	call   800e6d <sys_page_unmap>
  801fec:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801fef:	83 ec 08             	sub    $0x8,%esp
  801ff2:	ff 75 f0             	pushl  -0x10(%ebp)
  801ff5:	6a 00                	push   $0x0
  801ff7:	e8 71 ee ff ff       	call   800e6d <sys_page_unmap>
  801ffc:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801fff:	83 ec 08             	sub    $0x8,%esp
  802002:	ff 75 f4             	pushl  -0xc(%ebp)
  802005:	6a 00                	push   $0x0
  802007:	e8 61 ee ff ff       	call   800e6d <sys_page_unmap>
  80200c:	83 c4 10             	add    $0x10,%esp
}
  80200f:	89 d8                	mov    %ebx,%eax
  802011:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802014:	5b                   	pop    %ebx
  802015:	5e                   	pop    %esi
  802016:	5d                   	pop    %ebp
  802017:	c3                   	ret    

00802018 <pipeisclosed>:
{
  802018:	f3 0f 1e fb          	endbr32 
  80201c:	55                   	push   %ebp
  80201d:	89 e5                	mov    %esp,%ebp
  80201f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802022:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802025:	50                   	push   %eax
  802026:	ff 75 08             	pushl  0x8(%ebp)
  802029:	e8 f6 f4 ff ff       	call   801524 <fd_lookup>
  80202e:	83 c4 10             	add    $0x10,%esp
  802031:	85 c0                	test   %eax,%eax
  802033:	78 18                	js     80204d <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  802035:	83 ec 0c             	sub    $0xc,%esp
  802038:	ff 75 f4             	pushl  -0xc(%ebp)
  80203b:	e8 6f f4 ff ff       	call   8014af <fd2data>
  802040:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802042:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802045:	e8 1f fd ff ff       	call   801d69 <_pipeisclosed>
  80204a:	83 c4 10             	add    $0x10,%esp
}
  80204d:	c9                   	leave  
  80204e:	c3                   	ret    

0080204f <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80204f:	f3 0f 1e fb          	endbr32 
  802053:	55                   	push   %ebp
  802054:	89 e5                	mov    %esp,%ebp
  802056:	56                   	push   %esi
  802057:	53                   	push   %ebx
  802058:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80205b:	85 f6                	test   %esi,%esi
  80205d:	74 13                	je     802072 <wait+0x23>
	e = &envs[ENVX(envid)];
  80205f:	89 f3                	mov    %esi,%ebx
  802061:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802067:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80206a:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802070:	eb 1b                	jmp    80208d <wait+0x3e>
	assert(envid != 0);
  802072:	68 ee 2d 80 00       	push   $0x802dee
  802077:	68 a3 2d 80 00       	push   $0x802da3
  80207c:	6a 09                	push   $0x9
  80207e:	68 f9 2d 80 00       	push   $0x802df9
  802083:	e8 ba e2 ff ff       	call   800342 <_panic>
		sys_yield();
  802088:	e8 63 ed ff ff       	call   800df0 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80208d:	8b 43 48             	mov    0x48(%ebx),%eax
  802090:	39 f0                	cmp    %esi,%eax
  802092:	75 07                	jne    80209b <wait+0x4c>
  802094:	8b 43 54             	mov    0x54(%ebx),%eax
  802097:	85 c0                	test   %eax,%eax
  802099:	75 ed                	jne    802088 <wait+0x39>
}
  80209b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80209e:	5b                   	pop    %ebx
  80209f:	5e                   	pop    %esi
  8020a0:	5d                   	pop    %ebp
  8020a1:	c3                   	ret    

008020a2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8020a2:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  8020a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8020ab:	c3                   	ret    

008020ac <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8020ac:	f3 0f 1e fb          	endbr32 
  8020b0:	55                   	push   %ebp
  8020b1:	89 e5                	mov    %esp,%ebp
  8020b3:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8020b6:	68 04 2e 80 00       	push   $0x802e04
  8020bb:	ff 75 0c             	pushl  0xc(%ebp)
  8020be:	e8 d0 e8 ff ff       	call   800993 <strcpy>
	return 0;
}
  8020c3:	b8 00 00 00 00       	mov    $0x0,%eax
  8020c8:	c9                   	leave  
  8020c9:	c3                   	ret    

008020ca <devcons_write>:
{
  8020ca:	f3 0f 1e fb          	endbr32 
  8020ce:	55                   	push   %ebp
  8020cf:	89 e5                	mov    %esp,%ebp
  8020d1:	57                   	push   %edi
  8020d2:	56                   	push   %esi
  8020d3:	53                   	push   %ebx
  8020d4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8020da:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8020df:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8020e5:	3b 75 10             	cmp    0x10(%ebp),%esi
  8020e8:	73 31                	jae    80211b <devcons_write+0x51>
		m = n - tot;
  8020ea:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8020ed:	29 f3                	sub    %esi,%ebx
  8020ef:	83 fb 7f             	cmp    $0x7f,%ebx
  8020f2:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8020f7:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8020fa:	83 ec 04             	sub    $0x4,%esp
  8020fd:	53                   	push   %ebx
  8020fe:	89 f0                	mov    %esi,%eax
  802100:	03 45 0c             	add    0xc(%ebp),%eax
  802103:	50                   	push   %eax
  802104:	57                   	push   %edi
  802105:	e8 41 ea ff ff       	call   800b4b <memmove>
		sys_cputs(buf, m);
  80210a:	83 c4 08             	add    $0x8,%esp
  80210d:	53                   	push   %ebx
  80210e:	57                   	push   %edi
  80210f:	e8 3c ec ff ff       	call   800d50 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802114:	01 de                	add    %ebx,%esi
  802116:	83 c4 10             	add    $0x10,%esp
  802119:	eb ca                	jmp    8020e5 <devcons_write+0x1b>
}
  80211b:	89 f0                	mov    %esi,%eax
  80211d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802120:	5b                   	pop    %ebx
  802121:	5e                   	pop    %esi
  802122:	5f                   	pop    %edi
  802123:	5d                   	pop    %ebp
  802124:	c3                   	ret    

00802125 <devcons_read>:
{
  802125:	f3 0f 1e fb          	endbr32 
  802129:	55                   	push   %ebp
  80212a:	89 e5                	mov    %esp,%ebp
  80212c:	83 ec 08             	sub    $0x8,%esp
  80212f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802134:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802138:	74 21                	je     80215b <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  80213a:	e8 3b ec ff ff       	call   800d7a <sys_cgetc>
  80213f:	85 c0                	test   %eax,%eax
  802141:	75 07                	jne    80214a <devcons_read+0x25>
		sys_yield();
  802143:	e8 a8 ec ff ff       	call   800df0 <sys_yield>
  802148:	eb f0                	jmp    80213a <devcons_read+0x15>
	if (c < 0)
  80214a:	78 0f                	js     80215b <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  80214c:	83 f8 04             	cmp    $0x4,%eax
  80214f:	74 0c                	je     80215d <devcons_read+0x38>
	*(char*)vbuf = c;
  802151:	8b 55 0c             	mov    0xc(%ebp),%edx
  802154:	88 02                	mov    %al,(%edx)
	return 1;
  802156:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80215b:	c9                   	leave  
  80215c:	c3                   	ret    
		return 0;
  80215d:	b8 00 00 00 00       	mov    $0x0,%eax
  802162:	eb f7                	jmp    80215b <devcons_read+0x36>

00802164 <cputchar>:
{
  802164:	f3 0f 1e fb          	endbr32 
  802168:	55                   	push   %ebp
  802169:	89 e5                	mov    %esp,%ebp
  80216b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80216e:	8b 45 08             	mov    0x8(%ebp),%eax
  802171:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  802174:	6a 01                	push   $0x1
  802176:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802179:	50                   	push   %eax
  80217a:	e8 d1 eb ff ff       	call   800d50 <sys_cputs>
}
  80217f:	83 c4 10             	add    $0x10,%esp
  802182:	c9                   	leave  
  802183:	c3                   	ret    

00802184 <getchar>:
{
  802184:	f3 0f 1e fb          	endbr32 
  802188:	55                   	push   %ebp
  802189:	89 e5                	mov    %esp,%ebp
  80218b:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80218e:	6a 01                	push   $0x1
  802190:	8d 45 f7             	lea    -0x9(%ebp),%eax
  802193:	50                   	push   %eax
  802194:	6a 00                	push   $0x0
  802196:	e8 0c f6 ff ff       	call   8017a7 <read>
	if (r < 0)
  80219b:	83 c4 10             	add    $0x10,%esp
  80219e:	85 c0                	test   %eax,%eax
  8021a0:	78 06                	js     8021a8 <getchar+0x24>
	if (r < 1)
  8021a2:	74 06                	je     8021aa <getchar+0x26>
	return c;
  8021a4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8021a8:	c9                   	leave  
  8021a9:	c3                   	ret    
		return -E_EOF;
  8021aa:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8021af:	eb f7                	jmp    8021a8 <getchar+0x24>

008021b1 <iscons>:
{
  8021b1:	f3 0f 1e fb          	endbr32 
  8021b5:	55                   	push   %ebp
  8021b6:	89 e5                	mov    %esp,%ebp
  8021b8:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021bb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021be:	50                   	push   %eax
  8021bf:	ff 75 08             	pushl  0x8(%ebp)
  8021c2:	e8 5d f3 ff ff       	call   801524 <fd_lookup>
  8021c7:	83 c4 10             	add    $0x10,%esp
  8021ca:	85 c0                	test   %eax,%eax
  8021cc:	78 11                	js     8021df <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8021ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021d1:	8b 15 40 30 80 00    	mov    0x803040,%edx
  8021d7:	39 10                	cmp    %edx,(%eax)
  8021d9:	0f 94 c0             	sete   %al
  8021dc:	0f b6 c0             	movzbl %al,%eax
}
  8021df:	c9                   	leave  
  8021e0:	c3                   	ret    

008021e1 <opencons>:
{
  8021e1:	f3 0f 1e fb          	endbr32 
  8021e5:	55                   	push   %ebp
  8021e6:	89 e5                	mov    %esp,%ebp
  8021e8:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8021eb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021ee:	50                   	push   %eax
  8021ef:	e8 da f2 ff ff       	call   8014ce <fd_alloc>
  8021f4:	83 c4 10             	add    $0x10,%esp
  8021f7:	85 c0                	test   %eax,%eax
  8021f9:	78 3a                	js     802235 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8021fb:	83 ec 04             	sub    $0x4,%esp
  8021fe:	68 07 04 00 00       	push   $0x407
  802203:	ff 75 f4             	pushl  -0xc(%ebp)
  802206:	6a 00                	push   $0x0
  802208:	e8 0e ec ff ff       	call   800e1b <sys_page_alloc>
  80220d:	83 c4 10             	add    $0x10,%esp
  802210:	85 c0                	test   %eax,%eax
  802212:	78 21                	js     802235 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  802214:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802217:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80221d:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80221f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802222:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802229:	83 ec 0c             	sub    $0xc,%esp
  80222c:	50                   	push   %eax
  80222d:	e8 69 f2 ff ff       	call   80149b <fd2num>
  802232:	83 c4 10             	add    $0x10,%esp
}
  802235:	c9                   	leave  
  802236:	c3                   	ret    

00802237 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802237:	f3 0f 1e fb          	endbr32 
  80223b:	55                   	push   %ebp
  80223c:	89 e5                	mov    %esp,%ebp
  80223e:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802241:	83 3d 00 60 80 00 00 	cmpl   $0x0,0x806000
  802248:	74 1c                	je     802266 <set_pgfault_handler+0x2f>
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80224a:	8b 45 08             	mov    0x8(%ebp),%eax
  80224d:	a3 00 60 80 00       	mov    %eax,0x806000

	//Indicarle al kerne que _pgfault_upcall va a ser el manejador de pgfaults de un proceso
	sys_env_set_pgfault_upcall(0, &(_pgfault_upcall));
  802252:	83 ec 08             	sub    $0x8,%esp
  802255:	68 92 22 80 00       	push   $0x802292
  80225a:	6a 00                	push   $0x0
  80225c:	e8 81 ec ff ff       	call   800ee2 <sys_env_set_pgfault_upcall>
}
  802261:	83 c4 10             	add    $0x10,%esp
  802264:	c9                   	leave  
  802265:	c3                   	ret    
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
  802266:	83 ec 04             	sub    $0x4,%esp
  802269:	6a 02                	push   $0x2
  80226b:	68 00 f0 bf ee       	push   $0xeebff000
  802270:	6a 00                	push   $0x0
  802272:	e8 a4 eb ff ff       	call   800e1b <sys_page_alloc>
  802277:	83 c4 10             	add    $0x10,%esp
  80227a:	85 c0                	test   %eax,%eax
  80227c:	79 cc                	jns    80224a <set_pgfault_handler+0x13>
  80227e:	83 ec 04             	sub    $0x4,%esp
  802281:	68 10 2e 80 00       	push   $0x802e10
  802286:	6a 20                	push   $0x20
  802288:	68 2b 2e 80 00       	push   $0x802e2b
  80228d:	e8 b0 e0 ff ff       	call   800342 <_panic>

00802292 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  802292:	54                   	push   %esp
	movl _pgfault_handler, %eax
  802293:	a1 00 60 80 00       	mov    0x806000,%eax
	call *%eax
  802298:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  80229a:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 40(%esp), %eax
  80229d:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	
  8022a1:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  8022a5:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, (%ebx)
  8022a8:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 48(%esp)
  8022aa:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8022ae:	83 c4 08             	add    $0x8,%esp
	popal
  8022b1:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8022b2:	83 c4 04             	add    $0x4,%esp
	popfl
  8022b5:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  8022b6:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8022b9:	c3                   	ret    

008022ba <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8022ba:	f3 0f 1e fb          	endbr32 
  8022be:	55                   	push   %ebp
  8022bf:	89 e5                	mov    %esp,%ebp
  8022c1:	56                   	push   %esi
  8022c2:	53                   	push   %ebx
  8022c3:	8b 75 08             	mov    0x8(%ebp),%esi
  8022c6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8022c9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  8022cc:	85 c0                	test   %eax,%eax
  8022ce:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8022d3:	0f 44 c2             	cmove  %edx,%eax
  8022d6:	83 ec 0c             	sub    $0xc,%esp
  8022d9:	50                   	push   %eax
  8022da:	e8 53 ec ff ff       	call   800f32 <sys_ipc_recv>

	if (from_env_store != NULL)
  8022df:	83 c4 10             	add    $0x10,%esp
  8022e2:	85 f6                	test   %esi,%esi
  8022e4:	74 15                	je     8022fb <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  8022e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8022eb:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8022ee:	74 09                	je     8022f9 <ipc_recv+0x3f>
  8022f0:	8b 15 04 40 80 00    	mov    0x804004,%edx
  8022f6:	8b 52 74             	mov    0x74(%edx),%edx
  8022f9:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  8022fb:	85 db                	test   %ebx,%ebx
  8022fd:	74 15                	je     802314 <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  8022ff:	ba 00 00 00 00       	mov    $0x0,%edx
  802304:	83 f8 fd             	cmp    $0xfffffffd,%eax
  802307:	74 09                	je     802312 <ipc_recv+0x58>
  802309:	8b 15 04 40 80 00    	mov    0x804004,%edx
  80230f:	8b 52 78             	mov    0x78(%edx),%edx
  802312:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  802314:	83 f8 fd             	cmp    $0xfffffffd,%eax
  802317:	74 08                	je     802321 <ipc_recv+0x67>
  802319:	a1 04 40 80 00       	mov    0x804004,%eax
  80231e:	8b 40 70             	mov    0x70(%eax),%eax
}
  802321:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802324:	5b                   	pop    %ebx
  802325:	5e                   	pop    %esi
  802326:	5d                   	pop    %ebp
  802327:	c3                   	ret    

00802328 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802328:	f3 0f 1e fb          	endbr32 
  80232c:	55                   	push   %ebp
  80232d:	89 e5                	mov    %esp,%ebp
  80232f:	57                   	push   %edi
  802330:	56                   	push   %esi
  802331:	53                   	push   %ebx
  802332:	83 ec 0c             	sub    $0xc,%esp
  802335:	8b 7d 08             	mov    0x8(%ebp),%edi
  802338:	8b 75 0c             	mov    0xc(%ebp),%esi
  80233b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80233e:	eb 1f                	jmp    80235f <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  802340:	6a 00                	push   $0x0
  802342:	68 00 00 c0 ee       	push   $0xeec00000
  802347:	56                   	push   %esi
  802348:	57                   	push   %edi
  802349:	e8 bb eb ff ff       	call   800f09 <sys_ipc_try_send>
  80234e:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  802351:	85 c0                	test   %eax,%eax
  802353:	74 30                	je     802385 <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  802355:	83 f8 f9             	cmp    $0xfffffff9,%eax
  802358:	75 19                	jne    802373 <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  80235a:	e8 91 ea ff ff       	call   800df0 <sys_yield>
		if (pg != NULL) {
  80235f:	85 db                	test   %ebx,%ebx
  802361:	74 dd                	je     802340 <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  802363:	ff 75 14             	pushl  0x14(%ebp)
  802366:	53                   	push   %ebx
  802367:	56                   	push   %esi
  802368:	57                   	push   %edi
  802369:	e8 9b eb ff ff       	call   800f09 <sys_ipc_try_send>
  80236e:	83 c4 10             	add    $0x10,%esp
  802371:	eb de                	jmp    802351 <ipc_send+0x29>
			panic("ipc_send: %d", res);
  802373:	50                   	push   %eax
  802374:	68 39 2e 80 00       	push   $0x802e39
  802379:	6a 3e                	push   $0x3e
  80237b:	68 46 2e 80 00       	push   $0x802e46
  802380:	e8 bd df ff ff       	call   800342 <_panic>
	}
}
  802385:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802388:	5b                   	pop    %ebx
  802389:	5e                   	pop    %esi
  80238a:	5f                   	pop    %edi
  80238b:	5d                   	pop    %ebp
  80238c:	c3                   	ret    

0080238d <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  80238d:	f3 0f 1e fb          	endbr32 
  802391:	55                   	push   %ebp
  802392:	89 e5                	mov    %esp,%ebp
  802394:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  802397:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  80239c:	6b d0 7c             	imul   $0x7c,%eax,%edx
  80239f:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8023a5:	8b 52 50             	mov    0x50(%edx),%edx
  8023a8:	39 ca                	cmp    %ecx,%edx
  8023aa:	74 11                	je     8023bd <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8023ac:	83 c0 01             	add    $0x1,%eax
  8023af:	3d 00 04 00 00       	cmp    $0x400,%eax
  8023b4:	75 e6                	jne    80239c <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8023b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8023bb:	eb 0b                	jmp    8023c8 <ipc_find_env+0x3b>
			return envs[i].env_id;
  8023bd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8023c0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8023c5:	8b 40 48             	mov    0x48(%eax),%eax
}
  8023c8:	5d                   	pop    %ebp
  8023c9:	c3                   	ret    

008023ca <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8023ca:	f3 0f 1e fb          	endbr32 
  8023ce:	55                   	push   %ebp
  8023cf:	89 e5                	mov    %esp,%ebp
  8023d1:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8023d4:	89 c2                	mov    %eax,%edx
  8023d6:	c1 ea 16             	shr    $0x16,%edx
  8023d9:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  8023e0:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  8023e5:	f6 c1 01             	test   $0x1,%cl
  8023e8:	74 1c                	je     802406 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  8023ea:	c1 e8 0c             	shr    $0xc,%eax
  8023ed:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  8023f4:	a8 01                	test   $0x1,%al
  8023f6:	74 0e                	je     802406 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  8023f8:	c1 e8 0c             	shr    $0xc,%eax
  8023fb:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802402:	ef 
  802403:	0f b7 d2             	movzwl %dx,%edx
}
  802406:	89 d0                	mov    %edx,%eax
  802408:	5d                   	pop    %ebp
  802409:	c3                   	ret    
  80240a:	66 90                	xchg   %ax,%ax
  80240c:	66 90                	xchg   %ax,%ax
  80240e:	66 90                	xchg   %ax,%ax

00802410 <__udivdi3>:
  802410:	f3 0f 1e fb          	endbr32 
  802414:	55                   	push   %ebp
  802415:	57                   	push   %edi
  802416:	56                   	push   %esi
  802417:	53                   	push   %ebx
  802418:	83 ec 1c             	sub    $0x1c,%esp
  80241b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80241f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802423:	8b 74 24 34          	mov    0x34(%esp),%esi
  802427:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80242b:	85 d2                	test   %edx,%edx
  80242d:	75 19                	jne    802448 <__udivdi3+0x38>
  80242f:	39 f3                	cmp    %esi,%ebx
  802431:	76 4d                	jbe    802480 <__udivdi3+0x70>
  802433:	31 ff                	xor    %edi,%edi
  802435:	89 e8                	mov    %ebp,%eax
  802437:	89 f2                	mov    %esi,%edx
  802439:	f7 f3                	div    %ebx
  80243b:	89 fa                	mov    %edi,%edx
  80243d:	83 c4 1c             	add    $0x1c,%esp
  802440:	5b                   	pop    %ebx
  802441:	5e                   	pop    %esi
  802442:	5f                   	pop    %edi
  802443:	5d                   	pop    %ebp
  802444:	c3                   	ret    
  802445:	8d 76 00             	lea    0x0(%esi),%esi
  802448:	39 f2                	cmp    %esi,%edx
  80244a:	76 14                	jbe    802460 <__udivdi3+0x50>
  80244c:	31 ff                	xor    %edi,%edi
  80244e:	31 c0                	xor    %eax,%eax
  802450:	89 fa                	mov    %edi,%edx
  802452:	83 c4 1c             	add    $0x1c,%esp
  802455:	5b                   	pop    %ebx
  802456:	5e                   	pop    %esi
  802457:	5f                   	pop    %edi
  802458:	5d                   	pop    %ebp
  802459:	c3                   	ret    
  80245a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802460:	0f bd fa             	bsr    %edx,%edi
  802463:	83 f7 1f             	xor    $0x1f,%edi
  802466:	75 48                	jne    8024b0 <__udivdi3+0xa0>
  802468:	39 f2                	cmp    %esi,%edx
  80246a:	72 06                	jb     802472 <__udivdi3+0x62>
  80246c:	31 c0                	xor    %eax,%eax
  80246e:	39 eb                	cmp    %ebp,%ebx
  802470:	77 de                	ja     802450 <__udivdi3+0x40>
  802472:	b8 01 00 00 00       	mov    $0x1,%eax
  802477:	eb d7                	jmp    802450 <__udivdi3+0x40>
  802479:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802480:	89 d9                	mov    %ebx,%ecx
  802482:	85 db                	test   %ebx,%ebx
  802484:	75 0b                	jne    802491 <__udivdi3+0x81>
  802486:	b8 01 00 00 00       	mov    $0x1,%eax
  80248b:	31 d2                	xor    %edx,%edx
  80248d:	f7 f3                	div    %ebx
  80248f:	89 c1                	mov    %eax,%ecx
  802491:	31 d2                	xor    %edx,%edx
  802493:	89 f0                	mov    %esi,%eax
  802495:	f7 f1                	div    %ecx
  802497:	89 c6                	mov    %eax,%esi
  802499:	89 e8                	mov    %ebp,%eax
  80249b:	89 f7                	mov    %esi,%edi
  80249d:	f7 f1                	div    %ecx
  80249f:	89 fa                	mov    %edi,%edx
  8024a1:	83 c4 1c             	add    $0x1c,%esp
  8024a4:	5b                   	pop    %ebx
  8024a5:	5e                   	pop    %esi
  8024a6:	5f                   	pop    %edi
  8024a7:	5d                   	pop    %ebp
  8024a8:	c3                   	ret    
  8024a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8024b0:	89 f9                	mov    %edi,%ecx
  8024b2:	b8 20 00 00 00       	mov    $0x20,%eax
  8024b7:	29 f8                	sub    %edi,%eax
  8024b9:	d3 e2                	shl    %cl,%edx
  8024bb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8024bf:	89 c1                	mov    %eax,%ecx
  8024c1:	89 da                	mov    %ebx,%edx
  8024c3:	d3 ea                	shr    %cl,%edx
  8024c5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8024c9:	09 d1                	or     %edx,%ecx
  8024cb:	89 f2                	mov    %esi,%edx
  8024cd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8024d1:	89 f9                	mov    %edi,%ecx
  8024d3:	d3 e3                	shl    %cl,%ebx
  8024d5:	89 c1                	mov    %eax,%ecx
  8024d7:	d3 ea                	shr    %cl,%edx
  8024d9:	89 f9                	mov    %edi,%ecx
  8024db:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  8024df:	89 eb                	mov    %ebp,%ebx
  8024e1:	d3 e6                	shl    %cl,%esi
  8024e3:	89 c1                	mov    %eax,%ecx
  8024e5:	d3 eb                	shr    %cl,%ebx
  8024e7:	09 de                	or     %ebx,%esi
  8024e9:	89 f0                	mov    %esi,%eax
  8024eb:	f7 74 24 08          	divl   0x8(%esp)
  8024ef:	89 d6                	mov    %edx,%esi
  8024f1:	89 c3                	mov    %eax,%ebx
  8024f3:	f7 64 24 0c          	mull   0xc(%esp)
  8024f7:	39 d6                	cmp    %edx,%esi
  8024f9:	72 15                	jb     802510 <__udivdi3+0x100>
  8024fb:	89 f9                	mov    %edi,%ecx
  8024fd:	d3 e5                	shl    %cl,%ebp
  8024ff:	39 c5                	cmp    %eax,%ebp
  802501:	73 04                	jae    802507 <__udivdi3+0xf7>
  802503:	39 d6                	cmp    %edx,%esi
  802505:	74 09                	je     802510 <__udivdi3+0x100>
  802507:	89 d8                	mov    %ebx,%eax
  802509:	31 ff                	xor    %edi,%edi
  80250b:	e9 40 ff ff ff       	jmp    802450 <__udivdi3+0x40>
  802510:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802513:	31 ff                	xor    %edi,%edi
  802515:	e9 36 ff ff ff       	jmp    802450 <__udivdi3+0x40>
  80251a:	66 90                	xchg   %ax,%ax
  80251c:	66 90                	xchg   %ax,%ax
  80251e:	66 90                	xchg   %ax,%ax

00802520 <__umoddi3>:
  802520:	f3 0f 1e fb          	endbr32 
  802524:	55                   	push   %ebp
  802525:	57                   	push   %edi
  802526:	56                   	push   %esi
  802527:	53                   	push   %ebx
  802528:	83 ec 1c             	sub    $0x1c,%esp
  80252b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80252f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802533:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802537:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80253b:	85 c0                	test   %eax,%eax
  80253d:	75 19                	jne    802558 <__umoddi3+0x38>
  80253f:	39 df                	cmp    %ebx,%edi
  802541:	76 5d                	jbe    8025a0 <__umoddi3+0x80>
  802543:	89 f0                	mov    %esi,%eax
  802545:	89 da                	mov    %ebx,%edx
  802547:	f7 f7                	div    %edi
  802549:	89 d0                	mov    %edx,%eax
  80254b:	31 d2                	xor    %edx,%edx
  80254d:	83 c4 1c             	add    $0x1c,%esp
  802550:	5b                   	pop    %ebx
  802551:	5e                   	pop    %esi
  802552:	5f                   	pop    %edi
  802553:	5d                   	pop    %ebp
  802554:	c3                   	ret    
  802555:	8d 76 00             	lea    0x0(%esi),%esi
  802558:	89 f2                	mov    %esi,%edx
  80255a:	39 d8                	cmp    %ebx,%eax
  80255c:	76 12                	jbe    802570 <__umoddi3+0x50>
  80255e:	89 f0                	mov    %esi,%eax
  802560:	89 da                	mov    %ebx,%edx
  802562:	83 c4 1c             	add    $0x1c,%esp
  802565:	5b                   	pop    %ebx
  802566:	5e                   	pop    %esi
  802567:	5f                   	pop    %edi
  802568:	5d                   	pop    %ebp
  802569:	c3                   	ret    
  80256a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802570:	0f bd e8             	bsr    %eax,%ebp
  802573:	83 f5 1f             	xor    $0x1f,%ebp
  802576:	75 50                	jne    8025c8 <__umoddi3+0xa8>
  802578:	39 d8                	cmp    %ebx,%eax
  80257a:	0f 82 e0 00 00 00    	jb     802660 <__umoddi3+0x140>
  802580:	89 d9                	mov    %ebx,%ecx
  802582:	39 f7                	cmp    %esi,%edi
  802584:	0f 86 d6 00 00 00    	jbe    802660 <__umoddi3+0x140>
  80258a:	89 d0                	mov    %edx,%eax
  80258c:	89 ca                	mov    %ecx,%edx
  80258e:	83 c4 1c             	add    $0x1c,%esp
  802591:	5b                   	pop    %ebx
  802592:	5e                   	pop    %esi
  802593:	5f                   	pop    %edi
  802594:	5d                   	pop    %ebp
  802595:	c3                   	ret    
  802596:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80259d:	8d 76 00             	lea    0x0(%esi),%esi
  8025a0:	89 fd                	mov    %edi,%ebp
  8025a2:	85 ff                	test   %edi,%edi
  8025a4:	75 0b                	jne    8025b1 <__umoddi3+0x91>
  8025a6:	b8 01 00 00 00       	mov    $0x1,%eax
  8025ab:	31 d2                	xor    %edx,%edx
  8025ad:	f7 f7                	div    %edi
  8025af:	89 c5                	mov    %eax,%ebp
  8025b1:	89 d8                	mov    %ebx,%eax
  8025b3:	31 d2                	xor    %edx,%edx
  8025b5:	f7 f5                	div    %ebp
  8025b7:	89 f0                	mov    %esi,%eax
  8025b9:	f7 f5                	div    %ebp
  8025bb:	89 d0                	mov    %edx,%eax
  8025bd:	31 d2                	xor    %edx,%edx
  8025bf:	eb 8c                	jmp    80254d <__umoddi3+0x2d>
  8025c1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025c8:	89 e9                	mov    %ebp,%ecx
  8025ca:	ba 20 00 00 00       	mov    $0x20,%edx
  8025cf:	29 ea                	sub    %ebp,%edx
  8025d1:	d3 e0                	shl    %cl,%eax
  8025d3:	89 44 24 08          	mov    %eax,0x8(%esp)
  8025d7:	89 d1                	mov    %edx,%ecx
  8025d9:	89 f8                	mov    %edi,%eax
  8025db:	d3 e8                	shr    %cl,%eax
  8025dd:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8025e1:	89 54 24 04          	mov    %edx,0x4(%esp)
  8025e5:	8b 54 24 04          	mov    0x4(%esp),%edx
  8025e9:	09 c1                	or     %eax,%ecx
  8025eb:	89 d8                	mov    %ebx,%eax
  8025ed:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  8025f1:	89 e9                	mov    %ebp,%ecx
  8025f3:	d3 e7                	shl    %cl,%edi
  8025f5:	89 d1                	mov    %edx,%ecx
  8025f7:	d3 e8                	shr    %cl,%eax
  8025f9:	89 e9                	mov    %ebp,%ecx
  8025fb:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  8025ff:	d3 e3                	shl    %cl,%ebx
  802601:	89 c7                	mov    %eax,%edi
  802603:	89 d1                	mov    %edx,%ecx
  802605:	89 f0                	mov    %esi,%eax
  802607:	d3 e8                	shr    %cl,%eax
  802609:	89 e9                	mov    %ebp,%ecx
  80260b:	89 fa                	mov    %edi,%edx
  80260d:	d3 e6                	shl    %cl,%esi
  80260f:	09 d8                	or     %ebx,%eax
  802611:	f7 74 24 08          	divl   0x8(%esp)
  802615:	89 d1                	mov    %edx,%ecx
  802617:	89 f3                	mov    %esi,%ebx
  802619:	f7 64 24 0c          	mull   0xc(%esp)
  80261d:	89 c6                	mov    %eax,%esi
  80261f:	89 d7                	mov    %edx,%edi
  802621:	39 d1                	cmp    %edx,%ecx
  802623:	72 06                	jb     80262b <__umoddi3+0x10b>
  802625:	75 10                	jne    802637 <__umoddi3+0x117>
  802627:	39 c3                	cmp    %eax,%ebx
  802629:	73 0c                	jae    802637 <__umoddi3+0x117>
  80262b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80262f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802633:	89 d7                	mov    %edx,%edi
  802635:	89 c6                	mov    %eax,%esi
  802637:	89 ca                	mov    %ecx,%edx
  802639:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80263e:	29 f3                	sub    %esi,%ebx
  802640:	19 fa                	sbb    %edi,%edx
  802642:	89 d0                	mov    %edx,%eax
  802644:	d3 e0                	shl    %cl,%eax
  802646:	89 e9                	mov    %ebp,%ecx
  802648:	d3 eb                	shr    %cl,%ebx
  80264a:	d3 ea                	shr    %cl,%edx
  80264c:	09 d8                	or     %ebx,%eax
  80264e:	83 c4 1c             	add    $0x1c,%esp
  802651:	5b                   	pop    %ebx
  802652:	5e                   	pop    %esi
  802653:	5f                   	pop    %edi
  802654:	5d                   	pop    %ebp
  802655:	c3                   	ret    
  802656:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80265d:	8d 76 00             	lea    0x0(%esi),%esi
  802660:	29 fe                	sub    %edi,%esi
  802662:	19 c3                	sbb    %eax,%ebx
  802664:	89 f2                	mov    %esi,%edx
  802666:	89 d9                	mov    %ebx,%ecx
  802668:	e9 1d ff ff ff       	jmp    80258a <__umoddi3+0x6a>
