
obj/user/testkbd.debug:     formato del fichero elf32-i386


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
  80002c:	e8 4d 02 00 00       	call   80027e <libmain>
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
  80003a:	53                   	push   %ebx
  80003b:	83 ec 04             	sub    $0x4,%esp
  80003e:	bb 0a 00 00 00       	mov    $0xa,%ebx
	int i, r;

	// Spin for a bit to let the console quiet
	for (i = 0; i < 10; ++i)
		sys_yield();
  800043:	e8 44 0e 00 00       	call   800e8c <sys_yield>
	for (i = 0; i < 10; ++i)
  800048:	83 eb 01             	sub    $0x1,%ebx
  80004b:	75 f6                	jne    800043 <umain+0x10>

	close(0);
  80004d:	83 ec 0c             	sub    $0xc,%esp
  800050:	6a 00                	push   $0x0
  800052:	e8 5f 11 00 00       	call   8011b6 <close>
	if ((r = opencons()) < 0)
  800057:	e8 cc 01 00 00       	call   800228 <opencons>
  80005c:	83 c4 10             	add    $0x10,%esp
  80005f:	85 c0                	test   %eax,%eax
  800061:	78 14                	js     800077 <umain+0x44>
		panic("opencons: %e", r);
	if (r != 0)
  800063:	74 24                	je     800089 <umain+0x56>
		panic("first opencons used fd %d", r);
  800065:	50                   	push   %eax
  800066:	68 9c 20 80 00       	push   $0x80209c
  80006b:	6a 11                	push   $0x11
  80006d:	68 8d 20 80 00       	push   $0x80208d
  800072:	e8 73 02 00 00       	call   8002ea <_panic>
		panic("opencons: %e", r);
  800077:	50                   	push   %eax
  800078:	68 80 20 80 00       	push   $0x802080
  80007d:	6a 0f                	push   $0xf
  80007f:	68 8d 20 80 00       	push   $0x80208d
  800084:	e8 61 02 00 00       	call   8002ea <_panic>
	if ((r = dup(0, 1)) < 0)
  800089:	83 ec 08             	sub    $0x8,%esp
  80008c:	6a 01                	push   $0x1
  80008e:	6a 00                	push   $0x0
  800090:	e8 7b 11 00 00       	call   801210 <dup>
  800095:	83 c4 10             	add    $0x10,%esp
  800098:	85 c0                	test   %eax,%eax
  80009a:	79 25                	jns    8000c1 <umain+0x8e>
		panic("dup: %e", r);
  80009c:	50                   	push   %eax
  80009d:	68 b6 20 80 00       	push   $0x8020b6
  8000a2:	6a 13                	push   $0x13
  8000a4:	68 8d 20 80 00       	push   $0x80208d
  8000a9:	e8 3c 02 00 00       	call   8002ea <_panic>
	for(;;){
		char *buf;

		buf = readline("Type a line: ");
		if (buf != NULL)
			fprintf(1, "%s\n", buf);
  8000ae:	83 ec 04             	sub    $0x4,%esp
  8000b1:	50                   	push   %eax
  8000b2:	68 cc 20 80 00       	push   $0x8020cc
  8000b7:	6a 01                	push   $0x1
  8000b9:	e8 73 18 00 00       	call   801931 <fprintf>
  8000be:	83 c4 10             	add    $0x10,%esp
		buf = readline("Type a line: ");
  8000c1:	83 ec 0c             	sub    $0xc,%esp
  8000c4:	68 be 20 80 00       	push   $0x8020be
  8000c9:	e8 2a 08 00 00       	call   8008f8 <readline>
		if (buf != NULL)
  8000ce:	83 c4 10             	add    $0x10,%esp
  8000d1:	85 c0                	test   %eax,%eax
  8000d3:	75 d9                	jne    8000ae <umain+0x7b>
		else
			fprintf(1, "(end of file received)\n");
  8000d5:	83 ec 08             	sub    $0x8,%esp
  8000d8:	68 d0 20 80 00       	push   $0x8020d0
  8000dd:	6a 01                	push   $0x1
  8000df:	e8 4d 18 00 00       	call   801931 <fprintf>
  8000e4:	83 c4 10             	add    $0x10,%esp
  8000e7:	eb d8                	jmp    8000c1 <umain+0x8e>

008000e9 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  8000e9:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  8000ed:	b8 00 00 00 00       	mov    $0x0,%eax
  8000f2:	c3                   	ret    

008000f3 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  8000f3:	f3 0f 1e fb          	endbr32 
  8000f7:	55                   	push   %ebp
  8000f8:	89 e5                	mov    %esp,%ebp
  8000fa:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  8000fd:	68 e8 20 80 00       	push   $0x8020e8
  800102:	ff 75 0c             	pushl  0xc(%ebp)
  800105:	e8 25 09 00 00       	call   800a2f <strcpy>
	return 0;
}
  80010a:	b8 00 00 00 00       	mov    $0x0,%eax
  80010f:	c9                   	leave  
  800110:	c3                   	ret    

00800111 <devcons_write>:
{
  800111:	f3 0f 1e fb          	endbr32 
  800115:	55                   	push   %ebp
  800116:	89 e5                	mov    %esp,%ebp
  800118:	57                   	push   %edi
  800119:	56                   	push   %esi
  80011a:	53                   	push   %ebx
  80011b:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800121:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800126:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  80012c:	3b 75 10             	cmp    0x10(%ebp),%esi
  80012f:	73 31                	jae    800162 <devcons_write+0x51>
		m = n - tot;
  800131:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800134:	29 f3                	sub    %esi,%ebx
  800136:	83 fb 7f             	cmp    $0x7f,%ebx
  800139:	b8 7f 00 00 00       	mov    $0x7f,%eax
  80013e:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800141:	83 ec 04             	sub    $0x4,%esp
  800144:	53                   	push   %ebx
  800145:	89 f0                	mov    %esi,%eax
  800147:	03 45 0c             	add    0xc(%ebp),%eax
  80014a:	50                   	push   %eax
  80014b:	57                   	push   %edi
  80014c:	e8 96 0a 00 00       	call   800be7 <memmove>
		sys_cputs(buf, m);
  800151:	83 c4 08             	add    $0x8,%esp
  800154:	53                   	push   %ebx
  800155:	57                   	push   %edi
  800156:	e8 91 0c 00 00       	call   800dec <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  80015b:	01 de                	add    %ebx,%esi
  80015d:	83 c4 10             	add    $0x10,%esp
  800160:	eb ca                	jmp    80012c <devcons_write+0x1b>
}
  800162:	89 f0                	mov    %esi,%eax
  800164:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800167:	5b                   	pop    %ebx
  800168:	5e                   	pop    %esi
  800169:	5f                   	pop    %edi
  80016a:	5d                   	pop    %ebp
  80016b:	c3                   	ret    

0080016c <devcons_read>:
{
  80016c:	f3 0f 1e fb          	endbr32 
  800170:	55                   	push   %ebp
  800171:	89 e5                	mov    %esp,%ebp
  800173:	83 ec 08             	sub    $0x8,%esp
  800176:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  80017b:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  80017f:	74 21                	je     8001a2 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800181:	e8 90 0c 00 00       	call   800e16 <sys_cgetc>
  800186:	85 c0                	test   %eax,%eax
  800188:	75 07                	jne    800191 <devcons_read+0x25>
		sys_yield();
  80018a:	e8 fd 0c 00 00       	call   800e8c <sys_yield>
  80018f:	eb f0                	jmp    800181 <devcons_read+0x15>
	if (c < 0)
  800191:	78 0f                	js     8001a2 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800193:	83 f8 04             	cmp    $0x4,%eax
  800196:	74 0c                	je     8001a4 <devcons_read+0x38>
	*(char*)vbuf = c;
  800198:	8b 55 0c             	mov    0xc(%ebp),%edx
  80019b:	88 02                	mov    %al,(%edx)
	return 1;
  80019d:	b8 01 00 00 00       	mov    $0x1,%eax
}
  8001a2:	c9                   	leave  
  8001a3:	c3                   	ret    
		return 0;
  8001a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8001a9:	eb f7                	jmp    8001a2 <devcons_read+0x36>

008001ab <cputchar>:
{
  8001ab:	f3 0f 1e fb          	endbr32 
  8001af:	55                   	push   %ebp
  8001b0:	89 e5                	mov    %esp,%ebp
  8001b2:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  8001b5:	8b 45 08             	mov    0x8(%ebp),%eax
  8001b8:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8001bb:	6a 01                	push   $0x1
  8001bd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001c0:	50                   	push   %eax
  8001c1:	e8 26 0c 00 00       	call   800dec <sys_cputs>
}
  8001c6:	83 c4 10             	add    $0x10,%esp
  8001c9:	c9                   	leave  
  8001ca:	c3                   	ret    

008001cb <getchar>:
{
  8001cb:	f3 0f 1e fb          	endbr32 
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8001d5:	6a 01                	push   $0x1
  8001d7:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8001da:	50                   	push   %eax
  8001db:	6a 00                	push   $0x0
  8001dd:	e8 1e 11 00 00       	call   801300 <read>
	if (r < 0)
  8001e2:	83 c4 10             	add    $0x10,%esp
  8001e5:	85 c0                	test   %eax,%eax
  8001e7:	78 06                	js     8001ef <getchar+0x24>
	if (r < 1)
  8001e9:	74 06                	je     8001f1 <getchar+0x26>
	return c;
  8001eb:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8001ef:	c9                   	leave  
  8001f0:	c3                   	ret    
		return -E_EOF;
  8001f1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8001f6:	eb f7                	jmp    8001ef <getchar+0x24>

008001f8 <iscons>:
{
  8001f8:	f3 0f 1e fb          	endbr32 
  8001fc:	55                   	push   %ebp
  8001fd:	89 e5                	mov    %esp,%ebp
  8001ff:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800202:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800205:	50                   	push   %eax
  800206:	ff 75 08             	pushl  0x8(%ebp)
  800209:	e8 6f 0e 00 00       	call   80107d <fd_lookup>
  80020e:	83 c4 10             	add    $0x10,%esp
  800211:	85 c0                	test   %eax,%eax
  800213:	78 11                	js     800226 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  800215:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800218:	8b 15 00 30 80 00    	mov    0x803000,%edx
  80021e:	39 10                	cmp    %edx,(%eax)
  800220:	0f 94 c0             	sete   %al
  800223:	0f b6 c0             	movzbl %al,%eax
}
  800226:	c9                   	leave  
  800227:	c3                   	ret    

00800228 <opencons>:
{
  800228:	f3 0f 1e fb          	endbr32 
  80022c:	55                   	push   %ebp
  80022d:	89 e5                	mov    %esp,%ebp
  80022f:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800232:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800235:	50                   	push   %eax
  800236:	e8 ec 0d 00 00       	call   801027 <fd_alloc>
  80023b:	83 c4 10             	add    $0x10,%esp
  80023e:	85 c0                	test   %eax,%eax
  800240:	78 3a                	js     80027c <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800242:	83 ec 04             	sub    $0x4,%esp
  800245:	68 07 04 00 00       	push   $0x407
  80024a:	ff 75 f4             	pushl  -0xc(%ebp)
  80024d:	6a 00                	push   $0x0
  80024f:	e8 63 0c 00 00       	call   800eb7 <sys_page_alloc>
  800254:	83 c4 10             	add    $0x10,%esp
  800257:	85 c0                	test   %eax,%eax
  800259:	78 21                	js     80027c <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80025b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80025e:	8b 15 00 30 80 00    	mov    0x803000,%edx
  800264:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  800266:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800269:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800270:	83 ec 0c             	sub    $0xc,%esp
  800273:	50                   	push   %eax
  800274:	e8 7b 0d 00 00       	call   800ff4 <fd2num>
  800279:	83 c4 10             	add    $0x10,%esp
}
  80027c:	c9                   	leave  
  80027d:	c3                   	ret    

0080027e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80027e:	f3 0f 1e fb          	endbr32 
  800282:	55                   	push   %ebp
  800283:	89 e5                	mov    %esp,%ebp
  800285:	56                   	push   %esi
  800286:	53                   	push   %ebx
  800287:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80028a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  80028d:	e8 d2 0b 00 00       	call   800e64 <sys_getenvid>
	if (id >= 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	78 12                	js     8002a8 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800296:	25 ff 03 00 00       	and    $0x3ff,%eax
  80029b:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80029e:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8002a3:	a3 04 44 80 00       	mov    %eax,0x804404

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8002a8:	85 db                	test   %ebx,%ebx
  8002aa:	7e 07                	jle    8002b3 <libmain+0x35>
		binaryname = argv[0];
  8002ac:	8b 06                	mov    (%esi),%eax
  8002ae:	a3 1c 30 80 00       	mov    %eax,0x80301c

	// call user main routine
	umain(argc, argv);
  8002b3:	83 ec 08             	sub    $0x8,%esp
  8002b6:	56                   	push   %esi
  8002b7:	53                   	push   %ebx
  8002b8:	e8 76 fd ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8002bd:	e8 0a 00 00 00       	call   8002cc <exit>
}
  8002c2:	83 c4 10             	add    $0x10,%esp
  8002c5:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8002c8:	5b                   	pop    %ebx
  8002c9:	5e                   	pop    %esi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8002cc:	f3 0f 1e fb          	endbr32 
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8002d6:	e8 0c 0f 00 00       	call   8011e7 <close_all>
	sys_env_destroy(0);
  8002db:	83 ec 0c             	sub    $0xc,%esp
  8002de:	6a 00                	push   $0x0
  8002e0:	e8 59 0b 00 00       	call   800e3e <sys_env_destroy>
}
  8002e5:	83 c4 10             	add    $0x10,%esp
  8002e8:	c9                   	leave  
  8002e9:	c3                   	ret    

008002ea <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8002ea:	f3 0f 1e fb          	endbr32 
  8002ee:	55                   	push   %ebp
  8002ef:	89 e5                	mov    %esp,%ebp
  8002f1:	56                   	push   %esi
  8002f2:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8002f3:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  8002f6:	8b 35 1c 30 80 00    	mov    0x80301c,%esi
  8002fc:	e8 63 0b 00 00       	call   800e64 <sys_getenvid>
  800301:	83 ec 0c             	sub    $0xc,%esp
  800304:	ff 75 0c             	pushl  0xc(%ebp)
  800307:	ff 75 08             	pushl  0x8(%ebp)
  80030a:	56                   	push   %esi
  80030b:	50                   	push   %eax
  80030c:	68 00 21 80 00       	push   $0x802100
  800311:	e8 bb 00 00 00       	call   8003d1 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800316:	83 c4 18             	add    $0x18,%esp
  800319:	53                   	push   %ebx
  80031a:	ff 75 10             	pushl  0x10(%ebp)
  80031d:	e8 5a 00 00 00       	call   80037c <vcprintf>
	cprintf("\n");
  800322:	c7 04 24 e6 20 80 00 	movl   $0x8020e6,(%esp)
  800329:	e8 a3 00 00 00       	call   8003d1 <cprintf>
  80032e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800331:	cc                   	int3   
  800332:	eb fd                	jmp    800331 <_panic+0x47>

00800334 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800334:	f3 0f 1e fb          	endbr32 
  800338:	55                   	push   %ebp
  800339:	89 e5                	mov    %esp,%ebp
  80033b:	53                   	push   %ebx
  80033c:	83 ec 04             	sub    $0x4,%esp
  80033f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800342:	8b 13                	mov    (%ebx),%edx
  800344:	8d 42 01             	lea    0x1(%edx),%eax
  800347:	89 03                	mov    %eax,(%ebx)
  800349:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80034c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800350:	3d ff 00 00 00       	cmp    $0xff,%eax
  800355:	74 09                	je     800360 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800357:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  80035b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80035e:	c9                   	leave  
  80035f:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800360:	83 ec 08             	sub    $0x8,%esp
  800363:	68 ff 00 00 00       	push   $0xff
  800368:	8d 43 08             	lea    0x8(%ebx),%eax
  80036b:	50                   	push   %eax
  80036c:	e8 7b 0a 00 00       	call   800dec <sys_cputs>
		b->idx = 0;
  800371:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800377:	83 c4 10             	add    $0x10,%esp
  80037a:	eb db                	jmp    800357 <putch+0x23>

0080037c <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  80037c:	f3 0f 1e fb          	endbr32 
  800380:	55                   	push   %ebp
  800381:	89 e5                	mov    %esp,%ebp
  800383:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800389:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800390:	00 00 00 
	b.cnt = 0;
  800393:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80039a:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80039d:	ff 75 0c             	pushl  0xc(%ebp)
  8003a0:	ff 75 08             	pushl  0x8(%ebp)
  8003a3:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003a9:	50                   	push   %eax
  8003aa:	68 34 03 80 00       	push   $0x800334
  8003af:	e8 80 01 00 00       	call   800534 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003b4:	83 c4 08             	add    $0x8,%esp
  8003b7:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003bd:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003c3:	50                   	push   %eax
  8003c4:	e8 23 0a 00 00       	call   800dec <sys_cputs>

	return b.cnt;
}
  8003c9:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003cf:	c9                   	leave  
  8003d0:	c3                   	ret    

008003d1 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003d1:	f3 0f 1e fb          	endbr32 
  8003d5:	55                   	push   %ebp
  8003d6:	89 e5                	mov    %esp,%ebp
  8003d8:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003db:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003de:	50                   	push   %eax
  8003df:	ff 75 08             	pushl  0x8(%ebp)
  8003e2:	e8 95 ff ff ff       	call   80037c <vcprintf>
	va_end(ap);

	return cnt;
}
  8003e7:	c9                   	leave  
  8003e8:	c3                   	ret    

008003e9 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	57                   	push   %edi
  8003ed:	56                   	push   %esi
  8003ee:	53                   	push   %ebx
  8003ef:	83 ec 1c             	sub    $0x1c,%esp
  8003f2:	89 c7                	mov    %eax,%edi
  8003f4:	89 d6                	mov    %edx,%esi
  8003f6:	8b 45 08             	mov    0x8(%ebp),%eax
  8003f9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fc:	89 d1                	mov    %edx,%ecx
  8003fe:	89 c2                	mov    %eax,%edx
  800400:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800403:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800406:	8b 45 10             	mov    0x10(%ebp),%eax
  800409:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80040c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80040f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800416:	39 c2                	cmp    %eax,%edx
  800418:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  80041b:	72 3e                	jb     80045b <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80041d:	83 ec 0c             	sub    $0xc,%esp
  800420:	ff 75 18             	pushl  0x18(%ebp)
  800423:	83 eb 01             	sub    $0x1,%ebx
  800426:	53                   	push   %ebx
  800427:	50                   	push   %eax
  800428:	83 ec 08             	sub    $0x8,%esp
  80042b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80042e:	ff 75 e0             	pushl  -0x20(%ebp)
  800431:	ff 75 dc             	pushl  -0x24(%ebp)
  800434:	ff 75 d8             	pushl  -0x28(%ebp)
  800437:	e8 e4 19 00 00       	call   801e20 <__udivdi3>
  80043c:	83 c4 18             	add    $0x18,%esp
  80043f:	52                   	push   %edx
  800440:	50                   	push   %eax
  800441:	89 f2                	mov    %esi,%edx
  800443:	89 f8                	mov    %edi,%eax
  800445:	e8 9f ff ff ff       	call   8003e9 <printnum>
  80044a:	83 c4 20             	add    $0x20,%esp
  80044d:	eb 13                	jmp    800462 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80044f:	83 ec 08             	sub    $0x8,%esp
  800452:	56                   	push   %esi
  800453:	ff 75 18             	pushl  0x18(%ebp)
  800456:	ff d7                	call   *%edi
  800458:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  80045b:	83 eb 01             	sub    $0x1,%ebx
  80045e:	85 db                	test   %ebx,%ebx
  800460:	7f ed                	jg     80044f <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800462:	83 ec 08             	sub    $0x8,%esp
  800465:	56                   	push   %esi
  800466:	83 ec 04             	sub    $0x4,%esp
  800469:	ff 75 e4             	pushl  -0x1c(%ebp)
  80046c:	ff 75 e0             	pushl  -0x20(%ebp)
  80046f:	ff 75 dc             	pushl  -0x24(%ebp)
  800472:	ff 75 d8             	pushl  -0x28(%ebp)
  800475:	e8 b6 1a 00 00       	call   801f30 <__umoddi3>
  80047a:	83 c4 14             	add    $0x14,%esp
  80047d:	0f be 80 23 21 80 00 	movsbl 0x802123(%eax),%eax
  800484:	50                   	push   %eax
  800485:	ff d7                	call   *%edi
}
  800487:	83 c4 10             	add    $0x10,%esp
  80048a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80048d:	5b                   	pop    %ebx
  80048e:	5e                   	pop    %esi
  80048f:	5f                   	pop    %edi
  800490:	5d                   	pop    %ebp
  800491:	c3                   	ret    

00800492 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800492:	83 fa 01             	cmp    $0x1,%edx
  800495:	7f 13                	jg     8004aa <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800497:	85 d2                	test   %edx,%edx
  800499:	74 1c                	je     8004b7 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  80049b:	8b 10                	mov    (%eax),%edx
  80049d:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004a0:	89 08                	mov    %ecx,(%eax)
  8004a2:	8b 02                	mov    (%edx),%eax
  8004a4:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a9:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8004aa:	8b 10                	mov    (%eax),%edx
  8004ac:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004af:	89 08                	mov    %ecx,(%eax)
  8004b1:	8b 02                	mov    (%edx),%eax
  8004b3:	8b 52 04             	mov    0x4(%edx),%edx
  8004b6:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8004b7:	8b 10                	mov    (%eax),%edx
  8004b9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004bc:	89 08                	mov    %ecx,(%eax)
  8004be:	8b 02                	mov    (%edx),%eax
  8004c0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004c5:	c3                   	ret    

008004c6 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8004c6:	83 fa 01             	cmp    $0x1,%edx
  8004c9:	7f 0f                	jg     8004da <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8004cb:	85 d2                	test   %edx,%edx
  8004cd:	74 18                	je     8004e7 <getint+0x21>
		return va_arg(*ap, long);
  8004cf:	8b 10                	mov    (%eax),%edx
  8004d1:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004d4:	89 08                	mov    %ecx,(%eax)
  8004d6:	8b 02                	mov    (%edx),%eax
  8004d8:	99                   	cltd   
  8004d9:	c3                   	ret    
		return va_arg(*ap, long long);
  8004da:	8b 10                	mov    (%eax),%edx
  8004dc:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004df:	89 08                	mov    %ecx,(%eax)
  8004e1:	8b 02                	mov    (%edx),%eax
  8004e3:	8b 52 04             	mov    0x4(%edx),%edx
  8004e6:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8004e7:	8b 10                	mov    (%eax),%edx
  8004e9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004ec:	89 08                	mov    %ecx,(%eax)
  8004ee:	8b 02                	mov    (%edx),%eax
  8004f0:	99                   	cltd   
}
  8004f1:	c3                   	ret    

008004f2 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004f2:	f3 0f 1e fb          	endbr32 
  8004f6:	55                   	push   %ebp
  8004f7:	89 e5                	mov    %esp,%ebp
  8004f9:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004fc:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800500:	8b 10                	mov    (%eax),%edx
  800502:	3b 50 04             	cmp    0x4(%eax),%edx
  800505:	73 0a                	jae    800511 <sprintputch+0x1f>
		*b->buf++ = ch;
  800507:	8d 4a 01             	lea    0x1(%edx),%ecx
  80050a:	89 08                	mov    %ecx,(%eax)
  80050c:	8b 45 08             	mov    0x8(%ebp),%eax
  80050f:	88 02                	mov    %al,(%edx)
}
  800511:	5d                   	pop    %ebp
  800512:	c3                   	ret    

00800513 <printfmt>:
{
  800513:	f3 0f 1e fb          	endbr32 
  800517:	55                   	push   %ebp
  800518:	89 e5                	mov    %esp,%ebp
  80051a:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80051d:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800520:	50                   	push   %eax
  800521:	ff 75 10             	pushl  0x10(%ebp)
  800524:	ff 75 0c             	pushl  0xc(%ebp)
  800527:	ff 75 08             	pushl  0x8(%ebp)
  80052a:	e8 05 00 00 00       	call   800534 <vprintfmt>
}
  80052f:	83 c4 10             	add    $0x10,%esp
  800532:	c9                   	leave  
  800533:	c3                   	ret    

00800534 <vprintfmt>:
{
  800534:	f3 0f 1e fb          	endbr32 
  800538:	55                   	push   %ebp
  800539:	89 e5                	mov    %esp,%ebp
  80053b:	57                   	push   %edi
  80053c:	56                   	push   %esi
  80053d:	53                   	push   %ebx
  80053e:	83 ec 2c             	sub    $0x2c,%esp
  800541:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800544:	8b 75 0c             	mov    0xc(%ebp),%esi
  800547:	8b 7d 10             	mov    0x10(%ebp),%edi
  80054a:	e9 86 02 00 00       	jmp    8007d5 <vprintfmt+0x2a1>
		padc = ' ';
  80054f:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800553:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  80055a:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800561:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800568:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80056d:	8d 47 01             	lea    0x1(%edi),%eax
  800570:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800573:	0f b6 17             	movzbl (%edi),%edx
  800576:	8d 42 dd             	lea    -0x23(%edx),%eax
  800579:	3c 55                	cmp    $0x55,%al
  80057b:	0f 87 df 02 00 00    	ja     800860 <vprintfmt+0x32c>
  800581:	0f b6 c0             	movzbl %al,%eax
  800584:	3e ff 24 85 60 22 80 	notrack jmp *0x802260(,%eax,4)
  80058b:	00 
  80058c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80058f:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800593:	eb d8                	jmp    80056d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800595:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800598:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80059c:	eb cf                	jmp    80056d <vprintfmt+0x39>
  80059e:	0f b6 d2             	movzbl %dl,%edx
  8005a1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8005a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8005a9:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8005ac:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005af:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8005b3:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8005b6:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8005b9:	83 f9 09             	cmp    $0x9,%ecx
  8005bc:	77 52                	ja     800610 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  8005be:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8005c1:	eb e9                	jmp    8005ac <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8005c3:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c6:	8d 50 04             	lea    0x4(%eax),%edx
  8005c9:	89 55 14             	mov    %edx,0x14(%ebp)
  8005cc:	8b 00                	mov    (%eax),%eax
  8005ce:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8005d4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005d8:	79 93                	jns    80056d <vprintfmt+0x39>
				width = precision, precision = -1;
  8005da:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8005dd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8005e0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8005e7:	eb 84                	jmp    80056d <vprintfmt+0x39>
  8005e9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005ec:	85 c0                	test   %eax,%eax
  8005ee:	ba 00 00 00 00       	mov    $0x0,%edx
  8005f3:	0f 49 d0             	cmovns %eax,%edx
  8005f6:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8005f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8005fc:	e9 6c ff ff ff       	jmp    80056d <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800601:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800604:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  80060b:	e9 5d ff ff ff       	jmp    80056d <vprintfmt+0x39>
  800610:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800613:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800616:	eb bc                	jmp    8005d4 <vprintfmt+0xa0>
			lflag++;
  800618:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  80061b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80061e:	e9 4a ff ff ff       	jmp    80056d <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800623:	8b 45 14             	mov    0x14(%ebp),%eax
  800626:	8d 50 04             	lea    0x4(%eax),%edx
  800629:	89 55 14             	mov    %edx,0x14(%ebp)
  80062c:	83 ec 08             	sub    $0x8,%esp
  80062f:	56                   	push   %esi
  800630:	ff 30                	pushl  (%eax)
  800632:	ff d3                	call   *%ebx
			break;
  800634:	83 c4 10             	add    $0x10,%esp
  800637:	e9 96 01 00 00       	jmp    8007d2 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  80063c:	8b 45 14             	mov    0x14(%ebp),%eax
  80063f:	8d 50 04             	lea    0x4(%eax),%edx
  800642:	89 55 14             	mov    %edx,0x14(%ebp)
  800645:	8b 00                	mov    (%eax),%eax
  800647:	99                   	cltd   
  800648:	31 d0                	xor    %edx,%eax
  80064a:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  80064c:	83 f8 0f             	cmp    $0xf,%eax
  80064f:	7f 20                	jg     800671 <vprintfmt+0x13d>
  800651:	8b 14 85 c0 23 80 00 	mov    0x8023c0(,%eax,4),%edx
  800658:	85 d2                	test   %edx,%edx
  80065a:	74 15                	je     800671 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  80065c:	52                   	push   %edx
  80065d:	68 01 25 80 00       	push   $0x802501
  800662:	56                   	push   %esi
  800663:	53                   	push   %ebx
  800664:	e8 aa fe ff ff       	call   800513 <printfmt>
  800669:	83 c4 10             	add    $0x10,%esp
  80066c:	e9 61 01 00 00       	jmp    8007d2 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800671:	50                   	push   %eax
  800672:	68 3b 21 80 00       	push   $0x80213b
  800677:	56                   	push   %esi
  800678:	53                   	push   %ebx
  800679:	e8 95 fe ff ff       	call   800513 <printfmt>
  80067e:	83 c4 10             	add    $0x10,%esp
  800681:	e9 4c 01 00 00       	jmp    8007d2 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  800686:	8b 45 14             	mov    0x14(%ebp),%eax
  800689:	8d 50 04             	lea    0x4(%eax),%edx
  80068c:	89 55 14             	mov    %edx,0x14(%ebp)
  80068f:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800691:	85 c9                	test   %ecx,%ecx
  800693:	b8 34 21 80 00       	mov    $0x802134,%eax
  800698:	0f 45 c1             	cmovne %ecx,%eax
  80069b:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80069e:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006a2:	7e 06                	jle    8006aa <vprintfmt+0x176>
  8006a4:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8006a8:	75 0d                	jne    8006b7 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006aa:	8b 45 cc             	mov    -0x34(%ebp),%eax
  8006ad:	89 c7                	mov    %eax,%edi
  8006af:	03 45 e0             	add    -0x20(%ebp),%eax
  8006b2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006b5:	eb 57                	jmp    80070e <vprintfmt+0x1da>
  8006b7:	83 ec 08             	sub    $0x8,%esp
  8006ba:	ff 75 d8             	pushl  -0x28(%ebp)
  8006bd:	ff 75 cc             	pushl  -0x34(%ebp)
  8006c0:	e8 43 03 00 00       	call   800a08 <strnlen>
  8006c5:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006c8:	29 c2                	sub    %eax,%edx
  8006ca:	89 55 e0             	mov    %edx,-0x20(%ebp)
  8006cd:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006d0:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8006d4:	89 5d 08             	mov    %ebx,0x8(%ebp)
  8006d7:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  8006d9:	85 db                	test   %ebx,%ebx
  8006db:	7e 10                	jle    8006ed <vprintfmt+0x1b9>
					putch(padc, putdat);
  8006dd:	83 ec 08             	sub    $0x8,%esp
  8006e0:	56                   	push   %esi
  8006e1:	57                   	push   %edi
  8006e2:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  8006e5:	83 eb 01             	sub    $0x1,%ebx
  8006e8:	83 c4 10             	add    $0x10,%esp
  8006eb:	eb ec                	jmp    8006d9 <vprintfmt+0x1a5>
  8006ed:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8006f0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  8006f3:	85 d2                	test   %edx,%edx
  8006f5:	b8 00 00 00 00       	mov    $0x0,%eax
  8006fa:	0f 49 c2             	cmovns %edx,%eax
  8006fd:	29 c2                	sub    %eax,%edx
  8006ff:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800702:	eb a6                	jmp    8006aa <vprintfmt+0x176>
					putch(ch, putdat);
  800704:	83 ec 08             	sub    $0x8,%esp
  800707:	56                   	push   %esi
  800708:	52                   	push   %edx
  800709:	ff d3                	call   *%ebx
  80070b:	83 c4 10             	add    $0x10,%esp
  80070e:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800711:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800713:	83 c7 01             	add    $0x1,%edi
  800716:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80071a:	0f be d0             	movsbl %al,%edx
  80071d:	85 d2                	test   %edx,%edx
  80071f:	74 42                	je     800763 <vprintfmt+0x22f>
  800721:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800725:	78 06                	js     80072d <vprintfmt+0x1f9>
  800727:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  80072b:	78 1e                	js     80074b <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  80072d:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800731:	74 d1                	je     800704 <vprintfmt+0x1d0>
  800733:	0f be c0             	movsbl %al,%eax
  800736:	83 e8 20             	sub    $0x20,%eax
  800739:	83 f8 5e             	cmp    $0x5e,%eax
  80073c:	76 c6                	jbe    800704 <vprintfmt+0x1d0>
					putch('?', putdat);
  80073e:	83 ec 08             	sub    $0x8,%esp
  800741:	56                   	push   %esi
  800742:	6a 3f                	push   $0x3f
  800744:	ff d3                	call   *%ebx
  800746:	83 c4 10             	add    $0x10,%esp
  800749:	eb c3                	jmp    80070e <vprintfmt+0x1da>
  80074b:	89 cf                	mov    %ecx,%edi
  80074d:	eb 0e                	jmp    80075d <vprintfmt+0x229>
				putch(' ', putdat);
  80074f:	83 ec 08             	sub    $0x8,%esp
  800752:	56                   	push   %esi
  800753:	6a 20                	push   $0x20
  800755:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800757:	83 ef 01             	sub    $0x1,%edi
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	85 ff                	test   %edi,%edi
  80075f:	7f ee                	jg     80074f <vprintfmt+0x21b>
  800761:	eb 6f                	jmp    8007d2 <vprintfmt+0x29e>
  800763:	89 cf                	mov    %ecx,%edi
  800765:	eb f6                	jmp    80075d <vprintfmt+0x229>
			num = getint(&ap, lflag);
  800767:	89 ca                	mov    %ecx,%edx
  800769:	8d 45 14             	lea    0x14(%ebp),%eax
  80076c:	e8 55 fd ff ff       	call   8004c6 <getint>
  800771:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800774:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800777:	85 d2                	test   %edx,%edx
  800779:	78 0b                	js     800786 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  80077b:	89 d1                	mov    %edx,%ecx
  80077d:	89 c2                	mov    %eax,%edx
			base = 10;
  80077f:	b8 0a 00 00 00       	mov    $0xa,%eax
  800784:	eb 32                	jmp    8007b8 <vprintfmt+0x284>
				putch('-', putdat);
  800786:	83 ec 08             	sub    $0x8,%esp
  800789:	56                   	push   %esi
  80078a:	6a 2d                	push   $0x2d
  80078c:	ff d3                	call   *%ebx
				num = -(long long) num;
  80078e:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800791:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800794:	f7 da                	neg    %edx
  800796:	83 d1 00             	adc    $0x0,%ecx
  800799:	f7 d9                	neg    %ecx
  80079b:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80079e:	b8 0a 00 00 00       	mov    $0xa,%eax
  8007a3:	eb 13                	jmp    8007b8 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8007a5:	89 ca                	mov    %ecx,%edx
  8007a7:	8d 45 14             	lea    0x14(%ebp),%eax
  8007aa:	e8 e3 fc ff ff       	call   800492 <getuint>
  8007af:	89 d1                	mov    %edx,%ecx
  8007b1:	89 c2                	mov    %eax,%edx
			base = 10;
  8007b3:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  8007b8:	83 ec 0c             	sub    $0xc,%esp
  8007bb:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  8007bf:	57                   	push   %edi
  8007c0:	ff 75 e0             	pushl  -0x20(%ebp)
  8007c3:	50                   	push   %eax
  8007c4:	51                   	push   %ecx
  8007c5:	52                   	push   %edx
  8007c6:	89 f2                	mov    %esi,%edx
  8007c8:	89 d8                	mov    %ebx,%eax
  8007ca:	e8 1a fc ff ff       	call   8003e9 <printnum>
			break;
  8007cf:	83 c4 20             	add    $0x20,%esp
{
  8007d2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  8007d5:	83 c7 01             	add    $0x1,%edi
  8007d8:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8007dc:	83 f8 25             	cmp    $0x25,%eax
  8007df:	0f 84 6a fd ff ff    	je     80054f <vprintfmt+0x1b>
			if (ch == '\0')
  8007e5:	85 c0                	test   %eax,%eax
  8007e7:	0f 84 93 00 00 00    	je     800880 <vprintfmt+0x34c>
			putch(ch, putdat);
  8007ed:	83 ec 08             	sub    $0x8,%esp
  8007f0:	56                   	push   %esi
  8007f1:	50                   	push   %eax
  8007f2:	ff d3                	call   *%ebx
  8007f4:	83 c4 10             	add    $0x10,%esp
  8007f7:	eb dc                	jmp    8007d5 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  8007f9:	89 ca                	mov    %ecx,%edx
  8007fb:	8d 45 14             	lea    0x14(%ebp),%eax
  8007fe:	e8 8f fc ff ff       	call   800492 <getuint>
  800803:	89 d1                	mov    %edx,%ecx
  800805:	89 c2                	mov    %eax,%edx
			base = 8;
  800807:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80080c:	eb aa                	jmp    8007b8 <vprintfmt+0x284>
			putch('0', putdat);
  80080e:	83 ec 08             	sub    $0x8,%esp
  800811:	56                   	push   %esi
  800812:	6a 30                	push   $0x30
  800814:	ff d3                	call   *%ebx
			putch('x', putdat);
  800816:	83 c4 08             	add    $0x8,%esp
  800819:	56                   	push   %esi
  80081a:	6a 78                	push   $0x78
  80081c:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  80081e:	8b 45 14             	mov    0x14(%ebp),%eax
  800821:	8d 50 04             	lea    0x4(%eax),%edx
  800824:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800827:	8b 10                	mov    (%eax),%edx
  800829:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80082e:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800831:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800836:	eb 80                	jmp    8007b8 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800838:	89 ca                	mov    %ecx,%edx
  80083a:	8d 45 14             	lea    0x14(%ebp),%eax
  80083d:	e8 50 fc ff ff       	call   800492 <getuint>
  800842:	89 d1                	mov    %edx,%ecx
  800844:	89 c2                	mov    %eax,%edx
			base = 16;
  800846:	b8 10 00 00 00       	mov    $0x10,%eax
  80084b:	e9 68 ff ff ff       	jmp    8007b8 <vprintfmt+0x284>
			putch(ch, putdat);
  800850:	83 ec 08             	sub    $0x8,%esp
  800853:	56                   	push   %esi
  800854:	6a 25                	push   $0x25
  800856:	ff d3                	call   *%ebx
			break;
  800858:	83 c4 10             	add    $0x10,%esp
  80085b:	e9 72 ff ff ff       	jmp    8007d2 <vprintfmt+0x29e>
			putch('%', putdat);
  800860:	83 ec 08             	sub    $0x8,%esp
  800863:	56                   	push   %esi
  800864:	6a 25                	push   $0x25
  800866:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800868:	83 c4 10             	add    $0x10,%esp
  80086b:	89 f8                	mov    %edi,%eax
  80086d:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800871:	74 05                	je     800878 <vprintfmt+0x344>
  800873:	83 e8 01             	sub    $0x1,%eax
  800876:	eb f5                	jmp    80086d <vprintfmt+0x339>
  800878:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80087b:	e9 52 ff ff ff       	jmp    8007d2 <vprintfmt+0x29e>
}
  800880:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800883:	5b                   	pop    %ebx
  800884:	5e                   	pop    %esi
  800885:	5f                   	pop    %edi
  800886:	5d                   	pop    %ebp
  800887:	c3                   	ret    

00800888 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800888:	f3 0f 1e fb          	endbr32 
  80088c:	55                   	push   %ebp
  80088d:	89 e5                	mov    %esp,%ebp
  80088f:	83 ec 18             	sub    $0x18,%esp
  800892:	8b 45 08             	mov    0x8(%ebp),%eax
  800895:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800898:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80089b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80089f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8008a2:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8008a9:	85 c0                	test   %eax,%eax
  8008ab:	74 26                	je     8008d3 <vsnprintf+0x4b>
  8008ad:	85 d2                	test   %edx,%edx
  8008af:	7e 22                	jle    8008d3 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  8008b1:	ff 75 14             	pushl  0x14(%ebp)
  8008b4:	ff 75 10             	pushl  0x10(%ebp)
  8008b7:	8d 45 ec             	lea    -0x14(%ebp),%eax
  8008ba:	50                   	push   %eax
  8008bb:	68 f2 04 80 00       	push   $0x8004f2
  8008c0:	e8 6f fc ff ff       	call   800534 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  8008c5:	8b 45 ec             	mov    -0x14(%ebp),%eax
  8008c8:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  8008cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008ce:	83 c4 10             	add    $0x10,%esp
}
  8008d1:	c9                   	leave  
  8008d2:	c3                   	ret    
		return -E_INVAL;
  8008d3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8008d8:	eb f7                	jmp    8008d1 <vsnprintf+0x49>

008008da <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8008da:	f3 0f 1e fb          	endbr32 
  8008de:	55                   	push   %ebp
  8008df:	89 e5                	mov    %esp,%ebp
  8008e1:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8008e4:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8008e7:	50                   	push   %eax
  8008e8:	ff 75 10             	pushl  0x10(%ebp)
  8008eb:	ff 75 0c             	pushl  0xc(%ebp)
  8008ee:	ff 75 08             	pushl  0x8(%ebp)
  8008f1:	e8 92 ff ff ff       	call   800888 <vsnprintf>
	va_end(ap);

	return rc;
}
  8008f6:	c9                   	leave  
  8008f7:	c3                   	ret    

008008f8 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  8008f8:	f3 0f 1e fb          	endbr32 
  8008fc:	55                   	push   %ebp
  8008fd:	89 e5                	mov    %esp,%ebp
  8008ff:	57                   	push   %edi
  800900:	56                   	push   %esi
  800901:	53                   	push   %ebx
  800902:	83 ec 0c             	sub    $0xc,%esp
  800905:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  800908:	85 c0                	test   %eax,%eax
  80090a:	74 13                	je     80091f <readline+0x27>
		fprintf(1, "%s", prompt);
  80090c:	83 ec 04             	sub    $0x4,%esp
  80090f:	50                   	push   %eax
  800910:	68 01 25 80 00       	push   $0x802501
  800915:	6a 01                	push   $0x1
  800917:	e8 15 10 00 00       	call   801931 <fprintf>
  80091c:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  80091f:	83 ec 0c             	sub    $0xc,%esp
  800922:	6a 00                	push   $0x0
  800924:	e8 cf f8 ff ff       	call   8001f8 <iscons>
  800929:	89 c7                	mov    %eax,%edi
  80092b:	83 c4 10             	add    $0x10,%esp
	i = 0;
  80092e:	be 00 00 00 00       	mov    $0x0,%esi
  800933:	eb 57                	jmp    80098c <readline+0x94>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  800935:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
  80093a:	83 fb f8             	cmp    $0xfffffff8,%ebx
  80093d:	75 08                	jne    800947 <readline+0x4f>
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  80093f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800942:	5b                   	pop    %ebx
  800943:	5e                   	pop    %esi
  800944:	5f                   	pop    %edi
  800945:	5d                   	pop    %ebp
  800946:	c3                   	ret    
				cprintf("read error: %e\n", c);
  800947:	83 ec 08             	sub    $0x8,%esp
  80094a:	53                   	push   %ebx
  80094b:	68 1f 24 80 00       	push   $0x80241f
  800950:	e8 7c fa ff ff       	call   8003d1 <cprintf>
  800955:	83 c4 10             	add    $0x10,%esp
			return NULL;
  800958:	b8 00 00 00 00       	mov    $0x0,%eax
  80095d:	eb e0                	jmp    80093f <readline+0x47>
			if (echoing)
  80095f:	85 ff                	test   %edi,%edi
  800961:	75 05                	jne    800968 <readline+0x70>
			i--;
  800963:	83 ee 01             	sub    $0x1,%esi
  800966:	eb 24                	jmp    80098c <readline+0x94>
				cputchar('\b');
  800968:	83 ec 0c             	sub    $0xc,%esp
  80096b:	6a 08                	push   $0x8
  80096d:	e8 39 f8 ff ff       	call   8001ab <cputchar>
  800972:	83 c4 10             	add    $0x10,%esp
  800975:	eb ec                	jmp    800963 <readline+0x6b>
				cputchar(c);
  800977:	83 ec 0c             	sub    $0xc,%esp
  80097a:	53                   	push   %ebx
  80097b:	e8 2b f8 ff ff       	call   8001ab <cputchar>
  800980:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  800983:	88 9e 00 40 80 00    	mov    %bl,0x804000(%esi)
  800989:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
  80098c:	e8 3a f8 ff ff       	call   8001cb <getchar>
  800991:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  800993:	85 c0                	test   %eax,%eax
  800995:	78 9e                	js     800935 <readline+0x3d>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  800997:	83 f8 08             	cmp    $0x8,%eax
  80099a:	0f 94 c2             	sete   %dl
  80099d:	83 f8 7f             	cmp    $0x7f,%eax
  8009a0:	0f 94 c0             	sete   %al
  8009a3:	08 c2                	or     %al,%dl
  8009a5:	74 04                	je     8009ab <readline+0xb3>
  8009a7:	85 f6                	test   %esi,%esi
  8009a9:	7f b4                	jg     80095f <readline+0x67>
		} else if (c >= ' ' && i < BUFLEN-1) {
  8009ab:	83 fb 1f             	cmp    $0x1f,%ebx
  8009ae:	7e 0e                	jle    8009be <readline+0xc6>
  8009b0:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  8009b6:	7f 06                	jg     8009be <readline+0xc6>
			if (echoing)
  8009b8:	85 ff                	test   %edi,%edi
  8009ba:	74 c7                	je     800983 <readline+0x8b>
  8009bc:	eb b9                	jmp    800977 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
  8009be:	83 fb 0a             	cmp    $0xa,%ebx
  8009c1:	74 05                	je     8009c8 <readline+0xd0>
  8009c3:	83 fb 0d             	cmp    $0xd,%ebx
  8009c6:	75 c4                	jne    80098c <readline+0x94>
			if (echoing)
  8009c8:	85 ff                	test   %edi,%edi
  8009ca:	75 11                	jne    8009dd <readline+0xe5>
			buf[i] = 0;
  8009cc:	c6 86 00 40 80 00 00 	movb   $0x0,0x804000(%esi)
			return buf;
  8009d3:	b8 00 40 80 00       	mov    $0x804000,%eax
  8009d8:	e9 62 ff ff ff       	jmp    80093f <readline+0x47>
				cputchar('\n');
  8009dd:	83 ec 0c             	sub    $0xc,%esp
  8009e0:	6a 0a                	push   $0xa
  8009e2:	e8 c4 f7 ff ff       	call   8001ab <cputchar>
  8009e7:	83 c4 10             	add    $0x10,%esp
  8009ea:	eb e0                	jmp    8009cc <readline+0xd4>

008009ec <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8009ec:	f3 0f 1e fb          	endbr32 
  8009f0:	55                   	push   %ebp
  8009f1:	89 e5                	mov    %esp,%ebp
  8009f3:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8009f6:	b8 00 00 00 00       	mov    $0x0,%eax
  8009fb:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8009ff:	74 05                	je     800a06 <strlen+0x1a>
		n++;
  800a01:	83 c0 01             	add    $0x1,%eax
  800a04:	eb f5                	jmp    8009fb <strlen+0xf>
	return n;
}
  800a06:	5d                   	pop    %ebp
  800a07:	c3                   	ret    

00800a08 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800a08:	f3 0f 1e fb          	endbr32 
  800a0c:	55                   	push   %ebp
  800a0d:	89 e5                	mov    %esp,%ebp
  800a0f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a12:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800a15:	b8 00 00 00 00       	mov    $0x0,%eax
  800a1a:	39 d0                	cmp    %edx,%eax
  800a1c:	74 0d                	je     800a2b <strnlen+0x23>
  800a1e:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800a22:	74 05                	je     800a29 <strnlen+0x21>
		n++;
  800a24:	83 c0 01             	add    $0x1,%eax
  800a27:	eb f1                	jmp    800a1a <strnlen+0x12>
  800a29:	89 c2                	mov    %eax,%edx
	return n;
}
  800a2b:	89 d0                	mov    %edx,%eax
  800a2d:	5d                   	pop    %ebp
  800a2e:	c3                   	ret    

00800a2f <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800a2f:	f3 0f 1e fb          	endbr32 
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	53                   	push   %ebx
  800a37:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a3a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800a3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800a42:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800a46:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800a49:	83 c0 01             	add    $0x1,%eax
  800a4c:	84 d2                	test   %dl,%dl
  800a4e:	75 f2                	jne    800a42 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800a50:	89 c8                	mov    %ecx,%eax
  800a52:	5b                   	pop    %ebx
  800a53:	5d                   	pop    %ebp
  800a54:	c3                   	ret    

00800a55 <strcat>:

char *
strcat(char *dst, const char *src)
{
  800a55:	f3 0f 1e fb          	endbr32 
  800a59:	55                   	push   %ebp
  800a5a:	89 e5                	mov    %esp,%ebp
  800a5c:	53                   	push   %ebx
  800a5d:	83 ec 10             	sub    $0x10,%esp
  800a60:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800a63:	53                   	push   %ebx
  800a64:	e8 83 ff ff ff       	call   8009ec <strlen>
  800a69:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800a6c:	ff 75 0c             	pushl  0xc(%ebp)
  800a6f:	01 d8                	add    %ebx,%eax
  800a71:	50                   	push   %eax
  800a72:	e8 b8 ff ff ff       	call   800a2f <strcpy>
	return dst;
}
  800a77:	89 d8                	mov    %ebx,%eax
  800a79:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a7c:	c9                   	leave  
  800a7d:	c3                   	ret    

00800a7e <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800a7e:	f3 0f 1e fb          	endbr32 
  800a82:	55                   	push   %ebp
  800a83:	89 e5                	mov    %esp,%ebp
  800a85:	56                   	push   %esi
  800a86:	53                   	push   %ebx
  800a87:	8b 75 08             	mov    0x8(%ebp),%esi
  800a8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a8d:	89 f3                	mov    %esi,%ebx
  800a8f:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a92:	89 f0                	mov    %esi,%eax
  800a94:	39 d8                	cmp    %ebx,%eax
  800a96:	74 11                	je     800aa9 <strncpy+0x2b>
		*dst++ = *src;
  800a98:	83 c0 01             	add    $0x1,%eax
  800a9b:	0f b6 0a             	movzbl (%edx),%ecx
  800a9e:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800aa1:	80 f9 01             	cmp    $0x1,%cl
  800aa4:	83 da ff             	sbb    $0xffffffff,%edx
  800aa7:	eb eb                	jmp    800a94 <strncpy+0x16>
	}
	return ret;
}
  800aa9:	89 f0                	mov    %esi,%eax
  800aab:	5b                   	pop    %ebx
  800aac:	5e                   	pop    %esi
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800aaf:	f3 0f 1e fb          	endbr32 
  800ab3:	55                   	push   %ebp
  800ab4:	89 e5                	mov    %esp,%ebp
  800ab6:	56                   	push   %esi
  800ab7:	53                   	push   %ebx
  800ab8:	8b 75 08             	mov    0x8(%ebp),%esi
  800abb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800abe:	8b 55 10             	mov    0x10(%ebp),%edx
  800ac1:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800ac3:	85 d2                	test   %edx,%edx
  800ac5:	74 21                	je     800ae8 <strlcpy+0x39>
  800ac7:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800acb:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800acd:	39 c2                	cmp    %eax,%edx
  800acf:	74 14                	je     800ae5 <strlcpy+0x36>
  800ad1:	0f b6 19             	movzbl (%ecx),%ebx
  800ad4:	84 db                	test   %bl,%bl
  800ad6:	74 0b                	je     800ae3 <strlcpy+0x34>
			*dst++ = *src++;
  800ad8:	83 c1 01             	add    $0x1,%ecx
  800adb:	83 c2 01             	add    $0x1,%edx
  800ade:	88 5a ff             	mov    %bl,-0x1(%edx)
  800ae1:	eb ea                	jmp    800acd <strlcpy+0x1e>
  800ae3:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800ae5:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800ae8:	29 f0                	sub    %esi,%eax
}
  800aea:	5b                   	pop    %ebx
  800aeb:	5e                   	pop    %esi
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800aee:	f3 0f 1e fb          	endbr32 
  800af2:	55                   	push   %ebp
  800af3:	89 e5                	mov    %esp,%ebp
  800af5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800af8:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800afb:	0f b6 01             	movzbl (%ecx),%eax
  800afe:	84 c0                	test   %al,%al
  800b00:	74 0c                	je     800b0e <strcmp+0x20>
  800b02:	3a 02                	cmp    (%edx),%al
  800b04:	75 08                	jne    800b0e <strcmp+0x20>
		p++, q++;
  800b06:	83 c1 01             	add    $0x1,%ecx
  800b09:	83 c2 01             	add    $0x1,%edx
  800b0c:	eb ed                	jmp    800afb <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800b0e:	0f b6 c0             	movzbl %al,%eax
  800b11:	0f b6 12             	movzbl (%edx),%edx
  800b14:	29 d0                	sub    %edx,%eax
}
  800b16:	5d                   	pop    %ebp
  800b17:	c3                   	ret    

00800b18 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800b18:	f3 0f 1e fb          	endbr32 
  800b1c:	55                   	push   %ebp
  800b1d:	89 e5                	mov    %esp,%ebp
  800b1f:	53                   	push   %ebx
  800b20:	8b 45 08             	mov    0x8(%ebp),%eax
  800b23:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b26:	89 c3                	mov    %eax,%ebx
  800b28:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800b2b:	eb 06                	jmp    800b33 <strncmp+0x1b>
		n--, p++, q++;
  800b2d:	83 c0 01             	add    $0x1,%eax
  800b30:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800b33:	39 d8                	cmp    %ebx,%eax
  800b35:	74 16                	je     800b4d <strncmp+0x35>
  800b37:	0f b6 08             	movzbl (%eax),%ecx
  800b3a:	84 c9                	test   %cl,%cl
  800b3c:	74 04                	je     800b42 <strncmp+0x2a>
  800b3e:	3a 0a                	cmp    (%edx),%cl
  800b40:	74 eb                	je     800b2d <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800b42:	0f b6 00             	movzbl (%eax),%eax
  800b45:	0f b6 12             	movzbl (%edx),%edx
  800b48:	29 d0                	sub    %edx,%eax
}
  800b4a:	5b                   	pop    %ebx
  800b4b:	5d                   	pop    %ebp
  800b4c:	c3                   	ret    
		return 0;
  800b4d:	b8 00 00 00 00       	mov    $0x0,%eax
  800b52:	eb f6                	jmp    800b4a <strncmp+0x32>

00800b54 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800b54:	f3 0f 1e fb          	endbr32 
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	8b 45 08             	mov    0x8(%ebp),%eax
  800b5e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b62:	0f b6 10             	movzbl (%eax),%edx
  800b65:	84 d2                	test   %dl,%dl
  800b67:	74 09                	je     800b72 <strchr+0x1e>
		if (*s == c)
  800b69:	38 ca                	cmp    %cl,%dl
  800b6b:	74 0a                	je     800b77 <strchr+0x23>
	for (; *s; s++)
  800b6d:	83 c0 01             	add    $0x1,%eax
  800b70:	eb f0                	jmp    800b62 <strchr+0xe>
			return (char *) s;
	return 0;
  800b72:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800b77:	5d                   	pop    %ebp
  800b78:	c3                   	ret    

00800b79 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800b79:	f3 0f 1e fb          	endbr32 
  800b7d:	55                   	push   %ebp
  800b7e:	89 e5                	mov    %esp,%ebp
  800b80:	8b 45 08             	mov    0x8(%ebp),%eax
  800b83:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800b87:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800b8a:	38 ca                	cmp    %cl,%dl
  800b8c:	74 09                	je     800b97 <strfind+0x1e>
  800b8e:	84 d2                	test   %dl,%dl
  800b90:	74 05                	je     800b97 <strfind+0x1e>
	for (; *s; s++)
  800b92:	83 c0 01             	add    $0x1,%eax
  800b95:	eb f0                	jmp    800b87 <strfind+0xe>
			break;
	return (char *) s;
}
  800b97:	5d                   	pop    %ebp
  800b98:	c3                   	ret    

00800b99 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800b99:	f3 0f 1e fb          	endbr32 
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	57                   	push   %edi
  800ba1:	56                   	push   %esi
  800ba2:	53                   	push   %ebx
  800ba3:	8b 55 08             	mov    0x8(%ebp),%edx
  800ba6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800ba9:	85 c9                	test   %ecx,%ecx
  800bab:	74 33                	je     800be0 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800bad:	89 d0                	mov    %edx,%eax
  800baf:	09 c8                	or     %ecx,%eax
  800bb1:	a8 03                	test   $0x3,%al
  800bb3:	75 23                	jne    800bd8 <memset+0x3f>
		c &= 0xFF;
  800bb5:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bb9:	89 d8                	mov    %ebx,%eax
  800bbb:	c1 e0 08             	shl    $0x8,%eax
  800bbe:	89 df                	mov    %ebx,%edi
  800bc0:	c1 e7 18             	shl    $0x18,%edi
  800bc3:	89 de                	mov    %ebx,%esi
  800bc5:	c1 e6 10             	shl    $0x10,%esi
  800bc8:	09 f7                	or     %esi,%edi
  800bca:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800bcc:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800bcf:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800bd1:	89 d7                	mov    %edx,%edi
  800bd3:	fc                   	cld    
  800bd4:	f3 ab                	rep stos %eax,%es:(%edi)
  800bd6:	eb 08                	jmp    800be0 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800bd8:	89 d7                	mov    %edx,%edi
  800bda:	8b 45 0c             	mov    0xc(%ebp),%eax
  800bdd:	fc                   	cld    
  800bde:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800be0:	89 d0                	mov    %edx,%eax
  800be2:	5b                   	pop    %ebx
  800be3:	5e                   	pop    %esi
  800be4:	5f                   	pop    %edi
  800be5:	5d                   	pop    %ebp
  800be6:	c3                   	ret    

00800be7 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800be7:	f3 0f 1e fb          	endbr32 
  800beb:	55                   	push   %ebp
  800bec:	89 e5                	mov    %esp,%ebp
  800bee:	57                   	push   %edi
  800bef:	56                   	push   %esi
  800bf0:	8b 45 08             	mov    0x8(%ebp),%eax
  800bf3:	8b 75 0c             	mov    0xc(%ebp),%esi
  800bf6:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800bf9:	39 c6                	cmp    %eax,%esi
  800bfb:	73 32                	jae    800c2f <memmove+0x48>
  800bfd:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800c00:	39 c2                	cmp    %eax,%edx
  800c02:	76 2b                	jbe    800c2f <memmove+0x48>
		s += n;
		d += n;
  800c04:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c07:	89 fe                	mov    %edi,%esi
  800c09:	09 ce                	or     %ecx,%esi
  800c0b:	09 d6                	or     %edx,%esi
  800c0d:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800c13:	75 0e                	jne    800c23 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800c15:	83 ef 04             	sub    $0x4,%edi
  800c18:	8d 72 fc             	lea    -0x4(%edx),%esi
  800c1b:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800c1e:	fd                   	std    
  800c1f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c21:	eb 09                	jmp    800c2c <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800c23:	83 ef 01             	sub    $0x1,%edi
  800c26:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800c29:	fd                   	std    
  800c2a:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800c2c:	fc                   	cld    
  800c2d:	eb 1a                	jmp    800c49 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800c2f:	89 c2                	mov    %eax,%edx
  800c31:	09 ca                	or     %ecx,%edx
  800c33:	09 f2                	or     %esi,%edx
  800c35:	f6 c2 03             	test   $0x3,%dl
  800c38:	75 0a                	jne    800c44 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800c3a:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800c3d:	89 c7                	mov    %eax,%edi
  800c3f:	fc                   	cld    
  800c40:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800c42:	eb 05                	jmp    800c49 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800c44:	89 c7                	mov    %eax,%edi
  800c46:	fc                   	cld    
  800c47:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800c49:	5e                   	pop    %esi
  800c4a:	5f                   	pop    %edi
  800c4b:	5d                   	pop    %ebp
  800c4c:	c3                   	ret    

00800c4d <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800c4d:	f3 0f 1e fb          	endbr32 
  800c51:	55                   	push   %ebp
  800c52:	89 e5                	mov    %esp,%ebp
  800c54:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800c57:	ff 75 10             	pushl  0x10(%ebp)
  800c5a:	ff 75 0c             	pushl  0xc(%ebp)
  800c5d:	ff 75 08             	pushl  0x8(%ebp)
  800c60:	e8 82 ff ff ff       	call   800be7 <memmove>
}
  800c65:	c9                   	leave  
  800c66:	c3                   	ret    

00800c67 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800c67:	f3 0f 1e fb          	endbr32 
  800c6b:	55                   	push   %ebp
  800c6c:	89 e5                	mov    %esp,%ebp
  800c6e:	56                   	push   %esi
  800c6f:	53                   	push   %ebx
  800c70:	8b 45 08             	mov    0x8(%ebp),%eax
  800c73:	8b 55 0c             	mov    0xc(%ebp),%edx
  800c76:	89 c6                	mov    %eax,%esi
  800c78:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800c7b:	39 f0                	cmp    %esi,%eax
  800c7d:	74 1c                	je     800c9b <memcmp+0x34>
		if (*s1 != *s2)
  800c7f:	0f b6 08             	movzbl (%eax),%ecx
  800c82:	0f b6 1a             	movzbl (%edx),%ebx
  800c85:	38 d9                	cmp    %bl,%cl
  800c87:	75 08                	jne    800c91 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800c89:	83 c0 01             	add    $0x1,%eax
  800c8c:	83 c2 01             	add    $0x1,%edx
  800c8f:	eb ea                	jmp    800c7b <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800c91:	0f b6 c1             	movzbl %cl,%eax
  800c94:	0f b6 db             	movzbl %bl,%ebx
  800c97:	29 d8                	sub    %ebx,%eax
  800c99:	eb 05                	jmp    800ca0 <memcmp+0x39>
	}

	return 0;
  800c9b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ca0:	5b                   	pop    %ebx
  800ca1:	5e                   	pop    %esi
  800ca2:	5d                   	pop    %ebp
  800ca3:	c3                   	ret    

00800ca4 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800ca4:	f3 0f 1e fb          	endbr32 
  800ca8:	55                   	push   %ebp
  800ca9:	89 e5                	mov    %esp,%ebp
  800cab:	8b 45 08             	mov    0x8(%ebp),%eax
  800cae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800cb1:	89 c2                	mov    %eax,%edx
  800cb3:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800cb6:	39 d0                	cmp    %edx,%eax
  800cb8:	73 09                	jae    800cc3 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800cba:	38 08                	cmp    %cl,(%eax)
  800cbc:	74 05                	je     800cc3 <memfind+0x1f>
	for (; s < ends; s++)
  800cbe:	83 c0 01             	add    $0x1,%eax
  800cc1:	eb f3                	jmp    800cb6 <memfind+0x12>
			break;
	return (void *) s;
}
  800cc3:	5d                   	pop    %ebp
  800cc4:	c3                   	ret    

00800cc5 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800cc5:	f3 0f 1e fb          	endbr32 
  800cc9:	55                   	push   %ebp
  800cca:	89 e5                	mov    %esp,%ebp
  800ccc:	57                   	push   %edi
  800ccd:	56                   	push   %esi
  800cce:	53                   	push   %ebx
  800ccf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800cd2:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800cd5:	eb 03                	jmp    800cda <strtol+0x15>
		s++;
  800cd7:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800cda:	0f b6 01             	movzbl (%ecx),%eax
  800cdd:	3c 20                	cmp    $0x20,%al
  800cdf:	74 f6                	je     800cd7 <strtol+0x12>
  800ce1:	3c 09                	cmp    $0x9,%al
  800ce3:	74 f2                	je     800cd7 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800ce5:	3c 2b                	cmp    $0x2b,%al
  800ce7:	74 2a                	je     800d13 <strtol+0x4e>
	int neg = 0;
  800ce9:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  800cee:	3c 2d                	cmp    $0x2d,%al
  800cf0:	74 2b                	je     800d1d <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800cf2:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800cf8:	75 0f                	jne    800d09 <strtol+0x44>
  800cfa:	80 39 30             	cmpb   $0x30,(%ecx)
  800cfd:	74 28                	je     800d27 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800cff:	85 db                	test   %ebx,%ebx
  800d01:	b8 0a 00 00 00       	mov    $0xa,%eax
  800d06:	0f 44 d8             	cmove  %eax,%ebx
  800d09:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0e:	89 5d 10             	mov    %ebx,0x10(%ebp)
  800d11:	eb 46                	jmp    800d59 <strtol+0x94>
		s++;
  800d13:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  800d16:	bf 00 00 00 00       	mov    $0x0,%edi
  800d1b:	eb d5                	jmp    800cf2 <strtol+0x2d>
		s++, neg = 1;
  800d1d:	83 c1 01             	add    $0x1,%ecx
  800d20:	bf 01 00 00 00       	mov    $0x1,%edi
  800d25:	eb cb                	jmp    800cf2 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800d27:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800d2b:	74 0e                	je     800d3b <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  800d2d:	85 db                	test   %ebx,%ebx
  800d2f:	75 d8                	jne    800d09 <strtol+0x44>
		s++, base = 8;
  800d31:	83 c1 01             	add    $0x1,%ecx
  800d34:	bb 08 00 00 00       	mov    $0x8,%ebx
  800d39:	eb ce                	jmp    800d09 <strtol+0x44>
		s += 2, base = 16;
  800d3b:	83 c1 02             	add    $0x2,%ecx
  800d3e:	bb 10 00 00 00       	mov    $0x10,%ebx
  800d43:	eb c4                	jmp    800d09 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  800d45:	0f be d2             	movsbl %dl,%edx
  800d48:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  800d4b:	3b 55 10             	cmp    0x10(%ebp),%edx
  800d4e:	7d 3a                	jge    800d8a <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  800d50:	83 c1 01             	add    $0x1,%ecx
  800d53:	0f af 45 10          	imul   0x10(%ebp),%eax
  800d57:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  800d59:	0f b6 11             	movzbl (%ecx),%edx
  800d5c:	8d 72 d0             	lea    -0x30(%edx),%esi
  800d5f:	89 f3                	mov    %esi,%ebx
  800d61:	80 fb 09             	cmp    $0x9,%bl
  800d64:	76 df                	jbe    800d45 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  800d66:	8d 72 9f             	lea    -0x61(%edx),%esi
  800d69:	89 f3                	mov    %esi,%ebx
  800d6b:	80 fb 19             	cmp    $0x19,%bl
  800d6e:	77 08                	ja     800d78 <strtol+0xb3>
			dig = *s - 'a' + 10;
  800d70:	0f be d2             	movsbl %dl,%edx
  800d73:	83 ea 57             	sub    $0x57,%edx
  800d76:	eb d3                	jmp    800d4b <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  800d78:	8d 72 bf             	lea    -0x41(%edx),%esi
  800d7b:	89 f3                	mov    %esi,%ebx
  800d7d:	80 fb 19             	cmp    $0x19,%bl
  800d80:	77 08                	ja     800d8a <strtol+0xc5>
			dig = *s - 'A' + 10;
  800d82:	0f be d2             	movsbl %dl,%edx
  800d85:	83 ea 37             	sub    $0x37,%edx
  800d88:	eb c1                	jmp    800d4b <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  800d8a:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800d8e:	74 05                	je     800d95 <strtol+0xd0>
		*endptr = (char *) s;
  800d90:	8b 75 0c             	mov    0xc(%ebp),%esi
  800d93:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  800d95:	89 c2                	mov    %eax,%edx
  800d97:	f7 da                	neg    %edx
  800d99:	85 ff                	test   %edi,%edi
  800d9b:	0f 45 c2             	cmovne %edx,%eax
}
  800d9e:	5b                   	pop    %ebx
  800d9f:	5e                   	pop    %esi
  800da0:	5f                   	pop    %edi
  800da1:	5d                   	pop    %ebp
  800da2:	c3                   	ret    

00800da3 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  800da3:	55                   	push   %ebp
  800da4:	89 e5                	mov    %esp,%ebp
  800da6:	57                   	push   %edi
  800da7:	56                   	push   %esi
  800da8:	53                   	push   %ebx
  800da9:	83 ec 1c             	sub    $0x1c,%esp
  800dac:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800daf:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  800db2:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  800db4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800db7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800dba:	8b 7d 10             	mov    0x10(%ebp),%edi
  800dbd:	8b 75 14             	mov    0x14(%ebp),%esi
  800dc0:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800dc2:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  800dc6:	74 04                	je     800dcc <syscall+0x29>
  800dc8:	85 c0                	test   %eax,%eax
  800dca:	7f 08                	jg     800dd4 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  800dcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800dcf:	5b                   	pop    %ebx
  800dd0:	5e                   	pop    %esi
  800dd1:	5f                   	pop    %edi
  800dd2:	5d                   	pop    %ebp
  800dd3:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800dd4:	83 ec 0c             	sub    $0xc,%esp
  800dd7:	50                   	push   %eax
  800dd8:	ff 75 e0             	pushl  -0x20(%ebp)
  800ddb:	68 2f 24 80 00       	push   $0x80242f
  800de0:	6a 23                	push   $0x23
  800de2:	68 4c 24 80 00       	push   $0x80244c
  800de7:	e8 fe f4 ff ff       	call   8002ea <_panic>

00800dec <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800dec:	f3 0f 1e fb          	endbr32 
  800df0:	55                   	push   %ebp
  800df1:	89 e5                	mov    %esp,%ebp
  800df3:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800df6:	6a 00                	push   $0x0
  800df8:	6a 00                	push   $0x0
  800dfa:	6a 00                	push   $0x0
  800dfc:	ff 75 0c             	pushl  0xc(%ebp)
  800dff:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e02:	ba 00 00 00 00       	mov    $0x0,%edx
  800e07:	b8 00 00 00 00       	mov    $0x0,%eax
  800e0c:	e8 92 ff ff ff       	call   800da3 <syscall>
}
  800e11:	83 c4 10             	add    $0x10,%esp
  800e14:	c9                   	leave  
  800e15:	c3                   	ret    

00800e16 <sys_cgetc>:

int
sys_cgetc(void)
{
  800e16:	f3 0f 1e fb          	endbr32 
  800e1a:	55                   	push   %ebp
  800e1b:	89 e5                	mov    %esp,%ebp
  800e1d:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800e20:	6a 00                	push   $0x0
  800e22:	6a 00                	push   $0x0
  800e24:	6a 00                	push   $0x0
  800e26:	6a 00                	push   $0x0
  800e28:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e2d:	ba 00 00 00 00       	mov    $0x0,%edx
  800e32:	b8 01 00 00 00       	mov    $0x1,%eax
  800e37:	e8 67 ff ff ff       	call   800da3 <syscall>
}
  800e3c:	c9                   	leave  
  800e3d:	c3                   	ret    

00800e3e <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800e3e:	f3 0f 1e fb          	endbr32 
  800e42:	55                   	push   %ebp
  800e43:	89 e5                	mov    %esp,%ebp
  800e45:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800e48:	6a 00                	push   $0x0
  800e4a:	6a 00                	push   $0x0
  800e4c:	6a 00                	push   $0x0
  800e4e:	6a 00                	push   $0x0
  800e50:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e53:	ba 01 00 00 00       	mov    $0x1,%edx
  800e58:	b8 03 00 00 00       	mov    $0x3,%eax
  800e5d:	e8 41 ff ff ff       	call   800da3 <syscall>
}
  800e62:	c9                   	leave  
  800e63:	c3                   	ret    

00800e64 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800e64:	f3 0f 1e fb          	endbr32 
  800e68:	55                   	push   %ebp
  800e69:	89 e5                	mov    %esp,%ebp
  800e6b:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800e6e:	6a 00                	push   $0x0
  800e70:	6a 00                	push   $0x0
  800e72:	6a 00                	push   $0x0
  800e74:	6a 00                	push   $0x0
  800e76:	b9 00 00 00 00       	mov    $0x0,%ecx
  800e7b:	ba 00 00 00 00       	mov    $0x0,%edx
  800e80:	b8 02 00 00 00       	mov    $0x2,%eax
  800e85:	e8 19 ff ff ff       	call   800da3 <syscall>
}
  800e8a:	c9                   	leave  
  800e8b:	c3                   	ret    

00800e8c <sys_yield>:

void
sys_yield(void)
{
  800e8c:	f3 0f 1e fb          	endbr32 
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800e96:	6a 00                	push   $0x0
  800e98:	6a 00                	push   $0x0
  800e9a:	6a 00                	push   $0x0
  800e9c:	6a 00                	push   $0x0
  800e9e:	b9 00 00 00 00       	mov    $0x0,%ecx
  800ea3:	ba 00 00 00 00       	mov    $0x0,%edx
  800ea8:	b8 0b 00 00 00       	mov    $0xb,%eax
  800ead:	e8 f1 fe ff ff       	call   800da3 <syscall>
}
  800eb2:	83 c4 10             	add    $0x10,%esp
  800eb5:	c9                   	leave  
  800eb6:	c3                   	ret    

00800eb7 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800eb7:	f3 0f 1e fb          	endbr32 
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
  800ebe:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  800ec1:	6a 00                	push   $0x0
  800ec3:	6a 00                	push   $0x0
  800ec5:	ff 75 10             	pushl  0x10(%ebp)
  800ec8:	ff 75 0c             	pushl  0xc(%ebp)
  800ecb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ece:	ba 01 00 00 00       	mov    $0x1,%edx
  800ed3:	b8 04 00 00 00       	mov    $0x4,%eax
  800ed8:	e8 c6 fe ff ff       	call   800da3 <syscall>
}
  800edd:	c9                   	leave  
  800ede:	c3                   	ret    

00800edf <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800edf:	f3 0f 1e fb          	endbr32 
  800ee3:	55                   	push   %ebp
  800ee4:	89 e5                	mov    %esp,%ebp
  800ee6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800ee9:	ff 75 18             	pushl  0x18(%ebp)
  800eec:	ff 75 14             	pushl  0x14(%ebp)
  800eef:	ff 75 10             	pushl  0x10(%ebp)
  800ef2:	ff 75 0c             	pushl  0xc(%ebp)
  800ef5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ef8:	ba 01 00 00 00       	mov    $0x1,%edx
  800efd:	b8 05 00 00 00       	mov    $0x5,%eax
  800f02:	e8 9c fe ff ff       	call   800da3 <syscall>
}
  800f07:	c9                   	leave  
  800f08:	c3                   	ret    

00800f09 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800f09:	f3 0f 1e fb          	endbr32 
  800f0d:	55                   	push   %ebp
  800f0e:	89 e5                	mov    %esp,%ebp
  800f10:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800f13:	6a 00                	push   $0x0
  800f15:	6a 00                	push   $0x0
  800f17:	6a 00                	push   $0x0
  800f19:	ff 75 0c             	pushl  0xc(%ebp)
  800f1c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f1f:	ba 01 00 00 00       	mov    $0x1,%edx
  800f24:	b8 06 00 00 00       	mov    $0x6,%eax
  800f29:	e8 75 fe ff ff       	call   800da3 <syscall>
}
  800f2e:	c9                   	leave  
  800f2f:	c3                   	ret    

00800f30 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800f30:	f3 0f 1e fb          	endbr32 
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800f3a:	6a 00                	push   $0x0
  800f3c:	6a 00                	push   $0x0
  800f3e:	6a 00                	push   $0x0
  800f40:	ff 75 0c             	pushl  0xc(%ebp)
  800f43:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f46:	ba 01 00 00 00       	mov    $0x1,%edx
  800f4b:	b8 08 00 00 00       	mov    $0x8,%eax
  800f50:	e8 4e fe ff ff       	call   800da3 <syscall>
}
  800f55:	c9                   	leave  
  800f56:	c3                   	ret    

00800f57 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800f57:	f3 0f 1e fb          	endbr32 
  800f5b:	55                   	push   %ebp
  800f5c:	89 e5                	mov    %esp,%ebp
  800f5e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800f61:	6a 00                	push   $0x0
  800f63:	6a 00                	push   $0x0
  800f65:	6a 00                	push   $0x0
  800f67:	ff 75 0c             	pushl  0xc(%ebp)
  800f6a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f6d:	ba 01 00 00 00       	mov    $0x1,%edx
  800f72:	b8 09 00 00 00       	mov    $0x9,%eax
  800f77:	e8 27 fe ff ff       	call   800da3 <syscall>
}
  800f7c:	c9                   	leave  
  800f7d:	c3                   	ret    

00800f7e <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800f7e:	f3 0f 1e fb          	endbr32 
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800f88:	6a 00                	push   $0x0
  800f8a:	6a 00                	push   $0x0
  800f8c:	6a 00                	push   $0x0
  800f8e:	ff 75 0c             	pushl  0xc(%ebp)
  800f91:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800f94:	ba 01 00 00 00       	mov    $0x1,%edx
  800f99:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f9e:	e8 00 fe ff ff       	call   800da3 <syscall>
}
  800fa3:	c9                   	leave  
  800fa4:	c3                   	ret    

00800fa5 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  800fa5:	f3 0f 1e fb          	endbr32 
  800fa9:	55                   	push   %ebp
  800faa:	89 e5                	mov    %esp,%ebp
  800fac:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  800faf:	6a 00                	push   $0x0
  800fb1:	ff 75 14             	pushl  0x14(%ebp)
  800fb4:	ff 75 10             	pushl  0x10(%ebp)
  800fb7:	ff 75 0c             	pushl  0xc(%ebp)
  800fba:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fbd:	ba 00 00 00 00       	mov    $0x0,%edx
  800fc2:	b8 0c 00 00 00       	mov    $0xc,%eax
  800fc7:	e8 d7 fd ff ff       	call   800da3 <syscall>
}
  800fcc:	c9                   	leave  
  800fcd:	c3                   	ret    

00800fce <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800fce:	f3 0f 1e fb          	endbr32 
  800fd2:	55                   	push   %ebp
  800fd3:	89 e5                	mov    %esp,%ebp
  800fd5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  800fd8:	6a 00                	push   $0x0
  800fda:	6a 00                	push   $0x0
  800fdc:	6a 00                	push   $0x0
  800fde:	6a 00                	push   $0x0
  800fe0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fe3:	ba 01 00 00 00       	mov    $0x1,%edx
  800fe8:	b8 0d 00 00 00       	mov    $0xd,%eax
  800fed:	e8 b1 fd ff ff       	call   800da3 <syscall>
}
  800ff2:	c9                   	leave  
  800ff3:	c3                   	ret    

00800ff4 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800ff4:	f3 0f 1e fb          	endbr32 
  800ff8:	55                   	push   %ebp
  800ff9:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800ffb:	8b 45 08             	mov    0x8(%ebp),%eax
  800ffe:	05 00 00 00 30       	add    $0x30000000,%eax
  801003:	c1 e8 0c             	shr    $0xc,%eax
}
  801006:	5d                   	pop    %ebp
  801007:	c3                   	ret    

00801008 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801008:	f3 0f 1e fb          	endbr32 
  80100c:	55                   	push   %ebp
  80100d:	89 e5                	mov    %esp,%ebp
  80100f:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  801012:	ff 75 08             	pushl  0x8(%ebp)
  801015:	e8 da ff ff ff       	call   800ff4 <fd2num>
  80101a:	83 c4 10             	add    $0x10,%esp
  80101d:	c1 e0 0c             	shl    $0xc,%eax
  801020:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801025:	c9                   	leave  
  801026:	c3                   	ret    

00801027 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801027:	f3 0f 1e fb          	endbr32 
  80102b:	55                   	push   %ebp
  80102c:	89 e5                	mov    %esp,%ebp
  80102e:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801033:	89 c2                	mov    %eax,%edx
  801035:	c1 ea 16             	shr    $0x16,%edx
  801038:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80103f:	f6 c2 01             	test   $0x1,%dl
  801042:	74 2d                	je     801071 <fd_alloc+0x4a>
  801044:	89 c2                	mov    %eax,%edx
  801046:	c1 ea 0c             	shr    $0xc,%edx
  801049:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801050:	f6 c2 01             	test   $0x1,%dl
  801053:	74 1c                	je     801071 <fd_alloc+0x4a>
  801055:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80105a:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80105f:	75 d2                	jne    801033 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801061:	8b 45 08             	mov    0x8(%ebp),%eax
  801064:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80106a:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80106f:	eb 0a                	jmp    80107b <fd_alloc+0x54>
			*fd_store = fd;
  801071:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801074:	89 01                	mov    %eax,(%ecx)
			return 0;
  801076:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80107b:	5d                   	pop    %ebp
  80107c:	c3                   	ret    

0080107d <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  80107d:	f3 0f 1e fb          	endbr32 
  801081:	55                   	push   %ebp
  801082:	89 e5                	mov    %esp,%ebp
  801084:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801087:	83 f8 1f             	cmp    $0x1f,%eax
  80108a:	77 30                	ja     8010bc <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80108c:	c1 e0 0c             	shl    $0xc,%eax
  80108f:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801094:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80109a:	f6 c2 01             	test   $0x1,%dl
  80109d:	74 24                	je     8010c3 <fd_lookup+0x46>
  80109f:	89 c2                	mov    %eax,%edx
  8010a1:	c1 ea 0c             	shr    $0xc,%edx
  8010a4:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8010ab:	f6 c2 01             	test   $0x1,%dl
  8010ae:	74 1a                	je     8010ca <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8010b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8010b3:	89 02                	mov    %eax,(%edx)
	return 0;
  8010b5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8010ba:	5d                   	pop    %ebp
  8010bb:	c3                   	ret    
		return -E_INVAL;
  8010bc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010c1:	eb f7                	jmp    8010ba <fd_lookup+0x3d>
		return -E_INVAL;
  8010c3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010c8:	eb f0                	jmp    8010ba <fd_lookup+0x3d>
  8010ca:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8010cf:	eb e9                	jmp    8010ba <fd_lookup+0x3d>

008010d1 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8010d1:	f3 0f 1e fb          	endbr32 
  8010d5:	55                   	push   %ebp
  8010d6:	89 e5                	mov    %esp,%ebp
  8010d8:	83 ec 08             	sub    $0x8,%esp
  8010db:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010de:	ba d8 24 80 00       	mov    $0x8024d8,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8010e3:	b8 20 30 80 00       	mov    $0x803020,%eax
		if (devtab[i]->dev_id == dev_id) {
  8010e8:	39 08                	cmp    %ecx,(%eax)
  8010ea:	74 33                	je     80111f <dev_lookup+0x4e>
  8010ec:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8010ef:	8b 02                	mov    (%edx),%eax
  8010f1:	85 c0                	test   %eax,%eax
  8010f3:	75 f3                	jne    8010e8 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8010f5:	a1 04 44 80 00       	mov    0x804404,%eax
  8010fa:	8b 40 48             	mov    0x48(%eax),%eax
  8010fd:	83 ec 04             	sub    $0x4,%esp
  801100:	51                   	push   %ecx
  801101:	50                   	push   %eax
  801102:	68 5c 24 80 00       	push   $0x80245c
  801107:	e8 c5 f2 ff ff       	call   8003d1 <cprintf>
	*dev = 0;
  80110c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80110f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801115:	83 c4 10             	add    $0x10,%esp
  801118:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80111d:	c9                   	leave  
  80111e:	c3                   	ret    
			*dev = devtab[i];
  80111f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801122:	89 01                	mov    %eax,(%ecx)
			return 0;
  801124:	b8 00 00 00 00       	mov    $0x0,%eax
  801129:	eb f2                	jmp    80111d <dev_lookup+0x4c>

0080112b <fd_close>:
{
  80112b:	f3 0f 1e fb          	endbr32 
  80112f:	55                   	push   %ebp
  801130:	89 e5                	mov    %esp,%ebp
  801132:	57                   	push   %edi
  801133:	56                   	push   %esi
  801134:	53                   	push   %ebx
  801135:	83 ec 28             	sub    $0x28,%esp
  801138:	8b 75 08             	mov    0x8(%ebp),%esi
  80113b:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80113e:	56                   	push   %esi
  80113f:	e8 b0 fe ff ff       	call   800ff4 <fd2num>
  801144:	83 c4 08             	add    $0x8,%esp
  801147:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80114a:	52                   	push   %edx
  80114b:	50                   	push   %eax
  80114c:	e8 2c ff ff ff       	call   80107d <fd_lookup>
  801151:	89 c3                	mov    %eax,%ebx
  801153:	83 c4 10             	add    $0x10,%esp
  801156:	85 c0                	test   %eax,%eax
  801158:	78 05                	js     80115f <fd_close+0x34>
	    || fd != fd2)
  80115a:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80115d:	74 16                	je     801175 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80115f:	89 f8                	mov    %edi,%eax
  801161:	84 c0                	test   %al,%al
  801163:	b8 00 00 00 00       	mov    $0x0,%eax
  801168:	0f 44 d8             	cmove  %eax,%ebx
}
  80116b:	89 d8                	mov    %ebx,%eax
  80116d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801170:	5b                   	pop    %ebx
  801171:	5e                   	pop    %esi
  801172:	5f                   	pop    %edi
  801173:	5d                   	pop    %ebp
  801174:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801175:	83 ec 08             	sub    $0x8,%esp
  801178:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80117b:	50                   	push   %eax
  80117c:	ff 36                	pushl  (%esi)
  80117e:	e8 4e ff ff ff       	call   8010d1 <dev_lookup>
  801183:	89 c3                	mov    %eax,%ebx
  801185:	83 c4 10             	add    $0x10,%esp
  801188:	85 c0                	test   %eax,%eax
  80118a:	78 1a                	js     8011a6 <fd_close+0x7b>
		if (dev->dev_close)
  80118c:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80118f:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801192:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801197:	85 c0                	test   %eax,%eax
  801199:	74 0b                	je     8011a6 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80119b:	83 ec 0c             	sub    $0xc,%esp
  80119e:	56                   	push   %esi
  80119f:	ff d0                	call   *%eax
  8011a1:	89 c3                	mov    %eax,%ebx
  8011a3:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8011a6:	83 ec 08             	sub    $0x8,%esp
  8011a9:	56                   	push   %esi
  8011aa:	6a 00                	push   $0x0
  8011ac:	e8 58 fd ff ff       	call   800f09 <sys_page_unmap>
	return r;
  8011b1:	83 c4 10             	add    $0x10,%esp
  8011b4:	eb b5                	jmp    80116b <fd_close+0x40>

008011b6 <close>:

int
close(int fdnum)
{
  8011b6:	f3 0f 1e fb          	endbr32 
  8011ba:	55                   	push   %ebp
  8011bb:	89 e5                	mov    %esp,%ebp
  8011bd:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8011c0:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8011c3:	50                   	push   %eax
  8011c4:	ff 75 08             	pushl  0x8(%ebp)
  8011c7:	e8 b1 fe ff ff       	call   80107d <fd_lookup>
  8011cc:	83 c4 10             	add    $0x10,%esp
  8011cf:	85 c0                	test   %eax,%eax
  8011d1:	79 02                	jns    8011d5 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8011d3:	c9                   	leave  
  8011d4:	c3                   	ret    
		return fd_close(fd, 1);
  8011d5:	83 ec 08             	sub    $0x8,%esp
  8011d8:	6a 01                	push   $0x1
  8011da:	ff 75 f4             	pushl  -0xc(%ebp)
  8011dd:	e8 49 ff ff ff       	call   80112b <fd_close>
  8011e2:	83 c4 10             	add    $0x10,%esp
  8011e5:	eb ec                	jmp    8011d3 <close+0x1d>

008011e7 <close_all>:

void
close_all(void)
{
  8011e7:	f3 0f 1e fb          	endbr32 
  8011eb:	55                   	push   %ebp
  8011ec:	89 e5                	mov    %esp,%ebp
  8011ee:	53                   	push   %ebx
  8011ef:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8011f2:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8011f7:	83 ec 0c             	sub    $0xc,%esp
  8011fa:	53                   	push   %ebx
  8011fb:	e8 b6 ff ff ff       	call   8011b6 <close>
	for (i = 0; i < MAXFD; i++)
  801200:	83 c3 01             	add    $0x1,%ebx
  801203:	83 c4 10             	add    $0x10,%esp
  801206:	83 fb 20             	cmp    $0x20,%ebx
  801209:	75 ec                	jne    8011f7 <close_all+0x10>
}
  80120b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80120e:	c9                   	leave  
  80120f:	c3                   	ret    

00801210 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801210:	f3 0f 1e fb          	endbr32 
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
  801217:	57                   	push   %edi
  801218:	56                   	push   %esi
  801219:	53                   	push   %ebx
  80121a:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80121d:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801220:	50                   	push   %eax
  801221:	ff 75 08             	pushl  0x8(%ebp)
  801224:	e8 54 fe ff ff       	call   80107d <fd_lookup>
  801229:	89 c3                	mov    %eax,%ebx
  80122b:	83 c4 10             	add    $0x10,%esp
  80122e:	85 c0                	test   %eax,%eax
  801230:	0f 88 81 00 00 00    	js     8012b7 <dup+0xa7>
		return r;
	close(newfdnum);
  801236:	83 ec 0c             	sub    $0xc,%esp
  801239:	ff 75 0c             	pushl  0xc(%ebp)
  80123c:	e8 75 ff ff ff       	call   8011b6 <close>

	newfd = INDEX2FD(newfdnum);
  801241:	8b 75 0c             	mov    0xc(%ebp),%esi
  801244:	c1 e6 0c             	shl    $0xc,%esi
  801247:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80124d:	83 c4 04             	add    $0x4,%esp
  801250:	ff 75 e4             	pushl  -0x1c(%ebp)
  801253:	e8 b0 fd ff ff       	call   801008 <fd2data>
  801258:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80125a:	89 34 24             	mov    %esi,(%esp)
  80125d:	e8 a6 fd ff ff       	call   801008 <fd2data>
  801262:	83 c4 10             	add    $0x10,%esp
  801265:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  801267:	89 d8                	mov    %ebx,%eax
  801269:	c1 e8 16             	shr    $0x16,%eax
  80126c:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  801273:	a8 01                	test   $0x1,%al
  801275:	74 11                	je     801288 <dup+0x78>
  801277:	89 d8                	mov    %ebx,%eax
  801279:	c1 e8 0c             	shr    $0xc,%eax
  80127c:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  801283:	f6 c2 01             	test   $0x1,%dl
  801286:	75 39                	jne    8012c1 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  801288:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80128b:	89 d0                	mov    %edx,%eax
  80128d:	c1 e8 0c             	shr    $0xc,%eax
  801290:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  801297:	83 ec 0c             	sub    $0xc,%esp
  80129a:	25 07 0e 00 00       	and    $0xe07,%eax
  80129f:	50                   	push   %eax
  8012a0:	56                   	push   %esi
  8012a1:	6a 00                	push   $0x0
  8012a3:	52                   	push   %edx
  8012a4:	6a 00                	push   $0x0
  8012a6:	e8 34 fc ff ff       	call   800edf <sys_page_map>
  8012ab:	89 c3                	mov    %eax,%ebx
  8012ad:	83 c4 20             	add    $0x20,%esp
  8012b0:	85 c0                	test   %eax,%eax
  8012b2:	78 31                	js     8012e5 <dup+0xd5>
		goto err;

	return newfdnum;
  8012b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8012b7:	89 d8                	mov    %ebx,%eax
  8012b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8012bc:	5b                   	pop    %ebx
  8012bd:	5e                   	pop    %esi
  8012be:	5f                   	pop    %edi
  8012bf:	5d                   	pop    %ebp
  8012c0:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8012c1:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8012c8:	83 ec 0c             	sub    $0xc,%esp
  8012cb:	25 07 0e 00 00       	and    $0xe07,%eax
  8012d0:	50                   	push   %eax
  8012d1:	57                   	push   %edi
  8012d2:	6a 00                	push   $0x0
  8012d4:	53                   	push   %ebx
  8012d5:	6a 00                	push   $0x0
  8012d7:	e8 03 fc ff ff       	call   800edf <sys_page_map>
  8012dc:	89 c3                	mov    %eax,%ebx
  8012de:	83 c4 20             	add    $0x20,%esp
  8012e1:	85 c0                	test   %eax,%eax
  8012e3:	79 a3                	jns    801288 <dup+0x78>
	sys_page_unmap(0, newfd);
  8012e5:	83 ec 08             	sub    $0x8,%esp
  8012e8:	56                   	push   %esi
  8012e9:	6a 00                	push   $0x0
  8012eb:	e8 19 fc ff ff       	call   800f09 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8012f0:	83 c4 08             	add    $0x8,%esp
  8012f3:	57                   	push   %edi
  8012f4:	6a 00                	push   $0x0
  8012f6:	e8 0e fc ff ff       	call   800f09 <sys_page_unmap>
	return r;
  8012fb:	83 c4 10             	add    $0x10,%esp
  8012fe:	eb b7                	jmp    8012b7 <dup+0xa7>

00801300 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801300:	f3 0f 1e fb          	endbr32 
  801304:	55                   	push   %ebp
  801305:	89 e5                	mov    %esp,%ebp
  801307:	53                   	push   %ebx
  801308:	83 ec 1c             	sub    $0x1c,%esp
  80130b:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80130e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801311:	50                   	push   %eax
  801312:	53                   	push   %ebx
  801313:	e8 65 fd ff ff       	call   80107d <fd_lookup>
  801318:	83 c4 10             	add    $0x10,%esp
  80131b:	85 c0                	test   %eax,%eax
  80131d:	78 3f                	js     80135e <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80131f:	83 ec 08             	sub    $0x8,%esp
  801322:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801325:	50                   	push   %eax
  801326:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801329:	ff 30                	pushl  (%eax)
  80132b:	e8 a1 fd ff ff       	call   8010d1 <dev_lookup>
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	85 c0                	test   %eax,%eax
  801335:	78 27                	js     80135e <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  801337:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80133a:	8b 42 08             	mov    0x8(%edx),%eax
  80133d:	83 e0 03             	and    $0x3,%eax
  801340:	83 f8 01             	cmp    $0x1,%eax
  801343:	74 1e                	je     801363 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  801345:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801348:	8b 40 08             	mov    0x8(%eax),%eax
  80134b:	85 c0                	test   %eax,%eax
  80134d:	74 35                	je     801384 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80134f:	83 ec 04             	sub    $0x4,%esp
  801352:	ff 75 10             	pushl  0x10(%ebp)
  801355:	ff 75 0c             	pushl  0xc(%ebp)
  801358:	52                   	push   %edx
  801359:	ff d0                	call   *%eax
  80135b:	83 c4 10             	add    $0x10,%esp
}
  80135e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801361:	c9                   	leave  
  801362:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  801363:	a1 04 44 80 00       	mov    0x804404,%eax
  801368:	8b 40 48             	mov    0x48(%eax),%eax
  80136b:	83 ec 04             	sub    $0x4,%esp
  80136e:	53                   	push   %ebx
  80136f:	50                   	push   %eax
  801370:	68 9d 24 80 00       	push   $0x80249d
  801375:	e8 57 f0 ff ff       	call   8003d1 <cprintf>
		return -E_INVAL;
  80137a:	83 c4 10             	add    $0x10,%esp
  80137d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801382:	eb da                	jmp    80135e <read+0x5e>
		return -E_NOT_SUPP;
  801384:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801389:	eb d3                	jmp    80135e <read+0x5e>

0080138b <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80138b:	f3 0f 1e fb          	endbr32 
  80138f:	55                   	push   %ebp
  801390:	89 e5                	mov    %esp,%ebp
  801392:	57                   	push   %edi
  801393:	56                   	push   %esi
  801394:	53                   	push   %ebx
  801395:	83 ec 0c             	sub    $0xc,%esp
  801398:	8b 7d 08             	mov    0x8(%ebp),%edi
  80139b:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  80139e:	bb 00 00 00 00       	mov    $0x0,%ebx
  8013a3:	eb 02                	jmp    8013a7 <readn+0x1c>
  8013a5:	01 c3                	add    %eax,%ebx
  8013a7:	39 f3                	cmp    %esi,%ebx
  8013a9:	73 21                	jae    8013cc <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013ab:	83 ec 04             	sub    $0x4,%esp
  8013ae:	89 f0                	mov    %esi,%eax
  8013b0:	29 d8                	sub    %ebx,%eax
  8013b2:	50                   	push   %eax
  8013b3:	89 d8                	mov    %ebx,%eax
  8013b5:	03 45 0c             	add    0xc(%ebp),%eax
  8013b8:	50                   	push   %eax
  8013b9:	57                   	push   %edi
  8013ba:	e8 41 ff ff ff       	call   801300 <read>
		if (m < 0)
  8013bf:	83 c4 10             	add    $0x10,%esp
  8013c2:	85 c0                	test   %eax,%eax
  8013c4:	78 04                	js     8013ca <readn+0x3f>
			return m;
		if (m == 0)
  8013c6:	75 dd                	jne    8013a5 <readn+0x1a>
  8013c8:	eb 02                	jmp    8013cc <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8013ca:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8013cc:	89 d8                	mov    %ebx,%eax
  8013ce:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d1:	5b                   	pop    %ebx
  8013d2:	5e                   	pop    %esi
  8013d3:	5f                   	pop    %edi
  8013d4:	5d                   	pop    %ebp
  8013d5:	c3                   	ret    

008013d6 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8013d6:	f3 0f 1e fb          	endbr32 
  8013da:	55                   	push   %ebp
  8013db:	89 e5                	mov    %esp,%ebp
  8013dd:	53                   	push   %ebx
  8013de:	83 ec 1c             	sub    $0x1c,%esp
  8013e1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8013e4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8013e7:	50                   	push   %eax
  8013e8:	53                   	push   %ebx
  8013e9:	e8 8f fc ff ff       	call   80107d <fd_lookup>
  8013ee:	83 c4 10             	add    $0x10,%esp
  8013f1:	85 c0                	test   %eax,%eax
  8013f3:	78 3a                	js     80142f <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8013f5:	83 ec 08             	sub    $0x8,%esp
  8013f8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8013fb:	50                   	push   %eax
  8013fc:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8013ff:	ff 30                	pushl  (%eax)
  801401:	e8 cb fc ff ff       	call   8010d1 <dev_lookup>
  801406:	83 c4 10             	add    $0x10,%esp
  801409:	85 c0                	test   %eax,%eax
  80140b:	78 22                	js     80142f <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80140d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801410:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  801414:	74 1e                	je     801434 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  801416:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801419:	8b 52 0c             	mov    0xc(%edx),%edx
  80141c:	85 d2                	test   %edx,%edx
  80141e:	74 35                	je     801455 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801420:	83 ec 04             	sub    $0x4,%esp
  801423:	ff 75 10             	pushl  0x10(%ebp)
  801426:	ff 75 0c             	pushl  0xc(%ebp)
  801429:	50                   	push   %eax
  80142a:	ff d2                	call   *%edx
  80142c:	83 c4 10             	add    $0x10,%esp
}
  80142f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801432:	c9                   	leave  
  801433:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  801434:	a1 04 44 80 00       	mov    0x804404,%eax
  801439:	8b 40 48             	mov    0x48(%eax),%eax
  80143c:	83 ec 04             	sub    $0x4,%esp
  80143f:	53                   	push   %ebx
  801440:	50                   	push   %eax
  801441:	68 b9 24 80 00       	push   $0x8024b9
  801446:	e8 86 ef ff ff       	call   8003d1 <cprintf>
		return -E_INVAL;
  80144b:	83 c4 10             	add    $0x10,%esp
  80144e:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801453:	eb da                	jmp    80142f <write+0x59>
		return -E_NOT_SUPP;
  801455:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80145a:	eb d3                	jmp    80142f <write+0x59>

0080145c <seek>:

int
seek(int fdnum, off_t offset)
{
  80145c:	f3 0f 1e fb          	endbr32 
  801460:	55                   	push   %ebp
  801461:	89 e5                	mov    %esp,%ebp
  801463:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801466:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801469:	50                   	push   %eax
  80146a:	ff 75 08             	pushl  0x8(%ebp)
  80146d:	e8 0b fc ff ff       	call   80107d <fd_lookup>
  801472:	83 c4 10             	add    $0x10,%esp
  801475:	85 c0                	test   %eax,%eax
  801477:	78 0e                	js     801487 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  801479:	8b 55 0c             	mov    0xc(%ebp),%edx
  80147c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80147f:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  801482:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801487:	c9                   	leave  
  801488:	c3                   	ret    

00801489 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  801489:	f3 0f 1e fb          	endbr32 
  80148d:	55                   	push   %ebp
  80148e:	89 e5                	mov    %esp,%ebp
  801490:	53                   	push   %ebx
  801491:	83 ec 1c             	sub    $0x1c,%esp
  801494:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  801497:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80149a:	50                   	push   %eax
  80149b:	53                   	push   %ebx
  80149c:	e8 dc fb ff ff       	call   80107d <fd_lookup>
  8014a1:	83 c4 10             	add    $0x10,%esp
  8014a4:	85 c0                	test   %eax,%eax
  8014a6:	78 37                	js     8014df <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8014a8:	83 ec 08             	sub    $0x8,%esp
  8014ab:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8014ae:	50                   	push   %eax
  8014af:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014b2:	ff 30                	pushl  (%eax)
  8014b4:	e8 18 fc ff ff       	call   8010d1 <dev_lookup>
  8014b9:	83 c4 10             	add    $0x10,%esp
  8014bc:	85 c0                	test   %eax,%eax
  8014be:	78 1f                	js     8014df <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8014c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8014c3:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8014c7:	74 1b                	je     8014e4 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8014c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8014cc:	8b 52 18             	mov    0x18(%edx),%edx
  8014cf:	85 d2                	test   %edx,%edx
  8014d1:	74 32                	je     801505 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8014d3:	83 ec 08             	sub    $0x8,%esp
  8014d6:	ff 75 0c             	pushl  0xc(%ebp)
  8014d9:	50                   	push   %eax
  8014da:	ff d2                	call   *%edx
  8014dc:	83 c4 10             	add    $0x10,%esp
}
  8014df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8014e2:	c9                   	leave  
  8014e3:	c3                   	ret    
			thisenv->env_id, fdnum);
  8014e4:	a1 04 44 80 00       	mov    0x804404,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8014e9:	8b 40 48             	mov    0x48(%eax),%eax
  8014ec:	83 ec 04             	sub    $0x4,%esp
  8014ef:	53                   	push   %ebx
  8014f0:	50                   	push   %eax
  8014f1:	68 7c 24 80 00       	push   $0x80247c
  8014f6:	e8 d6 ee ff ff       	call   8003d1 <cprintf>
		return -E_INVAL;
  8014fb:	83 c4 10             	add    $0x10,%esp
  8014fe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801503:	eb da                	jmp    8014df <ftruncate+0x56>
		return -E_NOT_SUPP;
  801505:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80150a:	eb d3                	jmp    8014df <ftruncate+0x56>

0080150c <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80150c:	f3 0f 1e fb          	endbr32 
  801510:	55                   	push   %ebp
  801511:	89 e5                	mov    %esp,%ebp
  801513:	53                   	push   %ebx
  801514:	83 ec 1c             	sub    $0x1c,%esp
  801517:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80151a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80151d:	50                   	push   %eax
  80151e:	ff 75 08             	pushl  0x8(%ebp)
  801521:	e8 57 fb ff ff       	call   80107d <fd_lookup>
  801526:	83 c4 10             	add    $0x10,%esp
  801529:	85 c0                	test   %eax,%eax
  80152b:	78 4b                	js     801578 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80152d:	83 ec 08             	sub    $0x8,%esp
  801530:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801533:	50                   	push   %eax
  801534:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801537:	ff 30                	pushl  (%eax)
  801539:	e8 93 fb ff ff       	call   8010d1 <dev_lookup>
  80153e:	83 c4 10             	add    $0x10,%esp
  801541:	85 c0                	test   %eax,%eax
  801543:	78 33                	js     801578 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  801545:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801548:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80154c:	74 2f                	je     80157d <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80154e:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801551:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  801558:	00 00 00 
	stat->st_isdir = 0;
  80155b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801562:	00 00 00 
	stat->st_dev = dev;
  801565:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80156b:	83 ec 08             	sub    $0x8,%esp
  80156e:	53                   	push   %ebx
  80156f:	ff 75 f0             	pushl  -0x10(%ebp)
  801572:	ff 50 14             	call   *0x14(%eax)
  801575:	83 c4 10             	add    $0x10,%esp
}
  801578:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80157b:	c9                   	leave  
  80157c:	c3                   	ret    
		return -E_NOT_SUPP;
  80157d:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801582:	eb f4                	jmp    801578 <fstat+0x6c>

00801584 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  801584:	f3 0f 1e fb          	endbr32 
  801588:	55                   	push   %ebp
  801589:	89 e5                	mov    %esp,%ebp
  80158b:	56                   	push   %esi
  80158c:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  80158d:	83 ec 08             	sub    $0x8,%esp
  801590:	6a 00                	push   $0x0
  801592:	ff 75 08             	pushl  0x8(%ebp)
  801595:	e8 fb 01 00 00       	call   801795 <open>
  80159a:	89 c3                	mov    %eax,%ebx
  80159c:	83 c4 10             	add    $0x10,%esp
  80159f:	85 c0                	test   %eax,%eax
  8015a1:	78 1b                	js     8015be <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8015a3:	83 ec 08             	sub    $0x8,%esp
  8015a6:	ff 75 0c             	pushl  0xc(%ebp)
  8015a9:	50                   	push   %eax
  8015aa:	e8 5d ff ff ff       	call   80150c <fstat>
  8015af:	89 c6                	mov    %eax,%esi
	close(fd);
  8015b1:	89 1c 24             	mov    %ebx,(%esp)
  8015b4:	e8 fd fb ff ff       	call   8011b6 <close>
	return r;
  8015b9:	83 c4 10             	add    $0x10,%esp
  8015bc:	89 f3                	mov    %esi,%ebx
}
  8015be:	89 d8                	mov    %ebx,%eax
  8015c0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015c3:	5b                   	pop    %ebx
  8015c4:	5e                   	pop    %esi
  8015c5:	5d                   	pop    %ebp
  8015c6:	c3                   	ret    

008015c7 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8015c7:	55                   	push   %ebp
  8015c8:	89 e5                	mov    %esp,%ebp
  8015ca:	56                   	push   %esi
  8015cb:	53                   	push   %ebx
  8015cc:	89 c6                	mov    %eax,%esi
  8015ce:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8015d0:	83 3d 00 44 80 00 00 	cmpl   $0x0,0x804400
  8015d7:	74 27                	je     801600 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8015d9:	6a 07                	push   $0x7
  8015db:	68 00 50 80 00       	push   $0x805000
  8015e0:	56                   	push   %esi
  8015e1:	ff 35 00 44 80 00    	pushl  0x804400
  8015e7:	e8 4e 07 00 00       	call   801d3a <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8015ec:	83 c4 0c             	add    $0xc,%esp
  8015ef:	6a 00                	push   $0x0
  8015f1:	53                   	push   %ebx
  8015f2:	6a 00                	push   $0x0
  8015f4:	e8 d3 06 00 00       	call   801ccc <ipc_recv>
}
  8015f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8015fc:	5b                   	pop    %ebx
  8015fd:	5e                   	pop    %esi
  8015fe:	5d                   	pop    %ebp
  8015ff:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801600:	83 ec 0c             	sub    $0xc,%esp
  801603:	6a 01                	push   $0x1
  801605:	e8 95 07 00 00       	call   801d9f <ipc_find_env>
  80160a:	a3 00 44 80 00       	mov    %eax,0x804400
  80160f:	83 c4 10             	add    $0x10,%esp
  801612:	eb c5                	jmp    8015d9 <fsipc+0x12>

00801614 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801614:	f3 0f 1e fb          	endbr32 
  801618:	55                   	push   %ebp
  801619:	89 e5                	mov    %esp,%ebp
  80161b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80161e:	8b 45 08             	mov    0x8(%ebp),%eax
  801621:	8b 40 0c             	mov    0xc(%eax),%eax
  801624:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801629:	8b 45 0c             	mov    0xc(%ebp),%eax
  80162c:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801631:	ba 00 00 00 00       	mov    $0x0,%edx
  801636:	b8 02 00 00 00       	mov    $0x2,%eax
  80163b:	e8 87 ff ff ff       	call   8015c7 <fsipc>
}
  801640:	c9                   	leave  
  801641:	c3                   	ret    

00801642 <devfile_flush>:
{
  801642:	f3 0f 1e fb          	endbr32 
  801646:	55                   	push   %ebp
  801647:	89 e5                	mov    %esp,%ebp
  801649:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80164c:	8b 45 08             	mov    0x8(%ebp),%eax
  80164f:	8b 40 0c             	mov    0xc(%eax),%eax
  801652:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801657:	ba 00 00 00 00       	mov    $0x0,%edx
  80165c:	b8 06 00 00 00       	mov    $0x6,%eax
  801661:	e8 61 ff ff ff       	call   8015c7 <fsipc>
}
  801666:	c9                   	leave  
  801667:	c3                   	ret    

00801668 <devfile_stat>:
{
  801668:	f3 0f 1e fb          	endbr32 
  80166c:	55                   	push   %ebp
  80166d:	89 e5                	mov    %esp,%ebp
  80166f:	53                   	push   %ebx
  801670:	83 ec 04             	sub    $0x4,%esp
  801673:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801676:	8b 45 08             	mov    0x8(%ebp),%eax
  801679:	8b 40 0c             	mov    0xc(%eax),%eax
  80167c:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801681:	ba 00 00 00 00       	mov    $0x0,%edx
  801686:	b8 05 00 00 00       	mov    $0x5,%eax
  80168b:	e8 37 ff ff ff       	call   8015c7 <fsipc>
  801690:	85 c0                	test   %eax,%eax
  801692:	78 2c                	js     8016c0 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801694:	83 ec 08             	sub    $0x8,%esp
  801697:	68 00 50 80 00       	push   $0x805000
  80169c:	53                   	push   %ebx
  80169d:	e8 8d f3 ff ff       	call   800a2f <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8016a2:	a1 80 50 80 00       	mov    0x805080,%eax
  8016a7:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8016ad:	a1 84 50 80 00       	mov    0x805084,%eax
  8016b2:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8016b8:	83 c4 10             	add    $0x10,%esp
  8016bb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8016c0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016c3:	c9                   	leave  
  8016c4:	c3                   	ret    

008016c5 <devfile_write>:
{
  8016c5:	f3 0f 1e fb          	endbr32 
  8016c9:	55                   	push   %ebp
  8016ca:	89 e5                	mov    %esp,%ebp
  8016cc:	83 ec 0c             	sub    $0xc,%esp
  8016cf:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8016d2:	8b 55 08             	mov    0x8(%ebp),%edx
  8016d5:	8b 52 0c             	mov    0xc(%edx),%edx
  8016d8:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8016de:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8016e3:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8016e8:	0f 47 c2             	cmova  %edx,%eax
  8016eb:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8016f0:	50                   	push   %eax
  8016f1:	ff 75 0c             	pushl  0xc(%ebp)
  8016f4:	68 08 50 80 00       	push   $0x805008
  8016f9:	e8 e9 f4 ff ff       	call   800be7 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  8016fe:	ba 00 00 00 00       	mov    $0x0,%edx
  801703:	b8 04 00 00 00       	mov    $0x4,%eax
  801708:	e8 ba fe ff ff       	call   8015c7 <fsipc>
}
  80170d:	c9                   	leave  
  80170e:	c3                   	ret    

0080170f <devfile_read>:
{
  80170f:	f3 0f 1e fb          	endbr32 
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	56                   	push   %esi
  801717:	53                   	push   %ebx
  801718:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  80171b:	8b 45 08             	mov    0x8(%ebp),%eax
  80171e:	8b 40 0c             	mov    0xc(%eax),%eax
  801721:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801726:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  80172c:	ba 00 00 00 00       	mov    $0x0,%edx
  801731:	b8 03 00 00 00       	mov    $0x3,%eax
  801736:	e8 8c fe ff ff       	call   8015c7 <fsipc>
  80173b:	89 c3                	mov    %eax,%ebx
  80173d:	85 c0                	test   %eax,%eax
  80173f:	78 1f                	js     801760 <devfile_read+0x51>
	assert(r <= n);
  801741:	39 f0                	cmp    %esi,%eax
  801743:	77 24                	ja     801769 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801745:	3d 00 10 00 00       	cmp    $0x1000,%eax
  80174a:	7f 33                	jg     80177f <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  80174c:	83 ec 04             	sub    $0x4,%esp
  80174f:	50                   	push   %eax
  801750:	68 00 50 80 00       	push   $0x805000
  801755:	ff 75 0c             	pushl  0xc(%ebp)
  801758:	e8 8a f4 ff ff       	call   800be7 <memmove>
	return r;
  80175d:	83 c4 10             	add    $0x10,%esp
}
  801760:	89 d8                	mov    %ebx,%eax
  801762:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801765:	5b                   	pop    %ebx
  801766:	5e                   	pop    %esi
  801767:	5d                   	pop    %ebp
  801768:	c3                   	ret    
	assert(r <= n);
  801769:	68 e8 24 80 00       	push   $0x8024e8
  80176e:	68 ef 24 80 00       	push   $0x8024ef
  801773:	6a 7c                	push   $0x7c
  801775:	68 04 25 80 00       	push   $0x802504
  80177a:	e8 6b eb ff ff       	call   8002ea <_panic>
	assert(r <= PGSIZE);
  80177f:	68 0f 25 80 00       	push   $0x80250f
  801784:	68 ef 24 80 00       	push   $0x8024ef
  801789:	6a 7d                	push   $0x7d
  80178b:	68 04 25 80 00       	push   $0x802504
  801790:	e8 55 eb ff ff       	call   8002ea <_panic>

00801795 <open>:
{
  801795:	f3 0f 1e fb          	endbr32 
  801799:	55                   	push   %ebp
  80179a:	89 e5                	mov    %esp,%ebp
  80179c:	56                   	push   %esi
  80179d:	53                   	push   %ebx
  80179e:	83 ec 1c             	sub    $0x1c,%esp
  8017a1:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8017a4:	56                   	push   %esi
  8017a5:	e8 42 f2 ff ff       	call   8009ec <strlen>
  8017aa:	83 c4 10             	add    $0x10,%esp
  8017ad:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8017b2:	7f 6c                	jg     801820 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8017b4:	83 ec 0c             	sub    $0xc,%esp
  8017b7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8017ba:	50                   	push   %eax
  8017bb:	e8 67 f8 ff ff       	call   801027 <fd_alloc>
  8017c0:	89 c3                	mov    %eax,%ebx
  8017c2:	83 c4 10             	add    $0x10,%esp
  8017c5:	85 c0                	test   %eax,%eax
  8017c7:	78 3c                	js     801805 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  8017c9:	83 ec 08             	sub    $0x8,%esp
  8017cc:	56                   	push   %esi
  8017cd:	68 00 50 80 00       	push   $0x805000
  8017d2:	e8 58 f2 ff ff       	call   800a2f <strcpy>
	fsipcbuf.open.req_omode = mode;
  8017d7:	8b 45 0c             	mov    0xc(%ebp),%eax
  8017da:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  8017df:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8017e2:	b8 01 00 00 00       	mov    $0x1,%eax
  8017e7:	e8 db fd ff ff       	call   8015c7 <fsipc>
  8017ec:	89 c3                	mov    %eax,%ebx
  8017ee:	83 c4 10             	add    $0x10,%esp
  8017f1:	85 c0                	test   %eax,%eax
  8017f3:	78 19                	js     80180e <open+0x79>
	return fd2num(fd);
  8017f5:	83 ec 0c             	sub    $0xc,%esp
  8017f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8017fb:	e8 f4 f7 ff ff       	call   800ff4 <fd2num>
  801800:	89 c3                	mov    %eax,%ebx
  801802:	83 c4 10             	add    $0x10,%esp
}
  801805:	89 d8                	mov    %ebx,%eax
  801807:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80180a:	5b                   	pop    %ebx
  80180b:	5e                   	pop    %esi
  80180c:	5d                   	pop    %ebp
  80180d:	c3                   	ret    
		fd_close(fd, 0);
  80180e:	83 ec 08             	sub    $0x8,%esp
  801811:	6a 00                	push   $0x0
  801813:	ff 75 f4             	pushl  -0xc(%ebp)
  801816:	e8 10 f9 ff ff       	call   80112b <fd_close>
		return r;
  80181b:	83 c4 10             	add    $0x10,%esp
  80181e:	eb e5                	jmp    801805 <open+0x70>
		return -E_BAD_PATH;
  801820:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801825:	eb de                	jmp    801805 <open+0x70>

00801827 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801827:	f3 0f 1e fb          	endbr32 
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801831:	ba 00 00 00 00       	mov    $0x0,%edx
  801836:	b8 08 00 00 00       	mov    $0x8,%eax
  80183b:	e8 87 fd ff ff       	call   8015c7 <fsipc>
}
  801840:	c9                   	leave  
  801841:	c3                   	ret    

00801842 <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  801842:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  801846:	7f 01                	jg     801849 <writebuf+0x7>
  801848:	c3                   	ret    
{
  801849:	55                   	push   %ebp
  80184a:	89 e5                	mov    %esp,%ebp
  80184c:	53                   	push   %ebx
  80184d:	83 ec 08             	sub    $0x8,%esp
  801850:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  801852:	ff 70 04             	pushl  0x4(%eax)
  801855:	8d 40 10             	lea    0x10(%eax),%eax
  801858:	50                   	push   %eax
  801859:	ff 33                	pushl  (%ebx)
  80185b:	e8 76 fb ff ff       	call   8013d6 <write>
		if (result > 0)
  801860:	83 c4 10             	add    $0x10,%esp
  801863:	85 c0                	test   %eax,%eax
  801865:	7e 03                	jle    80186a <writebuf+0x28>
			b->result += result;
  801867:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  80186a:	39 43 04             	cmp    %eax,0x4(%ebx)
  80186d:	74 0d                	je     80187c <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  80186f:	85 c0                	test   %eax,%eax
  801871:	ba 00 00 00 00       	mov    $0x0,%edx
  801876:	0f 4f c2             	cmovg  %edx,%eax
  801879:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  80187c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80187f:	c9                   	leave  
  801880:	c3                   	ret    

00801881 <putch>:

static void
putch(int ch, void *thunk)
{
  801881:	f3 0f 1e fb          	endbr32 
  801885:	55                   	push   %ebp
  801886:	89 e5                	mov    %esp,%ebp
  801888:	53                   	push   %ebx
  801889:	83 ec 04             	sub    $0x4,%esp
  80188c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  80188f:	8b 53 04             	mov    0x4(%ebx),%edx
  801892:	8d 42 01             	lea    0x1(%edx),%eax
  801895:	89 43 04             	mov    %eax,0x4(%ebx)
  801898:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80189b:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  80189f:	3d 00 01 00 00       	cmp    $0x100,%eax
  8018a4:	74 06                	je     8018ac <putch+0x2b>
		writebuf(b);
		b->idx = 0;
	}
}
  8018a6:	83 c4 04             	add    $0x4,%esp
  8018a9:	5b                   	pop    %ebx
  8018aa:	5d                   	pop    %ebp
  8018ab:	c3                   	ret    
		writebuf(b);
  8018ac:	89 d8                	mov    %ebx,%eax
  8018ae:	e8 8f ff ff ff       	call   801842 <writebuf>
		b->idx = 0;
  8018b3:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  8018ba:	eb ea                	jmp    8018a6 <putch+0x25>

008018bc <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8018bc:	f3 0f 1e fb          	endbr32 
  8018c0:	55                   	push   %ebp
  8018c1:	89 e5                	mov    %esp,%ebp
  8018c3:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  8018c9:	8b 45 08             	mov    0x8(%ebp),%eax
  8018cc:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  8018d2:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  8018d9:	00 00 00 
	b.result = 0;
  8018dc:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8018e3:	00 00 00 
	b.error = 1;
  8018e6:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  8018ed:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  8018f0:	ff 75 10             	pushl  0x10(%ebp)
  8018f3:	ff 75 0c             	pushl  0xc(%ebp)
  8018f6:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  8018fc:	50                   	push   %eax
  8018fd:	68 81 18 80 00       	push   $0x801881
  801902:	e8 2d ec ff ff       	call   800534 <vprintfmt>
	if (b.idx > 0)
  801907:	83 c4 10             	add    $0x10,%esp
  80190a:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  801911:	7f 11                	jg     801924 <vfprintf+0x68>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  801913:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  801919:	85 c0                	test   %eax,%eax
  80191b:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  801922:	c9                   	leave  
  801923:	c3                   	ret    
		writebuf(&b);
  801924:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  80192a:	e8 13 ff ff ff       	call   801842 <writebuf>
  80192f:	eb e2                	jmp    801913 <vfprintf+0x57>

00801931 <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  801931:	f3 0f 1e fb          	endbr32 
  801935:	55                   	push   %ebp
  801936:	89 e5                	mov    %esp,%ebp
  801938:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80193b:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  80193e:	50                   	push   %eax
  80193f:	ff 75 0c             	pushl  0xc(%ebp)
  801942:	ff 75 08             	pushl  0x8(%ebp)
  801945:	e8 72 ff ff ff       	call   8018bc <vfprintf>
	va_end(ap);

	return cnt;
}
  80194a:	c9                   	leave  
  80194b:	c3                   	ret    

0080194c <printf>:

int
printf(const char *fmt, ...)
{
  80194c:	f3 0f 1e fb          	endbr32 
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801956:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  801959:	50                   	push   %eax
  80195a:	ff 75 08             	pushl  0x8(%ebp)
  80195d:	6a 01                	push   $0x1
  80195f:	e8 58 ff ff ff       	call   8018bc <vfprintf>
	va_end(ap);

	return cnt;
}
  801964:	c9                   	leave  
  801965:	c3                   	ret    

00801966 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801966:	f3 0f 1e fb          	endbr32 
  80196a:	55                   	push   %ebp
  80196b:	89 e5                	mov    %esp,%ebp
  80196d:	56                   	push   %esi
  80196e:	53                   	push   %ebx
  80196f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801972:	83 ec 0c             	sub    $0xc,%esp
  801975:	ff 75 08             	pushl  0x8(%ebp)
  801978:	e8 8b f6 ff ff       	call   801008 <fd2data>
  80197d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  80197f:	83 c4 08             	add    $0x8,%esp
  801982:	68 1b 25 80 00       	push   $0x80251b
  801987:	53                   	push   %ebx
  801988:	e8 a2 f0 ff ff       	call   800a2f <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  80198d:	8b 46 04             	mov    0x4(%esi),%eax
  801990:	2b 06                	sub    (%esi),%eax
  801992:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801998:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80199f:	00 00 00 
	stat->st_dev = &devpipe;
  8019a2:	c7 83 88 00 00 00 3c 	movl   $0x80303c,0x88(%ebx)
  8019a9:	30 80 00 
	return 0;
}
  8019ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019b4:	5b                   	pop    %ebx
  8019b5:	5e                   	pop    %esi
  8019b6:	5d                   	pop    %ebp
  8019b7:	c3                   	ret    

008019b8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  8019b8:	f3 0f 1e fb          	endbr32 
  8019bc:	55                   	push   %ebp
  8019bd:	89 e5                	mov    %esp,%ebp
  8019bf:	53                   	push   %ebx
  8019c0:	83 ec 0c             	sub    $0xc,%esp
  8019c3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  8019c6:	53                   	push   %ebx
  8019c7:	6a 00                	push   $0x0
  8019c9:	e8 3b f5 ff ff       	call   800f09 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  8019ce:	89 1c 24             	mov    %ebx,(%esp)
  8019d1:	e8 32 f6 ff ff       	call   801008 <fd2data>
  8019d6:	83 c4 08             	add    $0x8,%esp
  8019d9:	50                   	push   %eax
  8019da:	6a 00                	push   $0x0
  8019dc:	e8 28 f5 ff ff       	call   800f09 <sys_page_unmap>
}
  8019e1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019e4:	c9                   	leave  
  8019e5:	c3                   	ret    

008019e6 <_pipeisclosed>:
{
  8019e6:	55                   	push   %ebp
  8019e7:	89 e5                	mov    %esp,%ebp
  8019e9:	57                   	push   %edi
  8019ea:	56                   	push   %esi
  8019eb:	53                   	push   %ebx
  8019ec:	83 ec 1c             	sub    $0x1c,%esp
  8019ef:	89 c7                	mov    %eax,%edi
  8019f1:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  8019f3:	a1 04 44 80 00       	mov    0x804404,%eax
  8019f8:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  8019fb:	83 ec 0c             	sub    $0xc,%esp
  8019fe:	57                   	push   %edi
  8019ff:	e8 d8 03 00 00       	call   801ddc <pageref>
  801a04:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801a07:	89 34 24             	mov    %esi,(%esp)
  801a0a:	e8 cd 03 00 00       	call   801ddc <pageref>
		nn = thisenv->env_runs;
  801a0f:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801a15:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801a18:	83 c4 10             	add    $0x10,%esp
  801a1b:	39 cb                	cmp    %ecx,%ebx
  801a1d:	74 1b                	je     801a3a <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801a1f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a22:	75 cf                	jne    8019f3 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801a24:	8b 42 58             	mov    0x58(%edx),%eax
  801a27:	6a 01                	push   $0x1
  801a29:	50                   	push   %eax
  801a2a:	53                   	push   %ebx
  801a2b:	68 22 25 80 00       	push   $0x802522
  801a30:	e8 9c e9 ff ff       	call   8003d1 <cprintf>
  801a35:	83 c4 10             	add    $0x10,%esp
  801a38:	eb b9                	jmp    8019f3 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801a3a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801a3d:	0f 94 c0             	sete   %al
  801a40:	0f b6 c0             	movzbl %al,%eax
}
  801a43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801a46:	5b                   	pop    %ebx
  801a47:	5e                   	pop    %esi
  801a48:	5f                   	pop    %edi
  801a49:	5d                   	pop    %ebp
  801a4a:	c3                   	ret    

00801a4b <devpipe_write>:
{
  801a4b:	f3 0f 1e fb          	endbr32 
  801a4f:	55                   	push   %ebp
  801a50:	89 e5                	mov    %esp,%ebp
  801a52:	57                   	push   %edi
  801a53:	56                   	push   %esi
  801a54:	53                   	push   %ebx
  801a55:	83 ec 28             	sub    $0x28,%esp
  801a58:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801a5b:	56                   	push   %esi
  801a5c:	e8 a7 f5 ff ff       	call   801008 <fd2data>
  801a61:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801a63:	83 c4 10             	add    $0x10,%esp
  801a66:	bf 00 00 00 00       	mov    $0x0,%edi
  801a6b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801a6e:	74 4f                	je     801abf <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801a70:	8b 43 04             	mov    0x4(%ebx),%eax
  801a73:	8b 0b                	mov    (%ebx),%ecx
  801a75:	8d 51 20             	lea    0x20(%ecx),%edx
  801a78:	39 d0                	cmp    %edx,%eax
  801a7a:	72 14                	jb     801a90 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801a7c:	89 da                	mov    %ebx,%edx
  801a7e:	89 f0                	mov    %esi,%eax
  801a80:	e8 61 ff ff ff       	call   8019e6 <_pipeisclosed>
  801a85:	85 c0                	test   %eax,%eax
  801a87:	75 3b                	jne    801ac4 <devpipe_write+0x79>
			sys_yield();
  801a89:	e8 fe f3 ff ff       	call   800e8c <sys_yield>
  801a8e:	eb e0                	jmp    801a70 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801a90:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801a93:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801a97:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801a9a:	89 c2                	mov    %eax,%edx
  801a9c:	c1 fa 1f             	sar    $0x1f,%edx
  801a9f:	89 d1                	mov    %edx,%ecx
  801aa1:	c1 e9 1b             	shr    $0x1b,%ecx
  801aa4:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801aa7:	83 e2 1f             	and    $0x1f,%edx
  801aaa:	29 ca                	sub    %ecx,%edx
  801aac:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801ab0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801ab4:	83 c0 01             	add    $0x1,%eax
  801ab7:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801aba:	83 c7 01             	add    $0x1,%edi
  801abd:	eb ac                	jmp    801a6b <devpipe_write+0x20>
	return i;
  801abf:	8b 45 10             	mov    0x10(%ebp),%eax
  801ac2:	eb 05                	jmp    801ac9 <devpipe_write+0x7e>
				return 0;
  801ac4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ac9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801acc:	5b                   	pop    %ebx
  801acd:	5e                   	pop    %esi
  801ace:	5f                   	pop    %edi
  801acf:	5d                   	pop    %ebp
  801ad0:	c3                   	ret    

00801ad1 <devpipe_read>:
{
  801ad1:	f3 0f 1e fb          	endbr32 
  801ad5:	55                   	push   %ebp
  801ad6:	89 e5                	mov    %esp,%ebp
  801ad8:	57                   	push   %edi
  801ad9:	56                   	push   %esi
  801ada:	53                   	push   %ebx
  801adb:	83 ec 18             	sub    $0x18,%esp
  801ade:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801ae1:	57                   	push   %edi
  801ae2:	e8 21 f5 ff ff       	call   801008 <fd2data>
  801ae7:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801ae9:	83 c4 10             	add    $0x10,%esp
  801aec:	be 00 00 00 00       	mov    $0x0,%esi
  801af1:	3b 75 10             	cmp    0x10(%ebp),%esi
  801af4:	75 14                	jne    801b0a <devpipe_read+0x39>
	return i;
  801af6:	8b 45 10             	mov    0x10(%ebp),%eax
  801af9:	eb 02                	jmp    801afd <devpipe_read+0x2c>
				return i;
  801afb:	89 f0                	mov    %esi,%eax
}
  801afd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b00:	5b                   	pop    %ebx
  801b01:	5e                   	pop    %esi
  801b02:	5f                   	pop    %edi
  801b03:	5d                   	pop    %ebp
  801b04:	c3                   	ret    
			sys_yield();
  801b05:	e8 82 f3 ff ff       	call   800e8c <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801b0a:	8b 03                	mov    (%ebx),%eax
  801b0c:	3b 43 04             	cmp    0x4(%ebx),%eax
  801b0f:	75 18                	jne    801b29 <devpipe_read+0x58>
			if (i > 0)
  801b11:	85 f6                	test   %esi,%esi
  801b13:	75 e6                	jne    801afb <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801b15:	89 da                	mov    %ebx,%edx
  801b17:	89 f8                	mov    %edi,%eax
  801b19:	e8 c8 fe ff ff       	call   8019e6 <_pipeisclosed>
  801b1e:	85 c0                	test   %eax,%eax
  801b20:	74 e3                	je     801b05 <devpipe_read+0x34>
				return 0;
  801b22:	b8 00 00 00 00       	mov    $0x0,%eax
  801b27:	eb d4                	jmp    801afd <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801b29:	99                   	cltd   
  801b2a:	c1 ea 1b             	shr    $0x1b,%edx
  801b2d:	01 d0                	add    %edx,%eax
  801b2f:	83 e0 1f             	and    $0x1f,%eax
  801b32:	29 d0                	sub    %edx,%eax
  801b34:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801b39:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801b3c:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801b3f:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801b42:	83 c6 01             	add    $0x1,%esi
  801b45:	eb aa                	jmp    801af1 <devpipe_read+0x20>

00801b47 <pipe>:
{
  801b47:	f3 0f 1e fb          	endbr32 
  801b4b:	55                   	push   %ebp
  801b4c:	89 e5                	mov    %esp,%ebp
  801b4e:	56                   	push   %esi
  801b4f:	53                   	push   %ebx
  801b50:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801b53:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801b56:	50                   	push   %eax
  801b57:	e8 cb f4 ff ff       	call   801027 <fd_alloc>
  801b5c:	89 c3                	mov    %eax,%ebx
  801b5e:	83 c4 10             	add    $0x10,%esp
  801b61:	85 c0                	test   %eax,%eax
  801b63:	0f 88 23 01 00 00    	js     801c8c <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801b69:	83 ec 04             	sub    $0x4,%esp
  801b6c:	68 07 04 00 00       	push   $0x407
  801b71:	ff 75 f4             	pushl  -0xc(%ebp)
  801b74:	6a 00                	push   $0x0
  801b76:	e8 3c f3 ff ff       	call   800eb7 <sys_page_alloc>
  801b7b:	89 c3                	mov    %eax,%ebx
  801b7d:	83 c4 10             	add    $0x10,%esp
  801b80:	85 c0                	test   %eax,%eax
  801b82:	0f 88 04 01 00 00    	js     801c8c <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801b88:	83 ec 0c             	sub    $0xc,%esp
  801b8b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801b8e:	50                   	push   %eax
  801b8f:	e8 93 f4 ff ff       	call   801027 <fd_alloc>
  801b94:	89 c3                	mov    %eax,%ebx
  801b96:	83 c4 10             	add    $0x10,%esp
  801b99:	85 c0                	test   %eax,%eax
  801b9b:	0f 88 db 00 00 00    	js     801c7c <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ba1:	83 ec 04             	sub    $0x4,%esp
  801ba4:	68 07 04 00 00       	push   $0x407
  801ba9:	ff 75 f0             	pushl  -0x10(%ebp)
  801bac:	6a 00                	push   $0x0
  801bae:	e8 04 f3 ff ff       	call   800eb7 <sys_page_alloc>
  801bb3:	89 c3                	mov    %eax,%ebx
  801bb5:	83 c4 10             	add    $0x10,%esp
  801bb8:	85 c0                	test   %eax,%eax
  801bba:	0f 88 bc 00 00 00    	js     801c7c <pipe+0x135>
	va = fd2data(fd0);
  801bc0:	83 ec 0c             	sub    $0xc,%esp
  801bc3:	ff 75 f4             	pushl  -0xc(%ebp)
  801bc6:	e8 3d f4 ff ff       	call   801008 <fd2data>
  801bcb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bcd:	83 c4 0c             	add    $0xc,%esp
  801bd0:	68 07 04 00 00       	push   $0x407
  801bd5:	50                   	push   %eax
  801bd6:	6a 00                	push   $0x0
  801bd8:	e8 da f2 ff ff       	call   800eb7 <sys_page_alloc>
  801bdd:	89 c3                	mov    %eax,%ebx
  801bdf:	83 c4 10             	add    $0x10,%esp
  801be2:	85 c0                	test   %eax,%eax
  801be4:	0f 88 82 00 00 00    	js     801c6c <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801bea:	83 ec 0c             	sub    $0xc,%esp
  801bed:	ff 75 f0             	pushl  -0x10(%ebp)
  801bf0:	e8 13 f4 ff ff       	call   801008 <fd2data>
  801bf5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801bfc:	50                   	push   %eax
  801bfd:	6a 00                	push   $0x0
  801bff:	56                   	push   %esi
  801c00:	6a 00                	push   $0x0
  801c02:	e8 d8 f2 ff ff       	call   800edf <sys_page_map>
  801c07:	89 c3                	mov    %eax,%ebx
  801c09:	83 c4 20             	add    $0x20,%esp
  801c0c:	85 c0                	test   %eax,%eax
  801c0e:	78 4e                	js     801c5e <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801c10:	a1 3c 30 80 00       	mov    0x80303c,%eax
  801c15:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c18:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801c1a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c1d:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801c24:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801c27:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801c29:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801c2c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801c33:	83 ec 0c             	sub    $0xc,%esp
  801c36:	ff 75 f4             	pushl  -0xc(%ebp)
  801c39:	e8 b6 f3 ff ff       	call   800ff4 <fd2num>
  801c3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c41:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801c43:	83 c4 04             	add    $0x4,%esp
  801c46:	ff 75 f0             	pushl  -0x10(%ebp)
  801c49:	e8 a6 f3 ff ff       	call   800ff4 <fd2num>
  801c4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801c51:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801c54:	83 c4 10             	add    $0x10,%esp
  801c57:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c5c:	eb 2e                	jmp    801c8c <pipe+0x145>
	sys_page_unmap(0, va);
  801c5e:	83 ec 08             	sub    $0x8,%esp
  801c61:	56                   	push   %esi
  801c62:	6a 00                	push   $0x0
  801c64:	e8 a0 f2 ff ff       	call   800f09 <sys_page_unmap>
  801c69:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801c6c:	83 ec 08             	sub    $0x8,%esp
  801c6f:	ff 75 f0             	pushl  -0x10(%ebp)
  801c72:	6a 00                	push   $0x0
  801c74:	e8 90 f2 ff ff       	call   800f09 <sys_page_unmap>
  801c79:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801c7c:	83 ec 08             	sub    $0x8,%esp
  801c7f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c82:	6a 00                	push   $0x0
  801c84:	e8 80 f2 ff ff       	call   800f09 <sys_page_unmap>
  801c89:	83 c4 10             	add    $0x10,%esp
}
  801c8c:	89 d8                	mov    %ebx,%eax
  801c8e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c91:	5b                   	pop    %ebx
  801c92:	5e                   	pop    %esi
  801c93:	5d                   	pop    %ebp
  801c94:	c3                   	ret    

00801c95 <pipeisclosed>:
{
  801c95:	f3 0f 1e fb          	endbr32 
  801c99:	55                   	push   %ebp
  801c9a:	89 e5                	mov    %esp,%ebp
  801c9c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801c9f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ca2:	50                   	push   %eax
  801ca3:	ff 75 08             	pushl  0x8(%ebp)
  801ca6:	e8 d2 f3 ff ff       	call   80107d <fd_lookup>
  801cab:	83 c4 10             	add    $0x10,%esp
  801cae:	85 c0                	test   %eax,%eax
  801cb0:	78 18                	js     801cca <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801cb2:	83 ec 0c             	sub    $0xc,%esp
  801cb5:	ff 75 f4             	pushl  -0xc(%ebp)
  801cb8:	e8 4b f3 ff ff       	call   801008 <fd2data>
  801cbd:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801cbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801cc2:	e8 1f fd ff ff       	call   8019e6 <_pipeisclosed>
  801cc7:	83 c4 10             	add    $0x10,%esp
}
  801cca:	c9                   	leave  
  801ccb:	c3                   	ret    

00801ccc <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801ccc:	f3 0f 1e fb          	endbr32 
  801cd0:	55                   	push   %ebp
  801cd1:	89 e5                	mov    %esp,%ebp
  801cd3:	56                   	push   %esi
  801cd4:	53                   	push   %ebx
  801cd5:	8b 75 08             	mov    0x8(%ebp),%esi
  801cd8:	8b 45 0c             	mov    0xc(%ebp),%eax
  801cdb:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  801cde:	85 c0                	test   %eax,%eax
  801ce0:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801ce5:	0f 44 c2             	cmove  %edx,%eax
  801ce8:	83 ec 0c             	sub    $0xc,%esp
  801ceb:	50                   	push   %eax
  801cec:	e8 dd f2 ff ff       	call   800fce <sys_ipc_recv>

	if (from_env_store != NULL)
  801cf1:	83 c4 10             	add    $0x10,%esp
  801cf4:	85 f6                	test   %esi,%esi
  801cf6:	74 15                	je     801d0d <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  801cf8:	ba 00 00 00 00       	mov    $0x0,%edx
  801cfd:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801d00:	74 09                	je     801d0b <ipc_recv+0x3f>
  801d02:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801d08:	8b 52 74             	mov    0x74(%edx),%edx
  801d0b:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  801d0d:	85 db                	test   %ebx,%ebx
  801d0f:	74 15                	je     801d26 <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  801d11:	ba 00 00 00 00       	mov    $0x0,%edx
  801d16:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801d19:	74 09                	je     801d24 <ipc_recv+0x58>
  801d1b:	8b 15 04 44 80 00    	mov    0x804404,%edx
  801d21:	8b 52 78             	mov    0x78(%edx),%edx
  801d24:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  801d26:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801d29:	74 08                	je     801d33 <ipc_recv+0x67>
  801d2b:	a1 04 44 80 00       	mov    0x804404,%eax
  801d30:	8b 40 70             	mov    0x70(%eax),%eax
}
  801d33:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801d36:	5b                   	pop    %ebx
  801d37:	5e                   	pop    %esi
  801d38:	5d                   	pop    %ebp
  801d39:	c3                   	ret    

00801d3a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801d3a:	f3 0f 1e fb          	endbr32 
  801d3e:	55                   	push   %ebp
  801d3f:	89 e5                	mov    %esp,%ebp
  801d41:	57                   	push   %edi
  801d42:	56                   	push   %esi
  801d43:	53                   	push   %ebx
  801d44:	83 ec 0c             	sub    $0xc,%esp
  801d47:	8b 7d 08             	mov    0x8(%ebp),%edi
  801d4a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801d4d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801d50:	eb 1f                	jmp    801d71 <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  801d52:	6a 00                	push   $0x0
  801d54:	68 00 00 c0 ee       	push   $0xeec00000
  801d59:	56                   	push   %esi
  801d5a:	57                   	push   %edi
  801d5b:	e8 45 f2 ff ff       	call   800fa5 <sys_ipc_try_send>
  801d60:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  801d63:	85 c0                	test   %eax,%eax
  801d65:	74 30                	je     801d97 <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  801d67:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801d6a:	75 19                	jne    801d85 <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  801d6c:	e8 1b f1 ff ff       	call   800e8c <sys_yield>
		if (pg != NULL) {
  801d71:	85 db                	test   %ebx,%ebx
  801d73:	74 dd                	je     801d52 <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  801d75:	ff 75 14             	pushl  0x14(%ebp)
  801d78:	53                   	push   %ebx
  801d79:	56                   	push   %esi
  801d7a:	57                   	push   %edi
  801d7b:	e8 25 f2 ff ff       	call   800fa5 <sys_ipc_try_send>
  801d80:	83 c4 10             	add    $0x10,%esp
  801d83:	eb de                	jmp    801d63 <ipc_send+0x29>
			panic("ipc_send: %d", res);
  801d85:	50                   	push   %eax
  801d86:	68 3a 25 80 00       	push   $0x80253a
  801d8b:	6a 3e                	push   $0x3e
  801d8d:	68 47 25 80 00       	push   $0x802547
  801d92:	e8 53 e5 ff ff       	call   8002ea <_panic>
	}
}
  801d97:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d9a:	5b                   	pop    %ebx
  801d9b:	5e                   	pop    %esi
  801d9c:	5f                   	pop    %edi
  801d9d:	5d                   	pop    %ebp
  801d9e:	c3                   	ret    

00801d9f <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801d9f:	f3 0f 1e fb          	endbr32 
  801da3:	55                   	push   %ebp
  801da4:	89 e5                	mov    %esp,%ebp
  801da6:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801da9:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801dae:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801db1:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801db7:	8b 52 50             	mov    0x50(%edx),%edx
  801dba:	39 ca                	cmp    %ecx,%edx
  801dbc:	74 11                	je     801dcf <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801dbe:	83 c0 01             	add    $0x1,%eax
  801dc1:	3d 00 04 00 00       	cmp    $0x400,%eax
  801dc6:	75 e6                	jne    801dae <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801dc8:	b8 00 00 00 00       	mov    $0x0,%eax
  801dcd:	eb 0b                	jmp    801dda <ipc_find_env+0x3b>
			return envs[i].env_id;
  801dcf:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801dd2:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801dd7:	8b 40 48             	mov    0x48(%eax),%eax
}
  801dda:	5d                   	pop    %ebp
  801ddb:	c3                   	ret    

00801ddc <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801ddc:	f3 0f 1e fb          	endbr32 
  801de0:	55                   	push   %ebp
  801de1:	89 e5                	mov    %esp,%ebp
  801de3:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801de6:	89 c2                	mov    %eax,%edx
  801de8:	c1 ea 16             	shr    $0x16,%edx
  801deb:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801df2:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801df7:	f6 c1 01             	test   $0x1,%cl
  801dfa:	74 1c                	je     801e18 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801dfc:	c1 e8 0c             	shr    $0xc,%eax
  801dff:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801e06:	a8 01                	test   $0x1,%al
  801e08:	74 0e                	je     801e18 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801e0a:	c1 e8 0c             	shr    $0xc,%eax
  801e0d:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801e14:	ef 
  801e15:	0f b7 d2             	movzwl %dx,%edx
}
  801e18:	89 d0                	mov    %edx,%eax
  801e1a:	5d                   	pop    %ebp
  801e1b:	c3                   	ret    
  801e1c:	66 90                	xchg   %ax,%ax
  801e1e:	66 90                	xchg   %ax,%ax

00801e20 <__udivdi3>:
  801e20:	f3 0f 1e fb          	endbr32 
  801e24:	55                   	push   %ebp
  801e25:	57                   	push   %edi
  801e26:	56                   	push   %esi
  801e27:	53                   	push   %ebx
  801e28:	83 ec 1c             	sub    $0x1c,%esp
  801e2b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801e2f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801e33:	8b 74 24 34          	mov    0x34(%esp),%esi
  801e37:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801e3b:	85 d2                	test   %edx,%edx
  801e3d:	75 19                	jne    801e58 <__udivdi3+0x38>
  801e3f:	39 f3                	cmp    %esi,%ebx
  801e41:	76 4d                	jbe    801e90 <__udivdi3+0x70>
  801e43:	31 ff                	xor    %edi,%edi
  801e45:	89 e8                	mov    %ebp,%eax
  801e47:	89 f2                	mov    %esi,%edx
  801e49:	f7 f3                	div    %ebx
  801e4b:	89 fa                	mov    %edi,%edx
  801e4d:	83 c4 1c             	add    $0x1c,%esp
  801e50:	5b                   	pop    %ebx
  801e51:	5e                   	pop    %esi
  801e52:	5f                   	pop    %edi
  801e53:	5d                   	pop    %ebp
  801e54:	c3                   	ret    
  801e55:	8d 76 00             	lea    0x0(%esi),%esi
  801e58:	39 f2                	cmp    %esi,%edx
  801e5a:	76 14                	jbe    801e70 <__udivdi3+0x50>
  801e5c:	31 ff                	xor    %edi,%edi
  801e5e:	31 c0                	xor    %eax,%eax
  801e60:	89 fa                	mov    %edi,%edx
  801e62:	83 c4 1c             	add    $0x1c,%esp
  801e65:	5b                   	pop    %ebx
  801e66:	5e                   	pop    %esi
  801e67:	5f                   	pop    %edi
  801e68:	5d                   	pop    %ebp
  801e69:	c3                   	ret    
  801e6a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801e70:	0f bd fa             	bsr    %edx,%edi
  801e73:	83 f7 1f             	xor    $0x1f,%edi
  801e76:	75 48                	jne    801ec0 <__udivdi3+0xa0>
  801e78:	39 f2                	cmp    %esi,%edx
  801e7a:	72 06                	jb     801e82 <__udivdi3+0x62>
  801e7c:	31 c0                	xor    %eax,%eax
  801e7e:	39 eb                	cmp    %ebp,%ebx
  801e80:	77 de                	ja     801e60 <__udivdi3+0x40>
  801e82:	b8 01 00 00 00       	mov    $0x1,%eax
  801e87:	eb d7                	jmp    801e60 <__udivdi3+0x40>
  801e89:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801e90:	89 d9                	mov    %ebx,%ecx
  801e92:	85 db                	test   %ebx,%ebx
  801e94:	75 0b                	jne    801ea1 <__udivdi3+0x81>
  801e96:	b8 01 00 00 00       	mov    $0x1,%eax
  801e9b:	31 d2                	xor    %edx,%edx
  801e9d:	f7 f3                	div    %ebx
  801e9f:	89 c1                	mov    %eax,%ecx
  801ea1:	31 d2                	xor    %edx,%edx
  801ea3:	89 f0                	mov    %esi,%eax
  801ea5:	f7 f1                	div    %ecx
  801ea7:	89 c6                	mov    %eax,%esi
  801ea9:	89 e8                	mov    %ebp,%eax
  801eab:	89 f7                	mov    %esi,%edi
  801ead:	f7 f1                	div    %ecx
  801eaf:	89 fa                	mov    %edi,%edx
  801eb1:	83 c4 1c             	add    $0x1c,%esp
  801eb4:	5b                   	pop    %ebx
  801eb5:	5e                   	pop    %esi
  801eb6:	5f                   	pop    %edi
  801eb7:	5d                   	pop    %ebp
  801eb8:	c3                   	ret    
  801eb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ec0:	89 f9                	mov    %edi,%ecx
  801ec2:	b8 20 00 00 00       	mov    $0x20,%eax
  801ec7:	29 f8                	sub    %edi,%eax
  801ec9:	d3 e2                	shl    %cl,%edx
  801ecb:	89 54 24 08          	mov    %edx,0x8(%esp)
  801ecf:	89 c1                	mov    %eax,%ecx
  801ed1:	89 da                	mov    %ebx,%edx
  801ed3:	d3 ea                	shr    %cl,%edx
  801ed5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801ed9:	09 d1                	or     %edx,%ecx
  801edb:	89 f2                	mov    %esi,%edx
  801edd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ee1:	89 f9                	mov    %edi,%ecx
  801ee3:	d3 e3                	shl    %cl,%ebx
  801ee5:	89 c1                	mov    %eax,%ecx
  801ee7:	d3 ea                	shr    %cl,%edx
  801ee9:	89 f9                	mov    %edi,%ecx
  801eeb:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801eef:	89 eb                	mov    %ebp,%ebx
  801ef1:	d3 e6                	shl    %cl,%esi
  801ef3:	89 c1                	mov    %eax,%ecx
  801ef5:	d3 eb                	shr    %cl,%ebx
  801ef7:	09 de                	or     %ebx,%esi
  801ef9:	89 f0                	mov    %esi,%eax
  801efb:	f7 74 24 08          	divl   0x8(%esp)
  801eff:	89 d6                	mov    %edx,%esi
  801f01:	89 c3                	mov    %eax,%ebx
  801f03:	f7 64 24 0c          	mull   0xc(%esp)
  801f07:	39 d6                	cmp    %edx,%esi
  801f09:	72 15                	jb     801f20 <__udivdi3+0x100>
  801f0b:	89 f9                	mov    %edi,%ecx
  801f0d:	d3 e5                	shl    %cl,%ebp
  801f0f:	39 c5                	cmp    %eax,%ebp
  801f11:	73 04                	jae    801f17 <__udivdi3+0xf7>
  801f13:	39 d6                	cmp    %edx,%esi
  801f15:	74 09                	je     801f20 <__udivdi3+0x100>
  801f17:	89 d8                	mov    %ebx,%eax
  801f19:	31 ff                	xor    %edi,%edi
  801f1b:	e9 40 ff ff ff       	jmp    801e60 <__udivdi3+0x40>
  801f20:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801f23:	31 ff                	xor    %edi,%edi
  801f25:	e9 36 ff ff ff       	jmp    801e60 <__udivdi3+0x40>
  801f2a:	66 90                	xchg   %ax,%ax
  801f2c:	66 90                	xchg   %ax,%ax
  801f2e:	66 90                	xchg   %ax,%ax

00801f30 <__umoddi3>:
  801f30:	f3 0f 1e fb          	endbr32 
  801f34:	55                   	push   %ebp
  801f35:	57                   	push   %edi
  801f36:	56                   	push   %esi
  801f37:	53                   	push   %ebx
  801f38:	83 ec 1c             	sub    $0x1c,%esp
  801f3b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801f3f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801f43:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801f47:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801f4b:	85 c0                	test   %eax,%eax
  801f4d:	75 19                	jne    801f68 <__umoddi3+0x38>
  801f4f:	39 df                	cmp    %ebx,%edi
  801f51:	76 5d                	jbe    801fb0 <__umoddi3+0x80>
  801f53:	89 f0                	mov    %esi,%eax
  801f55:	89 da                	mov    %ebx,%edx
  801f57:	f7 f7                	div    %edi
  801f59:	89 d0                	mov    %edx,%eax
  801f5b:	31 d2                	xor    %edx,%edx
  801f5d:	83 c4 1c             	add    $0x1c,%esp
  801f60:	5b                   	pop    %ebx
  801f61:	5e                   	pop    %esi
  801f62:	5f                   	pop    %edi
  801f63:	5d                   	pop    %ebp
  801f64:	c3                   	ret    
  801f65:	8d 76 00             	lea    0x0(%esi),%esi
  801f68:	89 f2                	mov    %esi,%edx
  801f6a:	39 d8                	cmp    %ebx,%eax
  801f6c:	76 12                	jbe    801f80 <__umoddi3+0x50>
  801f6e:	89 f0                	mov    %esi,%eax
  801f70:	89 da                	mov    %ebx,%edx
  801f72:	83 c4 1c             	add    $0x1c,%esp
  801f75:	5b                   	pop    %ebx
  801f76:	5e                   	pop    %esi
  801f77:	5f                   	pop    %edi
  801f78:	5d                   	pop    %ebp
  801f79:	c3                   	ret    
  801f7a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801f80:	0f bd e8             	bsr    %eax,%ebp
  801f83:	83 f5 1f             	xor    $0x1f,%ebp
  801f86:	75 50                	jne    801fd8 <__umoddi3+0xa8>
  801f88:	39 d8                	cmp    %ebx,%eax
  801f8a:	0f 82 e0 00 00 00    	jb     802070 <__umoddi3+0x140>
  801f90:	89 d9                	mov    %ebx,%ecx
  801f92:	39 f7                	cmp    %esi,%edi
  801f94:	0f 86 d6 00 00 00    	jbe    802070 <__umoddi3+0x140>
  801f9a:	89 d0                	mov    %edx,%eax
  801f9c:	89 ca                	mov    %ecx,%edx
  801f9e:	83 c4 1c             	add    $0x1c,%esp
  801fa1:	5b                   	pop    %ebx
  801fa2:	5e                   	pop    %esi
  801fa3:	5f                   	pop    %edi
  801fa4:	5d                   	pop    %ebp
  801fa5:	c3                   	ret    
  801fa6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fad:	8d 76 00             	lea    0x0(%esi),%esi
  801fb0:	89 fd                	mov    %edi,%ebp
  801fb2:	85 ff                	test   %edi,%edi
  801fb4:	75 0b                	jne    801fc1 <__umoddi3+0x91>
  801fb6:	b8 01 00 00 00       	mov    $0x1,%eax
  801fbb:	31 d2                	xor    %edx,%edx
  801fbd:	f7 f7                	div    %edi
  801fbf:	89 c5                	mov    %eax,%ebp
  801fc1:	89 d8                	mov    %ebx,%eax
  801fc3:	31 d2                	xor    %edx,%edx
  801fc5:	f7 f5                	div    %ebp
  801fc7:	89 f0                	mov    %esi,%eax
  801fc9:	f7 f5                	div    %ebp
  801fcb:	89 d0                	mov    %edx,%eax
  801fcd:	31 d2                	xor    %edx,%edx
  801fcf:	eb 8c                	jmp    801f5d <__umoddi3+0x2d>
  801fd1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801fd8:	89 e9                	mov    %ebp,%ecx
  801fda:	ba 20 00 00 00       	mov    $0x20,%edx
  801fdf:	29 ea                	sub    %ebp,%edx
  801fe1:	d3 e0                	shl    %cl,%eax
  801fe3:	89 44 24 08          	mov    %eax,0x8(%esp)
  801fe7:	89 d1                	mov    %edx,%ecx
  801fe9:	89 f8                	mov    %edi,%eax
  801feb:	d3 e8                	shr    %cl,%eax
  801fed:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801ff1:	89 54 24 04          	mov    %edx,0x4(%esp)
  801ff5:	8b 54 24 04          	mov    0x4(%esp),%edx
  801ff9:	09 c1                	or     %eax,%ecx
  801ffb:	89 d8                	mov    %ebx,%eax
  801ffd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802001:	89 e9                	mov    %ebp,%ecx
  802003:	d3 e7                	shl    %cl,%edi
  802005:	89 d1                	mov    %edx,%ecx
  802007:	d3 e8                	shr    %cl,%eax
  802009:	89 e9                	mov    %ebp,%ecx
  80200b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80200f:	d3 e3                	shl    %cl,%ebx
  802011:	89 c7                	mov    %eax,%edi
  802013:	89 d1                	mov    %edx,%ecx
  802015:	89 f0                	mov    %esi,%eax
  802017:	d3 e8                	shr    %cl,%eax
  802019:	89 e9                	mov    %ebp,%ecx
  80201b:	89 fa                	mov    %edi,%edx
  80201d:	d3 e6                	shl    %cl,%esi
  80201f:	09 d8                	or     %ebx,%eax
  802021:	f7 74 24 08          	divl   0x8(%esp)
  802025:	89 d1                	mov    %edx,%ecx
  802027:	89 f3                	mov    %esi,%ebx
  802029:	f7 64 24 0c          	mull   0xc(%esp)
  80202d:	89 c6                	mov    %eax,%esi
  80202f:	89 d7                	mov    %edx,%edi
  802031:	39 d1                	cmp    %edx,%ecx
  802033:	72 06                	jb     80203b <__umoddi3+0x10b>
  802035:	75 10                	jne    802047 <__umoddi3+0x117>
  802037:	39 c3                	cmp    %eax,%ebx
  802039:	73 0c                	jae    802047 <__umoddi3+0x117>
  80203b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80203f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  802043:	89 d7                	mov    %edx,%edi
  802045:	89 c6                	mov    %eax,%esi
  802047:	89 ca                	mov    %ecx,%edx
  802049:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80204e:	29 f3                	sub    %esi,%ebx
  802050:	19 fa                	sbb    %edi,%edx
  802052:	89 d0                	mov    %edx,%eax
  802054:	d3 e0                	shl    %cl,%eax
  802056:	89 e9                	mov    %ebp,%ecx
  802058:	d3 eb                	shr    %cl,%ebx
  80205a:	d3 ea                	shr    %cl,%edx
  80205c:	09 d8                	or     %ebx,%eax
  80205e:	83 c4 1c             	add    $0x1c,%esp
  802061:	5b                   	pop    %ebx
  802062:	5e                   	pop    %esi
  802063:	5f                   	pop    %edi
  802064:	5d                   	pop    %ebp
  802065:	c3                   	ret    
  802066:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80206d:	8d 76 00             	lea    0x0(%esi),%esi
  802070:	29 fe                	sub    %edi,%esi
  802072:	19 c3                	sbb    %eax,%ebx
  802074:	89 f2                	mov    %esi,%edx
  802076:	89 d9                	mov    %ebx,%ecx
  802078:	e9 1d ff ff ff       	jmp    801f9a <__umoddi3+0x6a>
