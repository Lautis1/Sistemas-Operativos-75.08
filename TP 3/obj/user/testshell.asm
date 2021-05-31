
obj/user/testshell.debug:     formato del fichero elf32-i386


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
  80002c:	e8 83 04 00 00       	call   8004b4 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <breakpoint>:
#include <inc/types.h>

static inline void
breakpoint(void)
{
	asm volatile("int3");
  800033:	cc                   	int3   
}
  800034:	c3                   	ret    

00800035 <wrong>:
	breakpoint();
}

void
wrong(int rfd, int kfd, int off)
{
  800035:	f3 0f 1e fb          	endbr32 
  800039:	55                   	push   %ebp
  80003a:	89 e5                	mov    %esp,%ebp
  80003c:	57                   	push   %edi
  80003d:	56                   	push   %esi
  80003e:	53                   	push   %ebx
  80003f:	81 ec 84 00 00 00    	sub    $0x84,%esp
  800045:	8b 75 08             	mov    0x8(%ebp),%esi
  800048:	8b 7d 0c             	mov    0xc(%ebp),%edi
  80004b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	char buf[100];
	int n;

	seek(rfd, off);
  80004e:	53                   	push   %ebx
  80004f:	56                   	push   %esi
  800050:	e8 8c 1a 00 00       	call   801ae1 <seek>
	seek(kfd, off);
  800055:	83 c4 08             	add    $0x8,%esp
  800058:	53                   	push   %ebx
  800059:	57                   	push   %edi
  80005a:	e8 82 1a 00 00       	call   801ae1 <seek>

	cprintf("shell produced incorrect output.\n");
  80005f:	c7 04 24 c0 2c 80 00 	movl   $0x802cc0,(%esp)
  800066:	e8 9c 05 00 00       	call   800607 <cprintf>
	cprintf("expected:\n===\n");
  80006b:	c7 04 24 2b 2d 80 00 	movl   $0x802d2b,(%esp)
  800072:	e8 90 05 00 00       	call   800607 <cprintf>
	while ((n = read(kfd, buf, sizeof buf-1)) > 0)
  800077:	83 c4 10             	add    $0x10,%esp
  80007a:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  80007d:	83 ec 04             	sub    $0x4,%esp
  800080:	6a 63                	push   $0x63
  800082:	53                   	push   %ebx
  800083:	57                   	push   %edi
  800084:	e8 fc 18 00 00       	call   801985 <read>
  800089:	83 c4 10             	add    $0x10,%esp
  80008c:	85 c0                	test   %eax,%eax
  80008e:	7e 0f                	jle    80009f <wrong+0x6a>
		sys_cputs(buf, n);
  800090:	83 ec 08             	sub    $0x8,%esp
  800093:	50                   	push   %eax
  800094:	53                   	push   %ebx
  800095:	e8 94 0e 00 00       	call   800f2e <sys_cputs>
  80009a:	83 c4 10             	add    $0x10,%esp
  80009d:	eb de                	jmp    80007d <wrong+0x48>
	cprintf("===\ngot:\n===\n");
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	68 3a 2d 80 00       	push   $0x802d3a
  8000a7:	e8 5b 05 00 00       	call   800607 <cprintf>
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000ac:	83 c4 10             	add    $0x10,%esp
  8000af:	8d 5d 84             	lea    -0x7c(%ebp),%ebx
  8000b2:	eb 0d                	jmp    8000c1 <wrong+0x8c>
		sys_cputs(buf, n);
  8000b4:	83 ec 08             	sub    $0x8,%esp
  8000b7:	50                   	push   %eax
  8000b8:	53                   	push   %ebx
  8000b9:	e8 70 0e 00 00       	call   800f2e <sys_cputs>
  8000be:	83 c4 10             	add    $0x10,%esp
	while ((n = read(rfd, buf, sizeof buf-1)) > 0)
  8000c1:	83 ec 04             	sub    $0x4,%esp
  8000c4:	6a 63                	push   $0x63
  8000c6:	53                   	push   %ebx
  8000c7:	56                   	push   %esi
  8000c8:	e8 b8 18 00 00       	call   801985 <read>
  8000cd:	83 c4 10             	add    $0x10,%esp
  8000d0:	85 c0                	test   %eax,%eax
  8000d2:	7f e0                	jg     8000b4 <wrong+0x7f>
	cprintf("===\n");
  8000d4:	83 ec 0c             	sub    $0xc,%esp
  8000d7:	68 35 2d 80 00       	push   $0x802d35
  8000dc:	e8 26 05 00 00       	call   800607 <cprintf>
	exit();
  8000e1:	e8 1c 04 00 00       	call   800502 <exit>
}
  8000e6:	83 c4 10             	add    $0x10,%esp
  8000e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000ec:	5b                   	pop    %ebx
  8000ed:	5e                   	pop    %esi
  8000ee:	5f                   	pop    %edi
  8000ef:	5d                   	pop    %ebp
  8000f0:	c3                   	ret    

008000f1 <umain>:
{
  8000f1:	f3 0f 1e fb          	endbr32 
  8000f5:	55                   	push   %ebp
  8000f6:	89 e5                	mov    %esp,%ebp
  8000f8:	57                   	push   %edi
  8000f9:	56                   	push   %esi
  8000fa:	53                   	push   %ebx
  8000fb:	83 ec 38             	sub    $0x38,%esp
	close(0);
  8000fe:	6a 00                	push   $0x0
  800100:	e8 36 17 00 00       	call   80183b <close>
	close(1);
  800105:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  80010c:	e8 2a 17 00 00       	call   80183b <close>
	opencons();
  800111:	e8 48 03 00 00       	call   80045e <opencons>
	opencons();
  800116:	e8 43 03 00 00       	call   80045e <opencons>
	if ((rfd = open("testshell.sh", O_RDONLY)) < 0)
  80011b:	83 c4 08             	add    $0x8,%esp
  80011e:	6a 00                	push   $0x0
  800120:	68 48 2d 80 00       	push   $0x802d48
  800125:	e8 f0 1c 00 00       	call   801e1a <open>
  80012a:	89 c3                	mov    %eax,%ebx
  80012c:	83 c4 10             	add    $0x10,%esp
  80012f:	85 c0                	test   %eax,%eax
  800131:	0f 88 e7 00 00 00    	js     80021e <umain+0x12d>
	if ((wfd = pipe(pfds)) < 0)
  800137:	83 ec 0c             	sub    $0xc,%esp
  80013a:	8d 45 dc             	lea    -0x24(%ebp),%eax
  80013d:	50                   	push   %eax
  80013e:	e8 6d 25 00 00       	call   8026b0 <pipe>
  800143:	83 c4 10             	add    $0x10,%esp
  800146:	85 c0                	test   %eax,%eax
  800148:	0f 88 e2 00 00 00    	js     800230 <umain+0x13f>
	wfd = pfds[1];
  80014e:	8b 75 e0             	mov    -0x20(%ebp),%esi
	cprintf("running sh -x < testshell.sh | cat\n");
  800151:	83 ec 0c             	sub    $0xc,%esp
  800154:	68 e4 2c 80 00       	push   $0x802ce4
  800159:	e8 a9 04 00 00       	call   800607 <cprintf>
	if ((r = fork()) < 0)
  80015e:	e8 75 13 00 00       	call   8014d8 <fork>
  800163:	83 c4 10             	add    $0x10,%esp
  800166:	85 c0                	test   %eax,%eax
  800168:	0f 88 d4 00 00 00    	js     800242 <umain+0x151>
	if (r == 0) {
  80016e:	75 6f                	jne    8001df <umain+0xee>
		dup(rfd, 0);
  800170:	83 ec 08             	sub    $0x8,%esp
  800173:	6a 00                	push   $0x0
  800175:	53                   	push   %ebx
  800176:	e8 1a 17 00 00       	call   801895 <dup>
		dup(wfd, 1);
  80017b:	83 c4 08             	add    $0x8,%esp
  80017e:	6a 01                	push   $0x1
  800180:	56                   	push   %esi
  800181:	e8 0f 17 00 00       	call   801895 <dup>
		close(rfd);
  800186:	89 1c 24             	mov    %ebx,(%esp)
  800189:	e8 ad 16 00 00       	call   80183b <close>
		close(wfd);
  80018e:	89 34 24             	mov    %esi,(%esp)
  800191:	e8 a5 16 00 00       	call   80183b <close>
		if ((r = spawnl("/sh", "sh", "-x", 0)) < 0)
  800196:	6a 00                	push   $0x0
  800198:	68 8e 2d 80 00       	push   $0x802d8e
  80019d:	68 52 2d 80 00       	push   $0x802d52
  8001a2:	68 91 2d 80 00       	push   $0x802d91
  8001a7:	e8 71 22 00 00       	call   80241d <spawnl>
  8001ac:	89 c7                	mov    %eax,%edi
  8001ae:	83 c4 20             	add    $0x20,%esp
  8001b1:	85 c0                	test   %eax,%eax
  8001b3:	0f 88 9b 00 00 00    	js     800254 <umain+0x163>
		close(0);
  8001b9:	83 ec 0c             	sub    $0xc,%esp
  8001bc:	6a 00                	push   $0x0
  8001be:	e8 78 16 00 00       	call   80183b <close>
		close(1);
  8001c3:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  8001ca:	e8 6c 16 00 00       	call   80183b <close>
		wait(r);
  8001cf:	89 3c 24             	mov    %edi,(%esp)
  8001d2:	e8 5e 26 00 00       	call   802835 <wait>
		exit();
  8001d7:	e8 26 03 00 00       	call   800502 <exit>
  8001dc:	83 c4 10             	add    $0x10,%esp
	close(rfd);
  8001df:	83 ec 0c             	sub    $0xc,%esp
  8001e2:	53                   	push   %ebx
  8001e3:	e8 53 16 00 00       	call   80183b <close>
	close(wfd);
  8001e8:	89 34 24             	mov    %esi,(%esp)
  8001eb:	e8 4b 16 00 00       	call   80183b <close>
	rfd = pfds[0];
  8001f0:	8b 45 dc             	mov    -0x24(%ebp),%eax
  8001f3:	89 45 d0             	mov    %eax,-0x30(%ebp)
	if ((kfd = open("testshell.key", O_RDONLY)) < 0)
  8001f6:	83 c4 08             	add    $0x8,%esp
  8001f9:	6a 00                	push   $0x0
  8001fb:	68 9f 2d 80 00       	push   $0x802d9f
  800200:	e8 15 1c 00 00       	call   801e1a <open>
  800205:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  800208:	83 c4 10             	add    $0x10,%esp
  80020b:	85 c0                	test   %eax,%eax
  80020d:	78 57                	js     800266 <umain+0x175>
  80020f:	be 01 00 00 00       	mov    $0x1,%esi
	nloff = 0;
  800214:	bf 00 00 00 00       	mov    $0x0,%edi
  800219:	e9 9a 00 00 00       	jmp    8002b8 <umain+0x1c7>
		panic("open testshell.sh: %e", rfd);
  80021e:	50                   	push   %eax
  80021f:	68 55 2d 80 00       	push   $0x802d55
  800224:	6a 13                	push   $0x13
  800226:	68 6b 2d 80 00       	push   $0x802d6b
  80022b:	e8 f0 02 00 00       	call   800520 <_panic>
		panic("pipe: %e", wfd);
  800230:	50                   	push   %eax
  800231:	68 7c 2d 80 00       	push   $0x802d7c
  800236:	6a 15                	push   $0x15
  800238:	68 6b 2d 80 00       	push   $0x802d6b
  80023d:	e8 de 02 00 00       	call   800520 <_panic>
		panic("fork: %e", r);
  800242:	50                   	push   %eax
  800243:	68 85 2d 80 00       	push   $0x802d85
  800248:	6a 1a                	push   $0x1a
  80024a:	68 6b 2d 80 00       	push   $0x802d6b
  80024f:	e8 cc 02 00 00       	call   800520 <_panic>
			panic("spawn: %e", r);
  800254:	50                   	push   %eax
  800255:	68 95 2d 80 00       	push   $0x802d95
  80025a:	6a 21                	push   $0x21
  80025c:	68 6b 2d 80 00       	push   $0x802d6b
  800261:	e8 ba 02 00 00       	call   800520 <_panic>
		panic("open testshell.key for reading: %e", kfd);
  800266:	50                   	push   %eax
  800267:	68 08 2d 80 00       	push   $0x802d08
  80026c:	6a 2c                	push   $0x2c
  80026e:	68 6b 2d 80 00       	push   $0x802d6b
  800273:	e8 a8 02 00 00       	call   800520 <_panic>
			panic("reading testshell.out: %e", n1);
  800278:	53                   	push   %ebx
  800279:	68 ad 2d 80 00       	push   $0x802dad
  80027e:	6a 33                	push   $0x33
  800280:	68 6b 2d 80 00       	push   $0x802d6b
  800285:	e8 96 02 00 00       	call   800520 <_panic>
			panic("reading testshell.key: %e", n2);
  80028a:	50                   	push   %eax
  80028b:	68 c7 2d 80 00       	push   $0x802dc7
  800290:	6a 35                	push   $0x35
  800292:	68 6b 2d 80 00       	push   $0x802d6b
  800297:	e8 84 02 00 00       	call   800520 <_panic>
			wrong(rfd, kfd, nloff);
  80029c:	83 ec 04             	sub    $0x4,%esp
  80029f:	57                   	push   %edi
  8002a0:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002a3:	ff 75 d0             	pushl  -0x30(%ebp)
  8002a6:	e8 8a fd ff ff       	call   800035 <wrong>
  8002ab:	83 c4 10             	add    $0x10,%esp
			nloff = off+1;
  8002ae:	80 7d e7 0a          	cmpb   $0xa,-0x19(%ebp)
  8002b2:	0f 44 fe             	cmove  %esi,%edi
  8002b5:	83 c6 01             	add    $0x1,%esi
		n1 = read(rfd, &c1, 1);
  8002b8:	83 ec 04             	sub    $0x4,%esp
  8002bb:	6a 01                	push   $0x1
  8002bd:	8d 45 e7             	lea    -0x19(%ebp),%eax
  8002c0:	50                   	push   %eax
  8002c1:	ff 75 d0             	pushl  -0x30(%ebp)
  8002c4:	e8 bc 16 00 00       	call   801985 <read>
  8002c9:	89 c3                	mov    %eax,%ebx
		n2 = read(kfd, &c2, 1);
  8002cb:	83 c4 0c             	add    $0xc,%esp
  8002ce:	6a 01                	push   $0x1
  8002d0:	8d 45 e6             	lea    -0x1a(%ebp),%eax
  8002d3:	50                   	push   %eax
  8002d4:	ff 75 d4             	pushl  -0x2c(%ebp)
  8002d7:	e8 a9 16 00 00       	call   801985 <read>
		if (n1 < 0)
  8002dc:	83 c4 10             	add    $0x10,%esp
  8002df:	85 db                	test   %ebx,%ebx
  8002e1:	78 95                	js     800278 <umain+0x187>
		if (n2 < 0)
  8002e3:	85 c0                	test   %eax,%eax
  8002e5:	78 a3                	js     80028a <umain+0x199>
		if (n1 == 0 && n2 == 0)
  8002e7:	89 da                	mov    %ebx,%edx
  8002e9:	09 c2                	or     %eax,%edx
  8002eb:	74 15                	je     800302 <umain+0x211>
		if (n1 != 1 || n2 != 1 || c1 != c2)
  8002ed:	83 fb 01             	cmp    $0x1,%ebx
  8002f0:	75 aa                	jne    80029c <umain+0x1ab>
  8002f2:	83 f8 01             	cmp    $0x1,%eax
  8002f5:	75 a5                	jne    80029c <umain+0x1ab>
  8002f7:	0f b6 45 e6          	movzbl -0x1a(%ebp),%eax
  8002fb:	38 45 e7             	cmp    %al,-0x19(%ebp)
  8002fe:	75 9c                	jne    80029c <umain+0x1ab>
  800300:	eb ac                	jmp    8002ae <umain+0x1bd>
	cprintf("shell ran correctly\n");
  800302:	83 ec 0c             	sub    $0xc,%esp
  800305:	68 e1 2d 80 00       	push   $0x802de1
  80030a:	e8 f8 02 00 00       	call   800607 <cprintf>
	breakpoint();
  80030f:	e8 1f fd ff ff       	call   800033 <breakpoint>
}
  800314:	83 c4 10             	add    $0x10,%esp
  800317:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80031a:	5b                   	pop    %ebx
  80031b:	5e                   	pop    %esi
  80031c:	5f                   	pop    %edi
  80031d:	5d                   	pop    %ebp
  80031e:	c3                   	ret    

0080031f <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80031f:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800323:	b8 00 00 00 00       	mov    $0x0,%eax
  800328:	c3                   	ret    

00800329 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800329:	f3 0f 1e fb          	endbr32 
  80032d:	55                   	push   %ebp
  80032e:	89 e5                	mov    %esp,%ebp
  800330:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800333:	68 f6 2d 80 00       	push   $0x802df6
  800338:	ff 75 0c             	pushl  0xc(%ebp)
  80033b:	e8 31 08 00 00       	call   800b71 <strcpy>
	return 0;
}
  800340:	b8 00 00 00 00       	mov    $0x0,%eax
  800345:	c9                   	leave  
  800346:	c3                   	ret    

00800347 <devcons_write>:
{
  800347:	f3 0f 1e fb          	endbr32 
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
  80034e:	57                   	push   %edi
  80034f:	56                   	push   %esi
  800350:	53                   	push   %ebx
  800351:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800357:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80035c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800362:	3b 75 10             	cmp    0x10(%ebp),%esi
  800365:	73 31                	jae    800398 <devcons_write+0x51>
		m = n - tot;
  800367:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80036a:	29 f3                	sub    %esi,%ebx
  80036c:	83 fb 7f             	cmp    $0x7f,%ebx
  80036f:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800374:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800377:	83 ec 04             	sub    $0x4,%esp
  80037a:	53                   	push   %ebx
  80037b:	89 f0                	mov    %esi,%eax
  80037d:	03 45 0c             	add    0xc(%ebp),%eax
  800380:	50                   	push   %eax
  800381:	57                   	push   %edi
  800382:	e8 a2 09 00 00       	call   800d29 <memmove>
		sys_cputs(buf, m);
  800387:	83 c4 08             	add    $0x8,%esp
  80038a:	53                   	push   %ebx
  80038b:	57                   	push   %edi
  80038c:	e8 9d 0b 00 00       	call   800f2e <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800391:	01 de                	add    %ebx,%esi
  800393:	83 c4 10             	add    $0x10,%esp
  800396:	eb ca                	jmp    800362 <devcons_write+0x1b>
}
  800398:	89 f0                	mov    %esi,%eax
  80039a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80039d:	5b                   	pop    %ebx
  80039e:	5e                   	pop    %esi
  80039f:	5f                   	pop    %edi
  8003a0:	5d                   	pop    %ebp
  8003a1:	c3                   	ret    

008003a2 <devcons_read>:
{
  8003a2:	f3 0f 1e fb          	endbr32 
  8003a6:	55                   	push   %ebp
  8003a7:	89 e5                	mov    %esp,%ebp
  8003a9:	83 ec 08             	sub    $0x8,%esp
  8003ac:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8003b1:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8003b5:	74 21                	je     8003d8 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8003b7:	e8 9c 0b 00 00       	call   800f58 <sys_cgetc>
  8003bc:	85 c0                	test   %eax,%eax
  8003be:	75 07                	jne    8003c7 <devcons_read+0x25>
		sys_yield();
  8003c0:	e8 09 0c 00 00       	call   800fce <sys_yield>
  8003c5:	eb f0                	jmp    8003b7 <devcons_read+0x15>
	if (c < 0)
  8003c7:	78 0f                	js     8003d8 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  8003c9:	83 f8 04             	cmp    $0x4,%eax
  8003cc:	74 0c                	je     8003da <devcons_read+0x38>
	*(char*)vbuf = c;
  8003ce:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003d1:	88 02                	mov    %al,(%edx)
	return 1;
  8003d3:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8003d8:	c9                   	leave  
  8003d9:	c3                   	ret    
		return 0;
  8003da:	b8 00 00 00 00       	mov    $0x0,%eax
  8003df:	eb f7                	jmp    8003d8 <devcons_read+0x36>

008003e1 <cputchar>:
{
  8003e1:	f3 0f 1e fb          	endbr32 
  8003e5:	55                   	push   %ebp
  8003e6:	89 e5                	mov    %esp,%ebp
  8003e8:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8003eb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003ee:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8003f1:	6a 01                	push   $0x1
  8003f3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8003f6:	50                   	push   %eax
  8003f7:	e8 32 0b 00 00       	call   800f2e <sys_cputs>
}
  8003fc:	83 c4 10             	add    $0x10,%esp
  8003ff:	c9                   	leave  
  800400:	c3                   	ret    

00800401 <getchar>:
{
  800401:	f3 0f 1e fb          	endbr32 
  800405:	55                   	push   %ebp
  800406:	89 e5                	mov    %esp,%ebp
  800408:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80040b:	6a 01                	push   $0x1
  80040d:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800410:	50                   	push   %eax
  800411:	6a 00                	push   $0x0
  800413:	e8 6d 15 00 00       	call   801985 <read>
	if (r < 0)
  800418:	83 c4 10             	add    $0x10,%esp
  80041b:	85 c0                	test   %eax,%eax
  80041d:	78 06                	js     800425 <getchar+0x24>
	if (r < 1)
  80041f:	74 06                	je     800427 <getchar+0x26>
	return c;
  800421:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800425:	c9                   	leave  
  800426:	c3                   	ret    
		return -E_EOF;
  800427:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80042c:	eb f7                	jmp    800425 <getchar+0x24>

0080042e <iscons>:
{
  80042e:	f3 0f 1e fb          	endbr32 
  800432:	55                   	push   %ebp
  800433:	89 e5                	mov    %esp,%ebp
  800435:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800438:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80043b:	50                   	push   %eax
  80043c:	ff 75 08             	pushl  0x8(%ebp)
  80043f:	e8 be 12 00 00       	call   801702 <fd_lookup>
  800444:	83 c4 10             	add    $0x10,%esp
  800447:	85 c0                	test   %eax,%eax
  800449:	78 11                	js     80045c <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  80044b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80044e:	8b 15 00 40 80 00    	mov    0x804000,%edx
  800454:	39 10                	cmp    %edx,(%eax)
  800456:	0f 94 c0             	sete   %al
  800459:	0f b6 c0             	movzbl %al,%eax
}
  80045c:	c9                   	leave  
  80045d:	c3                   	ret    

0080045e <opencons>:
{
  80045e:	f3 0f 1e fb          	endbr32 
  800462:	55                   	push   %ebp
  800463:	89 e5                	mov    %esp,%ebp
  800465:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800468:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80046b:	50                   	push   %eax
  80046c:	e8 3b 12 00 00       	call   8016ac <fd_alloc>
  800471:	83 c4 10             	add    $0x10,%esp
  800474:	85 c0                	test   %eax,%eax
  800476:	78 3a                	js     8004b2 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800478:	83 ec 04             	sub    $0x4,%esp
  80047b:	68 07 04 00 00       	push   $0x407
  800480:	ff 75 f4             	pushl  -0xc(%ebp)
  800483:	6a 00                	push   $0x0
  800485:	e8 6f 0b 00 00       	call   800ff9 <sys_page_alloc>
  80048a:	83 c4 10             	add    $0x10,%esp
  80048d:	85 c0                	test   %eax,%eax
  80048f:	78 21                	js     8004b2 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  800491:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800494:	8b 15 00 40 80 00    	mov    0x804000,%edx
  80049a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80049c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80049f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8004a6:	83 ec 0c             	sub    $0xc,%esp
  8004a9:	50                   	push   %eax
  8004aa:	e8 ca 11 00 00       	call   801679 <fd2num>
  8004af:	83 c4 10             	add    $0x10,%esp
}
  8004b2:	c9                   	leave  
  8004b3:	c3                   	ret    

008004b4 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8004b4:	f3 0f 1e fb          	endbr32 
  8004b8:	55                   	push   %ebp
  8004b9:	89 e5                	mov    %esp,%ebp
  8004bb:	56                   	push   %esi
  8004bc:	53                   	push   %ebx
  8004bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8004c0:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8004c3:	e8 de 0a 00 00       	call   800fa6 <sys_getenvid>
	if (id >= 0)
  8004c8:	85 c0                	test   %eax,%eax
  8004ca:	78 12                	js     8004de <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8004cc:	25 ff 03 00 00       	and    $0x3ff,%eax
  8004d1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8004d4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8004d9:	a3 04 50 80 00       	mov    %eax,0x805004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8004de:	85 db                	test   %ebx,%ebx
  8004e0:	7e 07                	jle    8004e9 <libmain+0x35>
		binaryname = argv[0];
  8004e2:	8b 06                	mov    (%esi),%eax
  8004e4:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	56                   	push   %esi
  8004ed:	53                   	push   %ebx
  8004ee:	e8 fe fb ff ff       	call   8000f1 <umain>

	// exit gracefully
	exit();
  8004f3:	e8 0a 00 00 00       	call   800502 <exit>
}
  8004f8:	83 c4 10             	add    $0x10,%esp
  8004fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004fe:	5b                   	pop    %ebx
  8004ff:	5e                   	pop    %esi
  800500:	5d                   	pop    %ebp
  800501:	c3                   	ret    

00800502 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800502:	f3 0f 1e fb          	endbr32 
  800506:	55                   	push   %ebp
  800507:	89 e5                	mov    %esp,%ebp
  800509:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80050c:	e8 5b 13 00 00       	call   80186c <close_all>
	sys_env_destroy(0);
  800511:	83 ec 0c             	sub    $0xc,%esp
  800514:	6a 00                	push   $0x0
  800516:	e8 65 0a 00 00       	call   800f80 <sys_env_destroy>
}
  80051b:	83 c4 10             	add    $0x10,%esp
  80051e:	c9                   	leave  
  80051f:	c3                   	ret    

00800520 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800520:	f3 0f 1e fb          	endbr32 
  800524:	55                   	push   %ebp
  800525:	89 e5                	mov    %esp,%ebp
  800527:	56                   	push   %esi
  800528:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800529:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80052c:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800532:	e8 6f 0a 00 00       	call   800fa6 <sys_getenvid>
  800537:	83 ec 0c             	sub    $0xc,%esp
  80053a:	ff 75 0c             	pushl  0xc(%ebp)
  80053d:	ff 75 08             	pushl  0x8(%ebp)
  800540:	56                   	push   %esi
  800541:	50                   	push   %eax
  800542:	68 0c 2e 80 00       	push   $0x802e0c
  800547:	e8 bb 00 00 00       	call   800607 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80054c:	83 c4 18             	add    $0x18,%esp
  80054f:	53                   	push   %ebx
  800550:	ff 75 10             	pushl  0x10(%ebp)
  800553:	e8 5a 00 00 00       	call   8005b2 <vcprintf>
	cprintf("\n");
  800558:	c7 04 24 38 2d 80 00 	movl   $0x802d38,(%esp)
  80055f:	e8 a3 00 00 00       	call   800607 <cprintf>
  800564:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800567:	cc                   	int3   
  800568:	eb fd                	jmp    800567 <_panic+0x47>

0080056a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80056a:	f3 0f 1e fb          	endbr32 
  80056e:	55                   	push   %ebp
  80056f:	89 e5                	mov    %esp,%ebp
  800571:	53                   	push   %ebx
  800572:	83 ec 04             	sub    $0x4,%esp
  800575:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800578:	8b 13                	mov    (%ebx),%edx
  80057a:	8d 42 01             	lea    0x1(%edx),%eax
  80057d:	89 03                	mov    %eax,(%ebx)
  80057f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800582:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800586:	3d ff 00 00 00       	cmp    $0xff,%eax
  80058b:	74 09                	je     800596 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  80058d:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800591:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800594:	c9                   	leave  
  800595:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800596:	83 ec 08             	sub    $0x8,%esp
  800599:	68 ff 00 00 00       	push   $0xff
  80059e:	8d 43 08             	lea    0x8(%ebx),%eax
  8005a1:	50                   	push   %eax
  8005a2:	e8 87 09 00 00       	call   800f2e <sys_cputs>
		b->idx = 0;
  8005a7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8005ad:	83 c4 10             	add    $0x10,%esp
  8005b0:	eb db                	jmp    80058d <putch+0x23>

008005b2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8005b2:	f3 0f 1e fb          	endbr32 
  8005b6:	55                   	push   %ebp
  8005b7:	89 e5                	mov    %esp,%ebp
  8005b9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8005bf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8005c6:	00 00 00 
	b.cnt = 0;
  8005c9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8005d0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8005d3:	ff 75 0c             	pushl  0xc(%ebp)
  8005d6:	ff 75 08             	pushl  0x8(%ebp)
  8005d9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8005df:	50                   	push   %eax
  8005e0:	68 6a 05 80 00       	push   $0x80056a
  8005e5:	e8 80 01 00 00       	call   80076a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8005ea:	83 c4 08             	add    $0x8,%esp
  8005ed:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8005f3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8005f9:	50                   	push   %eax
  8005fa:	e8 2f 09 00 00       	call   800f2e <sys_cputs>

	return b.cnt;
}
  8005ff:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800605:	c9                   	leave  
  800606:	c3                   	ret    

00800607 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800607:	f3 0f 1e fb          	endbr32 
  80060b:	55                   	push   %ebp
  80060c:	89 e5                	mov    %esp,%ebp
  80060e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800611:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800614:	50                   	push   %eax
  800615:	ff 75 08             	pushl  0x8(%ebp)
  800618:	e8 95 ff ff ff       	call   8005b2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80061d:	c9                   	leave  
  80061e:	c3                   	ret    

0080061f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80061f:	55                   	push   %ebp
  800620:	89 e5                	mov    %esp,%ebp
  800622:	57                   	push   %edi
  800623:	56                   	push   %esi
  800624:	53                   	push   %ebx
  800625:	83 ec 1c             	sub    $0x1c,%esp
  800628:	89 c7                	mov    %eax,%edi
  80062a:	89 d6                	mov    %edx,%esi
  80062c:	8b 45 08             	mov    0x8(%ebp),%eax
  80062f:	8b 55 0c             	mov    0xc(%ebp),%edx
  800632:	89 d1                	mov    %edx,%ecx
  800634:	89 c2                	mov    %eax,%edx
  800636:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800639:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80063c:	8b 45 10             	mov    0x10(%ebp),%eax
  80063f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800642:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800645:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80064c:	39 c2                	cmp    %eax,%edx
  80064e:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800651:	72 3e                	jb     800691 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800653:	83 ec 0c             	sub    $0xc,%esp
  800656:	ff 75 18             	pushl  0x18(%ebp)
  800659:	83 eb 01             	sub    $0x1,%ebx
  80065c:	53                   	push   %ebx
  80065d:	50                   	push   %eax
  80065e:	83 ec 08             	sub    $0x8,%esp
  800661:	ff 75 e4             	pushl  -0x1c(%ebp)
  800664:	ff 75 e0             	pushl  -0x20(%ebp)
  800667:	ff 75 dc             	pushl  -0x24(%ebp)
  80066a:	ff 75 d8             	pushl  -0x28(%ebp)
  80066d:	e8 ee 23 00 00       	call   802a60 <__udivdi3>
  800672:	83 c4 18             	add    $0x18,%esp
  800675:	52                   	push   %edx
  800676:	50                   	push   %eax
  800677:	89 f2                	mov    %esi,%edx
  800679:	89 f8                	mov    %edi,%eax
  80067b:	e8 9f ff ff ff       	call   80061f <printnum>
  800680:	83 c4 20             	add    $0x20,%esp
  800683:	eb 13                	jmp    800698 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800685:	83 ec 08             	sub    $0x8,%esp
  800688:	56                   	push   %esi
  800689:	ff 75 18             	pushl  0x18(%ebp)
  80068c:	ff d7                	call   *%edi
  80068e:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800691:	83 eb 01             	sub    $0x1,%ebx
  800694:	85 db                	test   %ebx,%ebx
  800696:	7f ed                	jg     800685 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800698:	83 ec 08             	sub    $0x8,%esp
  80069b:	56                   	push   %esi
  80069c:	83 ec 04             	sub    $0x4,%esp
  80069f:	ff 75 e4             	pushl  -0x1c(%ebp)
  8006a2:	ff 75 e0             	pushl  -0x20(%ebp)
  8006a5:	ff 75 dc             	pushl  -0x24(%ebp)
  8006a8:	ff 75 d8             	pushl  -0x28(%ebp)
  8006ab:	e8 c0 24 00 00       	call   802b70 <__umoddi3>
  8006b0:	83 c4 14             	add    $0x14,%esp
  8006b3:	0f be 80 2f 2e 80 00 	movsbl 0x802e2f(%eax),%eax
  8006ba:	50                   	push   %eax
  8006bb:	ff d7                	call   *%edi
}
  8006bd:	83 c4 10             	add    $0x10,%esp
  8006c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006c3:	5b                   	pop    %ebx
  8006c4:	5e                   	pop    %esi
  8006c5:	5f                   	pop    %edi
  8006c6:	5d                   	pop    %ebp
  8006c7:	c3                   	ret    

008006c8 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006c8:	83 fa 01             	cmp    $0x1,%edx
  8006cb:	7f 13                	jg     8006e0 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8006cd:	85 d2                	test   %edx,%edx
  8006cf:	74 1c                	je     8006ed <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8006d1:	8b 10                	mov    (%eax),%edx
  8006d3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006d6:	89 08                	mov    %ecx,(%eax)
  8006d8:	8b 02                	mov    (%edx),%eax
  8006da:	ba 00 00 00 00       	mov    $0x0,%edx
  8006df:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8006e0:	8b 10                	mov    (%eax),%edx
  8006e2:	8d 4a 08             	lea    0x8(%edx),%ecx
  8006e5:	89 08                	mov    %ecx,(%eax)
  8006e7:	8b 02                	mov    (%edx),%eax
  8006e9:	8b 52 04             	mov    0x4(%edx),%edx
  8006ec:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8006ed:	8b 10                	mov    (%eax),%edx
  8006ef:	8d 4a 04             	lea    0x4(%edx),%ecx
  8006f2:	89 08                	mov    %ecx,(%eax)
  8006f4:	8b 02                	mov    (%edx),%eax
  8006f6:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8006fb:	c3                   	ret    

008006fc <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8006fc:	83 fa 01             	cmp    $0x1,%edx
  8006ff:	7f 0f                	jg     800710 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800701:	85 d2                	test   %edx,%edx
  800703:	74 18                	je     80071d <getint+0x21>
		return va_arg(*ap, long);
  800705:	8b 10                	mov    (%eax),%edx
  800707:	8d 4a 04             	lea    0x4(%edx),%ecx
  80070a:	89 08                	mov    %ecx,(%eax)
  80070c:	8b 02                	mov    (%edx),%eax
  80070e:	99                   	cltd   
  80070f:	c3                   	ret    
		return va_arg(*ap, long long);
  800710:	8b 10                	mov    (%eax),%edx
  800712:	8d 4a 08             	lea    0x8(%edx),%ecx
  800715:	89 08                	mov    %ecx,(%eax)
  800717:	8b 02                	mov    (%edx),%eax
  800719:	8b 52 04             	mov    0x4(%edx),%edx
  80071c:	c3                   	ret    
	else
		return va_arg(*ap, int);
  80071d:	8b 10                	mov    (%eax),%edx
  80071f:	8d 4a 04             	lea    0x4(%edx),%ecx
  800722:	89 08                	mov    %ecx,(%eax)
  800724:	8b 02                	mov    (%edx),%eax
  800726:	99                   	cltd   
}
  800727:	c3                   	ret    

00800728 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800728:	f3 0f 1e fb          	endbr32 
  80072c:	55                   	push   %ebp
  80072d:	89 e5                	mov    %esp,%ebp
  80072f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800732:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800736:	8b 10                	mov    (%eax),%edx
  800738:	3b 50 04             	cmp    0x4(%eax),%edx
  80073b:	73 0a                	jae    800747 <sprintputch+0x1f>
		*b->buf++ = ch;
  80073d:	8d 4a 01             	lea    0x1(%edx),%ecx
  800740:	89 08                	mov    %ecx,(%eax)
  800742:	8b 45 08             	mov    0x8(%ebp),%eax
  800745:	88 02                	mov    %al,(%edx)
}
  800747:	5d                   	pop    %ebp
  800748:	c3                   	ret    

00800749 <printfmt>:
{
  800749:	f3 0f 1e fb          	endbr32 
  80074d:	55                   	push   %ebp
  80074e:	89 e5                	mov    %esp,%ebp
  800750:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800753:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800756:	50                   	push   %eax
  800757:	ff 75 10             	pushl  0x10(%ebp)
  80075a:	ff 75 0c             	pushl  0xc(%ebp)
  80075d:	ff 75 08             	pushl  0x8(%ebp)
  800760:	e8 05 00 00 00       	call   80076a <vprintfmt>
}
  800765:	83 c4 10             	add    $0x10,%esp
  800768:	c9                   	leave  
  800769:	c3                   	ret    

0080076a <vprintfmt>:
{
  80076a:	f3 0f 1e fb          	endbr32 
  80076e:	55                   	push   %ebp
  80076f:	89 e5                	mov    %esp,%ebp
  800771:	57                   	push   %edi
  800772:	56                   	push   %esi
  800773:	53                   	push   %ebx
  800774:	83 ec 2c             	sub    $0x2c,%esp
  800777:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80077a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80077d:	8b 7d 10             	mov    0x10(%ebp),%edi
  800780:	e9 86 02 00 00       	jmp    800a0b <vprintfmt+0x2a1>
		padc = ' ';
  800785:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800789:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800790:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800797:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  80079e:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8007a3:	8d 47 01             	lea    0x1(%edi),%eax
  8007a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8007a9:	0f b6 17             	movzbl (%edi),%edx
  8007ac:	8d 42 dd             	lea    -0x23(%edx),%eax
  8007af:	3c 55                	cmp    $0x55,%al
  8007b1:	0f 87 df 02 00 00    	ja     800a96 <vprintfmt+0x32c>
  8007b7:	0f b6 c0             	movzbl %al,%eax
  8007ba:	3e ff 24 85 80 2f 80 	notrack jmp *0x802f80(,%eax,4)
  8007c1:	00 
  8007c2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8007c5:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8007c9:	eb d8                	jmp    8007a3 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8007cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007ce:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8007d2:	eb cf                	jmp    8007a3 <vprintfmt+0x39>
  8007d4:	0f b6 d2             	movzbl %dl,%edx
  8007d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8007da:	b8 00 00 00 00       	mov    $0x0,%eax
  8007df:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8007e2:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8007e5:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8007e9:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8007ec:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8007ef:	83 f9 09             	cmp    $0x9,%ecx
  8007f2:	77 52                	ja     800846 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  8007f4:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8007f7:	eb e9                	jmp    8007e2 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8007f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8007fc:	8d 50 04             	lea    0x4(%eax),%edx
  8007ff:	89 55 14             	mov    %edx,0x14(%ebp)
  800802:	8b 00                	mov    (%eax),%eax
  800804:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800807:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80080a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80080e:	79 93                	jns    8007a3 <vprintfmt+0x39>
				width = precision, precision = -1;
  800810:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800813:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800816:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80081d:	eb 84                	jmp    8007a3 <vprintfmt+0x39>
  80081f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800822:	85 c0                	test   %eax,%eax
  800824:	ba 00 00 00 00       	mov    $0x0,%edx
  800829:	0f 49 d0             	cmovns %eax,%edx
  80082c:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80082f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800832:	e9 6c ff ff ff       	jmp    8007a3 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800837:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80083a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800841:	e9 5d ff ff ff       	jmp    8007a3 <vprintfmt+0x39>
  800846:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800849:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80084c:	eb bc                	jmp    80080a <vprintfmt+0xa0>
			lflag++;
  80084e:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800851:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800854:	e9 4a ff ff ff       	jmp    8007a3 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800859:	8b 45 14             	mov    0x14(%ebp),%eax
  80085c:	8d 50 04             	lea    0x4(%eax),%edx
  80085f:	89 55 14             	mov    %edx,0x14(%ebp)
  800862:	83 ec 08             	sub    $0x8,%esp
  800865:	56                   	push   %esi
  800866:	ff 30                	pushl  (%eax)
  800868:	ff d3                	call   *%ebx
			break;
  80086a:	83 c4 10             	add    $0x10,%esp
  80086d:	e9 96 01 00 00       	jmp    800a08 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  800872:	8b 45 14             	mov    0x14(%ebp),%eax
  800875:	8d 50 04             	lea    0x4(%eax),%edx
  800878:	89 55 14             	mov    %edx,0x14(%ebp)
  80087b:	8b 00                	mov    (%eax),%eax
  80087d:	99                   	cltd   
  80087e:	31 d0                	xor    %edx,%eax
  800880:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800882:	83 f8 0f             	cmp    $0xf,%eax
  800885:	7f 20                	jg     8008a7 <vprintfmt+0x13d>
  800887:	8b 14 85 e0 30 80 00 	mov    0x8030e0(,%eax,4),%edx
  80088e:	85 d2                	test   %edx,%edx
  800890:	74 15                	je     8008a7 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  800892:	52                   	push   %edx
  800893:	68 f5 33 80 00       	push   $0x8033f5
  800898:	56                   	push   %esi
  800899:	53                   	push   %ebx
  80089a:	e8 aa fe ff ff       	call   800749 <printfmt>
  80089f:	83 c4 10             	add    $0x10,%esp
  8008a2:	e9 61 01 00 00       	jmp    800a08 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8008a7:	50                   	push   %eax
  8008a8:	68 47 2e 80 00       	push   $0x802e47
  8008ad:	56                   	push   %esi
  8008ae:	53                   	push   %ebx
  8008af:	e8 95 fe ff ff       	call   800749 <printfmt>
  8008b4:	83 c4 10             	add    $0x10,%esp
  8008b7:	e9 4c 01 00 00       	jmp    800a08 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8008bc:	8b 45 14             	mov    0x14(%ebp),%eax
  8008bf:	8d 50 04             	lea    0x4(%eax),%edx
  8008c2:	89 55 14             	mov    %edx,0x14(%ebp)
  8008c5:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8008c7:	85 c9                	test   %ecx,%ecx
  8008c9:	b8 40 2e 80 00       	mov    $0x802e40,%eax
  8008ce:	0f 45 c1             	cmovne %ecx,%eax
  8008d1:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8008d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8008d8:	7e 06                	jle    8008e0 <vprintfmt+0x176>
  8008da:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8008de:	75 0d                	jne    8008ed <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  8008e0:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8008e3:	89 c7                	mov    %eax,%edi
  8008e5:	03 45 e0             	add    -0x20(%ebp),%eax
  8008e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8008eb:	eb 57                	jmp    800944 <vprintfmt+0x1da>
  8008ed:	83 ec 08             	sub    $0x8,%esp
  8008f0:	ff 75 d8             	pushl  -0x28(%ebp)
  8008f3:	ff 75 cc             	pushl  -0x34(%ebp)
  8008f6:	e8 4f 02 00 00       	call   800b4a <strnlen>
  8008fb:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8008fe:	29 c2                	sub    %eax,%edx
  800900:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800903:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800906:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80090a:	89 5d 08             	mov    %ebx,0x8(%ebp)
  80090d:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80090f:	85 db                	test   %ebx,%ebx
  800911:	7e 10                	jle    800923 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800913:	83 ec 08             	sub    $0x8,%esp
  800916:	56                   	push   %esi
  800917:	57                   	push   %edi
  800918:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80091b:	83 eb 01             	sub    $0x1,%ebx
  80091e:	83 c4 10             	add    $0x10,%esp
  800921:	eb ec                	jmp    80090f <vprintfmt+0x1a5>
  800923:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800926:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800929:	85 d2                	test   %edx,%edx
  80092b:	b8 00 00 00 00       	mov    $0x0,%eax
  800930:	0f 49 c2             	cmovns %edx,%eax
  800933:	29 c2                	sub    %eax,%edx
  800935:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800938:	eb a6                	jmp    8008e0 <vprintfmt+0x176>
					putch(ch, putdat);
  80093a:	83 ec 08             	sub    $0x8,%esp
  80093d:	56                   	push   %esi
  80093e:	52                   	push   %edx
  80093f:	ff d3                	call   *%ebx
  800941:	83 c4 10             	add    $0x10,%esp
  800944:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800947:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800949:	83 c7 01             	add    $0x1,%edi
  80094c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800950:	0f be d0             	movsbl %al,%edx
  800953:	85 d2                	test   %edx,%edx
  800955:	74 42                	je     800999 <vprintfmt+0x22f>
  800957:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80095b:	78 06                	js     800963 <vprintfmt+0x1f9>
  80095d:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800961:	78 1e                	js     800981 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  800963:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800967:	74 d1                	je     80093a <vprintfmt+0x1d0>
  800969:	0f be c0             	movsbl %al,%eax
  80096c:	83 e8 20             	sub    $0x20,%eax
  80096f:	83 f8 5e             	cmp    $0x5e,%eax
  800972:	76 c6                	jbe    80093a <vprintfmt+0x1d0>
					putch('?', putdat);
  800974:	83 ec 08             	sub    $0x8,%esp
  800977:	56                   	push   %esi
  800978:	6a 3f                	push   $0x3f
  80097a:	ff d3                	call   *%ebx
  80097c:	83 c4 10             	add    $0x10,%esp
  80097f:	eb c3                	jmp    800944 <vprintfmt+0x1da>
  800981:	89 cf                	mov    %ecx,%edi
  800983:	eb 0e                	jmp    800993 <vprintfmt+0x229>
				putch(' ', putdat);
  800985:	83 ec 08             	sub    $0x8,%esp
  800988:	56                   	push   %esi
  800989:	6a 20                	push   $0x20
  80098b:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  80098d:	83 ef 01             	sub    $0x1,%edi
  800990:	83 c4 10             	add    $0x10,%esp
  800993:	85 ff                	test   %edi,%edi
  800995:	7f ee                	jg     800985 <vprintfmt+0x21b>
  800997:	eb 6f                	jmp    800a08 <vprintfmt+0x29e>
  800999:	89 cf                	mov    %ecx,%edi
  80099b:	eb f6                	jmp    800993 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  80099d:	89 ca                	mov    %ecx,%edx
  80099f:	8d 45 14             	lea    0x14(%ebp),%eax
  8009a2:	e8 55 fd ff ff       	call   8006fc <getint>
  8009a7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8009aa:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8009ad:	85 d2                	test   %edx,%edx
  8009af:	78 0b                	js     8009bc <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8009b1:	89 d1                	mov    %edx,%ecx
  8009b3:	89 c2                	mov    %eax,%edx
			base = 10;
  8009b5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009ba:	eb 32                	jmp    8009ee <vprintfmt+0x284>
				putch('-', putdat);
  8009bc:	83 ec 08             	sub    $0x8,%esp
  8009bf:	56                   	push   %esi
  8009c0:	6a 2d                	push   $0x2d
  8009c2:	ff d3                	call   *%ebx
				num = -(long long) num;
  8009c4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8009c7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8009ca:	f7 da                	neg    %edx
  8009cc:	83 d1 00             	adc    $0x0,%ecx
  8009cf:	f7 d9                	neg    %ecx
  8009d1:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8009d4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8009d9:	eb 13                	jmp    8009ee <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8009db:	89 ca                	mov    %ecx,%edx
  8009dd:	8d 45 14             	lea    0x14(%ebp),%eax
  8009e0:	e8 e3 fc ff ff       	call   8006c8 <getuint>
  8009e5:	89 d1                	mov    %edx,%ecx
  8009e7:	89 c2                	mov    %eax,%edx
			base = 10;
  8009e9:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  8009ee:	83 ec 0c             	sub    $0xc,%esp
  8009f1:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8009f5:	57                   	push   %edi
  8009f6:	ff 75 e0             	pushl  -0x20(%ebp)
  8009f9:	50                   	push   %eax
  8009fa:	51                   	push   %ecx
  8009fb:	52                   	push   %edx
  8009fc:	89 f2                	mov    %esi,%edx
  8009fe:	89 d8                	mov    %ebx,%eax
  800a00:	e8 1a fc ff ff       	call   80061f <printnum>
			break;
  800a05:	83 c4 20             	add    $0x20,%esp
{
  800a08:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800a0b:	83 c7 01             	add    $0x1,%edi
  800a0e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800a12:	83 f8 25             	cmp    $0x25,%eax
  800a15:	0f 84 6a fd ff ff    	je     800785 <vprintfmt+0x1b>
			if (ch == '\0')
  800a1b:	85 c0                	test   %eax,%eax
  800a1d:	0f 84 93 00 00 00    	je     800ab6 <vprintfmt+0x34c>
			putch(ch, putdat);
  800a23:	83 ec 08             	sub    $0x8,%esp
  800a26:	56                   	push   %esi
  800a27:	50                   	push   %eax
  800a28:	ff d3                	call   *%ebx
  800a2a:	83 c4 10             	add    $0x10,%esp
  800a2d:	eb dc                	jmp    800a0b <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  800a2f:	89 ca                	mov    %ecx,%edx
  800a31:	8d 45 14             	lea    0x14(%ebp),%eax
  800a34:	e8 8f fc ff ff       	call   8006c8 <getuint>
  800a39:	89 d1                	mov    %edx,%ecx
  800a3b:	89 c2                	mov    %eax,%edx
			base = 8;
  800a3d:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800a42:	eb aa                	jmp    8009ee <vprintfmt+0x284>
			putch('0', putdat);
  800a44:	83 ec 08             	sub    $0x8,%esp
  800a47:	56                   	push   %esi
  800a48:	6a 30                	push   $0x30
  800a4a:	ff d3                	call   *%ebx
			putch('x', putdat);
  800a4c:	83 c4 08             	add    $0x8,%esp
  800a4f:	56                   	push   %esi
  800a50:	6a 78                	push   $0x78
  800a52:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  800a54:	8b 45 14             	mov    0x14(%ebp),%eax
  800a57:	8d 50 04             	lea    0x4(%eax),%edx
  800a5a:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800a5d:	8b 10                	mov    (%eax),%edx
  800a5f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800a64:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800a67:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800a6c:	eb 80                	jmp    8009ee <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800a6e:	89 ca                	mov    %ecx,%edx
  800a70:	8d 45 14             	lea    0x14(%ebp),%eax
  800a73:	e8 50 fc ff ff       	call   8006c8 <getuint>
  800a78:	89 d1                	mov    %edx,%ecx
  800a7a:	89 c2                	mov    %eax,%edx
			base = 16;
  800a7c:	b8 10 00 00 00       	mov    $0x10,%eax
  800a81:	e9 68 ff ff ff       	jmp    8009ee <vprintfmt+0x284>
			putch(ch, putdat);
  800a86:	83 ec 08             	sub    $0x8,%esp
  800a89:	56                   	push   %esi
  800a8a:	6a 25                	push   $0x25
  800a8c:	ff d3                	call   *%ebx
			break;
  800a8e:	83 c4 10             	add    $0x10,%esp
  800a91:	e9 72 ff ff ff       	jmp    800a08 <vprintfmt+0x29e>
			putch('%', putdat);
  800a96:	83 ec 08             	sub    $0x8,%esp
  800a99:	56                   	push   %esi
  800a9a:	6a 25                	push   $0x25
  800a9c:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800a9e:	83 c4 10             	add    $0x10,%esp
  800aa1:	89 f8                	mov    %edi,%eax
  800aa3:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800aa7:	74 05                	je     800aae <vprintfmt+0x344>
  800aa9:	83 e8 01             	sub    $0x1,%eax
  800aac:	eb f5                	jmp    800aa3 <vprintfmt+0x339>
  800aae:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800ab1:	e9 52 ff ff ff       	jmp    800a08 <vprintfmt+0x29e>
}
  800ab6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ab9:	5b                   	pop    %ebx
  800aba:	5e                   	pop    %esi
  800abb:	5f                   	pop    %edi
  800abc:	5d                   	pop    %ebp
  800abd:	c3                   	ret    

00800abe <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800abe:	f3 0f 1e fb          	endbr32 
  800ac2:	55                   	push   %ebp
  800ac3:	89 e5                	mov    %esp,%ebp
  800ac5:	83 ec 18             	sub    $0x18,%esp
  800ac8:	8b 45 08             	mov    0x8(%ebp),%eax
  800acb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ace:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ad1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800ad5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800ad8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800adf:	85 c0                	test   %eax,%eax
  800ae1:	74 26                	je     800b09 <vsnprintf+0x4b>
  800ae3:	85 d2                	test   %edx,%edx
  800ae5:	7e 22                	jle    800b09 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800ae7:	ff 75 14             	pushl  0x14(%ebp)
  800aea:	ff 75 10             	pushl  0x10(%ebp)
  800aed:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800af0:	50                   	push   %eax
  800af1:	68 28 07 80 00       	push   $0x800728
  800af6:	e8 6f fc ff ff       	call   80076a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800afb:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800afe:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800b04:	83 c4 10             	add    $0x10,%esp
}
  800b07:	c9                   	leave  
  800b08:	c3                   	ret    
		return -E_INVAL;
  800b09:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800b0e:	eb f7                	jmp    800b07 <vsnprintf+0x49>

00800b10 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800b10:	f3 0f 1e fb          	endbr32 
  800b14:	55                   	push   %ebp
  800b15:	89 e5                	mov    %esp,%ebp
  800b17:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800b1a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800b1d:	50                   	push   %eax
  800b1e:	ff 75 10             	pushl  0x10(%ebp)
  800b21:	ff 75 0c             	pushl  0xc(%ebp)
  800b24:	ff 75 08             	pushl  0x8(%ebp)
  800b27:	e8 92 ff ff ff       	call   800abe <vsnprintf>
	va_end(ap);

	return rc;
}
  800b2c:	c9                   	leave  
  800b2d:	c3                   	ret    

00800b2e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800b2e:	f3 0f 1e fb          	endbr32 
  800b32:	55                   	push   %ebp
  800b33:	89 e5                	mov    %esp,%ebp
  800b35:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800b38:	b8 00 00 00 00       	mov    $0x0,%eax
  800b3d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800b41:	74 05                	je     800b48 <strlen+0x1a>
		n++;
  800b43:	83 c0 01             	add    $0x1,%eax
  800b46:	eb f5                	jmp    800b3d <strlen+0xf>
	return n;
}
  800b48:	5d                   	pop    %ebp
  800b49:	c3                   	ret    

00800b4a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800b4a:	f3 0f 1e fb          	endbr32 
  800b4e:	55                   	push   %ebp
  800b4f:	89 e5                	mov    %esp,%ebp
  800b51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b54:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800b57:	b8 00 00 00 00       	mov    $0x0,%eax
  800b5c:	39 d0                	cmp    %edx,%eax
  800b5e:	74 0d                	je     800b6d <strnlen+0x23>
  800b60:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800b64:	74 05                	je     800b6b <strnlen+0x21>
		n++;
  800b66:	83 c0 01             	add    $0x1,%eax
  800b69:	eb f1                	jmp    800b5c <strnlen+0x12>
  800b6b:	89 c2                	mov    %eax,%edx
	return n;
}
  800b6d:	89 d0                	mov    %edx,%eax
  800b6f:	5d                   	pop    %ebp
  800b70:	c3                   	ret    

00800b71 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800b71:	f3 0f 1e fb          	endbr32 
  800b75:	55                   	push   %ebp
  800b76:	89 e5                	mov    %esp,%ebp
  800b78:	53                   	push   %ebx
  800b79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b7c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800b7f:	b8 00 00 00 00       	mov    $0x0,%eax
  800b84:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800b88:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800b8b:	83 c0 01             	add    $0x1,%eax
  800b8e:	84 d2                	test   %dl,%dl
  800b90:	75 f2                	jne    800b84 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800b92:	89 c8                	mov    %ecx,%eax
  800b94:	5b                   	pop    %ebx
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800b97:	f3 0f 1e fb          	endbr32 
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	53                   	push   %ebx
  800b9f:	83 ec 10             	sub    $0x10,%esp
  800ba2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ba5:	53                   	push   %ebx
  800ba6:	e8 83 ff ff ff       	call   800b2e <strlen>
  800bab:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800bae:	ff 75 0c             	pushl  0xc(%ebp)
  800bb1:	01 d8                	add    %ebx,%eax
  800bb3:	50                   	push   %eax
  800bb4:	e8 b8 ff ff ff       	call   800b71 <strcpy>
	return dst;
}
  800bb9:	89 d8                	mov    %ebx,%eax
  800bbb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bbe:	c9                   	leave  
  800bbf:	c3                   	ret    

00800bc0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800bc0:	f3 0f 1e fb          	endbr32 
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	56                   	push   %esi
  800bc8:	53                   	push   %ebx
  800bc9:	8b 75 08             	mov    0x8(%ebp),%esi
  800bcc:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bcf:	89 f3                	mov    %esi,%ebx
  800bd1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800bd4:	89 f0                	mov    %esi,%eax
  800bd6:	39 d8                	cmp    %ebx,%eax
  800bd8:	74 11                	je     800beb <strncpy+0x2b>
		*dst++ = *src;
  800bda:	83 c0 01             	add    $0x1,%eax
  800bdd:	0f b6 0a             	movzbl (%edx),%ecx
  800be0:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800be3:	80 f9 01             	cmp    $0x1,%cl
  800be6:	83 da ff             	sbb    $0xffffffff,%edx
  800be9:	eb eb                	jmp    800bd6 <strncpy+0x16>
	}
	return ret;
}
  800beb:	89 f0                	mov    %esi,%eax
  800bed:	5b                   	pop    %ebx
  800bee:	5e                   	pop    %esi
  800bef:	5d                   	pop    %ebp
  800bf0:	c3                   	ret    

00800bf1 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800bf1:	f3 0f 1e fb          	endbr32 
  800bf5:	55                   	push   %ebp
  800bf6:	89 e5                	mov    %esp,%ebp
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	8b 75 08             	mov    0x8(%ebp),%esi
  800bfd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c00:	8b 55 10             	mov    0x10(%ebp),%edx
  800c03:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800c05:	85 d2                	test   %edx,%edx
  800c07:	74 21                	je     800c2a <strlcpy+0x39>
  800c09:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800c0d:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800c0f:	39 c2                	cmp    %eax,%edx
  800c11:	74 14                	je     800c27 <strlcpy+0x36>
  800c13:	0f b6 19             	movzbl (%ecx),%ebx
  800c16:	84 db                	test   %bl,%bl
  800c18:	74 0b                	je     800c25 <strlcpy+0x34>
			*dst++ = *src++;
  800c1a:	83 c1 01             	add    $0x1,%ecx
  800c1d:	83 c2 01             	add    $0x1,%edx
  800c20:	88 5a ff             	mov    %bl,-0x1(%edx)
  800c23:	eb ea                	jmp    800c0f <strlcpy+0x1e>
  800c25:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800c27:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800c2a:	29 f0                	sub    %esi,%eax
}
  800c2c:	5b                   	pop    %ebx
  800c2d:	5e                   	pop    %esi
  800c2e:	5d                   	pop    %ebp
  800c2f:	c3                   	ret    

00800c30 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800c30:	f3 0f 1e fb          	endbr32 
  800c34:	55                   	push   %ebp
  800c35:	89 e5                	mov    %esp,%ebp
  800c37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c3a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800c3d:	0f b6 01             	movzbl (%ecx),%eax
  800c40:	84 c0                	test   %al,%al
  800c42:	74 0c                	je     800c50 <strcmp+0x20>
  800c44:	3a 02                	cmp    (%edx),%al
  800c46:	75 08                	jne    800c50 <strcmp+0x20>
		p++, q++;
  800c48:	83 c1 01             	add    $0x1,%ecx
  800c4b:	83 c2 01             	add    $0x1,%edx
  800c4e:	eb ed                	jmp    800c3d <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800c50:	0f b6 c0             	movzbl %al,%eax
  800c53:	0f b6 12             	movzbl (%edx),%edx
  800c56:	29 d0                	sub    %edx,%eax
}
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800c5a:	f3 0f 1e fb          	endbr32 
  800c5e:	55                   	push   %ebp
  800c5f:	89 e5                	mov    %esp,%ebp
  800c61:	53                   	push   %ebx
  800c62:	8b 45 08             	mov    0x8(%ebp),%eax
  800c65:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c68:	89 c3                	mov    %eax,%ebx
  800c6a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800c6d:	eb 06                	jmp    800c75 <strncmp+0x1b>
		n--, p++, q++;
  800c6f:	83 c0 01             	add    $0x1,%eax
  800c72:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800c75:	39 d8                	cmp    %ebx,%eax
  800c77:	74 16                	je     800c8f <strncmp+0x35>
  800c79:	0f b6 08             	movzbl (%eax),%ecx
  800c7c:	84 c9                	test   %cl,%cl
  800c7e:	74 04                	je     800c84 <strncmp+0x2a>
  800c80:	3a 0a                	cmp    (%edx),%cl
  800c82:	74 eb                	je     800c6f <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800c84:	0f b6 00             	movzbl (%eax),%eax
  800c87:	0f b6 12             	movzbl (%edx),%edx
  800c8a:	29 d0                	sub    %edx,%eax
}
  800c8c:	5b                   	pop    %ebx
  800c8d:	5d                   	pop    %ebp
  800c8e:	c3                   	ret    
		return 0;
  800c8f:	b8 00 00 00 00       	mov    $0x0,%eax
  800c94:	eb f6                	jmp    800c8c <strncmp+0x32>

00800c96 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800c96:	f3 0f 1e fb          	endbr32 
  800c9a:	55                   	push   %ebp
  800c9b:	89 e5                	mov    %esp,%ebp
  800c9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800ca4:	0f b6 10             	movzbl (%eax),%edx
  800ca7:	84 d2                	test   %dl,%dl
  800ca9:	74 09                	je     800cb4 <strchr+0x1e>
		if (*s == c)
  800cab:	38 ca                	cmp    %cl,%dl
  800cad:	74 0a                	je     800cb9 <strchr+0x23>
	for (; *s; s++)
  800caf:	83 c0 01             	add    $0x1,%eax
  800cb2:	eb f0                	jmp    800ca4 <strchr+0xe>
			return (char *) s;
	return 0;
  800cb4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cb9:	5d                   	pop    %ebp
  800cba:	c3                   	ret    

00800cbb <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800cbb:	f3 0f 1e fb          	endbr32 
  800cbf:	55                   	push   %ebp
  800cc0:	89 e5                	mov    %esp,%ebp
  800cc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800cc9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ccc:	38 ca                	cmp    %cl,%dl
  800cce:	74 09                	je     800cd9 <strfind+0x1e>
  800cd0:	84 d2                	test   %dl,%dl
  800cd2:	74 05                	je     800cd9 <strfind+0x1e>
	for (; *s; s++)
  800cd4:	83 c0 01             	add    $0x1,%eax
  800cd7:	eb f0                	jmp    800cc9 <strfind+0xe>
			break;
	return (char *) s;
}
  800cd9:	5d                   	pop    %ebp
  800cda:	c3                   	ret    

00800cdb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800cdb:	f3 0f 1e fb          	endbr32 
  800cdf:	55                   	push   %ebp
  800ce0:	89 e5                	mov    %esp,%ebp
  800ce2:	57                   	push   %edi
  800ce3:	56                   	push   %esi
  800ce4:	53                   	push   %ebx
  800ce5:	8b 55 08             	mov    0x8(%ebp),%edx
  800ce8:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800ceb:	85 c9                	test   %ecx,%ecx
  800ced:	74 33                	je     800d22 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800cef:	89 d0                	mov    %edx,%eax
  800cf1:	09 c8                	or     %ecx,%eax
  800cf3:	a8 03                	test   $0x3,%al
  800cf5:	75 23                	jne    800d1a <memset+0x3f>
		c &= 0xFF;
  800cf7:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800cfb:	89 d8                	mov    %ebx,%eax
  800cfd:	c1 e0 08             	shl    $0x8,%eax
  800d00:	89 df                	mov    %ebx,%edi
  800d02:	c1 e7 18             	shl    $0x18,%edi
  800d05:	89 de                	mov    %ebx,%esi
  800d07:	c1 e6 10             	shl    $0x10,%esi
  800d0a:	09 f7                	or     %esi,%edi
  800d0c:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800d0e:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800d11:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800d13:	89 d7                	mov    %edx,%edi
  800d15:	fc                   	cld    
  800d16:	f3 ab                	rep stos %eax,%es:(%edi)
  800d18:	eb 08                	jmp    800d22 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800d1a:	89 d7                	mov    %edx,%edi
  800d1c:	8b 45 0c             	mov    0xc(%ebp),%eax
  800d1f:	fc                   	cld    
  800d20:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800d22:	89 d0                	mov    %edx,%eax
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800d29:	f3 0f 1e fb          	endbr32 
  800d2d:	55                   	push   %ebp
  800d2e:	89 e5                	mov    %esp,%ebp
  800d30:	57                   	push   %edi
  800d31:	56                   	push   %esi
  800d32:	8b 45 08             	mov    0x8(%ebp),%eax
  800d35:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d38:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800d3b:	39 c6                	cmp    %eax,%esi
  800d3d:	73 32                	jae    800d71 <memmove+0x48>
  800d3f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800d42:	39 c2                	cmp    %eax,%edx
  800d44:	76 2b                	jbe    800d71 <memmove+0x48>
		s += n;
		d += n;
  800d46:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d49:	89 fe                	mov    %edi,%esi
  800d4b:	09 ce                	or     %ecx,%esi
  800d4d:	09 d6                	or     %edx,%esi
  800d4f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800d55:	75 0e                	jne    800d65 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800d57:	83 ef 04             	sub    $0x4,%edi
  800d5a:	8d 72 fc             	lea    -0x4(%edx),%esi
  800d5d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800d60:	fd                   	std    
  800d61:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d63:	eb 09                	jmp    800d6e <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800d65:	83 ef 01             	sub    $0x1,%edi
  800d68:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800d6b:	fd                   	std    
  800d6c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800d6e:	fc                   	cld    
  800d6f:	eb 1a                	jmp    800d8b <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800d71:	89 c2                	mov    %eax,%edx
  800d73:	09 ca                	or     %ecx,%edx
  800d75:	09 f2                	or     %esi,%edx
  800d77:	f6 c2 03             	test   $0x3,%dl
  800d7a:	75 0a                	jne    800d86 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800d7c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800d7f:	89 c7                	mov    %eax,%edi
  800d81:	fc                   	cld    
  800d82:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800d84:	eb 05                	jmp    800d8b <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800d86:	89 c7                	mov    %eax,%edi
  800d88:	fc                   	cld    
  800d89:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800d8b:	5e                   	pop    %esi
  800d8c:	5f                   	pop    %edi
  800d8d:	5d                   	pop    %ebp
  800d8e:	c3                   	ret    

00800d8f <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800d8f:	f3 0f 1e fb          	endbr32 
  800d93:	55                   	push   %ebp
  800d94:	89 e5                	mov    %esp,%ebp
  800d96:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800d99:	ff 75 10             	pushl  0x10(%ebp)
  800d9c:	ff 75 0c             	pushl  0xc(%ebp)
  800d9f:	ff 75 08             	pushl  0x8(%ebp)
  800da2:	e8 82 ff ff ff       	call   800d29 <memmove>
}
  800da7:	c9                   	leave  
  800da8:	c3                   	ret    

00800da9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800da9:	f3 0f 1e fb          	endbr32 
  800dad:	55                   	push   %ebp
  800dae:	89 e5                	mov    %esp,%ebp
  800db0:	56                   	push   %esi
  800db1:	53                   	push   %ebx
  800db2:	8b 45 08             	mov    0x8(%ebp),%eax
  800db5:	8b 55 0c             	mov    0xc(%ebp),%edx
  800db8:	89 c6                	mov    %eax,%esi
  800dba:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800dbd:	39 f0                	cmp    %esi,%eax
  800dbf:	74 1c                	je     800ddd <memcmp+0x34>
		if (*s1 != *s2)
  800dc1:	0f b6 08             	movzbl (%eax),%ecx
  800dc4:	0f b6 1a             	movzbl (%edx),%ebx
  800dc7:	38 d9                	cmp    %bl,%cl
  800dc9:	75 08                	jne    800dd3 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800dcb:	83 c0 01             	add    $0x1,%eax
  800dce:	83 c2 01             	add    $0x1,%edx
  800dd1:	eb ea                	jmp    800dbd <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800dd3:	0f b6 c1             	movzbl %cl,%eax
  800dd6:	0f b6 db             	movzbl %bl,%ebx
  800dd9:	29 d8                	sub    %ebx,%eax
  800ddb:	eb 05                	jmp    800de2 <memcmp+0x39>
	}

	return 0;
  800ddd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800de2:	5b                   	pop    %ebx
  800de3:	5e                   	pop    %esi
  800de4:	5d                   	pop    %ebp
  800de5:	c3                   	ret    

00800de6 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800de6:	f3 0f 1e fb          	endbr32 
  800dea:	55                   	push   %ebp
  800deb:	89 e5                	mov    %esp,%ebp
  800ded:	8b 45 08             	mov    0x8(%ebp),%eax
  800df0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800df3:	89 c2                	mov    %eax,%edx
  800df5:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800df8:	39 d0                	cmp    %edx,%eax
  800dfa:	73 09                	jae    800e05 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800dfc:	38 08                	cmp    %cl,(%eax)
  800dfe:	74 05                	je     800e05 <memfind+0x1f>
	for (; s < ends; s++)
  800e00:	83 c0 01             	add    $0x1,%eax
  800e03:	eb f3                	jmp    800df8 <memfind+0x12>
			break;
	return (void *) s;
}
  800e05:	5d                   	pop    %ebp
  800e06:	c3                   	ret    

00800e07 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800e07:	f3 0f 1e fb          	endbr32 
  800e0b:	55                   	push   %ebp
  800e0c:	89 e5                	mov    %esp,%ebp
  800e0e:	57                   	push   %edi
  800e0f:	56                   	push   %esi
  800e10:	53                   	push   %ebx
  800e11:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e14:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800e17:	eb 03                	jmp    800e1c <strtol+0x15>
		s++;
  800e19:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800e1c:	0f b6 01             	movzbl (%ecx),%eax
  800e1f:	3c 20                	cmp    $0x20,%al
  800e21:	74 f6                	je     800e19 <strtol+0x12>
  800e23:	3c 09                	cmp    $0x9,%al
  800e25:	74 f2                	je     800e19 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800e27:	3c 2b                	cmp    $0x2b,%al
  800e29:	74 2a                	je     800e55 <strtol+0x4e>
	int neg = 0;
  800e2b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800e30:	3c 2d                	cmp    $0x2d,%al
  800e32:	74 2b                	je     800e5f <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e34:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800e3a:	75 0f                	jne    800e4b <strtol+0x44>
  800e3c:	80 39 30             	cmpb   $0x30,(%ecx)
  800e3f:	74 28                	je     800e69 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800e41:	85 db                	test   %ebx,%ebx
  800e43:	b8 0a 00 00 00       	mov    $0xa,%eax
  800e48:	0f 44 d8             	cmove  %eax,%ebx
  800e4b:	b8 00 00 00 00       	mov    $0x0,%eax
  800e50:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800e53:	eb 46                	jmp    800e9b <strtol+0x94>
		s++;
  800e55:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800e58:	bf 00 00 00 00       	mov    $0x0,%edi
  800e5d:	eb d5                	jmp    800e34 <strtol+0x2d>
		s++, neg = 1;
  800e5f:	83 c1 01             	add    $0x1,%ecx
  800e62:	bf 01 00 00 00       	mov    $0x1,%edi
  800e67:	eb cb                	jmp    800e34 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800e69:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800e6d:	74 0e                	je     800e7d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800e6f:	85 db                	test   %ebx,%ebx
  800e71:	75 d8                	jne    800e4b <strtol+0x44>
		s++, base = 8;
  800e73:	83 c1 01             	add    $0x1,%ecx
  800e76:	bb 08 00 00 00       	mov    $0x8,%ebx
  800e7b:	eb ce                	jmp    800e4b <strtol+0x44>
		s += 2, base = 16;
  800e7d:	83 c1 02             	add    $0x2,%ecx
  800e80:	bb 10 00 00 00       	mov    $0x10,%ebx
  800e85:	eb c4                	jmp    800e4b <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800e87:	0f be d2             	movsbl %dl,%edx
  800e8a:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800e8d:	3b 55 10             	cmp    0x10(%ebp),%edx
  800e90:	7d 3a                	jge    800ecc <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800e92:	83 c1 01             	add    $0x1,%ecx
  800e95:	0f af 45 10          	imul   0x10(%ebp),%eax
  800e99:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800e9b:	0f b6 11             	movzbl (%ecx),%edx
  800e9e:	8d 72 d0             	lea    -0x30(%edx),%esi
  800ea1:	89 f3                	mov    %esi,%ebx
  800ea3:	80 fb 09             	cmp    $0x9,%bl
  800ea6:	76 df                	jbe    800e87 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800ea8:	8d 72 9f             	lea    -0x61(%edx),%esi
  800eab:	89 f3                	mov    %esi,%ebx
  800ead:	80 fb 19             	cmp    $0x19,%bl
  800eb0:	77 08                	ja     800eba <strtol+0xb3>
			dig = *s - 'a' + 10;
  800eb2:	0f be d2             	movsbl %dl,%edx
  800eb5:	83 ea 57             	sub    $0x57,%edx
  800eb8:	eb d3                	jmp    800e8d <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800eba:	8d 72 bf             	lea    -0x41(%edx),%esi
  800ebd:	89 f3                	mov    %esi,%ebx
  800ebf:	80 fb 19             	cmp    $0x19,%bl
  800ec2:	77 08                	ja     800ecc <strtol+0xc5>
			dig = *s - 'A' + 10;
  800ec4:	0f be d2             	movsbl %dl,%edx
  800ec7:	83 ea 37             	sub    $0x37,%edx
  800eca:	eb c1                	jmp    800e8d <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800ecc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ed0:	74 05                	je     800ed7 <strtol+0xd0>
		*endptr = (char *) s;
  800ed2:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ed5:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800ed7:	89 c2                	mov    %eax,%edx
  800ed9:	f7 da                	neg    %edx
  800edb:	85 ff                	test   %edi,%edi
  800edd:	0f 45 c2             	cmovne %edx,%eax
}
  800ee0:	5b                   	pop    %ebx
  800ee1:	5e                   	pop    %esi
  800ee2:	5f                   	pop    %edi
  800ee3:	5d                   	pop    %ebp
  800ee4:	c3                   	ret    

00800ee5 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800ee5:	55                   	push   %ebp
  800ee6:	89 e5                	mov    %esp,%ebp
  800ee8:	57                   	push   %edi
  800ee9:	56                   	push   %esi
  800eea:	53                   	push   %ebx
  800eeb:	83 ec 1c             	sub    $0x1c,%esp
  800eee:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ef1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800ef4:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800ef6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800efc:	8b 7d 10             	mov    0x10(%ebp),%edi
  800eff:	8b 75 14             	mov    0x14(%ebp),%esi
  800f02:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800f04:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800f08:	74 04                	je     800f0e <syscall+0x29>
  800f0a:	85 c0                	test   %eax,%eax
  800f0c:	7f 08                	jg     800f16 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800f0e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f11:	5b                   	pop    %ebx
  800f12:	5e                   	pop    %esi
  800f13:	5f                   	pop    %edi
  800f14:	5d                   	pop    %ebp
  800f15:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800f16:	83 ec 0c             	sub    $0xc,%esp
  800f19:	50                   	push   %eax
  800f1a:	ff 75 e0             	pushl  -0x20(%ebp)
  800f1d:	68 3f 31 80 00       	push   $0x80313f
  800f22:	6a 23                	push   $0x23
  800f24:	68 5c 31 80 00       	push   $0x80315c
  800f29:	e8 f2 f5 ff ff       	call   800520 <_panic>

00800f2e <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800f2e:	f3 0f 1e fb          	endbr32 
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800f38:	6a 00                	push   $0x0
  800f3a:	6a 00                	push   $0x0
  800f3c:	6a 00                	push   $0x0
  800f3e:	ff 75 0c             	pushl  0xc(%ebp)
  800f41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f44:	ba 00 00 00 00       	mov    $0x0,%edx
  800f49:	b8 00 00 00 00       	mov    $0x0,%eax
  800f4e:	e8 92 ff ff ff       	call   800ee5 <syscall>
}
  800f53:	83 c4 10             	add    $0x10,%esp
  800f56:	c9                   	leave  
  800f57:	c3                   	ret    

00800f58 <sys_cgetc>:

int
sys_cgetc(void)
{
  800f58:	f3 0f 1e fb          	endbr32 
  800f5c:	55                   	push   %ebp
  800f5d:	89 e5                	mov    %esp,%ebp
  800f5f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800f62:	6a 00                	push   $0x0
  800f64:	6a 00                	push   $0x0
  800f66:	6a 00                	push   $0x0
  800f68:	6a 00                	push   $0x0
  800f6a:	b9 00 00 00 00       	mov    $0x0,%ecx
  800f6f:	ba 00 00 00 00       	mov    $0x0,%edx
  800f74:	b8 01 00 00 00       	mov    $0x1,%eax
  800f79:	e8 67 ff ff ff       	call   800ee5 <syscall>
}
  800f7e:	c9                   	leave  
  800f7f:	c3                   	ret    

00800f80 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800f80:	f3 0f 1e fb          	endbr32 
  800f84:	55                   	push   %ebp
  800f85:	89 e5                	mov    %esp,%ebp
  800f87:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800f8a:	6a 00                	push   $0x0
  800f8c:	6a 00                	push   $0x0
  800f8e:	6a 00                	push   $0x0
  800f90:	6a 00                	push   $0x0
  800f92:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f95:	ba 01 00 00 00       	mov    $0x1,%edx
  800f9a:	b8 03 00 00 00       	mov    $0x3,%eax
  800f9f:	e8 41 ff ff ff       	call   800ee5 <syscall>
}
  800fa4:	c9                   	leave  
  800fa5:	c3                   	ret    

00800fa6 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800fa6:	f3 0f 1e fb          	endbr32 
  800faa:	55                   	push   %ebp
  800fab:	89 e5                	mov    %esp,%ebp
  800fad:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800fb0:	6a 00                	push   $0x0
  800fb2:	6a 00                	push   $0x0
  800fb4:	6a 00                	push   $0x0
  800fb6:	6a 00                	push   $0x0
  800fb8:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc2:	b8 02 00 00 00       	mov    $0x2,%eax
  800fc7:	e8 19 ff ff ff       	call   800ee5 <syscall>
}
  800fcc:	c9                   	leave  
  800fcd:	c3                   	ret    

00800fce <sys_yield>:

void
sys_yield(void)
{
  800fce:	f3 0f 1e fb          	endbr32 
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800fd8:	6a 00                	push   $0x0
  800fda:	6a 00                	push   $0x0
  800fdc:	6a 00                	push   $0x0
  800fde:	6a 00                	push   $0x0
  800fe0:	b9 00 00 00 00       	mov    $0x0,%ecx
  800fe5:	ba 00 00 00 00       	mov    $0x0,%edx
  800fea:	b8 0b 00 00 00       	mov    $0xb,%eax
  800fef:	e8 f1 fe ff ff       	call   800ee5 <syscall>
}
  800ff4:	83 c4 10             	add    $0x10,%esp
  800ff7:	c9                   	leave  
  800ff8:	c3                   	ret    

00800ff9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800ff9:	f3 0f 1e fb          	endbr32 
  800ffd:	55                   	push   %ebp
  800ffe:	89 e5                	mov    %esp,%ebp
  801000:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  801003:	6a 00                	push   $0x0
  801005:	6a 00                	push   $0x0
  801007:	ff 75 10             	pushl  0x10(%ebp)
  80100a:	ff 75 0c             	pushl  0xc(%ebp)
  80100d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801010:	ba 01 00 00 00       	mov    $0x1,%edx
  801015:	b8 04 00 00 00       	mov    $0x4,%eax
  80101a:	e8 c6 fe ff ff       	call   800ee5 <syscall>
}
  80101f:	c9                   	leave  
  801020:	c3                   	ret    

00801021 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801021:	f3 0f 1e fb          	endbr32 
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
  801028:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  80102b:	ff 75 18             	pushl  0x18(%ebp)
  80102e:	ff 75 14             	pushl  0x14(%ebp)
  801031:	ff 75 10             	pushl  0x10(%ebp)
  801034:	ff 75 0c             	pushl  0xc(%ebp)
  801037:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80103a:	ba 01 00 00 00       	mov    $0x1,%edx
  80103f:	b8 05 00 00 00       	mov    $0x5,%eax
  801044:	e8 9c fe ff ff       	call   800ee5 <syscall>
}
  801049:	c9                   	leave  
  80104a:	c3                   	ret    

0080104b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80104b:	f3 0f 1e fb          	endbr32 
  80104f:	55                   	push   %ebp
  801050:	89 e5                	mov    %esp,%ebp
  801052:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  801055:	6a 00                	push   $0x0
  801057:	6a 00                	push   $0x0
  801059:	6a 00                	push   $0x0
  80105b:	ff 75 0c             	pushl  0xc(%ebp)
  80105e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801061:	ba 01 00 00 00       	mov    $0x1,%edx
  801066:	b8 06 00 00 00       	mov    $0x6,%eax
  80106b:	e8 75 fe ff ff       	call   800ee5 <syscall>
}
  801070:	c9                   	leave  
  801071:	c3                   	ret    

00801072 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801072:	f3 0f 1e fb          	endbr32 
  801076:	55                   	push   %ebp
  801077:	89 e5                	mov    %esp,%ebp
  801079:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80107c:	6a 00                	push   $0x0
  80107e:	6a 00                	push   $0x0
  801080:	6a 00                	push   $0x0
  801082:	ff 75 0c             	pushl  0xc(%ebp)
  801085:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801088:	ba 01 00 00 00       	mov    $0x1,%edx
  80108d:	b8 08 00 00 00       	mov    $0x8,%eax
  801092:	e8 4e fe ff ff       	call   800ee5 <syscall>
}
  801097:	c9                   	leave  
  801098:	c3                   	ret    

00801099 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  801099:	f3 0f 1e fb          	endbr32 
  80109d:	55                   	push   %ebp
  80109e:	89 e5                	mov    %esp,%ebp
  8010a0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  8010a3:	6a 00                	push   $0x0
  8010a5:	6a 00                	push   $0x0
  8010a7:	6a 00                	push   $0x0
  8010a9:	ff 75 0c             	pushl  0xc(%ebp)
  8010ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010af:	ba 01 00 00 00       	mov    $0x1,%edx
  8010b4:	b8 09 00 00 00       	mov    $0x9,%eax
  8010b9:	e8 27 fe ff ff       	call   800ee5 <syscall>
}
  8010be:	c9                   	leave  
  8010bf:	c3                   	ret    

008010c0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8010c0:	f3 0f 1e fb          	endbr32 
  8010c4:	55                   	push   %ebp
  8010c5:	89 e5                	mov    %esp,%ebp
  8010c7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8010ca:	6a 00                	push   $0x0
  8010cc:	6a 00                	push   $0x0
  8010ce:	6a 00                	push   $0x0
  8010d0:	ff 75 0c             	pushl  0xc(%ebp)
  8010d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d6:	ba 01 00 00 00       	mov    $0x1,%edx
  8010db:	b8 0a 00 00 00       	mov    $0xa,%eax
  8010e0:	e8 00 fe ff ff       	call   800ee5 <syscall>
}
  8010e5:	c9                   	leave  
  8010e6:	c3                   	ret    

008010e7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8010e7:	f3 0f 1e fb          	endbr32 
  8010eb:	55                   	push   %ebp
  8010ec:	89 e5                	mov    %esp,%ebp
  8010ee:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8010f1:	6a 00                	push   $0x0
  8010f3:	ff 75 14             	pushl  0x14(%ebp)
  8010f6:	ff 75 10             	pushl  0x10(%ebp)
  8010f9:	ff 75 0c             	pushl  0xc(%ebp)
  8010fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ff:	ba 00 00 00 00       	mov    $0x0,%edx
  801104:	b8 0c 00 00 00       	mov    $0xc,%eax
  801109:	e8 d7 fd ff ff       	call   800ee5 <syscall>
}
  80110e:	c9                   	leave  
  80110f:	c3                   	ret    

00801110 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801110:	f3 0f 1e fb          	endbr32 
  801114:	55                   	push   %ebp
  801115:	89 e5                	mov    %esp,%ebp
  801117:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80111a:	6a 00                	push   $0x0
  80111c:	6a 00                	push   $0x0
  80111e:	6a 00                	push   $0x0
  801120:	6a 00                	push   $0x0
  801122:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801125:	ba 01 00 00 00       	mov    $0x1,%edx
  80112a:	b8 0d 00 00 00       	mov    $0xd,%eax
  80112f:	e8 b1 fd ff ff       	call   800ee5 <syscall>
}
  801134:	c9                   	leave  
  801135:	c3                   	ret    

00801136 <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  801136:	55                   	push   %ebp
  801137:	89 e5                	mov    %esp,%ebp
  801139:	53                   	push   %ebx
  80113a:	83 ec 04             	sub    $0x4,%esp
  80113d:	89 d3                	mov    %edx,%ebx
	int r;

	// LAB 4: Your code here.

	// Page Table Entry
	pte_t pt_e = uvpt[pn];
  80113f:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Obtenemos la virtual address
	void *v_add = (void *) (pn << PTXSHIFT);
  801146:	c1 e3 0c             	shl    $0xc,%ebx

	if (pt_e & PTE_SHARE) {
  801149:	f6 c6 04             	test   $0x4,%dh
  80114c:	75 54                	jne    8011a2 <duppage+0x6c>
		// Permisos compartidos
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
		if (r < 0)
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	} else if ((pt_e & PTE_W) || (pt_e & PTE_COW)) {
  80114e:	f7 c2 02 08 00 00    	test   $0x802,%edx
  801154:	0f 84 8d 00 00 00    	je     8011e7 <duppage+0xb1>
		// Copy on write
		r = sys_page_map(0, v_add, envid, v_add, PTE_COW | PTE_U | PTE_P);
  80115a:	83 ec 0c             	sub    $0xc,%esp
  80115d:	68 05 08 00 00       	push   $0x805
  801162:	53                   	push   %ebx
  801163:	50                   	push   %eax
  801164:	53                   	push   %ebx
  801165:	6a 00                	push   $0x0
  801167:	e8 b5 fe ff ff       	call   801021 <sys_page_map>
		if (r < 0)
  80116c:	83 c4 20             	add    $0x20,%esp
  80116f:	85 c0                	test   %eax,%eax
  801171:	78 5f                	js     8011d2 <duppage+0x9c>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);

		r = sys_page_map(0, v_add, 0, v_add, PTE_COW | PTE_U | PTE_P);
  801173:	83 ec 0c             	sub    $0xc,%esp
  801176:	68 05 08 00 00       	push   $0x805
  80117b:	53                   	push   %ebx
  80117c:	6a 00                	push   $0x0
  80117e:	53                   	push   %ebx
  80117f:	6a 00                	push   $0x0
  801181:	e8 9b fe ff ff       	call   801021 <sys_page_map>
		if (r < 0)
  801186:	83 c4 20             	add    $0x20,%esp
  801189:	85 c0                	test   %eax,%eax
  80118b:	79 70                	jns    8011fd <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  80118d:	50                   	push   %eax
  80118e:	68 6c 31 80 00       	push   $0x80316c
  801193:	68 9b 00 00 00       	push   $0x9b
  801198:	68 da 32 80 00       	push   $0x8032da
  80119d:	e8 7e f3 ff ff       	call   800520 <_panic>
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
  8011a2:	83 ec 0c             	sub    $0xc,%esp
  8011a5:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  8011ab:	52                   	push   %edx
  8011ac:	53                   	push   %ebx
  8011ad:	50                   	push   %eax
  8011ae:	53                   	push   %ebx
  8011af:	6a 00                	push   $0x0
  8011b1:	e8 6b fe ff ff       	call   801021 <sys_page_map>
		if (r < 0)
  8011b6:	83 c4 20             	add    $0x20,%esp
  8011b9:	85 c0                	test   %eax,%eax
  8011bb:	79 40                	jns    8011fd <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  8011bd:	50                   	push   %eax
  8011be:	68 6c 31 80 00       	push   $0x80316c
  8011c3:	68 92 00 00 00       	push   $0x92
  8011c8:	68 da 32 80 00       	push   $0x8032da
  8011cd:	e8 4e f3 ff ff       	call   800520 <_panic>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  8011d2:	50                   	push   %eax
  8011d3:	68 6c 31 80 00       	push   $0x80316c
  8011d8:	68 97 00 00 00       	push   $0x97
  8011dd:	68 da 32 80 00       	push   $0x8032da
  8011e2:	e8 39 f3 ff ff       	call   800520 <_panic>
	} else {
		// En caso de lectura, compartir.
		r = sys_page_map(0, v_add, envid, v_add, PTE_U | PTE_P);
  8011e7:	83 ec 0c             	sub    $0xc,%esp
  8011ea:	6a 05                	push   $0x5
  8011ec:	53                   	push   %ebx
  8011ed:	50                   	push   %eax
  8011ee:	53                   	push   %ebx
  8011ef:	6a 00                	push   $0x0
  8011f1:	e8 2b fe ff ff       	call   801021 <sys_page_map>
		if (r < 0)
  8011f6:	83 c4 20             	add    $0x20,%esp
  8011f9:	85 c0                	test   %eax,%eax
  8011fb:	78 0a                	js     801207 <duppage+0xd1>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	}
	return 0;
}
  8011fd:	b8 00 00 00 00       	mov    $0x0,%eax
  801202:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801205:	c9                   	leave  
  801206:	c3                   	ret    
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  801207:	50                   	push   %eax
  801208:	68 6c 31 80 00       	push   $0x80316c
  80120d:	68 a0 00 00 00       	push   $0xa0
  801212:	68 da 32 80 00       	push   $0x8032da
  801217:	e8 04 f3 ff ff       	call   800520 <_panic>

0080121c <dup_or_share>:
{
  80121c:	55                   	push   %ebp
  80121d:	89 e5                	mov    %esp,%ebp
  80121f:	57                   	push   %edi
  801220:	56                   	push   %esi
  801221:	53                   	push   %ebx
  801222:	83 ec 0c             	sub    $0xc,%esp
  801225:	89 c7                	mov    %eax,%edi
  801227:	89 d6                	mov    %edx,%esi
  801229:	89 cb                	mov    %ecx,%ebx
	if (perm & PTE_W) {
  80122b:	f6 c1 02             	test   $0x2,%cl
  80122e:	0f 84 90 00 00 00    	je     8012c4 <dup_or_share+0xa8>
		if ((r = sys_page_alloc(dstenv, va, perm)) < 0)
  801234:	83 ec 04             	sub    $0x4,%esp
  801237:	51                   	push   %ecx
  801238:	52                   	push   %edx
  801239:	50                   	push   %eax
  80123a:	e8 ba fd ff ff       	call   800ff9 <sys_page_alloc>
  80123f:	83 c4 10             	add    $0x10,%esp
  801242:	85 c0                	test   %eax,%eax
  801244:	78 56                	js     80129c <dup_or_share+0x80>
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, perm)) < 0)
  801246:	83 ec 0c             	sub    $0xc,%esp
  801249:	53                   	push   %ebx
  80124a:	68 00 00 40 00       	push   $0x400000
  80124f:	6a 00                	push   $0x0
  801251:	56                   	push   %esi
  801252:	57                   	push   %edi
  801253:	e8 c9 fd ff ff       	call   801021 <sys_page_map>
  801258:	83 c4 20             	add    $0x20,%esp
  80125b:	85 c0                	test   %eax,%eax
  80125d:	78 51                	js     8012b0 <dup_or_share+0x94>
		memmove(UTEMP, va, PGSIZE);
  80125f:	83 ec 04             	sub    $0x4,%esp
  801262:	68 00 10 00 00       	push   $0x1000
  801267:	56                   	push   %esi
  801268:	68 00 00 40 00       	push   $0x400000
  80126d:	e8 b7 fa ff ff       	call   800d29 <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801272:	83 c4 08             	add    $0x8,%esp
  801275:	68 00 00 40 00       	push   $0x400000
  80127a:	6a 00                	push   $0x0
  80127c:	e8 ca fd ff ff       	call   80104b <sys_page_unmap>
  801281:	83 c4 10             	add    $0x10,%esp
  801284:	85 c0                	test   %eax,%eax
  801286:	79 51                	jns    8012d9 <dup_or_share+0xbd>
			panic("sys_page_unmap failed at dup_or_share");
  801288:	83 ec 04             	sub    $0x4,%esp
  80128b:	68 dc 31 80 00       	push   $0x8031dc
  801290:	6a 18                	push   $0x18
  801292:	68 da 32 80 00       	push   $0x8032da
  801297:	e8 84 f2 ff ff       	call   800520 <_panic>
			panic("sys_page_alloc failed at dup_or_share");
  80129c:	83 ec 04             	sub    $0x4,%esp
  80129f:	68 90 31 80 00       	push   $0x803190
  8012a4:	6a 13                	push   $0x13
  8012a6:	68 da 32 80 00       	push   $0x8032da
  8012ab:	e8 70 f2 ff ff       	call   800520 <_panic>
			panic("sys_page_map failed at dup_or_share");
  8012b0:	83 ec 04             	sub    $0x4,%esp
  8012b3:	68 b8 31 80 00       	push   $0x8031b8
  8012b8:	6a 15                	push   $0x15
  8012ba:	68 da 32 80 00       	push   $0x8032da
  8012bf:	e8 5c f2 ff ff       	call   800520 <_panic>
		if ((r = sys_page_map(0, va, dstenv, va, perm)) < 0)
  8012c4:	83 ec 0c             	sub    $0xc,%esp
  8012c7:	51                   	push   %ecx
  8012c8:	52                   	push   %edx
  8012c9:	50                   	push   %eax
  8012ca:	52                   	push   %edx
  8012cb:	6a 00                	push   $0x0
  8012cd:	e8 4f fd ff ff       	call   801021 <sys_page_map>
  8012d2:	83 c4 20             	add    $0x20,%esp
  8012d5:	85 c0                	test   %eax,%eax
  8012d7:	78 08                	js     8012e1 <dup_or_share+0xc5>
}
  8012d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012dc:	5b                   	pop    %ebx
  8012dd:	5e                   	pop    %esi
  8012de:	5f                   	pop    %edi
  8012df:	5d                   	pop    %ebp
  8012e0:	c3                   	ret    
			panic("sys_page_map failed at dup_or_share");
  8012e1:	83 ec 04             	sub    $0x4,%esp
  8012e4:	68 b8 31 80 00       	push   $0x8031b8
  8012e9:	6a 1c                	push   $0x1c
  8012eb:	68 da 32 80 00       	push   $0x8032da
  8012f0:	e8 2b f2 ff ff       	call   800520 <_panic>

008012f5 <pgfault>:
{
  8012f5:	f3 0f 1e fb          	endbr32 
  8012f9:	55                   	push   %ebp
  8012fa:	89 e5                	mov    %esp,%ebp
  8012fc:	53                   	push   %ebx
  8012fd:	83 ec 04             	sub    $0x4,%esp
  801300:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  801303:	8b 18                	mov    (%eax),%ebx
	pte_t pt_e = uvpt[PGNUM(addr)];
  801305:	89 da                	mov    %ebx,%edx
  801307:	c1 ea 0c             	shr    $0xc,%edx
  80130a:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if ((err & FEC_WR) == 0)
  801311:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  801315:	74 6e                	je     801385 <pgfault+0x90>
	if ((pt_e & PTE_COW) == 0)
  801317:	f6 c6 08             	test   $0x8,%dh
  80131a:	74 7d                	je     801399 <pgfault+0xa4>
	if ((r = sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  80131c:	83 ec 04             	sub    $0x4,%esp
  80131f:	6a 07                	push   $0x7
  801321:	68 00 f0 7f 00       	push   $0x7ff000
  801326:	6a 00                	push   $0x0
  801328:	e8 cc fc ff ff       	call   800ff9 <sys_page_alloc>
  80132d:	83 c4 10             	add    $0x10,%esp
  801330:	85 c0                	test   %eax,%eax
  801332:	78 79                	js     8013ad <pgfault+0xb8>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  801334:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  80133a:	83 ec 04             	sub    $0x4,%esp
  80133d:	68 00 10 00 00       	push   $0x1000
  801342:	53                   	push   %ebx
  801343:	68 00 f0 7f 00       	push   $0x7ff000
  801348:	e8 dc f9 ff ff       	call   800d29 <memmove>
	if ((r = sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U)) <
  80134d:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  801354:	53                   	push   %ebx
  801355:	6a 00                	push   $0x0
  801357:	68 00 f0 7f 00       	push   $0x7ff000
  80135c:	6a 00                	push   $0x0
  80135e:	e8 be fc ff ff       	call   801021 <sys_page_map>
  801363:	83 c4 20             	add    $0x20,%esp
  801366:	85 c0                	test   %eax,%eax
  801368:	78 57                	js     8013c1 <pgfault+0xcc>
	if ((r = sys_page_unmap(0, (void *) PFTEMP)) < 0)
  80136a:	83 ec 08             	sub    $0x8,%esp
  80136d:	68 00 f0 7f 00       	push   $0x7ff000
  801372:	6a 00                	push   $0x0
  801374:	e8 d2 fc ff ff       	call   80104b <sys_page_unmap>
  801379:	83 c4 10             	add    $0x10,%esp
  80137c:	85 c0                	test   %eax,%eax
  80137e:	78 55                	js     8013d5 <pgfault+0xe0>
}
  801380:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801383:	c9                   	leave  
  801384:	c3                   	ret    
		panic("ERROR EN PGFAULT: WRITE");
  801385:	83 ec 04             	sub    $0x4,%esp
  801388:	68 e5 32 80 00       	push   $0x8032e5
  80138d:	6a 5e                	push   $0x5e
  80138f:	68 da 32 80 00       	push   $0x8032da
  801394:	e8 87 f1 ff ff       	call   800520 <_panic>
		panic("ERROR EN PGFAULT: COPY-ON-WRITE");
  801399:	83 ec 04             	sub    $0x4,%esp
  80139c:	68 04 32 80 00       	push   $0x803204
  8013a1:	6a 62                	push   $0x62
  8013a3:	68 da 32 80 00       	push   $0x8032da
  8013a8:	e8 73 f1 ff ff       	call   800520 <_panic>
		panic("pgfault failed");
  8013ad:	83 ec 04             	sub    $0x4,%esp
  8013b0:	68 fd 32 80 00       	push   $0x8032fd
  8013b5:	6a 6d                	push   $0x6d
  8013b7:	68 da 32 80 00       	push   $0x8032da
  8013bc:	e8 5f f1 ff ff       	call   800520 <_panic>
		panic("pgfault failed");
  8013c1:	83 ec 04             	sub    $0x4,%esp
  8013c4:	68 fd 32 80 00       	push   $0x8032fd
  8013c9:	6a 72                	push   $0x72
  8013cb:	68 da 32 80 00       	push   $0x8032da
  8013d0:	e8 4b f1 ff ff       	call   800520 <_panic>
		panic("pgfault failed");
  8013d5:	83 ec 04             	sub    $0x4,%esp
  8013d8:	68 fd 32 80 00       	push   $0x8032fd
  8013dd:	6a 74                	push   $0x74
  8013df:	68 da 32 80 00       	push   $0x8032da
  8013e4:	e8 37 f1 ff ff       	call   800520 <_panic>

008013e9 <fork_v0>:
{
  8013e9:	f3 0f 1e fb          	endbr32 
  8013ed:	55                   	push   %ebp
  8013ee:	89 e5                	mov    %esp,%ebp
  8013f0:	57                   	push   %edi
  8013f1:	56                   	push   %esi
  8013f2:	53                   	push   %ebx
  8013f3:	83 ec 1c             	sub    $0x1c,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  8013f6:	b8 07 00 00 00       	mov    $0x7,%eax
  8013fb:	cd 30                	int    $0x30
  8013fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801400:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (envid < 0)
  801403:	85 c0                	test   %eax,%eax
  801405:	78 1d                	js     801424 <fork_v0+0x3b>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  801407:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  80140c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801410:	74 26                	je     801438 <fork_v0+0x4f>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  801412:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  801417:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
			        (pte_t *) (PGADDR(PDX(uvpt),
  80141d:	bf 00 00 40 ef       	mov    $0xef400000,%edi
  801422:	eb 4b                	jmp    80146f <fork_v0+0x86>
		panic("sys_exofork failed");
  801424:	83 ec 04             	sub    $0x4,%esp
  801427:	68 0c 33 80 00       	push   $0x80330c
  80142c:	6a 2b                	push   $0x2b
  80142e:	68 da 32 80 00       	push   $0x8032da
  801433:	e8 e8 f0 ff ff       	call   800520 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
  801438:	e8 69 fb ff ff       	call   800fa6 <sys_getenvid>
  80143d:	25 ff 03 00 00       	and    $0x3ff,%eax
  801442:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801445:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80144a:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  80144f:	eb 68                	jmp    8014b9 <fork_v0+0xd0>
				dup_or_share(envid,
  801451:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  801457:	89 da                	mov    %ebx,%edx
  801459:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  80145c:	e8 bb fd ff ff       	call   80121c <dup_or_share>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  801461:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801467:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  80146d:	74 36                	je     8014a5 <fork_v0+0xbc>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  80146f:	89 d8                	mov    %ebx,%eax
  801471:	c1 e8 16             	shr    $0x16,%eax
  801474:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  80147b:	09 f2                	or     %esi,%edx
		if ((*pgdirentry) & PTE_P) {
  80147d:	f6 02 01             	testb  $0x1,(%edx)
  801480:	74 df                	je     801461 <fork_v0+0x78>
			        (pte_t *) (PGADDR(PDX(uvpt),
  801482:	89 da                	mov    %ebx,%edx
  801484:	c1 ea 0a             	shr    $0xa,%edx
  801487:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  80148d:	c1 e0 0c             	shl    $0xc,%eax
  801490:	89 f9                	mov    %edi,%ecx
  801492:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
  801498:	09 c8                	or     %ecx,%eax
  80149a:	09 d0                	or     %edx,%eax
			if ((*pgtablentry) & PTE_P)
  80149c:	8b 08                	mov    (%eax),%ecx
  80149e:	f6 c1 01             	test   $0x1,%cl
  8014a1:	74 be                	je     801461 <fork_v0+0x78>
  8014a3:	eb ac                	jmp    801451 <fork_v0+0x68>
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  8014a5:	83 ec 08             	sub    $0x8,%esp
  8014a8:	6a 02                	push   $0x2
  8014aa:	ff 75 e0             	pushl  -0x20(%ebp)
  8014ad:	e8 c0 fb ff ff       	call   801072 <sys_env_set_status>
  8014b2:	83 c4 10             	add    $0x10,%esp
  8014b5:	85 c0                	test   %eax,%eax
  8014b7:	78 0b                	js     8014c4 <fork_v0+0xdb>
}
  8014b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8014bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8014bf:	5b                   	pop    %ebx
  8014c0:	5e                   	pop    %esi
  8014c1:	5f                   	pop    %edi
  8014c2:	5d                   	pop    %ebp
  8014c3:	c3                   	ret    
		panic("sys_env_set_status failed at fork_v0");
  8014c4:	83 ec 04             	sub    $0x4,%esp
  8014c7:	68 24 32 80 00       	push   $0x803224
  8014cc:	6a 43                	push   $0x43
  8014ce:	68 da 32 80 00       	push   $0x8032da
  8014d3:	e8 48 f0 ff ff       	call   800520 <_panic>

008014d8 <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  8014d8:	f3 0f 1e fb          	endbr32 
  8014dc:	55                   	push   %ebp
  8014dd:	89 e5                	mov    %esp,%ebp
  8014df:	57                   	push   %edi
  8014e0:	56                   	push   %esi
  8014e1:	53                   	push   %ebx
  8014e2:	83 ec 28             	sub    $0x28,%esp
	int err;

	// handle padre
	set_pgfault_handler(pgfault);
  8014e5:	68 f5 12 80 00       	push   $0x8012f5
  8014ea:	e8 99 13 00 00       	call   802888 <set_pgfault_handler>
  8014ef:	b8 07 00 00 00       	mov    $0x7,%eax
  8014f4:	cd 30                	int    $0x30
  8014f6:	89 45 e0             	mov    %eax,-0x20(%ebp)

	// Proceso hijo
	envid_t e_id = sys_exofork();

	if (e_id < 0)
  8014f9:	83 c4 10             	add    $0x10,%esp
  8014fc:	85 c0                	test   %eax,%eax
  8014fe:	78 2f                	js     80152f <fork+0x57>
  801500:	89 c7                	mov    %eax,%edi
  801502:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		panic("ERROR EN FORK: sys_exofork: %e", e_id);

	if (e_id == 0) {
  801509:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80150d:	0f 85 9e 00 00 00    	jne    8015b1 <fork+0xd9>
		// Si es hijo
		thisenv = &envs[ENVX(sys_getenvid())];
  801513:	e8 8e fa ff ff       	call   800fa6 <sys_getenvid>
  801518:	25 ff 03 00 00       	and    $0x3ff,%eax
  80151d:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801520:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801525:	a3 04 50 80 00       	mov    %eax,0x805004
		return 0;
  80152a:	e9 de 00 00 00       	jmp    80160d <fork+0x135>
		panic("ERROR EN FORK: sys_exofork: %e", e_id);
  80152f:	50                   	push   %eax
  801530:	68 4c 32 80 00       	push   $0x80324c
  801535:	68 c2 00 00 00       	push   $0xc2
  80153a:	68 da 32 80 00       	push   $0x8032da
  80153f:	e8 dc ef ff ff       	call   800520 <_panic>
		// LOOP PTEs
		while (pt_x < NPTENTRIES) {
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
			pte_t pt_e = uvpt[PGNUM(dir)];
			if (dir == (UXSTACKTOP - PGSIZE)) {
				err = sys_page_alloc(e_id,
  801544:	83 ec 04             	sub    $0x4,%esp
  801547:	6a 07                	push   $0x7
  801549:	68 00 f0 bf ee       	push   $0xeebff000
  80154e:	57                   	push   %edi
  80154f:	e8 a5 fa ff ff       	call   800ff9 <sys_page_alloc>
				                     (void *) dir,
				                     PTE_W | PTE_U | PTE_P);
				if (err)
  801554:	83 c4 10             	add    $0x10,%esp
  801557:	85 c0                	test   %eax,%eax
  801559:	75 33                	jne    80158e <fork+0xb6>
  80155b:	83 c3 01             	add    $0x1,%ebx
		while (pt_x < NPTENTRIES) {
  80155e:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801564:	74 3d                	je     8015a3 <fork+0xcb>
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
  801566:	89 d8                	mov    %ebx,%eax
  801568:	c1 e0 0c             	shl    $0xc,%eax
  80156b:	09 f0                	or     %esi,%eax
			pte_t pt_e = uvpt[PGNUM(dir)];
  80156d:	89 c2                	mov    %eax,%edx
  80156f:	c1 ea 0c             	shr    $0xc,%edx
  801572:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
			if (dir == (UXSTACKTOP - PGSIZE)) {
  801579:	3d 00 f0 bf ee       	cmp    $0xeebff000,%eax
  80157e:	74 c4                	je     801544 <fork+0x6c>
					      "%e",
					      err);
				pt_x++;
				continue;
			}
			if ((pt_e & PTE_P) == 0) {
  801580:	f6 c1 01             	test   $0x1,%cl
  801583:	74 d6                	je     80155b <fork+0x83>
				pt_x++;
				continue;
			}
			duppage(e_id, PGNUM(dir));
  801585:	89 f8                	mov    %edi,%eax
  801587:	e8 aa fb ff ff       	call   801136 <duppage>
  80158c:	eb cd                	jmp    80155b <fork+0x83>
					panic("ERROR EN FORK: sys_page_alloc: "
  80158e:	50                   	push   %eax
  80158f:	68 6c 32 80 00       	push   $0x80326c
  801594:	68 e1 00 00 00       	push   $0xe1
  801599:	68 da 32 80 00       	push   $0x8032da
  80159e:	e8 7d ef ff ff       	call   800520 <_panic>
  8015a3:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  8015a7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
	while (pd_x < PDX(UTOP)) {
  8015aa:	3d bb 03 00 00       	cmp    $0x3bb,%eax
  8015af:	74 18                	je     8015c9 <fork+0xf1>
		pde_t pd_e = uvpd[pd_x];
  8015b1:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  8015b4:	8b 04 b5 00 d0 7b ef 	mov    -0x10843000(,%esi,4),%eax
		if ((pd_e & PTE_P) == 0) {
  8015bb:	a8 01                	test   $0x1,%al
  8015bd:	74 e4                	je     8015a3 <fork+0xcb>
  8015bf:	c1 e6 16             	shl    $0x16,%esi
  8015c2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8015c7:	eb 9d                	jmp    801566 <fork+0x8e>
			pt_x++;
		}
		pd_x++;
	}

	if ((err = sys_page_alloc(e_id,
  8015c9:	83 ec 04             	sub    $0x4,%esp
  8015cc:	6a 07                	push   $0x7
  8015ce:	68 00 f0 bf ee       	push   $0xeebff000
  8015d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8015d6:	e8 1e fa ff ff       	call   800ff9 <sys_page_alloc>
  8015db:	83 c4 10             	add    $0x10,%esp
  8015de:	85 c0                	test   %eax,%eax
  8015e0:	78 36                	js     801618 <fork+0x140>
	                          (void *) (UXSTACKTOP - PGSIZE),
	                          PTE_P | PTE_U | PTE_W) < 0))
		panic("Error en sys_page_alloc");


	if ((sys_env_set_pgfault_upcall(e_id, _pgfault_upcall) < 0))
  8015e2:	83 ec 08             	sub    $0x8,%esp
  8015e5:	68 e3 28 80 00       	push   $0x8028e3
  8015ea:	ff 75 e0             	pushl  -0x20(%ebp)
  8015ed:	e8 ce fa ff ff       	call   8010c0 <sys_env_set_pgfault_upcall>
  8015f2:	83 c4 10             	add    $0x10,%esp
  8015f5:	85 c0                	test   %eax,%eax
  8015f7:	78 36                	js     80162f <fork+0x157>
		panic("sys_env_set_pgfault_upcall failed");

	// HIJO RUNNABLE
	if ((err = sys_env_set_status(e_id, ENV_RUNNABLE)) < 0)
  8015f9:	83 ec 08             	sub    $0x8,%esp
  8015fc:	6a 02                	push   $0x2
  8015fe:	ff 75 e0             	pushl  -0x20(%ebp)
  801601:	e8 6c fa ff ff       	call   801072 <sys_env_set_status>
  801606:	83 c4 10             	add    $0x10,%esp
  801609:	85 c0                	test   %eax,%eax
  80160b:	78 39                	js     801646 <fork+0x16e>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);

	return e_id;
}
  80160d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801610:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801613:	5b                   	pop    %ebx
  801614:	5e                   	pop    %esi
  801615:	5f                   	pop    %edi
  801616:	5d                   	pop    %ebp
  801617:	c3                   	ret    
		panic("Error en sys_page_alloc");
  801618:	83 ec 04             	sub    $0x4,%esp
  80161b:	68 1f 33 80 00       	push   $0x80331f
  801620:	68 f4 00 00 00       	push   $0xf4
  801625:	68 da 32 80 00       	push   $0x8032da
  80162a:	e8 f1 ee ff ff       	call   800520 <_panic>
		panic("sys_env_set_pgfault_upcall failed");
  80162f:	83 ec 04             	sub    $0x4,%esp
  801632:	68 90 32 80 00       	push   $0x803290
  801637:	68 f8 00 00 00       	push   $0xf8
  80163c:	68 da 32 80 00       	push   $0x8032da
  801641:	e8 da ee ff ff       	call   800520 <_panic>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);
  801646:	50                   	push   %eax
  801647:	68 b4 32 80 00       	push   $0x8032b4
  80164c:	68 fc 00 00 00       	push   $0xfc
  801651:	68 da 32 80 00       	push   $0x8032da
  801656:	e8 c5 ee ff ff       	call   800520 <_panic>

0080165b <sfork>:

// Challenge!
int
sfork(void)
{
  80165b:	f3 0f 1e fb          	endbr32 
  80165f:	55                   	push   %ebp
  801660:	89 e5                	mov    %esp,%ebp
  801662:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801665:	68 37 33 80 00       	push   $0x803337
  80166a:	68 05 01 00 00       	push   $0x105
  80166f:	68 da 32 80 00       	push   $0x8032da
  801674:	e8 a7 ee ff ff       	call   800520 <_panic>

00801679 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801679:	f3 0f 1e fb          	endbr32 
  80167d:	55                   	push   %ebp
  80167e:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801680:	8b 45 08             	mov    0x8(%ebp),%eax
  801683:	05 00 00 00 30       	add    $0x30000000,%eax
  801688:	c1 e8 0c             	shr    $0xc,%eax
}
  80168b:	5d                   	pop    %ebp
  80168c:	c3                   	ret    

0080168d <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80168d:	f3 0f 1e fb          	endbr32 
  801691:	55                   	push   %ebp
  801692:	89 e5                	mov    %esp,%ebp
  801694:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  801697:	ff 75 08             	pushl  0x8(%ebp)
  80169a:	e8 da ff ff ff       	call   801679 <fd2num>
  80169f:	83 c4 10             	add    $0x10,%esp
  8016a2:	c1 e0 0c             	shl    $0xc,%eax
  8016a5:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  8016aa:	c9                   	leave  
  8016ab:	c3                   	ret    

008016ac <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  8016ac:	f3 0f 1e fb          	endbr32 
  8016b0:	55                   	push   %ebp
  8016b1:	89 e5                	mov    %esp,%ebp
  8016b3:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8016b8:	89 c2                	mov    %eax,%edx
  8016ba:	c1 ea 16             	shr    $0x16,%edx
  8016bd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8016c4:	f6 c2 01             	test   $0x1,%dl
  8016c7:	74 2d                	je     8016f6 <fd_alloc+0x4a>
  8016c9:	89 c2                	mov    %eax,%edx
  8016cb:	c1 ea 0c             	shr    $0xc,%edx
  8016ce:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8016d5:	f6 c2 01             	test   $0x1,%dl
  8016d8:	74 1c                	je     8016f6 <fd_alloc+0x4a>
  8016da:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8016df:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8016e4:	75 d2                	jne    8016b8 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8016e6:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e9:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8016ef:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8016f4:	eb 0a                	jmp    801700 <fd_alloc+0x54>
			*fd_store = fd;
  8016f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016f9:	89 01                	mov    %eax,(%ecx)
			return 0;
  8016fb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801700:	5d                   	pop    %ebp
  801701:	c3                   	ret    

00801702 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801702:	f3 0f 1e fb          	endbr32 
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80170c:	83 f8 1f             	cmp    $0x1f,%eax
  80170f:	77 30                	ja     801741 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801711:	c1 e0 0c             	shl    $0xc,%eax
  801714:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801719:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80171f:	f6 c2 01             	test   $0x1,%dl
  801722:	74 24                	je     801748 <fd_lookup+0x46>
  801724:	89 c2                	mov    %eax,%edx
  801726:	c1 ea 0c             	shr    $0xc,%edx
  801729:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801730:	f6 c2 01             	test   $0x1,%dl
  801733:	74 1a                	je     80174f <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801735:	8b 55 0c             	mov    0xc(%ebp),%edx
  801738:	89 02                	mov    %eax,(%edx)
	return 0;
  80173a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80173f:	5d                   	pop    %ebp
  801740:	c3                   	ret    
		return -E_INVAL;
  801741:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801746:	eb f7                	jmp    80173f <fd_lookup+0x3d>
		return -E_INVAL;
  801748:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80174d:	eb f0                	jmp    80173f <fd_lookup+0x3d>
  80174f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801754:	eb e9                	jmp    80173f <fd_lookup+0x3d>

00801756 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801756:	f3 0f 1e fb          	endbr32 
  80175a:	55                   	push   %ebp
  80175b:	89 e5                	mov    %esp,%ebp
  80175d:	83 ec 08             	sub    $0x8,%esp
  801760:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801763:	ba cc 33 80 00       	mov    $0x8033cc,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801768:	b8 20 40 80 00       	mov    $0x804020,%eax
		if (devtab[i]->dev_id == dev_id) {
  80176d:	39 08                	cmp    %ecx,(%eax)
  80176f:	74 33                	je     8017a4 <dev_lookup+0x4e>
  801771:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801774:	8b 02                	mov    (%edx),%eax
  801776:	85 c0                	test   %eax,%eax
  801778:	75 f3                	jne    80176d <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80177a:	a1 04 50 80 00       	mov    0x805004,%eax
  80177f:	8b 40 48             	mov    0x48(%eax),%eax
  801782:	83 ec 04             	sub    $0x4,%esp
  801785:	51                   	push   %ecx
  801786:	50                   	push   %eax
  801787:	68 50 33 80 00       	push   $0x803350
  80178c:	e8 76 ee ff ff       	call   800607 <cprintf>
	*dev = 0;
  801791:	8b 45 0c             	mov    0xc(%ebp),%eax
  801794:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80179a:	83 c4 10             	add    $0x10,%esp
  80179d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  8017a2:	c9                   	leave  
  8017a3:	c3                   	ret    
			*dev = devtab[i];
  8017a4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8017a7:	89 01                	mov    %eax,(%ecx)
			return 0;
  8017a9:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ae:	eb f2                	jmp    8017a2 <dev_lookup+0x4c>

008017b0 <fd_close>:
{
  8017b0:	f3 0f 1e fb          	endbr32 
  8017b4:	55                   	push   %ebp
  8017b5:	89 e5                	mov    %esp,%ebp
  8017b7:	57                   	push   %edi
  8017b8:	56                   	push   %esi
  8017b9:	53                   	push   %ebx
  8017ba:	83 ec 28             	sub    $0x28,%esp
  8017bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8017c0:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  8017c3:	56                   	push   %esi
  8017c4:	e8 b0 fe ff ff       	call   801679 <fd2num>
  8017c9:	83 c4 08             	add    $0x8,%esp
  8017cc:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  8017cf:	52                   	push   %edx
  8017d0:	50                   	push   %eax
  8017d1:	e8 2c ff ff ff       	call   801702 <fd_lookup>
  8017d6:	89 c3                	mov    %eax,%ebx
  8017d8:	83 c4 10             	add    $0x10,%esp
  8017db:	85 c0                	test   %eax,%eax
  8017dd:	78 05                	js     8017e4 <fd_close+0x34>
	    || fd != fd2)
  8017df:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8017e2:	74 16                	je     8017fa <fd_close+0x4a>
		return (must_exist ? r : 0);
  8017e4:	89 f8                	mov    %edi,%eax
  8017e6:	84 c0                	test   %al,%al
  8017e8:	b8 00 00 00 00       	mov    $0x0,%eax
  8017ed:	0f 44 d8             	cmove  %eax,%ebx
}
  8017f0:	89 d8                	mov    %ebx,%eax
  8017f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017f5:	5b                   	pop    %ebx
  8017f6:	5e                   	pop    %esi
  8017f7:	5f                   	pop    %edi
  8017f8:	5d                   	pop    %ebp
  8017f9:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8017fa:	83 ec 08             	sub    $0x8,%esp
  8017fd:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801800:	50                   	push   %eax
  801801:	ff 36                	pushl  (%esi)
  801803:	e8 4e ff ff ff       	call   801756 <dev_lookup>
  801808:	89 c3                	mov    %eax,%ebx
  80180a:	83 c4 10             	add    $0x10,%esp
  80180d:	85 c0                	test   %eax,%eax
  80180f:	78 1a                	js     80182b <fd_close+0x7b>
		if (dev->dev_close)
  801811:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801814:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801817:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80181c:	85 c0                	test   %eax,%eax
  80181e:	74 0b                	je     80182b <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801820:	83 ec 0c             	sub    $0xc,%esp
  801823:	56                   	push   %esi
  801824:	ff d0                	call   *%eax
  801826:	89 c3                	mov    %eax,%ebx
  801828:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  80182b:	83 ec 08             	sub    $0x8,%esp
  80182e:	56                   	push   %esi
  80182f:	6a 00                	push   $0x0
  801831:	e8 15 f8 ff ff       	call   80104b <sys_page_unmap>
	return r;
  801836:	83 c4 10             	add    $0x10,%esp
  801839:	eb b5                	jmp    8017f0 <fd_close+0x40>

0080183b <close>:

int
close(int fdnum)
{
  80183b:	f3 0f 1e fb          	endbr32 
  80183f:	55                   	push   %ebp
  801840:	89 e5                	mov    %esp,%ebp
  801842:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801845:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801848:	50                   	push   %eax
  801849:	ff 75 08             	pushl  0x8(%ebp)
  80184c:	e8 b1 fe ff ff       	call   801702 <fd_lookup>
  801851:	83 c4 10             	add    $0x10,%esp
  801854:	85 c0                	test   %eax,%eax
  801856:	79 02                	jns    80185a <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801858:	c9                   	leave  
  801859:	c3                   	ret    
		return fd_close(fd, 1);
  80185a:	83 ec 08             	sub    $0x8,%esp
  80185d:	6a 01                	push   $0x1
  80185f:	ff 75 f4             	pushl  -0xc(%ebp)
  801862:	e8 49 ff ff ff       	call   8017b0 <fd_close>
  801867:	83 c4 10             	add    $0x10,%esp
  80186a:	eb ec                	jmp    801858 <close+0x1d>

0080186c <close_all>:

void
close_all(void)
{
  80186c:	f3 0f 1e fb          	endbr32 
  801870:	55                   	push   %ebp
  801871:	89 e5                	mov    %esp,%ebp
  801873:	53                   	push   %ebx
  801874:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801877:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80187c:	83 ec 0c             	sub    $0xc,%esp
  80187f:	53                   	push   %ebx
  801880:	e8 b6 ff ff ff       	call   80183b <close>
	for (i = 0; i < MAXFD; i++)
  801885:	83 c3 01             	add    $0x1,%ebx
  801888:	83 c4 10             	add    $0x10,%esp
  80188b:	83 fb 20             	cmp    $0x20,%ebx
  80188e:	75 ec                	jne    80187c <close_all+0x10>
}
  801890:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801893:	c9                   	leave  
  801894:	c3                   	ret    

00801895 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801895:	f3 0f 1e fb          	endbr32 
  801899:	55                   	push   %ebp
  80189a:	89 e5                	mov    %esp,%ebp
  80189c:	57                   	push   %edi
  80189d:	56                   	push   %esi
  80189e:	53                   	push   %ebx
  80189f:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  8018a2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  8018a5:	50                   	push   %eax
  8018a6:	ff 75 08             	pushl  0x8(%ebp)
  8018a9:	e8 54 fe ff ff       	call   801702 <fd_lookup>
  8018ae:	89 c3                	mov    %eax,%ebx
  8018b0:	83 c4 10             	add    $0x10,%esp
  8018b3:	85 c0                	test   %eax,%eax
  8018b5:	0f 88 81 00 00 00    	js     80193c <dup+0xa7>
		return r;
	close(newfdnum);
  8018bb:	83 ec 0c             	sub    $0xc,%esp
  8018be:	ff 75 0c             	pushl  0xc(%ebp)
  8018c1:	e8 75 ff ff ff       	call   80183b <close>

	newfd = INDEX2FD(newfdnum);
  8018c6:	8b 75 0c             	mov    0xc(%ebp),%esi
  8018c9:	c1 e6 0c             	shl    $0xc,%esi
  8018cc:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  8018d2:	83 c4 04             	add    $0x4,%esp
  8018d5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8018d8:	e8 b0 fd ff ff       	call   80168d <fd2data>
  8018dd:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8018df:	89 34 24             	mov    %esi,(%esp)
  8018e2:	e8 a6 fd ff ff       	call   80168d <fd2data>
  8018e7:	83 c4 10             	add    $0x10,%esp
  8018ea:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8018ec:	89 d8                	mov    %ebx,%eax
  8018ee:	c1 e8 16             	shr    $0x16,%eax
  8018f1:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8018f8:	a8 01                	test   $0x1,%al
  8018fa:	74 11                	je     80190d <dup+0x78>
  8018fc:	89 d8                	mov    %ebx,%eax
  8018fe:	c1 e8 0c             	shr    $0xc,%eax
  801901:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801908:	f6 c2 01             	test   $0x1,%dl
  80190b:	75 39                	jne    801946 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80190d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801910:	89 d0                	mov    %edx,%eax
  801912:	c1 e8 0c             	shr    $0xc,%eax
  801915:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80191c:	83 ec 0c             	sub    $0xc,%esp
  80191f:	25 07 0e 00 00       	and    $0xe07,%eax
  801924:	50                   	push   %eax
  801925:	56                   	push   %esi
  801926:	6a 00                	push   $0x0
  801928:	52                   	push   %edx
  801929:	6a 00                	push   $0x0
  80192b:	e8 f1 f6 ff ff       	call   801021 <sys_page_map>
  801930:	89 c3                	mov    %eax,%ebx
  801932:	83 c4 20             	add    $0x20,%esp
  801935:	85 c0                	test   %eax,%eax
  801937:	78 31                	js     80196a <dup+0xd5>
		goto err;

	return newfdnum;
  801939:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  80193c:	89 d8                	mov    %ebx,%eax
  80193e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801941:	5b                   	pop    %ebx
  801942:	5e                   	pop    %esi
  801943:	5f                   	pop    %edi
  801944:	5d                   	pop    %ebp
  801945:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  801946:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80194d:	83 ec 0c             	sub    $0xc,%esp
  801950:	25 07 0e 00 00       	and    $0xe07,%eax
  801955:	50                   	push   %eax
  801956:	57                   	push   %edi
  801957:	6a 00                	push   $0x0
  801959:	53                   	push   %ebx
  80195a:	6a 00                	push   $0x0
  80195c:	e8 c0 f6 ff ff       	call   801021 <sys_page_map>
  801961:	89 c3                	mov    %eax,%ebx
  801963:	83 c4 20             	add    $0x20,%esp
  801966:	85 c0                	test   %eax,%eax
  801968:	79 a3                	jns    80190d <dup+0x78>
	sys_page_unmap(0, newfd);
  80196a:	83 ec 08             	sub    $0x8,%esp
  80196d:	56                   	push   %esi
  80196e:	6a 00                	push   $0x0
  801970:	e8 d6 f6 ff ff       	call   80104b <sys_page_unmap>
	sys_page_unmap(0, nva);
  801975:	83 c4 08             	add    $0x8,%esp
  801978:	57                   	push   %edi
  801979:	6a 00                	push   $0x0
  80197b:	e8 cb f6 ff ff       	call   80104b <sys_page_unmap>
	return r;
  801980:	83 c4 10             	add    $0x10,%esp
  801983:	eb b7                	jmp    80193c <dup+0xa7>

00801985 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801985:	f3 0f 1e fb          	endbr32 
  801989:	55                   	push   %ebp
  80198a:	89 e5                	mov    %esp,%ebp
  80198c:	53                   	push   %ebx
  80198d:	83 ec 1c             	sub    $0x1c,%esp
  801990:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801993:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801996:	50                   	push   %eax
  801997:	53                   	push   %ebx
  801998:	e8 65 fd ff ff       	call   801702 <fd_lookup>
  80199d:	83 c4 10             	add    $0x10,%esp
  8019a0:	85 c0                	test   %eax,%eax
  8019a2:	78 3f                	js     8019e3 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8019a4:	83 ec 08             	sub    $0x8,%esp
  8019a7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8019aa:	50                   	push   %eax
  8019ab:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8019ae:	ff 30                	pushl  (%eax)
  8019b0:	e8 a1 fd ff ff       	call   801756 <dev_lookup>
  8019b5:	83 c4 10             	add    $0x10,%esp
  8019b8:	85 c0                	test   %eax,%eax
  8019ba:	78 27                	js     8019e3 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  8019bc:	8b 55 f0             	mov    -0x10(%ebp),%edx
  8019bf:	8b 42 08             	mov    0x8(%edx),%eax
  8019c2:	83 e0 03             	and    $0x3,%eax
  8019c5:	83 f8 01             	cmp    $0x1,%eax
  8019c8:	74 1e                	je     8019e8 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  8019ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8019cd:	8b 40 08             	mov    0x8(%eax),%eax
  8019d0:	85 c0                	test   %eax,%eax
  8019d2:	74 35                	je     801a09 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8019d4:	83 ec 04             	sub    $0x4,%esp
  8019d7:	ff 75 10             	pushl  0x10(%ebp)
  8019da:	ff 75 0c             	pushl  0xc(%ebp)
  8019dd:	52                   	push   %edx
  8019de:	ff d0                	call   *%eax
  8019e0:	83 c4 10             	add    $0x10,%esp
}
  8019e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e6:	c9                   	leave  
  8019e7:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8019e8:	a1 04 50 80 00       	mov    0x805004,%eax
  8019ed:	8b 40 48             	mov    0x48(%eax),%eax
  8019f0:	83 ec 04             	sub    $0x4,%esp
  8019f3:	53                   	push   %ebx
  8019f4:	50                   	push   %eax
  8019f5:	68 91 33 80 00       	push   $0x803391
  8019fa:	e8 08 ec ff ff       	call   800607 <cprintf>
		return -E_INVAL;
  8019ff:	83 c4 10             	add    $0x10,%esp
  801a02:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801a07:	eb da                	jmp    8019e3 <read+0x5e>
		return -E_NOT_SUPP;
  801a09:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801a0e:	eb d3                	jmp    8019e3 <read+0x5e>

00801a10 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  801a10:	f3 0f 1e fb          	endbr32 
  801a14:	55                   	push   %ebp
  801a15:	89 e5                	mov    %esp,%ebp
  801a17:	57                   	push   %edi
  801a18:	56                   	push   %esi
  801a19:	53                   	push   %ebx
  801a1a:	83 ec 0c             	sub    $0xc,%esp
  801a1d:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a20:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  801a23:	bb 00 00 00 00       	mov    $0x0,%ebx
  801a28:	eb 02                	jmp    801a2c <readn+0x1c>
  801a2a:	01 c3                	add    %eax,%ebx
  801a2c:	39 f3                	cmp    %esi,%ebx
  801a2e:	73 21                	jae    801a51 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a30:	83 ec 04             	sub    $0x4,%esp
  801a33:	89 f0                	mov    %esi,%eax
  801a35:	29 d8                	sub    %ebx,%eax
  801a37:	50                   	push   %eax
  801a38:	89 d8                	mov    %ebx,%eax
  801a3a:	03 45 0c             	add    0xc(%ebp),%eax
  801a3d:	50                   	push   %eax
  801a3e:	57                   	push   %edi
  801a3f:	e8 41 ff ff ff       	call   801985 <read>
		if (m < 0)
  801a44:	83 c4 10             	add    $0x10,%esp
  801a47:	85 c0                	test   %eax,%eax
  801a49:	78 04                	js     801a4f <readn+0x3f>
			return m;
		if (m == 0)
  801a4b:	75 dd                	jne    801a2a <readn+0x1a>
  801a4d:	eb 02                	jmp    801a51 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801a4f:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  801a51:	89 d8                	mov    %ebx,%eax
  801a53:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a56:	5b                   	pop    %ebx
  801a57:	5e                   	pop    %esi
  801a58:	5f                   	pop    %edi
  801a59:	5d                   	pop    %ebp
  801a5a:	c3                   	ret    

00801a5b <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801a5b:	f3 0f 1e fb          	endbr32 
  801a5f:	55                   	push   %ebp
  801a60:	89 e5                	mov    %esp,%ebp
  801a62:	53                   	push   %ebx
  801a63:	83 ec 1c             	sub    $0x1c,%esp
  801a66:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801a69:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801a6c:	50                   	push   %eax
  801a6d:	53                   	push   %ebx
  801a6e:	e8 8f fc ff ff       	call   801702 <fd_lookup>
  801a73:	83 c4 10             	add    $0x10,%esp
  801a76:	85 c0                	test   %eax,%eax
  801a78:	78 3a                	js     801ab4 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801a7a:	83 ec 08             	sub    $0x8,%esp
  801a7d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801a80:	50                   	push   %eax
  801a81:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a84:	ff 30                	pushl  (%eax)
  801a86:	e8 cb fc ff ff       	call   801756 <dev_lookup>
  801a8b:	83 c4 10             	add    $0x10,%esp
  801a8e:	85 c0                	test   %eax,%eax
  801a90:	78 22                	js     801ab4 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801a92:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801a95:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801a99:	74 1e                	je     801ab9 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801a9b:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801a9e:	8b 52 0c             	mov    0xc(%edx),%edx
  801aa1:	85 d2                	test   %edx,%edx
  801aa3:	74 35                	je     801ada <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801aa5:	83 ec 04             	sub    $0x4,%esp
  801aa8:	ff 75 10             	pushl  0x10(%ebp)
  801aab:	ff 75 0c             	pushl  0xc(%ebp)
  801aae:	50                   	push   %eax
  801aaf:	ff d2                	call   *%edx
  801ab1:	83 c4 10             	add    $0x10,%esp
}
  801ab4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ab7:	c9                   	leave  
  801ab8:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801ab9:	a1 04 50 80 00       	mov    0x805004,%eax
  801abe:	8b 40 48             	mov    0x48(%eax),%eax
  801ac1:	83 ec 04             	sub    $0x4,%esp
  801ac4:	53                   	push   %ebx
  801ac5:	50                   	push   %eax
  801ac6:	68 ad 33 80 00       	push   $0x8033ad
  801acb:	e8 37 eb ff ff       	call   800607 <cprintf>
		return -E_INVAL;
  801ad0:	83 c4 10             	add    $0x10,%esp
  801ad3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801ad8:	eb da                	jmp    801ab4 <write+0x59>
		return -E_NOT_SUPP;
  801ada:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801adf:	eb d3                	jmp    801ab4 <write+0x59>

00801ae1 <seek>:

int
seek(int fdnum, off_t offset)
{
  801ae1:	f3 0f 1e fb          	endbr32 
  801ae5:	55                   	push   %ebp
  801ae6:	89 e5                	mov    %esp,%ebp
  801ae8:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801aeb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801aee:	50                   	push   %eax
  801aef:	ff 75 08             	pushl  0x8(%ebp)
  801af2:	e8 0b fc ff ff       	call   801702 <fd_lookup>
  801af7:	83 c4 10             	add    $0x10,%esp
  801afa:	85 c0                	test   %eax,%eax
  801afc:	78 0e                	js     801b0c <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801afe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801b01:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801b04:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801b07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b0c:	c9                   	leave  
  801b0d:	c3                   	ret    

00801b0e <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801b0e:	f3 0f 1e fb          	endbr32 
  801b12:	55                   	push   %ebp
  801b13:	89 e5                	mov    %esp,%ebp
  801b15:	53                   	push   %ebx
  801b16:	83 ec 1c             	sub    $0x1c,%esp
  801b19:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b1c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b1f:	50                   	push   %eax
  801b20:	53                   	push   %ebx
  801b21:	e8 dc fb ff ff       	call   801702 <fd_lookup>
  801b26:	83 c4 10             	add    $0x10,%esp
  801b29:	85 c0                	test   %eax,%eax
  801b2b:	78 37                	js     801b64 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801b2d:	83 ec 08             	sub    $0x8,%esp
  801b30:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b33:	50                   	push   %eax
  801b34:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b37:	ff 30                	pushl  (%eax)
  801b39:	e8 18 fc ff ff       	call   801756 <dev_lookup>
  801b3e:	83 c4 10             	add    $0x10,%esp
  801b41:	85 c0                	test   %eax,%eax
  801b43:	78 1f                	js     801b64 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801b45:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801b48:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801b4c:	74 1b                	je     801b69 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801b4e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801b51:	8b 52 18             	mov    0x18(%edx),%edx
  801b54:	85 d2                	test   %edx,%edx
  801b56:	74 32                	je     801b8a <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801b58:	83 ec 08             	sub    $0x8,%esp
  801b5b:	ff 75 0c             	pushl  0xc(%ebp)
  801b5e:	50                   	push   %eax
  801b5f:	ff d2                	call   *%edx
  801b61:	83 c4 10             	add    $0x10,%esp
}
  801b64:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801b67:	c9                   	leave  
  801b68:	c3                   	ret    
			thisenv->env_id, fdnum);
  801b69:	a1 04 50 80 00       	mov    0x805004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801b6e:	8b 40 48             	mov    0x48(%eax),%eax
  801b71:	83 ec 04             	sub    $0x4,%esp
  801b74:	53                   	push   %ebx
  801b75:	50                   	push   %eax
  801b76:	68 70 33 80 00       	push   $0x803370
  801b7b:	e8 87 ea ff ff       	call   800607 <cprintf>
		return -E_INVAL;
  801b80:	83 c4 10             	add    $0x10,%esp
  801b83:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801b88:	eb da                	jmp    801b64 <ftruncate+0x56>
		return -E_NOT_SUPP;
  801b8a:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801b8f:	eb d3                	jmp    801b64 <ftruncate+0x56>

00801b91 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801b91:	f3 0f 1e fb          	endbr32 
  801b95:	55                   	push   %ebp
  801b96:	89 e5                	mov    %esp,%ebp
  801b98:	53                   	push   %ebx
  801b99:	83 ec 1c             	sub    $0x1c,%esp
  801b9c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801b9f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801ba2:	50                   	push   %eax
  801ba3:	ff 75 08             	pushl  0x8(%ebp)
  801ba6:	e8 57 fb ff ff       	call   801702 <fd_lookup>
  801bab:	83 c4 10             	add    $0x10,%esp
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	78 4b                	js     801bfd <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801bb2:	83 ec 08             	sub    $0x8,%esp
  801bb5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801bb8:	50                   	push   %eax
  801bb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801bbc:	ff 30                	pushl  (%eax)
  801bbe:	e8 93 fb ff ff       	call   801756 <dev_lookup>
  801bc3:	83 c4 10             	add    $0x10,%esp
  801bc6:	85 c0                	test   %eax,%eax
  801bc8:	78 33                	js     801bfd <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801bcd:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801bd1:	74 2f                	je     801c02 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801bd3:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801bd6:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801bdd:	00 00 00 
	stat->st_isdir = 0;
  801be0:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801be7:	00 00 00 
	stat->st_dev = dev;
  801bea:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801bf0:	83 ec 08             	sub    $0x8,%esp
  801bf3:	53                   	push   %ebx
  801bf4:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf7:	ff 50 14             	call   *0x14(%eax)
  801bfa:	83 c4 10             	add    $0x10,%esp
}
  801bfd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801c00:	c9                   	leave  
  801c01:	c3                   	ret    
		return -E_NOT_SUPP;
  801c02:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801c07:	eb f4                	jmp    801bfd <fstat+0x6c>

00801c09 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801c09:	f3 0f 1e fb          	endbr32 
  801c0d:	55                   	push   %ebp
  801c0e:	89 e5                	mov    %esp,%ebp
  801c10:	56                   	push   %esi
  801c11:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  801c12:	83 ec 08             	sub    $0x8,%esp
  801c15:	6a 00                	push   $0x0
  801c17:	ff 75 08             	pushl  0x8(%ebp)
  801c1a:	e8 fb 01 00 00       	call   801e1a <open>
  801c1f:	89 c3                	mov    %eax,%ebx
  801c21:	83 c4 10             	add    $0x10,%esp
  801c24:	85 c0                	test   %eax,%eax
  801c26:	78 1b                	js     801c43 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  801c28:	83 ec 08             	sub    $0x8,%esp
  801c2b:	ff 75 0c             	pushl  0xc(%ebp)
  801c2e:	50                   	push   %eax
  801c2f:	e8 5d ff ff ff       	call   801b91 <fstat>
  801c34:	89 c6                	mov    %eax,%esi
	close(fd);
  801c36:	89 1c 24             	mov    %ebx,(%esp)
  801c39:	e8 fd fb ff ff       	call   80183b <close>
	return r;
  801c3e:	83 c4 10             	add    $0x10,%esp
  801c41:	89 f3                	mov    %esi,%ebx
}
  801c43:	89 d8                	mov    %ebx,%eax
  801c45:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c48:	5b                   	pop    %ebx
  801c49:	5e                   	pop    %esi
  801c4a:	5d                   	pop    %ebp
  801c4b:	c3                   	ret    

00801c4c <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801c4c:	55                   	push   %ebp
  801c4d:	89 e5                	mov    %esp,%ebp
  801c4f:	56                   	push   %esi
  801c50:	53                   	push   %ebx
  801c51:	89 c6                	mov    %eax,%esi
  801c53:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  801c55:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801c5c:	74 27                	je     801c85 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801c5e:	6a 07                	push   $0x7
  801c60:	68 00 60 80 00       	push   $0x806000
  801c65:	56                   	push   %esi
  801c66:	ff 35 00 50 80 00    	pushl  0x805000
  801c6c:	e8 08 0d 00 00       	call   802979 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801c71:	83 c4 0c             	add    $0xc,%esp
  801c74:	6a 00                	push   $0x0
  801c76:	53                   	push   %ebx
  801c77:	6a 00                	push   $0x0
  801c79:	e8 8d 0c 00 00       	call   80290b <ipc_recv>
}
  801c7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c81:	5b                   	pop    %ebx
  801c82:	5e                   	pop    %esi
  801c83:	5d                   	pop    %ebp
  801c84:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801c85:	83 ec 0c             	sub    $0xc,%esp
  801c88:	6a 01                	push   $0x1
  801c8a:	e8 4f 0d 00 00       	call   8029de <ipc_find_env>
  801c8f:	a3 00 50 80 00       	mov    %eax,0x805000
  801c94:	83 c4 10             	add    $0x10,%esp
  801c97:	eb c5                	jmp    801c5e <fsipc+0x12>

00801c99 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801c99:	f3 0f 1e fb          	endbr32 
  801c9d:	55                   	push   %ebp
  801c9e:	89 e5                	mov    %esp,%ebp
  801ca0:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801ca3:	8b 45 08             	mov    0x8(%ebp),%eax
  801ca6:	8b 40 0c             	mov    0xc(%eax),%eax
  801ca9:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  801cae:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cb1:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801cb6:	ba 00 00 00 00       	mov    $0x0,%edx
  801cbb:	b8 02 00 00 00       	mov    $0x2,%eax
  801cc0:	e8 87 ff ff ff       	call   801c4c <fsipc>
}
  801cc5:	c9                   	leave  
  801cc6:	c3                   	ret    

00801cc7 <devfile_flush>:
{
  801cc7:	f3 0f 1e fb          	endbr32 
  801ccb:	55                   	push   %ebp
  801ccc:	89 e5                	mov    %esp,%ebp
  801cce:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801cd1:	8b 45 08             	mov    0x8(%ebp),%eax
  801cd4:	8b 40 0c             	mov    0xc(%eax),%eax
  801cd7:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  801cdc:	ba 00 00 00 00       	mov    $0x0,%edx
  801ce1:	b8 06 00 00 00       	mov    $0x6,%eax
  801ce6:	e8 61 ff ff ff       	call   801c4c <fsipc>
}
  801ceb:	c9                   	leave  
  801cec:	c3                   	ret    

00801ced <devfile_stat>:
{
  801ced:	f3 0f 1e fb          	endbr32 
  801cf1:	55                   	push   %ebp
  801cf2:	89 e5                	mov    %esp,%ebp
  801cf4:	53                   	push   %ebx
  801cf5:	83 ec 04             	sub    $0x4,%esp
  801cf8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801cfb:	8b 45 08             	mov    0x8(%ebp),%eax
  801cfe:	8b 40 0c             	mov    0xc(%eax),%eax
  801d01:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801d06:	ba 00 00 00 00       	mov    $0x0,%edx
  801d0b:	b8 05 00 00 00       	mov    $0x5,%eax
  801d10:	e8 37 ff ff ff       	call   801c4c <fsipc>
  801d15:	85 c0                	test   %eax,%eax
  801d17:	78 2c                	js     801d45 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801d19:	83 ec 08             	sub    $0x8,%esp
  801d1c:	68 00 60 80 00       	push   $0x806000
  801d21:	53                   	push   %ebx
  801d22:	e8 4a ee ff ff       	call   800b71 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801d27:	a1 80 60 80 00       	mov    0x806080,%eax
  801d2c:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801d32:	a1 84 60 80 00       	mov    0x806084,%eax
  801d37:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801d3d:	83 c4 10             	add    $0x10,%esp
  801d40:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801d45:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d48:	c9                   	leave  
  801d49:	c3                   	ret    

00801d4a <devfile_write>:
{
  801d4a:	f3 0f 1e fb          	endbr32 
  801d4e:	55                   	push   %ebp
  801d4f:	89 e5                	mov    %esp,%ebp
  801d51:	83 ec 0c             	sub    $0xc,%esp
  801d54:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801d57:	8b 55 08             	mov    0x8(%ebp),%edx
  801d5a:	8b 52 0c             	mov    0xc(%edx),%edx
  801d5d:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  801d63:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801d68:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801d6d:	0f 47 c2             	cmova  %edx,%eax
  801d70:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801d75:	50                   	push   %eax
  801d76:	ff 75 0c             	pushl  0xc(%ebp)
  801d79:	68 08 60 80 00       	push   $0x806008
  801d7e:	e8 a6 ef ff ff       	call   800d29 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801d83:	ba 00 00 00 00       	mov    $0x0,%edx
  801d88:	b8 04 00 00 00       	mov    $0x4,%eax
  801d8d:	e8 ba fe ff ff       	call   801c4c <fsipc>
}
  801d92:	c9                   	leave  
  801d93:	c3                   	ret    

00801d94 <devfile_read>:
{
  801d94:	f3 0f 1e fb          	endbr32 
  801d98:	55                   	push   %ebp
  801d99:	89 e5                	mov    %esp,%ebp
  801d9b:	56                   	push   %esi
  801d9c:	53                   	push   %ebx
  801d9d:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801da0:	8b 45 08             	mov    0x8(%ebp),%eax
  801da3:	8b 40 0c             	mov    0xc(%eax),%eax
  801da6:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  801dab:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801db1:	ba 00 00 00 00       	mov    $0x0,%edx
  801db6:	b8 03 00 00 00       	mov    $0x3,%eax
  801dbb:	e8 8c fe ff ff       	call   801c4c <fsipc>
  801dc0:	89 c3                	mov    %eax,%ebx
  801dc2:	85 c0                	test   %eax,%eax
  801dc4:	78 1f                	js     801de5 <devfile_read+0x51>
	assert(r <= n);
  801dc6:	39 f0                	cmp    %esi,%eax
  801dc8:	77 24                	ja     801dee <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801dca:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801dcf:	7f 33                	jg     801e04 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801dd1:	83 ec 04             	sub    $0x4,%esp
  801dd4:	50                   	push   %eax
  801dd5:	68 00 60 80 00       	push   $0x806000
  801dda:	ff 75 0c             	pushl  0xc(%ebp)
  801ddd:	e8 47 ef ff ff       	call   800d29 <memmove>
	return r;
  801de2:	83 c4 10             	add    $0x10,%esp
}
  801de5:	89 d8                	mov    %ebx,%eax
  801de7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801dea:	5b                   	pop    %ebx
  801deb:	5e                   	pop    %esi
  801dec:	5d                   	pop    %ebp
  801ded:	c3                   	ret    
	assert(r <= n);
  801dee:	68 dc 33 80 00       	push   $0x8033dc
  801df3:	68 e3 33 80 00       	push   $0x8033e3
  801df8:	6a 7c                	push   $0x7c
  801dfa:	68 f8 33 80 00       	push   $0x8033f8
  801dff:	e8 1c e7 ff ff       	call   800520 <_panic>
	assert(r <= PGSIZE);
  801e04:	68 03 34 80 00       	push   $0x803403
  801e09:	68 e3 33 80 00       	push   $0x8033e3
  801e0e:	6a 7d                	push   $0x7d
  801e10:	68 f8 33 80 00       	push   $0x8033f8
  801e15:	e8 06 e7 ff ff       	call   800520 <_panic>

00801e1a <open>:
{
  801e1a:	f3 0f 1e fb          	endbr32 
  801e1e:	55                   	push   %ebp
  801e1f:	89 e5                	mov    %esp,%ebp
  801e21:	56                   	push   %esi
  801e22:	53                   	push   %ebx
  801e23:	83 ec 1c             	sub    $0x1c,%esp
  801e26:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801e29:	56                   	push   %esi
  801e2a:	e8 ff ec ff ff       	call   800b2e <strlen>
  801e2f:	83 c4 10             	add    $0x10,%esp
  801e32:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801e37:	7f 6c                	jg     801ea5 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801e39:	83 ec 0c             	sub    $0xc,%esp
  801e3c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e3f:	50                   	push   %eax
  801e40:	e8 67 f8 ff ff       	call   8016ac <fd_alloc>
  801e45:	89 c3                	mov    %eax,%ebx
  801e47:	83 c4 10             	add    $0x10,%esp
  801e4a:	85 c0                	test   %eax,%eax
  801e4c:	78 3c                	js     801e8a <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801e4e:	83 ec 08             	sub    $0x8,%esp
  801e51:	56                   	push   %esi
  801e52:	68 00 60 80 00       	push   $0x806000
  801e57:	e8 15 ed ff ff       	call   800b71 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801e5c:	8b 45 0c             	mov    0xc(%ebp),%eax
  801e5f:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801e64:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801e67:	b8 01 00 00 00       	mov    $0x1,%eax
  801e6c:	e8 db fd ff ff       	call   801c4c <fsipc>
  801e71:	89 c3                	mov    %eax,%ebx
  801e73:	83 c4 10             	add    $0x10,%esp
  801e76:	85 c0                	test   %eax,%eax
  801e78:	78 19                	js     801e93 <open+0x79>
	return fd2num(fd);
  801e7a:	83 ec 0c             	sub    $0xc,%esp
  801e7d:	ff 75 f4             	pushl  -0xc(%ebp)
  801e80:	e8 f4 f7 ff ff       	call   801679 <fd2num>
  801e85:	89 c3                	mov    %eax,%ebx
  801e87:	83 c4 10             	add    $0x10,%esp
}
  801e8a:	89 d8                	mov    %ebx,%eax
  801e8c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801e8f:	5b                   	pop    %ebx
  801e90:	5e                   	pop    %esi
  801e91:	5d                   	pop    %ebp
  801e92:	c3                   	ret    
		fd_close(fd, 0);
  801e93:	83 ec 08             	sub    $0x8,%esp
  801e96:	6a 00                	push   $0x0
  801e98:	ff 75 f4             	pushl  -0xc(%ebp)
  801e9b:	e8 10 f9 ff ff       	call   8017b0 <fd_close>
		return r;
  801ea0:	83 c4 10             	add    $0x10,%esp
  801ea3:	eb e5                	jmp    801e8a <open+0x70>
		return -E_BAD_PATH;
  801ea5:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801eaa:	eb de                	jmp    801e8a <open+0x70>

00801eac <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801eac:	f3 0f 1e fb          	endbr32 
  801eb0:	55                   	push   %ebp
  801eb1:	89 e5                	mov    %esp,%ebp
  801eb3:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801eb6:	ba 00 00 00 00       	mov    $0x0,%edx
  801ebb:	b8 08 00 00 00       	mov    $0x8,%eax
  801ec0:	e8 87 fd ff ff       	call   801c4c <fsipc>
}
  801ec5:	c9                   	leave  
  801ec6:	c3                   	ret    

00801ec7 <copy_shared_pages>:
}

// Copy the mappings for shared pages into the child address space.
static int
copy_shared_pages(envid_t child)
{
  801ec7:	55                   	push   %ebp
  801ec8:	89 e5                	mov    %esp,%ebp
  801eca:	56                   	push   %esi
  801ecb:	53                   	push   %ebx
  801ecc:	89 c6                	mov    %eax,%esi
	// LAB 5: Your code here.
	for(uint32_t addr = UTEXT; addr < UTOP; addr +=PGSIZE){
  801ece:	bb 00 00 80 00       	mov    $0x800000,%ebx
  801ed3:	eb 33                	jmp    801f08 <copy_shared_pages+0x41>
		if(addr != UXSTACKTOP - PGSIZE){
			if(((uvpd[PDX(addr)] & PTE_P) != 0) && ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U|PTE_SHARE))) == 0){
				sys_page_map(0, (void*)addr, child, (void*)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  801ed5:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801edc:	83 ec 0c             	sub    $0xc,%esp
  801edf:	25 07 0e 00 00       	and    $0xe07,%eax
  801ee4:	50                   	push   %eax
  801ee5:	53                   	push   %ebx
  801ee6:	56                   	push   %esi
  801ee7:	53                   	push   %ebx
  801ee8:	6a 00                	push   $0x0
  801eea:	e8 32 f1 ff ff       	call   801021 <sys_page_map>
  801eef:	83 c4 20             	add    $0x20,%esp
	for(uint32_t addr = UTEXT; addr < UTOP; addr +=PGSIZE){
  801ef2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801ef8:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  801efe:	77 2f                	ja     801f2f <copy_shared_pages+0x68>
		if(addr != UXSTACKTOP - PGSIZE){
  801f00:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  801f06:	74 ea                	je     801ef2 <copy_shared_pages+0x2b>
			if(((uvpd[PDX(addr)] & PTE_P) != 0) && ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U|PTE_SHARE))) == 0){
  801f08:	89 d8                	mov    %ebx,%eax
  801f0a:	c1 e8 16             	shr    $0x16,%eax
  801f0d:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801f14:	a8 01                	test   $0x1,%al
  801f16:	74 da                	je     801ef2 <copy_shared_pages+0x2b>
  801f18:	89 da                	mov    %ebx,%edx
  801f1a:	c1 ea 0c             	shr    $0xc,%edx
  801f1d:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  801f24:	f7 d0                	not    %eax
  801f26:	a9 05 04 00 00       	test   $0x405,%eax
  801f2b:	75 c5                	jne    801ef2 <copy_shared_pages+0x2b>
  801f2d:	eb a6                	jmp    801ed5 <copy_shared_pages+0xe>
			}
		}
	}
	return 0;
}
  801f2f:	b8 00 00 00 00       	mov    $0x0,%eax
  801f34:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f37:	5b                   	pop    %ebx
  801f38:	5e                   	pop    %esi
  801f39:	5d                   	pop    %ebp
  801f3a:	c3                   	ret    

00801f3b <init_stack>:
{
  801f3b:	55                   	push   %ebp
  801f3c:	89 e5                	mov    %esp,%ebp
  801f3e:	57                   	push   %edi
  801f3f:	56                   	push   %esi
  801f40:	53                   	push   %ebx
  801f41:	83 ec 2c             	sub    $0x2c,%esp
  801f44:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801f47:	89 55 d0             	mov    %edx,-0x30(%ebp)
  801f4a:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (argc = 0; argv[argc] != 0; argc++)
  801f4d:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  801f52:	be 00 00 00 00       	mov    $0x0,%esi
  801f57:	89 d7                	mov    %edx,%edi
  801f59:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
	for (argc = 0; argv[argc] != 0; argc++)
  801f60:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  801f63:	85 c0                	test   %eax,%eax
  801f65:	74 15                	je     801f7c <init_stack+0x41>
		string_size += strlen(argv[argc]) + 1;
  801f67:	83 ec 0c             	sub    $0xc,%esp
  801f6a:	50                   	push   %eax
  801f6b:	e8 be eb ff ff       	call   800b2e <strlen>
  801f70:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  801f74:	83 c3 01             	add    $0x1,%ebx
  801f77:	83 c4 10             	add    $0x10,%esp
  801f7a:	eb dd                	jmp    801f59 <init_stack+0x1e>
  801f7c:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  801f7f:	89 4d d8             	mov    %ecx,-0x28(%ebp)
	string_store = (char *) UTEMP + PGSIZE - string_size;
  801f82:	bf 00 10 40 00       	mov    $0x401000,%edi
  801f87:	29 f7                	sub    %esi,%edi
	argv_store = (uintptr_t *) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801f89:	89 fa                	mov    %edi,%edx
  801f8b:	83 e2 fc             	and    $0xfffffffc,%edx
  801f8e:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  801f95:	29 c2                	sub    %eax,%edx
  801f97:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	if ((void *) (argv_store - 2) < (void *) UTEMP)
  801f9a:	8d 42 f8             	lea    -0x8(%edx),%eax
  801f9d:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  801fa2:	0f 86 06 01 00 00    	jbe    8020ae <init_stack+0x173>
	if ((r = sys_page_alloc(0, (void *) UTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  801fa8:	83 ec 04             	sub    $0x4,%esp
  801fab:	6a 07                	push   $0x7
  801fad:	68 00 00 40 00       	push   $0x400000
  801fb2:	6a 00                	push   $0x0
  801fb4:	e8 40 f0 ff ff       	call   800ff9 <sys_page_alloc>
  801fb9:	89 c6                	mov    %eax,%esi
  801fbb:	83 c4 10             	add    $0x10,%esp
  801fbe:	85 c0                	test   %eax,%eax
  801fc0:	0f 88 de 00 00 00    	js     8020a4 <init_stack+0x169>
	for (i = 0; i < argc; i++) {
  801fc6:	be 00 00 00 00       	mov    $0x0,%esi
  801fcb:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  801fce:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  801fd1:	39 75 e0             	cmp    %esi,-0x20(%ebp)
  801fd4:	7e 2f                	jle    802005 <init_stack+0xca>
		argv_store[i] = UTEMP2USTACK(string_store);
  801fd6:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  801fdc:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801fdf:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  801fe2:	83 ec 08             	sub    $0x8,%esp
  801fe5:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801fe8:	57                   	push   %edi
  801fe9:	e8 83 eb ff ff       	call   800b71 <strcpy>
		string_store += strlen(argv[i]) + 1;
  801fee:	83 c4 04             	add    $0x4,%esp
  801ff1:	ff 34 b3             	pushl  (%ebx,%esi,4)
  801ff4:	e8 35 eb ff ff       	call   800b2e <strlen>
  801ff9:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  801ffd:	83 c6 01             	add    $0x1,%esi
  802000:	83 c4 10             	add    $0x10,%esp
  802003:	eb cc                	jmp    801fd1 <init_stack+0x96>
	argv_store[argc] = 0;
  802005:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  802008:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  80200b:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char *) UTEMP + PGSIZE);
  802012:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  802018:	75 5f                	jne    802079 <init_stack+0x13e>
	argv_store[-1] = UTEMP2USTACK(argv_store);
  80201a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80201d:	8d 82 00 d0 7f ee    	lea    -0x11803000(%edx),%eax
  802023:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  802026:	89 d0                	mov    %edx,%eax
  802028:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  80202b:	89 4a f8             	mov    %ecx,-0x8(%edx)
	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  80202e:	2d 08 30 80 11       	sub    $0x11803008,%eax
  802033:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  802036:	89 01                	mov    %eax,(%ecx)
	if ((r = sys_page_map(0,
  802038:	83 ec 0c             	sub    $0xc,%esp
  80203b:	6a 07                	push   $0x7
  80203d:	68 00 d0 bf ee       	push   $0xeebfd000
  802042:	ff 75 d4             	pushl  -0x2c(%ebp)
  802045:	68 00 00 40 00       	push   $0x400000
  80204a:	6a 00                	push   $0x0
  80204c:	e8 d0 ef ff ff       	call   801021 <sys_page_map>
  802051:	89 c6                	mov    %eax,%esi
  802053:	83 c4 20             	add    $0x20,%esp
  802056:	85 c0                	test   %eax,%eax
  802058:	78 38                	js     802092 <init_stack+0x157>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  80205a:	83 ec 08             	sub    $0x8,%esp
  80205d:	68 00 00 40 00       	push   $0x400000
  802062:	6a 00                	push   $0x0
  802064:	e8 e2 ef ff ff       	call   80104b <sys_page_unmap>
  802069:	89 c6                	mov    %eax,%esi
  80206b:	83 c4 10             	add    $0x10,%esp
  80206e:	85 c0                	test   %eax,%eax
  802070:	78 20                	js     802092 <init_stack+0x157>
	return 0;
  802072:	be 00 00 00 00       	mov    $0x0,%esi
  802077:	eb 2b                	jmp    8020a4 <init_stack+0x169>
	assert(string_store == (char *) UTEMP + PGSIZE);
  802079:	68 10 34 80 00       	push   $0x803410
  80207e:	68 e3 33 80 00       	push   $0x8033e3
  802083:	68 fc 00 00 00       	push   $0xfc
  802088:	68 38 34 80 00       	push   $0x803438
  80208d:	e8 8e e4 ff ff       	call   800520 <_panic>
	sys_page_unmap(0, UTEMP);
  802092:	83 ec 08             	sub    $0x8,%esp
  802095:	68 00 00 40 00       	push   $0x400000
  80209a:	6a 00                	push   $0x0
  80209c:	e8 aa ef ff ff       	call   80104b <sys_page_unmap>
	return r;
  8020a1:	83 c4 10             	add    $0x10,%esp
}
  8020a4:	89 f0                	mov    %esi,%eax
  8020a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020a9:	5b                   	pop    %ebx
  8020aa:	5e                   	pop    %esi
  8020ab:	5f                   	pop    %edi
  8020ac:	5d                   	pop    %ebp
  8020ad:	c3                   	ret    
		return -E_NO_MEM;
  8020ae:	be fc ff ff ff       	mov    $0xfffffffc,%esi
  8020b3:	eb ef                	jmp    8020a4 <init_stack+0x169>

008020b5 <map_segment>:
{
  8020b5:	55                   	push   %ebp
  8020b6:	89 e5                	mov    %esp,%ebp
  8020b8:	57                   	push   %edi
  8020b9:	56                   	push   %esi
  8020ba:	53                   	push   %ebx
  8020bb:	83 ec 1c             	sub    $0x1c,%esp
  8020be:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8020c1:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8020c4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8020c7:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((i = PGOFF(va))) {
  8020ca:	89 d0                	mov    %edx,%eax
  8020cc:	25 ff 0f 00 00       	and    $0xfff,%eax
  8020d1:	74 0f                	je     8020e2 <map_segment+0x2d>
		va -= i;
  8020d3:	29 c2                	sub    %eax,%edx
  8020d5:	89 55 e0             	mov    %edx,-0x20(%ebp)
		memsz += i;
  8020d8:	01 c1                	add    %eax,%ecx
  8020da:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		filesz += i;
  8020dd:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8020df:	29 45 10             	sub    %eax,0x10(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  8020e2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8020e7:	e9 99 00 00 00       	jmp    802185 <map_segment+0xd0>
			if ((r = sys_page_alloc(0, UTEMP, PTE_P | PTE_U | PTE_W)) <
  8020ec:	83 ec 04             	sub    $0x4,%esp
  8020ef:	6a 07                	push   $0x7
  8020f1:	68 00 00 40 00       	push   $0x400000
  8020f6:	6a 00                	push   $0x0
  8020f8:	e8 fc ee ff ff       	call   800ff9 <sys_page_alloc>
  8020fd:	83 c4 10             	add    $0x10,%esp
  802100:	85 c0                	test   %eax,%eax
  802102:	0f 88 c1 00 00 00    	js     8021c9 <map_segment+0x114>
			if ((r = seek(fd, fileoffset + i)) < 0)
  802108:	83 ec 08             	sub    $0x8,%esp
  80210b:	89 f0                	mov    %esi,%eax
  80210d:	03 45 10             	add    0x10(%ebp),%eax
  802110:	50                   	push   %eax
  802111:	ff 75 08             	pushl  0x8(%ebp)
  802114:	e8 c8 f9 ff ff       	call   801ae1 <seek>
  802119:	83 c4 10             	add    $0x10,%esp
  80211c:	85 c0                	test   %eax,%eax
  80211e:	0f 88 a5 00 00 00    	js     8021c9 <map_segment+0x114>
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz - i))) < 0)
  802124:	83 ec 04             	sub    $0x4,%esp
  802127:	89 f8                	mov    %edi,%eax
  802129:	29 f0                	sub    %esi,%eax
  80212b:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802130:	ba 00 10 00 00       	mov    $0x1000,%edx
  802135:	0f 47 c2             	cmova  %edx,%eax
  802138:	50                   	push   %eax
  802139:	68 00 00 40 00       	push   $0x400000
  80213e:	ff 75 08             	pushl  0x8(%ebp)
  802141:	e8 ca f8 ff ff       	call   801a10 <readn>
  802146:	83 c4 10             	add    $0x10,%esp
  802149:	85 c0                	test   %eax,%eax
  80214b:	78 7c                	js     8021c9 <map_segment+0x114>
			if ((r = sys_page_map(
  80214d:	83 ec 0c             	sub    $0xc,%esp
  802150:	ff 75 14             	pushl  0x14(%ebp)
  802153:	03 75 e0             	add    -0x20(%ebp),%esi
  802156:	56                   	push   %esi
  802157:	ff 75 dc             	pushl  -0x24(%ebp)
  80215a:	68 00 00 40 00       	push   $0x400000
  80215f:	6a 00                	push   $0x0
  802161:	e8 bb ee ff ff       	call   801021 <sys_page_map>
  802166:	83 c4 20             	add    $0x20,%esp
  802169:	85 c0                	test   %eax,%eax
  80216b:	78 42                	js     8021af <map_segment+0xfa>
			sys_page_unmap(0, UTEMP);
  80216d:	83 ec 08             	sub    $0x8,%esp
  802170:	68 00 00 40 00       	push   $0x400000
  802175:	6a 00                	push   $0x0
  802177:	e8 cf ee ff ff       	call   80104b <sys_page_unmap>
  80217c:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  80217f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802185:	89 de                	mov    %ebx,%esi
  802187:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
  80218a:	76 38                	jbe    8021c4 <map_segment+0x10f>
		if (i >= filesz) {
  80218c:	39 df                	cmp    %ebx,%edi
  80218e:	0f 87 58 ff ff ff    	ja     8020ec <map_segment+0x37>
			if ((r = sys_page_alloc(child, (void *) (va + i), perm)) < 0)
  802194:	83 ec 04             	sub    $0x4,%esp
  802197:	ff 75 14             	pushl  0x14(%ebp)
  80219a:	03 75 e0             	add    -0x20(%ebp),%esi
  80219d:	56                   	push   %esi
  80219e:	ff 75 dc             	pushl  -0x24(%ebp)
  8021a1:	e8 53 ee ff ff       	call   800ff9 <sys_page_alloc>
  8021a6:	83 c4 10             	add    $0x10,%esp
  8021a9:	85 c0                	test   %eax,%eax
  8021ab:	79 d2                	jns    80217f <map_segment+0xca>
  8021ad:	eb 1a                	jmp    8021c9 <map_segment+0x114>
				panic("spawn: sys_page_map data: %e", r);
  8021af:	50                   	push   %eax
  8021b0:	68 44 34 80 00       	push   $0x803444
  8021b5:	68 3a 01 00 00       	push   $0x13a
  8021ba:	68 38 34 80 00       	push   $0x803438
  8021bf:	e8 5c e3 ff ff       	call   800520 <_panic>
	return 0;
  8021c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8021c9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8021cc:	5b                   	pop    %ebx
  8021cd:	5e                   	pop    %esi
  8021ce:	5f                   	pop    %edi
  8021cf:	5d                   	pop    %ebp
  8021d0:	c3                   	ret    

008021d1 <spawn>:
{
  8021d1:	f3 0f 1e fb          	endbr32 
  8021d5:	55                   	push   %ebp
  8021d6:	89 e5                	mov    %esp,%ebp
  8021d8:	57                   	push   %edi
  8021d9:	56                   	push   %esi
  8021da:	53                   	push   %ebx
  8021db:	81 ec 74 02 00 00    	sub    $0x274,%esp
	if ((r = open(prog, O_RDONLY)) < 0)
  8021e1:	6a 00                	push   $0x0
  8021e3:	ff 75 08             	pushl  0x8(%ebp)
  8021e6:	e8 2f fc ff ff       	call   801e1a <open>
  8021eb:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8021f1:	83 c4 10             	add    $0x10,%esp
  8021f4:	85 c0                	test   %eax,%eax
  8021f6:	0f 88 0b 02 00 00    	js     802407 <spawn+0x236>
  8021fc:	89 c7                	mov    %eax,%edi
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf) ||
  8021fe:	83 ec 04             	sub    $0x4,%esp
  802201:	68 00 02 00 00       	push   $0x200
  802206:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  80220c:	50                   	push   %eax
  80220d:	57                   	push   %edi
  80220e:	e8 fd f7 ff ff       	call   801a10 <readn>
  802213:	83 c4 10             	add    $0x10,%esp
  802216:	3d 00 02 00 00       	cmp    $0x200,%eax
  80221b:	0f 85 85 00 00 00    	jne    8022a6 <spawn+0xd5>
  802221:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802228:	45 4c 46 
  80222b:	75 79                	jne    8022a6 <spawn+0xd5>
  80222d:	b8 07 00 00 00       	mov    $0x7,%eax
  802232:	cd 30                	int    $0x30
  802234:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  80223a:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	if ((r = sys_exofork()) < 0)
  802240:	89 c3                	mov    %eax,%ebx
  802242:	85 c0                	test   %eax,%eax
  802244:	0f 88 b1 01 00 00    	js     8023fb <spawn+0x22a>
	child_tf = envs[ENVX(child)].env_tf;
  80224a:	89 c6                	mov    %eax,%esi
  80224c:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  802252:	6b f6 7c             	imul   $0x7c,%esi,%esi
  802255:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  80225b:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802261:	b9 11 00 00 00       	mov    $0x11,%ecx
  802266:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802268:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  80226e:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
  802274:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  80227a:	8b 55 0c             	mov    0xc(%ebp),%edx
  80227d:	89 d8                	mov    %ebx,%eax
  80227f:	e8 b7 fc ff ff       	call   801f3b <init_stack>
  802284:	85 c0                	test   %eax,%eax
  802286:	0f 88 89 01 00 00    	js     802415 <spawn+0x244>
	ph = (struct Proghdr *) (elf_buf + elf->e_phoff);
  80228c:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  802292:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802299:	be 00 00 00 00       	mov    $0x0,%esi
  80229e:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  8022a4:	eb 3e                	jmp    8022e4 <spawn+0x113>
		close(fd);
  8022a6:	83 ec 0c             	sub    $0xc,%esp
  8022a9:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  8022af:	e8 87 f5 ff ff       	call   80183b <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  8022b4:	83 c4 0c             	add    $0xc,%esp
  8022b7:	68 7f 45 4c 46       	push   $0x464c457f
  8022bc:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  8022c2:	68 61 34 80 00       	push   $0x803461
  8022c7:	e8 3b e3 ff ff       	call   800607 <cprintf>
		return -E_NOT_EXEC;
  8022cc:	83 c4 10             	add    $0x10,%esp
  8022cf:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  8022d6:	ff ff ff 
  8022d9:	e9 29 01 00 00       	jmp    802407 <spawn+0x236>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  8022de:	83 c6 01             	add    $0x1,%esi
  8022e1:	83 c3 20             	add    $0x20,%ebx
  8022e4:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  8022eb:	39 f0                	cmp    %esi,%eax
  8022ed:	7e 62                	jle    802351 <spawn+0x180>
		if (ph->p_type != ELF_PROG_LOAD)
  8022ef:	83 3b 01             	cmpl   $0x1,(%ebx)
  8022f2:	75 ea                	jne    8022de <spawn+0x10d>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  8022f4:	8b 43 18             	mov    0x18(%ebx),%eax
  8022f7:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  8022fa:	83 f8 01             	cmp    $0x1,%eax
  8022fd:	19 c0                	sbb    %eax,%eax
  8022ff:	83 e0 fe             	and    $0xfffffffe,%eax
  802302:	83 c0 07             	add    $0x7,%eax
		if ((r = map_segment(child,
  802305:	8b 4b 14             	mov    0x14(%ebx),%ecx
  802308:	8b 53 08             	mov    0x8(%ebx),%edx
  80230b:	50                   	push   %eax
  80230c:	ff 73 04             	pushl  0x4(%ebx)
  80230f:	ff 73 10             	pushl  0x10(%ebx)
  802312:	57                   	push   %edi
  802313:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802319:	e8 97 fd ff ff       	call   8020b5 <map_segment>
  80231e:	83 c4 10             	add    $0x10,%esp
  802321:	85 c0                	test   %eax,%eax
  802323:	79 b9                	jns    8022de <spawn+0x10d>
  802325:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  802327:	83 ec 0c             	sub    $0xc,%esp
  80232a:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802330:	e8 4b ec ff ff       	call   800f80 <sys_env_destroy>
	close(fd);
  802335:	83 c4 04             	add    $0x4,%esp
  802338:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  80233e:	e8 f8 f4 ff ff       	call   80183b <close>
	return r;
  802343:	83 c4 10             	add    $0x10,%esp
		if ((r = map_segment(child,
  802346:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
	return r;
  80234c:	e9 b6 00 00 00       	jmp    802407 <spawn+0x236>
	close(fd);
  802351:	83 ec 0c             	sub    $0xc,%esp
  802354:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  80235a:	e8 dc f4 ff ff       	call   80183b <close>
	if ((r = copy_shared_pages(child)) < 0)
  80235f:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  802365:	e8 5d fb ff ff       	call   801ec7 <copy_shared_pages>
  80236a:	83 c4 10             	add    $0x10,%esp
  80236d:	85 c0                	test   %eax,%eax
  80236f:	78 4b                	js     8023bc <spawn+0x1eb>
	child_tf.tf_eflags |= FL_IOPL_3;  // devious: see user/faultio.c
  802371:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802378:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  80237b:	83 ec 08             	sub    $0x8,%esp
  80237e:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802384:	50                   	push   %eax
  802385:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  80238b:	e8 09 ed ff ff       	call   801099 <sys_env_set_trapframe>
  802390:	83 c4 10             	add    $0x10,%esp
  802393:	85 c0                	test   %eax,%eax
  802395:	78 3a                	js     8023d1 <spawn+0x200>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802397:	83 ec 08             	sub    $0x8,%esp
  80239a:	6a 02                	push   $0x2
  80239c:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  8023a2:	e8 cb ec ff ff       	call   801072 <sys_env_set_status>
  8023a7:	83 c4 10             	add    $0x10,%esp
  8023aa:	85 c0                	test   %eax,%eax
  8023ac:	78 38                	js     8023e6 <spawn+0x215>
	return child;
  8023ae:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  8023b4:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  8023ba:	eb 4b                	jmp    802407 <spawn+0x236>
		panic("copy_shared_pages: %e", r);
  8023bc:	50                   	push   %eax
  8023bd:	68 7b 34 80 00       	push   $0x80347b
  8023c2:	68 8c 00 00 00       	push   $0x8c
  8023c7:	68 38 34 80 00       	push   $0x803438
  8023cc:	e8 4f e1 ff ff       	call   800520 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  8023d1:	50                   	push   %eax
  8023d2:	68 91 34 80 00       	push   $0x803491
  8023d7:	68 90 00 00 00       	push   $0x90
  8023dc:	68 38 34 80 00       	push   $0x803438
  8023e1:	e8 3a e1 ff ff       	call   800520 <_panic>
		panic("sys_env_set_status: %e", r);
  8023e6:	50                   	push   %eax
  8023e7:	68 ab 34 80 00       	push   $0x8034ab
  8023ec:	68 93 00 00 00       	push   $0x93
  8023f1:	68 38 34 80 00       	push   $0x803438
  8023f6:	e8 25 e1 ff ff       	call   800520 <_panic>
		return r;
  8023fb:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  802401:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
}
  802407:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  80240d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802410:	5b                   	pop    %ebx
  802411:	5e                   	pop    %esi
  802412:	5f                   	pop    %edi
  802413:	5d                   	pop    %ebp
  802414:	c3                   	ret    
		return r;
  802415:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  80241b:	eb ea                	jmp    802407 <spawn+0x236>

0080241d <spawnl>:
{
  80241d:	f3 0f 1e fb          	endbr32 
  802421:	55                   	push   %ebp
  802422:	89 e5                	mov    %esp,%ebp
  802424:	57                   	push   %edi
  802425:	56                   	push   %esi
  802426:	53                   	push   %ebx
  802427:	83 ec 0c             	sub    $0xc,%esp
	va_start(vl, arg0);
  80242a:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc = 0;
  80242d:	b8 00 00 00 00       	mov    $0x0,%eax
	while (va_arg(vl, void *) != NULL)
  802432:	8d 4a 04             	lea    0x4(%edx),%ecx
  802435:	83 3a 00             	cmpl   $0x0,(%edx)
  802438:	74 07                	je     802441 <spawnl+0x24>
		argc++;
  80243a:	83 c0 01             	add    $0x1,%eax
	while (va_arg(vl, void *) != NULL)
  80243d:	89 ca                	mov    %ecx,%edx
  80243f:	eb f1                	jmp    802432 <spawnl+0x15>
	const char *argv[argc + 2];
  802441:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  802448:	89 d1                	mov    %edx,%ecx
  80244a:	83 e1 f0             	and    $0xfffffff0,%ecx
  80244d:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  802453:	89 e6                	mov    %esp,%esi
  802455:	29 d6                	sub    %edx,%esi
  802457:	89 f2                	mov    %esi,%edx
  802459:	39 d4                	cmp    %edx,%esp
  80245b:	74 10                	je     80246d <spawnl+0x50>
  80245d:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  802463:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  80246a:	00 
  80246b:	eb ec                	jmp    802459 <spawnl+0x3c>
  80246d:	89 ca                	mov    %ecx,%edx
  80246f:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  802475:	29 d4                	sub    %edx,%esp
  802477:	85 d2                	test   %edx,%edx
  802479:	74 05                	je     802480 <spawnl+0x63>
  80247b:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  802480:	8d 74 24 03          	lea    0x3(%esp),%esi
  802484:	89 f2                	mov    %esi,%edx
  802486:	c1 ea 02             	shr    $0x2,%edx
  802489:	83 e6 fc             	and    $0xfffffffc,%esi
  80248c:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  80248e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802491:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc + 1] = NULL;
  802498:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  80249f:	00 
	va_start(vl, arg0);
  8024a0:	8d 4d 10             	lea    0x10(%ebp),%ecx
  8024a3:	89 c2                	mov    %eax,%edx
	for (i = 0; i < argc; i++)
  8024a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8024aa:	eb 0b                	jmp    8024b7 <spawnl+0x9a>
		argv[i + 1] = va_arg(vl, const char *);
  8024ac:	83 c0 01             	add    $0x1,%eax
  8024af:	8b 39                	mov    (%ecx),%edi
  8024b1:	89 3c 83             	mov    %edi,(%ebx,%eax,4)
  8024b4:	8d 49 04             	lea    0x4(%ecx),%ecx
	for (i = 0; i < argc; i++)
  8024b7:	39 d0                	cmp    %edx,%eax
  8024b9:	75 f1                	jne    8024ac <spawnl+0x8f>
	return spawn(prog, argv);
  8024bb:	83 ec 08             	sub    $0x8,%esp
  8024be:	56                   	push   %esi
  8024bf:	ff 75 08             	pushl  0x8(%ebp)
  8024c2:	e8 0a fd ff ff       	call   8021d1 <spawn>
}
  8024c7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8024ca:	5b                   	pop    %ebx
  8024cb:	5e                   	pop    %esi
  8024cc:	5f                   	pop    %edi
  8024cd:	5d                   	pop    %ebp
  8024ce:	c3                   	ret    

008024cf <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  8024cf:	f3 0f 1e fb          	endbr32 
  8024d3:	55                   	push   %ebp
  8024d4:	89 e5                	mov    %esp,%ebp
  8024d6:	56                   	push   %esi
  8024d7:	53                   	push   %ebx
  8024d8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  8024db:	83 ec 0c             	sub    $0xc,%esp
  8024de:	ff 75 08             	pushl  0x8(%ebp)
  8024e1:	e8 a7 f1 ff ff       	call   80168d <fd2data>
  8024e6:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  8024e8:	83 c4 08             	add    $0x8,%esp
  8024eb:	68 c2 34 80 00       	push   $0x8034c2
  8024f0:	53                   	push   %ebx
  8024f1:	e8 7b e6 ff ff       	call   800b71 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  8024f6:	8b 46 04             	mov    0x4(%esi),%eax
  8024f9:	2b 06                	sub    (%esi),%eax
  8024fb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802501:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802508:	00 00 00 
	stat->st_dev = &devpipe;
  80250b:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802512:	40 80 00 
	return 0;
}
  802515:	b8 00 00 00 00       	mov    $0x0,%eax
  80251a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80251d:	5b                   	pop    %ebx
  80251e:	5e                   	pop    %esi
  80251f:	5d                   	pop    %ebp
  802520:	c3                   	ret    

00802521 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802521:	f3 0f 1e fb          	endbr32 
  802525:	55                   	push   %ebp
  802526:	89 e5                	mov    %esp,%ebp
  802528:	53                   	push   %ebx
  802529:	83 ec 0c             	sub    $0xc,%esp
  80252c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  80252f:	53                   	push   %ebx
  802530:	6a 00                	push   $0x0
  802532:	e8 14 eb ff ff       	call   80104b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802537:	89 1c 24             	mov    %ebx,(%esp)
  80253a:	e8 4e f1 ff ff       	call   80168d <fd2data>
  80253f:	83 c4 08             	add    $0x8,%esp
  802542:	50                   	push   %eax
  802543:	6a 00                	push   $0x0
  802545:	e8 01 eb ff ff       	call   80104b <sys_page_unmap>
}
  80254a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80254d:	c9                   	leave  
  80254e:	c3                   	ret    

0080254f <_pipeisclosed>:
{
  80254f:	55                   	push   %ebp
  802550:	89 e5                	mov    %esp,%ebp
  802552:	57                   	push   %edi
  802553:	56                   	push   %esi
  802554:	53                   	push   %ebx
  802555:	83 ec 1c             	sub    $0x1c,%esp
  802558:	89 c7                	mov    %eax,%edi
  80255a:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  80255c:	a1 04 50 80 00       	mov    0x805004,%eax
  802561:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802564:	83 ec 0c             	sub    $0xc,%esp
  802567:	57                   	push   %edi
  802568:	e8 ae 04 00 00       	call   802a1b <pageref>
  80256d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802570:	89 34 24             	mov    %esi,(%esp)
  802573:	e8 a3 04 00 00       	call   802a1b <pageref>
		nn = thisenv->env_runs;
  802578:	8b 15 04 50 80 00    	mov    0x805004,%edx
  80257e:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802581:	83 c4 10             	add    $0x10,%esp
  802584:	39 cb                	cmp    %ecx,%ebx
  802586:	74 1b                	je     8025a3 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802588:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  80258b:	75 cf                	jne    80255c <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  80258d:	8b 42 58             	mov    0x58(%edx),%eax
  802590:	6a 01                	push   $0x1
  802592:	50                   	push   %eax
  802593:	53                   	push   %ebx
  802594:	68 c9 34 80 00       	push   $0x8034c9
  802599:	e8 69 e0 ff ff       	call   800607 <cprintf>
  80259e:	83 c4 10             	add    $0x10,%esp
  8025a1:	eb b9                	jmp    80255c <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  8025a3:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  8025a6:	0f 94 c0             	sete   %al
  8025a9:	0f b6 c0             	movzbl %al,%eax
}
  8025ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8025af:	5b                   	pop    %ebx
  8025b0:	5e                   	pop    %esi
  8025b1:	5f                   	pop    %edi
  8025b2:	5d                   	pop    %ebp
  8025b3:	c3                   	ret    

008025b4 <devpipe_write>:
{
  8025b4:	f3 0f 1e fb          	endbr32 
  8025b8:	55                   	push   %ebp
  8025b9:	89 e5                	mov    %esp,%ebp
  8025bb:	57                   	push   %edi
  8025bc:	56                   	push   %esi
  8025bd:	53                   	push   %ebx
  8025be:	83 ec 28             	sub    $0x28,%esp
  8025c1:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  8025c4:	56                   	push   %esi
  8025c5:	e8 c3 f0 ff ff       	call   80168d <fd2data>
  8025ca:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  8025cc:	83 c4 10             	add    $0x10,%esp
  8025cf:	bf 00 00 00 00       	mov    $0x0,%edi
  8025d4:	3b 7d 10             	cmp    0x10(%ebp),%edi
  8025d7:	74 4f                	je     802628 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  8025d9:	8b 43 04             	mov    0x4(%ebx),%eax
  8025dc:	8b 0b                	mov    (%ebx),%ecx
  8025de:	8d 51 20             	lea    0x20(%ecx),%edx
  8025e1:	39 d0                	cmp    %edx,%eax
  8025e3:	72 14                	jb     8025f9 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  8025e5:	89 da                	mov    %ebx,%edx
  8025e7:	89 f0                	mov    %esi,%eax
  8025e9:	e8 61 ff ff ff       	call   80254f <_pipeisclosed>
  8025ee:	85 c0                	test   %eax,%eax
  8025f0:	75 3b                	jne    80262d <devpipe_write+0x79>
			sys_yield();
  8025f2:	e8 d7 e9 ff ff       	call   800fce <sys_yield>
  8025f7:	eb e0                	jmp    8025d9 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  8025f9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8025fc:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802600:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802603:	89 c2                	mov    %eax,%edx
  802605:	c1 fa 1f             	sar    $0x1f,%edx
  802608:	89 d1                	mov    %edx,%ecx
  80260a:	c1 e9 1b             	shr    $0x1b,%ecx
  80260d:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802610:	83 e2 1f             	and    $0x1f,%edx
  802613:	29 ca                	sub    %ecx,%edx
  802615:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802619:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  80261d:	83 c0 01             	add    $0x1,%eax
  802620:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802623:	83 c7 01             	add    $0x1,%edi
  802626:	eb ac                	jmp    8025d4 <devpipe_write+0x20>
	return i;
  802628:	8b 45 10             	mov    0x10(%ebp),%eax
  80262b:	eb 05                	jmp    802632 <devpipe_write+0x7e>
				return 0;
  80262d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802632:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802635:	5b                   	pop    %ebx
  802636:	5e                   	pop    %esi
  802637:	5f                   	pop    %edi
  802638:	5d                   	pop    %ebp
  802639:	c3                   	ret    

0080263a <devpipe_read>:
{
  80263a:	f3 0f 1e fb          	endbr32 
  80263e:	55                   	push   %ebp
  80263f:	89 e5                	mov    %esp,%ebp
  802641:	57                   	push   %edi
  802642:	56                   	push   %esi
  802643:	53                   	push   %ebx
  802644:	83 ec 18             	sub    $0x18,%esp
  802647:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  80264a:	57                   	push   %edi
  80264b:	e8 3d f0 ff ff       	call   80168d <fd2data>
  802650:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802652:	83 c4 10             	add    $0x10,%esp
  802655:	be 00 00 00 00       	mov    $0x0,%esi
  80265a:	3b 75 10             	cmp    0x10(%ebp),%esi
  80265d:	75 14                	jne    802673 <devpipe_read+0x39>
	return i;
  80265f:	8b 45 10             	mov    0x10(%ebp),%eax
  802662:	eb 02                	jmp    802666 <devpipe_read+0x2c>
				return i;
  802664:	89 f0                	mov    %esi,%eax
}
  802666:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802669:	5b                   	pop    %ebx
  80266a:	5e                   	pop    %esi
  80266b:	5f                   	pop    %edi
  80266c:	5d                   	pop    %ebp
  80266d:	c3                   	ret    
			sys_yield();
  80266e:	e8 5b e9 ff ff       	call   800fce <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802673:	8b 03                	mov    (%ebx),%eax
  802675:	3b 43 04             	cmp    0x4(%ebx),%eax
  802678:	75 18                	jne    802692 <devpipe_read+0x58>
			if (i > 0)
  80267a:	85 f6                	test   %esi,%esi
  80267c:	75 e6                	jne    802664 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  80267e:	89 da                	mov    %ebx,%edx
  802680:	89 f8                	mov    %edi,%eax
  802682:	e8 c8 fe ff ff       	call   80254f <_pipeisclosed>
  802687:	85 c0                	test   %eax,%eax
  802689:	74 e3                	je     80266e <devpipe_read+0x34>
				return 0;
  80268b:	b8 00 00 00 00       	mov    $0x0,%eax
  802690:	eb d4                	jmp    802666 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802692:	99                   	cltd   
  802693:	c1 ea 1b             	shr    $0x1b,%edx
  802696:	01 d0                	add    %edx,%eax
  802698:	83 e0 1f             	and    $0x1f,%eax
  80269b:	29 d0                	sub    %edx,%eax
  80269d:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  8026a2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8026a5:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  8026a8:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  8026ab:	83 c6 01             	add    $0x1,%esi
  8026ae:	eb aa                	jmp    80265a <devpipe_read+0x20>

008026b0 <pipe>:
{
  8026b0:	f3 0f 1e fb          	endbr32 
  8026b4:	55                   	push   %ebp
  8026b5:	89 e5                	mov    %esp,%ebp
  8026b7:	56                   	push   %esi
  8026b8:	53                   	push   %ebx
  8026b9:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  8026bc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8026bf:	50                   	push   %eax
  8026c0:	e8 e7 ef ff ff       	call   8016ac <fd_alloc>
  8026c5:	89 c3                	mov    %eax,%ebx
  8026c7:	83 c4 10             	add    $0x10,%esp
  8026ca:	85 c0                	test   %eax,%eax
  8026cc:	0f 88 23 01 00 00    	js     8027f5 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8026d2:	83 ec 04             	sub    $0x4,%esp
  8026d5:	68 07 04 00 00       	push   $0x407
  8026da:	ff 75 f4             	pushl  -0xc(%ebp)
  8026dd:	6a 00                	push   $0x0
  8026df:	e8 15 e9 ff ff       	call   800ff9 <sys_page_alloc>
  8026e4:	89 c3                	mov    %eax,%ebx
  8026e6:	83 c4 10             	add    $0x10,%esp
  8026e9:	85 c0                	test   %eax,%eax
  8026eb:	0f 88 04 01 00 00    	js     8027f5 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  8026f1:	83 ec 0c             	sub    $0xc,%esp
  8026f4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8026f7:	50                   	push   %eax
  8026f8:	e8 af ef ff ff       	call   8016ac <fd_alloc>
  8026fd:	89 c3                	mov    %eax,%ebx
  8026ff:	83 c4 10             	add    $0x10,%esp
  802702:	85 c0                	test   %eax,%eax
  802704:	0f 88 db 00 00 00    	js     8027e5 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80270a:	83 ec 04             	sub    $0x4,%esp
  80270d:	68 07 04 00 00       	push   $0x407
  802712:	ff 75 f0             	pushl  -0x10(%ebp)
  802715:	6a 00                	push   $0x0
  802717:	e8 dd e8 ff ff       	call   800ff9 <sys_page_alloc>
  80271c:	89 c3                	mov    %eax,%ebx
  80271e:	83 c4 10             	add    $0x10,%esp
  802721:	85 c0                	test   %eax,%eax
  802723:	0f 88 bc 00 00 00    	js     8027e5 <pipe+0x135>
	va = fd2data(fd0);
  802729:	83 ec 0c             	sub    $0xc,%esp
  80272c:	ff 75 f4             	pushl  -0xc(%ebp)
  80272f:	e8 59 ef ff ff       	call   80168d <fd2data>
  802734:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802736:	83 c4 0c             	add    $0xc,%esp
  802739:	68 07 04 00 00       	push   $0x407
  80273e:	50                   	push   %eax
  80273f:	6a 00                	push   $0x0
  802741:	e8 b3 e8 ff ff       	call   800ff9 <sys_page_alloc>
  802746:	89 c3                	mov    %eax,%ebx
  802748:	83 c4 10             	add    $0x10,%esp
  80274b:	85 c0                	test   %eax,%eax
  80274d:	0f 88 82 00 00 00    	js     8027d5 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802753:	83 ec 0c             	sub    $0xc,%esp
  802756:	ff 75 f0             	pushl  -0x10(%ebp)
  802759:	e8 2f ef ff ff       	call   80168d <fd2data>
  80275e:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  802765:	50                   	push   %eax
  802766:	6a 00                	push   $0x0
  802768:	56                   	push   %esi
  802769:	6a 00                	push   $0x0
  80276b:	e8 b1 e8 ff ff       	call   801021 <sys_page_map>
  802770:	89 c3                	mov    %eax,%ebx
  802772:	83 c4 20             	add    $0x20,%esp
  802775:	85 c0                	test   %eax,%eax
  802777:	78 4e                	js     8027c7 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  802779:	a1 3c 40 80 00       	mov    0x80403c,%eax
  80277e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802781:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  802783:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802786:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  80278d:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802790:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  802792:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802795:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  80279c:	83 ec 0c             	sub    $0xc,%esp
  80279f:	ff 75 f4             	pushl  -0xc(%ebp)
  8027a2:	e8 d2 ee ff ff       	call   801679 <fd2num>
  8027a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8027aa:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  8027ac:	83 c4 04             	add    $0x4,%esp
  8027af:	ff 75 f0             	pushl  -0x10(%ebp)
  8027b2:	e8 c2 ee ff ff       	call   801679 <fd2num>
  8027b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8027ba:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  8027bd:	83 c4 10             	add    $0x10,%esp
  8027c0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8027c5:	eb 2e                	jmp    8027f5 <pipe+0x145>
	sys_page_unmap(0, va);
  8027c7:	83 ec 08             	sub    $0x8,%esp
  8027ca:	56                   	push   %esi
  8027cb:	6a 00                	push   $0x0
  8027cd:	e8 79 e8 ff ff       	call   80104b <sys_page_unmap>
  8027d2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8027d5:	83 ec 08             	sub    $0x8,%esp
  8027d8:	ff 75 f0             	pushl  -0x10(%ebp)
  8027db:	6a 00                	push   $0x0
  8027dd:	e8 69 e8 ff ff       	call   80104b <sys_page_unmap>
  8027e2:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8027e5:	83 ec 08             	sub    $0x8,%esp
  8027e8:	ff 75 f4             	pushl  -0xc(%ebp)
  8027eb:	6a 00                	push   $0x0
  8027ed:	e8 59 e8 ff ff       	call   80104b <sys_page_unmap>
  8027f2:	83 c4 10             	add    $0x10,%esp
}
  8027f5:	89 d8                	mov    %ebx,%eax
  8027f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8027fa:	5b                   	pop    %ebx
  8027fb:	5e                   	pop    %esi
  8027fc:	5d                   	pop    %ebp
  8027fd:	c3                   	ret    

008027fe <pipeisclosed>:
{
  8027fe:	f3 0f 1e fb          	endbr32 
  802802:	55                   	push   %ebp
  802803:	89 e5                	mov    %esp,%ebp
  802805:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  802808:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80280b:	50                   	push   %eax
  80280c:	ff 75 08             	pushl  0x8(%ebp)
  80280f:	e8 ee ee ff ff       	call   801702 <fd_lookup>
  802814:	83 c4 10             	add    $0x10,%esp
  802817:	85 c0                	test   %eax,%eax
  802819:	78 18                	js     802833 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  80281b:	83 ec 0c             	sub    $0xc,%esp
  80281e:	ff 75 f4             	pushl  -0xc(%ebp)
  802821:	e8 67 ee ff ff       	call   80168d <fd2data>
  802826:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  802828:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80282b:	e8 1f fd ff ff       	call   80254f <_pipeisclosed>
  802830:	83 c4 10             	add    $0x10,%esp
}
  802833:	c9                   	leave  
  802834:	c3                   	ret    

00802835 <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  802835:	f3 0f 1e fb          	endbr32 
  802839:	55                   	push   %ebp
  80283a:	89 e5                	mov    %esp,%ebp
  80283c:	56                   	push   %esi
  80283d:	53                   	push   %ebx
  80283e:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  802841:	85 f6                	test   %esi,%esi
  802843:	74 13                	je     802858 <wait+0x23>
	e = &envs[ENVX(envid)];
  802845:	89 f3                	mov    %esi,%ebx
  802847:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80284d:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802850:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  802856:	eb 1b                	jmp    802873 <wait+0x3e>
	assert(envid != 0);
  802858:	68 e1 34 80 00       	push   $0x8034e1
  80285d:	68 e3 33 80 00       	push   $0x8033e3
  802862:	6a 09                	push   $0x9
  802864:	68 ec 34 80 00       	push   $0x8034ec
  802869:	e8 b2 dc ff ff       	call   800520 <_panic>
		sys_yield();
  80286e:	e8 5b e7 ff ff       	call   800fce <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802873:	8b 43 48             	mov    0x48(%ebx),%eax
  802876:	39 f0                	cmp    %esi,%eax
  802878:	75 07                	jne    802881 <wait+0x4c>
  80287a:	8b 43 54             	mov    0x54(%ebx),%eax
  80287d:	85 c0                	test   %eax,%eax
  80287f:	75 ed                	jne    80286e <wait+0x39>
}
  802881:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802884:	5b                   	pop    %ebx
  802885:	5e                   	pop    %esi
  802886:	5d                   	pop    %ebp
  802887:	c3                   	ret    

00802888 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  802888:	f3 0f 1e fb          	endbr32 
  80288c:	55                   	push   %ebp
  80288d:	89 e5                	mov    %esp,%ebp
  80288f:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  802892:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  802899:	74 1c                	je     8028b7 <set_pgfault_handler+0x2f>
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  80289b:	8b 45 08             	mov    0x8(%ebp),%eax
  80289e:	a3 00 70 80 00       	mov    %eax,0x807000

	//Indicarle al kerne que _pgfault_upcall va a ser el manejador de pgfaults de un proceso
	sys_env_set_pgfault_upcall(0, &(_pgfault_upcall));
  8028a3:	83 ec 08             	sub    $0x8,%esp
  8028a6:	68 e3 28 80 00       	push   $0x8028e3
  8028ab:	6a 00                	push   $0x0
  8028ad:	e8 0e e8 ff ff       	call   8010c0 <sys_env_set_pgfault_upcall>
}
  8028b2:	83 c4 10             	add    $0x10,%esp
  8028b5:	c9                   	leave  
  8028b6:	c3                   	ret    
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
  8028b7:	83 ec 04             	sub    $0x4,%esp
  8028ba:	6a 02                	push   $0x2
  8028bc:	68 00 f0 bf ee       	push   $0xeebff000
  8028c1:	6a 00                	push   $0x0
  8028c3:	e8 31 e7 ff ff       	call   800ff9 <sys_page_alloc>
  8028c8:	83 c4 10             	add    $0x10,%esp
  8028cb:	85 c0                	test   %eax,%eax
  8028cd:	79 cc                	jns    80289b <set_pgfault_handler+0x13>
  8028cf:	83 ec 04             	sub    $0x4,%esp
  8028d2:	68 f7 34 80 00       	push   $0x8034f7
  8028d7:	6a 20                	push   $0x20
  8028d9:	68 12 35 80 00       	push   $0x803512
  8028de:	e8 3d dc ff ff       	call   800520 <_panic>

008028e3 <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8028e3:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8028e4:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8028e9:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8028eb:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 40(%esp), %eax
  8028ee:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	
  8028f2:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  8028f6:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, (%ebx)
  8028f9:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 48(%esp)
  8028fb:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8028ff:	83 c4 08             	add    $0x8,%esp
	popal
  802902:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  802903:	83 c4 04             	add    $0x4,%esp
	popfl
  802906:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  802907:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  80290a:	c3                   	ret    

0080290b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80290b:	f3 0f 1e fb          	endbr32 
  80290f:	55                   	push   %ebp
  802910:	89 e5                	mov    %esp,%ebp
  802912:	56                   	push   %esi
  802913:	53                   	push   %ebx
  802914:	8b 75 08             	mov    0x8(%ebp),%esi
  802917:	8b 45 0c             	mov    0xc(%ebp),%eax
  80291a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  80291d:	85 c0                	test   %eax,%eax
  80291f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  802924:	0f 44 c2             	cmove  %edx,%eax
  802927:	83 ec 0c             	sub    $0xc,%esp
  80292a:	50                   	push   %eax
  80292b:	e8 e0 e7 ff ff       	call   801110 <sys_ipc_recv>

	if (from_env_store != NULL)
  802930:	83 c4 10             	add    $0x10,%esp
  802933:	85 f6                	test   %esi,%esi
  802935:	74 15                	je     80294c <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  802937:	ba 00 00 00 00       	mov    $0x0,%edx
  80293c:	83 f8 fd             	cmp    $0xfffffffd,%eax
  80293f:	74 09                	je     80294a <ipc_recv+0x3f>
  802941:	8b 15 04 50 80 00    	mov    0x805004,%edx
  802947:	8b 52 74             	mov    0x74(%edx),%edx
  80294a:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  80294c:	85 db                	test   %ebx,%ebx
  80294e:	74 15                	je     802965 <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  802950:	ba 00 00 00 00       	mov    $0x0,%edx
  802955:	83 f8 fd             	cmp    $0xfffffffd,%eax
  802958:	74 09                	je     802963 <ipc_recv+0x58>
  80295a:	8b 15 04 50 80 00    	mov    0x805004,%edx
  802960:	8b 52 78             	mov    0x78(%edx),%edx
  802963:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  802965:	83 f8 fd             	cmp    $0xfffffffd,%eax
  802968:	74 08                	je     802972 <ipc_recv+0x67>
  80296a:	a1 04 50 80 00       	mov    0x805004,%eax
  80296f:	8b 40 70             	mov    0x70(%eax),%eax
}
  802972:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802975:	5b                   	pop    %ebx
  802976:	5e                   	pop    %esi
  802977:	5d                   	pop    %ebp
  802978:	c3                   	ret    

00802979 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  802979:	f3 0f 1e fb          	endbr32 
  80297d:	55                   	push   %ebp
  80297e:	89 e5                	mov    %esp,%ebp
  802980:	57                   	push   %edi
  802981:	56                   	push   %esi
  802982:	53                   	push   %ebx
  802983:	83 ec 0c             	sub    $0xc,%esp
  802986:	8b 7d 08             	mov    0x8(%ebp),%edi
  802989:	8b 75 0c             	mov    0xc(%ebp),%esi
  80298c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80298f:	eb 1f                	jmp    8029b0 <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  802991:	6a 00                	push   $0x0
  802993:	68 00 00 c0 ee       	push   $0xeec00000
  802998:	56                   	push   %esi
  802999:	57                   	push   %edi
  80299a:	e8 48 e7 ff ff       	call   8010e7 <sys_ipc_try_send>
  80299f:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  8029a2:	85 c0                	test   %eax,%eax
  8029a4:	74 30                	je     8029d6 <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  8029a6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8029a9:	75 19                	jne    8029c4 <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  8029ab:	e8 1e e6 ff ff       	call   800fce <sys_yield>
		if (pg != NULL) {
  8029b0:	85 db                	test   %ebx,%ebx
  8029b2:	74 dd                	je     802991 <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  8029b4:	ff 75 14             	pushl  0x14(%ebp)
  8029b7:	53                   	push   %ebx
  8029b8:	56                   	push   %esi
  8029b9:	57                   	push   %edi
  8029ba:	e8 28 e7 ff ff       	call   8010e7 <sys_ipc_try_send>
  8029bf:	83 c4 10             	add    $0x10,%esp
  8029c2:	eb de                	jmp    8029a2 <ipc_send+0x29>
			panic("ipc_send: %d", res);
  8029c4:	50                   	push   %eax
  8029c5:	68 20 35 80 00       	push   $0x803520
  8029ca:	6a 3e                	push   $0x3e
  8029cc:	68 2d 35 80 00       	push   $0x80352d
  8029d1:	e8 4a db ff ff       	call   800520 <_panic>
	}
}
  8029d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8029d9:	5b                   	pop    %ebx
  8029da:	5e                   	pop    %esi
  8029db:	5f                   	pop    %edi
  8029dc:	5d                   	pop    %ebp
  8029dd:	c3                   	ret    

008029de <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8029de:	f3 0f 1e fb          	endbr32 
  8029e2:	55                   	push   %ebp
  8029e3:	89 e5                	mov    %esp,%ebp
  8029e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8029e8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8029ed:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8029f0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8029f6:	8b 52 50             	mov    0x50(%edx),%edx
  8029f9:	39 ca                	cmp    %ecx,%edx
  8029fb:	74 11                	je     802a0e <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8029fd:	83 c0 01             	add    $0x1,%eax
  802a00:	3d 00 04 00 00       	cmp    $0x400,%eax
  802a05:	75 e6                	jne    8029ed <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  802a07:	b8 00 00 00 00       	mov    $0x0,%eax
  802a0c:	eb 0b                	jmp    802a19 <ipc_find_env+0x3b>
			return envs[i].env_id;
  802a0e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802a11:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  802a16:	8b 40 48             	mov    0x48(%eax),%eax
}
  802a19:	5d                   	pop    %ebp
  802a1a:	c3                   	ret    

00802a1b <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802a1b:	f3 0f 1e fb          	endbr32 
  802a1f:	55                   	push   %ebp
  802a20:	89 e5                	mov    %esp,%ebp
  802a22:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  802a25:	89 c2                	mov    %eax,%edx
  802a27:	c1 ea 16             	shr    $0x16,%edx
  802a2a:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802a31:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  802a36:	f6 c1 01             	test   $0x1,%cl
  802a39:	74 1c                	je     802a57 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802a3b:	c1 e8 0c             	shr    $0xc,%eax
  802a3e:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  802a45:	a8 01                	test   $0x1,%al
  802a47:	74 0e                	je     802a57 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802a49:	c1 e8 0c             	shr    $0xc,%eax
  802a4c:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802a53:	ef 
  802a54:	0f b7 d2             	movzwl %dx,%edx
}
  802a57:	89 d0                	mov    %edx,%eax
  802a59:	5d                   	pop    %ebp
  802a5a:	c3                   	ret    
  802a5b:	66 90                	xchg   %ax,%ax
  802a5d:	66 90                	xchg   %ax,%ax
  802a5f:	90                   	nop

00802a60 <__udivdi3>:
  802a60:	f3 0f 1e fb          	endbr32 
  802a64:	55                   	push   %ebp
  802a65:	57                   	push   %edi
  802a66:	56                   	push   %esi
  802a67:	53                   	push   %ebx
  802a68:	83 ec 1c             	sub    $0x1c,%esp
  802a6b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  802a6f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  802a73:	8b 74 24 34          	mov    0x34(%esp),%esi
  802a77:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  802a7b:	85 d2                	test   %edx,%edx
  802a7d:	75 19                	jne    802a98 <__udivdi3+0x38>
  802a7f:	39 f3                	cmp    %esi,%ebx
  802a81:	76 4d                	jbe    802ad0 <__udivdi3+0x70>
  802a83:	31 ff                	xor    %edi,%edi
  802a85:	89 e8                	mov    %ebp,%eax
  802a87:	89 f2                	mov    %esi,%edx
  802a89:	f7 f3                	div    %ebx
  802a8b:	89 fa                	mov    %edi,%edx
  802a8d:	83 c4 1c             	add    $0x1c,%esp
  802a90:	5b                   	pop    %ebx
  802a91:	5e                   	pop    %esi
  802a92:	5f                   	pop    %edi
  802a93:	5d                   	pop    %ebp
  802a94:	c3                   	ret    
  802a95:	8d 76 00             	lea    0x0(%esi),%esi
  802a98:	39 f2                	cmp    %esi,%edx
  802a9a:	76 14                	jbe    802ab0 <__udivdi3+0x50>
  802a9c:	31 ff                	xor    %edi,%edi
  802a9e:	31 c0                	xor    %eax,%eax
  802aa0:	89 fa                	mov    %edi,%edx
  802aa2:	83 c4 1c             	add    $0x1c,%esp
  802aa5:	5b                   	pop    %ebx
  802aa6:	5e                   	pop    %esi
  802aa7:	5f                   	pop    %edi
  802aa8:	5d                   	pop    %ebp
  802aa9:	c3                   	ret    
  802aaa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802ab0:	0f bd fa             	bsr    %edx,%edi
  802ab3:	83 f7 1f             	xor    $0x1f,%edi
  802ab6:	75 48                	jne    802b00 <__udivdi3+0xa0>
  802ab8:	39 f2                	cmp    %esi,%edx
  802aba:	72 06                	jb     802ac2 <__udivdi3+0x62>
  802abc:	31 c0                	xor    %eax,%eax
  802abe:	39 eb                	cmp    %ebp,%ebx
  802ac0:	77 de                	ja     802aa0 <__udivdi3+0x40>
  802ac2:	b8 01 00 00 00       	mov    $0x1,%eax
  802ac7:	eb d7                	jmp    802aa0 <__udivdi3+0x40>
  802ac9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802ad0:	89 d9                	mov    %ebx,%ecx
  802ad2:	85 db                	test   %ebx,%ebx
  802ad4:	75 0b                	jne    802ae1 <__udivdi3+0x81>
  802ad6:	b8 01 00 00 00       	mov    $0x1,%eax
  802adb:	31 d2                	xor    %edx,%edx
  802add:	f7 f3                	div    %ebx
  802adf:	89 c1                	mov    %eax,%ecx
  802ae1:	31 d2                	xor    %edx,%edx
  802ae3:	89 f0                	mov    %esi,%eax
  802ae5:	f7 f1                	div    %ecx
  802ae7:	89 c6                	mov    %eax,%esi
  802ae9:	89 e8                	mov    %ebp,%eax
  802aeb:	89 f7                	mov    %esi,%edi
  802aed:	f7 f1                	div    %ecx
  802aef:	89 fa                	mov    %edi,%edx
  802af1:	83 c4 1c             	add    $0x1c,%esp
  802af4:	5b                   	pop    %ebx
  802af5:	5e                   	pop    %esi
  802af6:	5f                   	pop    %edi
  802af7:	5d                   	pop    %ebp
  802af8:	c3                   	ret    
  802af9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802b00:	89 f9                	mov    %edi,%ecx
  802b02:	b8 20 00 00 00       	mov    $0x20,%eax
  802b07:	29 f8                	sub    %edi,%eax
  802b09:	d3 e2                	shl    %cl,%edx
  802b0b:	89 54 24 08          	mov    %edx,0x8(%esp)
  802b0f:	89 c1                	mov    %eax,%ecx
  802b11:	89 da                	mov    %ebx,%edx
  802b13:	d3 ea                	shr    %cl,%edx
  802b15:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802b19:	09 d1                	or     %edx,%ecx
  802b1b:	89 f2                	mov    %esi,%edx
  802b1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802b21:	89 f9                	mov    %edi,%ecx
  802b23:	d3 e3                	shl    %cl,%ebx
  802b25:	89 c1                	mov    %eax,%ecx
  802b27:	d3 ea                	shr    %cl,%edx
  802b29:	89 f9                	mov    %edi,%ecx
  802b2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  802b2f:	89 eb                	mov    %ebp,%ebx
  802b31:	d3 e6                	shl    %cl,%esi
  802b33:	89 c1                	mov    %eax,%ecx
  802b35:	d3 eb                	shr    %cl,%ebx
  802b37:	09 de                	or     %ebx,%esi
  802b39:	89 f0                	mov    %esi,%eax
  802b3b:	f7 74 24 08          	divl   0x8(%esp)
  802b3f:	89 d6                	mov    %edx,%esi
  802b41:	89 c3                	mov    %eax,%ebx
  802b43:	f7 64 24 0c          	mull   0xc(%esp)
  802b47:	39 d6                	cmp    %edx,%esi
  802b49:	72 15                	jb     802b60 <__udivdi3+0x100>
  802b4b:	89 f9                	mov    %edi,%ecx
  802b4d:	d3 e5                	shl    %cl,%ebp
  802b4f:	39 c5                	cmp    %eax,%ebp
  802b51:	73 04                	jae    802b57 <__udivdi3+0xf7>
  802b53:	39 d6                	cmp    %edx,%esi
  802b55:	74 09                	je     802b60 <__udivdi3+0x100>
  802b57:	89 d8                	mov    %ebx,%eax
  802b59:	31 ff                	xor    %edi,%edi
  802b5b:	e9 40 ff ff ff       	jmp    802aa0 <__udivdi3+0x40>
  802b60:	8d 43 ff             	lea    -0x1(%ebx),%eax
  802b63:	31 ff                	xor    %edi,%edi
  802b65:	e9 36 ff ff ff       	jmp    802aa0 <__udivdi3+0x40>
  802b6a:	66 90                	xchg   %ax,%ax
  802b6c:	66 90                	xchg   %ax,%ax
  802b6e:	66 90                	xchg   %ax,%ax

00802b70 <__umoddi3>:
  802b70:	f3 0f 1e fb          	endbr32 
  802b74:	55                   	push   %ebp
  802b75:	57                   	push   %edi
  802b76:	56                   	push   %esi
  802b77:	53                   	push   %ebx
  802b78:	83 ec 1c             	sub    $0x1c,%esp
  802b7b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  802b7f:	8b 74 24 30          	mov    0x30(%esp),%esi
  802b83:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  802b87:	8b 7c 24 38          	mov    0x38(%esp),%edi
  802b8b:	85 c0                	test   %eax,%eax
  802b8d:	75 19                	jne    802ba8 <__umoddi3+0x38>
  802b8f:	39 df                	cmp    %ebx,%edi
  802b91:	76 5d                	jbe    802bf0 <__umoddi3+0x80>
  802b93:	89 f0                	mov    %esi,%eax
  802b95:	89 da                	mov    %ebx,%edx
  802b97:	f7 f7                	div    %edi
  802b99:	89 d0                	mov    %edx,%eax
  802b9b:	31 d2                	xor    %edx,%edx
  802b9d:	83 c4 1c             	add    $0x1c,%esp
  802ba0:	5b                   	pop    %ebx
  802ba1:	5e                   	pop    %esi
  802ba2:	5f                   	pop    %edi
  802ba3:	5d                   	pop    %ebp
  802ba4:	c3                   	ret    
  802ba5:	8d 76 00             	lea    0x0(%esi),%esi
  802ba8:	89 f2                	mov    %esi,%edx
  802baa:	39 d8                	cmp    %ebx,%eax
  802bac:	76 12                	jbe    802bc0 <__umoddi3+0x50>
  802bae:	89 f0                	mov    %esi,%eax
  802bb0:	89 da                	mov    %ebx,%edx
  802bb2:	83 c4 1c             	add    $0x1c,%esp
  802bb5:	5b                   	pop    %ebx
  802bb6:	5e                   	pop    %esi
  802bb7:	5f                   	pop    %edi
  802bb8:	5d                   	pop    %ebp
  802bb9:	c3                   	ret    
  802bba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802bc0:	0f bd e8             	bsr    %eax,%ebp
  802bc3:	83 f5 1f             	xor    $0x1f,%ebp
  802bc6:	75 50                	jne    802c18 <__umoddi3+0xa8>
  802bc8:	39 d8                	cmp    %ebx,%eax
  802bca:	0f 82 e0 00 00 00    	jb     802cb0 <__umoddi3+0x140>
  802bd0:	89 d9                	mov    %ebx,%ecx
  802bd2:	39 f7                	cmp    %esi,%edi
  802bd4:	0f 86 d6 00 00 00    	jbe    802cb0 <__umoddi3+0x140>
  802bda:	89 d0                	mov    %edx,%eax
  802bdc:	89 ca                	mov    %ecx,%edx
  802bde:	83 c4 1c             	add    $0x1c,%esp
  802be1:	5b                   	pop    %ebx
  802be2:	5e                   	pop    %esi
  802be3:	5f                   	pop    %edi
  802be4:	5d                   	pop    %ebp
  802be5:	c3                   	ret    
  802be6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802bed:	8d 76 00             	lea    0x0(%esi),%esi
  802bf0:	89 fd                	mov    %edi,%ebp
  802bf2:	85 ff                	test   %edi,%edi
  802bf4:	75 0b                	jne    802c01 <__umoddi3+0x91>
  802bf6:	b8 01 00 00 00       	mov    $0x1,%eax
  802bfb:	31 d2                	xor    %edx,%edx
  802bfd:	f7 f7                	div    %edi
  802bff:	89 c5                	mov    %eax,%ebp
  802c01:	89 d8                	mov    %ebx,%eax
  802c03:	31 d2                	xor    %edx,%edx
  802c05:	f7 f5                	div    %ebp
  802c07:	89 f0                	mov    %esi,%eax
  802c09:	f7 f5                	div    %ebp
  802c0b:	89 d0                	mov    %edx,%eax
  802c0d:	31 d2                	xor    %edx,%edx
  802c0f:	eb 8c                	jmp    802b9d <__umoddi3+0x2d>
  802c11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802c18:	89 e9                	mov    %ebp,%ecx
  802c1a:	ba 20 00 00 00       	mov    $0x20,%edx
  802c1f:	29 ea                	sub    %ebp,%edx
  802c21:	d3 e0                	shl    %cl,%eax
  802c23:	89 44 24 08          	mov    %eax,0x8(%esp)
  802c27:	89 d1                	mov    %edx,%ecx
  802c29:	89 f8                	mov    %edi,%eax
  802c2b:	d3 e8                	shr    %cl,%eax
  802c2d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802c31:	89 54 24 04          	mov    %edx,0x4(%esp)
  802c35:	8b 54 24 04          	mov    0x4(%esp),%edx
  802c39:	09 c1                	or     %eax,%ecx
  802c3b:	89 d8                	mov    %ebx,%eax
  802c3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802c41:	89 e9                	mov    %ebp,%ecx
  802c43:	d3 e7                	shl    %cl,%edi
  802c45:	89 d1                	mov    %edx,%ecx
  802c47:	d3 e8                	shr    %cl,%eax
  802c49:	89 e9                	mov    %ebp,%ecx
  802c4b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  802c4f:	d3 e3                	shl    %cl,%ebx
  802c51:	89 c7                	mov    %eax,%edi
  802c53:	89 d1                	mov    %edx,%ecx
  802c55:	89 f0                	mov    %esi,%eax
  802c57:	d3 e8                	shr    %cl,%eax
  802c59:	89 e9                	mov    %ebp,%ecx
  802c5b:	89 fa                	mov    %edi,%edx
  802c5d:	d3 e6                	shl    %cl,%esi
  802c5f:	09 d8                	or     %ebx,%eax
  802c61:	f7 74 24 08          	divl   0x8(%esp)
  802c65:	89 d1                	mov    %edx,%ecx
  802c67:	89 f3                	mov    %esi,%ebx
  802c69:	f7 64 24 0c          	mull   0xc(%esp)
  802c6d:	89 c6                	mov    %eax,%esi
  802c6f:	89 d7                	mov    %edx,%edi
  802c71:	39 d1                	cmp    %edx,%ecx
  802c73:	72 06                	jb     802c7b <__umoddi3+0x10b>
  802c75:	75 10                	jne    802c87 <__umoddi3+0x117>
  802c77:	39 c3                	cmp    %eax,%ebx
  802c79:	73 0c                	jae    802c87 <__umoddi3+0x117>
  802c7b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  802c7f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802c83:	89 d7                	mov    %edx,%edi
  802c85:	89 c6                	mov    %eax,%esi
  802c87:	89 ca                	mov    %ecx,%edx
  802c89:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  802c8e:	29 f3                	sub    %esi,%ebx
  802c90:	19 fa                	sbb    %edi,%edx
  802c92:	89 d0                	mov    %edx,%eax
  802c94:	d3 e0                	shl    %cl,%eax
  802c96:	89 e9                	mov    %ebp,%ecx
  802c98:	d3 eb                	shr    %cl,%ebx
  802c9a:	d3 ea                	shr    %cl,%edx
  802c9c:	09 d8                	or     %ebx,%eax
  802c9e:	83 c4 1c             	add    $0x1c,%esp
  802ca1:	5b                   	pop    %ebx
  802ca2:	5e                   	pop    %esi
  802ca3:	5f                   	pop    %edi
  802ca4:	5d                   	pop    %ebp
  802ca5:	c3                   	ret    
  802ca6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802cad:	8d 76 00             	lea    0x0(%esi),%esi
  802cb0:	29 fe                	sub    %edi,%esi
  802cb2:	19 c3                	sbb    %eax,%ebx
  802cb4:	89 f2                	mov    %esi,%edx
  802cb6:	89 d9                	mov    %ebx,%ecx
  802cb8:	e9 1d ff ff ff       	jmp    802bda <__umoddi3+0x6a>
