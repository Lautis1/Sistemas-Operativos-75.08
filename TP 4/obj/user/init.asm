
obj/user/init.debug:     formato del fichero elf32-i386


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
  80002c:	e8 8f 03 00 00       	call   8003c0 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <sum>:

char bss[6000];

int
sum(const char *s, int n)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	56                   	push   %esi
  80003b:	53                   	push   %ebx
  80003c:	8b 75 08             	mov    0x8(%ebp),%esi
  80003f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int i, tot = 0;
  800042:	b9 00 00 00 00       	mov    $0x0,%ecx
	for (i = 0; i < n; i++)
  800047:	b8 00 00 00 00       	mov    $0x0,%eax
  80004c:	39 d8                	cmp    %ebx,%eax
  80004e:	7d 0e                	jge    80005e <sum+0x2b>
		tot ^= i * s[i];
  800050:	0f be 14 06          	movsbl (%esi,%eax,1),%edx
  800054:	0f af d0             	imul   %eax,%edx
  800057:	31 d1                	xor    %edx,%ecx
	for (i = 0; i < n; i++)
  800059:	83 c0 01             	add    $0x1,%eax
  80005c:	eb ee                	jmp    80004c <sum+0x19>
	return tot;
}
  80005e:	89 c8                	mov    %ecx,%eax
  800060:	5b                   	pop    %ebx
  800061:	5e                   	pop    %esi
  800062:	5d                   	pop    %ebp
  800063:	c3                   	ret    

00800064 <umain>:

void
umain(int argc, char **argv)
{
  800064:	f3 0f 1e fb          	endbr32 
  800068:	55                   	push   %ebp
  800069:	89 e5                	mov    %esp,%ebp
  80006b:	57                   	push   %edi
  80006c:	56                   	push   %esi
  80006d:	53                   	push   %ebx
  80006e:	81 ec 18 01 00 00    	sub    $0x118,%esp
  800074:	8b 7d 08             	mov    0x8(%ebp),%edi
	int i, r, x, want;
	char args[256];

	cprintf("init: running\n");
  800077:	68 20 26 80 00       	push   $0x802620
  80007c:	e8 92 04 00 00       	call   800513 <cprintf>

	want = 0xf989e;
	if ((x = sum((char*)&data, sizeof data)) != want)
  800081:	83 c4 08             	add    $0x8,%esp
  800084:	68 70 17 00 00       	push   $0x1770
  800089:	68 00 30 80 00       	push   $0x803000
  80008e:	e8 a0 ff ff ff       	call   800033 <sum>
  800093:	83 c4 10             	add    $0x10,%esp
  800096:	3d 9e 98 0f 00       	cmp    $0xf989e,%eax
  80009b:	0f 84 99 00 00 00    	je     80013a <umain+0xd6>
		cprintf("init: data is not initialized: got sum %08x wanted %08x\n",
  8000a1:	83 ec 04             	sub    $0x4,%esp
  8000a4:	68 9e 98 0f 00       	push   $0xf989e
  8000a9:	50                   	push   %eax
  8000aa:	68 e8 26 80 00       	push   $0x8026e8
  8000af:	e8 5f 04 00 00       	call   800513 <cprintf>
  8000b4:	83 c4 10             	add    $0x10,%esp
			x, want);
	else
		cprintf("init: data seems okay\n");
	if ((x = sum(bss, sizeof bss)) != 0)
  8000b7:	83 ec 08             	sub    $0x8,%esp
  8000ba:	68 70 17 00 00       	push   $0x1770
  8000bf:	68 20 50 80 00       	push   $0x805020
  8000c4:	e8 6a ff ff ff       	call   800033 <sum>
  8000c9:	83 c4 10             	add    $0x10,%esp
  8000cc:	85 c0                	test   %eax,%eax
  8000ce:	74 7f                	je     80014f <umain+0xeb>
		cprintf("bss is not initialized: wanted sum 0 got %08x\n", x);
  8000d0:	83 ec 08             	sub    $0x8,%esp
  8000d3:	50                   	push   %eax
  8000d4:	68 24 27 80 00       	push   $0x802724
  8000d9:	e8 35 04 00 00       	call   800513 <cprintf>
  8000de:	83 c4 10             	add    $0x10,%esp
	else
		cprintf("init: bss seems okay\n");

	// output in one syscall per line to avoid output interleaving 
	strcat(args, "init: args:");
  8000e1:	83 ec 08             	sub    $0x8,%esp
  8000e4:	68 5c 26 80 00       	push   $0x80265c
  8000e9:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8000ef:	50                   	push   %eax
  8000f0:	e8 ae 09 00 00       	call   800aa3 <strcat>
	for (i = 0; i < argc; i++) {
  8000f5:	83 c4 10             	add    $0x10,%esp
  8000f8:	bb 00 00 00 00       	mov    $0x0,%ebx
		strcat(args, " '");
  8000fd:	8d b5 e8 fe ff ff    	lea    -0x118(%ebp),%esi
	for (i = 0; i < argc; i++) {
  800103:	39 fb                	cmp    %edi,%ebx
  800105:	7d 5a                	jge    800161 <umain+0xfd>
		strcat(args, " '");
  800107:	83 ec 08             	sub    $0x8,%esp
  80010a:	68 68 26 80 00       	push   $0x802668
  80010f:	56                   	push   %esi
  800110:	e8 8e 09 00 00       	call   800aa3 <strcat>
		strcat(args, argv[i]);
  800115:	83 c4 08             	add    $0x8,%esp
  800118:	8b 45 0c             	mov    0xc(%ebp),%eax
  80011b:	ff 34 98             	pushl  (%eax,%ebx,4)
  80011e:	56                   	push   %esi
  80011f:	e8 7f 09 00 00       	call   800aa3 <strcat>
		strcat(args, "'");
  800124:	83 c4 08             	add    $0x8,%esp
  800127:	68 69 26 80 00       	push   $0x802669
  80012c:	56                   	push   %esi
  80012d:	e8 71 09 00 00       	call   800aa3 <strcat>
	for (i = 0; i < argc; i++) {
  800132:	83 c3 01             	add    $0x1,%ebx
  800135:	83 c4 10             	add    $0x10,%esp
  800138:	eb c9                	jmp    800103 <umain+0x9f>
		cprintf("init: data seems okay\n");
  80013a:	83 ec 0c             	sub    $0xc,%esp
  80013d:	68 2f 26 80 00       	push   $0x80262f
  800142:	e8 cc 03 00 00       	call   800513 <cprintf>
  800147:	83 c4 10             	add    $0x10,%esp
  80014a:	e9 68 ff ff ff       	jmp    8000b7 <umain+0x53>
		cprintf("init: bss seems okay\n");
  80014f:	83 ec 0c             	sub    $0xc,%esp
  800152:	68 46 26 80 00       	push   $0x802646
  800157:	e8 b7 03 00 00       	call   800513 <cprintf>
  80015c:	83 c4 10             	add    $0x10,%esp
  80015f:	eb 80                	jmp    8000e1 <umain+0x7d>
	}
	cprintf("%s\n", args);
  800161:	83 ec 08             	sub    $0x8,%esp
  800164:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80016a:	50                   	push   %eax
  80016b:	68 6b 26 80 00       	push   $0x80266b
  800170:	e8 9e 03 00 00       	call   800513 <cprintf>

	cprintf("init: running sh\n");
  800175:	c7 04 24 6f 26 80 00 	movl   $0x80266f,(%esp)
  80017c:	e8 92 03 00 00       	call   800513 <cprintf>

	// being run directly from kernel, so no file descriptors open yet
	close(0);
  800181:	c7 04 24 00 00 00 00 	movl   $0x0,(%esp)
  800188:	e8 77 10 00 00       	call   801204 <close>
	if ((r = opencons()) < 0)
  80018d:	e8 d8 01 00 00       	call   80036a <opencons>
  800192:	83 c4 10             	add    $0x10,%esp
  800195:	85 c0                	test   %eax,%eax
  800197:	78 14                	js     8001ad <umain+0x149>
		panic("opencons: %e", r);
	if (r != 0)
  800199:	74 24                	je     8001bf <umain+0x15b>
		panic("first opencons used fd %d", r);
  80019b:	50                   	push   %eax
  80019c:	68 9a 26 80 00       	push   $0x80269a
  8001a1:	6a 39                	push   $0x39
  8001a3:	68 8e 26 80 00       	push   $0x80268e
  8001a8:	e8 7f 02 00 00       	call   80042c <_panic>
		panic("opencons: %e", r);
  8001ad:	50                   	push   %eax
  8001ae:	68 81 26 80 00       	push   $0x802681
  8001b3:	6a 37                	push   $0x37
  8001b5:	68 8e 26 80 00       	push   $0x80268e
  8001ba:	e8 6d 02 00 00       	call   80042c <_panic>
	if ((r = dup(0, 1)) < 0)
  8001bf:	83 ec 08             	sub    $0x8,%esp
  8001c2:	6a 01                	push   $0x1
  8001c4:	6a 00                	push   $0x0
  8001c6:	e8 93 10 00 00       	call   80125e <dup>
  8001cb:	83 c4 10             	add    $0x10,%esp
  8001ce:	85 c0                	test   %eax,%eax
  8001d0:	79 23                	jns    8001f5 <umain+0x191>
		panic("dup: %e", r);
  8001d2:	50                   	push   %eax
  8001d3:	68 b4 26 80 00       	push   $0x8026b4
  8001d8:	6a 3b                	push   $0x3b
  8001da:	68 8e 26 80 00       	push   $0x80268e
  8001df:	e8 48 02 00 00       	call   80042c <_panic>
	while (1) {
		cprintf("init: starting sh\n");
		r = spawnl("/sh", "sh", (char*)0);
		if (r < 0) {
			cprintf("init: spawn sh: %e\n", r);
  8001e4:	83 ec 08             	sub    $0x8,%esp
  8001e7:	50                   	push   %eax
  8001e8:	68 d3 26 80 00       	push   $0x8026d3
  8001ed:	e8 21 03 00 00       	call   800513 <cprintf>
			continue;
  8001f2:	83 c4 10             	add    $0x10,%esp
		cprintf("init: starting sh\n");
  8001f5:	83 ec 0c             	sub    $0xc,%esp
  8001f8:	68 bc 26 80 00       	push   $0x8026bc
  8001fd:	e8 11 03 00 00       	call   800513 <cprintf>
		r = spawnl("/sh", "sh", (char*)0);
  800202:	83 c4 0c             	add    $0xc,%esp
  800205:	6a 00                	push   $0x0
  800207:	68 d0 26 80 00       	push   $0x8026d0
  80020c:	68 cf 26 80 00       	push   $0x8026cf
  800211:	e8 d0 1b 00 00       	call   801de6 <spawnl>
		if (r < 0) {
  800216:	83 c4 10             	add    $0x10,%esp
  800219:	85 c0                	test   %eax,%eax
  80021b:	78 c7                	js     8001e4 <umain+0x180>
		}
		wait(r);
  80021d:	83 ec 0c             	sub    $0xc,%esp
  800220:	50                   	push   %eax
  800221:	e8 d8 1f 00 00       	call   8021fe <wait>
  800226:	83 c4 10             	add    $0x10,%esp
  800229:	eb ca                	jmp    8001f5 <umain+0x191>

0080022b <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  80022b:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  80022f:	b8 00 00 00 00       	mov    $0x0,%eax
  800234:	c3                   	ret    

00800235 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800235:	f3 0f 1e fb          	endbr32 
  800239:	55                   	push   %ebp
  80023a:	89 e5                	mov    %esp,%ebp
  80023c:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  80023f:	68 53 27 80 00       	push   $0x802753
  800244:	ff 75 0c             	pushl  0xc(%ebp)
  800247:	e8 31 08 00 00       	call   800a7d <strcpy>
	return 0;
}
  80024c:	b8 00 00 00 00       	mov    $0x0,%eax
  800251:	c9                   	leave  
  800252:	c3                   	ret    

00800253 <devcons_write>:
{
  800253:	f3 0f 1e fb          	endbr32 
  800257:	55                   	push   %ebp
  800258:	89 e5                	mov    %esp,%ebp
  80025a:	57                   	push   %edi
  80025b:	56                   	push   %esi
  80025c:	53                   	push   %ebx
  80025d:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800263:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800268:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80026e:	3b 75 10             	cmp    0x10(%ebp),%esi
  800271:	73 31                	jae    8002a4 <devcons_write+0x51>
		m = n - tot;
  800273:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800276:	29 f3                	sub    %esi,%ebx
  800278:	83 fb 7f             	cmp    $0x7f,%ebx
  80027b:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800280:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800283:	83 ec 04             	sub    $0x4,%esp
  800286:	53                   	push   %ebx
  800287:	89 f0                	mov    %esi,%eax
  800289:	03 45 0c             	add    0xc(%ebp),%eax
  80028c:	50                   	push   %eax
  80028d:	57                   	push   %edi
  80028e:	e8 a2 09 00 00       	call   800c35 <memmove>
		sys_cputs(buf, m);
  800293:	83 c4 08             	add    $0x8,%esp
  800296:	53                   	push   %ebx
  800297:	57                   	push   %edi
  800298:	e8 9d 0b 00 00       	call   800e3a <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80029d:	01 de                	add    %ebx,%esi
  80029f:	83 c4 10             	add    $0x10,%esp
  8002a2:	eb ca                	jmp    80026e <devcons_write+0x1b>
}
  8002a4:	89 f0                	mov    %esi,%eax
  8002a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5e                   	pop    %esi
  8002ab:	5f                   	pop    %edi
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <devcons_read>:
{
  8002ae:	f3 0f 1e fb          	endbr32 
  8002b2:	55                   	push   %ebp
  8002b3:	89 e5                	mov    %esp,%ebp
  8002b5:	83 ec 08             	sub    $0x8,%esp
  8002b8:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  8002bd:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  8002c1:	74 21                	je     8002e4 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  8002c3:	e8 9c 0b 00 00       	call   800e64 <sys_cgetc>
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	75 07                	jne    8002d3 <devcons_read+0x25>
		sys_yield();
  8002cc:	e8 09 0c 00 00       	call   800eda <sys_yield>
  8002d1:	eb f0                	jmp    8002c3 <devcons_read+0x15>
	if (c < 0)
  8002d3:	78 0f                	js     8002e4 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  8002d5:	83 f8 04             	cmp    $0x4,%eax
  8002d8:	74 0c                	je     8002e6 <devcons_read+0x38>
	*(char*)vbuf = c;
  8002da:	8b 55 0c             	mov    0xc(%ebp),%edx
  8002dd:	88 02                	mov    %al,(%edx)
	return 1;
  8002df:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8002e4:	c9                   	leave  
  8002e5:	c3                   	ret    
		return 0;
  8002e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8002eb:	eb f7                	jmp    8002e4 <devcons_read+0x36>

008002ed <cputchar>:
{
  8002ed:	f3 0f 1e fb          	endbr32 
  8002f1:	55                   	push   %ebp
  8002f2:	89 e5                	mov    %esp,%ebp
  8002f4:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8002f7:	8b 45 08             	mov    0x8(%ebp),%eax
  8002fa:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8002fd:	6a 01                	push   $0x1
  8002ff:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800302:	50                   	push   %eax
  800303:	e8 32 0b 00 00       	call   800e3a <sys_cputs>
}
  800308:	83 c4 10             	add    $0x10,%esp
  80030b:	c9                   	leave  
  80030c:	c3                   	ret    

0080030d <getchar>:
{
  80030d:	f3 0f 1e fb          	endbr32 
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800317:	6a 01                	push   $0x1
  800319:	8d 45 f7             	lea    -0x9(%ebp),%eax
  80031c:	50                   	push   %eax
  80031d:	6a 00                	push   $0x0
  80031f:	e8 2a 10 00 00       	call   80134e <read>
	if (r < 0)
  800324:	83 c4 10             	add    $0x10,%esp
  800327:	85 c0                	test   %eax,%eax
  800329:	78 06                	js     800331 <getchar+0x24>
	if (r < 1)
  80032b:	74 06                	je     800333 <getchar+0x26>
	return c;
  80032d:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800331:	c9                   	leave  
  800332:	c3                   	ret    
		return -E_EOF;
  800333:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800338:	eb f7                	jmp    800331 <getchar+0x24>

0080033a <iscons>:
{
  80033a:	f3 0f 1e fb          	endbr32 
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800344:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800347:	50                   	push   %eax
  800348:	ff 75 08             	pushl  0x8(%ebp)
  80034b:	e8 7b 0d 00 00       	call   8010cb <fd_lookup>
  800350:	83 c4 10             	add    $0x10,%esp
  800353:	85 c0                	test   %eax,%eax
  800355:	78 11                	js     800368 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  800357:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80035a:	8b 15 70 47 80 00    	mov    0x804770,%edx
  800360:	39 10                	cmp    %edx,(%eax)
  800362:	0f 94 c0             	sete   %al
  800365:	0f b6 c0             	movzbl %al,%eax
}
  800368:	c9                   	leave  
  800369:	c3                   	ret    

0080036a <opencons>:
{
  80036a:	f3 0f 1e fb          	endbr32 
  80036e:	55                   	push   %ebp
  80036f:	89 e5                	mov    %esp,%ebp
  800371:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800374:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800377:	50                   	push   %eax
  800378:	e8 f8 0c 00 00       	call   801075 <fd_alloc>
  80037d:	83 c4 10             	add    $0x10,%esp
  800380:	85 c0                	test   %eax,%eax
  800382:	78 3a                	js     8003be <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800384:	83 ec 04             	sub    $0x4,%esp
  800387:	68 07 04 00 00       	push   $0x407
  80038c:	ff 75 f4             	pushl  -0xc(%ebp)
  80038f:	6a 00                	push   $0x0
  800391:	e8 6f 0b 00 00       	call   800f05 <sys_page_alloc>
  800396:	83 c4 10             	add    $0x10,%esp
  800399:	85 c0                	test   %eax,%eax
  80039b:	78 21                	js     8003be <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80039d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003a0:	8b 15 70 47 80 00    	mov    0x804770,%edx
  8003a6:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8003a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8003ab:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  8003b2:	83 ec 0c             	sub    $0xc,%esp
  8003b5:	50                   	push   %eax
  8003b6:	e8 87 0c 00 00       	call   801042 <fd2num>
  8003bb:	83 c4 10             	add    $0x10,%esp
}
  8003be:	c9                   	leave  
  8003bf:	c3                   	ret    

008003c0 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  8003c0:	f3 0f 1e fb          	endbr32 
  8003c4:	55                   	push   %ebp
  8003c5:	89 e5                	mov    %esp,%ebp
  8003c7:	56                   	push   %esi
  8003c8:	53                   	push   %ebx
  8003c9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8003cc:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  8003cf:	e8 de 0a 00 00       	call   800eb2 <sys_getenvid>
	if (id >= 0)
  8003d4:	85 c0                	test   %eax,%eax
  8003d6:	78 12                	js     8003ea <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8003d8:	25 ff 03 00 00       	and    $0x3ff,%eax
  8003dd:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8003e0:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8003e5:	a3 90 67 80 00       	mov    %eax,0x806790

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8003ea:	85 db                	test   %ebx,%ebx
  8003ec:	7e 07                	jle    8003f5 <libmain+0x35>
		binaryname = argv[0];
  8003ee:	8b 06                	mov    (%esi),%eax
  8003f0:	a3 8c 47 80 00       	mov    %eax,0x80478c

	// call user main routine
	umain(argc, argv);
  8003f5:	83 ec 08             	sub    $0x8,%esp
  8003f8:	56                   	push   %esi
  8003f9:	53                   	push   %ebx
  8003fa:	e8 65 fc ff ff       	call   800064 <umain>

	// exit gracefully
	exit();
  8003ff:	e8 0a 00 00 00       	call   80040e <exit>
}
  800404:	83 c4 10             	add    $0x10,%esp
  800407:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80040a:	5b                   	pop    %ebx
  80040b:	5e                   	pop    %esi
  80040c:	5d                   	pop    %ebp
  80040d:	c3                   	ret    

0080040e <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80040e:	f3 0f 1e fb          	endbr32 
  800412:	55                   	push   %ebp
  800413:	89 e5                	mov    %esp,%ebp
  800415:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800418:	e8 18 0e 00 00       	call   801235 <close_all>
	sys_env_destroy(0);
  80041d:	83 ec 0c             	sub    $0xc,%esp
  800420:	6a 00                	push   $0x0
  800422:	e8 65 0a 00 00       	call   800e8c <sys_env_destroy>
}
  800427:	83 c4 10             	add    $0x10,%esp
  80042a:	c9                   	leave  
  80042b:	c3                   	ret    

0080042c <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80042c:	f3 0f 1e fb          	endbr32 
  800430:	55                   	push   %ebp
  800431:	89 e5                	mov    %esp,%ebp
  800433:	56                   	push   %esi
  800434:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800435:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800438:	8b 35 8c 47 80 00    	mov    0x80478c,%esi
  80043e:	e8 6f 0a 00 00       	call   800eb2 <sys_getenvid>
  800443:	83 ec 0c             	sub    $0xc,%esp
  800446:	ff 75 0c             	pushl  0xc(%ebp)
  800449:	ff 75 08             	pushl  0x8(%ebp)
  80044c:	56                   	push   %esi
  80044d:	50                   	push   %eax
  80044e:	68 6c 27 80 00       	push   $0x80276c
  800453:	e8 bb 00 00 00       	call   800513 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800458:	83 c4 18             	add    $0x18,%esp
  80045b:	53                   	push   %ebx
  80045c:	ff 75 10             	pushl  0x10(%ebp)
  80045f:	e8 5a 00 00 00       	call   8004be <vcprintf>
	cprintf("\n");
  800464:	c7 04 24 56 2c 80 00 	movl   $0x802c56,(%esp)
  80046b:	e8 a3 00 00 00       	call   800513 <cprintf>
  800470:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800473:	cc                   	int3   
  800474:	eb fd                	jmp    800473 <_panic+0x47>

00800476 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800476:	f3 0f 1e fb          	endbr32 
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	53                   	push   %ebx
  80047e:	83 ec 04             	sub    $0x4,%esp
  800481:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800484:	8b 13                	mov    (%ebx),%edx
  800486:	8d 42 01             	lea    0x1(%edx),%eax
  800489:	89 03                	mov    %eax,(%ebx)
  80048b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80048e:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800492:	3d ff 00 00 00       	cmp    $0xff,%eax
  800497:	74 09                	je     8004a2 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800499:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80049d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8004a0:	c9                   	leave  
  8004a1:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8004a2:	83 ec 08             	sub    $0x8,%esp
  8004a5:	68 ff 00 00 00       	push   $0xff
  8004aa:	8d 43 08             	lea    0x8(%ebx),%eax
  8004ad:	50                   	push   %eax
  8004ae:	e8 87 09 00 00       	call   800e3a <sys_cputs>
		b->idx = 0;
  8004b3:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8004b9:	83 c4 10             	add    $0x10,%esp
  8004bc:	eb db                	jmp    800499 <putch+0x23>

008004be <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8004be:	f3 0f 1e fb          	endbr32 
  8004c2:	55                   	push   %ebp
  8004c3:	89 e5                	mov    %esp,%ebp
  8004c5:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8004cb:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8004d2:	00 00 00 
	b.cnt = 0;
  8004d5:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8004dc:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8004df:	ff 75 0c             	pushl  0xc(%ebp)
  8004e2:	ff 75 08             	pushl  0x8(%ebp)
  8004e5:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8004eb:	50                   	push   %eax
  8004ec:	68 76 04 80 00       	push   $0x800476
  8004f1:	e8 80 01 00 00       	call   800676 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8004f6:	83 c4 08             	add    $0x8,%esp
  8004f9:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8004ff:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800505:	50                   	push   %eax
  800506:	e8 2f 09 00 00       	call   800e3a <sys_cputs>

	return b.cnt;
}
  80050b:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800511:	c9                   	leave  
  800512:	c3                   	ret    

00800513 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800513:	f3 0f 1e fb          	endbr32 
  800517:	55                   	push   %ebp
  800518:	89 e5                	mov    %esp,%ebp
  80051a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80051d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800520:	50                   	push   %eax
  800521:	ff 75 08             	pushl  0x8(%ebp)
  800524:	e8 95 ff ff ff       	call   8004be <vcprintf>
	va_end(ap);

	return cnt;
}
  800529:	c9                   	leave  
  80052a:	c3                   	ret    

0080052b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80052b:	55                   	push   %ebp
  80052c:	89 e5                	mov    %esp,%ebp
  80052e:	57                   	push   %edi
  80052f:	56                   	push   %esi
  800530:	53                   	push   %ebx
  800531:	83 ec 1c             	sub    $0x1c,%esp
  800534:	89 c7                	mov    %eax,%edi
  800536:	89 d6                	mov    %edx,%esi
  800538:	8b 45 08             	mov    0x8(%ebp),%eax
  80053b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80053e:	89 d1                	mov    %edx,%ecx
  800540:	89 c2                	mov    %eax,%edx
  800542:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800545:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800548:	8b 45 10             	mov    0x10(%ebp),%eax
  80054b:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80054e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800551:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800558:	39 c2                	cmp    %eax,%edx
  80055a:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80055d:	72 3e                	jb     80059d <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80055f:	83 ec 0c             	sub    $0xc,%esp
  800562:	ff 75 18             	pushl  0x18(%ebp)
  800565:	83 eb 01             	sub    $0x1,%ebx
  800568:	53                   	push   %ebx
  800569:	50                   	push   %eax
  80056a:	83 ec 08             	sub    $0x8,%esp
  80056d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800570:	ff 75 e0             	pushl  -0x20(%ebp)
  800573:	ff 75 dc             	pushl  -0x24(%ebp)
  800576:	ff 75 d8             	pushl  -0x28(%ebp)
  800579:	e8 32 1e 00 00       	call   8023b0 <__udivdi3>
  80057e:	83 c4 18             	add    $0x18,%esp
  800581:	52                   	push   %edx
  800582:	50                   	push   %eax
  800583:	89 f2                	mov    %esi,%edx
  800585:	89 f8                	mov    %edi,%eax
  800587:	e8 9f ff ff ff       	call   80052b <printnum>
  80058c:	83 c4 20             	add    $0x20,%esp
  80058f:	eb 13                	jmp    8005a4 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800591:	83 ec 08             	sub    $0x8,%esp
  800594:	56                   	push   %esi
  800595:	ff 75 18             	pushl  0x18(%ebp)
  800598:	ff d7                	call   *%edi
  80059a:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80059d:	83 eb 01             	sub    $0x1,%ebx
  8005a0:	85 db                	test   %ebx,%ebx
  8005a2:	7f ed                	jg     800591 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8005a4:	83 ec 08             	sub    $0x8,%esp
  8005a7:	56                   	push   %esi
  8005a8:	83 ec 04             	sub    $0x4,%esp
  8005ab:	ff 75 e4             	pushl  -0x1c(%ebp)
  8005ae:	ff 75 e0             	pushl  -0x20(%ebp)
  8005b1:	ff 75 dc             	pushl  -0x24(%ebp)
  8005b4:	ff 75 d8             	pushl  -0x28(%ebp)
  8005b7:	e8 04 1f 00 00       	call   8024c0 <__umoddi3>
  8005bc:	83 c4 14             	add    $0x14,%esp
  8005bf:	0f be 80 8f 27 80 00 	movsbl 0x80278f(%eax),%eax
  8005c6:	50                   	push   %eax
  8005c7:	ff d7                	call   *%edi
}
  8005c9:	83 c4 10             	add    $0x10,%esp
  8005cc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005cf:	5b                   	pop    %ebx
  8005d0:	5e                   	pop    %esi
  8005d1:	5f                   	pop    %edi
  8005d2:	5d                   	pop    %ebp
  8005d3:	c3                   	ret    

008005d4 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8005d4:	83 fa 01             	cmp    $0x1,%edx
  8005d7:	7f 13                	jg     8005ec <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8005d9:	85 d2                	test   %edx,%edx
  8005db:	74 1c                	je     8005f9 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8005dd:	8b 10                	mov    (%eax),%edx
  8005df:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005e2:	89 08                	mov    %ecx,(%eax)
  8005e4:	8b 02                	mov    (%edx),%eax
  8005e6:	ba 00 00 00 00       	mov    $0x0,%edx
  8005eb:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8005ec:	8b 10                	mov    (%eax),%edx
  8005ee:	8d 4a 08             	lea    0x8(%edx),%ecx
  8005f1:	89 08                	mov    %ecx,(%eax)
  8005f3:	8b 02                	mov    (%edx),%eax
  8005f5:	8b 52 04             	mov    0x4(%edx),%edx
  8005f8:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8005f9:	8b 10                	mov    (%eax),%edx
  8005fb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8005fe:	89 08                	mov    %ecx,(%eax)
  800600:	8b 02                	mov    (%edx),%eax
  800602:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800607:	c3                   	ret    

00800608 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800608:	83 fa 01             	cmp    $0x1,%edx
  80060b:	7f 0f                	jg     80061c <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  80060d:	85 d2                	test   %edx,%edx
  80060f:	74 18                	je     800629 <getint+0x21>
		return va_arg(*ap, long);
  800611:	8b 10                	mov    (%eax),%edx
  800613:	8d 4a 04             	lea    0x4(%edx),%ecx
  800616:	89 08                	mov    %ecx,(%eax)
  800618:	8b 02                	mov    (%edx),%eax
  80061a:	99                   	cltd   
  80061b:	c3                   	ret    
		return va_arg(*ap, long long);
  80061c:	8b 10                	mov    (%eax),%edx
  80061e:	8d 4a 08             	lea    0x8(%edx),%ecx
  800621:	89 08                	mov    %ecx,(%eax)
  800623:	8b 02                	mov    (%edx),%eax
  800625:	8b 52 04             	mov    0x4(%edx),%edx
  800628:	c3                   	ret    
	else
		return va_arg(*ap, int);
  800629:	8b 10                	mov    (%eax),%edx
  80062b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80062e:	89 08                	mov    %ecx,(%eax)
  800630:	8b 02                	mov    (%edx),%eax
  800632:	99                   	cltd   
}
  800633:	c3                   	ret    

00800634 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800634:	f3 0f 1e fb          	endbr32 
  800638:	55                   	push   %ebp
  800639:	89 e5                	mov    %esp,%ebp
  80063b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80063e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800642:	8b 10                	mov    (%eax),%edx
  800644:	3b 50 04             	cmp    0x4(%eax),%edx
  800647:	73 0a                	jae    800653 <sprintputch+0x1f>
		*b->buf++ = ch;
  800649:	8d 4a 01             	lea    0x1(%edx),%ecx
  80064c:	89 08                	mov    %ecx,(%eax)
  80064e:	8b 45 08             	mov    0x8(%ebp),%eax
  800651:	88 02                	mov    %al,(%edx)
}
  800653:	5d                   	pop    %ebp
  800654:	c3                   	ret    

00800655 <printfmt>:
{
  800655:	f3 0f 1e fb          	endbr32 
  800659:	55                   	push   %ebp
  80065a:	89 e5                	mov    %esp,%ebp
  80065c:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80065f:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800662:	50                   	push   %eax
  800663:	ff 75 10             	pushl  0x10(%ebp)
  800666:	ff 75 0c             	pushl  0xc(%ebp)
  800669:	ff 75 08             	pushl  0x8(%ebp)
  80066c:	e8 05 00 00 00       	call   800676 <vprintfmt>
}
  800671:	83 c4 10             	add    $0x10,%esp
  800674:	c9                   	leave  
  800675:	c3                   	ret    

00800676 <vprintfmt>:
{
  800676:	f3 0f 1e fb          	endbr32 
  80067a:	55                   	push   %ebp
  80067b:	89 e5                	mov    %esp,%ebp
  80067d:	57                   	push   %edi
  80067e:	56                   	push   %esi
  80067f:	53                   	push   %ebx
  800680:	83 ec 2c             	sub    $0x2c,%esp
  800683:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800686:	8b 75 0c             	mov    0xc(%ebp),%esi
  800689:	8b 7d 10             	mov    0x10(%ebp),%edi
  80068c:	e9 86 02 00 00       	jmp    800917 <vprintfmt+0x2a1>
		padc = ' ';
  800691:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800695:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80069c:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8006a3:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8006aa:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8006af:	8d 47 01             	lea    0x1(%edi),%eax
  8006b2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8006b5:	0f b6 17             	movzbl (%edi),%edx
  8006b8:	8d 42 dd             	lea    -0x23(%edx),%eax
  8006bb:	3c 55                	cmp    $0x55,%al
  8006bd:	0f 87 df 02 00 00    	ja     8009a2 <vprintfmt+0x32c>
  8006c3:	0f b6 c0             	movzbl %al,%eax
  8006c6:	3e ff 24 85 e0 28 80 	notrack jmp *0x8028e0(,%eax,4)
  8006cd:	00 
  8006ce:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8006d1:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8006d5:	eb d8                	jmp    8006af <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8006d7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8006da:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8006de:	eb cf                	jmp    8006af <vprintfmt+0x39>
  8006e0:	0f b6 d2             	movzbl %dl,%edx
  8006e3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8006e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8006eb:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8006ee:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8006f1:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8006f5:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8006f8:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8006fb:	83 f9 09             	cmp    $0x9,%ecx
  8006fe:	77 52                	ja     800752 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  800700:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800703:	eb e9                	jmp    8006ee <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800705:	8b 45 14             	mov    0x14(%ebp),%eax
  800708:	8d 50 04             	lea    0x4(%eax),%edx
  80070b:	89 55 14             	mov    %edx,0x14(%ebp)
  80070e:	8b 00                	mov    (%eax),%eax
  800710:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800713:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800716:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80071a:	79 93                	jns    8006af <vprintfmt+0x39>
				width = precision, precision = -1;
  80071c:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80071f:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800722:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800729:	eb 84                	jmp    8006af <vprintfmt+0x39>
  80072b:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80072e:	85 c0                	test   %eax,%eax
  800730:	ba 00 00 00 00       	mov    $0x0,%edx
  800735:	0f 49 d0             	cmovns %eax,%edx
  800738:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80073b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80073e:	e9 6c ff ff ff       	jmp    8006af <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800743:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800746:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80074d:	e9 5d ff ff ff       	jmp    8006af <vprintfmt+0x39>
  800752:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800755:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800758:	eb bc                	jmp    800716 <vprintfmt+0xa0>
			lflag++;
  80075a:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80075d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800760:	e9 4a ff ff ff       	jmp    8006af <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800765:	8b 45 14             	mov    0x14(%ebp),%eax
  800768:	8d 50 04             	lea    0x4(%eax),%edx
  80076b:	89 55 14             	mov    %edx,0x14(%ebp)
  80076e:	83 ec 08             	sub    $0x8,%esp
  800771:	56                   	push   %esi
  800772:	ff 30                	pushl  (%eax)
  800774:	ff d3                	call   *%ebx
			break;
  800776:	83 c4 10             	add    $0x10,%esp
  800779:	e9 96 01 00 00       	jmp    800914 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  80077e:	8b 45 14             	mov    0x14(%ebp),%eax
  800781:	8d 50 04             	lea    0x4(%eax),%edx
  800784:	89 55 14             	mov    %edx,0x14(%ebp)
  800787:	8b 00                	mov    (%eax),%eax
  800789:	99                   	cltd   
  80078a:	31 d0                	xor    %edx,%eax
  80078c:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80078e:	83 f8 0f             	cmp    $0xf,%eax
  800791:	7f 20                	jg     8007b3 <vprintfmt+0x13d>
  800793:	8b 14 85 40 2a 80 00 	mov    0x802a40(,%eax,4),%edx
  80079a:	85 d2                	test   %edx,%edx
  80079c:	74 15                	je     8007b3 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  80079e:	52                   	push   %edx
  80079f:	68 71 2b 80 00       	push   $0x802b71
  8007a4:	56                   	push   %esi
  8007a5:	53                   	push   %ebx
  8007a6:	e8 aa fe ff ff       	call   800655 <printfmt>
  8007ab:	83 c4 10             	add    $0x10,%esp
  8007ae:	e9 61 01 00 00       	jmp    800914 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8007b3:	50                   	push   %eax
  8007b4:	68 a7 27 80 00       	push   $0x8027a7
  8007b9:	56                   	push   %esi
  8007ba:	53                   	push   %ebx
  8007bb:	e8 95 fe ff ff       	call   800655 <printfmt>
  8007c0:	83 c4 10             	add    $0x10,%esp
  8007c3:	e9 4c 01 00 00       	jmp    800914 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8007c8:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cb:	8d 50 04             	lea    0x4(%eax),%edx
  8007ce:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d1:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8007d3:	85 c9                	test   %ecx,%ecx
  8007d5:	b8 a0 27 80 00       	mov    $0x8027a0,%eax
  8007da:	0f 45 c1             	cmovne %ecx,%eax
  8007dd:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8007e0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8007e4:	7e 06                	jle    8007ec <vprintfmt+0x176>
  8007e6:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8007ea:	75 0d                	jne    8007f9 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  8007ec:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8007ef:	89 c7                	mov    %eax,%edi
  8007f1:	03 45 e0             	add    -0x20(%ebp),%eax
  8007f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8007f7:	eb 57                	jmp    800850 <vprintfmt+0x1da>
  8007f9:	83 ec 08             	sub    $0x8,%esp
  8007fc:	ff 75 d8             	pushl  -0x28(%ebp)
  8007ff:	ff 75 cc             	pushl  -0x34(%ebp)
  800802:	e8 4f 02 00 00       	call   800a56 <strnlen>
  800807:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80080a:	29 c2                	sub    %eax,%edx
  80080c:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80080f:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800812:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800816:	89 5d 08             	mov    %ebx,0x8(%ebp)
  800819:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80081b:	85 db                	test   %ebx,%ebx
  80081d:	7e 10                	jle    80082f <vprintfmt+0x1b9>
					putch(padc, putdat);
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	56                   	push   %esi
  800823:	57                   	push   %edi
  800824:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800827:	83 eb 01             	sub    $0x1,%ebx
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	eb ec                	jmp    80081b <vprintfmt+0x1a5>
  80082f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800832:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800835:	85 d2                	test   %edx,%edx
  800837:	b8 00 00 00 00       	mov    $0x0,%eax
  80083c:	0f 49 c2             	cmovns %edx,%eax
  80083f:	29 c2                	sub    %eax,%edx
  800841:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800844:	eb a6                	jmp    8007ec <vprintfmt+0x176>
					putch(ch, putdat);
  800846:	83 ec 08             	sub    $0x8,%esp
  800849:	56                   	push   %esi
  80084a:	52                   	push   %edx
  80084b:	ff d3                	call   *%ebx
  80084d:	83 c4 10             	add    $0x10,%esp
  800850:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800853:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800855:	83 c7 01             	add    $0x1,%edi
  800858:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80085c:	0f be d0             	movsbl %al,%edx
  80085f:	85 d2                	test   %edx,%edx
  800861:	74 42                	je     8008a5 <vprintfmt+0x22f>
  800863:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800867:	78 06                	js     80086f <vprintfmt+0x1f9>
  800869:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80086d:	78 1e                	js     80088d <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  80086f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800873:	74 d1                	je     800846 <vprintfmt+0x1d0>
  800875:	0f be c0             	movsbl %al,%eax
  800878:	83 e8 20             	sub    $0x20,%eax
  80087b:	83 f8 5e             	cmp    $0x5e,%eax
  80087e:	76 c6                	jbe    800846 <vprintfmt+0x1d0>
					putch('?', putdat);
  800880:	83 ec 08             	sub    $0x8,%esp
  800883:	56                   	push   %esi
  800884:	6a 3f                	push   $0x3f
  800886:	ff d3                	call   *%ebx
  800888:	83 c4 10             	add    $0x10,%esp
  80088b:	eb c3                	jmp    800850 <vprintfmt+0x1da>
  80088d:	89 cf                	mov    %ecx,%edi
  80088f:	eb 0e                	jmp    80089f <vprintfmt+0x229>
				putch(' ', putdat);
  800891:	83 ec 08             	sub    $0x8,%esp
  800894:	56                   	push   %esi
  800895:	6a 20                	push   $0x20
  800897:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800899:	83 ef 01             	sub    $0x1,%edi
  80089c:	83 c4 10             	add    $0x10,%esp
  80089f:	85 ff                	test   %edi,%edi
  8008a1:	7f ee                	jg     800891 <vprintfmt+0x21b>
  8008a3:	eb 6f                	jmp    800914 <vprintfmt+0x29e>
  8008a5:	89 cf                	mov    %ecx,%edi
  8008a7:	eb f6                	jmp    80089f <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8008a9:	89 ca                	mov    %ecx,%edx
  8008ab:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ae:	e8 55 fd ff ff       	call   800608 <getint>
  8008b3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b6:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8008b9:	85 d2                	test   %edx,%edx
  8008bb:	78 0b                	js     8008c8 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8008bd:	89 d1                	mov    %edx,%ecx
  8008bf:	89 c2                	mov    %eax,%edx
			base = 10;
  8008c1:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008c6:	eb 32                	jmp    8008fa <vprintfmt+0x284>
				putch('-', putdat);
  8008c8:	83 ec 08             	sub    $0x8,%esp
  8008cb:	56                   	push   %esi
  8008cc:	6a 2d                	push   $0x2d
  8008ce:	ff d3                	call   *%ebx
				num = -(long long) num;
  8008d0:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8008d3:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8008d6:	f7 da                	neg    %edx
  8008d8:	83 d1 00             	adc    $0x0,%ecx
  8008db:	f7 d9                	neg    %ecx
  8008dd:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8008e0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8008e5:	eb 13                	jmp    8008fa <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8008e7:	89 ca                	mov    %ecx,%edx
  8008e9:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ec:	e8 e3 fc ff ff       	call   8005d4 <getuint>
  8008f1:	89 d1                	mov    %edx,%ecx
  8008f3:	89 c2                	mov    %eax,%edx
			base = 10;
  8008f5:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  8008fa:	83 ec 0c             	sub    $0xc,%esp
  8008fd:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800901:	57                   	push   %edi
  800902:	ff 75 e0             	pushl  -0x20(%ebp)
  800905:	50                   	push   %eax
  800906:	51                   	push   %ecx
  800907:	52                   	push   %edx
  800908:	89 f2                	mov    %esi,%edx
  80090a:	89 d8                	mov    %ebx,%eax
  80090c:	e8 1a fc ff ff       	call   80052b <printnum>
			break;
  800911:	83 c4 20             	add    $0x20,%esp
{
  800914:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800917:	83 c7 01             	add    $0x1,%edi
  80091a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80091e:	83 f8 25             	cmp    $0x25,%eax
  800921:	0f 84 6a fd ff ff    	je     800691 <vprintfmt+0x1b>
			if (ch == '\0')
  800927:	85 c0                	test   %eax,%eax
  800929:	0f 84 93 00 00 00    	je     8009c2 <vprintfmt+0x34c>
			putch(ch, putdat);
  80092f:	83 ec 08             	sub    $0x8,%esp
  800932:	56                   	push   %esi
  800933:	50                   	push   %eax
  800934:	ff d3                	call   *%ebx
  800936:	83 c4 10             	add    $0x10,%esp
  800939:	eb dc                	jmp    800917 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  80093b:	89 ca                	mov    %ecx,%edx
  80093d:	8d 45 14             	lea    0x14(%ebp),%eax
  800940:	e8 8f fc ff ff       	call   8005d4 <getuint>
  800945:	89 d1                	mov    %edx,%ecx
  800947:	89 c2                	mov    %eax,%edx
			base = 8;
  800949:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80094e:	eb aa                	jmp    8008fa <vprintfmt+0x284>
			putch('0', putdat);
  800950:	83 ec 08             	sub    $0x8,%esp
  800953:	56                   	push   %esi
  800954:	6a 30                	push   $0x30
  800956:	ff d3                	call   *%ebx
			putch('x', putdat);
  800958:	83 c4 08             	add    $0x8,%esp
  80095b:	56                   	push   %esi
  80095c:	6a 78                	push   $0x78
  80095e:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  800960:	8b 45 14             	mov    0x14(%ebp),%eax
  800963:	8d 50 04             	lea    0x4(%eax),%edx
  800966:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800969:	8b 10                	mov    (%eax),%edx
  80096b:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800970:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800973:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800978:	eb 80                	jmp    8008fa <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  80097a:	89 ca                	mov    %ecx,%edx
  80097c:	8d 45 14             	lea    0x14(%ebp),%eax
  80097f:	e8 50 fc ff ff       	call   8005d4 <getuint>
  800984:	89 d1                	mov    %edx,%ecx
  800986:	89 c2                	mov    %eax,%edx
			base = 16;
  800988:	b8 10 00 00 00       	mov    $0x10,%eax
  80098d:	e9 68 ff ff ff       	jmp    8008fa <vprintfmt+0x284>
			putch(ch, putdat);
  800992:	83 ec 08             	sub    $0x8,%esp
  800995:	56                   	push   %esi
  800996:	6a 25                	push   $0x25
  800998:	ff d3                	call   *%ebx
			break;
  80099a:	83 c4 10             	add    $0x10,%esp
  80099d:	e9 72 ff ff ff       	jmp    800914 <vprintfmt+0x29e>
			putch('%', putdat);
  8009a2:	83 ec 08             	sub    $0x8,%esp
  8009a5:	56                   	push   %esi
  8009a6:	6a 25                	push   $0x25
  8009a8:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8009aa:	83 c4 10             	add    $0x10,%esp
  8009ad:	89 f8                	mov    %edi,%eax
  8009af:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8009b3:	74 05                	je     8009ba <vprintfmt+0x344>
  8009b5:	83 e8 01             	sub    $0x1,%eax
  8009b8:	eb f5                	jmp    8009af <vprintfmt+0x339>
  8009ba:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8009bd:	e9 52 ff ff ff       	jmp    800914 <vprintfmt+0x29e>
}
  8009c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8009c5:	5b                   	pop    %ebx
  8009c6:	5e                   	pop    %esi
  8009c7:	5f                   	pop    %edi
  8009c8:	5d                   	pop    %ebp
  8009c9:	c3                   	ret    

008009ca <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8009ca:	f3 0f 1e fb          	endbr32 
  8009ce:	55                   	push   %ebp
  8009cf:	89 e5                	mov    %esp,%ebp
  8009d1:	83 ec 18             	sub    $0x18,%esp
  8009d4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009d7:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8009da:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8009dd:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8009e1:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8009e4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8009eb:	85 c0                	test   %eax,%eax
  8009ed:	74 26                	je     800a15 <vsnprintf+0x4b>
  8009ef:	85 d2                	test   %edx,%edx
  8009f1:	7e 22                	jle    800a15 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8009f3:	ff 75 14             	pushl  0x14(%ebp)
  8009f6:	ff 75 10             	pushl  0x10(%ebp)
  8009f9:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8009fc:	50                   	push   %eax
  8009fd:	68 34 06 80 00       	push   $0x800634
  800a02:	e8 6f fc ff ff       	call   800676 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800a07:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800a0a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800a0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a10:	83 c4 10             	add    $0x10,%esp
}
  800a13:	c9                   	leave  
  800a14:	c3                   	ret    
		return -E_INVAL;
  800a15:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800a1a:	eb f7                	jmp    800a13 <vsnprintf+0x49>

00800a1c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800a1c:	f3 0f 1e fb          	endbr32 
  800a20:	55                   	push   %ebp
  800a21:	89 e5                	mov    %esp,%ebp
  800a23:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800a26:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800a29:	50                   	push   %eax
  800a2a:	ff 75 10             	pushl  0x10(%ebp)
  800a2d:	ff 75 0c             	pushl  0xc(%ebp)
  800a30:	ff 75 08             	pushl  0x8(%ebp)
  800a33:	e8 92 ff ff ff       	call   8009ca <vsnprintf>
	va_end(ap);

	return rc;
}
  800a38:	c9                   	leave  
  800a39:	c3                   	ret    

00800a3a <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800a3a:	f3 0f 1e fb          	endbr32 
  800a3e:	55                   	push   %ebp
  800a3f:	89 e5                	mov    %esp,%ebp
  800a41:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800a44:	b8 00 00 00 00       	mov    $0x0,%eax
  800a49:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800a4d:	74 05                	je     800a54 <strlen+0x1a>
		n++;
  800a4f:	83 c0 01             	add    $0x1,%eax
  800a52:	eb f5                	jmp    800a49 <strlen+0xf>
	return n;
}
  800a54:	5d                   	pop    %ebp
  800a55:	c3                   	ret    

00800a56 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a56:	f3 0f 1e fb          	endbr32 
  800a5a:	55                   	push   %ebp
  800a5b:	89 e5                	mov    %esp,%ebp
  800a5d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a60:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a63:	b8 00 00 00 00       	mov    $0x0,%eax
  800a68:	39 d0                	cmp    %edx,%eax
  800a6a:	74 0d                	je     800a79 <strnlen+0x23>
  800a6c:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a70:	74 05                	je     800a77 <strnlen+0x21>
		n++;
  800a72:	83 c0 01             	add    $0x1,%eax
  800a75:	eb f1                	jmp    800a68 <strnlen+0x12>
  800a77:	89 c2                	mov    %eax,%edx
	return n;
}
  800a79:	89 d0                	mov    %edx,%eax
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    

00800a7d <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a7d:	f3 0f 1e fb          	endbr32 
  800a81:	55                   	push   %ebp
  800a82:	89 e5                	mov    %esp,%ebp
  800a84:	53                   	push   %ebx
  800a85:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a88:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800a90:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a94:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a97:	83 c0 01             	add    $0x1,%eax
  800a9a:	84 d2                	test   %dl,%dl
  800a9c:	75 f2                	jne    800a90 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a9e:	89 c8                	mov    %ecx,%eax
  800aa0:	5b                   	pop    %ebx
  800aa1:	5d                   	pop    %ebp
  800aa2:	c3                   	ret    

00800aa3 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800aa3:	f3 0f 1e fb          	endbr32 
  800aa7:	55                   	push   %ebp
  800aa8:	89 e5                	mov    %esp,%ebp
  800aaa:	53                   	push   %ebx
  800aab:	83 ec 10             	sub    $0x10,%esp
  800aae:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800ab1:	53                   	push   %ebx
  800ab2:	e8 83 ff ff ff       	call   800a3a <strlen>
  800ab7:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800aba:	ff 75 0c             	pushl  0xc(%ebp)
  800abd:	01 d8                	add    %ebx,%eax
  800abf:	50                   	push   %eax
  800ac0:	e8 b8 ff ff ff       	call   800a7d <strcpy>
	return dst;
}
  800ac5:	89 d8                	mov    %ebx,%eax
  800ac7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800aca:	c9                   	leave  
  800acb:	c3                   	ret    

00800acc <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800acc:	f3 0f 1e fb          	endbr32 
  800ad0:	55                   	push   %ebp
  800ad1:	89 e5                	mov    %esp,%ebp
  800ad3:	56                   	push   %esi
  800ad4:	53                   	push   %ebx
  800ad5:	8b 75 08             	mov    0x8(%ebp),%esi
  800ad8:	8b 55 0c             	mov    0xc(%ebp),%edx
  800adb:	89 f3                	mov    %esi,%ebx
  800add:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800ae0:	89 f0                	mov    %esi,%eax
  800ae2:	39 d8                	cmp    %ebx,%eax
  800ae4:	74 11                	je     800af7 <strncpy+0x2b>
		*dst++ = *src;
  800ae6:	83 c0 01             	add    $0x1,%eax
  800ae9:	0f b6 0a             	movzbl (%edx),%ecx
  800aec:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aef:	80 f9 01             	cmp    $0x1,%cl
  800af2:	83 da ff             	sbb    $0xffffffff,%edx
  800af5:	eb eb                	jmp    800ae2 <strncpy+0x16>
	}
	return ret;
}
  800af7:	89 f0                	mov    %esi,%eax
  800af9:	5b                   	pop    %ebx
  800afa:	5e                   	pop    %esi
  800afb:	5d                   	pop    %ebp
  800afc:	c3                   	ret    

00800afd <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800afd:	f3 0f 1e fb          	endbr32 
  800b01:	55                   	push   %ebp
  800b02:	89 e5                	mov    %esp,%ebp
  800b04:	56                   	push   %esi
  800b05:	53                   	push   %ebx
  800b06:	8b 75 08             	mov    0x8(%ebp),%esi
  800b09:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800b0c:	8b 55 10             	mov    0x10(%ebp),%edx
  800b0f:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800b11:	85 d2                	test   %edx,%edx
  800b13:	74 21                	je     800b36 <strlcpy+0x39>
  800b15:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800b19:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800b1b:	39 c2                	cmp    %eax,%edx
  800b1d:	74 14                	je     800b33 <strlcpy+0x36>
  800b1f:	0f b6 19             	movzbl (%ecx),%ebx
  800b22:	84 db                	test   %bl,%bl
  800b24:	74 0b                	je     800b31 <strlcpy+0x34>
			*dst++ = *src++;
  800b26:	83 c1 01             	add    $0x1,%ecx
  800b29:	83 c2 01             	add    $0x1,%edx
  800b2c:	88 5a ff             	mov    %bl,-0x1(%edx)
  800b2f:	eb ea                	jmp    800b1b <strlcpy+0x1e>
  800b31:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800b33:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800b36:	29 f0                	sub    %esi,%eax
}
  800b38:	5b                   	pop    %ebx
  800b39:	5e                   	pop    %esi
  800b3a:	5d                   	pop    %ebp
  800b3b:	c3                   	ret    

00800b3c <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800b3c:	f3 0f 1e fb          	endbr32 
  800b40:	55                   	push   %ebp
  800b41:	89 e5                	mov    %esp,%ebp
  800b43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800b46:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800b49:	0f b6 01             	movzbl (%ecx),%eax
  800b4c:	84 c0                	test   %al,%al
  800b4e:	74 0c                	je     800b5c <strcmp+0x20>
  800b50:	3a 02                	cmp    (%edx),%al
  800b52:	75 08                	jne    800b5c <strcmp+0x20>
		p++, q++;
  800b54:	83 c1 01             	add    $0x1,%ecx
  800b57:	83 c2 01             	add    $0x1,%edx
  800b5a:	eb ed                	jmp    800b49 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b5c:	0f b6 c0             	movzbl %al,%eax
  800b5f:	0f b6 12             	movzbl (%edx),%edx
  800b62:	29 d0                	sub    %edx,%eax
}
  800b64:	5d                   	pop    %ebp
  800b65:	c3                   	ret    

00800b66 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b66:	f3 0f 1e fb          	endbr32 
  800b6a:	55                   	push   %ebp
  800b6b:	89 e5                	mov    %esp,%ebp
  800b6d:	53                   	push   %ebx
  800b6e:	8b 45 08             	mov    0x8(%ebp),%eax
  800b71:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b74:	89 c3                	mov    %eax,%ebx
  800b76:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b79:	eb 06                	jmp    800b81 <strncmp+0x1b>
		n--, p++, q++;
  800b7b:	83 c0 01             	add    $0x1,%eax
  800b7e:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b81:	39 d8                	cmp    %ebx,%eax
  800b83:	74 16                	je     800b9b <strncmp+0x35>
  800b85:	0f b6 08             	movzbl (%eax),%ecx
  800b88:	84 c9                	test   %cl,%cl
  800b8a:	74 04                	je     800b90 <strncmp+0x2a>
  800b8c:	3a 0a                	cmp    (%edx),%cl
  800b8e:	74 eb                	je     800b7b <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b90:	0f b6 00             	movzbl (%eax),%eax
  800b93:	0f b6 12             	movzbl (%edx),%edx
  800b96:	29 d0                	sub    %edx,%eax
}
  800b98:	5b                   	pop    %ebx
  800b99:	5d                   	pop    %ebp
  800b9a:	c3                   	ret    
		return 0;
  800b9b:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba0:	eb f6                	jmp    800b98 <strncmp+0x32>

00800ba2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ba2:	f3 0f 1e fb          	endbr32 
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	8b 45 08             	mov    0x8(%ebp),%eax
  800bac:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bb0:	0f b6 10             	movzbl (%eax),%edx
  800bb3:	84 d2                	test   %dl,%dl
  800bb5:	74 09                	je     800bc0 <strchr+0x1e>
		if (*s == c)
  800bb7:	38 ca                	cmp    %cl,%dl
  800bb9:	74 0a                	je     800bc5 <strchr+0x23>
	for (; *s; s++)
  800bbb:	83 c0 01             	add    $0x1,%eax
  800bbe:	eb f0                	jmp    800bb0 <strchr+0xe>
			return (char *) s;
	return 0;
  800bc0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bc5:	5d                   	pop    %ebp
  800bc6:	c3                   	ret    

00800bc7 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800bc7:	f3 0f 1e fb          	endbr32 
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	8b 45 08             	mov    0x8(%ebp),%eax
  800bd1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800bd5:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800bd8:	38 ca                	cmp    %cl,%dl
  800bda:	74 09                	je     800be5 <strfind+0x1e>
  800bdc:	84 d2                	test   %dl,%dl
  800bde:	74 05                	je     800be5 <strfind+0x1e>
	for (; *s; s++)
  800be0:	83 c0 01             	add    $0x1,%eax
  800be3:	eb f0                	jmp    800bd5 <strfind+0xe>
			break;
	return (char *) s;
}
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800be7:	f3 0f 1e fb          	endbr32 
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	53                   	push   %ebx
  800bf1:	8b 55 08             	mov    0x8(%ebp),%edx
  800bf4:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800bf7:	85 c9                	test   %ecx,%ecx
  800bf9:	74 33                	je     800c2e <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bfb:	89 d0                	mov    %edx,%eax
  800bfd:	09 c8                	or     %ecx,%eax
  800bff:	a8 03                	test   $0x3,%al
  800c01:	75 23                	jne    800c26 <memset+0x3f>
		c &= 0xFF;
  800c03:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c07:	89 d8                	mov    %ebx,%eax
  800c09:	c1 e0 08             	shl    $0x8,%eax
  800c0c:	89 df                	mov    %ebx,%edi
  800c0e:	c1 e7 18             	shl    $0x18,%edi
  800c11:	89 de                	mov    %ebx,%esi
  800c13:	c1 e6 10             	shl    $0x10,%esi
  800c16:	09 f7                	or     %esi,%edi
  800c18:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800c1a:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800c1d:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800c1f:	89 d7                	mov    %edx,%edi
  800c21:	fc                   	cld    
  800c22:	f3 ab                	rep stos %eax,%es:(%edi)
  800c24:	eb 08                	jmp    800c2e <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800c26:	89 d7                	mov    %edx,%edi
  800c28:	8b 45 0c             	mov    0xc(%ebp),%eax
  800c2b:	fc                   	cld    
  800c2c:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800c2e:	89 d0                	mov    %edx,%eax
  800c30:	5b                   	pop    %ebx
  800c31:	5e                   	pop    %esi
  800c32:	5f                   	pop    %edi
  800c33:	5d                   	pop    %ebp
  800c34:	c3                   	ret    

00800c35 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800c35:	f3 0f 1e fb          	endbr32 
  800c39:	55                   	push   %ebp
  800c3a:	89 e5                	mov    %esp,%ebp
  800c3c:	57                   	push   %edi
  800c3d:	56                   	push   %esi
  800c3e:	8b 45 08             	mov    0x8(%ebp),%eax
  800c41:	8b 75 0c             	mov    0xc(%ebp),%esi
  800c44:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800c47:	39 c6                	cmp    %eax,%esi
  800c49:	73 32                	jae    800c7d <memmove+0x48>
  800c4b:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c4e:	39 c2                	cmp    %eax,%edx
  800c50:	76 2b                	jbe    800c7d <memmove+0x48>
		s += n;
		d += n;
  800c52:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c55:	89 fe                	mov    %edi,%esi
  800c57:	09 ce                	or     %ecx,%esi
  800c59:	09 d6                	or     %edx,%esi
  800c5b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c61:	75 0e                	jne    800c71 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c63:	83 ef 04             	sub    $0x4,%edi
  800c66:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c69:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c6c:	fd                   	std    
  800c6d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c6f:	eb 09                	jmp    800c7a <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c71:	83 ef 01             	sub    $0x1,%edi
  800c74:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c77:	fd                   	std    
  800c78:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c7a:	fc                   	cld    
  800c7b:	eb 1a                	jmp    800c97 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c7d:	89 c2                	mov    %eax,%edx
  800c7f:	09 ca                	or     %ecx,%edx
  800c81:	09 f2                	or     %esi,%edx
  800c83:	f6 c2 03             	test   $0x3,%dl
  800c86:	75 0a                	jne    800c92 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c88:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c8b:	89 c7                	mov    %eax,%edi
  800c8d:	fc                   	cld    
  800c8e:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c90:	eb 05                	jmp    800c97 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c92:	89 c7                	mov    %eax,%edi
  800c94:	fc                   	cld    
  800c95:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c97:	5e                   	pop    %esi
  800c98:	5f                   	pop    %edi
  800c99:	5d                   	pop    %ebp
  800c9a:	c3                   	ret    

00800c9b <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c9b:	f3 0f 1e fb          	endbr32 
  800c9f:	55                   	push   %ebp
  800ca0:	89 e5                	mov    %esp,%ebp
  800ca2:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800ca5:	ff 75 10             	pushl  0x10(%ebp)
  800ca8:	ff 75 0c             	pushl  0xc(%ebp)
  800cab:	ff 75 08             	pushl  0x8(%ebp)
  800cae:	e8 82 ff ff ff       	call   800c35 <memmove>
}
  800cb3:	c9                   	leave  
  800cb4:	c3                   	ret    

00800cb5 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800cb5:	f3 0f 1e fb          	endbr32 
  800cb9:	55                   	push   %ebp
  800cba:	89 e5                	mov    %esp,%ebp
  800cbc:	56                   	push   %esi
  800cbd:	53                   	push   %ebx
  800cbe:	8b 45 08             	mov    0x8(%ebp),%eax
  800cc1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800cc4:	89 c6                	mov    %eax,%esi
  800cc6:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800cc9:	39 f0                	cmp    %esi,%eax
  800ccb:	74 1c                	je     800ce9 <memcmp+0x34>
		if (*s1 != *s2)
  800ccd:	0f b6 08             	movzbl (%eax),%ecx
  800cd0:	0f b6 1a             	movzbl (%edx),%ebx
  800cd3:	38 d9                	cmp    %bl,%cl
  800cd5:	75 08                	jne    800cdf <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800cd7:	83 c0 01             	add    $0x1,%eax
  800cda:	83 c2 01             	add    $0x1,%edx
  800cdd:	eb ea                	jmp    800cc9 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800cdf:	0f b6 c1             	movzbl %cl,%eax
  800ce2:	0f b6 db             	movzbl %bl,%ebx
  800ce5:	29 d8                	sub    %ebx,%eax
  800ce7:	eb 05                	jmp    800cee <memcmp+0x39>
	}

	return 0;
  800ce9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cee:	5b                   	pop    %ebx
  800cef:	5e                   	pop    %esi
  800cf0:	5d                   	pop    %ebp
  800cf1:	c3                   	ret    

00800cf2 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800cf2:	f3 0f 1e fb          	endbr32 
  800cf6:	55                   	push   %ebp
  800cf7:	89 e5                	mov    %esp,%ebp
  800cf9:	8b 45 08             	mov    0x8(%ebp),%eax
  800cfc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cff:	89 c2                	mov    %eax,%edx
  800d01:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800d04:	39 d0                	cmp    %edx,%eax
  800d06:	73 09                	jae    800d11 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800d08:	38 08                	cmp    %cl,(%eax)
  800d0a:	74 05                	je     800d11 <memfind+0x1f>
	for (; s < ends; s++)
  800d0c:	83 c0 01             	add    $0x1,%eax
  800d0f:	eb f3                	jmp    800d04 <memfind+0x12>
			break;
	return (void *) s;
}
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    

00800d13 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800d13:	f3 0f 1e fb          	endbr32 
  800d17:	55                   	push   %ebp
  800d18:	89 e5                	mov    %esp,%ebp
  800d1a:	57                   	push   %edi
  800d1b:	56                   	push   %esi
  800d1c:	53                   	push   %ebx
  800d1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d20:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800d23:	eb 03                	jmp    800d28 <strtol+0x15>
		s++;
  800d25:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800d28:	0f b6 01             	movzbl (%ecx),%eax
  800d2b:	3c 20                	cmp    $0x20,%al
  800d2d:	74 f6                	je     800d25 <strtol+0x12>
  800d2f:	3c 09                	cmp    $0x9,%al
  800d31:	74 f2                	je     800d25 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800d33:	3c 2b                	cmp    $0x2b,%al
  800d35:	74 2a                	je     800d61 <strtol+0x4e>
	int neg = 0;
  800d37:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800d3c:	3c 2d                	cmp    $0x2d,%al
  800d3e:	74 2b                	je     800d6b <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d40:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800d46:	75 0f                	jne    800d57 <strtol+0x44>
  800d48:	80 39 30             	cmpb   $0x30,(%ecx)
  800d4b:	74 28                	je     800d75 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800d4d:	85 db                	test   %ebx,%ebx
  800d4f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d54:	0f 44 d8             	cmove  %eax,%ebx
  800d57:	b8 00 00 00 00       	mov    $0x0,%eax
  800d5c:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d5f:	eb 46                	jmp    800da7 <strtol+0x94>
		s++;
  800d61:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d64:	bf 00 00 00 00       	mov    $0x0,%edi
  800d69:	eb d5                	jmp    800d40 <strtol+0x2d>
		s++, neg = 1;
  800d6b:	83 c1 01             	add    $0x1,%ecx
  800d6e:	bf 01 00 00 00       	mov    $0x1,%edi
  800d73:	eb cb                	jmp    800d40 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d75:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d79:	74 0e                	je     800d89 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d7b:	85 db                	test   %ebx,%ebx
  800d7d:	75 d8                	jne    800d57 <strtol+0x44>
		s++, base = 8;
  800d7f:	83 c1 01             	add    $0x1,%ecx
  800d82:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d87:	eb ce                	jmp    800d57 <strtol+0x44>
		s += 2, base = 16;
  800d89:	83 c1 02             	add    $0x2,%ecx
  800d8c:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d91:	eb c4                	jmp    800d57 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d93:	0f be d2             	movsbl %dl,%edx
  800d96:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d99:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d9c:	7d 3a                	jge    800dd8 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d9e:	83 c1 01             	add    $0x1,%ecx
  800da1:	0f af 45 10          	imul   0x10(%ebp),%eax
  800da5:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800da7:	0f b6 11             	movzbl (%ecx),%edx
  800daa:	8d 72 d0             	lea    -0x30(%edx),%esi
  800dad:	89 f3                	mov    %esi,%ebx
  800daf:	80 fb 09             	cmp    $0x9,%bl
  800db2:	76 df                	jbe    800d93 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800db4:	8d 72 9f             	lea    -0x61(%edx),%esi
  800db7:	89 f3                	mov    %esi,%ebx
  800db9:	80 fb 19             	cmp    $0x19,%bl
  800dbc:	77 08                	ja     800dc6 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800dbe:	0f be d2             	movsbl %dl,%edx
  800dc1:	83 ea 57             	sub    $0x57,%edx
  800dc4:	eb d3                	jmp    800d99 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800dc6:	8d 72 bf             	lea    -0x41(%edx),%esi
  800dc9:	89 f3                	mov    %esi,%ebx
  800dcb:	80 fb 19             	cmp    $0x19,%bl
  800dce:	77 08                	ja     800dd8 <strtol+0xc5>
			dig = *s - 'A' + 10;
  800dd0:	0f be d2             	movsbl %dl,%edx
  800dd3:	83 ea 37             	sub    $0x37,%edx
  800dd6:	eb c1                	jmp    800d99 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800dd8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ddc:	74 05                	je     800de3 <strtol+0xd0>
		*endptr = (char *) s;
  800dde:	8b 75 0c             	mov    0xc(%ebp),%esi
  800de1:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800de3:	89 c2                	mov    %eax,%edx
  800de5:	f7 da                	neg    %edx
  800de7:	85 ff                	test   %edi,%edi
  800de9:	0f 45 c2             	cmovne %edx,%eax
}
  800dec:	5b                   	pop    %ebx
  800ded:	5e                   	pop    %esi
  800dee:	5f                   	pop    %edi
  800def:	5d                   	pop    %ebp
  800df0:	c3                   	ret    

00800df1 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800df1:	55                   	push   %ebp
  800df2:	89 e5                	mov    %esp,%ebp
  800df4:	57                   	push   %edi
  800df5:	56                   	push   %esi
  800df6:	53                   	push   %ebx
  800df7:	83 ec 1c             	sub    $0x1c,%esp
  800dfa:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800dfd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800e00:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800e02:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e05:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800e08:	8b 7d 10             	mov    0x10(%ebp),%edi
  800e0b:	8b 75 14             	mov    0x14(%ebp),%esi
  800e0e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800e10:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800e14:	74 04                	je     800e1a <syscall+0x29>
  800e16:	85 c0                	test   %eax,%eax
  800e18:	7f 08                	jg     800e22 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800e1a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800e1d:	5b                   	pop    %ebx
  800e1e:	5e                   	pop    %esi
  800e1f:	5f                   	pop    %edi
  800e20:	5d                   	pop    %ebp
  800e21:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800e22:	83 ec 0c             	sub    $0xc,%esp
  800e25:	50                   	push   %eax
  800e26:	ff 75 e0             	pushl  -0x20(%ebp)
  800e29:	68 9f 2a 80 00       	push   $0x802a9f
  800e2e:	6a 23                	push   $0x23
  800e30:	68 bc 2a 80 00       	push   $0x802abc
  800e35:	e8 f2 f5 ff ff       	call   80042c <_panic>

00800e3a <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800e3a:	f3 0f 1e fb          	endbr32 
  800e3e:	55                   	push   %ebp
  800e3f:	89 e5                	mov    %esp,%ebp
  800e41:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800e44:	6a 00                	push   $0x0
  800e46:	6a 00                	push   $0x0
  800e48:	6a 00                	push   $0x0
  800e4a:	ff 75 0c             	pushl  0xc(%ebp)
  800e4d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e50:	ba 00 00 00 00       	mov    $0x0,%edx
  800e55:	b8 00 00 00 00       	mov    $0x0,%eax
  800e5a:	e8 92 ff ff ff       	call   800df1 <syscall>
}
  800e5f:	83 c4 10             	add    $0x10,%esp
  800e62:	c9                   	leave  
  800e63:	c3                   	ret    

00800e64 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e64:	f3 0f 1e fb          	endbr32 
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800e6e:	6a 00                	push   $0x0
  800e70:	6a 00                	push   $0x0
  800e72:	6a 00                	push   $0x0
  800e74:	6a 00                	push   $0x0
  800e76:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e80:	b8 01 00 00 00       	mov    $0x1,%eax
  800e85:	e8 67 ff ff ff       	call   800df1 <syscall>
}
  800e8a:	c9                   	leave  
  800e8b:	c3                   	ret    

00800e8c <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e8c:	f3 0f 1e fb          	endbr32 
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800e96:	6a 00                	push   $0x0
  800e98:	6a 00                	push   $0x0
  800e9a:	6a 00                	push   $0x0
  800e9c:	6a 00                	push   $0x0
  800e9e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ea1:	ba 01 00 00 00       	mov    $0x1,%edx
  800ea6:	b8 03 00 00 00       	mov    $0x3,%eax
  800eab:	e8 41 ff ff ff       	call   800df1 <syscall>
}
  800eb0:	c9                   	leave  
  800eb1:	c3                   	ret    

00800eb2 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800eb2:	f3 0f 1e fb          	endbr32 
  800eb6:	55                   	push   %ebp
  800eb7:	89 e5                	mov    %esp,%ebp
  800eb9:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800ebc:	6a 00                	push   $0x0
  800ebe:	6a 00                	push   $0x0
  800ec0:	6a 00                	push   $0x0
  800ec2:	6a 00                	push   $0x0
  800ec4:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ec9:	ba 00 00 00 00       	mov    $0x0,%edx
  800ece:	b8 02 00 00 00       	mov    $0x2,%eax
  800ed3:	e8 19 ff ff ff       	call   800df1 <syscall>
}
  800ed8:	c9                   	leave  
  800ed9:	c3                   	ret    

00800eda <sys_yield>:

void
sys_yield(void)
{
  800eda:	f3 0f 1e fb          	endbr32 
  800ede:	55                   	push   %ebp
  800edf:	89 e5                	mov    %esp,%ebp
  800ee1:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800ee4:	6a 00                	push   $0x0
  800ee6:	6a 00                	push   $0x0
  800ee8:	6a 00                	push   $0x0
  800eea:	6a 00                	push   $0x0
  800eec:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ef1:	ba 00 00 00 00       	mov    $0x0,%edx
  800ef6:	b8 0b 00 00 00       	mov    $0xb,%eax
  800efb:	e8 f1 fe ff ff       	call   800df1 <syscall>
}
  800f00:	83 c4 10             	add    $0x10,%esp
  800f03:	c9                   	leave  
  800f04:	c3                   	ret    

00800f05 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800f05:	f3 0f 1e fb          	endbr32 
  800f09:	55                   	push   %ebp
  800f0a:	89 e5                	mov    %esp,%ebp
  800f0c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800f0f:	6a 00                	push   $0x0
  800f11:	6a 00                	push   $0x0
  800f13:	ff 75 10             	pushl  0x10(%ebp)
  800f16:	ff 75 0c             	pushl  0xc(%ebp)
  800f19:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f1c:	ba 01 00 00 00       	mov    $0x1,%edx
  800f21:	b8 04 00 00 00       	mov    $0x4,%eax
  800f26:	e8 c6 fe ff ff       	call   800df1 <syscall>
}
  800f2b:	c9                   	leave  
  800f2c:	c3                   	ret    

00800f2d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800f2d:	f3 0f 1e fb          	endbr32 
  800f31:	55                   	push   %ebp
  800f32:	89 e5                	mov    %esp,%ebp
  800f34:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800f37:	ff 75 18             	pushl  0x18(%ebp)
  800f3a:	ff 75 14             	pushl  0x14(%ebp)
  800f3d:	ff 75 10             	pushl  0x10(%ebp)
  800f40:	ff 75 0c             	pushl  0xc(%ebp)
  800f43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f46:	ba 01 00 00 00       	mov    $0x1,%edx
  800f4b:	b8 05 00 00 00       	mov    $0x5,%eax
  800f50:	e8 9c fe ff ff       	call   800df1 <syscall>
}
  800f55:	c9                   	leave  
  800f56:	c3                   	ret    

00800f57 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f57:	f3 0f 1e fb          	endbr32 
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800f61:	6a 00                	push   $0x0
  800f63:	6a 00                	push   $0x0
  800f65:	6a 00                	push   $0x0
  800f67:	ff 75 0c             	pushl  0xc(%ebp)
  800f6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f6d:	ba 01 00 00 00       	mov    $0x1,%edx
  800f72:	b8 06 00 00 00       	mov    $0x6,%eax
  800f77:	e8 75 fe ff ff       	call   800df1 <syscall>
}
  800f7c:	c9                   	leave  
  800f7d:	c3                   	ret    

00800f7e <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f7e:	f3 0f 1e fb          	endbr32 
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800f88:	6a 00                	push   $0x0
  800f8a:	6a 00                	push   $0x0
  800f8c:	6a 00                	push   $0x0
  800f8e:	ff 75 0c             	pushl  0xc(%ebp)
  800f91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f94:	ba 01 00 00 00       	mov    $0x1,%edx
  800f99:	b8 08 00 00 00       	mov    $0x8,%eax
  800f9e:	e8 4e fe ff ff       	call   800df1 <syscall>
}
  800fa3:	c9                   	leave  
  800fa4:	c3                   	ret    

00800fa5 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800fa5:	f3 0f 1e fb          	endbr32 
  800fa9:	55                   	push   %ebp
  800faa:	89 e5                	mov    %esp,%ebp
  800fac:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800faf:	6a 00                	push   $0x0
  800fb1:	6a 00                	push   $0x0
  800fb3:	6a 00                	push   $0x0
  800fb5:	ff 75 0c             	pushl  0xc(%ebp)
  800fb8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fbb:	ba 01 00 00 00       	mov    $0x1,%edx
  800fc0:	b8 09 00 00 00       	mov    $0x9,%eax
  800fc5:	e8 27 fe ff ff       	call   800df1 <syscall>
}
  800fca:	c9                   	leave  
  800fcb:	c3                   	ret    

00800fcc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800fcc:	f3 0f 1e fb          	endbr32 
  800fd0:	55                   	push   %ebp
  800fd1:	89 e5                	mov    %esp,%ebp
  800fd3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800fd6:	6a 00                	push   $0x0
  800fd8:	6a 00                	push   $0x0
  800fda:	6a 00                	push   $0x0
  800fdc:	ff 75 0c             	pushl  0xc(%ebp)
  800fdf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fe2:	ba 01 00 00 00       	mov    $0x1,%edx
  800fe7:	b8 0a 00 00 00       	mov    $0xa,%eax
  800fec:	e8 00 fe ff ff       	call   800df1 <syscall>
}
  800ff1:	c9                   	leave  
  800ff2:	c3                   	ret    

00800ff3 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800ff3:	f3 0f 1e fb          	endbr32 
  800ff7:	55                   	push   %ebp
  800ff8:	89 e5                	mov    %esp,%ebp
  800ffa:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800ffd:	6a 00                	push   $0x0
  800fff:	ff 75 14             	pushl  0x14(%ebp)
  801002:	ff 75 10             	pushl  0x10(%ebp)
  801005:	ff 75 0c             	pushl  0xc(%ebp)
  801008:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80100b:	ba 00 00 00 00       	mov    $0x0,%edx
  801010:	b8 0c 00 00 00       	mov    $0xc,%eax
  801015:	e8 d7 fd ff ff       	call   800df1 <syscall>
}
  80101a:	c9                   	leave  
  80101b:	c3                   	ret    

0080101c <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80101c:	f3 0f 1e fb          	endbr32 
  801020:	55                   	push   %ebp
  801021:	89 e5                	mov    %esp,%ebp
  801023:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801026:	6a 00                	push   $0x0
  801028:	6a 00                	push   $0x0
  80102a:	6a 00                	push   $0x0
  80102c:	6a 00                	push   $0x0
  80102e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801031:	ba 01 00 00 00       	mov    $0x1,%edx
  801036:	b8 0d 00 00 00       	mov    $0xd,%eax
  80103b:	e8 b1 fd ff ff       	call   800df1 <syscall>
}
  801040:	c9                   	leave  
  801041:	c3                   	ret    

00801042 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801042:	f3 0f 1e fb          	endbr32 
  801046:	55                   	push   %ebp
  801047:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801049:	8b 45 08             	mov    0x8(%ebp),%eax
  80104c:	05 00 00 00 30       	add    $0x30000000,%eax
  801051:	c1 e8 0c             	shr    $0xc,%eax
}
  801054:	5d                   	pop    %ebp
  801055:	c3                   	ret    

00801056 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801056:	f3 0f 1e fb          	endbr32 
  80105a:	55                   	push   %ebp
  80105b:	89 e5                	mov    %esp,%ebp
  80105d:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  801060:	ff 75 08             	pushl  0x8(%ebp)
  801063:	e8 da ff ff ff       	call   801042 <fd2num>
  801068:	83 c4 10             	add    $0x10,%esp
  80106b:	c1 e0 0c             	shl    $0xc,%eax
  80106e:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801073:	c9                   	leave  
  801074:	c3                   	ret    

00801075 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801075:	f3 0f 1e fb          	endbr32 
  801079:	55                   	push   %ebp
  80107a:	89 e5                	mov    %esp,%ebp
  80107c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801081:	89 c2                	mov    %eax,%edx
  801083:	c1 ea 16             	shr    $0x16,%edx
  801086:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80108d:	f6 c2 01             	test   $0x1,%dl
  801090:	74 2d                	je     8010bf <fd_alloc+0x4a>
  801092:	89 c2                	mov    %eax,%edx
  801094:	c1 ea 0c             	shr    $0xc,%edx
  801097:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80109e:	f6 c2 01             	test   $0x1,%dl
  8010a1:	74 1c                	je     8010bf <fd_alloc+0x4a>
  8010a3:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  8010a8:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8010ad:	75 d2                	jne    801081 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8010af:	8b 45 08             	mov    0x8(%ebp),%eax
  8010b2:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  8010b8:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8010bd:	eb 0a                	jmp    8010c9 <fd_alloc+0x54>
			*fd_store = fd;
  8010bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010c2:	89 01                	mov    %eax,(%ecx)
			return 0;
  8010c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010c9:	5d                   	pop    %ebp
  8010ca:	c3                   	ret    

008010cb <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8010cb:	f3 0f 1e fb          	endbr32 
  8010cf:	55                   	push   %ebp
  8010d0:	89 e5                	mov    %esp,%ebp
  8010d2:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8010d5:	83 f8 1f             	cmp    $0x1f,%eax
  8010d8:	77 30                	ja     80110a <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8010da:	c1 e0 0c             	shl    $0xc,%eax
  8010dd:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8010e2:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8010e8:	f6 c2 01             	test   $0x1,%dl
  8010eb:	74 24                	je     801111 <fd_lookup+0x46>
  8010ed:	89 c2                	mov    %eax,%edx
  8010ef:	c1 ea 0c             	shr    $0xc,%edx
  8010f2:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010f9:	f6 c2 01             	test   $0x1,%dl
  8010fc:	74 1a                	je     801118 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  801101:	89 02                	mov    %eax,(%edx)
	return 0;
  801103:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801108:	5d                   	pop    %ebp
  801109:	c3                   	ret    
		return -E_INVAL;
  80110a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80110f:	eb f7                	jmp    801108 <fd_lookup+0x3d>
		return -E_INVAL;
  801111:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801116:	eb f0                	jmp    801108 <fd_lookup+0x3d>
  801118:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80111d:	eb e9                	jmp    801108 <fd_lookup+0x3d>

0080111f <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80111f:	f3 0f 1e fb          	endbr32 
  801123:	55                   	push   %ebp
  801124:	89 e5                	mov    %esp,%ebp
  801126:	83 ec 08             	sub    $0x8,%esp
  801129:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80112c:	ba 48 2b 80 00       	mov    $0x802b48,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801131:	b8 90 47 80 00       	mov    $0x804790,%eax
		if (devtab[i]->dev_id == dev_id) {
  801136:	39 08                	cmp    %ecx,(%eax)
  801138:	74 33                	je     80116d <dev_lookup+0x4e>
  80113a:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80113d:	8b 02                	mov    (%edx),%eax
  80113f:	85 c0                	test   %eax,%eax
  801141:	75 f3                	jne    801136 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801143:	a1 90 67 80 00       	mov    0x806790,%eax
  801148:	8b 40 48             	mov    0x48(%eax),%eax
  80114b:	83 ec 04             	sub    $0x4,%esp
  80114e:	51                   	push   %ecx
  80114f:	50                   	push   %eax
  801150:	68 cc 2a 80 00       	push   $0x802acc
  801155:	e8 b9 f3 ff ff       	call   800513 <cprintf>
	*dev = 0;
  80115a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80115d:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801163:	83 c4 10             	add    $0x10,%esp
  801166:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80116b:	c9                   	leave  
  80116c:	c3                   	ret    
			*dev = devtab[i];
  80116d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801170:	89 01                	mov    %eax,(%ecx)
			return 0;
  801172:	b8 00 00 00 00       	mov    $0x0,%eax
  801177:	eb f2                	jmp    80116b <dev_lookup+0x4c>

00801179 <fd_close>:
{
  801179:	f3 0f 1e fb          	endbr32 
  80117d:	55                   	push   %ebp
  80117e:	89 e5                	mov    %esp,%ebp
  801180:	57                   	push   %edi
  801181:	56                   	push   %esi
  801182:	53                   	push   %ebx
  801183:	83 ec 28             	sub    $0x28,%esp
  801186:	8b 75 08             	mov    0x8(%ebp),%esi
  801189:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80118c:	56                   	push   %esi
  80118d:	e8 b0 fe ff ff       	call   801042 <fd2num>
  801192:	83 c4 08             	add    $0x8,%esp
  801195:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801198:	52                   	push   %edx
  801199:	50                   	push   %eax
  80119a:	e8 2c ff ff ff       	call   8010cb <fd_lookup>
  80119f:	89 c3                	mov    %eax,%ebx
  8011a1:	83 c4 10             	add    $0x10,%esp
  8011a4:	85 c0                	test   %eax,%eax
  8011a6:	78 05                	js     8011ad <fd_close+0x34>
	    || fd != fd2)
  8011a8:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  8011ab:	74 16                	je     8011c3 <fd_close+0x4a>
		return (must_exist ? r : 0);
  8011ad:	89 f8                	mov    %edi,%eax
  8011af:	84 c0                	test   %al,%al
  8011b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b6:	0f 44 d8             	cmove  %eax,%ebx
}
  8011b9:	89 d8                	mov    %ebx,%eax
  8011bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011be:	5b                   	pop    %ebx
  8011bf:	5e                   	pop    %esi
  8011c0:	5f                   	pop    %edi
  8011c1:	5d                   	pop    %ebp
  8011c2:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8011c3:	83 ec 08             	sub    $0x8,%esp
  8011c6:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8011c9:	50                   	push   %eax
  8011ca:	ff 36                	pushl  (%esi)
  8011cc:	e8 4e ff ff ff       	call   80111f <dev_lookup>
  8011d1:	89 c3                	mov    %eax,%ebx
  8011d3:	83 c4 10             	add    $0x10,%esp
  8011d6:	85 c0                	test   %eax,%eax
  8011d8:	78 1a                	js     8011f4 <fd_close+0x7b>
		if (dev->dev_close)
  8011da:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8011dd:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8011e0:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8011e5:	85 c0                	test   %eax,%eax
  8011e7:	74 0b                	je     8011f4 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8011e9:	83 ec 0c             	sub    $0xc,%esp
  8011ec:	56                   	push   %esi
  8011ed:	ff d0                	call   *%eax
  8011ef:	89 c3                	mov    %eax,%ebx
  8011f1:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8011f4:	83 ec 08             	sub    $0x8,%esp
  8011f7:	56                   	push   %esi
  8011f8:	6a 00                	push   $0x0
  8011fa:	e8 58 fd ff ff       	call   800f57 <sys_page_unmap>
	return r;
  8011ff:	83 c4 10             	add    $0x10,%esp
  801202:	eb b5                	jmp    8011b9 <fd_close+0x40>

00801204 <close>:

int
close(int fdnum)
{
  801204:	f3 0f 1e fb          	endbr32 
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80120e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801211:	50                   	push   %eax
  801212:	ff 75 08             	pushl  0x8(%ebp)
  801215:	e8 b1 fe ff ff       	call   8010cb <fd_lookup>
  80121a:	83 c4 10             	add    $0x10,%esp
  80121d:	85 c0                	test   %eax,%eax
  80121f:	79 02                	jns    801223 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  801221:	c9                   	leave  
  801222:	c3                   	ret    
		return fd_close(fd, 1);
  801223:	83 ec 08             	sub    $0x8,%esp
  801226:	6a 01                	push   $0x1
  801228:	ff 75 f4             	pushl  -0xc(%ebp)
  80122b:	e8 49 ff ff ff       	call   801179 <fd_close>
  801230:	83 c4 10             	add    $0x10,%esp
  801233:	eb ec                	jmp    801221 <close+0x1d>

00801235 <close_all>:

void
close_all(void)
{
  801235:	f3 0f 1e fb          	endbr32 
  801239:	55                   	push   %ebp
  80123a:	89 e5                	mov    %esp,%ebp
  80123c:	53                   	push   %ebx
  80123d:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801240:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  801245:	83 ec 0c             	sub    $0xc,%esp
  801248:	53                   	push   %ebx
  801249:	e8 b6 ff ff ff       	call   801204 <close>
	for (i = 0; i < MAXFD; i++)
  80124e:	83 c3 01             	add    $0x1,%ebx
  801251:	83 c4 10             	add    $0x10,%esp
  801254:	83 fb 20             	cmp    $0x20,%ebx
  801257:	75 ec                	jne    801245 <close_all+0x10>
}
  801259:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80125c:	c9                   	leave  
  80125d:	c3                   	ret    

0080125e <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80125e:	f3 0f 1e fb          	endbr32 
  801262:	55                   	push   %ebp
  801263:	89 e5                	mov    %esp,%ebp
  801265:	57                   	push   %edi
  801266:	56                   	push   %esi
  801267:	53                   	push   %ebx
  801268:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80126b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80126e:	50                   	push   %eax
  80126f:	ff 75 08             	pushl  0x8(%ebp)
  801272:	e8 54 fe ff ff       	call   8010cb <fd_lookup>
  801277:	89 c3                	mov    %eax,%ebx
  801279:	83 c4 10             	add    $0x10,%esp
  80127c:	85 c0                	test   %eax,%eax
  80127e:	0f 88 81 00 00 00    	js     801305 <dup+0xa7>
		return r;
	close(newfdnum);
  801284:	83 ec 0c             	sub    $0xc,%esp
  801287:	ff 75 0c             	pushl  0xc(%ebp)
  80128a:	e8 75 ff ff ff       	call   801204 <close>

	newfd = INDEX2FD(newfdnum);
  80128f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801292:	c1 e6 0c             	shl    $0xc,%esi
  801295:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80129b:	83 c4 04             	add    $0x4,%esp
  80129e:	ff 75 e4             	pushl  -0x1c(%ebp)
  8012a1:	e8 b0 fd ff ff       	call   801056 <fd2data>
  8012a6:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  8012a8:	89 34 24             	mov    %esi,(%esp)
  8012ab:	e8 a6 fd ff ff       	call   801056 <fd2data>
  8012b0:	83 c4 10             	add    $0x10,%esp
  8012b3:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8012b5:	89 d8                	mov    %ebx,%eax
  8012b7:	c1 e8 16             	shr    $0x16,%eax
  8012ba:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8012c1:	a8 01                	test   $0x1,%al
  8012c3:	74 11                	je     8012d6 <dup+0x78>
  8012c5:	89 d8                	mov    %ebx,%eax
  8012c7:	c1 e8 0c             	shr    $0xc,%eax
  8012ca:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8012d1:	f6 c2 01             	test   $0x1,%dl
  8012d4:	75 39                	jne    80130f <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8012d6:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8012d9:	89 d0                	mov    %edx,%eax
  8012db:	c1 e8 0c             	shr    $0xc,%eax
  8012de:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012e5:	83 ec 0c             	sub    $0xc,%esp
  8012e8:	25 07 0e 00 00       	and    $0xe07,%eax
  8012ed:	50                   	push   %eax
  8012ee:	56                   	push   %esi
  8012ef:	6a 00                	push   $0x0
  8012f1:	52                   	push   %edx
  8012f2:	6a 00                	push   $0x0
  8012f4:	e8 34 fc ff ff       	call   800f2d <sys_page_map>
  8012f9:	89 c3                	mov    %eax,%ebx
  8012fb:	83 c4 20             	add    $0x20,%esp
  8012fe:	85 c0                	test   %eax,%eax
  801300:	78 31                	js     801333 <dup+0xd5>
		goto err;

	return newfdnum;
  801302:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  801305:	89 d8                	mov    %ebx,%eax
  801307:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80130a:	5b                   	pop    %ebx
  80130b:	5e                   	pop    %esi
  80130c:	5f                   	pop    %edi
  80130d:	5d                   	pop    %ebp
  80130e:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  80130f:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801316:	83 ec 0c             	sub    $0xc,%esp
  801319:	25 07 0e 00 00       	and    $0xe07,%eax
  80131e:	50                   	push   %eax
  80131f:	57                   	push   %edi
  801320:	6a 00                	push   $0x0
  801322:	53                   	push   %ebx
  801323:	6a 00                	push   $0x0
  801325:	e8 03 fc ff ff       	call   800f2d <sys_page_map>
  80132a:	89 c3                	mov    %eax,%ebx
  80132c:	83 c4 20             	add    $0x20,%esp
  80132f:	85 c0                	test   %eax,%eax
  801331:	79 a3                	jns    8012d6 <dup+0x78>
	sys_page_unmap(0, newfd);
  801333:	83 ec 08             	sub    $0x8,%esp
  801336:	56                   	push   %esi
  801337:	6a 00                	push   $0x0
  801339:	e8 19 fc ff ff       	call   800f57 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80133e:	83 c4 08             	add    $0x8,%esp
  801341:	57                   	push   %edi
  801342:	6a 00                	push   $0x0
  801344:	e8 0e fc ff ff       	call   800f57 <sys_page_unmap>
	return r;
  801349:	83 c4 10             	add    $0x10,%esp
  80134c:	eb b7                	jmp    801305 <dup+0xa7>

0080134e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80134e:	f3 0f 1e fb          	endbr32 
  801352:	55                   	push   %ebp
  801353:	89 e5                	mov    %esp,%ebp
  801355:	53                   	push   %ebx
  801356:	83 ec 1c             	sub    $0x1c,%esp
  801359:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80135c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80135f:	50                   	push   %eax
  801360:	53                   	push   %ebx
  801361:	e8 65 fd ff ff       	call   8010cb <fd_lookup>
  801366:	83 c4 10             	add    $0x10,%esp
  801369:	85 c0                	test   %eax,%eax
  80136b:	78 3f                	js     8013ac <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80136d:	83 ec 08             	sub    $0x8,%esp
  801370:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801373:	50                   	push   %eax
  801374:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801377:	ff 30                	pushl  (%eax)
  801379:	e8 a1 fd ff ff       	call   80111f <dev_lookup>
  80137e:	83 c4 10             	add    $0x10,%esp
  801381:	85 c0                	test   %eax,%eax
  801383:	78 27                	js     8013ac <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801385:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801388:	8b 42 08             	mov    0x8(%edx),%eax
  80138b:	83 e0 03             	and    $0x3,%eax
  80138e:	83 f8 01             	cmp    $0x1,%eax
  801391:	74 1e                	je     8013b1 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801393:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801396:	8b 40 08             	mov    0x8(%eax),%eax
  801399:	85 c0                	test   %eax,%eax
  80139b:	74 35                	je     8013d2 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80139d:	83 ec 04             	sub    $0x4,%esp
  8013a0:	ff 75 10             	pushl  0x10(%ebp)
  8013a3:	ff 75 0c             	pushl  0xc(%ebp)
  8013a6:	52                   	push   %edx
  8013a7:	ff d0                	call   *%eax
  8013a9:	83 c4 10             	add    $0x10,%esp
}
  8013ac:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8013af:	c9                   	leave  
  8013b0:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  8013b1:	a1 90 67 80 00       	mov    0x806790,%eax
  8013b6:	8b 40 48             	mov    0x48(%eax),%eax
  8013b9:	83 ec 04             	sub    $0x4,%esp
  8013bc:	53                   	push   %ebx
  8013bd:	50                   	push   %eax
  8013be:	68 0d 2b 80 00       	push   $0x802b0d
  8013c3:	e8 4b f1 ff ff       	call   800513 <cprintf>
		return -E_INVAL;
  8013c8:	83 c4 10             	add    $0x10,%esp
  8013cb:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8013d0:	eb da                	jmp    8013ac <read+0x5e>
		return -E_NOT_SUPP;
  8013d2:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8013d7:	eb d3                	jmp    8013ac <read+0x5e>

008013d9 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8013d9:	f3 0f 1e fb          	endbr32 
  8013dd:	55                   	push   %ebp
  8013de:	89 e5                	mov    %esp,%ebp
  8013e0:	57                   	push   %edi
  8013e1:	56                   	push   %esi
  8013e2:	53                   	push   %ebx
  8013e3:	83 ec 0c             	sub    $0xc,%esp
  8013e6:	8b 7d 08             	mov    0x8(%ebp),%edi
  8013e9:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8013ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013f1:	eb 02                	jmp    8013f5 <readn+0x1c>
  8013f3:	01 c3                	add    %eax,%ebx
  8013f5:	39 f3                	cmp    %esi,%ebx
  8013f7:	73 21                	jae    80141a <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013f9:	83 ec 04             	sub    $0x4,%esp
  8013fc:	89 f0                	mov    %esi,%eax
  8013fe:	29 d8                	sub    %ebx,%eax
  801400:	50                   	push   %eax
  801401:	89 d8                	mov    %ebx,%eax
  801403:	03 45 0c             	add    0xc(%ebp),%eax
  801406:	50                   	push   %eax
  801407:	57                   	push   %edi
  801408:	e8 41 ff ff ff       	call   80134e <read>
		if (m < 0)
  80140d:	83 c4 10             	add    $0x10,%esp
  801410:	85 c0                	test   %eax,%eax
  801412:	78 04                	js     801418 <readn+0x3f>
			return m;
		if (m == 0)
  801414:	75 dd                	jne    8013f3 <readn+0x1a>
  801416:	eb 02                	jmp    80141a <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  801418:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  80141a:	89 d8                	mov    %ebx,%eax
  80141c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80141f:	5b                   	pop    %ebx
  801420:	5e                   	pop    %esi
  801421:	5f                   	pop    %edi
  801422:	5d                   	pop    %ebp
  801423:	c3                   	ret    

00801424 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  801424:	f3 0f 1e fb          	endbr32 
  801428:	55                   	push   %ebp
  801429:	89 e5                	mov    %esp,%ebp
  80142b:	53                   	push   %ebx
  80142c:	83 ec 1c             	sub    $0x1c,%esp
  80142f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801432:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801435:	50                   	push   %eax
  801436:	53                   	push   %ebx
  801437:	e8 8f fc ff ff       	call   8010cb <fd_lookup>
  80143c:	83 c4 10             	add    $0x10,%esp
  80143f:	85 c0                	test   %eax,%eax
  801441:	78 3a                	js     80147d <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801443:	83 ec 08             	sub    $0x8,%esp
  801446:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801449:	50                   	push   %eax
  80144a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80144d:	ff 30                	pushl  (%eax)
  80144f:	e8 cb fc ff ff       	call   80111f <dev_lookup>
  801454:	83 c4 10             	add    $0x10,%esp
  801457:	85 c0                	test   %eax,%eax
  801459:	78 22                	js     80147d <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80145b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80145e:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801462:	74 1e                	je     801482 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801464:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801467:	8b 52 0c             	mov    0xc(%edx),%edx
  80146a:	85 d2                	test   %edx,%edx
  80146c:	74 35                	je     8014a3 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80146e:	83 ec 04             	sub    $0x4,%esp
  801471:	ff 75 10             	pushl  0x10(%ebp)
  801474:	ff 75 0c             	pushl  0xc(%ebp)
  801477:	50                   	push   %eax
  801478:	ff d2                	call   *%edx
  80147a:	83 c4 10             	add    $0x10,%esp
}
  80147d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801480:	c9                   	leave  
  801481:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801482:	a1 90 67 80 00       	mov    0x806790,%eax
  801487:	8b 40 48             	mov    0x48(%eax),%eax
  80148a:	83 ec 04             	sub    $0x4,%esp
  80148d:	53                   	push   %ebx
  80148e:	50                   	push   %eax
  80148f:	68 29 2b 80 00       	push   $0x802b29
  801494:	e8 7a f0 ff ff       	call   800513 <cprintf>
		return -E_INVAL;
  801499:	83 c4 10             	add    $0x10,%esp
  80149c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014a1:	eb da                	jmp    80147d <write+0x59>
		return -E_NOT_SUPP;
  8014a3:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8014a8:	eb d3                	jmp    80147d <write+0x59>

008014aa <seek>:

int
seek(int fdnum, off_t offset)
{
  8014aa:	f3 0f 1e fb          	endbr32 
  8014ae:	55                   	push   %ebp
  8014af:	89 e5                	mov    %esp,%ebp
  8014b1:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8014b4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014b7:	50                   	push   %eax
  8014b8:	ff 75 08             	pushl  0x8(%ebp)
  8014bb:	e8 0b fc ff ff       	call   8010cb <fd_lookup>
  8014c0:	83 c4 10             	add    $0x10,%esp
  8014c3:	85 c0                	test   %eax,%eax
  8014c5:	78 0e                	js     8014d5 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8014c7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014ca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8014cd:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8014d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014d5:	c9                   	leave  
  8014d6:	c3                   	ret    

008014d7 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8014d7:	f3 0f 1e fb          	endbr32 
  8014db:	55                   	push   %ebp
  8014dc:	89 e5                	mov    %esp,%ebp
  8014de:	53                   	push   %ebx
  8014df:	83 ec 1c             	sub    $0x1c,%esp
  8014e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8014e5:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8014e8:	50                   	push   %eax
  8014e9:	53                   	push   %ebx
  8014ea:	e8 dc fb ff ff       	call   8010cb <fd_lookup>
  8014ef:	83 c4 10             	add    $0x10,%esp
  8014f2:	85 c0                	test   %eax,%eax
  8014f4:	78 37                	js     80152d <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014f6:	83 ec 08             	sub    $0x8,%esp
  8014f9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014fc:	50                   	push   %eax
  8014fd:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801500:	ff 30                	pushl  (%eax)
  801502:	e8 18 fc ff ff       	call   80111f <dev_lookup>
  801507:	83 c4 10             	add    $0x10,%esp
  80150a:	85 c0                	test   %eax,%eax
  80150c:	78 1f                	js     80152d <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80150e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801511:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801515:	74 1b                	je     801532 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  801517:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80151a:	8b 52 18             	mov    0x18(%edx),%edx
  80151d:	85 d2                	test   %edx,%edx
  80151f:	74 32                	je     801553 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  801521:	83 ec 08             	sub    $0x8,%esp
  801524:	ff 75 0c             	pushl  0xc(%ebp)
  801527:	50                   	push   %eax
  801528:	ff d2                	call   *%edx
  80152a:	83 c4 10             	add    $0x10,%esp
}
  80152d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801530:	c9                   	leave  
  801531:	c3                   	ret    
			thisenv->env_id, fdnum);
  801532:	a1 90 67 80 00       	mov    0x806790,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801537:	8b 40 48             	mov    0x48(%eax),%eax
  80153a:	83 ec 04             	sub    $0x4,%esp
  80153d:	53                   	push   %ebx
  80153e:	50                   	push   %eax
  80153f:	68 ec 2a 80 00       	push   $0x802aec
  801544:	e8 ca ef ff ff       	call   800513 <cprintf>
		return -E_INVAL;
  801549:	83 c4 10             	add    $0x10,%esp
  80154c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801551:	eb da                	jmp    80152d <ftruncate+0x56>
		return -E_NOT_SUPP;
  801553:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801558:	eb d3                	jmp    80152d <ftruncate+0x56>

0080155a <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80155a:	f3 0f 1e fb          	endbr32 
  80155e:	55                   	push   %ebp
  80155f:	89 e5                	mov    %esp,%ebp
  801561:	53                   	push   %ebx
  801562:	83 ec 1c             	sub    $0x1c,%esp
  801565:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801568:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80156b:	50                   	push   %eax
  80156c:	ff 75 08             	pushl  0x8(%ebp)
  80156f:	e8 57 fb ff ff       	call   8010cb <fd_lookup>
  801574:	83 c4 10             	add    $0x10,%esp
  801577:	85 c0                	test   %eax,%eax
  801579:	78 4b                	js     8015c6 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80157b:	83 ec 08             	sub    $0x8,%esp
  80157e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801581:	50                   	push   %eax
  801582:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801585:	ff 30                	pushl  (%eax)
  801587:	e8 93 fb ff ff       	call   80111f <dev_lookup>
  80158c:	83 c4 10             	add    $0x10,%esp
  80158f:	85 c0                	test   %eax,%eax
  801591:	78 33                	js     8015c6 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801593:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801596:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80159a:	74 2f                	je     8015cb <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80159c:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80159f:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8015a6:	00 00 00 
	stat->st_isdir = 0;
  8015a9:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8015b0:	00 00 00 
	stat->st_dev = dev;
  8015b3:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8015b9:	83 ec 08             	sub    $0x8,%esp
  8015bc:	53                   	push   %ebx
  8015bd:	ff 75 f0             	pushl  -0x10(%ebp)
  8015c0:	ff 50 14             	call   *0x14(%eax)
  8015c3:	83 c4 10             	add    $0x10,%esp
}
  8015c6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8015c9:	c9                   	leave  
  8015ca:	c3                   	ret    
		return -E_NOT_SUPP;
  8015cb:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8015d0:	eb f4                	jmp    8015c6 <fstat+0x6c>

008015d2 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8015d2:	f3 0f 1e fb          	endbr32 
  8015d6:	55                   	push   %ebp
  8015d7:	89 e5                	mov    %esp,%ebp
  8015d9:	56                   	push   %esi
  8015da:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8015db:	83 ec 08             	sub    $0x8,%esp
  8015de:	6a 00                	push   $0x0
  8015e0:	ff 75 08             	pushl  0x8(%ebp)
  8015e3:	e8 fb 01 00 00       	call   8017e3 <open>
  8015e8:	89 c3                	mov    %eax,%ebx
  8015ea:	83 c4 10             	add    $0x10,%esp
  8015ed:	85 c0                	test   %eax,%eax
  8015ef:	78 1b                	js     80160c <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8015f1:	83 ec 08             	sub    $0x8,%esp
  8015f4:	ff 75 0c             	pushl  0xc(%ebp)
  8015f7:	50                   	push   %eax
  8015f8:	e8 5d ff ff ff       	call   80155a <fstat>
  8015fd:	89 c6                	mov    %eax,%esi
	close(fd);
  8015ff:	89 1c 24             	mov    %ebx,(%esp)
  801602:	e8 fd fb ff ff       	call   801204 <close>
	return r;
  801607:	83 c4 10             	add    $0x10,%esp
  80160a:	89 f3                	mov    %esi,%ebx
}
  80160c:	89 d8                	mov    %ebx,%eax
  80160e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801611:	5b                   	pop    %ebx
  801612:	5e                   	pop    %esi
  801613:	5d                   	pop    %ebp
  801614:	c3                   	ret    

00801615 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  801615:	55                   	push   %ebp
  801616:	89 e5                	mov    %esp,%ebp
  801618:	56                   	push   %esi
  801619:	53                   	push   %ebx
  80161a:	89 c6                	mov    %eax,%esi
  80161c:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80161e:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  801625:	74 27                	je     80164e <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801627:	6a 07                	push   $0x7
  801629:	68 00 70 80 00       	push   $0x807000
  80162e:	56                   	push   %esi
  80162f:	ff 35 00 50 80 00    	pushl  0x805000
  801635:	e8 85 0c 00 00       	call   8022bf <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80163a:	83 c4 0c             	add    $0xc,%esp
  80163d:	6a 00                	push   $0x0
  80163f:	53                   	push   %ebx
  801640:	6a 00                	push   $0x0
  801642:	e8 0a 0c 00 00       	call   802251 <ipc_recv>
}
  801647:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80164a:	5b                   	pop    %ebx
  80164b:	5e                   	pop    %esi
  80164c:	5d                   	pop    %ebp
  80164d:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80164e:	83 ec 0c             	sub    $0xc,%esp
  801651:	6a 01                	push   $0x1
  801653:	e8 cc 0c 00 00       	call   802324 <ipc_find_env>
  801658:	a3 00 50 80 00       	mov    %eax,0x805000
  80165d:	83 c4 10             	add    $0x10,%esp
  801660:	eb c5                	jmp    801627 <fsipc+0x12>

00801662 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801662:	f3 0f 1e fb          	endbr32 
  801666:	55                   	push   %ebp
  801667:	89 e5                	mov    %esp,%ebp
  801669:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80166c:	8b 45 08             	mov    0x8(%ebp),%eax
  80166f:	8b 40 0c             	mov    0xc(%eax),%eax
  801672:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.set_size.req_size = newsize;
  801677:	8b 45 0c             	mov    0xc(%ebp),%eax
  80167a:	a3 04 70 80 00       	mov    %eax,0x807004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80167f:	ba 00 00 00 00       	mov    $0x0,%edx
  801684:	b8 02 00 00 00       	mov    $0x2,%eax
  801689:	e8 87 ff ff ff       	call   801615 <fsipc>
}
  80168e:	c9                   	leave  
  80168f:	c3                   	ret    

00801690 <devfile_flush>:
{
  801690:	f3 0f 1e fb          	endbr32 
  801694:	55                   	push   %ebp
  801695:	89 e5                	mov    %esp,%ebp
  801697:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80169a:	8b 45 08             	mov    0x8(%ebp),%eax
  80169d:	8b 40 0c             	mov    0xc(%eax),%eax
  8016a0:	a3 00 70 80 00       	mov    %eax,0x807000
	return fsipc(FSREQ_FLUSH, NULL);
  8016a5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016aa:	b8 06 00 00 00       	mov    $0x6,%eax
  8016af:	e8 61 ff ff ff       	call   801615 <fsipc>
}
  8016b4:	c9                   	leave  
  8016b5:	c3                   	ret    

008016b6 <devfile_stat>:
{
  8016b6:	f3 0f 1e fb          	endbr32 
  8016ba:	55                   	push   %ebp
  8016bb:	89 e5                	mov    %esp,%ebp
  8016bd:	53                   	push   %ebx
  8016be:	83 ec 04             	sub    $0x4,%esp
  8016c1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8016c4:	8b 45 08             	mov    0x8(%ebp),%eax
  8016c7:	8b 40 0c             	mov    0xc(%eax),%eax
  8016ca:	a3 00 70 80 00       	mov    %eax,0x807000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8016cf:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d4:	b8 05 00 00 00       	mov    $0x5,%eax
  8016d9:	e8 37 ff ff ff       	call   801615 <fsipc>
  8016de:	85 c0                	test   %eax,%eax
  8016e0:	78 2c                	js     80170e <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8016e2:	83 ec 08             	sub    $0x8,%esp
  8016e5:	68 00 70 80 00       	push   $0x807000
  8016ea:	53                   	push   %ebx
  8016eb:	e8 8d f3 ff ff       	call   800a7d <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016f0:	a1 80 70 80 00       	mov    0x807080,%eax
  8016f5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016fb:	a1 84 70 80 00       	mov    0x807084,%eax
  801700:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801706:	83 c4 10             	add    $0x10,%esp
  801709:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80170e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801711:	c9                   	leave  
  801712:	c3                   	ret    

00801713 <devfile_write>:
{
  801713:	f3 0f 1e fb          	endbr32 
  801717:	55                   	push   %ebp
  801718:	89 e5                	mov    %esp,%ebp
  80171a:	83 ec 0c             	sub    $0xc,%esp
  80171d:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801720:	8b 55 08             	mov    0x8(%ebp),%edx
  801723:	8b 52 0c             	mov    0xc(%edx),%edx
  801726:	89 15 00 70 80 00    	mov    %edx,0x807000
	fsipcbuf.write.req_n = n;
  80172c:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801731:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801736:	0f 47 c2             	cmova  %edx,%eax
  801739:	a3 04 70 80 00       	mov    %eax,0x807004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80173e:	50                   	push   %eax
  80173f:	ff 75 0c             	pushl  0xc(%ebp)
  801742:	68 08 70 80 00       	push   $0x807008
  801747:	e8 e9 f4 ff ff       	call   800c35 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  80174c:	ba 00 00 00 00       	mov    $0x0,%edx
  801751:	b8 04 00 00 00       	mov    $0x4,%eax
  801756:	e8 ba fe ff ff       	call   801615 <fsipc>
}
  80175b:	c9                   	leave  
  80175c:	c3                   	ret    

0080175d <devfile_read>:
{
  80175d:	f3 0f 1e fb          	endbr32 
  801761:	55                   	push   %ebp
  801762:	89 e5                	mov    %esp,%ebp
  801764:	56                   	push   %esi
  801765:	53                   	push   %ebx
  801766:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801769:	8b 45 08             	mov    0x8(%ebp),%eax
  80176c:	8b 40 0c             	mov    0xc(%eax),%eax
  80176f:	a3 00 70 80 00       	mov    %eax,0x807000
	fsipcbuf.read.req_n = n;
  801774:	89 35 04 70 80 00    	mov    %esi,0x807004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80177a:	ba 00 00 00 00       	mov    $0x0,%edx
  80177f:	b8 03 00 00 00       	mov    $0x3,%eax
  801784:	e8 8c fe ff ff       	call   801615 <fsipc>
  801789:	89 c3                	mov    %eax,%ebx
  80178b:	85 c0                	test   %eax,%eax
  80178d:	78 1f                	js     8017ae <devfile_read+0x51>
	assert(r <= n);
  80178f:	39 f0                	cmp    %esi,%eax
  801791:	77 24                	ja     8017b7 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801793:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801798:	7f 33                	jg     8017cd <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80179a:	83 ec 04             	sub    $0x4,%esp
  80179d:	50                   	push   %eax
  80179e:	68 00 70 80 00       	push   $0x807000
  8017a3:	ff 75 0c             	pushl  0xc(%ebp)
  8017a6:	e8 8a f4 ff ff       	call   800c35 <memmove>
	return r;
  8017ab:	83 c4 10             	add    $0x10,%esp
}
  8017ae:	89 d8                	mov    %ebx,%eax
  8017b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8017b3:	5b                   	pop    %ebx
  8017b4:	5e                   	pop    %esi
  8017b5:	5d                   	pop    %ebp
  8017b6:	c3                   	ret    
	assert(r <= n);
  8017b7:	68 58 2b 80 00       	push   $0x802b58
  8017bc:	68 5f 2b 80 00       	push   $0x802b5f
  8017c1:	6a 7c                	push   $0x7c
  8017c3:	68 74 2b 80 00       	push   $0x802b74
  8017c8:	e8 5f ec ff ff       	call   80042c <_panic>
	assert(r <= PGSIZE);
  8017cd:	68 7f 2b 80 00       	push   $0x802b7f
  8017d2:	68 5f 2b 80 00       	push   $0x802b5f
  8017d7:	6a 7d                	push   $0x7d
  8017d9:	68 74 2b 80 00       	push   $0x802b74
  8017de:	e8 49 ec ff ff       	call   80042c <_panic>

008017e3 <open>:
{
  8017e3:	f3 0f 1e fb          	endbr32 
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	56                   	push   %esi
  8017eb:	53                   	push   %ebx
  8017ec:	83 ec 1c             	sub    $0x1c,%esp
  8017ef:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8017f2:	56                   	push   %esi
  8017f3:	e8 42 f2 ff ff       	call   800a3a <strlen>
  8017f8:	83 c4 10             	add    $0x10,%esp
  8017fb:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801800:	7f 6c                	jg     80186e <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801802:	83 ec 0c             	sub    $0xc,%esp
  801805:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801808:	50                   	push   %eax
  801809:	e8 67 f8 ff ff       	call   801075 <fd_alloc>
  80180e:	89 c3                	mov    %eax,%ebx
  801810:	83 c4 10             	add    $0x10,%esp
  801813:	85 c0                	test   %eax,%eax
  801815:	78 3c                	js     801853 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801817:	83 ec 08             	sub    $0x8,%esp
  80181a:	56                   	push   %esi
  80181b:	68 00 70 80 00       	push   $0x807000
  801820:	e8 58 f2 ff ff       	call   800a7d <strcpy>
	fsipcbuf.open.req_omode = mode;
  801825:	8b 45 0c             	mov    0xc(%ebp),%eax
  801828:	a3 00 74 80 00       	mov    %eax,0x807400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80182d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801830:	b8 01 00 00 00       	mov    $0x1,%eax
  801835:	e8 db fd ff ff       	call   801615 <fsipc>
  80183a:	89 c3                	mov    %eax,%ebx
  80183c:	83 c4 10             	add    $0x10,%esp
  80183f:	85 c0                	test   %eax,%eax
  801841:	78 19                	js     80185c <open+0x79>
	return fd2num(fd);
  801843:	83 ec 0c             	sub    $0xc,%esp
  801846:	ff 75 f4             	pushl  -0xc(%ebp)
  801849:	e8 f4 f7 ff ff       	call   801042 <fd2num>
  80184e:	89 c3                	mov    %eax,%ebx
  801850:	83 c4 10             	add    $0x10,%esp
}
  801853:	89 d8                	mov    %ebx,%eax
  801855:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801858:	5b                   	pop    %ebx
  801859:	5e                   	pop    %esi
  80185a:	5d                   	pop    %ebp
  80185b:	c3                   	ret    
		fd_close(fd, 0);
  80185c:	83 ec 08             	sub    $0x8,%esp
  80185f:	6a 00                	push   $0x0
  801861:	ff 75 f4             	pushl  -0xc(%ebp)
  801864:	e8 10 f9 ff ff       	call   801179 <fd_close>
		return r;
  801869:	83 c4 10             	add    $0x10,%esp
  80186c:	eb e5                	jmp    801853 <open+0x70>
		return -E_BAD_PATH;
  80186e:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801873:	eb de                	jmp    801853 <open+0x70>

00801875 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801875:	f3 0f 1e fb          	endbr32 
  801879:	55                   	push   %ebp
  80187a:	89 e5                	mov    %esp,%ebp
  80187c:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80187f:	ba 00 00 00 00       	mov    $0x0,%edx
  801884:	b8 08 00 00 00       	mov    $0x8,%eax
  801889:	e8 87 fd ff ff       	call   801615 <fsipc>
}
  80188e:	c9                   	leave  
  80188f:	c3                   	ret    

00801890 <copy_shared_pages>:
}

// Copy the mappings for shared pages into the child address space.
static int
copy_shared_pages(envid_t child)
{
  801890:	55                   	push   %ebp
  801891:	89 e5                	mov    %esp,%ebp
  801893:	56                   	push   %esi
  801894:	53                   	push   %ebx
  801895:	89 c6                	mov    %eax,%esi
	// LAB 5: Your code here.
	for(uint32_t addr = UTEXT; addr < UTOP; addr +=PGSIZE){
  801897:	bb 00 00 80 00       	mov    $0x800000,%ebx
  80189c:	eb 33                	jmp    8018d1 <copy_shared_pages+0x41>
		if(addr != UXSTACKTOP - PGSIZE){
			if(((uvpd[PDX(addr)] & PTE_P) != 0) && ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U|PTE_SHARE))) == 0){
				sys_page_map(0, (void*)addr, child, (void*)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  80189e:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8018a5:	83 ec 0c             	sub    $0xc,%esp
  8018a8:	25 07 0e 00 00       	and    $0xe07,%eax
  8018ad:	50                   	push   %eax
  8018ae:	53                   	push   %ebx
  8018af:	56                   	push   %esi
  8018b0:	53                   	push   %ebx
  8018b1:	6a 00                	push   $0x0
  8018b3:	e8 75 f6 ff ff       	call   800f2d <sys_page_map>
  8018b8:	83 c4 20             	add    $0x20,%esp
	for(uint32_t addr = UTEXT; addr < UTOP; addr +=PGSIZE){
  8018bb:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8018c1:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  8018c7:	77 2f                	ja     8018f8 <copy_shared_pages+0x68>
		if(addr != UXSTACKTOP - PGSIZE){
  8018c9:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8018cf:	74 ea                	je     8018bb <copy_shared_pages+0x2b>
			if(((uvpd[PDX(addr)] & PTE_P) != 0) && ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U|PTE_SHARE))) == 0){
  8018d1:	89 d8                	mov    %ebx,%eax
  8018d3:	c1 e8 16             	shr    $0x16,%eax
  8018d6:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8018dd:	a8 01                	test   $0x1,%al
  8018df:	74 da                	je     8018bb <copy_shared_pages+0x2b>
  8018e1:	89 da                	mov    %ebx,%edx
  8018e3:	c1 ea 0c             	shr    $0xc,%edx
  8018e6:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8018ed:	f7 d0                	not    %eax
  8018ef:	a9 05 04 00 00       	test   $0x405,%eax
  8018f4:	75 c5                	jne    8018bb <copy_shared_pages+0x2b>
  8018f6:	eb a6                	jmp    80189e <copy_shared_pages+0xe>
			}
		}
	}
	return 0;
}
  8018f8:	b8 00 00 00 00       	mov    $0x0,%eax
  8018fd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801900:	5b                   	pop    %ebx
  801901:	5e                   	pop    %esi
  801902:	5d                   	pop    %ebp
  801903:	c3                   	ret    

00801904 <init_stack>:
{
  801904:	55                   	push   %ebp
  801905:	89 e5                	mov    %esp,%ebp
  801907:	57                   	push   %edi
  801908:	56                   	push   %esi
  801909:	53                   	push   %ebx
  80190a:	83 ec 2c             	sub    $0x2c,%esp
  80190d:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  801910:	89 55 d0             	mov    %edx,-0x30(%ebp)
  801913:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (argc = 0; argv[argc] != 0; argc++)
  801916:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  80191b:	be 00 00 00 00       	mov    $0x0,%esi
  801920:	89 d7                	mov    %edx,%edi
  801922:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
	for (argc = 0; argv[argc] != 0; argc++)
  801929:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80192c:	85 c0                	test   %eax,%eax
  80192e:	74 15                	je     801945 <init_stack+0x41>
		string_size += strlen(argv[argc]) + 1;
  801930:	83 ec 0c             	sub    $0xc,%esp
  801933:	50                   	push   %eax
  801934:	e8 01 f1 ff ff       	call   800a3a <strlen>
  801939:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  80193d:	83 c3 01             	add    $0x1,%ebx
  801940:	83 c4 10             	add    $0x10,%esp
  801943:	eb dd                	jmp    801922 <init_stack+0x1e>
  801945:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  801948:	89 4d d8             	mov    %ecx,-0x28(%ebp)
	string_store = (char *) UTEMP + PGSIZE - string_size;
  80194b:	bf 00 10 40 00       	mov    $0x401000,%edi
  801950:	29 f7                	sub    %esi,%edi
	argv_store = (uintptr_t *) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  801952:	89 fa                	mov    %edi,%edx
  801954:	83 e2 fc             	and    $0xfffffffc,%edx
  801957:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80195e:	29 c2                	sub    %eax,%edx
  801960:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	if ((void *) (argv_store - 2) < (void *) UTEMP)
  801963:	8d 42 f8             	lea    -0x8(%edx),%eax
  801966:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80196b:	0f 86 06 01 00 00    	jbe    801a77 <init_stack+0x173>
	if ((r = sys_page_alloc(0, (void *) UTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  801971:	83 ec 04             	sub    $0x4,%esp
  801974:	6a 07                	push   $0x7
  801976:	68 00 00 40 00       	push   $0x400000
  80197b:	6a 00                	push   $0x0
  80197d:	e8 83 f5 ff ff       	call   800f05 <sys_page_alloc>
  801982:	89 c6                	mov    %eax,%esi
  801984:	83 c4 10             	add    $0x10,%esp
  801987:	85 c0                	test   %eax,%eax
  801989:	0f 88 de 00 00 00    	js     801a6d <init_stack+0x169>
	for (i = 0; i < argc; i++) {
  80198f:	be 00 00 00 00       	mov    $0x0,%esi
  801994:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  801997:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  80199a:	39 75 e0             	cmp    %esi,-0x20(%ebp)
  80199d:	7e 2f                	jle    8019ce <init_stack+0xca>
		argv_store[i] = UTEMP2USTACK(string_store);
  80199f:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8019a5:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8019a8:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8019ab:	83 ec 08             	sub    $0x8,%esp
  8019ae:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8019b1:	57                   	push   %edi
  8019b2:	e8 c6 f0 ff ff       	call   800a7d <strcpy>
		string_store += strlen(argv[i]) + 1;
  8019b7:	83 c4 04             	add    $0x4,%esp
  8019ba:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8019bd:	e8 78 f0 ff ff       	call   800a3a <strlen>
  8019c2:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  8019c6:	83 c6 01             	add    $0x1,%esi
  8019c9:	83 c4 10             	add    $0x10,%esp
  8019cc:	eb cc                	jmp    80199a <init_stack+0x96>
	argv_store[argc] = 0;
  8019ce:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8019d1:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8019d4:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char *) UTEMP + PGSIZE);
  8019db:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8019e1:	75 5f                	jne    801a42 <init_stack+0x13e>
	argv_store[-1] = UTEMP2USTACK(argv_store);
  8019e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8019e6:	8d 82 00 d0 7f ee    	lea    -0x11803000(%edx),%eax
  8019ec:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  8019ef:	89 d0                	mov    %edx,%eax
  8019f1:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8019f4:	89 4a f8             	mov    %ecx,-0x8(%edx)
	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  8019f7:	2d 08 30 80 11       	sub    $0x11803008,%eax
  8019fc:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  8019ff:	89 01                	mov    %eax,(%ecx)
	if ((r = sys_page_map(0,
  801a01:	83 ec 0c             	sub    $0xc,%esp
  801a04:	6a 07                	push   $0x7
  801a06:	68 00 d0 bf ee       	push   $0xeebfd000
  801a0b:	ff 75 d4             	pushl  -0x2c(%ebp)
  801a0e:	68 00 00 40 00       	push   $0x400000
  801a13:	6a 00                	push   $0x0
  801a15:	e8 13 f5 ff ff       	call   800f2d <sys_page_map>
  801a1a:	89 c6                	mov    %eax,%esi
  801a1c:	83 c4 20             	add    $0x20,%esp
  801a1f:	85 c0                	test   %eax,%eax
  801a21:	78 38                	js     801a5b <init_stack+0x157>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  801a23:	83 ec 08             	sub    $0x8,%esp
  801a26:	68 00 00 40 00       	push   $0x400000
  801a2b:	6a 00                	push   $0x0
  801a2d:	e8 25 f5 ff ff       	call   800f57 <sys_page_unmap>
  801a32:	89 c6                	mov    %eax,%esi
  801a34:	83 c4 10             	add    $0x10,%esp
  801a37:	85 c0                	test   %eax,%eax
  801a39:	78 20                	js     801a5b <init_stack+0x157>
	return 0;
  801a3b:	be 00 00 00 00       	mov    $0x0,%esi
  801a40:	eb 2b                	jmp    801a6d <init_stack+0x169>
	assert(string_store == (char *) UTEMP + PGSIZE);
  801a42:	68 8c 2b 80 00       	push   $0x802b8c
  801a47:	68 5f 2b 80 00       	push   $0x802b5f
  801a4c:	68 fc 00 00 00       	push   $0xfc
  801a51:	68 b4 2b 80 00       	push   $0x802bb4
  801a56:	e8 d1 e9 ff ff       	call   80042c <_panic>
	sys_page_unmap(0, UTEMP);
  801a5b:	83 ec 08             	sub    $0x8,%esp
  801a5e:	68 00 00 40 00       	push   $0x400000
  801a63:	6a 00                	push   $0x0
  801a65:	e8 ed f4 ff ff       	call   800f57 <sys_page_unmap>
	return r;
  801a6a:	83 c4 10             	add    $0x10,%esp
}
  801a6d:	89 f0                	mov    %esi,%eax
  801a6f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a72:	5b                   	pop    %ebx
  801a73:	5e                   	pop    %esi
  801a74:	5f                   	pop    %edi
  801a75:	5d                   	pop    %ebp
  801a76:	c3                   	ret    
		return -E_NO_MEM;
  801a77:	be fc ff ff ff       	mov    $0xfffffffc,%esi
  801a7c:	eb ef                	jmp    801a6d <init_stack+0x169>

00801a7e <map_segment>:
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	57                   	push   %edi
  801a82:	56                   	push   %esi
  801a83:	53                   	push   %ebx
  801a84:	83 ec 1c             	sub    $0x1c,%esp
  801a87:	89 45 dc             	mov    %eax,-0x24(%ebp)
  801a8a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801a8d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  801a90:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((i = PGOFF(va))) {
  801a93:	89 d0                	mov    %edx,%eax
  801a95:	25 ff 0f 00 00       	and    $0xfff,%eax
  801a9a:	74 0f                	je     801aab <map_segment+0x2d>
		va -= i;
  801a9c:	29 c2                	sub    %eax,%edx
  801a9e:	89 55 e0             	mov    %edx,-0x20(%ebp)
		memsz += i;
  801aa1:	01 c1                	add    %eax,%ecx
  801aa3:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		filesz += i;
  801aa6:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  801aa8:	29 45 10             	sub    %eax,0x10(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  801aab:	bb 00 00 00 00       	mov    $0x0,%ebx
  801ab0:	e9 99 00 00 00       	jmp    801b4e <map_segment+0xd0>
			if ((r = sys_page_alloc(0, UTEMP, PTE_P | PTE_U | PTE_W)) <
  801ab5:	83 ec 04             	sub    $0x4,%esp
  801ab8:	6a 07                	push   $0x7
  801aba:	68 00 00 40 00       	push   $0x400000
  801abf:	6a 00                	push   $0x0
  801ac1:	e8 3f f4 ff ff       	call   800f05 <sys_page_alloc>
  801ac6:	83 c4 10             	add    $0x10,%esp
  801ac9:	85 c0                	test   %eax,%eax
  801acb:	0f 88 c1 00 00 00    	js     801b92 <map_segment+0x114>
			if ((r = seek(fd, fileoffset + i)) < 0)
  801ad1:	83 ec 08             	sub    $0x8,%esp
  801ad4:	89 f0                	mov    %esi,%eax
  801ad6:	03 45 10             	add    0x10(%ebp),%eax
  801ad9:	50                   	push   %eax
  801ada:	ff 75 08             	pushl  0x8(%ebp)
  801add:	e8 c8 f9 ff ff       	call   8014aa <seek>
  801ae2:	83 c4 10             	add    $0x10,%esp
  801ae5:	85 c0                	test   %eax,%eax
  801ae7:	0f 88 a5 00 00 00    	js     801b92 <map_segment+0x114>
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz - i))) < 0)
  801aed:	83 ec 04             	sub    $0x4,%esp
  801af0:	89 f8                	mov    %edi,%eax
  801af2:	29 f0                	sub    %esi,%eax
  801af4:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801af9:	ba 00 10 00 00       	mov    $0x1000,%edx
  801afe:	0f 47 c2             	cmova  %edx,%eax
  801b01:	50                   	push   %eax
  801b02:	68 00 00 40 00       	push   $0x400000
  801b07:	ff 75 08             	pushl  0x8(%ebp)
  801b0a:	e8 ca f8 ff ff       	call   8013d9 <readn>
  801b0f:	83 c4 10             	add    $0x10,%esp
  801b12:	85 c0                	test   %eax,%eax
  801b14:	78 7c                	js     801b92 <map_segment+0x114>
			if ((r = sys_page_map(
  801b16:	83 ec 0c             	sub    $0xc,%esp
  801b19:	ff 75 14             	pushl  0x14(%ebp)
  801b1c:	03 75 e0             	add    -0x20(%ebp),%esi
  801b1f:	56                   	push   %esi
  801b20:	ff 75 dc             	pushl  -0x24(%ebp)
  801b23:	68 00 00 40 00       	push   $0x400000
  801b28:	6a 00                	push   $0x0
  801b2a:	e8 fe f3 ff ff       	call   800f2d <sys_page_map>
  801b2f:	83 c4 20             	add    $0x20,%esp
  801b32:	85 c0                	test   %eax,%eax
  801b34:	78 42                	js     801b78 <map_segment+0xfa>
			sys_page_unmap(0, UTEMP);
  801b36:	83 ec 08             	sub    $0x8,%esp
  801b39:	68 00 00 40 00       	push   $0x400000
  801b3e:	6a 00                	push   $0x0
  801b40:	e8 12 f4 ff ff       	call   800f57 <sys_page_unmap>
  801b45:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  801b48:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801b4e:	89 de                	mov    %ebx,%esi
  801b50:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
  801b53:	76 38                	jbe    801b8d <map_segment+0x10f>
		if (i >= filesz) {
  801b55:	39 df                	cmp    %ebx,%edi
  801b57:	0f 87 58 ff ff ff    	ja     801ab5 <map_segment+0x37>
			if ((r = sys_page_alloc(child, (void *) (va + i), perm)) < 0)
  801b5d:	83 ec 04             	sub    $0x4,%esp
  801b60:	ff 75 14             	pushl  0x14(%ebp)
  801b63:	03 75 e0             	add    -0x20(%ebp),%esi
  801b66:	56                   	push   %esi
  801b67:	ff 75 dc             	pushl  -0x24(%ebp)
  801b6a:	e8 96 f3 ff ff       	call   800f05 <sys_page_alloc>
  801b6f:	83 c4 10             	add    $0x10,%esp
  801b72:	85 c0                	test   %eax,%eax
  801b74:	79 d2                	jns    801b48 <map_segment+0xca>
  801b76:	eb 1a                	jmp    801b92 <map_segment+0x114>
				panic("spawn: sys_page_map data: %e", r);
  801b78:	50                   	push   %eax
  801b79:	68 c0 2b 80 00       	push   $0x802bc0
  801b7e:	68 3a 01 00 00       	push   $0x13a
  801b83:	68 b4 2b 80 00       	push   $0x802bb4
  801b88:	e8 9f e8 ff ff       	call   80042c <_panic>
	return 0;
  801b8d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b92:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b95:	5b                   	pop    %ebx
  801b96:	5e                   	pop    %esi
  801b97:	5f                   	pop    %edi
  801b98:	5d                   	pop    %ebp
  801b99:	c3                   	ret    

00801b9a <spawn>:
{
  801b9a:	f3 0f 1e fb          	endbr32 
  801b9e:	55                   	push   %ebp
  801b9f:	89 e5                	mov    %esp,%ebp
  801ba1:	57                   	push   %edi
  801ba2:	56                   	push   %esi
  801ba3:	53                   	push   %ebx
  801ba4:	81 ec 74 02 00 00    	sub    $0x274,%esp
	if ((r = open(prog, O_RDONLY)) < 0)
  801baa:	6a 00                	push   $0x0
  801bac:	ff 75 08             	pushl  0x8(%ebp)
  801baf:	e8 2f fc ff ff       	call   8017e3 <open>
  801bb4:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801bba:	83 c4 10             	add    $0x10,%esp
  801bbd:	85 c0                	test   %eax,%eax
  801bbf:	0f 88 0b 02 00 00    	js     801dd0 <spawn+0x236>
  801bc5:	89 c7                	mov    %eax,%edi
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf) ||
  801bc7:	83 ec 04             	sub    $0x4,%esp
  801bca:	68 00 02 00 00       	push   $0x200
  801bcf:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  801bd5:	50                   	push   %eax
  801bd6:	57                   	push   %edi
  801bd7:	e8 fd f7 ff ff       	call   8013d9 <readn>
  801bdc:	83 c4 10             	add    $0x10,%esp
  801bdf:	3d 00 02 00 00       	cmp    $0x200,%eax
  801be4:	0f 85 85 00 00 00    	jne    801c6f <spawn+0xd5>
  801bea:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  801bf1:	45 4c 46 
  801bf4:	75 79                	jne    801c6f <spawn+0xd5>
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801bf6:	b8 07 00 00 00       	mov    $0x7,%eax
  801bfb:	cd 30                	int    $0x30
  801bfd:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  801c03:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	if ((r = sys_exofork()) < 0)
  801c09:	89 c3                	mov    %eax,%ebx
  801c0b:	85 c0                	test   %eax,%eax
  801c0d:	0f 88 b1 01 00 00    	js     801dc4 <spawn+0x22a>
	child_tf = envs[ENVX(child)].env_tf;
  801c13:	89 c6                	mov    %eax,%esi
  801c15:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  801c1b:	6b f6 7c             	imul   $0x7c,%esi,%esi
  801c1e:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  801c24:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  801c2a:	b9 11 00 00 00       	mov    $0x11,%ecx
  801c2f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  801c31:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  801c37:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
  801c3d:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  801c43:	8b 55 0c             	mov    0xc(%ebp),%edx
  801c46:	89 d8                	mov    %ebx,%eax
  801c48:	e8 b7 fc ff ff       	call   801904 <init_stack>
  801c4d:	85 c0                	test   %eax,%eax
  801c4f:	0f 88 89 01 00 00    	js     801dde <spawn+0x244>
	ph = (struct Proghdr *) (elf_buf + elf->e_phoff);
  801c55:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  801c5b:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801c62:	be 00 00 00 00       	mov    $0x0,%esi
  801c67:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  801c6d:	eb 3e                	jmp    801cad <spawn+0x113>
		close(fd);
  801c6f:	83 ec 0c             	sub    $0xc,%esp
  801c72:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801c78:	e8 87 f5 ff ff       	call   801204 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  801c7d:	83 c4 0c             	add    $0xc,%esp
  801c80:	68 7f 45 4c 46       	push   $0x464c457f
  801c85:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  801c8b:	68 dd 2b 80 00       	push   $0x802bdd
  801c90:	e8 7e e8 ff ff       	call   800513 <cprintf>
		return -E_NOT_EXEC;
  801c95:	83 c4 10             	add    $0x10,%esp
  801c98:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  801c9f:	ff ff ff 
  801ca2:	e9 29 01 00 00       	jmp    801dd0 <spawn+0x236>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  801ca7:	83 c6 01             	add    $0x1,%esi
  801caa:	83 c3 20             	add    $0x20,%ebx
  801cad:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  801cb4:	39 f0                	cmp    %esi,%eax
  801cb6:	7e 62                	jle    801d1a <spawn+0x180>
		if (ph->p_type != ELF_PROG_LOAD)
  801cb8:	83 3b 01             	cmpl   $0x1,(%ebx)
  801cbb:	75 ea                	jne    801ca7 <spawn+0x10d>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  801cbd:	8b 43 18             	mov    0x18(%ebx),%eax
  801cc0:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  801cc3:	83 f8 01             	cmp    $0x1,%eax
  801cc6:	19 c0                	sbb    %eax,%eax
  801cc8:	83 e0 fe             	and    $0xfffffffe,%eax
  801ccb:	83 c0 07             	add    $0x7,%eax
		if ((r = map_segment(child,
  801cce:	8b 4b 14             	mov    0x14(%ebx),%ecx
  801cd1:	8b 53 08             	mov    0x8(%ebx),%edx
  801cd4:	50                   	push   %eax
  801cd5:	ff 73 04             	pushl  0x4(%ebx)
  801cd8:	ff 73 10             	pushl  0x10(%ebx)
  801cdb:	57                   	push   %edi
  801cdc:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  801ce2:	e8 97 fd ff ff       	call   801a7e <map_segment>
  801ce7:	83 c4 10             	add    $0x10,%esp
  801cea:	85 c0                	test   %eax,%eax
  801cec:	79 b9                	jns    801ca7 <spawn+0x10d>
  801cee:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  801cf0:	83 ec 0c             	sub    $0xc,%esp
  801cf3:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801cf9:	e8 8e f1 ff ff       	call   800e8c <sys_env_destroy>
	close(fd);
  801cfe:	83 c4 04             	add    $0x4,%esp
  801d01:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801d07:	e8 f8 f4 ff ff       	call   801204 <close>
	return r;
  801d0c:	83 c4 10             	add    $0x10,%esp
		if ((r = map_segment(child,
  801d0f:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
	return r;
  801d15:	e9 b6 00 00 00       	jmp    801dd0 <spawn+0x236>
	close(fd);
  801d1a:	83 ec 0c             	sub    $0xc,%esp
  801d1d:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  801d23:	e8 dc f4 ff ff       	call   801204 <close>
	if ((r = copy_shared_pages(child)) < 0)
  801d28:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801d2e:	e8 5d fb ff ff       	call   801890 <copy_shared_pages>
  801d33:	83 c4 10             	add    $0x10,%esp
  801d36:	85 c0                	test   %eax,%eax
  801d38:	78 4b                	js     801d85 <spawn+0x1eb>
	child_tf.tf_eflags |= FL_IOPL_3;  // devious: see user/faultio.c
  801d3a:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  801d41:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  801d44:	83 ec 08             	sub    $0x8,%esp
  801d47:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  801d4d:	50                   	push   %eax
  801d4e:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d54:	e8 4c f2 ff ff       	call   800fa5 <sys_env_set_trapframe>
  801d59:	83 c4 10             	add    $0x10,%esp
  801d5c:	85 c0                	test   %eax,%eax
  801d5e:	78 3a                	js     801d9a <spawn+0x200>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  801d60:	83 ec 08             	sub    $0x8,%esp
  801d63:	6a 02                	push   $0x2
  801d65:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  801d6b:	e8 0e f2 ff ff       	call   800f7e <sys_env_set_status>
  801d70:	83 c4 10             	add    $0x10,%esp
  801d73:	85 c0                	test   %eax,%eax
  801d75:	78 38                	js     801daf <spawn+0x215>
	return child;
  801d77:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801d7d:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801d83:	eb 4b                	jmp    801dd0 <spawn+0x236>
		panic("copy_shared_pages: %e", r);
  801d85:	50                   	push   %eax
  801d86:	68 f7 2b 80 00       	push   $0x802bf7
  801d8b:	68 8c 00 00 00       	push   $0x8c
  801d90:	68 b4 2b 80 00       	push   $0x802bb4
  801d95:	e8 92 e6 ff ff       	call   80042c <_panic>
		panic("sys_env_set_trapframe: %e", r);
  801d9a:	50                   	push   %eax
  801d9b:	68 0d 2c 80 00       	push   $0x802c0d
  801da0:	68 90 00 00 00       	push   $0x90
  801da5:	68 b4 2b 80 00       	push   $0x802bb4
  801daa:	e8 7d e6 ff ff       	call   80042c <_panic>
		panic("sys_env_set_status: %e", r);
  801daf:	50                   	push   %eax
  801db0:	68 27 2c 80 00       	push   $0x802c27
  801db5:	68 93 00 00 00       	push   $0x93
  801dba:	68 b4 2b 80 00       	push   $0x802bb4
  801dbf:	e8 68 e6 ff ff       	call   80042c <_panic>
		return r;
  801dc4:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  801dca:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
}
  801dd0:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  801dd6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dd9:	5b                   	pop    %ebx
  801dda:	5e                   	pop    %esi
  801ddb:	5f                   	pop    %edi
  801ddc:	5d                   	pop    %ebp
  801ddd:	c3                   	ret    
		return r;
  801dde:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  801de4:	eb ea                	jmp    801dd0 <spawn+0x236>

00801de6 <spawnl>:
{
  801de6:	f3 0f 1e fb          	endbr32 
  801dea:	55                   	push   %ebp
  801deb:	89 e5                	mov    %esp,%ebp
  801ded:	57                   	push   %edi
  801dee:	56                   	push   %esi
  801def:	53                   	push   %ebx
  801df0:	83 ec 0c             	sub    $0xc,%esp
	va_start(vl, arg0);
  801df3:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc = 0;
  801df6:	b8 00 00 00 00       	mov    $0x0,%eax
	while (va_arg(vl, void *) != NULL)
  801dfb:	8d 4a 04             	lea    0x4(%edx),%ecx
  801dfe:	83 3a 00             	cmpl   $0x0,(%edx)
  801e01:	74 07                	je     801e0a <spawnl+0x24>
		argc++;
  801e03:	83 c0 01             	add    $0x1,%eax
	while (va_arg(vl, void *) != NULL)
  801e06:	89 ca                	mov    %ecx,%edx
  801e08:	eb f1                	jmp    801dfb <spawnl+0x15>
	const char *argv[argc + 2];
  801e0a:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  801e11:	89 d1                	mov    %edx,%ecx
  801e13:	83 e1 f0             	and    $0xfffffff0,%ecx
  801e16:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  801e1c:	89 e6                	mov    %esp,%esi
  801e1e:	29 d6                	sub    %edx,%esi
  801e20:	89 f2                	mov    %esi,%edx
  801e22:	39 d4                	cmp    %edx,%esp
  801e24:	74 10                	je     801e36 <spawnl+0x50>
  801e26:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  801e2c:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  801e33:	00 
  801e34:	eb ec                	jmp    801e22 <spawnl+0x3c>
  801e36:	89 ca                	mov    %ecx,%edx
  801e38:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  801e3e:	29 d4                	sub    %edx,%esp
  801e40:	85 d2                	test   %edx,%edx
  801e42:	74 05                	je     801e49 <spawnl+0x63>
  801e44:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  801e49:	8d 74 24 03          	lea    0x3(%esp),%esi
  801e4d:	89 f2                	mov    %esi,%edx
  801e4f:	c1 ea 02             	shr    $0x2,%edx
  801e52:	83 e6 fc             	and    $0xfffffffc,%esi
  801e55:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  801e57:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e5a:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc + 1] = NULL;
  801e61:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  801e68:	00 
	va_start(vl, arg0);
  801e69:	8d 4d 10             	lea    0x10(%ebp),%ecx
  801e6c:	89 c2                	mov    %eax,%edx
	for (i = 0; i < argc; i++)
  801e6e:	b8 00 00 00 00       	mov    $0x0,%eax
  801e73:	eb 0b                	jmp    801e80 <spawnl+0x9a>
		argv[i + 1] = va_arg(vl, const char *);
  801e75:	83 c0 01             	add    $0x1,%eax
  801e78:	8b 39                	mov    (%ecx),%edi
  801e7a:	89 3c 83             	mov    %edi,(%ebx,%eax,4)
  801e7d:	8d 49 04             	lea    0x4(%ecx),%ecx
	for (i = 0; i < argc; i++)
  801e80:	39 d0                	cmp    %edx,%eax
  801e82:	75 f1                	jne    801e75 <spawnl+0x8f>
	return spawn(prog, argv);
  801e84:	83 ec 08             	sub    $0x8,%esp
  801e87:	56                   	push   %esi
  801e88:	ff 75 08             	pushl  0x8(%ebp)
  801e8b:	e8 0a fd ff ff       	call   801b9a <spawn>
}
  801e90:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e93:	5b                   	pop    %ebx
  801e94:	5e                   	pop    %esi
  801e95:	5f                   	pop    %edi
  801e96:	5d                   	pop    %ebp
  801e97:	c3                   	ret    

00801e98 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801e98:	f3 0f 1e fb          	endbr32 
  801e9c:	55                   	push   %ebp
  801e9d:	89 e5                	mov    %esp,%ebp
  801e9f:	56                   	push   %esi
  801ea0:	53                   	push   %ebx
  801ea1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801ea4:	83 ec 0c             	sub    $0xc,%esp
  801ea7:	ff 75 08             	pushl  0x8(%ebp)
  801eaa:	e8 a7 f1 ff ff       	call   801056 <fd2data>
  801eaf:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801eb1:	83 c4 08             	add    $0x8,%esp
  801eb4:	68 3e 2c 80 00       	push   $0x802c3e
  801eb9:	53                   	push   %ebx
  801eba:	e8 be eb ff ff       	call   800a7d <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801ebf:	8b 46 04             	mov    0x4(%esi),%eax
  801ec2:	2b 06                	sub    (%esi),%eax
  801ec4:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801eca:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ed1:	00 00 00 
	stat->st_dev = &devpipe;
  801ed4:	c7 83 88 00 00 00 ac 	movl   $0x8047ac,0x88(%ebx)
  801edb:	47 80 00 
	return 0;
}
  801ede:	b8 00 00 00 00       	mov    $0x0,%eax
  801ee3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801ee6:	5b                   	pop    %ebx
  801ee7:	5e                   	pop    %esi
  801ee8:	5d                   	pop    %ebp
  801ee9:	c3                   	ret    

00801eea <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801eea:	f3 0f 1e fb          	endbr32 
  801eee:	55                   	push   %ebp
  801eef:	89 e5                	mov    %esp,%ebp
  801ef1:	53                   	push   %ebx
  801ef2:	83 ec 0c             	sub    $0xc,%esp
  801ef5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801ef8:	53                   	push   %ebx
  801ef9:	6a 00                	push   $0x0
  801efb:	e8 57 f0 ff ff       	call   800f57 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801f00:	89 1c 24             	mov    %ebx,(%esp)
  801f03:	e8 4e f1 ff ff       	call   801056 <fd2data>
  801f08:	83 c4 08             	add    $0x8,%esp
  801f0b:	50                   	push   %eax
  801f0c:	6a 00                	push   $0x0
  801f0e:	e8 44 f0 ff ff       	call   800f57 <sys_page_unmap>
}
  801f13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801f16:	c9                   	leave  
  801f17:	c3                   	ret    

00801f18 <_pipeisclosed>:
{
  801f18:	55                   	push   %ebp
  801f19:	89 e5                	mov    %esp,%ebp
  801f1b:	57                   	push   %edi
  801f1c:	56                   	push   %esi
  801f1d:	53                   	push   %ebx
  801f1e:	83 ec 1c             	sub    $0x1c,%esp
  801f21:	89 c7                	mov    %eax,%edi
  801f23:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801f25:	a1 90 67 80 00       	mov    0x806790,%eax
  801f2a:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801f2d:	83 ec 0c             	sub    $0xc,%esp
  801f30:	57                   	push   %edi
  801f31:	e8 2b 04 00 00       	call   802361 <pageref>
  801f36:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801f39:	89 34 24             	mov    %esi,(%esp)
  801f3c:	e8 20 04 00 00       	call   802361 <pageref>
		nn = thisenv->env_runs;
  801f41:	8b 15 90 67 80 00    	mov    0x806790,%edx
  801f47:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801f4a:	83 c4 10             	add    $0x10,%esp
  801f4d:	39 cb                	cmp    %ecx,%ebx
  801f4f:	74 1b                	je     801f6c <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801f51:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f54:	75 cf                	jne    801f25 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801f56:	8b 42 58             	mov    0x58(%edx),%eax
  801f59:	6a 01                	push   $0x1
  801f5b:	50                   	push   %eax
  801f5c:	53                   	push   %ebx
  801f5d:	68 45 2c 80 00       	push   $0x802c45
  801f62:	e8 ac e5 ff ff       	call   800513 <cprintf>
  801f67:	83 c4 10             	add    $0x10,%esp
  801f6a:	eb b9                	jmp    801f25 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801f6c:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801f6f:	0f 94 c0             	sete   %al
  801f72:	0f b6 c0             	movzbl %al,%eax
}
  801f75:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801f78:	5b                   	pop    %ebx
  801f79:	5e                   	pop    %esi
  801f7a:	5f                   	pop    %edi
  801f7b:	5d                   	pop    %ebp
  801f7c:	c3                   	ret    

00801f7d <devpipe_write>:
{
  801f7d:	f3 0f 1e fb          	endbr32 
  801f81:	55                   	push   %ebp
  801f82:	89 e5                	mov    %esp,%ebp
  801f84:	57                   	push   %edi
  801f85:	56                   	push   %esi
  801f86:	53                   	push   %ebx
  801f87:	83 ec 28             	sub    $0x28,%esp
  801f8a:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801f8d:	56                   	push   %esi
  801f8e:	e8 c3 f0 ff ff       	call   801056 <fd2data>
  801f93:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801f95:	83 c4 10             	add    $0x10,%esp
  801f98:	bf 00 00 00 00       	mov    $0x0,%edi
  801f9d:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801fa0:	74 4f                	je     801ff1 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801fa2:	8b 43 04             	mov    0x4(%ebx),%eax
  801fa5:	8b 0b                	mov    (%ebx),%ecx
  801fa7:	8d 51 20             	lea    0x20(%ecx),%edx
  801faa:	39 d0                	cmp    %edx,%eax
  801fac:	72 14                	jb     801fc2 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801fae:	89 da                	mov    %ebx,%edx
  801fb0:	89 f0                	mov    %esi,%eax
  801fb2:	e8 61 ff ff ff       	call   801f18 <_pipeisclosed>
  801fb7:	85 c0                	test   %eax,%eax
  801fb9:	75 3b                	jne    801ff6 <devpipe_write+0x79>
			sys_yield();
  801fbb:	e8 1a ef ff ff       	call   800eda <sys_yield>
  801fc0:	eb e0                	jmp    801fa2 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801fc2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801fc5:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801fc9:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801fcc:	89 c2                	mov    %eax,%edx
  801fce:	c1 fa 1f             	sar    $0x1f,%edx
  801fd1:	89 d1                	mov    %edx,%ecx
  801fd3:	c1 e9 1b             	shr    $0x1b,%ecx
  801fd6:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801fd9:	83 e2 1f             	and    $0x1f,%edx
  801fdc:	29 ca                	sub    %ecx,%edx
  801fde:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801fe2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801fe6:	83 c0 01             	add    $0x1,%eax
  801fe9:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801fec:	83 c7 01             	add    $0x1,%edi
  801fef:	eb ac                	jmp    801f9d <devpipe_write+0x20>
	return i;
  801ff1:	8b 45 10             	mov    0x10(%ebp),%eax
  801ff4:	eb 05                	jmp    801ffb <devpipe_write+0x7e>
				return 0;
  801ff6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ffb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ffe:	5b                   	pop    %ebx
  801fff:	5e                   	pop    %esi
  802000:	5f                   	pop    %edi
  802001:	5d                   	pop    %ebp
  802002:	c3                   	ret    

00802003 <devpipe_read>:
{
  802003:	f3 0f 1e fb          	endbr32 
  802007:	55                   	push   %ebp
  802008:	89 e5                	mov    %esp,%ebp
  80200a:	57                   	push   %edi
  80200b:	56                   	push   %esi
  80200c:	53                   	push   %ebx
  80200d:	83 ec 18             	sub    $0x18,%esp
  802010:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802013:	57                   	push   %edi
  802014:	e8 3d f0 ff ff       	call   801056 <fd2data>
  802019:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  80201b:	83 c4 10             	add    $0x10,%esp
  80201e:	be 00 00 00 00       	mov    $0x0,%esi
  802023:	3b 75 10             	cmp    0x10(%ebp),%esi
  802026:	75 14                	jne    80203c <devpipe_read+0x39>
	return i;
  802028:	8b 45 10             	mov    0x10(%ebp),%eax
  80202b:	eb 02                	jmp    80202f <devpipe_read+0x2c>
				return i;
  80202d:	89 f0                	mov    %esi,%eax
}
  80202f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802032:	5b                   	pop    %ebx
  802033:	5e                   	pop    %esi
  802034:	5f                   	pop    %edi
  802035:	5d                   	pop    %ebp
  802036:	c3                   	ret    
			sys_yield();
  802037:	e8 9e ee ff ff       	call   800eda <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  80203c:	8b 03                	mov    (%ebx),%eax
  80203e:	3b 43 04             	cmp    0x4(%ebx),%eax
  802041:	75 18                	jne    80205b <devpipe_read+0x58>
			if (i > 0)
  802043:	85 f6                	test   %esi,%esi
  802045:	75 e6                	jne    80202d <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  802047:	89 da                	mov    %ebx,%edx
  802049:	89 f8                	mov    %edi,%eax
  80204b:	e8 c8 fe ff ff       	call   801f18 <_pipeisclosed>
  802050:	85 c0                	test   %eax,%eax
  802052:	74 e3                	je     802037 <devpipe_read+0x34>
				return 0;
  802054:	b8 00 00 00 00       	mov    $0x0,%eax
  802059:	eb d4                	jmp    80202f <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  80205b:	99                   	cltd   
  80205c:	c1 ea 1b             	shr    $0x1b,%edx
  80205f:	01 d0                	add    %edx,%eax
  802061:	83 e0 1f             	and    $0x1f,%eax
  802064:	29 d0                	sub    %edx,%eax
  802066:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  80206b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80206e:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802071:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802074:	83 c6 01             	add    $0x1,%esi
  802077:	eb aa                	jmp    802023 <devpipe_read+0x20>

00802079 <pipe>:
{
  802079:	f3 0f 1e fb          	endbr32 
  80207d:	55                   	push   %ebp
  80207e:	89 e5                	mov    %esp,%ebp
  802080:	56                   	push   %esi
  802081:	53                   	push   %ebx
  802082:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802085:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802088:	50                   	push   %eax
  802089:	e8 e7 ef ff ff       	call   801075 <fd_alloc>
  80208e:	89 c3                	mov    %eax,%ebx
  802090:	83 c4 10             	add    $0x10,%esp
  802093:	85 c0                	test   %eax,%eax
  802095:	0f 88 23 01 00 00    	js     8021be <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80209b:	83 ec 04             	sub    $0x4,%esp
  80209e:	68 07 04 00 00       	push   $0x407
  8020a3:	ff 75 f4             	pushl  -0xc(%ebp)
  8020a6:	6a 00                	push   $0x0
  8020a8:	e8 58 ee ff ff       	call   800f05 <sys_page_alloc>
  8020ad:	89 c3                	mov    %eax,%ebx
  8020af:	83 c4 10             	add    $0x10,%esp
  8020b2:	85 c0                	test   %eax,%eax
  8020b4:	0f 88 04 01 00 00    	js     8021be <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  8020ba:	83 ec 0c             	sub    $0xc,%esp
  8020bd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8020c0:	50                   	push   %eax
  8020c1:	e8 af ef ff ff       	call   801075 <fd_alloc>
  8020c6:	89 c3                	mov    %eax,%ebx
  8020c8:	83 c4 10             	add    $0x10,%esp
  8020cb:	85 c0                	test   %eax,%eax
  8020cd:	0f 88 db 00 00 00    	js     8021ae <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020d3:	83 ec 04             	sub    $0x4,%esp
  8020d6:	68 07 04 00 00       	push   $0x407
  8020db:	ff 75 f0             	pushl  -0x10(%ebp)
  8020de:	6a 00                	push   $0x0
  8020e0:	e8 20 ee ff ff       	call   800f05 <sys_page_alloc>
  8020e5:	89 c3                	mov    %eax,%ebx
  8020e7:	83 c4 10             	add    $0x10,%esp
  8020ea:	85 c0                	test   %eax,%eax
  8020ec:	0f 88 bc 00 00 00    	js     8021ae <pipe+0x135>
	va = fd2data(fd0);
  8020f2:	83 ec 0c             	sub    $0xc,%esp
  8020f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8020f8:	e8 59 ef ff ff       	call   801056 <fd2data>
  8020fd:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  8020ff:	83 c4 0c             	add    $0xc,%esp
  802102:	68 07 04 00 00       	push   $0x407
  802107:	50                   	push   %eax
  802108:	6a 00                	push   $0x0
  80210a:	e8 f6 ed ff ff       	call   800f05 <sys_page_alloc>
  80210f:	89 c3                	mov    %eax,%ebx
  802111:	83 c4 10             	add    $0x10,%esp
  802114:	85 c0                	test   %eax,%eax
  802116:	0f 88 82 00 00 00    	js     80219e <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80211c:	83 ec 0c             	sub    $0xc,%esp
  80211f:	ff 75 f0             	pushl  -0x10(%ebp)
  802122:	e8 2f ef ff ff       	call   801056 <fd2data>
  802127:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80212e:	50                   	push   %eax
  80212f:	6a 00                	push   $0x0
  802131:	56                   	push   %esi
  802132:	6a 00                	push   $0x0
  802134:	e8 f4 ed ff ff       	call   800f2d <sys_page_map>
  802139:	89 c3                	mov    %eax,%ebx
  80213b:	83 c4 20             	add    $0x20,%esp
  80213e:	85 c0                	test   %eax,%eax
  802140:	78 4e                	js     802190 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  802142:	a1 ac 47 80 00       	mov    0x8047ac,%eax
  802147:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80214a:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80214c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80214f:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  802156:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802159:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80215b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80215e:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  802165:	83 ec 0c             	sub    $0xc,%esp
  802168:	ff 75 f4             	pushl  -0xc(%ebp)
  80216b:	e8 d2 ee ff ff       	call   801042 <fd2num>
  802170:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802173:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  802175:	83 c4 04             	add    $0x4,%esp
  802178:	ff 75 f0             	pushl  -0x10(%ebp)
  80217b:	e8 c2 ee ff ff       	call   801042 <fd2num>
  802180:	8b 4d 08             	mov    0x8(%ebp),%ecx
  802183:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  802186:	83 c4 10             	add    $0x10,%esp
  802189:	bb 00 00 00 00       	mov    $0x0,%ebx
  80218e:	eb 2e                	jmp    8021be <pipe+0x145>
	sys_page_unmap(0, va);
  802190:	83 ec 08             	sub    $0x8,%esp
  802193:	56                   	push   %esi
  802194:	6a 00                	push   $0x0
  802196:	e8 bc ed ff ff       	call   800f57 <sys_page_unmap>
  80219b:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  80219e:	83 ec 08             	sub    $0x8,%esp
  8021a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8021a4:	6a 00                	push   $0x0
  8021a6:	e8 ac ed ff ff       	call   800f57 <sys_page_unmap>
  8021ab:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8021ae:	83 ec 08             	sub    $0x8,%esp
  8021b1:	ff 75 f4             	pushl  -0xc(%ebp)
  8021b4:	6a 00                	push   $0x0
  8021b6:	e8 9c ed ff ff       	call   800f57 <sys_page_unmap>
  8021bb:	83 c4 10             	add    $0x10,%esp
}
  8021be:	89 d8                	mov    %ebx,%eax
  8021c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8021c3:	5b                   	pop    %ebx
  8021c4:	5e                   	pop    %esi
  8021c5:	5d                   	pop    %ebp
  8021c6:	c3                   	ret    

008021c7 <pipeisclosed>:
{
  8021c7:	f3 0f 1e fb          	endbr32 
  8021cb:	55                   	push   %ebp
  8021cc:	89 e5                	mov    %esp,%ebp
  8021ce:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8021d1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8021d4:	50                   	push   %eax
  8021d5:	ff 75 08             	pushl  0x8(%ebp)
  8021d8:	e8 ee ee ff ff       	call   8010cb <fd_lookup>
  8021dd:	83 c4 10             	add    $0x10,%esp
  8021e0:	85 c0                	test   %eax,%eax
  8021e2:	78 18                	js     8021fc <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  8021e4:	83 ec 0c             	sub    $0xc,%esp
  8021e7:	ff 75 f4             	pushl  -0xc(%ebp)
  8021ea:	e8 67 ee ff ff       	call   801056 <fd2data>
  8021ef:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  8021f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8021f4:	e8 1f fd ff ff       	call   801f18 <_pipeisclosed>
  8021f9:	83 c4 10             	add    $0x10,%esp
}
  8021fc:	c9                   	leave  
  8021fd:	c3                   	ret    

008021fe <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  8021fe:	f3 0f 1e fb          	endbr32 
  802202:	55                   	push   %ebp
  802203:	89 e5                	mov    %esp,%ebp
  802205:	56                   	push   %esi
  802206:	53                   	push   %ebx
  802207:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80220a:	85 f6                	test   %esi,%esi
  80220c:	74 13                	je     802221 <wait+0x23>
	e = &envs[ENVX(envid)];
  80220e:	89 f3                	mov    %esi,%ebx
  802210:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  802216:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  802219:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  80221f:	eb 1b                	jmp    80223c <wait+0x3e>
	assert(envid != 0);
  802221:	68 5d 2c 80 00       	push   $0x802c5d
  802226:	68 5f 2b 80 00       	push   $0x802b5f
  80222b:	6a 09                	push   $0x9
  80222d:	68 68 2c 80 00       	push   $0x802c68
  802232:	e8 f5 e1 ff ff       	call   80042c <_panic>
		sys_yield();
  802237:	e8 9e ec ff ff       	call   800eda <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80223c:	8b 43 48             	mov    0x48(%ebx),%eax
  80223f:	39 f0                	cmp    %esi,%eax
  802241:	75 07                	jne    80224a <wait+0x4c>
  802243:	8b 43 54             	mov    0x54(%ebx),%eax
  802246:	85 c0                	test   %eax,%eax
  802248:	75 ed                	jne    802237 <wait+0x39>
}
  80224a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80224d:	5b                   	pop    %ebx
  80224e:	5e                   	pop    %esi
  80224f:	5d                   	pop    %ebp
  802250:	c3                   	ret    

00802251 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  802251:	f3 0f 1e fb          	endbr32 
  802255:	55                   	push   %ebp
  802256:	89 e5                	mov    %esp,%ebp
  802258:	56                   	push   %esi
  802259:	53                   	push   %ebx
  80225a:	8b 75 08             	mov    0x8(%ebp),%esi
  80225d:	8b 45 0c             	mov    0xc(%ebp),%eax
  802260:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  802263:	85 c0                	test   %eax,%eax
  802265:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  80226a:	0f 44 c2             	cmove  %edx,%eax
  80226d:	83 ec 0c             	sub    $0xc,%esp
  802270:	50                   	push   %eax
  802271:	e8 a6 ed ff ff       	call   80101c <sys_ipc_recv>

	if (from_env_store != NULL)
  802276:	83 c4 10             	add    $0x10,%esp
  802279:	85 f6                	test   %esi,%esi
  80227b:	74 15                	je     802292 <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  80227d:	ba 00 00 00 00       	mov    $0x0,%edx
  802282:	83 f8 fd             	cmp    $0xfffffffd,%eax
  802285:	74 09                	je     802290 <ipc_recv+0x3f>
  802287:	8b 15 90 67 80 00    	mov    0x806790,%edx
  80228d:	8b 52 74             	mov    0x74(%edx),%edx
  802290:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  802292:	85 db                	test   %ebx,%ebx
  802294:	74 15                	je     8022ab <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  802296:	ba 00 00 00 00       	mov    $0x0,%edx
  80229b:	83 f8 fd             	cmp    $0xfffffffd,%eax
  80229e:	74 09                	je     8022a9 <ipc_recv+0x58>
  8022a0:	8b 15 90 67 80 00    	mov    0x806790,%edx
  8022a6:	8b 52 78             	mov    0x78(%edx),%edx
  8022a9:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  8022ab:	83 f8 fd             	cmp    $0xfffffffd,%eax
  8022ae:	74 08                	je     8022b8 <ipc_recv+0x67>
  8022b0:	a1 90 67 80 00       	mov    0x806790,%eax
  8022b5:	8b 40 70             	mov    0x70(%eax),%eax
}
  8022b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8022bb:	5b                   	pop    %ebx
  8022bc:	5e                   	pop    %esi
  8022bd:	5d                   	pop    %ebp
  8022be:	c3                   	ret    

008022bf <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  8022bf:	f3 0f 1e fb          	endbr32 
  8022c3:	55                   	push   %ebp
  8022c4:	89 e5                	mov    %esp,%ebp
  8022c6:	57                   	push   %edi
  8022c7:	56                   	push   %esi
  8022c8:	53                   	push   %ebx
  8022c9:	83 ec 0c             	sub    $0xc,%esp
  8022cc:	8b 7d 08             	mov    0x8(%ebp),%edi
  8022cf:	8b 75 0c             	mov    0xc(%ebp),%esi
  8022d2:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8022d5:	eb 1f                	jmp    8022f6 <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  8022d7:	6a 00                	push   $0x0
  8022d9:	68 00 00 c0 ee       	push   $0xeec00000
  8022de:	56                   	push   %esi
  8022df:	57                   	push   %edi
  8022e0:	e8 0e ed ff ff       	call   800ff3 <sys_ipc_try_send>
  8022e5:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  8022e8:	85 c0                	test   %eax,%eax
  8022ea:	74 30                	je     80231c <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  8022ec:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8022ef:	75 19                	jne    80230a <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  8022f1:	e8 e4 eb ff ff       	call   800eda <sys_yield>
		if (pg != NULL) {
  8022f6:	85 db                	test   %ebx,%ebx
  8022f8:	74 dd                	je     8022d7 <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  8022fa:	ff 75 14             	pushl  0x14(%ebp)
  8022fd:	53                   	push   %ebx
  8022fe:	56                   	push   %esi
  8022ff:	57                   	push   %edi
  802300:	e8 ee ec ff ff       	call   800ff3 <sys_ipc_try_send>
  802305:	83 c4 10             	add    $0x10,%esp
  802308:	eb de                	jmp    8022e8 <ipc_send+0x29>
			panic("ipc_send: %d", res);
  80230a:	50                   	push   %eax
  80230b:	68 73 2c 80 00       	push   $0x802c73
  802310:	6a 3e                	push   $0x3e
  802312:	68 80 2c 80 00       	push   $0x802c80
  802317:	e8 10 e1 ff ff       	call   80042c <_panic>
	}
}
  80231c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80231f:	5b                   	pop    %ebx
  802320:	5e                   	pop    %esi
  802321:	5f                   	pop    %edi
  802322:	5d                   	pop    %ebp
  802323:	c3                   	ret    

00802324 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  802324:	f3 0f 1e fb          	endbr32 
  802328:	55                   	push   %ebp
  802329:	89 e5                	mov    %esp,%ebp
  80232b:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  80232e:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  802333:	6b d0 7c             	imul   $0x7c,%eax,%edx
  802336:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  80233c:	8b 52 50             	mov    0x50(%edx),%edx
  80233f:	39 ca                	cmp    %ecx,%edx
  802341:	74 11                	je     802354 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  802343:	83 c0 01             	add    $0x1,%eax
  802346:	3d 00 04 00 00       	cmp    $0x400,%eax
  80234b:	75 e6                	jne    802333 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  80234d:	b8 00 00 00 00       	mov    $0x0,%eax
  802352:	eb 0b                	jmp    80235f <ipc_find_env+0x3b>
			return envs[i].env_id;
  802354:	6b c0 7c             	imul   $0x7c,%eax,%eax
  802357:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80235c:	8b 40 48             	mov    0x48(%eax),%eax
}
  80235f:	5d                   	pop    %ebp
  802360:	c3                   	ret    

00802361 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802361:	f3 0f 1e fb          	endbr32 
  802365:	55                   	push   %ebp
  802366:	89 e5                	mov    %esp,%ebp
  802368:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80236b:	89 c2                	mov    %eax,%edx
  80236d:	c1 ea 16             	shr    $0x16,%edx
  802370:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  802377:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80237c:	f6 c1 01             	test   $0x1,%cl
  80237f:	74 1c                	je     80239d <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802381:	c1 e8 0c             	shr    $0xc,%eax
  802384:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80238b:	a8 01                	test   $0x1,%al
  80238d:	74 0e                	je     80239d <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  80238f:	c1 e8 0c             	shr    $0xc,%eax
  802392:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  802399:	ef 
  80239a:	0f b7 d2             	movzwl %dx,%edx
}
  80239d:	89 d0                	mov    %edx,%eax
  80239f:	5d                   	pop    %ebp
  8023a0:	c3                   	ret    
  8023a1:	66 90                	xchg   %ax,%ax
  8023a3:	66 90                	xchg   %ax,%ax
  8023a5:	66 90                	xchg   %ax,%ax
  8023a7:	66 90                	xchg   %ax,%ax
  8023a9:	66 90                	xchg   %ax,%ax
  8023ab:	66 90                	xchg   %ax,%ax
  8023ad:	66 90                	xchg   %ax,%ax
  8023af:	90                   	nop

008023b0 <__udivdi3>:
  8023b0:	f3 0f 1e fb          	endbr32 
  8023b4:	55                   	push   %ebp
  8023b5:	57                   	push   %edi
  8023b6:	56                   	push   %esi
  8023b7:	53                   	push   %ebx
  8023b8:	83 ec 1c             	sub    $0x1c,%esp
  8023bb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8023bf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8023c3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8023c7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8023cb:	85 d2                	test   %edx,%edx
  8023cd:	75 19                	jne    8023e8 <__udivdi3+0x38>
  8023cf:	39 f3                	cmp    %esi,%ebx
  8023d1:	76 4d                	jbe    802420 <__udivdi3+0x70>
  8023d3:	31 ff                	xor    %edi,%edi
  8023d5:	89 e8                	mov    %ebp,%eax
  8023d7:	89 f2                	mov    %esi,%edx
  8023d9:	f7 f3                	div    %ebx
  8023db:	89 fa                	mov    %edi,%edx
  8023dd:	83 c4 1c             	add    $0x1c,%esp
  8023e0:	5b                   	pop    %ebx
  8023e1:	5e                   	pop    %esi
  8023e2:	5f                   	pop    %edi
  8023e3:	5d                   	pop    %ebp
  8023e4:	c3                   	ret    
  8023e5:	8d 76 00             	lea    0x0(%esi),%esi
  8023e8:	39 f2                	cmp    %esi,%edx
  8023ea:	76 14                	jbe    802400 <__udivdi3+0x50>
  8023ec:	31 ff                	xor    %edi,%edi
  8023ee:	31 c0                	xor    %eax,%eax
  8023f0:	89 fa                	mov    %edi,%edx
  8023f2:	83 c4 1c             	add    $0x1c,%esp
  8023f5:	5b                   	pop    %ebx
  8023f6:	5e                   	pop    %esi
  8023f7:	5f                   	pop    %edi
  8023f8:	5d                   	pop    %ebp
  8023f9:	c3                   	ret    
  8023fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802400:	0f bd fa             	bsr    %edx,%edi
  802403:	83 f7 1f             	xor    $0x1f,%edi
  802406:	75 48                	jne    802450 <__udivdi3+0xa0>
  802408:	39 f2                	cmp    %esi,%edx
  80240a:	72 06                	jb     802412 <__udivdi3+0x62>
  80240c:	31 c0                	xor    %eax,%eax
  80240e:	39 eb                	cmp    %ebp,%ebx
  802410:	77 de                	ja     8023f0 <__udivdi3+0x40>
  802412:	b8 01 00 00 00       	mov    $0x1,%eax
  802417:	eb d7                	jmp    8023f0 <__udivdi3+0x40>
  802419:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802420:	89 d9                	mov    %ebx,%ecx
  802422:	85 db                	test   %ebx,%ebx
  802424:	75 0b                	jne    802431 <__udivdi3+0x81>
  802426:	b8 01 00 00 00       	mov    $0x1,%eax
  80242b:	31 d2                	xor    %edx,%edx
  80242d:	f7 f3                	div    %ebx
  80242f:	89 c1                	mov    %eax,%ecx
  802431:	31 d2                	xor    %edx,%edx
  802433:	89 f0                	mov    %esi,%eax
  802435:	f7 f1                	div    %ecx
  802437:	89 c6                	mov    %eax,%esi
  802439:	89 e8                	mov    %ebp,%eax
  80243b:	89 f7                	mov    %esi,%edi
  80243d:	f7 f1                	div    %ecx
  80243f:	89 fa                	mov    %edi,%edx
  802441:	83 c4 1c             	add    $0x1c,%esp
  802444:	5b                   	pop    %ebx
  802445:	5e                   	pop    %esi
  802446:	5f                   	pop    %edi
  802447:	5d                   	pop    %ebp
  802448:	c3                   	ret    
  802449:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802450:	89 f9                	mov    %edi,%ecx
  802452:	b8 20 00 00 00       	mov    $0x20,%eax
  802457:	29 f8                	sub    %edi,%eax
  802459:	d3 e2                	shl    %cl,%edx
  80245b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80245f:	89 c1                	mov    %eax,%ecx
  802461:	89 da                	mov    %ebx,%edx
  802463:	d3 ea                	shr    %cl,%edx
  802465:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802469:	09 d1                	or     %edx,%ecx
  80246b:	89 f2                	mov    %esi,%edx
  80246d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802471:	89 f9                	mov    %edi,%ecx
  802473:	d3 e3                	shl    %cl,%ebx
  802475:	89 c1                	mov    %eax,%ecx
  802477:	d3 ea                	shr    %cl,%edx
  802479:	89 f9                	mov    %edi,%ecx
  80247b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80247f:	89 eb                	mov    %ebp,%ebx
  802481:	d3 e6                	shl    %cl,%esi
  802483:	89 c1                	mov    %eax,%ecx
  802485:	d3 eb                	shr    %cl,%ebx
  802487:	09 de                	or     %ebx,%esi
  802489:	89 f0                	mov    %esi,%eax
  80248b:	f7 74 24 08          	divl   0x8(%esp)
  80248f:	89 d6                	mov    %edx,%esi
  802491:	89 c3                	mov    %eax,%ebx
  802493:	f7 64 24 0c          	mull   0xc(%esp)
  802497:	39 d6                	cmp    %edx,%esi
  802499:	72 15                	jb     8024b0 <__udivdi3+0x100>
  80249b:	89 f9                	mov    %edi,%ecx
  80249d:	d3 e5                	shl    %cl,%ebp
  80249f:	39 c5                	cmp    %eax,%ebp
  8024a1:	73 04                	jae    8024a7 <__udivdi3+0xf7>
  8024a3:	39 d6                	cmp    %edx,%esi
  8024a5:	74 09                	je     8024b0 <__udivdi3+0x100>
  8024a7:	89 d8                	mov    %ebx,%eax
  8024a9:	31 ff                	xor    %edi,%edi
  8024ab:	e9 40 ff ff ff       	jmp    8023f0 <__udivdi3+0x40>
  8024b0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8024b3:	31 ff                	xor    %edi,%edi
  8024b5:	e9 36 ff ff ff       	jmp    8023f0 <__udivdi3+0x40>
  8024ba:	66 90                	xchg   %ax,%ax
  8024bc:	66 90                	xchg   %ax,%ax
  8024be:	66 90                	xchg   %ax,%ax

008024c0 <__umoddi3>:
  8024c0:	f3 0f 1e fb          	endbr32 
  8024c4:	55                   	push   %ebp
  8024c5:	57                   	push   %edi
  8024c6:	56                   	push   %esi
  8024c7:	53                   	push   %ebx
  8024c8:	83 ec 1c             	sub    $0x1c,%esp
  8024cb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8024cf:	8b 74 24 30          	mov    0x30(%esp),%esi
  8024d3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8024d7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8024db:	85 c0                	test   %eax,%eax
  8024dd:	75 19                	jne    8024f8 <__umoddi3+0x38>
  8024df:	39 df                	cmp    %ebx,%edi
  8024e1:	76 5d                	jbe    802540 <__umoddi3+0x80>
  8024e3:	89 f0                	mov    %esi,%eax
  8024e5:	89 da                	mov    %ebx,%edx
  8024e7:	f7 f7                	div    %edi
  8024e9:	89 d0                	mov    %edx,%eax
  8024eb:	31 d2                	xor    %edx,%edx
  8024ed:	83 c4 1c             	add    $0x1c,%esp
  8024f0:	5b                   	pop    %ebx
  8024f1:	5e                   	pop    %esi
  8024f2:	5f                   	pop    %edi
  8024f3:	5d                   	pop    %ebp
  8024f4:	c3                   	ret    
  8024f5:	8d 76 00             	lea    0x0(%esi),%esi
  8024f8:	89 f2                	mov    %esi,%edx
  8024fa:	39 d8                	cmp    %ebx,%eax
  8024fc:	76 12                	jbe    802510 <__umoddi3+0x50>
  8024fe:	89 f0                	mov    %esi,%eax
  802500:	89 da                	mov    %ebx,%edx
  802502:	83 c4 1c             	add    $0x1c,%esp
  802505:	5b                   	pop    %ebx
  802506:	5e                   	pop    %esi
  802507:	5f                   	pop    %edi
  802508:	5d                   	pop    %ebp
  802509:	c3                   	ret    
  80250a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802510:	0f bd e8             	bsr    %eax,%ebp
  802513:	83 f5 1f             	xor    $0x1f,%ebp
  802516:	75 50                	jne    802568 <__umoddi3+0xa8>
  802518:	39 d8                	cmp    %ebx,%eax
  80251a:	0f 82 e0 00 00 00    	jb     802600 <__umoddi3+0x140>
  802520:	89 d9                	mov    %ebx,%ecx
  802522:	39 f7                	cmp    %esi,%edi
  802524:	0f 86 d6 00 00 00    	jbe    802600 <__umoddi3+0x140>
  80252a:	89 d0                	mov    %edx,%eax
  80252c:	89 ca                	mov    %ecx,%edx
  80252e:	83 c4 1c             	add    $0x1c,%esp
  802531:	5b                   	pop    %ebx
  802532:	5e                   	pop    %esi
  802533:	5f                   	pop    %edi
  802534:	5d                   	pop    %ebp
  802535:	c3                   	ret    
  802536:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80253d:	8d 76 00             	lea    0x0(%esi),%esi
  802540:	89 fd                	mov    %edi,%ebp
  802542:	85 ff                	test   %edi,%edi
  802544:	75 0b                	jne    802551 <__umoddi3+0x91>
  802546:	b8 01 00 00 00       	mov    $0x1,%eax
  80254b:	31 d2                	xor    %edx,%edx
  80254d:	f7 f7                	div    %edi
  80254f:	89 c5                	mov    %eax,%ebp
  802551:	89 d8                	mov    %ebx,%eax
  802553:	31 d2                	xor    %edx,%edx
  802555:	f7 f5                	div    %ebp
  802557:	89 f0                	mov    %esi,%eax
  802559:	f7 f5                	div    %ebp
  80255b:	89 d0                	mov    %edx,%eax
  80255d:	31 d2                	xor    %edx,%edx
  80255f:	eb 8c                	jmp    8024ed <__umoddi3+0x2d>
  802561:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802568:	89 e9                	mov    %ebp,%ecx
  80256a:	ba 20 00 00 00       	mov    $0x20,%edx
  80256f:	29 ea                	sub    %ebp,%edx
  802571:	d3 e0                	shl    %cl,%eax
  802573:	89 44 24 08          	mov    %eax,0x8(%esp)
  802577:	89 d1                	mov    %edx,%ecx
  802579:	89 f8                	mov    %edi,%eax
  80257b:	d3 e8                	shr    %cl,%eax
  80257d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802581:	89 54 24 04          	mov    %edx,0x4(%esp)
  802585:	8b 54 24 04          	mov    0x4(%esp),%edx
  802589:	09 c1                	or     %eax,%ecx
  80258b:	89 d8                	mov    %ebx,%eax
  80258d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802591:	89 e9                	mov    %ebp,%ecx
  802593:	d3 e7                	shl    %cl,%edi
  802595:	89 d1                	mov    %edx,%ecx
  802597:	d3 e8                	shr    %cl,%eax
  802599:	89 e9                	mov    %ebp,%ecx
  80259b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80259f:	d3 e3                	shl    %cl,%ebx
  8025a1:	89 c7                	mov    %eax,%edi
  8025a3:	89 d1                	mov    %edx,%ecx
  8025a5:	89 f0                	mov    %esi,%eax
  8025a7:	d3 e8                	shr    %cl,%eax
  8025a9:	89 e9                	mov    %ebp,%ecx
  8025ab:	89 fa                	mov    %edi,%edx
  8025ad:	d3 e6                	shl    %cl,%esi
  8025af:	09 d8                	or     %ebx,%eax
  8025b1:	f7 74 24 08          	divl   0x8(%esp)
  8025b5:	89 d1                	mov    %edx,%ecx
  8025b7:	89 f3                	mov    %esi,%ebx
  8025b9:	f7 64 24 0c          	mull   0xc(%esp)
  8025bd:	89 c6                	mov    %eax,%esi
  8025bf:	89 d7                	mov    %edx,%edi
  8025c1:	39 d1                	cmp    %edx,%ecx
  8025c3:	72 06                	jb     8025cb <__umoddi3+0x10b>
  8025c5:	75 10                	jne    8025d7 <__umoddi3+0x117>
  8025c7:	39 c3                	cmp    %eax,%ebx
  8025c9:	73 0c                	jae    8025d7 <__umoddi3+0x117>
  8025cb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8025cf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8025d3:	89 d7                	mov    %edx,%edi
  8025d5:	89 c6                	mov    %eax,%esi
  8025d7:	89 ca                	mov    %ecx,%edx
  8025d9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8025de:	29 f3                	sub    %esi,%ebx
  8025e0:	19 fa                	sbb    %edi,%edx
  8025e2:	89 d0                	mov    %edx,%eax
  8025e4:	d3 e0                	shl    %cl,%eax
  8025e6:	89 e9                	mov    %ebp,%ecx
  8025e8:	d3 eb                	shr    %cl,%ebx
  8025ea:	d3 ea                	shr    %cl,%edx
  8025ec:	09 d8                	or     %ebx,%eax
  8025ee:	83 c4 1c             	add    $0x1c,%esp
  8025f1:	5b                   	pop    %ebx
  8025f2:	5e                   	pop    %esi
  8025f3:	5f                   	pop    %edi
  8025f4:	5d                   	pop    %ebp
  8025f5:	c3                   	ret    
  8025f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8025fd:	8d 76 00             	lea    0x0(%esi),%esi
  802600:	29 fe                	sub    %edi,%esi
  802602:	19 c3                	sbb    %eax,%ebx
  802604:	89 f2                	mov    %esi,%edx
  802606:	89 d9                	mov    %ebx,%ecx
  802608:	e9 1d ff ff ff       	jmp    80252a <__umoddi3+0x6a>
