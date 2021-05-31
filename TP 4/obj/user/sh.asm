
obj/user/sh.debug:     formato del fichero elf32-i386


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
  80002c:	e8 e6 09 00 00       	call   800a17 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <_gettoken>:
#define WHITESPACE " \t\r\n"
#define SYMBOLS "<|>&;()"

int
_gettoken(char *s, char **p1, char **p2)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	57                   	push   %edi
  80003b:	56                   	push   %esi
  80003c:	53                   	push   %ebx
  80003d:	83 ec 0c             	sub    $0xc,%esp
  800040:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800043:	8b 7d 0c             	mov    0xc(%ebp),%edi
	int t;

	if (s == 0) {
  800046:	85 db                	test   %ebx,%ebx
  800048:	74 1a                	je     800064 <_gettoken+0x31>
		if (debug > 1)
			cprintf("GETTOKEN NULL\n");
		return 0;
	}

	if (debug > 1)
  80004a:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800051:	7f 31                	jg     800084 <_gettoken+0x51>
		cprintf("GETTOKEN: %s\n", s);

	*p1 = 0;
  800053:	c7 07 00 00 00 00    	movl   $0x0,(%edi)
	*p2 = 0;
  800059:	8b 45 10             	mov    0x10(%ebp),%eax
  80005c:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

	while (strchr(WHITESPACE, *s))
  800062:	eb 3a                	jmp    80009e <_gettoken+0x6b>
		return 0;
  800064:	be 00 00 00 00       	mov    $0x0,%esi
		if (debug > 1)
  800069:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800070:	7e 59                	jle    8000cb <_gettoken+0x98>
			cprintf("GETTOKEN NULL\n");
  800072:	83 ec 0c             	sub    $0xc,%esp
  800075:	68 a0 35 80 00       	push   $0x8035a0
  80007a:	e8 eb 0a 00 00       	call   800b6a <cprintf>
  80007f:	83 c4 10             	add    $0x10,%esp
  800082:	eb 47                	jmp    8000cb <_gettoken+0x98>
		cprintf("GETTOKEN: %s\n", s);
  800084:	83 ec 08             	sub    $0x8,%esp
  800087:	53                   	push   %ebx
  800088:	68 af 35 80 00       	push   $0x8035af
  80008d:	e8 d8 0a 00 00       	call   800b6a <cprintf>
  800092:	83 c4 10             	add    $0x10,%esp
  800095:	eb bc                	jmp    800053 <_gettoken+0x20>
		*s++ = 0;
  800097:	83 c3 01             	add    $0x1,%ebx
  80009a:	c6 43 ff 00          	movb   $0x0,-0x1(%ebx)
	while (strchr(WHITESPACE, *s))
  80009e:	83 ec 08             	sub    $0x8,%esp
  8000a1:	0f be 03             	movsbl (%ebx),%eax
  8000a4:	50                   	push   %eax
  8000a5:	68 bd 35 80 00       	push   $0x8035bd
  8000aa:	e8 3e 12 00 00       	call   8012ed <strchr>
  8000af:	83 c4 10             	add    $0x10,%esp
  8000b2:	85 c0                	test   %eax,%eax
  8000b4:	75 e1                	jne    800097 <_gettoken+0x64>
	if (*s == 0) {
  8000b6:	0f b6 03             	movzbl (%ebx),%eax
  8000b9:	84 c0                	test   %al,%al
  8000bb:	75 2a                	jne    8000e7 <_gettoken+0xb4>
		if (debug > 1)
			cprintf("EOL\n");
		return 0;
  8000bd:	be 00 00 00 00       	mov    $0x0,%esi
		if (debug > 1)
  8000c2:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  8000c9:	7f 0a                	jg     8000d5 <_gettoken+0xa2>
		**p2 = 0;
		cprintf("WORD: %s\n", *p1);
		**p2 = t;
	}
	return 'w';
}
  8000cb:	89 f0                	mov    %esi,%eax
  8000cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d0:	5b                   	pop    %ebx
  8000d1:	5e                   	pop    %esi
  8000d2:	5f                   	pop    %edi
  8000d3:	5d                   	pop    %ebp
  8000d4:	c3                   	ret    
			cprintf("EOL\n");
  8000d5:	83 ec 0c             	sub    $0xc,%esp
  8000d8:	68 c2 35 80 00       	push   $0x8035c2
  8000dd:	e8 88 0a 00 00       	call   800b6a <cprintf>
  8000e2:	83 c4 10             	add    $0x10,%esp
  8000e5:	eb e4                	jmp    8000cb <_gettoken+0x98>
	if (strchr(SYMBOLS, *s)) {
  8000e7:	83 ec 08             	sub    $0x8,%esp
  8000ea:	0f be c0             	movsbl %al,%eax
  8000ed:	50                   	push   %eax
  8000ee:	68 d3 35 80 00       	push   $0x8035d3
  8000f3:	e8 f5 11 00 00       	call   8012ed <strchr>
  8000f8:	83 c4 10             	add    $0x10,%esp
  8000fb:	85 c0                	test   %eax,%eax
  8000fd:	74 2c                	je     80012b <_gettoken+0xf8>
		t = *s;
  8000ff:	0f be 33             	movsbl (%ebx),%esi
		*p1 = s;
  800102:	89 1f                	mov    %ebx,(%edi)
		*s++ = 0;
  800104:	c6 03 00             	movb   $0x0,(%ebx)
  800107:	83 c3 01             	add    $0x1,%ebx
  80010a:	8b 45 10             	mov    0x10(%ebp),%eax
  80010d:	89 18                	mov    %ebx,(%eax)
		if (debug > 1)
  80010f:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800116:	7e b3                	jle    8000cb <_gettoken+0x98>
			cprintf("TOK %c\n", t);
  800118:	83 ec 08             	sub    $0x8,%esp
  80011b:	56                   	push   %esi
  80011c:	68 c7 35 80 00       	push   $0x8035c7
  800121:	e8 44 0a 00 00       	call   800b6a <cprintf>
  800126:	83 c4 10             	add    $0x10,%esp
  800129:	eb a0                	jmp    8000cb <_gettoken+0x98>
	*p1 = s;
  80012b:	89 1f                	mov    %ebx,(%edi)
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  80012d:	eb 03                	jmp    800132 <_gettoken+0xff>
		s++;
  80012f:	83 c3 01             	add    $0x1,%ebx
	while (*s && !strchr(WHITESPACE SYMBOLS, *s))
  800132:	0f b6 03             	movzbl (%ebx),%eax
  800135:	84 c0                	test   %al,%al
  800137:	74 18                	je     800151 <_gettoken+0x11e>
  800139:	83 ec 08             	sub    $0x8,%esp
  80013c:	0f be c0             	movsbl %al,%eax
  80013f:	50                   	push   %eax
  800140:	68 cf 35 80 00       	push   $0x8035cf
  800145:	e8 a3 11 00 00       	call   8012ed <strchr>
  80014a:	83 c4 10             	add    $0x10,%esp
  80014d:	85 c0                	test   %eax,%eax
  80014f:	74 de                	je     80012f <_gettoken+0xfc>
	*p2 = s;
  800151:	8b 45 10             	mov    0x10(%ebp),%eax
  800154:	89 18                	mov    %ebx,(%eax)
	return 'w';
  800156:	be 77 00 00 00       	mov    $0x77,%esi
	if (debug > 1) {
  80015b:	83 3d 00 50 80 00 01 	cmpl   $0x1,0x805000
  800162:	0f 8e 63 ff ff ff    	jle    8000cb <_gettoken+0x98>
		t = **p2;
  800168:	0f b6 33             	movzbl (%ebx),%esi
		**p2 = 0;
  80016b:	c6 03 00             	movb   $0x0,(%ebx)
		cprintf("WORD: %s\n", *p1);
  80016e:	83 ec 08             	sub    $0x8,%esp
  800171:	ff 37                	pushl  (%edi)
  800173:	68 db 35 80 00       	push   $0x8035db
  800178:	e8 ed 09 00 00       	call   800b6a <cprintf>
		**p2 = t;
  80017d:	8b 45 10             	mov    0x10(%ebp),%eax
  800180:	8b 00                	mov    (%eax),%eax
  800182:	89 f2                	mov    %esi,%edx
  800184:	88 10                	mov    %dl,(%eax)
  800186:	83 c4 10             	add    $0x10,%esp
	return 'w';
  800189:	be 77 00 00 00       	mov    $0x77,%esi
  80018e:	e9 38 ff ff ff       	jmp    8000cb <_gettoken+0x98>

00800193 <gettoken>:

int
gettoken(char *s, char **p1)
{
  800193:	f3 0f 1e fb          	endbr32 
  800197:	55                   	push   %ebp
  800198:	89 e5                	mov    %esp,%ebp
  80019a:	83 ec 08             	sub    $0x8,%esp
  80019d:	8b 45 08             	mov    0x8(%ebp),%eax
	static int c, nc;
	static char *np1, *np2;

	if (s) {
  8001a0:	85 c0                	test   %eax,%eax
  8001a2:	74 22                	je     8001c6 <gettoken+0x33>
		nc = _gettoken(s, &np1, &np2);
  8001a4:	83 ec 04             	sub    $0x4,%esp
  8001a7:	68 0c 50 80 00       	push   $0x80500c
  8001ac:	68 10 50 80 00       	push   $0x805010
  8001b1:	50                   	push   %eax
  8001b2:	e8 7c fe ff ff       	call   800033 <_gettoken>
  8001b7:	a3 08 50 80 00       	mov    %eax,0x805008
		return 0;
  8001bc:	83 c4 10             	add    $0x10,%esp
  8001bf:	b8 00 00 00 00       	mov    $0x0,%eax
	}
	c = nc;
	*p1 = np1;
	nc = _gettoken(np2, &np1, &np2);
	return c;
}
  8001c4:	c9                   	leave  
  8001c5:	c3                   	ret    
	c = nc;
  8001c6:	a1 08 50 80 00       	mov    0x805008,%eax
  8001cb:	a3 04 50 80 00       	mov    %eax,0x805004
	*p1 = np1;
  8001d0:	8b 15 10 50 80 00    	mov    0x805010,%edx
  8001d6:	8b 45 0c             	mov    0xc(%ebp),%eax
  8001d9:	89 10                	mov    %edx,(%eax)
	nc = _gettoken(np2, &np1, &np2);
  8001db:	83 ec 04             	sub    $0x4,%esp
  8001de:	68 0c 50 80 00       	push   $0x80500c
  8001e3:	68 10 50 80 00       	push   $0x805010
  8001e8:	ff 35 0c 50 80 00    	pushl  0x80500c
  8001ee:	e8 40 fe ff ff       	call   800033 <_gettoken>
  8001f3:	a3 08 50 80 00       	mov    %eax,0x805008
	return c;
  8001f8:	a1 04 50 80 00       	mov    0x805004,%eax
  8001fd:	83 c4 10             	add    $0x10,%esp
  800200:	eb c2                	jmp    8001c4 <gettoken+0x31>

00800202 <runcmd>:
{
  800202:	f3 0f 1e fb          	endbr32 
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	57                   	push   %edi
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	81 ec 64 04 00 00    	sub    $0x464,%esp
	gettoken(s, 0);
  800212:	6a 00                	push   $0x0
  800214:	ff 75 08             	pushl  0x8(%ebp)
  800217:	e8 77 ff ff ff       	call   800193 <gettoken>
  80021c:	83 c4 10             	add    $0x10,%esp
		switch ((c = gettoken(0, &t))) {
  80021f:	8d 75 a4             	lea    -0x5c(%ebp),%esi
	argc = 0;
  800222:	bf 00 00 00 00       	mov    $0x0,%edi
		switch ((c = gettoken(0, &t))) {
  800227:	83 ec 08             	sub    $0x8,%esp
  80022a:	56                   	push   %esi
  80022b:	6a 00                	push   $0x0
  80022d:	e8 61 ff ff ff       	call   800193 <gettoken>
  800232:	89 c3                	mov    %eax,%ebx
  800234:	83 c4 10             	add    $0x10,%esp
  800237:	83 f8 3e             	cmp    $0x3e,%eax
  80023a:	0f 84 0b 01 00 00    	je     80034b <runcmd+0x149>
  800240:	7f 56                	jg     800298 <runcmd+0x96>
  800242:	85 c0                	test   %eax,%eax
  800244:	0f 84 f5 01 00 00    	je     80043f <runcmd+0x23d>
  80024a:	83 f8 3c             	cmp    $0x3c,%eax
  80024d:	0f 85 c8 02 00 00    	jne    80051b <runcmd+0x319>
			if (gettoken(0, &t) != 'w') {
  800253:	83 ec 08             	sub    $0x8,%esp
  800256:	56                   	push   %esi
  800257:	6a 00                	push   $0x0
  800259:	e8 35 ff ff ff       	call   800193 <gettoken>
  80025e:	83 c4 10             	add    $0x10,%esp
  800261:	83 f8 77             	cmp    $0x77,%eax
  800264:	0f 85 c7 00 00 00    	jne    800331 <runcmd+0x12f>
			if ((fd = open(t, O_RDONLY)) != 0){
  80026a:	83 ec 08             	sub    $0x8,%esp
  80026d:	6a 00                	push   $0x0
  80026f:	ff 75 a4             	pushl  -0x5c(%ebp)
  800272:	e8 59 23 00 00       	call   8025d0 <open>
  800277:	89 c3                	mov    %eax,%ebx
  800279:	83 c4 10             	add    $0x10,%esp
  80027c:	85 c0                	test   %eax,%eax
  80027e:	74 a7                	je     800227 <runcmd+0x25>
				dup(fd,0);
  800280:	83 ec 08             	sub    $0x8,%esp
  800283:	6a 00                	push   $0x0
  800285:	50                   	push   %eax
  800286:	e8 c0 1d 00 00       	call   80204b <dup>
				close(fd);
  80028b:	89 1c 24             	mov    %ebx,(%esp)
  80028e:	e8 5e 1d 00 00       	call   801ff1 <close>
  800293:	83 c4 10             	add    $0x10,%esp
  800296:	eb 8f                	jmp    800227 <runcmd+0x25>
		switch ((c = gettoken(0, &t))) {
  800298:	83 f8 77             	cmp    $0x77,%eax
  80029b:	74 69                	je     800306 <runcmd+0x104>
  80029d:	83 f8 7c             	cmp    $0x7c,%eax
  8002a0:	0f 85 75 02 00 00    	jne    80051b <runcmd+0x319>
			if ((r = pipe(p)) < 0) {
  8002a6:	83 ec 0c             	sub    $0xc,%esp
  8002a9:	8d 85 9c fb ff ff    	lea    -0x464(%ebp),%eax
  8002af:	50                   	push   %eax
  8002b0:	e8 d5 2c 00 00       	call   802f8a <pipe>
  8002b5:	83 c4 10             	add    $0x10,%esp
  8002b8:	85 c0                	test   %eax,%eax
  8002ba:	0f 88 0d 01 00 00    	js     8003cd <runcmd+0x1cb>
			if (debug)
  8002c0:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8002c7:	0f 85 1b 01 00 00    	jne    8003e8 <runcmd+0x1e6>
			if ((r = fork()) < 0) {
  8002cd:	e8 5d 18 00 00       	call   801b2f <fork>
  8002d2:	89 c3                	mov    %eax,%ebx
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	0f 88 2d 01 00 00    	js     800409 <runcmd+0x207>
			if (r == 0) {
  8002dc:	0f 85 3d 01 00 00    	jne    80041f <runcmd+0x21d>
				if (p[0] != 0) {
  8002e2:	8b 85 9c fb ff ff    	mov    -0x464(%ebp),%eax
  8002e8:	85 c0                	test   %eax,%eax
  8002ea:	0f 85 e9 01 00 00    	jne    8004d9 <runcmd+0x2d7>
				close(p[1]);
  8002f0:	83 ec 0c             	sub    $0xc,%esp
  8002f3:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8002f9:	e8 f3 1c 00 00       	call   801ff1 <close>
				goto again;
  8002fe:	83 c4 10             	add    $0x10,%esp
  800301:	e9 1c ff ff ff       	jmp    800222 <runcmd+0x20>
			if (argc == MAXARGS) {
  800306:	83 ff 10             	cmp    $0x10,%edi
  800309:	74 0f                	je     80031a <runcmd+0x118>
			argv[argc++] = t;
  80030b:	8b 45 a4             	mov    -0x5c(%ebp),%eax
  80030e:	89 44 bd a8          	mov    %eax,-0x58(%ebp,%edi,4)
  800312:	8d 7f 01             	lea    0x1(%edi),%edi
			break;
  800315:	e9 0d ff ff ff       	jmp    800227 <runcmd+0x25>
				cprintf("too many arguments\n");
  80031a:	83 ec 0c             	sub    $0xc,%esp
  80031d:	68 e5 35 80 00       	push   $0x8035e5
  800322:	e8 43 08 00 00       	call   800b6a <cprintf>
				exit();
  800327:	e8 39 07 00 00       	call   800a65 <exit>
  80032c:	83 c4 10             	add    $0x10,%esp
  80032f:	eb da                	jmp    80030b <runcmd+0x109>
				cprintf("syntax error: < not followed by "
  800331:	83 ec 0c             	sub    $0xc,%esp
  800334:	68 24 37 80 00       	push   $0x803724
  800339:	e8 2c 08 00 00       	call   800b6a <cprintf>
				exit();
  80033e:	e8 22 07 00 00       	call   800a65 <exit>
  800343:	83 c4 10             	add    $0x10,%esp
  800346:	e9 1f ff ff ff       	jmp    80026a <runcmd+0x68>
			if (gettoken(0, &t) != 'w') {
  80034b:	83 ec 08             	sub    $0x8,%esp
  80034e:	56                   	push   %esi
  80034f:	6a 00                	push   $0x0
  800351:	e8 3d fe ff ff       	call   800193 <gettoken>
  800356:	83 c4 10             	add    $0x10,%esp
  800359:	83 f8 77             	cmp    $0x77,%eax
  80035c:	75 24                	jne    800382 <runcmd+0x180>
			if ((fd = open(t, O_WRONLY | O_CREAT | O_TRUNC)) < 0) {
  80035e:	83 ec 08             	sub    $0x8,%esp
  800361:	68 01 03 00 00       	push   $0x301
  800366:	ff 75 a4             	pushl  -0x5c(%ebp)
  800369:	e8 62 22 00 00       	call   8025d0 <open>
  80036e:	89 c3                	mov    %eax,%ebx
  800370:	83 c4 10             	add    $0x10,%esp
  800373:	85 c0                	test   %eax,%eax
  800375:	78 22                	js     800399 <runcmd+0x197>
			if (fd != 1) {
  800377:	83 f8 01             	cmp    $0x1,%eax
  80037a:	0f 84 a7 fe ff ff    	je     800227 <runcmd+0x25>
  800380:	eb 30                	jmp    8003b2 <runcmd+0x1b0>
				cprintf("syntax error: > not followed by "
  800382:	83 ec 0c             	sub    $0xc,%esp
  800385:	68 4c 37 80 00       	push   $0x80374c
  80038a:	e8 db 07 00 00       	call   800b6a <cprintf>
				exit();
  80038f:	e8 d1 06 00 00       	call   800a65 <exit>
  800394:	83 c4 10             	add    $0x10,%esp
  800397:	eb c5                	jmp    80035e <runcmd+0x15c>
				cprintf("open %s for write: %e", t, fd);
  800399:	83 ec 04             	sub    $0x4,%esp
  80039c:	50                   	push   %eax
  80039d:	ff 75 a4             	pushl  -0x5c(%ebp)
  8003a0:	68 f9 35 80 00       	push   $0x8035f9
  8003a5:	e8 c0 07 00 00       	call   800b6a <cprintf>
				exit();
  8003aa:	e8 b6 06 00 00       	call   800a65 <exit>
  8003af:	83 c4 10             	add    $0x10,%esp
				dup(fd, 1);
  8003b2:	83 ec 08             	sub    $0x8,%esp
  8003b5:	6a 01                	push   $0x1
  8003b7:	53                   	push   %ebx
  8003b8:	e8 8e 1c 00 00       	call   80204b <dup>
				close(fd);
  8003bd:	89 1c 24             	mov    %ebx,(%esp)
  8003c0:	e8 2c 1c 00 00       	call   801ff1 <close>
  8003c5:	83 c4 10             	add    $0x10,%esp
  8003c8:	e9 5a fe ff ff       	jmp    800227 <runcmd+0x25>
				cprintf("pipe: %e", r);
  8003cd:	83 ec 08             	sub    $0x8,%esp
  8003d0:	50                   	push   %eax
  8003d1:	68 0f 36 80 00       	push   $0x80360f
  8003d6:	e8 8f 07 00 00       	call   800b6a <cprintf>
				exit();
  8003db:	e8 85 06 00 00       	call   800a65 <exit>
  8003e0:	83 c4 10             	add    $0x10,%esp
  8003e3:	e9 d8 fe ff ff       	jmp    8002c0 <runcmd+0xbe>
				cprintf("PIPE: %d %d\n", p[0], p[1]);
  8003e8:	83 ec 04             	sub    $0x4,%esp
  8003eb:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  8003f1:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8003f7:	68 18 36 80 00       	push   $0x803618
  8003fc:	e8 69 07 00 00       	call   800b6a <cprintf>
  800401:	83 c4 10             	add    $0x10,%esp
  800404:	e9 c4 fe ff ff       	jmp    8002cd <runcmd+0xcb>
				cprintf("fork: %e", r);
  800409:	83 ec 08             	sub    $0x8,%esp
  80040c:	50                   	push   %eax
  80040d:	68 25 36 80 00       	push   $0x803625
  800412:	e8 53 07 00 00       	call   800b6a <cprintf>
				exit();
  800417:	e8 49 06 00 00       	call   800a65 <exit>
  80041c:	83 c4 10             	add    $0x10,%esp
				if (p[1] != 1) {
  80041f:	8b 85 a0 fb ff ff    	mov    -0x460(%ebp),%eax
  800425:	83 f8 01             	cmp    $0x1,%eax
  800428:	0f 85 cc 00 00 00    	jne    8004fa <runcmd+0x2f8>
				close(p[0]);
  80042e:	83 ec 0c             	sub    $0xc,%esp
  800431:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  800437:	e8 b5 1b 00 00       	call   801ff1 <close>
				goto runit;
  80043c:	83 c4 10             	add    $0x10,%esp
	if (argc == 0) {
  80043f:	85 ff                	test   %edi,%edi
  800441:	0f 84 e6 00 00 00    	je     80052d <runcmd+0x32b>
	if (argv[0][0] != '/') {
  800447:	8b 45 a8             	mov    -0x58(%ebp),%eax
  80044a:	80 38 2f             	cmpb   $0x2f,(%eax)
  80044d:	0f 85 f5 00 00 00    	jne    800548 <runcmd+0x346>
	argv[argc] = 0;
  800453:	c7 44 bd a8 00 00 00 	movl   $0x0,-0x58(%ebp,%edi,4)
  80045a:	00 
	if (debug) {
  80045b:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800462:	0f 85 08 01 00 00    	jne    800570 <runcmd+0x36e>
	if ((r = spawn(argv[0], (const char **) argv)) < 0)
  800468:	83 ec 08             	sub    $0x8,%esp
  80046b:	8d 45 a8             	lea    -0x58(%ebp),%eax
  80046e:	50                   	push   %eax
  80046f:	ff 75 a8             	pushl  -0x58(%ebp)
  800472:	e8 34 26 00 00       	call   802aab <spawn>
  800477:	89 c6                	mov    %eax,%esi
  800479:	83 c4 10             	add    $0x10,%esp
  80047c:	85 c0                	test   %eax,%eax
  80047e:	0f 88 3a 01 00 00    	js     8005be <runcmd+0x3bc>
	close_all();
  800484:	e8 99 1b 00 00       	call   802022 <close_all>
		if (debug)
  800489:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800490:	0f 85 75 01 00 00    	jne    80060b <runcmd+0x409>
		wait(r);
  800496:	83 ec 0c             	sub    $0xc,%esp
  800499:	56                   	push   %esi
  80049a:	e8 70 2c 00 00       	call   80310f <wait>
		if (debug)
  80049f:	83 c4 10             	add    $0x10,%esp
  8004a2:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004a9:	0f 85 7b 01 00 00    	jne    80062a <runcmd+0x428>
	if (pipe_child) {
  8004af:	85 db                	test   %ebx,%ebx
  8004b1:	74 19                	je     8004cc <runcmd+0x2ca>
		wait(pipe_child);
  8004b3:	83 ec 0c             	sub    $0xc,%esp
  8004b6:	53                   	push   %ebx
  8004b7:	e8 53 2c 00 00       	call   80310f <wait>
		if (debug)
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8004c6:	0f 85 79 01 00 00    	jne    800645 <runcmd+0x443>
	exit();
  8004cc:	e8 94 05 00 00       	call   800a65 <exit>
}
  8004d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004d4:	5b                   	pop    %ebx
  8004d5:	5e                   	pop    %esi
  8004d6:	5f                   	pop    %edi
  8004d7:	5d                   	pop    %ebp
  8004d8:	c3                   	ret    
					dup(p[0], 0);
  8004d9:	83 ec 08             	sub    $0x8,%esp
  8004dc:	6a 00                	push   $0x0
  8004de:	50                   	push   %eax
  8004df:	e8 67 1b 00 00       	call   80204b <dup>
					close(p[0]);
  8004e4:	83 c4 04             	add    $0x4,%esp
  8004e7:	ff b5 9c fb ff ff    	pushl  -0x464(%ebp)
  8004ed:	e8 ff 1a 00 00       	call   801ff1 <close>
  8004f2:	83 c4 10             	add    $0x10,%esp
  8004f5:	e9 f6 fd ff ff       	jmp    8002f0 <runcmd+0xee>
					dup(p[1], 1);
  8004fa:	83 ec 08             	sub    $0x8,%esp
  8004fd:	6a 01                	push   $0x1
  8004ff:	50                   	push   %eax
  800500:	e8 46 1b 00 00       	call   80204b <dup>
					close(p[1]);
  800505:	83 c4 04             	add    $0x4,%esp
  800508:	ff b5 a0 fb ff ff    	pushl  -0x460(%ebp)
  80050e:	e8 de 1a 00 00       	call   801ff1 <close>
  800513:	83 c4 10             	add    $0x10,%esp
  800516:	e9 13 ff ff ff       	jmp    80042e <runcmd+0x22c>
			panic("bad return %d from gettoken", c);
  80051b:	53                   	push   %ebx
  80051c:	68 2e 36 80 00       	push   $0x80362e
  800521:	6a 74                	push   $0x74
  800523:	68 4a 36 80 00       	push   $0x80364a
  800528:	e8 56 05 00 00       	call   800a83 <_panic>
		if (debug)
  80052d:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800534:	74 9b                	je     8004d1 <runcmd+0x2cf>
			cprintf("EMPTY COMMAND\n");
  800536:	83 ec 0c             	sub    $0xc,%esp
  800539:	68 54 36 80 00       	push   $0x803654
  80053e:	e8 27 06 00 00       	call   800b6a <cprintf>
  800543:	83 c4 10             	add    $0x10,%esp
  800546:	eb 89                	jmp    8004d1 <runcmd+0x2cf>
		argv0buf[0] = '/';
  800548:	c6 85 a4 fb ff ff 2f 	movb   $0x2f,-0x45c(%ebp)
		strcpy(argv0buf + 1, argv[0]);
  80054f:	83 ec 08             	sub    $0x8,%esp
  800552:	50                   	push   %eax
  800553:	8d b5 a4 fb ff ff    	lea    -0x45c(%ebp),%esi
  800559:	8d 85 a5 fb ff ff    	lea    -0x45b(%ebp),%eax
  80055f:	50                   	push   %eax
  800560:	e8 63 0c 00 00       	call   8011c8 <strcpy>
		argv[0] = argv0buf;
  800565:	89 75 a8             	mov    %esi,-0x58(%ebp)
  800568:	83 c4 10             	add    $0x10,%esp
  80056b:	e9 e3 fe ff ff       	jmp    800453 <runcmd+0x251>
		cprintf("[%08x] SPAWN:", thisenv->env_id);
  800570:	a1 24 54 80 00       	mov    0x805424,%eax
  800575:	8b 40 48             	mov    0x48(%eax),%eax
  800578:	83 ec 08             	sub    $0x8,%esp
  80057b:	50                   	push   %eax
  80057c:	68 63 36 80 00       	push   $0x803663
  800581:	e8 e4 05 00 00       	call   800b6a <cprintf>
  800586:	8d 75 a8             	lea    -0x58(%ebp),%esi
		for (i = 0; argv[i]; i++)
  800589:	83 c4 10             	add    $0x10,%esp
  80058c:	eb 11                	jmp    80059f <runcmd+0x39d>
			cprintf(" %s", argv[i]);
  80058e:	83 ec 08             	sub    $0x8,%esp
  800591:	50                   	push   %eax
  800592:	68 eb 36 80 00       	push   $0x8036eb
  800597:	e8 ce 05 00 00       	call   800b6a <cprintf>
  80059c:	83 c4 10             	add    $0x10,%esp
  80059f:	83 c6 04             	add    $0x4,%esi
		for (i = 0; argv[i]; i++)
  8005a2:	8b 46 fc             	mov    -0x4(%esi),%eax
  8005a5:	85 c0                	test   %eax,%eax
  8005a7:	75 e5                	jne    80058e <runcmd+0x38c>
		cprintf("\n");
  8005a9:	83 ec 0c             	sub    $0xc,%esp
  8005ac:	68 c0 35 80 00       	push   $0x8035c0
  8005b1:	e8 b4 05 00 00       	call   800b6a <cprintf>
  8005b6:	83 c4 10             	add    $0x10,%esp
  8005b9:	e9 aa fe ff ff       	jmp    800468 <runcmd+0x266>
		cprintf("spawn %s: %e\n", argv[0], r);
  8005be:	83 ec 04             	sub    $0x4,%esp
  8005c1:	50                   	push   %eax
  8005c2:	ff 75 a8             	pushl  -0x58(%ebp)
  8005c5:	68 71 36 80 00       	push   $0x803671
  8005ca:	e8 9b 05 00 00       	call   800b6a <cprintf>
	close_all();
  8005cf:	e8 4e 1a 00 00       	call   802022 <close_all>
  8005d4:	83 c4 10             	add    $0x10,%esp
	if (pipe_child) {
  8005d7:	85 db                	test   %ebx,%ebx
  8005d9:	0f 84 ed fe ff ff    	je     8004cc <runcmd+0x2ca>
		if (debug)
  8005df:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  8005e6:	0f 84 c7 fe ff ff    	je     8004b3 <runcmd+0x2b1>
			        thisenv->env_id,
  8005ec:	a1 24 54 80 00       	mov    0x805424,%eax
			cprintf("[%08x] WAIT pipe_child %08x\n",
  8005f1:	8b 40 48             	mov    0x48(%eax),%eax
  8005f4:	83 ec 04             	sub    $0x4,%esp
  8005f7:	53                   	push   %ebx
  8005f8:	50                   	push   %eax
  8005f9:	68 aa 36 80 00       	push   $0x8036aa
  8005fe:	e8 67 05 00 00       	call   800b6a <cprintf>
  800603:	83 c4 10             	add    $0x10,%esp
  800606:	e9 a8 fe ff ff       	jmp    8004b3 <runcmd+0x2b1>
			cprintf("[%08x] WAIT %s %08x\n", thisenv->env_id, argv[0], r);
  80060b:	a1 24 54 80 00       	mov    0x805424,%eax
  800610:	8b 40 48             	mov    0x48(%eax),%eax
  800613:	56                   	push   %esi
  800614:	ff 75 a8             	pushl  -0x58(%ebp)
  800617:	50                   	push   %eax
  800618:	68 7f 36 80 00       	push   $0x80367f
  80061d:	e8 48 05 00 00       	call   800b6a <cprintf>
  800622:	83 c4 10             	add    $0x10,%esp
  800625:	e9 6c fe ff ff       	jmp    800496 <runcmd+0x294>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  80062a:	a1 24 54 80 00       	mov    0x805424,%eax
  80062f:	8b 40 48             	mov    0x48(%eax),%eax
  800632:	83 ec 08             	sub    $0x8,%esp
  800635:	50                   	push   %eax
  800636:	68 94 36 80 00       	push   $0x803694
  80063b:	e8 2a 05 00 00       	call   800b6a <cprintf>
  800640:	83 c4 10             	add    $0x10,%esp
  800643:	eb 92                	jmp    8005d7 <runcmd+0x3d5>
			cprintf("[%08x] wait finished\n", thisenv->env_id);
  800645:	a1 24 54 80 00       	mov    0x805424,%eax
  80064a:	8b 40 48             	mov    0x48(%eax),%eax
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	50                   	push   %eax
  800651:	68 94 36 80 00       	push   $0x803694
  800656:	e8 0f 05 00 00       	call   800b6a <cprintf>
  80065b:	83 c4 10             	add    $0x10,%esp
  80065e:	e9 69 fe ff ff       	jmp    8004cc <runcmd+0x2ca>

00800663 <usage>:


void
usage(void)
{
  800663:	f3 0f 1e fb          	endbr32 
  800667:	55                   	push   %ebp
  800668:	89 e5                	mov    %esp,%ebp
  80066a:	83 ec 14             	sub    $0x14,%esp
	cprintf("usage: sh [-dix] [command-file]\n");
  80066d:	68 74 37 80 00       	push   $0x803774
  800672:	e8 f3 04 00 00       	call   800b6a <cprintf>
	exit();
  800677:	e8 e9 03 00 00       	call   800a65 <exit>
}
  80067c:	83 c4 10             	add    $0x10,%esp
  80067f:	c9                   	leave  
  800680:	c3                   	ret    

00800681 <umain>:

void
umain(int argc, char **argv)
{
  800681:	f3 0f 1e fb          	endbr32 
  800685:	55                   	push   %ebp
  800686:	89 e5                	mov    %esp,%ebp
  800688:	57                   	push   %edi
  800689:	56                   	push   %esi
  80068a:	53                   	push   %ebx
  80068b:	83 ec 30             	sub    $0x30,%esp
	int r, interactive, echocmds;
	struct Argstate args;

	interactive = '?';
	echocmds = 0;
	argstart(&argc, argv, &args);
  80068e:	8d 45 d8             	lea    -0x28(%ebp),%eax
  800691:	50                   	push   %eax
  800692:	ff 75 0c             	pushl  0xc(%ebp)
  800695:	8d 45 08             	lea    0x8(%ebp),%eax
  800698:	50                   	push   %eax
  800699:	e8 32 16 00 00       	call   801cd0 <argstart>
	while ((r = argnext(&args)) >= 0)
  80069e:	83 c4 10             	add    $0x10,%esp
	echocmds = 0;
  8006a1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
	interactive = '?';
  8006a8:	bf 3f 00 00 00       	mov    $0x3f,%edi
	while ((r = argnext(&args)) >= 0)
  8006ad:	8d 5d d8             	lea    -0x28(%ebp),%ebx
		switch (r) {
		case 'd':
			debug++;
			break;
		case 'i':
			interactive = 1;
  8006b0:	be 01 00 00 00       	mov    $0x1,%esi
	while ((r = argnext(&args)) >= 0)
  8006b5:	eb 10                	jmp    8006c7 <umain+0x46>
			debug++;
  8006b7:	83 05 00 50 80 00 01 	addl   $0x1,0x805000
			break;
  8006be:	eb 07                	jmp    8006c7 <umain+0x46>
			interactive = 1;
  8006c0:	89 f7                	mov    %esi,%edi
  8006c2:	eb 03                	jmp    8006c7 <umain+0x46>
		switch (r) {
  8006c4:	89 75 d4             	mov    %esi,-0x2c(%ebp)
	while ((r = argnext(&args)) >= 0)
  8006c7:	83 ec 0c             	sub    $0xc,%esp
  8006ca:	53                   	push   %ebx
  8006cb:	e8 34 16 00 00       	call   801d04 <argnext>
  8006d0:	83 c4 10             	add    $0x10,%esp
  8006d3:	85 c0                	test   %eax,%eax
  8006d5:	78 16                	js     8006ed <umain+0x6c>
		switch (r) {
  8006d7:	83 f8 69             	cmp    $0x69,%eax
  8006da:	74 e4                	je     8006c0 <umain+0x3f>
  8006dc:	83 f8 78             	cmp    $0x78,%eax
  8006df:	74 e3                	je     8006c4 <umain+0x43>
  8006e1:	83 f8 64             	cmp    $0x64,%eax
  8006e4:	74 d1                	je     8006b7 <umain+0x36>
			break;
		case 'x':
			echocmds = 1;
			break;
		default:
			usage();
  8006e6:	e8 78 ff ff ff       	call   800663 <usage>
  8006eb:	eb da                	jmp    8006c7 <umain+0x46>
		}

	if (argc > 2)
  8006ed:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006f1:	7f 1f                	jg     800712 <umain+0x91>
		usage();
	if (argc == 2) {
  8006f3:	83 7d 08 02          	cmpl   $0x2,0x8(%ebp)
  8006f7:	74 20                	je     800719 <umain+0x98>
		close(0);
		if ((r = open(argv[1], O_RDONLY)) < 0)
			panic("open %s: %e", argv[1], r);
		assert(r == 0);
	}
	if (interactive == '?')
  8006f9:	83 ff 3f             	cmp    $0x3f,%edi
  8006fc:	74 75                	je     800773 <umain+0xf2>
  8006fe:	85 ff                	test   %edi,%edi
  800700:	bf ef 36 80 00       	mov    $0x8036ef,%edi
  800705:	b8 00 00 00 00       	mov    $0x0,%eax
  80070a:	0f 44 f8             	cmove  %eax,%edi
  80070d:	e9 06 01 00 00       	jmp    800818 <umain+0x197>
		usage();
  800712:	e8 4c ff ff ff       	call   800663 <usage>
  800717:	eb da                	jmp    8006f3 <umain+0x72>
		close(0);
  800719:	83 ec 0c             	sub    $0xc,%esp
  80071c:	6a 00                	push   $0x0
  80071e:	e8 ce 18 00 00       	call   801ff1 <close>
		if ((r = open(argv[1], O_RDONLY)) < 0)
  800723:	83 c4 08             	add    $0x8,%esp
  800726:	6a 00                	push   $0x0
  800728:	8b 45 0c             	mov    0xc(%ebp),%eax
  80072b:	ff 70 04             	pushl  0x4(%eax)
  80072e:	e8 9d 1e 00 00       	call   8025d0 <open>
  800733:	83 c4 10             	add    $0x10,%esp
  800736:	85 c0                	test   %eax,%eax
  800738:	78 1b                	js     800755 <umain+0xd4>
		assert(r == 0);
  80073a:	74 bd                	je     8006f9 <umain+0x78>
  80073c:	68 d3 36 80 00       	push   $0x8036d3
  800741:	68 da 36 80 00       	push   $0x8036da
  800746:	68 26 01 00 00       	push   $0x126
  80074b:	68 4a 36 80 00       	push   $0x80364a
  800750:	e8 2e 03 00 00       	call   800a83 <_panic>
			panic("open %s: %e", argv[1], r);
  800755:	83 ec 0c             	sub    $0xc,%esp
  800758:	50                   	push   %eax
  800759:	8b 45 0c             	mov    0xc(%ebp),%eax
  80075c:	ff 70 04             	pushl  0x4(%eax)
  80075f:	68 c7 36 80 00       	push   $0x8036c7
  800764:	68 25 01 00 00       	push   $0x125
  800769:	68 4a 36 80 00       	push   $0x80364a
  80076e:	e8 10 03 00 00       	call   800a83 <_panic>
		interactive = iscons(0);
  800773:	83 ec 0c             	sub    $0xc,%esp
  800776:	6a 00                	push   $0x0
  800778:	e8 14 02 00 00       	call   800991 <iscons>
  80077d:	89 c7                	mov    %eax,%edi
  80077f:	83 c4 10             	add    $0x10,%esp
  800782:	e9 77 ff ff ff       	jmp    8006fe <umain+0x7d>
	while (1) {
		char *buf;

		buf = readline(interactive ? "$ " : NULL);
		if (buf == NULL) {
			if (debug)
  800787:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  80078e:	75 0a                	jne    80079a <umain+0x119>
				cprintf("EXITING\n");
			exit();  // end of file
  800790:	e8 d0 02 00 00       	call   800a65 <exit>
  800795:	e9 94 00 00 00       	jmp    80082e <umain+0x1ad>
				cprintf("EXITING\n");
  80079a:	83 ec 0c             	sub    $0xc,%esp
  80079d:	68 f2 36 80 00       	push   $0x8036f2
  8007a2:	e8 c3 03 00 00       	call   800b6a <cprintf>
  8007a7:	83 c4 10             	add    $0x10,%esp
  8007aa:	eb e4                	jmp    800790 <umain+0x10f>
		}
		if (debug)
			cprintf("LINE: %s\n", buf);
  8007ac:	83 ec 08             	sub    $0x8,%esp
  8007af:	53                   	push   %ebx
  8007b0:	68 fb 36 80 00       	push   $0x8036fb
  8007b5:	e8 b0 03 00 00       	call   800b6a <cprintf>
  8007ba:	83 c4 10             	add    $0x10,%esp
  8007bd:	eb 7c                	jmp    80083b <umain+0x1ba>
		if (buf[0] == '#')
			continue;
		if (echocmds)
			printf("# %s\n", buf);
  8007bf:	83 ec 08             	sub    $0x8,%esp
  8007c2:	53                   	push   %ebx
  8007c3:	68 05 37 80 00       	push   $0x803705
  8007c8:	e8 ba 1f 00 00       	call   802787 <printf>
  8007cd:	83 c4 10             	add    $0x10,%esp
  8007d0:	eb 78                	jmp    80084a <umain+0x1c9>
		if (debug)
			cprintf("BEFORE FORK\n");
  8007d2:	83 ec 0c             	sub    $0xc,%esp
  8007d5:	68 0b 37 80 00       	push   $0x80370b
  8007da:	e8 8b 03 00 00       	call   800b6a <cprintf>
  8007df:	83 c4 10             	add    $0x10,%esp
  8007e2:	eb 73                	jmp    800857 <umain+0x1d6>
		if ((r = fork()) < 0)
			panic("fork: %e", r);
  8007e4:	50                   	push   %eax
  8007e5:	68 25 36 80 00       	push   $0x803625
  8007ea:	68 3d 01 00 00       	push   $0x13d
  8007ef:	68 4a 36 80 00       	push   $0x80364a
  8007f4:	e8 8a 02 00 00       	call   800a83 <_panic>
		if (debug)
			cprintf("FORK: %d\n", r);
  8007f9:	83 ec 08             	sub    $0x8,%esp
  8007fc:	50                   	push   %eax
  8007fd:	68 18 37 80 00       	push   $0x803718
  800802:	e8 63 03 00 00       	call   800b6a <cprintf>
  800807:	83 c4 10             	add    $0x10,%esp
  80080a:	eb 5f                	jmp    80086b <umain+0x1ea>
		if (r == 0) {
			runcmd(buf);
			exit();
		} else
			wait(r);
  80080c:	83 ec 0c             	sub    $0xc,%esp
  80080f:	56                   	push   %esi
  800810:	e8 fa 28 00 00       	call   80310f <wait>
  800815:	83 c4 10             	add    $0x10,%esp
		buf = readline(interactive ? "$ " : NULL);
  800818:	83 ec 0c             	sub    $0xc,%esp
  80081b:	57                   	push   %edi
  80081c:	e8 70 08 00 00       	call   801091 <readline>
  800821:	89 c3                	mov    %eax,%ebx
		if (buf == NULL) {
  800823:	83 c4 10             	add    $0x10,%esp
  800826:	85 c0                	test   %eax,%eax
  800828:	0f 84 59 ff ff ff    	je     800787 <umain+0x106>
		if (debug)
  80082e:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800835:	0f 85 71 ff ff ff    	jne    8007ac <umain+0x12b>
		if (buf[0] == '#')
  80083b:	80 3b 23             	cmpb   $0x23,(%ebx)
  80083e:	74 d8                	je     800818 <umain+0x197>
		if (echocmds)
  800840:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800844:	0f 85 75 ff ff ff    	jne    8007bf <umain+0x13e>
		if (debug)
  80084a:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800851:	0f 85 7b ff ff ff    	jne    8007d2 <umain+0x151>
		if ((r = fork()) < 0)
  800857:	e8 d3 12 00 00       	call   801b2f <fork>
  80085c:	89 c6                	mov    %eax,%esi
  80085e:	85 c0                	test   %eax,%eax
  800860:	78 82                	js     8007e4 <umain+0x163>
		if (debug)
  800862:	83 3d 00 50 80 00 00 	cmpl   $0x0,0x805000
  800869:	75 8e                	jne    8007f9 <umain+0x178>
		if (r == 0) {
  80086b:	85 f6                	test   %esi,%esi
  80086d:	75 9d                	jne    80080c <umain+0x18b>
			runcmd(buf);
  80086f:	83 ec 0c             	sub    $0xc,%esp
  800872:	53                   	push   %ebx
  800873:	e8 8a f9 ff ff       	call   800202 <runcmd>
			exit();
  800878:	e8 e8 01 00 00       	call   800a65 <exit>
  80087d:	83 c4 10             	add    $0x10,%esp
  800880:	eb 96                	jmp    800818 <umain+0x197>

00800882 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800882:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800886:	b8 00 00 00 00       	mov    $0x0,%eax
  80088b:	c3                   	ret    

0080088c <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  80088c:	f3 0f 1e fb          	endbr32 
  800890:	55                   	push   %ebp
  800891:	89 e5                	mov    %esp,%ebp
  800893:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800896:	68 95 37 80 00       	push   $0x803795
  80089b:	ff 75 0c             	pushl  0xc(%ebp)
  80089e:	e8 25 09 00 00       	call   8011c8 <strcpy>
	return 0;
}
  8008a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8008a8:	c9                   	leave  
  8008a9:	c3                   	ret    

008008aa <devcons_write>:
{
  8008aa:	f3 0f 1e fb          	endbr32 
  8008ae:	55                   	push   %ebp
  8008af:	89 e5                	mov    %esp,%ebp
  8008b1:	57                   	push   %edi
  8008b2:	56                   	push   %esi
  8008b3:	53                   	push   %ebx
  8008b4:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  8008ba:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  8008bf:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  8008c5:	3b 75 10             	cmp    0x10(%ebp),%esi
  8008c8:	73 31                	jae    8008fb <devcons_write+0x51>
		m = n - tot;
  8008ca:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8008cd:	29 f3                	sub    %esi,%ebx
  8008cf:	83 fb 7f             	cmp    $0x7f,%ebx
  8008d2:	b8 7f 00 00 00       	mov    $0x7f,%eax
  8008d7:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  8008da:	83 ec 04             	sub    $0x4,%esp
  8008dd:	53                   	push   %ebx
  8008de:	89 f0                	mov    %esi,%eax
  8008e0:	03 45 0c             	add    0xc(%ebp),%eax
  8008e3:	50                   	push   %eax
  8008e4:	57                   	push   %edi
  8008e5:	e8 96 0a 00 00       	call   801380 <memmove>
		sys_cputs(buf, m);
  8008ea:	83 c4 08             	add    $0x8,%esp
  8008ed:	53                   	push   %ebx
  8008ee:	57                   	push   %edi
  8008ef:	e8 91 0c 00 00       	call   801585 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  8008f4:	01 de                	add    %ebx,%esi
  8008f6:	83 c4 10             	add    $0x10,%esp
  8008f9:	eb ca                	jmp    8008c5 <devcons_write+0x1b>
}
  8008fb:	89 f0                	mov    %esi,%eax
  8008fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800900:	5b                   	pop    %ebx
  800901:	5e                   	pop    %esi
  800902:	5f                   	pop    %edi
  800903:	5d                   	pop    %ebp
  800904:	c3                   	ret    

00800905 <devcons_read>:
{
  800905:	f3 0f 1e fb          	endbr32 
  800909:	55                   	push   %ebp
  80090a:	89 e5                	mov    %esp,%ebp
  80090c:	83 ec 08             	sub    $0x8,%esp
  80090f:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800914:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800918:	74 21                	je     80093b <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  80091a:	e8 90 0c 00 00       	call   8015af <sys_cgetc>
  80091f:	85 c0                	test   %eax,%eax
  800921:	75 07                	jne    80092a <devcons_read+0x25>
		sys_yield();
  800923:	e8 fd 0c 00 00       	call   801625 <sys_yield>
  800928:	eb f0                	jmp    80091a <devcons_read+0x15>
	if (c < 0)
  80092a:	78 0f                	js     80093b <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  80092c:	83 f8 04             	cmp    $0x4,%eax
  80092f:	74 0c                	je     80093d <devcons_read+0x38>
	*(char*)vbuf = c;
  800931:	8b 55 0c             	mov    0xc(%ebp),%edx
  800934:	88 02                	mov    %al,(%edx)
	return 1;
  800936:	b8 01 00 00 00       	mov    $0x1,%eax
}
  80093b:	c9                   	leave  
  80093c:	c3                   	ret    
		return 0;
  80093d:	b8 00 00 00 00       	mov    $0x0,%eax
  800942:	eb f7                	jmp    80093b <devcons_read+0x36>

00800944 <cputchar>:
{
  800944:	f3 0f 1e fb          	endbr32 
  800948:	55                   	push   %ebp
  800949:	89 e5                	mov    %esp,%ebp
  80094b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80094e:	8b 45 08             	mov    0x8(%ebp),%eax
  800951:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800954:	6a 01                	push   $0x1
  800956:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800959:	50                   	push   %eax
  80095a:	e8 26 0c 00 00       	call   801585 <sys_cputs>
}
  80095f:	83 c4 10             	add    $0x10,%esp
  800962:	c9                   	leave  
  800963:	c3                   	ret    

00800964 <getchar>:
{
  800964:	f3 0f 1e fb          	endbr32 
  800968:	55                   	push   %ebp
  800969:	89 e5                	mov    %esp,%ebp
  80096b:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  80096e:	6a 01                	push   $0x1
  800970:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800973:	50                   	push   %eax
  800974:	6a 00                	push   $0x0
  800976:	e8 c0 17 00 00       	call   80213b <read>
	if (r < 0)
  80097b:	83 c4 10             	add    $0x10,%esp
  80097e:	85 c0                	test   %eax,%eax
  800980:	78 06                	js     800988 <getchar+0x24>
	if (r < 1)
  800982:	74 06                	je     80098a <getchar+0x26>
	return c;
  800984:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800988:	c9                   	leave  
  800989:	c3                   	ret    
		return -E_EOF;
  80098a:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  80098f:	eb f7                	jmp    800988 <getchar+0x24>

00800991 <iscons>:
{
  800991:	f3 0f 1e fb          	endbr32 
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80099b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80099e:	50                   	push   %eax
  80099f:	ff 75 08             	pushl  0x8(%ebp)
  8009a2:	e8 11 15 00 00       	call   801eb8 <fd_lookup>
  8009a7:	83 c4 10             	add    $0x10,%esp
  8009aa:	85 c0                	test   %eax,%eax
  8009ac:	78 11                	js     8009bf <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8009ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009b1:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8009b7:	39 10                	cmp    %edx,(%eax)
  8009b9:	0f 94 c0             	sete   %al
  8009bc:	0f b6 c0             	movzbl %al,%eax
}
  8009bf:	c9                   	leave  
  8009c0:	c3                   	ret    

008009c1 <opencons>:
{
  8009c1:	f3 0f 1e fb          	endbr32 
  8009c5:	55                   	push   %ebp
  8009c6:	89 e5                	mov    %esp,%ebp
  8009c8:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  8009cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8009ce:	50                   	push   %eax
  8009cf:	e8 8e 14 00 00       	call   801e62 <fd_alloc>
  8009d4:	83 c4 10             	add    $0x10,%esp
  8009d7:	85 c0                	test   %eax,%eax
  8009d9:	78 3a                	js     800a15 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  8009db:	83 ec 04             	sub    $0x4,%esp
  8009de:	68 07 04 00 00       	push   $0x407
  8009e3:	ff 75 f4             	pushl  -0xc(%ebp)
  8009e6:	6a 00                	push   $0x0
  8009e8:	e8 63 0c 00 00       	call   801650 <sys_page_alloc>
  8009ed:	83 c4 10             	add    $0x10,%esp
  8009f0:	85 c0                	test   %eax,%eax
  8009f2:	78 21                	js     800a15 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  8009f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8009f7:	8b 15 00 40 80 00    	mov    0x804000,%edx
  8009fd:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  8009ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800a02:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  800a09:	83 ec 0c             	sub    $0xc,%esp
  800a0c:	50                   	push   %eax
  800a0d:	e8 1d 14 00 00       	call   801e2f <fd2num>
  800a12:	83 c4 10             	add    $0x10,%esp
}
  800a15:	c9                   	leave  
  800a16:	c3                   	ret    

00800a17 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800a17:	f3 0f 1e fb          	endbr32 
  800a1b:	55                   	push   %ebp
  800a1c:	89 e5                	mov    %esp,%ebp
  800a1e:	56                   	push   %esi
  800a1f:	53                   	push   %ebx
  800a20:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800a23:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800a26:	e8 d2 0b 00 00       	call   8015fd <sys_getenvid>
	if (id >= 0)
  800a2b:	85 c0                	test   %eax,%eax
  800a2d:	78 12                	js     800a41 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800a2f:	25 ff 03 00 00       	and    $0x3ff,%eax
  800a34:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800a37:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800a3c:	a3 24 54 80 00       	mov    %eax,0x805424

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800a41:	85 db                	test   %ebx,%ebx
  800a43:	7e 07                	jle    800a4c <libmain+0x35>
		binaryname = argv[0];
  800a45:	8b 06                	mov    (%esi),%eax
  800a47:	a3 1c 40 80 00       	mov    %eax,0x80401c

	// call user main routine
	umain(argc, argv);
  800a4c:	83 ec 08             	sub    $0x8,%esp
  800a4f:	56                   	push   %esi
  800a50:	53                   	push   %ebx
  800a51:	e8 2b fc ff ff       	call   800681 <umain>

	// exit gracefully
	exit();
  800a56:	e8 0a 00 00 00       	call   800a65 <exit>
}
  800a5b:	83 c4 10             	add    $0x10,%esp
  800a5e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a61:	5b                   	pop    %ebx
  800a62:	5e                   	pop    %esi
  800a63:	5d                   	pop    %ebp
  800a64:	c3                   	ret    

00800a65 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800a65:	f3 0f 1e fb          	endbr32 
  800a69:	55                   	push   %ebp
  800a6a:	89 e5                	mov    %esp,%ebp
  800a6c:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800a6f:	e8 ae 15 00 00       	call   802022 <close_all>
	sys_env_destroy(0);
  800a74:	83 ec 0c             	sub    $0xc,%esp
  800a77:	6a 00                	push   $0x0
  800a79:	e8 59 0b 00 00       	call   8015d7 <sys_env_destroy>
}
  800a7e:	83 c4 10             	add    $0x10,%esp
  800a81:	c9                   	leave  
  800a82:	c3                   	ret    

00800a83 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800a83:	f3 0f 1e fb          	endbr32 
  800a87:	55                   	push   %ebp
  800a88:	89 e5                	mov    %esp,%ebp
  800a8a:	56                   	push   %esi
  800a8b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800a8c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800a8f:	8b 35 1c 40 80 00    	mov    0x80401c,%esi
  800a95:	e8 63 0b 00 00       	call   8015fd <sys_getenvid>
  800a9a:	83 ec 0c             	sub    $0xc,%esp
  800a9d:	ff 75 0c             	pushl  0xc(%ebp)
  800aa0:	ff 75 08             	pushl  0x8(%ebp)
  800aa3:	56                   	push   %esi
  800aa4:	50                   	push   %eax
  800aa5:	68 ac 37 80 00       	push   $0x8037ac
  800aaa:	e8 bb 00 00 00       	call   800b6a <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800aaf:	83 c4 18             	add    $0x18,%esp
  800ab2:	53                   	push   %ebx
  800ab3:	ff 75 10             	pushl  0x10(%ebp)
  800ab6:	e8 5a 00 00 00       	call   800b15 <vcprintf>
	cprintf("\n");
  800abb:	c7 04 24 c0 35 80 00 	movl   $0x8035c0,(%esp)
  800ac2:	e8 a3 00 00 00       	call   800b6a <cprintf>
  800ac7:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800aca:	cc                   	int3   
  800acb:	eb fd                	jmp    800aca <_panic+0x47>

00800acd <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800acd:	f3 0f 1e fb          	endbr32 
  800ad1:	55                   	push   %ebp
  800ad2:	89 e5                	mov    %esp,%ebp
  800ad4:	53                   	push   %ebx
  800ad5:	83 ec 04             	sub    $0x4,%esp
  800ad8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800adb:	8b 13                	mov    (%ebx),%edx
  800add:	8d 42 01             	lea    0x1(%edx),%eax
  800ae0:	89 03                	mov    %eax,(%ebx)
  800ae2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800ae5:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  800ae9:	3d ff 00 00 00       	cmp    $0xff,%eax
  800aee:	74 09                	je     800af9 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800af0:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800af4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800af7:	c9                   	leave  
  800af8:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  800af9:	83 ec 08             	sub    $0x8,%esp
  800afc:	68 ff 00 00 00       	push   $0xff
  800b01:	8d 43 08             	lea    0x8(%ebx),%eax
  800b04:	50                   	push   %eax
  800b05:	e8 7b 0a 00 00       	call   801585 <sys_cputs>
		b->idx = 0;
  800b0a:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800b10:	83 c4 10             	add    $0x10,%esp
  800b13:	eb db                	jmp    800af0 <putch+0x23>

00800b15 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800b15:	f3 0f 1e fb          	endbr32 
  800b19:	55                   	push   %ebp
  800b1a:	89 e5                	mov    %esp,%ebp
  800b1c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800b22:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800b29:	00 00 00 
	b.cnt = 0;
  800b2c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  800b33:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  800b36:	ff 75 0c             	pushl  0xc(%ebp)
  800b39:	ff 75 08             	pushl  0x8(%ebp)
  800b3c:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  800b42:	50                   	push   %eax
  800b43:	68 cd 0a 80 00       	push   $0x800acd
  800b48:	e8 80 01 00 00       	call   800ccd <vprintfmt>
	sys_cputs(b.buf, b.idx);
  800b4d:	83 c4 08             	add    $0x8,%esp
  800b50:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  800b56:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  800b5c:	50                   	push   %eax
  800b5d:	e8 23 0a 00 00       	call   801585 <sys_cputs>

	return b.cnt;
}
  800b62:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  800b68:	c9                   	leave  
  800b69:	c3                   	ret    

00800b6a <cprintf>:

int
cprintf(const char *fmt, ...)
{
  800b6a:	f3 0f 1e fb          	endbr32 
  800b6e:	55                   	push   %ebp
  800b6f:	89 e5                	mov    %esp,%ebp
  800b71:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  800b74:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  800b77:	50                   	push   %eax
  800b78:	ff 75 08             	pushl  0x8(%ebp)
  800b7b:	e8 95 ff ff ff       	call   800b15 <vcprintf>
	va_end(ap);

	return cnt;
}
  800b80:	c9                   	leave  
  800b81:	c3                   	ret    

00800b82 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  800b82:	55                   	push   %ebp
  800b83:	89 e5                	mov    %esp,%ebp
  800b85:	57                   	push   %edi
  800b86:	56                   	push   %esi
  800b87:	53                   	push   %ebx
  800b88:	83 ec 1c             	sub    $0x1c,%esp
  800b8b:	89 c7                	mov    %eax,%edi
  800b8d:	89 d6                	mov    %edx,%esi
  800b8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800b92:	8b 55 0c             	mov    0xc(%ebp),%edx
  800b95:	89 d1                	mov    %edx,%ecx
  800b97:	89 c2                	mov    %eax,%edx
  800b99:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b9c:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800b9f:	8b 45 10             	mov    0x10(%ebp),%eax
  800ba2:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800ba5:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ba8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800baf:	39 c2                	cmp    %eax,%edx
  800bb1:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800bb4:	72 3e                	jb     800bf4 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800bb6:	83 ec 0c             	sub    $0xc,%esp
  800bb9:	ff 75 18             	pushl  0x18(%ebp)
  800bbc:	83 eb 01             	sub    $0x1,%ebx
  800bbf:	53                   	push   %ebx
  800bc0:	50                   	push   %eax
  800bc1:	83 ec 08             	sub    $0x8,%esp
  800bc4:	ff 75 e4             	pushl  -0x1c(%ebp)
  800bc7:	ff 75 e0             	pushl  -0x20(%ebp)
  800bca:	ff 75 dc             	pushl  -0x24(%ebp)
  800bcd:	ff 75 d8             	pushl  -0x28(%ebp)
  800bd0:	e8 6b 27 00 00       	call   803340 <__udivdi3>
  800bd5:	83 c4 18             	add    $0x18,%esp
  800bd8:	52                   	push   %edx
  800bd9:	50                   	push   %eax
  800bda:	89 f2                	mov    %esi,%edx
  800bdc:	89 f8                	mov    %edi,%eax
  800bde:	e8 9f ff ff ff       	call   800b82 <printnum>
  800be3:	83 c4 20             	add    $0x20,%esp
  800be6:	eb 13                	jmp    800bfb <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800be8:	83 ec 08             	sub    $0x8,%esp
  800beb:	56                   	push   %esi
  800bec:	ff 75 18             	pushl  0x18(%ebp)
  800bef:	ff d7                	call   *%edi
  800bf1:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800bf4:	83 eb 01             	sub    $0x1,%ebx
  800bf7:	85 db                	test   %ebx,%ebx
  800bf9:	7f ed                	jg     800be8 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  800bfb:	83 ec 08             	sub    $0x8,%esp
  800bfe:	56                   	push   %esi
  800bff:	83 ec 04             	sub    $0x4,%esp
  800c02:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c05:	ff 75 e0             	pushl  -0x20(%ebp)
  800c08:	ff 75 dc             	pushl  -0x24(%ebp)
  800c0b:	ff 75 d8             	pushl  -0x28(%ebp)
  800c0e:	e8 3d 28 00 00       	call   803450 <__umoddi3>
  800c13:	83 c4 14             	add    $0x14,%esp
  800c16:	0f be 80 cf 37 80 00 	movsbl 0x8037cf(%eax),%eax
  800c1d:	50                   	push   %eax
  800c1e:	ff d7                	call   *%edi
}
  800c20:	83 c4 10             	add    $0x10,%esp
  800c23:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c26:	5b                   	pop    %ebx
  800c27:	5e                   	pop    %esi
  800c28:	5f                   	pop    %edi
  800c29:	5d                   	pop    %ebp
  800c2a:	c3                   	ret    

00800c2b <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c2b:	83 fa 01             	cmp    $0x1,%edx
  800c2e:	7f 13                	jg     800c43 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  800c30:	85 d2                	test   %edx,%edx
  800c32:	74 1c                	je     800c50 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  800c34:	8b 10                	mov    (%eax),%edx
  800c36:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c39:	89 08                	mov    %ecx,(%eax)
  800c3b:	8b 02                	mov    (%edx),%eax
  800c3d:	ba 00 00 00 00       	mov    $0x0,%edx
  800c42:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  800c43:	8b 10                	mov    (%eax),%edx
  800c45:	8d 4a 08             	lea    0x8(%edx),%ecx
  800c48:	89 08                	mov    %ecx,(%eax)
  800c4a:	8b 02                	mov    (%edx),%eax
  800c4c:	8b 52 04             	mov    0x4(%edx),%edx
  800c4f:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  800c50:	8b 10                	mov    (%eax),%edx
  800c52:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c55:	89 08                	mov    %ecx,(%eax)
  800c57:	8b 02                	mov    (%edx),%eax
  800c59:	ba 00 00 00 00       	mov    $0x0,%edx
}
  800c5e:	c3                   	ret    

00800c5f <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800c5f:	83 fa 01             	cmp    $0x1,%edx
  800c62:	7f 0f                	jg     800c73 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  800c64:	85 d2                	test   %edx,%edx
  800c66:	74 18                	je     800c80 <getint+0x21>
		return va_arg(*ap, long);
  800c68:	8b 10                	mov    (%eax),%edx
  800c6a:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c6d:	89 08                	mov    %ecx,(%eax)
  800c6f:	8b 02                	mov    (%edx),%eax
  800c71:	99                   	cltd   
  800c72:	c3                   	ret    
		return va_arg(*ap, long long);
  800c73:	8b 10                	mov    (%eax),%edx
  800c75:	8d 4a 08             	lea    0x8(%edx),%ecx
  800c78:	89 08                	mov    %ecx,(%eax)
  800c7a:	8b 02                	mov    (%edx),%eax
  800c7c:	8b 52 04             	mov    0x4(%edx),%edx
  800c7f:	c3                   	ret    
	else
		return va_arg(*ap, int);
  800c80:	8b 10                	mov    (%eax),%edx
  800c82:	8d 4a 04             	lea    0x4(%edx),%ecx
  800c85:	89 08                	mov    %ecx,(%eax)
  800c87:	8b 02                	mov    (%edx),%eax
  800c89:	99                   	cltd   
}
  800c8a:	c3                   	ret    

00800c8b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  800c8b:	f3 0f 1e fb          	endbr32 
  800c8f:	55                   	push   %ebp
  800c90:	89 e5                	mov    %esp,%ebp
  800c92:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800c95:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  800c99:	8b 10                	mov    (%eax),%edx
  800c9b:	3b 50 04             	cmp    0x4(%eax),%edx
  800c9e:	73 0a                	jae    800caa <sprintputch+0x1f>
		*b->buf++ = ch;
  800ca0:	8d 4a 01             	lea    0x1(%edx),%ecx
  800ca3:	89 08                	mov    %ecx,(%eax)
  800ca5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca8:	88 02                	mov    %al,(%edx)
}
  800caa:	5d                   	pop    %ebp
  800cab:	c3                   	ret    

00800cac <printfmt>:
{
  800cac:	f3 0f 1e fb          	endbr32 
  800cb0:	55                   	push   %ebp
  800cb1:	89 e5                	mov    %esp,%ebp
  800cb3:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800cb6:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  800cb9:	50                   	push   %eax
  800cba:	ff 75 10             	pushl  0x10(%ebp)
  800cbd:	ff 75 0c             	pushl  0xc(%ebp)
  800cc0:	ff 75 08             	pushl  0x8(%ebp)
  800cc3:	e8 05 00 00 00       	call   800ccd <vprintfmt>
}
  800cc8:	83 c4 10             	add    $0x10,%esp
  800ccb:	c9                   	leave  
  800ccc:	c3                   	ret    

00800ccd <vprintfmt>:
{
  800ccd:	f3 0f 1e fb          	endbr32 
  800cd1:	55                   	push   %ebp
  800cd2:	89 e5                	mov    %esp,%ebp
  800cd4:	57                   	push   %edi
  800cd5:	56                   	push   %esi
  800cd6:	53                   	push   %ebx
  800cd7:	83 ec 2c             	sub    $0x2c,%esp
  800cda:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800cdd:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ce0:	8b 7d 10             	mov    0x10(%ebp),%edi
  800ce3:	e9 86 02 00 00       	jmp    800f6e <vprintfmt+0x2a1>
		padc = ' ';
  800ce8:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  800cec:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800cf3:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  800cfa:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800d01:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800d06:	8d 47 01             	lea    0x1(%edi),%eax
  800d09:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800d0c:	0f b6 17             	movzbl (%edi),%edx
  800d0f:	8d 42 dd             	lea    -0x23(%edx),%eax
  800d12:	3c 55                	cmp    $0x55,%al
  800d14:	0f 87 df 02 00 00    	ja     800ff9 <vprintfmt+0x32c>
  800d1a:	0f b6 c0             	movzbl %al,%eax
  800d1d:	3e ff 24 85 20 39 80 	notrack jmp *0x803920(,%eax,4)
  800d24:	00 
  800d25:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  800d28:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  800d2c:	eb d8                	jmp    800d06 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800d2e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800d31:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  800d35:	eb cf                	jmp    800d06 <vprintfmt+0x39>
  800d37:	0f b6 d2             	movzbl %dl,%edx
  800d3a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  800d3d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d42:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  800d45:	8d 04 80             	lea    (%eax,%eax,4),%eax
  800d48:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  800d4c:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  800d4f:	8d 4a d0             	lea    -0x30(%edx),%ecx
  800d52:	83 f9 09             	cmp    $0x9,%ecx
  800d55:	77 52                	ja     800da9 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  800d57:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  800d5a:	eb e9                	jmp    800d45 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  800d5c:	8b 45 14             	mov    0x14(%ebp),%eax
  800d5f:	8d 50 04             	lea    0x4(%eax),%edx
  800d62:	89 55 14             	mov    %edx,0x14(%ebp)
  800d65:	8b 00                	mov    (%eax),%eax
  800d67:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800d6a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  800d6d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800d71:	79 93                	jns    800d06 <vprintfmt+0x39>
				width = precision, precision = -1;
  800d73:	8b 45 d8             	mov    -0x28(%ebp),%eax
  800d76:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800d79:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  800d80:	eb 84                	jmp    800d06 <vprintfmt+0x39>
  800d82:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800d85:	85 c0                	test   %eax,%eax
  800d87:	ba 00 00 00 00       	mov    $0x0,%edx
  800d8c:	0f 49 d0             	cmovns %eax,%edx
  800d8f:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800d92:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800d95:	e9 6c ff ff ff       	jmp    800d06 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800d9a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800d9d:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800da4:	e9 5d ff ff ff       	jmp    800d06 <vprintfmt+0x39>
  800da9:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800dac:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800daf:	eb bc                	jmp    800d6d <vprintfmt+0xa0>
			lflag++;
  800db1:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800db4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800db7:	e9 4a ff ff ff       	jmp    800d06 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800dbc:	8b 45 14             	mov    0x14(%ebp),%eax
  800dbf:	8d 50 04             	lea    0x4(%eax),%edx
  800dc2:	89 55 14             	mov    %edx,0x14(%ebp)
  800dc5:	83 ec 08             	sub    $0x8,%esp
  800dc8:	56                   	push   %esi
  800dc9:	ff 30                	pushl  (%eax)
  800dcb:	ff d3                	call   *%ebx
			break;
  800dcd:	83 c4 10             	add    $0x10,%esp
  800dd0:	e9 96 01 00 00       	jmp    800f6b <vprintfmt+0x29e>
			err = va_arg(ap, int);
  800dd5:	8b 45 14             	mov    0x14(%ebp),%eax
  800dd8:	8d 50 04             	lea    0x4(%eax),%edx
  800ddb:	89 55 14             	mov    %edx,0x14(%ebp)
  800dde:	8b 00                	mov    (%eax),%eax
  800de0:	99                   	cltd   
  800de1:	31 d0                	xor    %edx,%eax
  800de3:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800de5:	83 f8 0f             	cmp    $0xf,%eax
  800de8:	7f 20                	jg     800e0a <vprintfmt+0x13d>
  800dea:	8b 14 85 80 3a 80 00 	mov    0x803a80(,%eax,4),%edx
  800df1:	85 d2                	test   %edx,%edx
  800df3:	74 15                	je     800e0a <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  800df5:	52                   	push   %edx
  800df6:	68 ec 36 80 00       	push   $0x8036ec
  800dfb:	56                   	push   %esi
  800dfc:	53                   	push   %ebx
  800dfd:	e8 aa fe ff ff       	call   800cac <printfmt>
  800e02:	83 c4 10             	add    $0x10,%esp
  800e05:	e9 61 01 00 00       	jmp    800f6b <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800e0a:	50                   	push   %eax
  800e0b:	68 e7 37 80 00       	push   $0x8037e7
  800e10:	56                   	push   %esi
  800e11:	53                   	push   %ebx
  800e12:	e8 95 fe ff ff       	call   800cac <printfmt>
  800e17:	83 c4 10             	add    $0x10,%esp
  800e1a:	e9 4c 01 00 00       	jmp    800f6b <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  800e1f:	8b 45 14             	mov    0x14(%ebp),%eax
  800e22:	8d 50 04             	lea    0x4(%eax),%edx
  800e25:	89 55 14             	mov    %edx,0x14(%ebp)
  800e28:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800e2a:	85 c9                	test   %ecx,%ecx
  800e2c:	b8 e0 37 80 00       	mov    $0x8037e0,%eax
  800e31:	0f 45 c1             	cmovne %ecx,%eax
  800e34:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800e37:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800e3b:	7e 06                	jle    800e43 <vprintfmt+0x176>
  800e3d:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800e41:	75 0d                	jne    800e50 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  800e43:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800e46:	89 c7                	mov    %eax,%edi
  800e48:	03 45 e0             	add    -0x20(%ebp),%eax
  800e4b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800e4e:	eb 57                	jmp    800ea7 <vprintfmt+0x1da>
  800e50:	83 ec 08             	sub    $0x8,%esp
  800e53:	ff 75 d8             	pushl  -0x28(%ebp)
  800e56:	ff 75 cc             	pushl  -0x34(%ebp)
  800e59:	e8 43 03 00 00       	call   8011a1 <strnlen>
  800e5e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800e61:	29 c2                	sub    %eax,%edx
  800e63:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800e66:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800e69:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800e6d:	89 5d 08             	mov    %ebx,0x8(%ebp)
  800e70:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800e72:	85 db                	test   %ebx,%ebx
  800e74:	7e 10                	jle    800e86 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800e76:	83 ec 08             	sub    $0x8,%esp
  800e79:	56                   	push   %esi
  800e7a:	57                   	push   %edi
  800e7b:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800e7e:	83 eb 01             	sub    $0x1,%ebx
  800e81:	83 c4 10             	add    $0x10,%esp
  800e84:	eb ec                	jmp    800e72 <vprintfmt+0x1a5>
  800e86:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800e89:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800e8c:	85 d2                	test   %edx,%edx
  800e8e:	b8 00 00 00 00       	mov    $0x0,%eax
  800e93:	0f 49 c2             	cmovns %edx,%eax
  800e96:	29 c2                	sub    %eax,%edx
  800e98:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800e9b:	eb a6                	jmp    800e43 <vprintfmt+0x176>
					putch(ch, putdat);
  800e9d:	83 ec 08             	sub    $0x8,%esp
  800ea0:	56                   	push   %esi
  800ea1:	52                   	push   %edx
  800ea2:	ff d3                	call   *%ebx
  800ea4:	83 c4 10             	add    $0x10,%esp
  800ea7:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800eaa:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800eac:	83 c7 01             	add    $0x1,%edi
  800eaf:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800eb3:	0f be d0             	movsbl %al,%edx
  800eb6:	85 d2                	test   %edx,%edx
  800eb8:	74 42                	je     800efc <vprintfmt+0x22f>
  800eba:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800ebe:	78 06                	js     800ec6 <vprintfmt+0x1f9>
  800ec0:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800ec4:	78 1e                	js     800ee4 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  800ec6:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800eca:	74 d1                	je     800e9d <vprintfmt+0x1d0>
  800ecc:	0f be c0             	movsbl %al,%eax
  800ecf:	83 e8 20             	sub    $0x20,%eax
  800ed2:	83 f8 5e             	cmp    $0x5e,%eax
  800ed5:	76 c6                	jbe    800e9d <vprintfmt+0x1d0>
					putch('?', putdat);
  800ed7:	83 ec 08             	sub    $0x8,%esp
  800eda:	56                   	push   %esi
  800edb:	6a 3f                	push   $0x3f
  800edd:	ff d3                	call   *%ebx
  800edf:	83 c4 10             	add    $0x10,%esp
  800ee2:	eb c3                	jmp    800ea7 <vprintfmt+0x1da>
  800ee4:	89 cf                	mov    %ecx,%edi
  800ee6:	eb 0e                	jmp    800ef6 <vprintfmt+0x229>
				putch(' ', putdat);
  800ee8:	83 ec 08             	sub    $0x8,%esp
  800eeb:	56                   	push   %esi
  800eec:	6a 20                	push   $0x20
  800eee:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800ef0:	83 ef 01             	sub    $0x1,%edi
  800ef3:	83 c4 10             	add    $0x10,%esp
  800ef6:	85 ff                	test   %edi,%edi
  800ef8:	7f ee                	jg     800ee8 <vprintfmt+0x21b>
  800efa:	eb 6f                	jmp    800f6b <vprintfmt+0x29e>
  800efc:	89 cf                	mov    %ecx,%edi
  800efe:	eb f6                	jmp    800ef6 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  800f00:	89 ca                	mov    %ecx,%edx
  800f02:	8d 45 14             	lea    0x14(%ebp),%eax
  800f05:	e8 55 fd ff ff       	call   800c5f <getint>
  800f0a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800f0d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800f10:	85 d2                	test   %edx,%edx
  800f12:	78 0b                	js     800f1f <vprintfmt+0x252>
			num = getint(&ap, lflag);
  800f14:	89 d1                	mov    %edx,%ecx
  800f16:	89 c2                	mov    %eax,%edx
			base = 10;
  800f18:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f1d:	eb 32                	jmp    800f51 <vprintfmt+0x284>
				putch('-', putdat);
  800f1f:	83 ec 08             	sub    $0x8,%esp
  800f22:	56                   	push   %esi
  800f23:	6a 2d                	push   $0x2d
  800f25:	ff d3                	call   *%ebx
				num = -(long long) num;
  800f27:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800f2a:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800f2d:	f7 da                	neg    %edx
  800f2f:	83 d1 00             	adc    $0x0,%ecx
  800f32:	f7 d9                	neg    %ecx
  800f34:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800f37:	b8 0a 00 00 00       	mov    $0xa,%eax
  800f3c:	eb 13                	jmp    800f51 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800f3e:	89 ca                	mov    %ecx,%edx
  800f40:	8d 45 14             	lea    0x14(%ebp),%eax
  800f43:	e8 e3 fc ff ff       	call   800c2b <getuint>
  800f48:	89 d1                	mov    %edx,%ecx
  800f4a:	89 c2                	mov    %eax,%edx
			base = 10;
  800f4c:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  800f51:	83 ec 0c             	sub    $0xc,%esp
  800f54:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800f58:	57                   	push   %edi
  800f59:	ff 75 e0             	pushl  -0x20(%ebp)
  800f5c:	50                   	push   %eax
  800f5d:	51                   	push   %ecx
  800f5e:	52                   	push   %edx
  800f5f:	89 f2                	mov    %esi,%edx
  800f61:	89 d8                	mov    %ebx,%eax
  800f63:	e8 1a fc ff ff       	call   800b82 <printnum>
			break;
  800f68:	83 c4 20             	add    $0x20,%esp
{
  800f6b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800f6e:	83 c7 01             	add    $0x1,%edi
  800f71:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800f75:	83 f8 25             	cmp    $0x25,%eax
  800f78:	0f 84 6a fd ff ff    	je     800ce8 <vprintfmt+0x1b>
			if (ch == '\0')
  800f7e:	85 c0                	test   %eax,%eax
  800f80:	0f 84 93 00 00 00    	je     801019 <vprintfmt+0x34c>
			putch(ch, putdat);
  800f86:	83 ec 08             	sub    $0x8,%esp
  800f89:	56                   	push   %esi
  800f8a:	50                   	push   %eax
  800f8b:	ff d3                	call   *%ebx
  800f8d:	83 c4 10             	add    $0x10,%esp
  800f90:	eb dc                	jmp    800f6e <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  800f92:	89 ca                	mov    %ecx,%edx
  800f94:	8d 45 14             	lea    0x14(%ebp),%eax
  800f97:	e8 8f fc ff ff       	call   800c2b <getuint>
  800f9c:	89 d1                	mov    %edx,%ecx
  800f9e:	89 c2                	mov    %eax,%edx
			base = 8;
  800fa0:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800fa5:	eb aa                	jmp    800f51 <vprintfmt+0x284>
			putch('0', putdat);
  800fa7:	83 ec 08             	sub    $0x8,%esp
  800faa:	56                   	push   %esi
  800fab:	6a 30                	push   $0x30
  800fad:	ff d3                	call   *%ebx
			putch('x', putdat);
  800faf:	83 c4 08             	add    $0x8,%esp
  800fb2:	56                   	push   %esi
  800fb3:	6a 78                	push   $0x78
  800fb5:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  800fb7:	8b 45 14             	mov    0x14(%ebp),%eax
  800fba:	8d 50 04             	lea    0x4(%eax),%edx
  800fbd:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800fc0:	8b 10                	mov    (%eax),%edx
  800fc2:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800fc7:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800fca:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800fcf:	eb 80                	jmp    800f51 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800fd1:	89 ca                	mov    %ecx,%edx
  800fd3:	8d 45 14             	lea    0x14(%ebp),%eax
  800fd6:	e8 50 fc ff ff       	call   800c2b <getuint>
  800fdb:	89 d1                	mov    %edx,%ecx
  800fdd:	89 c2                	mov    %eax,%edx
			base = 16;
  800fdf:	b8 10 00 00 00       	mov    $0x10,%eax
  800fe4:	e9 68 ff ff ff       	jmp    800f51 <vprintfmt+0x284>
			putch(ch, putdat);
  800fe9:	83 ec 08             	sub    $0x8,%esp
  800fec:	56                   	push   %esi
  800fed:	6a 25                	push   $0x25
  800fef:	ff d3                	call   *%ebx
			break;
  800ff1:	83 c4 10             	add    $0x10,%esp
  800ff4:	e9 72 ff ff ff       	jmp    800f6b <vprintfmt+0x29e>
			putch('%', putdat);
  800ff9:	83 ec 08             	sub    $0x8,%esp
  800ffc:	56                   	push   %esi
  800ffd:	6a 25                	push   $0x25
  800fff:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  801001:	83 c4 10             	add    $0x10,%esp
  801004:	89 f8                	mov    %edi,%eax
  801006:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  80100a:	74 05                	je     801011 <vprintfmt+0x344>
  80100c:	83 e8 01             	sub    $0x1,%eax
  80100f:	eb f5                	jmp    801006 <vprintfmt+0x339>
  801011:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801014:	e9 52 ff ff ff       	jmp    800f6b <vprintfmt+0x29e>
}
  801019:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80101c:	5b                   	pop    %ebx
  80101d:	5e                   	pop    %esi
  80101e:	5f                   	pop    %edi
  80101f:	5d                   	pop    %ebp
  801020:	c3                   	ret    

00801021 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801021:	f3 0f 1e fb          	endbr32 
  801025:	55                   	push   %ebp
  801026:	89 e5                	mov    %esp,%ebp
  801028:	83 ec 18             	sub    $0x18,%esp
  80102b:	8b 45 08             	mov    0x8(%ebp),%eax
  80102e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801031:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801034:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801038:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80103b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801042:	85 c0                	test   %eax,%eax
  801044:	74 26                	je     80106c <vsnprintf+0x4b>
  801046:	85 d2                	test   %edx,%edx
  801048:	7e 22                	jle    80106c <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80104a:	ff 75 14             	pushl  0x14(%ebp)
  80104d:	ff 75 10             	pushl  0x10(%ebp)
  801050:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801053:	50                   	push   %eax
  801054:	68 8b 0c 80 00       	push   $0x800c8b
  801059:	e8 6f fc ff ff       	call   800ccd <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80105e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801061:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801064:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801067:	83 c4 10             	add    $0x10,%esp
}
  80106a:	c9                   	leave  
  80106b:	c3                   	ret    
		return -E_INVAL;
  80106c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801071:	eb f7                	jmp    80106a <vsnprintf+0x49>

00801073 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801073:	f3 0f 1e fb          	endbr32 
  801077:	55                   	push   %ebp
  801078:	89 e5                	mov    %esp,%ebp
  80107a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80107d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801080:	50                   	push   %eax
  801081:	ff 75 10             	pushl  0x10(%ebp)
  801084:	ff 75 0c             	pushl  0xc(%ebp)
  801087:	ff 75 08             	pushl  0x8(%ebp)
  80108a:	e8 92 ff ff ff       	call   801021 <vsnprintf>
	va_end(ap);

	return rc;
}
  80108f:	c9                   	leave  
  801090:	c3                   	ret    

00801091 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
  801091:	f3 0f 1e fb          	endbr32 
  801095:	55                   	push   %ebp
  801096:	89 e5                	mov    %esp,%ebp
  801098:	57                   	push   %edi
  801099:	56                   	push   %esi
  80109a:	53                   	push   %ebx
  80109b:	83 ec 0c             	sub    $0xc,%esp
  80109e:	8b 45 08             	mov    0x8(%ebp),%eax

#if JOS_KERNEL
	if (prompt != NULL)
		cprintf("%s", prompt);
#else
	if (prompt != NULL)
  8010a1:	85 c0                	test   %eax,%eax
  8010a3:	74 13                	je     8010b8 <readline+0x27>
		fprintf(1, "%s", prompt);
  8010a5:	83 ec 04             	sub    $0x4,%esp
  8010a8:	50                   	push   %eax
  8010a9:	68 ec 36 80 00       	push   $0x8036ec
  8010ae:	6a 01                	push   $0x1
  8010b0:	e8 b7 16 00 00       	call   80276c <fprintf>
  8010b5:	83 c4 10             	add    $0x10,%esp
#endif

	i = 0;
	echoing = iscons(0);
  8010b8:	83 ec 0c             	sub    $0xc,%esp
  8010bb:	6a 00                	push   $0x0
  8010bd:	e8 cf f8 ff ff       	call   800991 <iscons>
  8010c2:	89 c7                	mov    %eax,%edi
  8010c4:	83 c4 10             	add    $0x10,%esp
	i = 0;
  8010c7:	be 00 00 00 00       	mov    $0x0,%esi
  8010cc:	eb 57                	jmp    801125 <readline+0x94>
	while (1) {
		c = getchar();
		if (c < 0) {
			if (c != -E_EOF)
				cprintf("read error: %e\n", c);
			return NULL;
  8010ce:	b8 00 00 00 00       	mov    $0x0,%eax
			if (c != -E_EOF)
  8010d3:	83 fb f8             	cmp    $0xfffffff8,%ebx
  8010d6:	75 08                	jne    8010e0 <readline+0x4f>
				cputchar('\n');
			buf[i] = 0;
			return buf;
		}
	}
}
  8010d8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010db:	5b                   	pop    %ebx
  8010dc:	5e                   	pop    %esi
  8010dd:	5f                   	pop    %edi
  8010de:	5d                   	pop    %ebp
  8010df:	c3                   	ret    
				cprintf("read error: %e\n", c);
  8010e0:	83 ec 08             	sub    $0x8,%esp
  8010e3:	53                   	push   %ebx
  8010e4:	68 df 3a 80 00       	push   $0x803adf
  8010e9:	e8 7c fa ff ff       	call   800b6a <cprintf>
  8010ee:	83 c4 10             	add    $0x10,%esp
			return NULL;
  8010f1:	b8 00 00 00 00       	mov    $0x0,%eax
  8010f6:	eb e0                	jmp    8010d8 <readline+0x47>
			if (echoing)
  8010f8:	85 ff                	test   %edi,%edi
  8010fa:	75 05                	jne    801101 <readline+0x70>
			i--;
  8010fc:	83 ee 01             	sub    $0x1,%esi
  8010ff:	eb 24                	jmp    801125 <readline+0x94>
				cputchar('\b');
  801101:	83 ec 0c             	sub    $0xc,%esp
  801104:	6a 08                	push   $0x8
  801106:	e8 39 f8 ff ff       	call   800944 <cputchar>
  80110b:	83 c4 10             	add    $0x10,%esp
  80110e:	eb ec                	jmp    8010fc <readline+0x6b>
				cputchar(c);
  801110:	83 ec 0c             	sub    $0xc,%esp
  801113:	53                   	push   %ebx
  801114:	e8 2b f8 ff ff       	call   800944 <cputchar>
  801119:	83 c4 10             	add    $0x10,%esp
			buf[i++] = c;
  80111c:	88 9e 20 50 80 00    	mov    %bl,0x805020(%esi)
  801122:	8d 76 01             	lea    0x1(%esi),%esi
		c = getchar();
  801125:	e8 3a f8 ff ff       	call   800964 <getchar>
  80112a:	89 c3                	mov    %eax,%ebx
		if (c < 0) {
  80112c:	85 c0                	test   %eax,%eax
  80112e:	78 9e                	js     8010ce <readline+0x3d>
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
  801130:	83 f8 08             	cmp    $0x8,%eax
  801133:	0f 94 c2             	sete   %dl
  801136:	83 f8 7f             	cmp    $0x7f,%eax
  801139:	0f 94 c0             	sete   %al
  80113c:	08 c2                	or     %al,%dl
  80113e:	74 04                	je     801144 <readline+0xb3>
  801140:	85 f6                	test   %esi,%esi
  801142:	7f b4                	jg     8010f8 <readline+0x67>
		} else if (c >= ' ' && i < BUFLEN-1) {
  801144:	83 fb 1f             	cmp    $0x1f,%ebx
  801147:	7e 0e                	jle    801157 <readline+0xc6>
  801149:	81 fe fe 03 00 00    	cmp    $0x3fe,%esi
  80114f:	7f 06                	jg     801157 <readline+0xc6>
			if (echoing)
  801151:	85 ff                	test   %edi,%edi
  801153:	74 c7                	je     80111c <readline+0x8b>
  801155:	eb b9                	jmp    801110 <readline+0x7f>
		} else if (c == '\n' || c == '\r') {
  801157:	83 fb 0a             	cmp    $0xa,%ebx
  80115a:	74 05                	je     801161 <readline+0xd0>
  80115c:	83 fb 0d             	cmp    $0xd,%ebx
  80115f:	75 c4                	jne    801125 <readline+0x94>
			if (echoing)
  801161:	85 ff                	test   %edi,%edi
  801163:	75 11                	jne    801176 <readline+0xe5>
			buf[i] = 0;
  801165:	c6 86 20 50 80 00 00 	movb   $0x0,0x805020(%esi)
			return buf;
  80116c:	b8 20 50 80 00       	mov    $0x805020,%eax
  801171:	e9 62 ff ff ff       	jmp    8010d8 <readline+0x47>
				cputchar('\n');
  801176:	83 ec 0c             	sub    $0xc,%esp
  801179:	6a 0a                	push   $0xa
  80117b:	e8 c4 f7 ff ff       	call   800944 <cputchar>
  801180:	83 c4 10             	add    $0x10,%esp
  801183:	eb e0                	jmp    801165 <readline+0xd4>

00801185 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801185:	f3 0f 1e fb          	endbr32 
  801189:	55                   	push   %ebp
  80118a:	89 e5                	mov    %esp,%ebp
  80118c:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  80118f:	b8 00 00 00 00       	mov    $0x0,%eax
  801194:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801198:	74 05                	je     80119f <strlen+0x1a>
		n++;
  80119a:	83 c0 01             	add    $0x1,%eax
  80119d:	eb f5                	jmp    801194 <strlen+0xf>
	return n;
}
  80119f:	5d                   	pop    %ebp
  8011a0:	c3                   	ret    

008011a1 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8011a1:	f3 0f 1e fb          	endbr32 
  8011a5:	55                   	push   %ebp
  8011a6:	89 e5                	mov    %esp,%ebp
  8011a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011ab:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8011ae:	b8 00 00 00 00       	mov    $0x0,%eax
  8011b3:	39 d0                	cmp    %edx,%eax
  8011b5:	74 0d                	je     8011c4 <strnlen+0x23>
  8011b7:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8011bb:	74 05                	je     8011c2 <strnlen+0x21>
		n++;
  8011bd:	83 c0 01             	add    $0x1,%eax
  8011c0:	eb f1                	jmp    8011b3 <strnlen+0x12>
  8011c2:	89 c2                	mov    %eax,%edx
	return n;
}
  8011c4:	89 d0                	mov    %edx,%eax
  8011c6:	5d                   	pop    %ebp
  8011c7:	c3                   	ret    

008011c8 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8011c8:	f3 0f 1e fb          	endbr32 
  8011cc:	55                   	push   %ebp
  8011cd:	89 e5                	mov    %esp,%ebp
  8011cf:	53                   	push   %ebx
  8011d0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011d3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8011d6:	b8 00 00 00 00       	mov    $0x0,%eax
  8011db:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8011df:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8011e2:	83 c0 01             	add    $0x1,%eax
  8011e5:	84 d2                	test   %dl,%dl
  8011e7:	75 f2                	jne    8011db <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8011e9:	89 c8                	mov    %ecx,%eax
  8011eb:	5b                   	pop    %ebx
  8011ec:	5d                   	pop    %ebp
  8011ed:	c3                   	ret    

008011ee <strcat>:

char *
strcat(char *dst, const char *src)
{
  8011ee:	f3 0f 1e fb          	endbr32 
  8011f2:	55                   	push   %ebp
  8011f3:	89 e5                	mov    %esp,%ebp
  8011f5:	53                   	push   %ebx
  8011f6:	83 ec 10             	sub    $0x10,%esp
  8011f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8011fc:	53                   	push   %ebx
  8011fd:	e8 83 ff ff ff       	call   801185 <strlen>
  801202:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  801205:	ff 75 0c             	pushl  0xc(%ebp)
  801208:	01 d8                	add    %ebx,%eax
  80120a:	50                   	push   %eax
  80120b:	e8 b8 ff ff ff       	call   8011c8 <strcpy>
	return dst;
}
  801210:	89 d8                	mov    %ebx,%eax
  801212:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801215:	c9                   	leave  
  801216:	c3                   	ret    

00801217 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801217:	f3 0f 1e fb          	endbr32 
  80121b:	55                   	push   %ebp
  80121c:	89 e5                	mov    %esp,%ebp
  80121e:	56                   	push   %esi
  80121f:	53                   	push   %ebx
  801220:	8b 75 08             	mov    0x8(%ebp),%esi
  801223:	8b 55 0c             	mov    0xc(%ebp),%edx
  801226:	89 f3                	mov    %esi,%ebx
  801228:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80122b:	89 f0                	mov    %esi,%eax
  80122d:	39 d8                	cmp    %ebx,%eax
  80122f:	74 11                	je     801242 <strncpy+0x2b>
		*dst++ = *src;
  801231:	83 c0 01             	add    $0x1,%eax
  801234:	0f b6 0a             	movzbl (%edx),%ecx
  801237:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80123a:	80 f9 01             	cmp    $0x1,%cl
  80123d:	83 da ff             	sbb    $0xffffffff,%edx
  801240:	eb eb                	jmp    80122d <strncpy+0x16>
	}
	return ret;
}
  801242:	89 f0                	mov    %esi,%eax
  801244:	5b                   	pop    %ebx
  801245:	5e                   	pop    %esi
  801246:	5d                   	pop    %ebp
  801247:	c3                   	ret    

00801248 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801248:	f3 0f 1e fb          	endbr32 
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
  80124f:	56                   	push   %esi
  801250:	53                   	push   %ebx
  801251:	8b 75 08             	mov    0x8(%ebp),%esi
  801254:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801257:	8b 55 10             	mov    0x10(%ebp),%edx
  80125a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80125c:	85 d2                	test   %edx,%edx
  80125e:	74 21                	je     801281 <strlcpy+0x39>
  801260:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801264:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801266:	39 c2                	cmp    %eax,%edx
  801268:	74 14                	je     80127e <strlcpy+0x36>
  80126a:	0f b6 19             	movzbl (%ecx),%ebx
  80126d:	84 db                	test   %bl,%bl
  80126f:	74 0b                	je     80127c <strlcpy+0x34>
			*dst++ = *src++;
  801271:	83 c1 01             	add    $0x1,%ecx
  801274:	83 c2 01             	add    $0x1,%edx
  801277:	88 5a ff             	mov    %bl,-0x1(%edx)
  80127a:	eb ea                	jmp    801266 <strlcpy+0x1e>
  80127c:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80127e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801281:	29 f0                	sub    %esi,%eax
}
  801283:	5b                   	pop    %ebx
  801284:	5e                   	pop    %esi
  801285:	5d                   	pop    %ebp
  801286:	c3                   	ret    

00801287 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801287:	f3 0f 1e fb          	endbr32 
  80128b:	55                   	push   %ebp
  80128c:	89 e5                	mov    %esp,%ebp
  80128e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801291:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801294:	0f b6 01             	movzbl (%ecx),%eax
  801297:	84 c0                	test   %al,%al
  801299:	74 0c                	je     8012a7 <strcmp+0x20>
  80129b:	3a 02                	cmp    (%edx),%al
  80129d:	75 08                	jne    8012a7 <strcmp+0x20>
		p++, q++;
  80129f:	83 c1 01             	add    $0x1,%ecx
  8012a2:	83 c2 01             	add    $0x1,%edx
  8012a5:	eb ed                	jmp    801294 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8012a7:	0f b6 c0             	movzbl %al,%eax
  8012aa:	0f b6 12             	movzbl (%edx),%edx
  8012ad:	29 d0                	sub    %edx,%eax
}
  8012af:	5d                   	pop    %ebp
  8012b0:	c3                   	ret    

008012b1 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8012b1:	f3 0f 1e fb          	endbr32 
  8012b5:	55                   	push   %ebp
  8012b6:	89 e5                	mov    %esp,%ebp
  8012b8:	53                   	push   %ebx
  8012b9:	8b 45 08             	mov    0x8(%ebp),%eax
  8012bc:	8b 55 0c             	mov    0xc(%ebp),%edx
  8012bf:	89 c3                	mov    %eax,%ebx
  8012c1:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8012c4:	eb 06                	jmp    8012cc <strncmp+0x1b>
		n--, p++, q++;
  8012c6:	83 c0 01             	add    $0x1,%eax
  8012c9:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8012cc:	39 d8                	cmp    %ebx,%eax
  8012ce:	74 16                	je     8012e6 <strncmp+0x35>
  8012d0:	0f b6 08             	movzbl (%eax),%ecx
  8012d3:	84 c9                	test   %cl,%cl
  8012d5:	74 04                	je     8012db <strncmp+0x2a>
  8012d7:	3a 0a                	cmp    (%edx),%cl
  8012d9:	74 eb                	je     8012c6 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8012db:	0f b6 00             	movzbl (%eax),%eax
  8012de:	0f b6 12             	movzbl (%edx),%edx
  8012e1:	29 d0                	sub    %edx,%eax
}
  8012e3:	5b                   	pop    %ebx
  8012e4:	5d                   	pop    %ebp
  8012e5:	c3                   	ret    
		return 0;
  8012e6:	b8 00 00 00 00       	mov    $0x0,%eax
  8012eb:	eb f6                	jmp    8012e3 <strncmp+0x32>

008012ed <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8012ed:	f3 0f 1e fb          	endbr32 
  8012f1:	55                   	push   %ebp
  8012f2:	89 e5                	mov    %esp,%ebp
  8012f4:	8b 45 08             	mov    0x8(%ebp),%eax
  8012f7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8012fb:	0f b6 10             	movzbl (%eax),%edx
  8012fe:	84 d2                	test   %dl,%dl
  801300:	74 09                	je     80130b <strchr+0x1e>
		if (*s == c)
  801302:	38 ca                	cmp    %cl,%dl
  801304:	74 0a                	je     801310 <strchr+0x23>
	for (; *s; s++)
  801306:	83 c0 01             	add    $0x1,%eax
  801309:	eb f0                	jmp    8012fb <strchr+0xe>
			return (char *) s;
	return 0;
  80130b:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801310:	5d                   	pop    %ebp
  801311:	c3                   	ret    

00801312 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801312:	f3 0f 1e fb          	endbr32 
  801316:	55                   	push   %ebp
  801317:	89 e5                	mov    %esp,%ebp
  801319:	8b 45 08             	mov    0x8(%ebp),%eax
  80131c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801320:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801323:	38 ca                	cmp    %cl,%dl
  801325:	74 09                	je     801330 <strfind+0x1e>
  801327:	84 d2                	test   %dl,%dl
  801329:	74 05                	je     801330 <strfind+0x1e>
	for (; *s; s++)
  80132b:	83 c0 01             	add    $0x1,%eax
  80132e:	eb f0                	jmp    801320 <strfind+0xe>
			break;
	return (char *) s;
}
  801330:	5d                   	pop    %ebp
  801331:	c3                   	ret    

00801332 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801332:	f3 0f 1e fb          	endbr32 
  801336:	55                   	push   %ebp
  801337:	89 e5                	mov    %esp,%ebp
  801339:	57                   	push   %edi
  80133a:	56                   	push   %esi
  80133b:	53                   	push   %ebx
  80133c:	8b 55 08             	mov    0x8(%ebp),%edx
  80133f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  801342:	85 c9                	test   %ecx,%ecx
  801344:	74 33                	je     801379 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801346:	89 d0                	mov    %edx,%eax
  801348:	09 c8                	or     %ecx,%eax
  80134a:	a8 03                	test   $0x3,%al
  80134c:	75 23                	jne    801371 <memset+0x3f>
		c &= 0xFF;
  80134e:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801352:	89 d8                	mov    %ebx,%eax
  801354:	c1 e0 08             	shl    $0x8,%eax
  801357:	89 df                	mov    %ebx,%edi
  801359:	c1 e7 18             	shl    $0x18,%edi
  80135c:	89 de                	mov    %ebx,%esi
  80135e:	c1 e6 10             	shl    $0x10,%esi
  801361:	09 f7                	or     %esi,%edi
  801363:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  801365:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801368:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  80136a:	89 d7                	mov    %edx,%edi
  80136c:	fc                   	cld    
  80136d:	f3 ab                	rep stos %eax,%es:(%edi)
  80136f:	eb 08                	jmp    801379 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801371:	89 d7                	mov    %edx,%edi
  801373:	8b 45 0c             	mov    0xc(%ebp),%eax
  801376:	fc                   	cld    
  801377:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  801379:	89 d0                	mov    %edx,%eax
  80137b:	5b                   	pop    %ebx
  80137c:	5e                   	pop    %esi
  80137d:	5f                   	pop    %edi
  80137e:	5d                   	pop    %ebp
  80137f:	c3                   	ret    

00801380 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801380:	f3 0f 1e fb          	endbr32 
  801384:	55                   	push   %ebp
  801385:	89 e5                	mov    %esp,%ebp
  801387:	57                   	push   %edi
  801388:	56                   	push   %esi
  801389:	8b 45 08             	mov    0x8(%ebp),%eax
  80138c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80138f:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801392:	39 c6                	cmp    %eax,%esi
  801394:	73 32                	jae    8013c8 <memmove+0x48>
  801396:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801399:	39 c2                	cmp    %eax,%edx
  80139b:	76 2b                	jbe    8013c8 <memmove+0x48>
		s += n;
		d += n;
  80139d:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8013a0:	89 fe                	mov    %edi,%esi
  8013a2:	09 ce                	or     %ecx,%esi
  8013a4:	09 d6                	or     %edx,%esi
  8013a6:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8013ac:	75 0e                	jne    8013bc <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8013ae:	83 ef 04             	sub    $0x4,%edi
  8013b1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8013b4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8013b7:	fd                   	std    
  8013b8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8013ba:	eb 09                	jmp    8013c5 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8013bc:	83 ef 01             	sub    $0x1,%edi
  8013bf:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8013c2:	fd                   	std    
  8013c3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8013c5:	fc                   	cld    
  8013c6:	eb 1a                	jmp    8013e2 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8013c8:	89 c2                	mov    %eax,%edx
  8013ca:	09 ca                	or     %ecx,%edx
  8013cc:	09 f2                	or     %esi,%edx
  8013ce:	f6 c2 03             	test   $0x3,%dl
  8013d1:	75 0a                	jne    8013dd <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8013d3:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8013d6:	89 c7                	mov    %eax,%edi
  8013d8:	fc                   	cld    
  8013d9:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8013db:	eb 05                	jmp    8013e2 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8013dd:	89 c7                	mov    %eax,%edi
  8013df:	fc                   	cld    
  8013e0:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8013e2:	5e                   	pop    %esi
  8013e3:	5f                   	pop    %edi
  8013e4:	5d                   	pop    %ebp
  8013e5:	c3                   	ret    

008013e6 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8013e6:	f3 0f 1e fb          	endbr32 
  8013ea:	55                   	push   %ebp
  8013eb:	89 e5                	mov    %esp,%ebp
  8013ed:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8013f0:	ff 75 10             	pushl  0x10(%ebp)
  8013f3:	ff 75 0c             	pushl  0xc(%ebp)
  8013f6:	ff 75 08             	pushl  0x8(%ebp)
  8013f9:	e8 82 ff ff ff       	call   801380 <memmove>
}
  8013fe:	c9                   	leave  
  8013ff:	c3                   	ret    

00801400 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  801400:	f3 0f 1e fb          	endbr32 
  801404:	55                   	push   %ebp
  801405:	89 e5                	mov    %esp,%ebp
  801407:	56                   	push   %esi
  801408:	53                   	push   %ebx
  801409:	8b 45 08             	mov    0x8(%ebp),%eax
  80140c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80140f:	89 c6                	mov    %eax,%esi
  801411:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801414:	39 f0                	cmp    %esi,%eax
  801416:	74 1c                	je     801434 <memcmp+0x34>
		if (*s1 != *s2)
  801418:	0f b6 08             	movzbl (%eax),%ecx
  80141b:	0f b6 1a             	movzbl (%edx),%ebx
  80141e:	38 d9                	cmp    %bl,%cl
  801420:	75 08                	jne    80142a <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801422:	83 c0 01             	add    $0x1,%eax
  801425:	83 c2 01             	add    $0x1,%edx
  801428:	eb ea                	jmp    801414 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  80142a:	0f b6 c1             	movzbl %cl,%eax
  80142d:	0f b6 db             	movzbl %bl,%ebx
  801430:	29 d8                	sub    %ebx,%eax
  801432:	eb 05                	jmp    801439 <memcmp+0x39>
	}

	return 0;
  801434:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801439:	5b                   	pop    %ebx
  80143a:	5e                   	pop    %esi
  80143b:	5d                   	pop    %ebp
  80143c:	c3                   	ret    

0080143d <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80143d:	f3 0f 1e fb          	endbr32 
  801441:	55                   	push   %ebp
  801442:	89 e5                	mov    %esp,%ebp
  801444:	8b 45 08             	mov    0x8(%ebp),%eax
  801447:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80144a:	89 c2                	mov    %eax,%edx
  80144c:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  80144f:	39 d0                	cmp    %edx,%eax
  801451:	73 09                	jae    80145c <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801453:	38 08                	cmp    %cl,(%eax)
  801455:	74 05                	je     80145c <memfind+0x1f>
	for (; s < ends; s++)
  801457:	83 c0 01             	add    $0x1,%eax
  80145a:	eb f3                	jmp    80144f <memfind+0x12>
			break;
	return (void *) s;
}
  80145c:	5d                   	pop    %ebp
  80145d:	c3                   	ret    

0080145e <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80145e:	f3 0f 1e fb          	endbr32 
  801462:	55                   	push   %ebp
  801463:	89 e5                	mov    %esp,%ebp
  801465:	57                   	push   %edi
  801466:	56                   	push   %esi
  801467:	53                   	push   %ebx
  801468:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80146b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80146e:	eb 03                	jmp    801473 <strtol+0x15>
		s++;
  801470:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801473:	0f b6 01             	movzbl (%ecx),%eax
  801476:	3c 20                	cmp    $0x20,%al
  801478:	74 f6                	je     801470 <strtol+0x12>
  80147a:	3c 09                	cmp    $0x9,%al
  80147c:	74 f2                	je     801470 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  80147e:	3c 2b                	cmp    $0x2b,%al
  801480:	74 2a                	je     8014ac <strtol+0x4e>
	int neg = 0;
  801482:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801487:	3c 2d                	cmp    $0x2d,%al
  801489:	74 2b                	je     8014b6 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80148b:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801491:	75 0f                	jne    8014a2 <strtol+0x44>
  801493:	80 39 30             	cmpb   $0x30,(%ecx)
  801496:	74 28                	je     8014c0 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801498:	85 db                	test   %ebx,%ebx
  80149a:	b8 0a 00 00 00       	mov    $0xa,%eax
  80149f:	0f 44 d8             	cmove  %eax,%ebx
  8014a2:	b8 00 00 00 00       	mov    $0x0,%eax
  8014a7:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8014aa:	eb 46                	jmp    8014f2 <strtol+0x94>
		s++;
  8014ac:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8014af:	bf 00 00 00 00       	mov    $0x0,%edi
  8014b4:	eb d5                	jmp    80148b <strtol+0x2d>
		s++, neg = 1;
  8014b6:	83 c1 01             	add    $0x1,%ecx
  8014b9:	bf 01 00 00 00       	mov    $0x1,%edi
  8014be:	eb cb                	jmp    80148b <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8014c0:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8014c4:	74 0e                	je     8014d4 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8014c6:	85 db                	test   %ebx,%ebx
  8014c8:	75 d8                	jne    8014a2 <strtol+0x44>
		s++, base = 8;
  8014ca:	83 c1 01             	add    $0x1,%ecx
  8014cd:	bb 08 00 00 00       	mov    $0x8,%ebx
  8014d2:	eb ce                	jmp    8014a2 <strtol+0x44>
		s += 2, base = 16;
  8014d4:	83 c1 02             	add    $0x2,%ecx
  8014d7:	bb 10 00 00 00       	mov    $0x10,%ebx
  8014dc:	eb c4                	jmp    8014a2 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8014de:	0f be d2             	movsbl %dl,%edx
  8014e1:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8014e4:	3b 55 10             	cmp    0x10(%ebp),%edx
  8014e7:	7d 3a                	jge    801523 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8014e9:	83 c1 01             	add    $0x1,%ecx
  8014ec:	0f af 45 10          	imul   0x10(%ebp),%eax
  8014f0:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8014f2:	0f b6 11             	movzbl (%ecx),%edx
  8014f5:	8d 72 d0             	lea    -0x30(%edx),%esi
  8014f8:	89 f3                	mov    %esi,%ebx
  8014fa:	80 fb 09             	cmp    $0x9,%bl
  8014fd:	76 df                	jbe    8014de <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  8014ff:	8d 72 9f             	lea    -0x61(%edx),%esi
  801502:	89 f3                	mov    %esi,%ebx
  801504:	80 fb 19             	cmp    $0x19,%bl
  801507:	77 08                	ja     801511 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801509:	0f be d2             	movsbl %dl,%edx
  80150c:	83 ea 57             	sub    $0x57,%edx
  80150f:	eb d3                	jmp    8014e4 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801511:	8d 72 bf             	lea    -0x41(%edx),%esi
  801514:	89 f3                	mov    %esi,%ebx
  801516:	80 fb 19             	cmp    $0x19,%bl
  801519:	77 08                	ja     801523 <strtol+0xc5>
			dig = *s - 'A' + 10;
  80151b:	0f be d2             	movsbl %dl,%edx
  80151e:	83 ea 37             	sub    $0x37,%edx
  801521:	eb c1                	jmp    8014e4 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801523:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801527:	74 05                	je     80152e <strtol+0xd0>
		*endptr = (char *) s;
  801529:	8b 75 0c             	mov    0xc(%ebp),%esi
  80152c:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  80152e:	89 c2                	mov    %eax,%edx
  801530:	f7 da                	neg    %edx
  801532:	85 ff                	test   %edi,%edi
  801534:	0f 45 c2             	cmovne %edx,%eax
}
  801537:	5b                   	pop    %ebx
  801538:	5e                   	pop    %esi
  801539:	5f                   	pop    %edi
  80153a:	5d                   	pop    %ebp
  80153b:	c3                   	ret    

0080153c <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  80153c:	55                   	push   %ebp
  80153d:	89 e5                	mov    %esp,%ebp
  80153f:	57                   	push   %edi
  801540:	56                   	push   %esi
  801541:	53                   	push   %ebx
  801542:	83 ec 1c             	sub    $0x1c,%esp
  801545:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801548:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  80154b:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  80154d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801550:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801553:	8b 7d 10             	mov    0x10(%ebp),%edi
  801556:	8b 75 14             	mov    0x14(%ebp),%esi
  801559:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80155b:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  80155f:	74 04                	je     801565 <syscall+0x29>
  801561:	85 c0                	test   %eax,%eax
  801563:	7f 08                	jg     80156d <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  801565:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801568:	5b                   	pop    %ebx
  801569:	5e                   	pop    %esi
  80156a:	5f                   	pop    %edi
  80156b:	5d                   	pop    %ebp
  80156c:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  80156d:	83 ec 0c             	sub    $0xc,%esp
  801570:	50                   	push   %eax
  801571:	ff 75 e0             	pushl  -0x20(%ebp)
  801574:	68 ef 3a 80 00       	push   $0x803aef
  801579:	6a 23                	push   $0x23
  80157b:	68 0c 3b 80 00       	push   $0x803b0c
  801580:	e8 fe f4 ff ff       	call   800a83 <_panic>

00801585 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  801585:	f3 0f 1e fb          	endbr32 
  801589:	55                   	push   %ebp
  80158a:	89 e5                	mov    %esp,%ebp
  80158c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80158f:	6a 00                	push   $0x0
  801591:	6a 00                	push   $0x0
  801593:	6a 00                	push   $0x0
  801595:	ff 75 0c             	pushl  0xc(%ebp)
  801598:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80159b:	ba 00 00 00 00       	mov    $0x0,%edx
  8015a0:	b8 00 00 00 00       	mov    $0x0,%eax
  8015a5:	e8 92 ff ff ff       	call   80153c <syscall>
}
  8015aa:	83 c4 10             	add    $0x10,%esp
  8015ad:	c9                   	leave  
  8015ae:	c3                   	ret    

008015af <sys_cgetc>:

int
sys_cgetc(void)
{
  8015af:	f3 0f 1e fb          	endbr32 
  8015b3:	55                   	push   %ebp
  8015b4:	89 e5                	mov    %esp,%ebp
  8015b6:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  8015b9:	6a 00                	push   $0x0
  8015bb:	6a 00                	push   $0x0
  8015bd:	6a 00                	push   $0x0
  8015bf:	6a 00                	push   $0x0
  8015c1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8015c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8015cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8015d0:	e8 67 ff ff ff       	call   80153c <syscall>
}
  8015d5:	c9                   	leave  
  8015d6:	c3                   	ret    

008015d7 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8015d7:	f3 0f 1e fb          	endbr32 
  8015db:	55                   	push   %ebp
  8015dc:	89 e5                	mov    %esp,%ebp
  8015de:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  8015e1:	6a 00                	push   $0x0
  8015e3:	6a 00                	push   $0x0
  8015e5:	6a 00                	push   $0x0
  8015e7:	6a 00                	push   $0x0
  8015e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8015ec:	ba 01 00 00 00       	mov    $0x1,%edx
  8015f1:	b8 03 00 00 00       	mov    $0x3,%eax
  8015f6:	e8 41 ff ff ff       	call   80153c <syscall>
}
  8015fb:	c9                   	leave  
  8015fc:	c3                   	ret    

008015fd <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  8015fd:	f3 0f 1e fb          	endbr32 
  801601:	55                   	push   %ebp
  801602:	89 e5                	mov    %esp,%ebp
  801604:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  801607:	6a 00                	push   $0x0
  801609:	6a 00                	push   $0x0
  80160b:	6a 00                	push   $0x0
  80160d:	6a 00                	push   $0x0
  80160f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801614:	ba 00 00 00 00       	mov    $0x0,%edx
  801619:	b8 02 00 00 00       	mov    $0x2,%eax
  80161e:	e8 19 ff ff ff       	call   80153c <syscall>
}
  801623:	c9                   	leave  
  801624:	c3                   	ret    

00801625 <sys_yield>:

void
sys_yield(void)
{
  801625:	f3 0f 1e fb          	endbr32 
  801629:	55                   	push   %ebp
  80162a:	89 e5                	mov    %esp,%ebp
  80162c:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  80162f:	6a 00                	push   $0x0
  801631:	6a 00                	push   $0x0
  801633:	6a 00                	push   $0x0
  801635:	6a 00                	push   $0x0
  801637:	b9 00 00 00 00       	mov    $0x0,%ecx
  80163c:	ba 00 00 00 00       	mov    $0x0,%edx
  801641:	b8 0b 00 00 00       	mov    $0xb,%eax
  801646:	e8 f1 fe ff ff       	call   80153c <syscall>
}
  80164b:	83 c4 10             	add    $0x10,%esp
  80164e:	c9                   	leave  
  80164f:	c3                   	ret    

00801650 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  801650:	f3 0f 1e fb          	endbr32 
  801654:	55                   	push   %ebp
  801655:	89 e5                	mov    %esp,%ebp
  801657:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  80165a:	6a 00                	push   $0x0
  80165c:	6a 00                	push   $0x0
  80165e:	ff 75 10             	pushl  0x10(%ebp)
  801661:	ff 75 0c             	pushl  0xc(%ebp)
  801664:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801667:	ba 01 00 00 00       	mov    $0x1,%edx
  80166c:	b8 04 00 00 00       	mov    $0x4,%eax
  801671:	e8 c6 fe ff ff       	call   80153c <syscall>
}
  801676:	c9                   	leave  
  801677:	c3                   	ret    

00801678 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  801678:	f3 0f 1e fb          	endbr32 
  80167c:	55                   	push   %ebp
  80167d:	89 e5                	mov    %esp,%ebp
  80167f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  801682:	ff 75 18             	pushl  0x18(%ebp)
  801685:	ff 75 14             	pushl  0x14(%ebp)
  801688:	ff 75 10             	pushl  0x10(%ebp)
  80168b:	ff 75 0c             	pushl  0xc(%ebp)
  80168e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801691:	ba 01 00 00 00       	mov    $0x1,%edx
  801696:	b8 05 00 00 00       	mov    $0x5,%eax
  80169b:	e8 9c fe ff ff       	call   80153c <syscall>
}
  8016a0:	c9                   	leave  
  8016a1:	c3                   	ret    

008016a2 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8016a2:	f3 0f 1e fb          	endbr32 
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  8016ac:	6a 00                	push   $0x0
  8016ae:	6a 00                	push   $0x0
  8016b0:	6a 00                	push   $0x0
  8016b2:	ff 75 0c             	pushl  0xc(%ebp)
  8016b5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016b8:	ba 01 00 00 00       	mov    $0x1,%edx
  8016bd:	b8 06 00 00 00       	mov    $0x6,%eax
  8016c2:	e8 75 fe ff ff       	call   80153c <syscall>
}
  8016c7:	c9                   	leave  
  8016c8:	c3                   	ret    

008016c9 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  8016c9:	f3 0f 1e fb          	endbr32 
  8016cd:	55                   	push   %ebp
  8016ce:	89 e5                	mov    %esp,%ebp
  8016d0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  8016d3:	6a 00                	push   $0x0
  8016d5:	6a 00                	push   $0x0
  8016d7:	6a 00                	push   $0x0
  8016d9:	ff 75 0c             	pushl  0xc(%ebp)
  8016dc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016df:	ba 01 00 00 00       	mov    $0x1,%edx
  8016e4:	b8 08 00 00 00       	mov    $0x8,%eax
  8016e9:	e8 4e fe ff ff       	call   80153c <syscall>
}
  8016ee:	c9                   	leave  
  8016ef:	c3                   	ret    

008016f0 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  8016f0:	f3 0f 1e fb          	endbr32 
  8016f4:	55                   	push   %ebp
  8016f5:	89 e5                	mov    %esp,%ebp
  8016f7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  8016fa:	6a 00                	push   $0x0
  8016fc:	6a 00                	push   $0x0
  8016fe:	6a 00                	push   $0x0
  801700:	ff 75 0c             	pushl  0xc(%ebp)
  801703:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801706:	ba 01 00 00 00       	mov    $0x1,%edx
  80170b:	b8 09 00 00 00       	mov    $0x9,%eax
  801710:	e8 27 fe ff ff       	call   80153c <syscall>
}
  801715:	c9                   	leave  
  801716:	c3                   	ret    

00801717 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801717:	f3 0f 1e fb          	endbr32 
  80171b:	55                   	push   %ebp
  80171c:	89 e5                	mov    %esp,%ebp
  80171e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  801721:	6a 00                	push   $0x0
  801723:	6a 00                	push   $0x0
  801725:	6a 00                	push   $0x0
  801727:	ff 75 0c             	pushl  0xc(%ebp)
  80172a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80172d:	ba 01 00 00 00       	mov    $0x1,%edx
  801732:	b8 0a 00 00 00       	mov    $0xa,%eax
  801737:	e8 00 fe ff ff       	call   80153c <syscall>
}
  80173c:	c9                   	leave  
  80173d:	c3                   	ret    

0080173e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80173e:	f3 0f 1e fb          	endbr32 
  801742:	55                   	push   %ebp
  801743:	89 e5                	mov    %esp,%ebp
  801745:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  801748:	6a 00                	push   $0x0
  80174a:	ff 75 14             	pushl  0x14(%ebp)
  80174d:	ff 75 10             	pushl  0x10(%ebp)
  801750:	ff 75 0c             	pushl  0xc(%ebp)
  801753:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801756:	ba 00 00 00 00       	mov    $0x0,%edx
  80175b:	b8 0c 00 00 00       	mov    $0xc,%eax
  801760:	e8 d7 fd ff ff       	call   80153c <syscall>
}
  801765:	c9                   	leave  
  801766:	c3                   	ret    

00801767 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  801767:	f3 0f 1e fb          	endbr32 
  80176b:	55                   	push   %ebp
  80176c:	89 e5                	mov    %esp,%ebp
  80176e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  801771:	6a 00                	push   $0x0
  801773:	6a 00                	push   $0x0
  801775:	6a 00                	push   $0x0
  801777:	6a 00                	push   $0x0
  801779:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80177c:	ba 01 00 00 00       	mov    $0x1,%edx
  801781:	b8 0d 00 00 00       	mov    $0xd,%eax
  801786:	e8 b1 fd ff ff       	call   80153c <syscall>
}
  80178b:	c9                   	leave  
  80178c:	c3                   	ret    

0080178d <duppage>:
// Returns: 0 on success, < 0 on error.
// It is also OK to panic on error.
//
static int
duppage(envid_t envid, unsigned pn)
{
  80178d:	55                   	push   %ebp
  80178e:	89 e5                	mov    %esp,%ebp
  801790:	53                   	push   %ebx
  801791:	83 ec 04             	sub    $0x4,%esp
  801794:	89 d3                	mov    %edx,%ebx
	int r;

	// LAB 4: Your code here.

	// Page Table Entry
	pte_t pt_e = uvpt[pn];
  801796:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	// Obtenemos la virtual address
	void *v_add = (void *) (pn << PTXSHIFT);
  80179d:	c1 e3 0c             	shl    $0xc,%ebx

	if (pt_e & PTE_SHARE) {
  8017a0:	f6 c6 04             	test   $0x4,%dh
  8017a3:	75 54                	jne    8017f9 <duppage+0x6c>
		// Permisos compartidos
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
		if (r < 0)
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	} else if ((pt_e & PTE_W) || (pt_e & PTE_COW)) {
  8017a5:	f7 c2 02 08 00 00    	test   $0x802,%edx
  8017ab:	0f 84 8d 00 00 00    	je     80183e <duppage+0xb1>
		// Copy on write
		r = sys_page_map(0, v_add, envid, v_add, PTE_COW | PTE_U | PTE_P);
  8017b1:	83 ec 0c             	sub    $0xc,%esp
  8017b4:	68 05 08 00 00       	push   $0x805
  8017b9:	53                   	push   %ebx
  8017ba:	50                   	push   %eax
  8017bb:	53                   	push   %ebx
  8017bc:	6a 00                	push   $0x0
  8017be:	e8 b5 fe ff ff       	call   801678 <sys_page_map>
		if (r < 0)
  8017c3:	83 c4 20             	add    $0x20,%esp
  8017c6:	85 c0                	test   %eax,%eax
  8017c8:	78 5f                	js     801829 <duppage+0x9c>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);

		r = sys_page_map(0, v_add, 0, v_add, PTE_COW | PTE_U | PTE_P);
  8017ca:	83 ec 0c             	sub    $0xc,%esp
  8017cd:	68 05 08 00 00       	push   $0x805
  8017d2:	53                   	push   %ebx
  8017d3:	6a 00                	push   $0x0
  8017d5:	53                   	push   %ebx
  8017d6:	6a 00                	push   $0x0
  8017d8:	e8 9b fe ff ff       	call   801678 <sys_page_map>
		if (r < 0)
  8017dd:	83 c4 20             	add    $0x20,%esp
  8017e0:	85 c0                	test   %eax,%eax
  8017e2:	79 70                	jns    801854 <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  8017e4:	50                   	push   %eax
  8017e5:	68 1c 3b 80 00       	push   $0x803b1c
  8017ea:	68 9b 00 00 00       	push   $0x9b
  8017ef:	68 8a 3c 80 00       	push   $0x803c8a
  8017f4:	e8 8a f2 ff ff       	call   800a83 <_panic>
		r = sys_page_map(0, v_add, envid, v_add, pt_e & PTE_SYSCALL);
  8017f9:	83 ec 0c             	sub    $0xc,%esp
  8017fc:	81 e2 07 0e 00 00    	and    $0xe07,%edx
  801802:	52                   	push   %edx
  801803:	53                   	push   %ebx
  801804:	50                   	push   %eax
  801805:	53                   	push   %ebx
  801806:	6a 00                	push   $0x0
  801808:	e8 6b fe ff ff       	call   801678 <sys_page_map>
		if (r < 0)
  80180d:	83 c4 20             	add    $0x20,%esp
  801810:	85 c0                	test   %eax,%eax
  801812:	79 40                	jns    801854 <duppage+0xc7>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  801814:	50                   	push   %eax
  801815:	68 1c 3b 80 00       	push   $0x803b1c
  80181a:	68 92 00 00 00       	push   $0x92
  80181f:	68 8a 3c 80 00       	push   $0x803c8a
  801824:	e8 5a f2 ff ff       	call   800a83 <_panic>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  801829:	50                   	push   %eax
  80182a:	68 1c 3b 80 00       	push   $0x803b1c
  80182f:	68 97 00 00 00       	push   $0x97
  801834:	68 8a 3c 80 00       	push   $0x803c8a
  801839:	e8 45 f2 ff ff       	call   800a83 <_panic>
	} else {
		// En caso de lectura, compartir.
		r = sys_page_map(0, v_add, envid, v_add, PTE_U | PTE_P);
  80183e:	83 ec 0c             	sub    $0xc,%esp
  801841:	6a 05                	push   $0x5
  801843:	53                   	push   %ebx
  801844:	50                   	push   %eax
  801845:	53                   	push   %ebx
  801846:	6a 00                	push   $0x0
  801848:	e8 2b fe ff ff       	call   801678 <sys_page_map>
		if (r < 0)
  80184d:	83 c4 20             	add    $0x20,%esp
  801850:	85 c0                	test   %eax,%eax
  801852:	78 0a                	js     80185e <duppage+0xd1>
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
	}
	return 0;
}
  801854:	b8 00 00 00 00       	mov    $0x0,%eax
  801859:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80185c:	c9                   	leave  
  80185d:	c3                   	ret    
			panic("ERROR EN DUPAGE: sys_page_map: %e", r);
  80185e:	50                   	push   %eax
  80185f:	68 1c 3b 80 00       	push   $0x803b1c
  801864:	68 a0 00 00 00       	push   $0xa0
  801869:	68 8a 3c 80 00       	push   $0x803c8a
  80186e:	e8 10 f2 ff ff       	call   800a83 <_panic>

00801873 <dup_or_share>:
{
  801873:	55                   	push   %ebp
  801874:	89 e5                	mov    %esp,%ebp
  801876:	57                   	push   %edi
  801877:	56                   	push   %esi
  801878:	53                   	push   %ebx
  801879:	83 ec 0c             	sub    $0xc,%esp
  80187c:	89 c7                	mov    %eax,%edi
  80187e:	89 d6                	mov    %edx,%esi
  801880:	89 cb                	mov    %ecx,%ebx
	if (perm & PTE_W) {
  801882:	f6 c1 02             	test   $0x2,%cl
  801885:	0f 84 90 00 00 00    	je     80191b <dup_or_share+0xa8>
		if ((r = sys_page_alloc(dstenv, va, perm)) < 0)
  80188b:	83 ec 04             	sub    $0x4,%esp
  80188e:	51                   	push   %ecx
  80188f:	52                   	push   %edx
  801890:	50                   	push   %eax
  801891:	e8 ba fd ff ff       	call   801650 <sys_page_alloc>
  801896:	83 c4 10             	add    $0x10,%esp
  801899:	85 c0                	test   %eax,%eax
  80189b:	78 56                	js     8018f3 <dup_or_share+0x80>
		if ((r = sys_page_map(dstenv, va, 0, UTEMP, perm)) < 0)
  80189d:	83 ec 0c             	sub    $0xc,%esp
  8018a0:	53                   	push   %ebx
  8018a1:	68 00 00 40 00       	push   $0x400000
  8018a6:	6a 00                	push   $0x0
  8018a8:	56                   	push   %esi
  8018a9:	57                   	push   %edi
  8018aa:	e8 c9 fd ff ff       	call   801678 <sys_page_map>
  8018af:	83 c4 20             	add    $0x20,%esp
  8018b2:	85 c0                	test   %eax,%eax
  8018b4:	78 51                	js     801907 <dup_or_share+0x94>
		memmove(UTEMP, va, PGSIZE);
  8018b6:	83 ec 04             	sub    $0x4,%esp
  8018b9:	68 00 10 00 00       	push   $0x1000
  8018be:	56                   	push   %esi
  8018bf:	68 00 00 40 00       	push   $0x400000
  8018c4:	e8 b7 fa ff ff       	call   801380 <memmove>
		if ((r = sys_page_unmap(0, UTEMP)) < 0)
  8018c9:	83 c4 08             	add    $0x8,%esp
  8018cc:	68 00 00 40 00       	push   $0x400000
  8018d1:	6a 00                	push   $0x0
  8018d3:	e8 ca fd ff ff       	call   8016a2 <sys_page_unmap>
  8018d8:	83 c4 10             	add    $0x10,%esp
  8018db:	85 c0                	test   %eax,%eax
  8018dd:	79 51                	jns    801930 <dup_or_share+0xbd>
			panic("sys_page_unmap failed at dup_or_share");
  8018df:	83 ec 04             	sub    $0x4,%esp
  8018e2:	68 8c 3b 80 00       	push   $0x803b8c
  8018e7:	6a 18                	push   $0x18
  8018e9:	68 8a 3c 80 00       	push   $0x803c8a
  8018ee:	e8 90 f1 ff ff       	call   800a83 <_panic>
			panic("sys_page_alloc failed at dup_or_share");
  8018f3:	83 ec 04             	sub    $0x4,%esp
  8018f6:	68 40 3b 80 00       	push   $0x803b40
  8018fb:	6a 13                	push   $0x13
  8018fd:	68 8a 3c 80 00       	push   $0x803c8a
  801902:	e8 7c f1 ff ff       	call   800a83 <_panic>
			panic("sys_page_map failed at dup_or_share");
  801907:	83 ec 04             	sub    $0x4,%esp
  80190a:	68 68 3b 80 00       	push   $0x803b68
  80190f:	6a 15                	push   $0x15
  801911:	68 8a 3c 80 00       	push   $0x803c8a
  801916:	e8 68 f1 ff ff       	call   800a83 <_panic>
		if ((r = sys_page_map(0, va, dstenv, va, perm)) < 0)
  80191b:	83 ec 0c             	sub    $0xc,%esp
  80191e:	51                   	push   %ecx
  80191f:	52                   	push   %edx
  801920:	50                   	push   %eax
  801921:	52                   	push   %edx
  801922:	6a 00                	push   $0x0
  801924:	e8 4f fd ff ff       	call   801678 <sys_page_map>
  801929:	83 c4 20             	add    $0x20,%esp
  80192c:	85 c0                	test   %eax,%eax
  80192e:	78 08                	js     801938 <dup_or_share+0xc5>
}
  801930:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801933:	5b                   	pop    %ebx
  801934:	5e                   	pop    %esi
  801935:	5f                   	pop    %edi
  801936:	5d                   	pop    %ebp
  801937:	c3                   	ret    
			panic("sys_page_map failed at dup_or_share");
  801938:	83 ec 04             	sub    $0x4,%esp
  80193b:	68 68 3b 80 00       	push   $0x803b68
  801940:	6a 1c                	push   $0x1c
  801942:	68 8a 3c 80 00       	push   $0x803c8a
  801947:	e8 37 f1 ff ff       	call   800a83 <_panic>

0080194c <pgfault>:
{
  80194c:	f3 0f 1e fb          	endbr32 
  801950:	55                   	push   %ebp
  801951:	89 e5                	mov    %esp,%ebp
  801953:	53                   	push   %ebx
  801954:	83 ec 04             	sub    $0x4,%esp
  801957:	8b 45 08             	mov    0x8(%ebp),%eax
	void *addr = (void *) utf->utf_fault_va;
  80195a:	8b 18                	mov    (%eax),%ebx
	pte_t pt_e = uvpt[PGNUM(addr)];
  80195c:	89 da                	mov    %ebx,%edx
  80195e:	c1 ea 0c             	shr    $0xc,%edx
  801961:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if ((err & FEC_WR) == 0)
  801968:	f6 40 04 02          	testb  $0x2,0x4(%eax)
  80196c:	74 6e                	je     8019dc <pgfault+0x90>
	if ((pt_e & PTE_COW) == 0)
  80196e:	f6 c6 08             	test   $0x8,%dh
  801971:	74 7d                	je     8019f0 <pgfault+0xa4>
	if ((r = sys_page_alloc(0, (void *) PFTEMP, PTE_P | PTE_W | PTE_U)) < 0)
  801973:	83 ec 04             	sub    $0x4,%esp
  801976:	6a 07                	push   $0x7
  801978:	68 00 f0 7f 00       	push   $0x7ff000
  80197d:	6a 00                	push   $0x0
  80197f:	e8 cc fc ff ff       	call   801650 <sys_page_alloc>
  801984:	83 c4 10             	add    $0x10,%esp
  801987:	85 c0                	test   %eax,%eax
  801989:	78 79                	js     801a04 <pgfault+0xb8>
	addr = (void *) ROUNDDOWN(addr, PGSIZE);
  80198b:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
	memmove(PFTEMP, addr, PGSIZE);
  801991:	83 ec 04             	sub    $0x4,%esp
  801994:	68 00 10 00 00       	push   $0x1000
  801999:	53                   	push   %ebx
  80199a:	68 00 f0 7f 00       	push   $0x7ff000
  80199f:	e8 dc f9 ff ff       	call   801380 <memmove>
	if ((r = sys_page_map(0, (void *) PFTEMP, 0, addr, PTE_P | PTE_W | PTE_U)) <
  8019a4:	c7 04 24 07 00 00 00 	movl   $0x7,(%esp)
  8019ab:	53                   	push   %ebx
  8019ac:	6a 00                	push   $0x0
  8019ae:	68 00 f0 7f 00       	push   $0x7ff000
  8019b3:	6a 00                	push   $0x0
  8019b5:	e8 be fc ff ff       	call   801678 <sys_page_map>
  8019ba:	83 c4 20             	add    $0x20,%esp
  8019bd:	85 c0                	test   %eax,%eax
  8019bf:	78 57                	js     801a18 <pgfault+0xcc>
	if ((r = sys_page_unmap(0, (void *) PFTEMP)) < 0)
  8019c1:	83 ec 08             	sub    $0x8,%esp
  8019c4:	68 00 f0 7f 00       	push   $0x7ff000
  8019c9:	6a 00                	push   $0x0
  8019cb:	e8 d2 fc ff ff       	call   8016a2 <sys_page_unmap>
  8019d0:	83 c4 10             	add    $0x10,%esp
  8019d3:	85 c0                	test   %eax,%eax
  8019d5:	78 55                	js     801a2c <pgfault+0xe0>
}
  8019d7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019da:	c9                   	leave  
  8019db:	c3                   	ret    
		panic("ERROR EN PGFAULT: WRITE");
  8019dc:	83 ec 04             	sub    $0x4,%esp
  8019df:	68 95 3c 80 00       	push   $0x803c95
  8019e4:	6a 5e                	push   $0x5e
  8019e6:	68 8a 3c 80 00       	push   $0x803c8a
  8019eb:	e8 93 f0 ff ff       	call   800a83 <_panic>
		panic("ERROR EN PGFAULT: COPY-ON-WRITE");
  8019f0:	83 ec 04             	sub    $0x4,%esp
  8019f3:	68 b4 3b 80 00       	push   $0x803bb4
  8019f8:	6a 62                	push   $0x62
  8019fa:	68 8a 3c 80 00       	push   $0x803c8a
  8019ff:	e8 7f f0 ff ff       	call   800a83 <_panic>
		panic("pgfault failed");
  801a04:	83 ec 04             	sub    $0x4,%esp
  801a07:	68 ad 3c 80 00       	push   $0x803cad
  801a0c:	6a 6d                	push   $0x6d
  801a0e:	68 8a 3c 80 00       	push   $0x803c8a
  801a13:	e8 6b f0 ff ff       	call   800a83 <_panic>
		panic("pgfault failed");
  801a18:	83 ec 04             	sub    $0x4,%esp
  801a1b:	68 ad 3c 80 00       	push   $0x803cad
  801a20:	6a 72                	push   $0x72
  801a22:	68 8a 3c 80 00       	push   $0x803c8a
  801a27:	e8 57 f0 ff ff       	call   800a83 <_panic>
		panic("pgfault failed");
  801a2c:	83 ec 04             	sub    $0x4,%esp
  801a2f:	68 ad 3c 80 00       	push   $0x803cad
  801a34:	6a 74                	push   $0x74
  801a36:	68 8a 3c 80 00       	push   $0x803c8a
  801a3b:	e8 43 f0 ff ff       	call   800a83 <_panic>

00801a40 <fork_v0>:
{
  801a40:	f3 0f 1e fb          	endbr32 
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	57                   	push   %edi
  801a48:	56                   	push   %esi
  801a49:	53                   	push   %ebx
  801a4a:	83 ec 1c             	sub    $0x1c,%esp
// This must be inlined.  Exercise for reader: why?
static inline envid_t __attribute__((always_inline))
sys_exofork(void)
{
	envid_t ret;
	asm volatile("int %2"
  801a4d:	b8 07 00 00 00       	mov    $0x7,%eax
  801a52:	cd 30                	int    $0x30
  801a54:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801a57:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	if (envid < 0)
  801a5a:	85 c0                	test   %eax,%eax
  801a5c:	78 1d                	js     801a7b <fork_v0+0x3b>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  801a5e:	bb 00 00 80 00       	mov    $0x800000,%ebx
	if (envid == 0) {
  801a63:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801a67:	74 26                	je     801a8f <fork_v0+0x4f>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  801a69:	be 00 d0 7b ef       	mov    $0xef7bd000,%esi
  801a6e:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
			        (pte_t *) (PGADDR(PDX(uvpt),
  801a74:	bf 00 00 40 ef       	mov    $0xef400000,%edi
  801a79:	eb 4b                	jmp    801ac6 <fork_v0+0x86>
		panic("sys_exofork failed");
  801a7b:	83 ec 04             	sub    $0x4,%esp
  801a7e:	68 bc 3c 80 00       	push   $0x803cbc
  801a83:	6a 2b                	push   $0x2b
  801a85:	68 8a 3c 80 00       	push   $0x803c8a
  801a8a:	e8 f4 ef ff ff       	call   800a83 <_panic>
		thisenv = &envs[ENVX(sys_getenvid())];
  801a8f:	e8 69 fb ff ff       	call   8015fd <sys_getenvid>
  801a94:	25 ff 03 00 00       	and    $0x3ff,%eax
  801a99:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801a9c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801aa1:	a3 24 54 80 00       	mov    %eax,0x805424
		return 0;
  801aa6:	eb 68                	jmp    801b10 <fork_v0+0xd0>
				dup_or_share(envid,
  801aa8:	81 e1 07 0e 00 00    	and    $0xe07,%ecx
  801aae:	89 da                	mov    %ebx,%edx
  801ab0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  801ab3:	e8 bb fd ff ff       	call   801873 <dup_or_share>
	for (addr = (uint8_t *) UTEXT; addr < (uint8_t *) UTOP; addr += PGSIZE) {
  801ab8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  801abe:	81 fb 00 00 c0 ee    	cmp    $0xeec00000,%ebx
  801ac4:	74 36                	je     801afc <fork_v0+0xbc>
		pde_t *pgdirentry = (pde_t *) (PGADDR(
  801ac6:	89 d8                	mov    %ebx,%eax
  801ac8:	c1 e8 16             	shr    $0x16,%eax
  801acb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  801ad2:	09 f2                	or     %esi,%edx
		if ((*pgdirentry) & PTE_P) {
  801ad4:	f6 02 01             	testb  $0x1,(%edx)
  801ad7:	74 df                	je     801ab8 <fork_v0+0x78>
			        (pte_t *) (PGADDR(PDX(uvpt),
  801ad9:	89 da                	mov    %ebx,%edx
  801adb:	c1 ea 0a             	shr    $0xa,%edx
  801ade:	81 e2 fc 0f 00 00    	and    $0xffc,%edx
  801ae4:	c1 e0 0c             	shl    $0xc,%eax
  801ae7:	89 f9                	mov    %edi,%ecx
  801ae9:	81 e1 00 00 c0 ff    	and    $0xffc00000,%ecx
  801aef:	09 c8                	or     %ecx,%eax
  801af1:	09 d0                	or     %edx,%eax
			if ((*pgtablentry) & PTE_P)
  801af3:	8b 08                	mov    (%eax),%ecx
  801af5:	f6 c1 01             	test   $0x1,%cl
  801af8:	74 be                	je     801ab8 <fork_v0+0x78>
  801afa:	eb ac                	jmp    801aa8 <fork_v0+0x68>
	if ((r = sys_env_set_status(envid, ENV_RUNNABLE)) < 0)
  801afc:	83 ec 08             	sub    $0x8,%esp
  801aff:	6a 02                	push   $0x2
  801b01:	ff 75 e0             	pushl  -0x20(%ebp)
  801b04:	e8 c0 fb ff ff       	call   8016c9 <sys_env_set_status>
  801b09:	83 c4 10             	add    $0x10,%esp
  801b0c:	85 c0                	test   %eax,%eax
  801b0e:	78 0b                	js     801b1b <fork_v0+0xdb>
}
  801b10:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801b13:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b16:	5b                   	pop    %ebx
  801b17:	5e                   	pop    %esi
  801b18:	5f                   	pop    %edi
  801b19:	5d                   	pop    %ebp
  801b1a:	c3                   	ret    
		panic("sys_env_set_status failed at fork_v0");
  801b1b:	83 ec 04             	sub    $0x4,%esp
  801b1e:	68 d4 3b 80 00       	push   $0x803bd4
  801b23:	6a 43                	push   $0x43
  801b25:	68 8a 3c 80 00       	push   $0x803c8a
  801b2a:	e8 54 ef ff ff       	call   800a83 <_panic>

00801b2f <fork>:
//   so you must allocate a new page for the child's user exception stack.
//
extern void _pgfault_upcall(void);
envid_t
fork(void)
{
  801b2f:	f3 0f 1e fb          	endbr32 
  801b33:	55                   	push   %ebp
  801b34:	89 e5                	mov    %esp,%ebp
  801b36:	57                   	push   %edi
  801b37:	56                   	push   %esi
  801b38:	53                   	push   %ebx
  801b39:	83 ec 28             	sub    $0x28,%esp
	int err;

	// handle padre
	set_pgfault_handler(pgfault);
  801b3c:	68 4c 19 80 00       	push   $0x80194c
  801b41:	e8 1c 16 00 00       	call   803162 <set_pgfault_handler>
  801b46:	b8 07 00 00 00       	mov    $0x7,%eax
  801b4b:	cd 30                	int    $0x30
  801b4d:	89 45 e0             	mov    %eax,-0x20(%ebp)

	// Proceso hijo
	envid_t e_id = sys_exofork();

	if (e_id < 0)
  801b50:	83 c4 10             	add    $0x10,%esp
  801b53:	85 c0                	test   %eax,%eax
  801b55:	78 2f                	js     801b86 <fork+0x57>
  801b57:	89 c7                	mov    %eax,%edi
  801b59:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
		panic("ERROR EN FORK: sys_exofork: %e", e_id);

	if (e_id == 0) {
  801b60:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801b64:	0f 85 9e 00 00 00    	jne    801c08 <fork+0xd9>
		// Si es hijo
		thisenv = &envs[ENVX(sys_getenvid())];
  801b6a:	e8 8e fa ff ff       	call   8015fd <sys_getenvid>
  801b6f:	25 ff 03 00 00       	and    $0x3ff,%eax
  801b74:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b77:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b7c:	a3 24 54 80 00       	mov    %eax,0x805424
		return 0;
  801b81:	e9 de 00 00 00       	jmp    801c64 <fork+0x135>
		panic("ERROR EN FORK: sys_exofork: %e", e_id);
  801b86:	50                   	push   %eax
  801b87:	68 fc 3b 80 00       	push   $0x803bfc
  801b8c:	68 c2 00 00 00       	push   $0xc2
  801b91:	68 8a 3c 80 00       	push   $0x803c8a
  801b96:	e8 e8 ee ff ff       	call   800a83 <_panic>
		// LOOP PTEs
		while (pt_x < NPTENTRIES) {
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
			pte_t pt_e = uvpt[PGNUM(dir)];
			if (dir == (UXSTACKTOP - PGSIZE)) {
				err = sys_page_alloc(e_id,
  801b9b:	83 ec 04             	sub    $0x4,%esp
  801b9e:	6a 07                	push   $0x7
  801ba0:	68 00 f0 bf ee       	push   $0xeebff000
  801ba5:	57                   	push   %edi
  801ba6:	e8 a5 fa ff ff       	call   801650 <sys_page_alloc>
				                     (void *) dir,
				                     PTE_W | PTE_U | PTE_P);
				if (err)
  801bab:	83 c4 10             	add    $0x10,%esp
  801bae:	85 c0                	test   %eax,%eax
  801bb0:	75 33                	jne    801be5 <fork+0xb6>
  801bb2:	83 c3 01             	add    $0x1,%ebx
		while (pt_x < NPTENTRIES) {
  801bb5:	81 fb 00 04 00 00    	cmp    $0x400,%ebx
  801bbb:	74 3d                	je     801bfa <fork+0xcb>
			uintptr_t dir = (uintptr_t) PGADDR(pd_x, pt_x, 0);
  801bbd:	89 d8                	mov    %ebx,%eax
  801bbf:	c1 e0 0c             	shl    $0xc,%eax
  801bc2:	09 f0                	or     %esi,%eax
			pte_t pt_e = uvpt[PGNUM(dir)];
  801bc4:	89 c2                	mov    %eax,%edx
  801bc6:	c1 ea 0c             	shr    $0xc,%edx
  801bc9:	8b 0c 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%ecx
			if (dir == (UXSTACKTOP - PGSIZE)) {
  801bd0:	3d 00 f0 bf ee       	cmp    $0xeebff000,%eax
  801bd5:	74 c4                	je     801b9b <fork+0x6c>
					      "%e",
					      err);
				pt_x++;
				continue;
			}
			if ((pt_e & PTE_P) == 0) {
  801bd7:	f6 c1 01             	test   $0x1,%cl
  801bda:	74 d6                	je     801bb2 <fork+0x83>
				pt_x++;
				continue;
			}
			duppage(e_id, PGNUM(dir));
  801bdc:	89 f8                	mov    %edi,%eax
  801bde:	e8 aa fb ff ff       	call   80178d <duppage>
  801be3:	eb cd                	jmp    801bb2 <fork+0x83>
					panic("ERROR EN FORK: sys_page_alloc: "
  801be5:	50                   	push   %eax
  801be6:	68 1c 3c 80 00       	push   $0x803c1c
  801beb:	68 e1 00 00 00       	push   $0xe1
  801bf0:	68 8a 3c 80 00       	push   $0x803c8a
  801bf5:	e8 89 ee ff ff       	call   800a83 <_panic>
  801bfa:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
  801bfe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
	while (pd_x < PDX(UTOP)) {
  801c01:	3d bb 03 00 00       	cmp    $0x3bb,%eax
  801c06:	74 18                	je     801c20 <fork+0xf1>
		pde_t pd_e = uvpd[pd_x];
  801c08:	8b 75 e4             	mov    -0x1c(%ebp),%esi
  801c0b:	8b 04 b5 00 d0 7b ef 	mov    -0x10843000(,%esi,4),%eax
		if ((pd_e & PTE_P) == 0) {
  801c12:	a8 01                	test   $0x1,%al
  801c14:	74 e4                	je     801bfa <fork+0xcb>
  801c16:	c1 e6 16             	shl    $0x16,%esi
  801c19:	bb 00 00 00 00       	mov    $0x0,%ebx
  801c1e:	eb 9d                	jmp    801bbd <fork+0x8e>
			pt_x++;
		}
		pd_x++;
	}

	if ((err = sys_page_alloc(e_id,
  801c20:	83 ec 04             	sub    $0x4,%esp
  801c23:	6a 07                	push   $0x7
  801c25:	68 00 f0 bf ee       	push   $0xeebff000
  801c2a:	ff 75 e0             	pushl  -0x20(%ebp)
  801c2d:	e8 1e fa ff ff       	call   801650 <sys_page_alloc>
  801c32:	83 c4 10             	add    $0x10,%esp
  801c35:	85 c0                	test   %eax,%eax
  801c37:	78 36                	js     801c6f <fork+0x140>
	                          (void *) (UXSTACKTOP - PGSIZE),
	                          PTE_P | PTE_U | PTE_W) < 0))
		panic("Error en sys_page_alloc");


	if ((sys_env_set_pgfault_upcall(e_id, _pgfault_upcall) < 0))
  801c39:	83 ec 08             	sub    $0x8,%esp
  801c3c:	68 bd 31 80 00       	push   $0x8031bd
  801c41:	ff 75 e0             	pushl  -0x20(%ebp)
  801c44:	e8 ce fa ff ff       	call   801717 <sys_env_set_pgfault_upcall>
  801c49:	83 c4 10             	add    $0x10,%esp
  801c4c:	85 c0                	test   %eax,%eax
  801c4e:	78 36                	js     801c86 <fork+0x157>
		panic("sys_env_set_pgfault_upcall failed");

	// HIJO RUNNABLE
	if ((err = sys_env_set_status(e_id, ENV_RUNNABLE)) < 0)
  801c50:	83 ec 08             	sub    $0x8,%esp
  801c53:	6a 02                	push   $0x2
  801c55:	ff 75 e0             	pushl  -0x20(%ebp)
  801c58:	e8 6c fa ff ff       	call   8016c9 <sys_env_set_status>
  801c5d:	83 c4 10             	add    $0x10,%esp
  801c60:	85 c0                	test   %eax,%eax
  801c62:	78 39                	js     801c9d <fork+0x16e>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);

	return e_id;
}
  801c64:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801c67:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801c6a:	5b                   	pop    %ebx
  801c6b:	5e                   	pop    %esi
  801c6c:	5f                   	pop    %edi
  801c6d:	5d                   	pop    %ebp
  801c6e:	c3                   	ret    
		panic("Error en sys_page_alloc");
  801c6f:	83 ec 04             	sub    $0x4,%esp
  801c72:	68 cf 3c 80 00       	push   $0x803ccf
  801c77:	68 f4 00 00 00       	push   $0xf4
  801c7c:	68 8a 3c 80 00       	push   $0x803c8a
  801c81:	e8 fd ed ff ff       	call   800a83 <_panic>
		panic("sys_env_set_pgfault_upcall failed");
  801c86:	83 ec 04             	sub    $0x4,%esp
  801c89:	68 40 3c 80 00       	push   $0x803c40
  801c8e:	68 f8 00 00 00       	push   $0xf8
  801c93:	68 8a 3c 80 00       	push   $0x803c8a
  801c98:	e8 e6 ed ff ff       	call   800a83 <_panic>
		panic("ERROR EN FORK: sys_env_set_status: %e", err);
  801c9d:	50                   	push   %eax
  801c9e:	68 64 3c 80 00       	push   $0x803c64
  801ca3:	68 fc 00 00 00       	push   $0xfc
  801ca8:	68 8a 3c 80 00       	push   $0x803c8a
  801cad:	e8 d1 ed ff ff       	call   800a83 <_panic>

00801cb2 <sfork>:

// Challenge!
int
sfork(void)
{
  801cb2:	f3 0f 1e fb          	endbr32 
  801cb6:	55                   	push   %ebp
  801cb7:	89 e5                	mov    %esp,%ebp
  801cb9:	83 ec 0c             	sub    $0xc,%esp
	panic("sfork not implemented");
  801cbc:	68 e7 3c 80 00       	push   $0x803ce7
  801cc1:	68 05 01 00 00       	push   $0x105
  801cc6:	68 8a 3c 80 00       	push   $0x803c8a
  801ccb:	e8 b3 ed ff ff       	call   800a83 <_panic>

00801cd0 <argstart>:
#include <inc/args.h>
#include <inc/string.h>

void
argstart(int *argc, char **argv, struct Argstate *args)
{
  801cd0:	f3 0f 1e fb          	endbr32 
  801cd4:	55                   	push   %ebp
  801cd5:	89 e5                	mov    %esp,%ebp
  801cd7:	8b 55 08             	mov    0x8(%ebp),%edx
  801cda:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801cdd:	8b 45 10             	mov    0x10(%ebp),%eax
	args->argc = argc;
  801ce0:	89 10                	mov    %edx,(%eax)
	args->argv = (const char **) argv;
  801ce2:	89 48 04             	mov    %ecx,0x4(%eax)
	args->curarg = (*argc > 1 && argv ? "" : 0);
  801ce5:	83 3a 01             	cmpl   $0x1,(%edx)
  801ce8:	7e 09                	jle    801cf3 <argstart+0x23>
  801cea:	ba c1 35 80 00       	mov    $0x8035c1,%edx
  801cef:	85 c9                	test   %ecx,%ecx
  801cf1:	75 05                	jne    801cf8 <argstart+0x28>
  801cf3:	ba 00 00 00 00       	mov    $0x0,%edx
  801cf8:	89 50 08             	mov    %edx,0x8(%eax)
	args->argvalue = 0;
  801cfb:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
}
  801d02:	5d                   	pop    %ebp
  801d03:	c3                   	ret    

00801d04 <argnext>:

int
argnext(struct Argstate *args)
{
  801d04:	f3 0f 1e fb          	endbr32 
  801d08:	55                   	push   %ebp
  801d09:	89 e5                	mov    %esp,%ebp
  801d0b:	53                   	push   %ebx
  801d0c:	83 ec 04             	sub    $0x4,%esp
  801d0f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int arg;

	args->argvalue = 0;
  801d12:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)

	// Done processing arguments if args->curarg == 0
	if (args->curarg == 0)
  801d19:	8b 43 08             	mov    0x8(%ebx),%eax
  801d1c:	85 c0                	test   %eax,%eax
  801d1e:	74 74                	je     801d94 <argnext+0x90>
		return -1;

	if (!*args->curarg) {
  801d20:	80 38 00             	cmpb   $0x0,(%eax)
  801d23:	75 48                	jne    801d6d <argnext+0x69>
		// Need to process the next argument
		// Check for end of argument list
		if (*args->argc == 1
  801d25:	8b 0b                	mov    (%ebx),%ecx
  801d27:	83 39 01             	cmpl   $0x1,(%ecx)
  801d2a:	74 5a                	je     801d86 <argnext+0x82>
		    || args->argv[1][0] != '-'
  801d2c:	8b 53 04             	mov    0x4(%ebx),%edx
  801d2f:	8b 42 04             	mov    0x4(%edx),%eax
  801d32:	80 38 2d             	cmpb   $0x2d,(%eax)
  801d35:	75 4f                	jne    801d86 <argnext+0x82>
		    || args->argv[1][1] == '\0')
  801d37:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801d3b:	74 49                	je     801d86 <argnext+0x82>
			goto endofargs;
		// Shift arguments down one
		args->curarg = args->argv[1] + 1;
  801d3d:	83 c0 01             	add    $0x1,%eax
  801d40:	89 43 08             	mov    %eax,0x8(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801d43:	83 ec 04             	sub    $0x4,%esp
  801d46:	8b 01                	mov    (%ecx),%eax
  801d48:	8d 04 85 fc ff ff ff 	lea    -0x4(,%eax,4),%eax
  801d4f:	50                   	push   %eax
  801d50:	8d 42 08             	lea    0x8(%edx),%eax
  801d53:	50                   	push   %eax
  801d54:	83 c2 04             	add    $0x4,%edx
  801d57:	52                   	push   %edx
  801d58:	e8 23 f6 ff ff       	call   801380 <memmove>
		(*args->argc)--;
  801d5d:	8b 03                	mov    (%ebx),%eax
  801d5f:	83 28 01             	subl   $0x1,(%eax)
		// Check for "--": end of argument list
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801d62:	8b 43 08             	mov    0x8(%ebx),%eax
  801d65:	83 c4 10             	add    $0x10,%esp
  801d68:	80 38 2d             	cmpb   $0x2d,(%eax)
  801d6b:	74 13                	je     801d80 <argnext+0x7c>
			goto endofargs;
	}

	arg = (unsigned char) *args->curarg;
  801d6d:	8b 43 08             	mov    0x8(%ebx),%eax
  801d70:	0f b6 10             	movzbl (%eax),%edx
	args->curarg++;
  801d73:	83 c0 01             	add    $0x1,%eax
  801d76:	89 43 08             	mov    %eax,0x8(%ebx)
	return arg;

    endofargs:
	args->curarg = 0;
	return -1;
}
  801d79:	89 d0                	mov    %edx,%eax
  801d7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801d7e:	c9                   	leave  
  801d7f:	c3                   	ret    
		if (args->curarg[0] == '-' && args->curarg[1] == '\0')
  801d80:	80 78 01 00          	cmpb   $0x0,0x1(%eax)
  801d84:	75 e7                	jne    801d6d <argnext+0x69>
	args->curarg = 0;
  801d86:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
	return -1;
  801d8d:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801d92:	eb e5                	jmp    801d79 <argnext+0x75>
		return -1;
  801d94:	ba ff ff ff ff       	mov    $0xffffffff,%edx
  801d99:	eb de                	jmp    801d79 <argnext+0x75>

00801d9b <argnextvalue>:
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
}

char *
argnextvalue(struct Argstate *args)
{
  801d9b:	f3 0f 1e fb          	endbr32 
  801d9f:	55                   	push   %ebp
  801da0:	89 e5                	mov    %esp,%ebp
  801da2:	53                   	push   %ebx
  801da3:	83 ec 04             	sub    $0x4,%esp
  801da6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	if (!args->curarg)
  801da9:	8b 43 08             	mov    0x8(%ebx),%eax
  801dac:	85 c0                	test   %eax,%eax
  801dae:	74 12                	je     801dc2 <argnextvalue+0x27>
		return 0;
	if (*args->curarg) {
  801db0:	80 38 00             	cmpb   $0x0,(%eax)
  801db3:	74 12                	je     801dc7 <argnextvalue+0x2c>
		args->argvalue = args->curarg;
  801db5:	89 43 0c             	mov    %eax,0xc(%ebx)
		args->curarg = "";
  801db8:	c7 43 08 c1 35 80 00 	movl   $0x8035c1,0x8(%ebx)
		(*args->argc)--;
	} else {
		args->argvalue = 0;
		args->curarg = 0;
	}
	return (char*) args->argvalue;
  801dbf:	8b 43 0c             	mov    0xc(%ebx),%eax
}
  801dc2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801dc5:	c9                   	leave  
  801dc6:	c3                   	ret    
	} else if (*args->argc > 1) {
  801dc7:	8b 13                	mov    (%ebx),%edx
  801dc9:	83 3a 01             	cmpl   $0x1,(%edx)
  801dcc:	7f 10                	jg     801dde <argnextvalue+0x43>
		args->argvalue = 0;
  801dce:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
		args->curarg = 0;
  801dd5:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  801ddc:	eb e1                	jmp    801dbf <argnextvalue+0x24>
		args->argvalue = args->argv[1];
  801dde:	8b 43 04             	mov    0x4(%ebx),%eax
  801de1:	8b 48 04             	mov    0x4(%eax),%ecx
  801de4:	89 4b 0c             	mov    %ecx,0xc(%ebx)
		memmove(args->argv + 1, args->argv + 2, sizeof(const char *) * (*args->argc - 1));
  801de7:	83 ec 04             	sub    $0x4,%esp
  801dea:	8b 12                	mov    (%edx),%edx
  801dec:	8d 14 95 fc ff ff ff 	lea    -0x4(,%edx,4),%edx
  801df3:	52                   	push   %edx
  801df4:	8d 50 08             	lea    0x8(%eax),%edx
  801df7:	52                   	push   %edx
  801df8:	83 c0 04             	add    $0x4,%eax
  801dfb:	50                   	push   %eax
  801dfc:	e8 7f f5 ff ff       	call   801380 <memmove>
		(*args->argc)--;
  801e01:	8b 03                	mov    (%ebx),%eax
  801e03:	83 28 01             	subl   $0x1,(%eax)
  801e06:	83 c4 10             	add    $0x10,%esp
  801e09:	eb b4                	jmp    801dbf <argnextvalue+0x24>

00801e0b <argvalue>:
{
  801e0b:	f3 0f 1e fb          	endbr32 
  801e0f:	55                   	push   %ebp
  801e10:	89 e5                	mov    %esp,%ebp
  801e12:	83 ec 08             	sub    $0x8,%esp
  801e15:	8b 55 08             	mov    0x8(%ebp),%edx
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801e18:	8b 42 0c             	mov    0xc(%edx),%eax
  801e1b:	85 c0                	test   %eax,%eax
  801e1d:	74 02                	je     801e21 <argvalue+0x16>
}
  801e1f:	c9                   	leave  
  801e20:	c3                   	ret    
	return (char*) (args->argvalue ? args->argvalue : argnextvalue(args));
  801e21:	83 ec 0c             	sub    $0xc,%esp
  801e24:	52                   	push   %edx
  801e25:	e8 71 ff ff ff       	call   801d9b <argnextvalue>
  801e2a:	83 c4 10             	add    $0x10,%esp
  801e2d:	eb f0                	jmp    801e1f <argvalue+0x14>

00801e2f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  801e2f:	f3 0f 1e fb          	endbr32 
  801e33:	55                   	push   %ebp
  801e34:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801e36:	8b 45 08             	mov    0x8(%ebp),%eax
  801e39:	05 00 00 00 30       	add    $0x30000000,%eax
  801e3e:	c1 e8 0c             	shr    $0xc,%eax
}
  801e41:	5d                   	pop    %ebp
  801e42:	c3                   	ret    

00801e43 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  801e43:	f3 0f 1e fb          	endbr32 
  801e47:	55                   	push   %ebp
  801e48:	89 e5                	mov    %esp,%ebp
  801e4a:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  801e4d:	ff 75 08             	pushl  0x8(%ebp)
  801e50:	e8 da ff ff ff       	call   801e2f <fd2num>
  801e55:	83 c4 10             	add    $0x10,%esp
  801e58:	c1 e0 0c             	shl    $0xc,%eax
  801e5b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  801e60:	c9                   	leave  
  801e61:	c3                   	ret    

00801e62 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  801e62:	f3 0f 1e fb          	endbr32 
  801e66:	55                   	push   %ebp
  801e67:	89 e5                	mov    %esp,%ebp
  801e69:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  801e6e:	89 c2                	mov    %eax,%edx
  801e70:	c1 ea 16             	shr    $0x16,%edx
  801e73:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801e7a:	f6 c2 01             	test   $0x1,%dl
  801e7d:	74 2d                	je     801eac <fd_alloc+0x4a>
  801e7f:	89 c2                	mov    %eax,%edx
  801e81:	c1 ea 0c             	shr    $0xc,%edx
  801e84:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801e8b:	f6 c2 01             	test   $0x1,%dl
  801e8e:	74 1c                	je     801eac <fd_alloc+0x4a>
  801e90:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801e95:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801e9a:	75 d2                	jne    801e6e <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801e9c:	8b 45 08             	mov    0x8(%ebp),%eax
  801e9f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801ea5:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801eaa:	eb 0a                	jmp    801eb6 <fd_alloc+0x54>
			*fd_store = fd;
  801eac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801eaf:	89 01                	mov    %eax,(%ecx)
			return 0;
  801eb1:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801eb6:	5d                   	pop    %ebp
  801eb7:	c3                   	ret    

00801eb8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  801eb8:	f3 0f 1e fb          	endbr32 
  801ebc:	55                   	push   %ebp
  801ebd:	89 e5                	mov    %esp,%ebp
  801ebf:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  801ec2:	83 f8 1f             	cmp    $0x1f,%eax
  801ec5:	77 30                	ja     801ef7 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  801ec7:	c1 e0 0c             	shl    $0xc,%eax
  801eca:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  801ecf:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  801ed5:	f6 c2 01             	test   $0x1,%dl
  801ed8:	74 24                	je     801efe <fd_lookup+0x46>
  801eda:	89 c2                	mov    %eax,%edx
  801edc:	c1 ea 0c             	shr    $0xc,%edx
  801edf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801ee6:	f6 c2 01             	test   $0x1,%dl
  801ee9:	74 1a                	je     801f05 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  801eeb:	8b 55 0c             	mov    0xc(%ebp),%edx
  801eee:	89 02                	mov    %eax,(%edx)
	return 0;
  801ef0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ef5:	5d                   	pop    %ebp
  801ef6:	c3                   	ret    
		return -E_INVAL;
  801ef7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801efc:	eb f7                	jmp    801ef5 <fd_lookup+0x3d>
		return -E_INVAL;
  801efe:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801f03:	eb f0                	jmp    801ef5 <fd_lookup+0x3d>
  801f05:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801f0a:	eb e9                	jmp    801ef5 <fd_lookup+0x3d>

00801f0c <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  801f0c:	f3 0f 1e fb          	endbr32 
  801f10:	55                   	push   %ebp
  801f11:	89 e5                	mov    %esp,%ebp
  801f13:	83 ec 08             	sub    $0x8,%esp
  801f16:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f19:	ba 7c 3d 80 00       	mov    $0x803d7c,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  801f1e:	b8 20 40 80 00       	mov    $0x804020,%eax
		if (devtab[i]->dev_id == dev_id) {
  801f23:	39 08                	cmp    %ecx,(%eax)
  801f25:	74 33                	je     801f5a <dev_lookup+0x4e>
  801f27:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801f2a:	8b 02                	mov    (%edx),%eax
  801f2c:	85 c0                	test   %eax,%eax
  801f2e:	75 f3                	jne    801f23 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  801f30:	a1 24 54 80 00       	mov    0x805424,%eax
  801f35:	8b 40 48             	mov    0x48(%eax),%eax
  801f38:	83 ec 04             	sub    $0x4,%esp
  801f3b:	51                   	push   %ecx
  801f3c:	50                   	push   %eax
  801f3d:	68 00 3d 80 00       	push   $0x803d00
  801f42:	e8 23 ec ff ff       	call   800b6a <cprintf>
	*dev = 0;
  801f47:	8b 45 0c             	mov    0xc(%ebp),%eax
  801f4a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  801f50:	83 c4 10             	add    $0x10,%esp
  801f53:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801f58:	c9                   	leave  
  801f59:	c3                   	ret    
			*dev = devtab[i];
  801f5a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801f5d:	89 01                	mov    %eax,(%ecx)
			return 0;
  801f5f:	b8 00 00 00 00       	mov    $0x0,%eax
  801f64:	eb f2                	jmp    801f58 <dev_lookup+0x4c>

00801f66 <fd_close>:
{
  801f66:	f3 0f 1e fb          	endbr32 
  801f6a:	55                   	push   %ebp
  801f6b:	89 e5                	mov    %esp,%ebp
  801f6d:	57                   	push   %edi
  801f6e:	56                   	push   %esi
  801f6f:	53                   	push   %ebx
  801f70:	83 ec 28             	sub    $0x28,%esp
  801f73:	8b 75 08             	mov    0x8(%ebp),%esi
  801f76:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801f79:	56                   	push   %esi
  801f7a:	e8 b0 fe ff ff       	call   801e2f <fd2num>
  801f7f:	83 c4 08             	add    $0x8,%esp
  801f82:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801f85:	52                   	push   %edx
  801f86:	50                   	push   %eax
  801f87:	e8 2c ff ff ff       	call   801eb8 <fd_lookup>
  801f8c:	89 c3                	mov    %eax,%ebx
  801f8e:	83 c4 10             	add    $0x10,%esp
  801f91:	85 c0                	test   %eax,%eax
  801f93:	78 05                	js     801f9a <fd_close+0x34>
	    || fd != fd2)
  801f95:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801f98:	74 16                	je     801fb0 <fd_close+0x4a>
		return (must_exist ? r : 0);
  801f9a:	89 f8                	mov    %edi,%eax
  801f9c:	84 c0                	test   %al,%al
  801f9e:	b8 00 00 00 00       	mov    $0x0,%eax
  801fa3:	0f 44 d8             	cmove  %eax,%ebx
}
  801fa6:	89 d8                	mov    %ebx,%eax
  801fa8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801fab:	5b                   	pop    %ebx
  801fac:	5e                   	pop    %esi
  801fad:	5f                   	pop    %edi
  801fae:	5d                   	pop    %ebp
  801faf:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  801fb0:	83 ec 08             	sub    $0x8,%esp
  801fb3:	8d 45 e0             	lea    -0x20(%ebp),%eax
  801fb6:	50                   	push   %eax
  801fb7:	ff 36                	pushl  (%esi)
  801fb9:	e8 4e ff ff ff       	call   801f0c <dev_lookup>
  801fbe:	89 c3                	mov    %eax,%ebx
  801fc0:	83 c4 10             	add    $0x10,%esp
  801fc3:	85 c0                	test   %eax,%eax
  801fc5:	78 1a                	js     801fe1 <fd_close+0x7b>
		if (dev->dev_close)
  801fc7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801fca:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  801fcd:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  801fd2:	85 c0                	test   %eax,%eax
  801fd4:	74 0b                	je     801fe1 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  801fd6:	83 ec 0c             	sub    $0xc,%esp
  801fd9:	56                   	push   %esi
  801fda:	ff d0                	call   *%eax
  801fdc:	89 c3                	mov    %eax,%ebx
  801fde:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  801fe1:	83 ec 08             	sub    $0x8,%esp
  801fe4:	56                   	push   %esi
  801fe5:	6a 00                	push   $0x0
  801fe7:	e8 b6 f6 ff ff       	call   8016a2 <sys_page_unmap>
	return r;
  801fec:	83 c4 10             	add    $0x10,%esp
  801fef:	eb b5                	jmp    801fa6 <fd_close+0x40>

00801ff1 <close>:

int
close(int fdnum)
{
  801ff1:	f3 0f 1e fb          	endbr32 
  801ff5:	55                   	push   %ebp
  801ff6:	89 e5                	mov    %esp,%ebp
  801ff8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801ffb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801ffe:	50                   	push   %eax
  801fff:	ff 75 08             	pushl  0x8(%ebp)
  802002:	e8 b1 fe ff ff       	call   801eb8 <fd_lookup>
  802007:	83 c4 10             	add    $0x10,%esp
  80200a:	85 c0                	test   %eax,%eax
  80200c:	79 02                	jns    802010 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  80200e:	c9                   	leave  
  80200f:	c3                   	ret    
		return fd_close(fd, 1);
  802010:	83 ec 08             	sub    $0x8,%esp
  802013:	6a 01                	push   $0x1
  802015:	ff 75 f4             	pushl  -0xc(%ebp)
  802018:	e8 49 ff ff ff       	call   801f66 <fd_close>
  80201d:	83 c4 10             	add    $0x10,%esp
  802020:	eb ec                	jmp    80200e <close+0x1d>

00802022 <close_all>:

void
close_all(void)
{
  802022:	f3 0f 1e fb          	endbr32 
  802026:	55                   	push   %ebp
  802027:	89 e5                	mov    %esp,%ebp
  802029:	53                   	push   %ebx
  80202a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80202d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  802032:	83 ec 0c             	sub    $0xc,%esp
  802035:	53                   	push   %ebx
  802036:	e8 b6 ff ff ff       	call   801ff1 <close>
	for (i = 0; i < MAXFD; i++)
  80203b:	83 c3 01             	add    $0x1,%ebx
  80203e:	83 c4 10             	add    $0x10,%esp
  802041:	83 fb 20             	cmp    $0x20,%ebx
  802044:	75 ec                	jne    802032 <close_all+0x10>
}
  802046:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802049:	c9                   	leave  
  80204a:	c3                   	ret    

0080204b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80204b:	f3 0f 1e fb          	endbr32 
  80204f:	55                   	push   %ebp
  802050:	89 e5                	mov    %esp,%ebp
  802052:	57                   	push   %edi
  802053:	56                   	push   %esi
  802054:	53                   	push   %ebx
  802055:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  802058:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80205b:	50                   	push   %eax
  80205c:	ff 75 08             	pushl  0x8(%ebp)
  80205f:	e8 54 fe ff ff       	call   801eb8 <fd_lookup>
  802064:	89 c3                	mov    %eax,%ebx
  802066:	83 c4 10             	add    $0x10,%esp
  802069:	85 c0                	test   %eax,%eax
  80206b:	0f 88 81 00 00 00    	js     8020f2 <dup+0xa7>
		return r;
	close(newfdnum);
  802071:	83 ec 0c             	sub    $0xc,%esp
  802074:	ff 75 0c             	pushl  0xc(%ebp)
  802077:	e8 75 ff ff ff       	call   801ff1 <close>

	newfd = INDEX2FD(newfdnum);
  80207c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80207f:	c1 e6 0c             	shl    $0xc,%esi
  802082:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  802088:	83 c4 04             	add    $0x4,%esp
  80208b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80208e:	e8 b0 fd ff ff       	call   801e43 <fd2data>
  802093:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  802095:	89 34 24             	mov    %esi,(%esp)
  802098:	e8 a6 fd ff ff       	call   801e43 <fd2data>
  80209d:	83 c4 10             	add    $0x10,%esp
  8020a0:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8020a2:	89 d8                	mov    %ebx,%eax
  8020a4:	c1 e8 16             	shr    $0x16,%eax
  8020a7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8020ae:	a8 01                	test   $0x1,%al
  8020b0:	74 11                	je     8020c3 <dup+0x78>
  8020b2:	89 d8                	mov    %ebx,%eax
  8020b4:	c1 e8 0c             	shr    $0xc,%eax
  8020b7:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8020be:	f6 c2 01             	test   $0x1,%dl
  8020c1:	75 39                	jne    8020fc <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8020c3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8020c6:	89 d0                	mov    %edx,%eax
  8020c8:	c1 e8 0c             	shr    $0xc,%eax
  8020cb:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8020d2:	83 ec 0c             	sub    $0xc,%esp
  8020d5:	25 07 0e 00 00       	and    $0xe07,%eax
  8020da:	50                   	push   %eax
  8020db:	56                   	push   %esi
  8020dc:	6a 00                	push   $0x0
  8020de:	52                   	push   %edx
  8020df:	6a 00                	push   $0x0
  8020e1:	e8 92 f5 ff ff       	call   801678 <sys_page_map>
  8020e6:	89 c3                	mov    %eax,%ebx
  8020e8:	83 c4 20             	add    $0x20,%esp
  8020eb:	85 c0                	test   %eax,%eax
  8020ed:	78 31                	js     802120 <dup+0xd5>
		goto err;

	return newfdnum;
  8020ef:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8020f2:	89 d8                	mov    %ebx,%eax
  8020f4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8020f7:	5b                   	pop    %ebx
  8020f8:	5e                   	pop    %esi
  8020f9:	5f                   	pop    %edi
  8020fa:	5d                   	pop    %ebp
  8020fb:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8020fc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  802103:	83 ec 0c             	sub    $0xc,%esp
  802106:	25 07 0e 00 00       	and    $0xe07,%eax
  80210b:	50                   	push   %eax
  80210c:	57                   	push   %edi
  80210d:	6a 00                	push   $0x0
  80210f:	53                   	push   %ebx
  802110:	6a 00                	push   $0x0
  802112:	e8 61 f5 ff ff       	call   801678 <sys_page_map>
  802117:	89 c3                	mov    %eax,%ebx
  802119:	83 c4 20             	add    $0x20,%esp
  80211c:	85 c0                	test   %eax,%eax
  80211e:	79 a3                	jns    8020c3 <dup+0x78>
	sys_page_unmap(0, newfd);
  802120:	83 ec 08             	sub    $0x8,%esp
  802123:	56                   	push   %esi
  802124:	6a 00                	push   $0x0
  802126:	e8 77 f5 ff ff       	call   8016a2 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80212b:	83 c4 08             	add    $0x8,%esp
  80212e:	57                   	push   %edi
  80212f:	6a 00                	push   $0x0
  802131:	e8 6c f5 ff ff       	call   8016a2 <sys_page_unmap>
	return r;
  802136:	83 c4 10             	add    $0x10,%esp
  802139:	eb b7                	jmp    8020f2 <dup+0xa7>

0080213b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80213b:	f3 0f 1e fb          	endbr32 
  80213f:	55                   	push   %ebp
  802140:	89 e5                	mov    %esp,%ebp
  802142:	53                   	push   %ebx
  802143:	83 ec 1c             	sub    $0x1c,%esp
  802146:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802149:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80214c:	50                   	push   %eax
  80214d:	53                   	push   %ebx
  80214e:	e8 65 fd ff ff       	call   801eb8 <fd_lookup>
  802153:	83 c4 10             	add    $0x10,%esp
  802156:	85 c0                	test   %eax,%eax
  802158:	78 3f                	js     802199 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80215a:	83 ec 08             	sub    $0x8,%esp
  80215d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802160:	50                   	push   %eax
  802161:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802164:	ff 30                	pushl  (%eax)
  802166:	e8 a1 fd ff ff       	call   801f0c <dev_lookup>
  80216b:	83 c4 10             	add    $0x10,%esp
  80216e:	85 c0                	test   %eax,%eax
  802170:	78 27                	js     802199 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  802172:	8b 55 f0             	mov    -0x10(%ebp),%edx
  802175:	8b 42 08             	mov    0x8(%edx),%eax
  802178:	83 e0 03             	and    $0x3,%eax
  80217b:	83 f8 01             	cmp    $0x1,%eax
  80217e:	74 1e                	je     80219e <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  802180:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802183:	8b 40 08             	mov    0x8(%eax),%eax
  802186:	85 c0                	test   %eax,%eax
  802188:	74 35                	je     8021bf <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80218a:	83 ec 04             	sub    $0x4,%esp
  80218d:	ff 75 10             	pushl  0x10(%ebp)
  802190:	ff 75 0c             	pushl  0xc(%ebp)
  802193:	52                   	push   %edx
  802194:	ff d0                	call   *%eax
  802196:	83 c4 10             	add    $0x10,%esp
}
  802199:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80219c:	c9                   	leave  
  80219d:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80219e:	a1 24 54 80 00       	mov    0x805424,%eax
  8021a3:	8b 40 48             	mov    0x48(%eax),%eax
  8021a6:	83 ec 04             	sub    $0x4,%esp
  8021a9:	53                   	push   %ebx
  8021aa:	50                   	push   %eax
  8021ab:	68 41 3d 80 00       	push   $0x803d41
  8021b0:	e8 b5 e9 ff ff       	call   800b6a <cprintf>
		return -E_INVAL;
  8021b5:	83 c4 10             	add    $0x10,%esp
  8021b8:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8021bd:	eb da                	jmp    802199 <read+0x5e>
		return -E_NOT_SUPP;
  8021bf:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8021c4:	eb d3                	jmp    802199 <read+0x5e>

008021c6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8021c6:	f3 0f 1e fb          	endbr32 
  8021ca:	55                   	push   %ebp
  8021cb:	89 e5                	mov    %esp,%ebp
  8021cd:	57                   	push   %edi
  8021ce:	56                   	push   %esi
  8021cf:	53                   	push   %ebx
  8021d0:	83 ec 0c             	sub    $0xc,%esp
  8021d3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8021d6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8021d9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8021de:	eb 02                	jmp    8021e2 <readn+0x1c>
  8021e0:	01 c3                	add    %eax,%ebx
  8021e2:	39 f3                	cmp    %esi,%ebx
  8021e4:	73 21                	jae    802207 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8021e6:	83 ec 04             	sub    $0x4,%esp
  8021e9:	89 f0                	mov    %esi,%eax
  8021eb:	29 d8                	sub    %ebx,%eax
  8021ed:	50                   	push   %eax
  8021ee:	89 d8                	mov    %ebx,%eax
  8021f0:	03 45 0c             	add    0xc(%ebp),%eax
  8021f3:	50                   	push   %eax
  8021f4:	57                   	push   %edi
  8021f5:	e8 41 ff ff ff       	call   80213b <read>
		if (m < 0)
  8021fa:	83 c4 10             	add    $0x10,%esp
  8021fd:	85 c0                	test   %eax,%eax
  8021ff:	78 04                	js     802205 <readn+0x3f>
			return m;
		if (m == 0)
  802201:	75 dd                	jne    8021e0 <readn+0x1a>
  802203:	eb 02                	jmp    802207 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  802205:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  802207:	89 d8                	mov    %ebx,%eax
  802209:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80220c:	5b                   	pop    %ebx
  80220d:	5e                   	pop    %esi
  80220e:	5f                   	pop    %edi
  80220f:	5d                   	pop    %ebp
  802210:	c3                   	ret    

00802211 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  802211:	f3 0f 1e fb          	endbr32 
  802215:	55                   	push   %ebp
  802216:	89 e5                	mov    %esp,%ebp
  802218:	53                   	push   %ebx
  802219:	83 ec 1c             	sub    $0x1c,%esp
  80221c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80221f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802222:	50                   	push   %eax
  802223:	53                   	push   %ebx
  802224:	e8 8f fc ff ff       	call   801eb8 <fd_lookup>
  802229:	83 c4 10             	add    $0x10,%esp
  80222c:	85 c0                	test   %eax,%eax
  80222e:	78 3a                	js     80226a <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802230:	83 ec 08             	sub    $0x8,%esp
  802233:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802236:	50                   	push   %eax
  802237:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80223a:	ff 30                	pushl  (%eax)
  80223c:	e8 cb fc ff ff       	call   801f0c <dev_lookup>
  802241:	83 c4 10             	add    $0x10,%esp
  802244:	85 c0                	test   %eax,%eax
  802246:	78 22                	js     80226a <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  802248:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80224b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80224f:	74 1e                	je     80226f <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  802251:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802254:	8b 52 0c             	mov    0xc(%edx),%edx
  802257:	85 d2                	test   %edx,%edx
  802259:	74 35                	je     802290 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80225b:	83 ec 04             	sub    $0x4,%esp
  80225e:	ff 75 10             	pushl  0x10(%ebp)
  802261:	ff 75 0c             	pushl  0xc(%ebp)
  802264:	50                   	push   %eax
  802265:	ff d2                	call   *%edx
  802267:	83 c4 10             	add    $0x10,%esp
}
  80226a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80226d:	c9                   	leave  
  80226e:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80226f:	a1 24 54 80 00       	mov    0x805424,%eax
  802274:	8b 40 48             	mov    0x48(%eax),%eax
  802277:	83 ec 04             	sub    $0x4,%esp
  80227a:	53                   	push   %ebx
  80227b:	50                   	push   %eax
  80227c:	68 5d 3d 80 00       	push   $0x803d5d
  802281:	e8 e4 e8 ff ff       	call   800b6a <cprintf>
		return -E_INVAL;
  802286:	83 c4 10             	add    $0x10,%esp
  802289:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80228e:	eb da                	jmp    80226a <write+0x59>
		return -E_NOT_SUPP;
  802290:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802295:	eb d3                	jmp    80226a <write+0x59>

00802297 <seek>:

int
seek(int fdnum, off_t offset)
{
  802297:	f3 0f 1e fb          	endbr32 
  80229b:	55                   	push   %ebp
  80229c:	89 e5                	mov    %esp,%ebp
  80229e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8022a1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022a4:	50                   	push   %eax
  8022a5:	ff 75 08             	pushl  0x8(%ebp)
  8022a8:	e8 0b fc ff ff       	call   801eb8 <fd_lookup>
  8022ad:	83 c4 10             	add    $0x10,%esp
  8022b0:	85 c0                	test   %eax,%eax
  8022b2:	78 0e                	js     8022c2 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8022b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8022b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8022ba:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8022bd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8022c2:	c9                   	leave  
  8022c3:	c3                   	ret    

008022c4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8022c4:	f3 0f 1e fb          	endbr32 
  8022c8:	55                   	push   %ebp
  8022c9:	89 e5                	mov    %esp,%ebp
  8022cb:	53                   	push   %ebx
  8022cc:	83 ec 1c             	sub    $0x1c,%esp
  8022cf:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8022d2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8022d5:	50                   	push   %eax
  8022d6:	53                   	push   %ebx
  8022d7:	e8 dc fb ff ff       	call   801eb8 <fd_lookup>
  8022dc:	83 c4 10             	add    $0x10,%esp
  8022df:	85 c0                	test   %eax,%eax
  8022e1:	78 37                	js     80231a <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8022e3:	83 ec 08             	sub    $0x8,%esp
  8022e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8022e9:	50                   	push   %eax
  8022ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022ed:	ff 30                	pushl  (%eax)
  8022ef:	e8 18 fc ff ff       	call   801f0c <dev_lookup>
  8022f4:	83 c4 10             	add    $0x10,%esp
  8022f7:	85 c0                	test   %eax,%eax
  8022f9:	78 1f                	js     80231a <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8022fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8022fe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  802302:	74 1b                	je     80231f <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  802304:	8b 55 f4             	mov    -0xc(%ebp),%edx
  802307:	8b 52 18             	mov    0x18(%edx),%edx
  80230a:	85 d2                	test   %edx,%edx
  80230c:	74 32                	je     802340 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80230e:	83 ec 08             	sub    $0x8,%esp
  802311:	ff 75 0c             	pushl  0xc(%ebp)
  802314:	50                   	push   %eax
  802315:	ff d2                	call   *%edx
  802317:	83 c4 10             	add    $0x10,%esp
}
  80231a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80231d:	c9                   	leave  
  80231e:	c3                   	ret    
			thisenv->env_id, fdnum);
  80231f:	a1 24 54 80 00       	mov    0x805424,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  802324:	8b 40 48             	mov    0x48(%eax),%eax
  802327:	83 ec 04             	sub    $0x4,%esp
  80232a:	53                   	push   %ebx
  80232b:	50                   	push   %eax
  80232c:	68 20 3d 80 00       	push   $0x803d20
  802331:	e8 34 e8 ff ff       	call   800b6a <cprintf>
		return -E_INVAL;
  802336:	83 c4 10             	add    $0x10,%esp
  802339:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80233e:	eb da                	jmp    80231a <ftruncate+0x56>
		return -E_NOT_SUPP;
  802340:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  802345:	eb d3                	jmp    80231a <ftruncate+0x56>

00802347 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  802347:	f3 0f 1e fb          	endbr32 
  80234b:	55                   	push   %ebp
  80234c:	89 e5                	mov    %esp,%ebp
  80234e:	53                   	push   %ebx
  80234f:	83 ec 1c             	sub    $0x1c,%esp
  802352:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  802355:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802358:	50                   	push   %eax
  802359:	ff 75 08             	pushl  0x8(%ebp)
  80235c:	e8 57 fb ff ff       	call   801eb8 <fd_lookup>
  802361:	83 c4 10             	add    $0x10,%esp
  802364:	85 c0                	test   %eax,%eax
  802366:	78 4b                	js     8023b3 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  802368:	83 ec 08             	sub    $0x8,%esp
  80236b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80236e:	50                   	push   %eax
  80236f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  802372:	ff 30                	pushl  (%eax)
  802374:	e8 93 fb ff ff       	call   801f0c <dev_lookup>
  802379:	83 c4 10             	add    $0x10,%esp
  80237c:	85 c0                	test   %eax,%eax
  80237e:	78 33                	js     8023b3 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  802380:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802383:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  802387:	74 2f                	je     8023b8 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  802389:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80238c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  802393:	00 00 00 
	stat->st_isdir = 0;
  802396:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80239d:	00 00 00 
	stat->st_dev = dev;
  8023a0:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8023a6:	83 ec 08             	sub    $0x8,%esp
  8023a9:	53                   	push   %ebx
  8023aa:	ff 75 f0             	pushl  -0x10(%ebp)
  8023ad:	ff 50 14             	call   *0x14(%eax)
  8023b0:	83 c4 10             	add    $0x10,%esp
}
  8023b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8023b6:	c9                   	leave  
  8023b7:	c3                   	ret    
		return -E_NOT_SUPP;
  8023b8:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8023bd:	eb f4                	jmp    8023b3 <fstat+0x6c>

008023bf <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8023bf:	f3 0f 1e fb          	endbr32 
  8023c3:	55                   	push   %ebp
  8023c4:	89 e5                	mov    %esp,%ebp
  8023c6:	56                   	push   %esi
  8023c7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8023c8:	83 ec 08             	sub    $0x8,%esp
  8023cb:	6a 00                	push   $0x0
  8023cd:	ff 75 08             	pushl  0x8(%ebp)
  8023d0:	e8 fb 01 00 00       	call   8025d0 <open>
  8023d5:	89 c3                	mov    %eax,%ebx
  8023d7:	83 c4 10             	add    $0x10,%esp
  8023da:	85 c0                	test   %eax,%eax
  8023dc:	78 1b                	js     8023f9 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8023de:	83 ec 08             	sub    $0x8,%esp
  8023e1:	ff 75 0c             	pushl  0xc(%ebp)
  8023e4:	50                   	push   %eax
  8023e5:	e8 5d ff ff ff       	call   802347 <fstat>
  8023ea:	89 c6                	mov    %eax,%esi
	close(fd);
  8023ec:	89 1c 24             	mov    %ebx,(%esp)
  8023ef:	e8 fd fb ff ff       	call   801ff1 <close>
	return r;
  8023f4:	83 c4 10             	add    $0x10,%esp
  8023f7:	89 f3                	mov    %esi,%ebx
}
  8023f9:	89 d8                	mov    %ebx,%eax
  8023fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8023fe:	5b                   	pop    %ebx
  8023ff:	5e                   	pop    %esi
  802400:	5d                   	pop    %ebp
  802401:	c3                   	ret    

00802402 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  802402:	55                   	push   %ebp
  802403:	89 e5                	mov    %esp,%ebp
  802405:	56                   	push   %esi
  802406:	53                   	push   %ebx
  802407:	89 c6                	mov    %eax,%esi
  802409:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80240b:	83 3d 20 54 80 00 00 	cmpl   $0x0,0x805420
  802412:	74 27                	je     80243b <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  802414:	6a 07                	push   $0x7
  802416:	68 00 60 80 00       	push   $0x806000
  80241b:	56                   	push   %esi
  80241c:	ff 35 20 54 80 00    	pushl  0x805420
  802422:	e8 2c 0e 00 00       	call   803253 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  802427:	83 c4 0c             	add    $0xc,%esp
  80242a:	6a 00                	push   $0x0
  80242c:	53                   	push   %ebx
  80242d:	6a 00                	push   $0x0
  80242f:	e8 b1 0d 00 00       	call   8031e5 <ipc_recv>
}
  802434:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802437:	5b                   	pop    %ebx
  802438:	5e                   	pop    %esi
  802439:	5d                   	pop    %ebp
  80243a:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80243b:	83 ec 0c             	sub    $0xc,%esp
  80243e:	6a 01                	push   $0x1
  802440:	e8 73 0e 00 00       	call   8032b8 <ipc_find_env>
  802445:	a3 20 54 80 00       	mov    %eax,0x805420
  80244a:	83 c4 10             	add    $0x10,%esp
  80244d:	eb c5                	jmp    802414 <fsipc+0x12>

0080244f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80244f:	f3 0f 1e fb          	endbr32 
  802453:	55                   	push   %ebp
  802454:	89 e5                	mov    %esp,%ebp
  802456:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  802459:	8b 45 08             	mov    0x8(%ebp),%eax
  80245c:	8b 40 0c             	mov    0xc(%eax),%eax
  80245f:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.set_size.req_size = newsize;
  802464:	8b 45 0c             	mov    0xc(%ebp),%eax
  802467:	a3 04 60 80 00       	mov    %eax,0x806004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80246c:	ba 00 00 00 00       	mov    $0x0,%edx
  802471:	b8 02 00 00 00       	mov    $0x2,%eax
  802476:	e8 87 ff ff ff       	call   802402 <fsipc>
}
  80247b:	c9                   	leave  
  80247c:	c3                   	ret    

0080247d <devfile_flush>:
{
  80247d:	f3 0f 1e fb          	endbr32 
  802481:	55                   	push   %ebp
  802482:	89 e5                	mov    %esp,%ebp
  802484:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  802487:	8b 45 08             	mov    0x8(%ebp),%eax
  80248a:	8b 40 0c             	mov    0xc(%eax),%eax
  80248d:	a3 00 60 80 00       	mov    %eax,0x806000
	return fsipc(FSREQ_FLUSH, NULL);
  802492:	ba 00 00 00 00       	mov    $0x0,%edx
  802497:	b8 06 00 00 00       	mov    $0x6,%eax
  80249c:	e8 61 ff ff ff       	call   802402 <fsipc>
}
  8024a1:	c9                   	leave  
  8024a2:	c3                   	ret    

008024a3 <devfile_stat>:
{
  8024a3:	f3 0f 1e fb          	endbr32 
  8024a7:	55                   	push   %ebp
  8024a8:	89 e5                	mov    %esp,%ebp
  8024aa:	53                   	push   %ebx
  8024ab:	83 ec 04             	sub    $0x4,%esp
  8024ae:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8024b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8024b4:	8b 40 0c             	mov    0xc(%eax),%eax
  8024b7:	a3 00 60 80 00       	mov    %eax,0x806000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8024bc:	ba 00 00 00 00       	mov    $0x0,%edx
  8024c1:	b8 05 00 00 00       	mov    $0x5,%eax
  8024c6:	e8 37 ff ff ff       	call   802402 <fsipc>
  8024cb:	85 c0                	test   %eax,%eax
  8024cd:	78 2c                	js     8024fb <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8024cf:	83 ec 08             	sub    $0x8,%esp
  8024d2:	68 00 60 80 00       	push   $0x806000
  8024d7:	53                   	push   %ebx
  8024d8:	e8 eb ec ff ff       	call   8011c8 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8024dd:	a1 80 60 80 00       	mov    0x806080,%eax
  8024e2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8024e8:	a1 84 60 80 00       	mov    0x806084,%eax
  8024ed:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8024f3:	83 c4 10             	add    $0x10,%esp
  8024f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8024fb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8024fe:	c9                   	leave  
  8024ff:	c3                   	ret    

00802500 <devfile_write>:
{
  802500:	f3 0f 1e fb          	endbr32 
  802504:	55                   	push   %ebp
  802505:	89 e5                	mov    %esp,%ebp
  802507:	83 ec 0c             	sub    $0xc,%esp
  80250a:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  80250d:	8b 55 08             	mov    0x8(%ebp),%edx
  802510:	8b 52 0c             	mov    0xc(%edx),%edx
  802513:	89 15 00 60 80 00    	mov    %edx,0x806000
	fsipcbuf.write.req_n = n;
  802519:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  80251e:	ba f8 0f 00 00       	mov    $0xff8,%edx
  802523:	0f 47 c2             	cmova  %edx,%eax
  802526:	a3 04 60 80 00       	mov    %eax,0x806004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  80252b:	50                   	push   %eax
  80252c:	ff 75 0c             	pushl  0xc(%ebp)
  80252f:	68 08 60 80 00       	push   $0x806008
  802534:	e8 47 ee ff ff       	call   801380 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  802539:	ba 00 00 00 00       	mov    $0x0,%edx
  80253e:	b8 04 00 00 00       	mov    $0x4,%eax
  802543:	e8 ba fe ff ff       	call   802402 <fsipc>
}
  802548:	c9                   	leave  
  802549:	c3                   	ret    

0080254a <devfile_read>:
{
  80254a:	f3 0f 1e fb          	endbr32 
  80254e:	55                   	push   %ebp
  80254f:	89 e5                	mov    %esp,%ebp
  802551:	56                   	push   %esi
  802552:	53                   	push   %ebx
  802553:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  802556:	8b 45 08             	mov    0x8(%ebp),%eax
  802559:	8b 40 0c             	mov    0xc(%eax),%eax
  80255c:	a3 00 60 80 00       	mov    %eax,0x806000
	fsipcbuf.read.req_n = n;
  802561:	89 35 04 60 80 00    	mov    %esi,0x806004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  802567:	ba 00 00 00 00       	mov    $0x0,%edx
  80256c:	b8 03 00 00 00       	mov    $0x3,%eax
  802571:	e8 8c fe ff ff       	call   802402 <fsipc>
  802576:	89 c3                	mov    %eax,%ebx
  802578:	85 c0                	test   %eax,%eax
  80257a:	78 1f                	js     80259b <devfile_read+0x51>
	assert(r <= n);
  80257c:	39 f0                	cmp    %esi,%eax
  80257e:	77 24                	ja     8025a4 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  802580:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802585:	7f 33                	jg     8025ba <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  802587:	83 ec 04             	sub    $0x4,%esp
  80258a:	50                   	push   %eax
  80258b:	68 00 60 80 00       	push   $0x806000
  802590:	ff 75 0c             	pushl  0xc(%ebp)
  802593:	e8 e8 ed ff ff       	call   801380 <memmove>
	return r;
  802598:	83 c4 10             	add    $0x10,%esp
}
  80259b:	89 d8                	mov    %ebx,%eax
  80259d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8025a0:	5b                   	pop    %ebx
  8025a1:	5e                   	pop    %esi
  8025a2:	5d                   	pop    %ebp
  8025a3:	c3                   	ret    
	assert(r <= n);
  8025a4:	68 8c 3d 80 00       	push   $0x803d8c
  8025a9:	68 da 36 80 00       	push   $0x8036da
  8025ae:	6a 7c                	push   $0x7c
  8025b0:	68 93 3d 80 00       	push   $0x803d93
  8025b5:	e8 c9 e4 ff ff       	call   800a83 <_panic>
	assert(r <= PGSIZE);
  8025ba:	68 9e 3d 80 00       	push   $0x803d9e
  8025bf:	68 da 36 80 00       	push   $0x8036da
  8025c4:	6a 7d                	push   $0x7d
  8025c6:	68 93 3d 80 00       	push   $0x803d93
  8025cb:	e8 b3 e4 ff ff       	call   800a83 <_panic>

008025d0 <open>:
{
  8025d0:	f3 0f 1e fb          	endbr32 
  8025d4:	55                   	push   %ebp
  8025d5:	89 e5                	mov    %esp,%ebp
  8025d7:	56                   	push   %esi
  8025d8:	53                   	push   %ebx
  8025d9:	83 ec 1c             	sub    $0x1c,%esp
  8025dc:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  8025df:	56                   	push   %esi
  8025e0:	e8 a0 eb ff ff       	call   801185 <strlen>
  8025e5:	83 c4 10             	add    $0x10,%esp
  8025e8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  8025ed:	7f 6c                	jg     80265b <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  8025ef:	83 ec 0c             	sub    $0xc,%esp
  8025f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8025f5:	50                   	push   %eax
  8025f6:	e8 67 f8 ff ff       	call   801e62 <fd_alloc>
  8025fb:	89 c3                	mov    %eax,%ebx
  8025fd:	83 c4 10             	add    $0x10,%esp
  802600:	85 c0                	test   %eax,%eax
  802602:	78 3c                	js     802640 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  802604:	83 ec 08             	sub    $0x8,%esp
  802607:	56                   	push   %esi
  802608:	68 00 60 80 00       	push   $0x806000
  80260d:	e8 b6 eb ff ff       	call   8011c8 <strcpy>
	fsipcbuf.open.req_omode = mode;
  802612:	8b 45 0c             	mov    0xc(%ebp),%eax
  802615:	a3 00 64 80 00       	mov    %eax,0x806400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  80261a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80261d:	b8 01 00 00 00       	mov    $0x1,%eax
  802622:	e8 db fd ff ff       	call   802402 <fsipc>
  802627:	89 c3                	mov    %eax,%ebx
  802629:	83 c4 10             	add    $0x10,%esp
  80262c:	85 c0                	test   %eax,%eax
  80262e:	78 19                	js     802649 <open+0x79>
	return fd2num(fd);
  802630:	83 ec 0c             	sub    $0xc,%esp
  802633:	ff 75 f4             	pushl  -0xc(%ebp)
  802636:	e8 f4 f7 ff ff       	call   801e2f <fd2num>
  80263b:	89 c3                	mov    %eax,%ebx
  80263d:	83 c4 10             	add    $0x10,%esp
}
  802640:	89 d8                	mov    %ebx,%eax
  802642:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802645:	5b                   	pop    %ebx
  802646:	5e                   	pop    %esi
  802647:	5d                   	pop    %ebp
  802648:	c3                   	ret    
		fd_close(fd, 0);
  802649:	83 ec 08             	sub    $0x8,%esp
  80264c:	6a 00                	push   $0x0
  80264e:	ff 75 f4             	pushl  -0xc(%ebp)
  802651:	e8 10 f9 ff ff       	call   801f66 <fd_close>
		return r;
  802656:	83 c4 10             	add    $0x10,%esp
  802659:	eb e5                	jmp    802640 <open+0x70>
		return -E_BAD_PATH;
  80265b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  802660:	eb de                	jmp    802640 <open+0x70>

00802662 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  802662:	f3 0f 1e fb          	endbr32 
  802666:	55                   	push   %ebp
  802667:	89 e5                	mov    %esp,%ebp
  802669:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  80266c:	ba 00 00 00 00       	mov    $0x0,%edx
  802671:	b8 08 00 00 00       	mov    $0x8,%eax
  802676:	e8 87 fd ff ff       	call   802402 <fsipc>
}
  80267b:	c9                   	leave  
  80267c:	c3                   	ret    

0080267d <writebuf>:


static void
writebuf(struct printbuf *b)
{
	if (b->error > 0) {
  80267d:	83 78 0c 00          	cmpl   $0x0,0xc(%eax)
  802681:	7f 01                	jg     802684 <writebuf+0x7>
  802683:	c3                   	ret    
{
  802684:	55                   	push   %ebp
  802685:	89 e5                	mov    %esp,%ebp
  802687:	53                   	push   %ebx
  802688:	83 ec 08             	sub    $0x8,%esp
  80268b:	89 c3                	mov    %eax,%ebx
		ssize_t result = write(b->fd, b->buf, b->idx);
  80268d:	ff 70 04             	pushl  0x4(%eax)
  802690:	8d 40 10             	lea    0x10(%eax),%eax
  802693:	50                   	push   %eax
  802694:	ff 33                	pushl  (%ebx)
  802696:	e8 76 fb ff ff       	call   802211 <write>
		if (result > 0)
  80269b:	83 c4 10             	add    $0x10,%esp
  80269e:	85 c0                	test   %eax,%eax
  8026a0:	7e 03                	jle    8026a5 <writebuf+0x28>
			b->result += result;
  8026a2:	01 43 08             	add    %eax,0x8(%ebx)
		if (result != b->idx) // error, or wrote less than supplied
  8026a5:	39 43 04             	cmp    %eax,0x4(%ebx)
  8026a8:	74 0d                	je     8026b7 <writebuf+0x3a>
			b->error = (result < 0 ? result : 0);
  8026aa:	85 c0                	test   %eax,%eax
  8026ac:	ba 00 00 00 00       	mov    $0x0,%edx
  8026b1:	0f 4f c2             	cmovg  %edx,%eax
  8026b4:	89 43 0c             	mov    %eax,0xc(%ebx)
	}
}
  8026b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8026ba:	c9                   	leave  
  8026bb:	c3                   	ret    

008026bc <putch>:

static void
putch(int ch, void *thunk)
{
  8026bc:	f3 0f 1e fb          	endbr32 
  8026c0:	55                   	push   %ebp
  8026c1:	89 e5                	mov    %esp,%ebp
  8026c3:	53                   	push   %ebx
  8026c4:	83 ec 04             	sub    $0x4,%esp
  8026c7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct printbuf *b = (struct printbuf *) thunk;
	b->buf[b->idx++] = ch;
  8026ca:	8b 53 04             	mov    0x4(%ebx),%edx
  8026cd:	8d 42 01             	lea    0x1(%edx),%eax
  8026d0:	89 43 04             	mov    %eax,0x4(%ebx)
  8026d3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8026d6:	88 4c 13 10          	mov    %cl,0x10(%ebx,%edx,1)
	if (b->idx == 256) {
  8026da:	3d 00 01 00 00       	cmp    $0x100,%eax
  8026df:	74 06                	je     8026e7 <putch+0x2b>
		writebuf(b);
		b->idx = 0;
	}
}
  8026e1:	83 c4 04             	add    $0x4,%esp
  8026e4:	5b                   	pop    %ebx
  8026e5:	5d                   	pop    %ebp
  8026e6:	c3                   	ret    
		writebuf(b);
  8026e7:	89 d8                	mov    %ebx,%eax
  8026e9:	e8 8f ff ff ff       	call   80267d <writebuf>
		b->idx = 0;
  8026ee:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
}
  8026f5:	eb ea                	jmp    8026e1 <putch+0x25>

008026f7 <vfprintf>:

int
vfprintf(int fd, const char *fmt, va_list ap)
{
  8026f7:	f3 0f 1e fb          	endbr32 
  8026fb:	55                   	push   %ebp
  8026fc:	89 e5                	mov    %esp,%ebp
  8026fe:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.fd = fd;
  802704:	8b 45 08             	mov    0x8(%ebp),%eax
  802707:	89 85 e8 fe ff ff    	mov    %eax,-0x118(%ebp)
	b.idx = 0;
  80270d:	c7 85 ec fe ff ff 00 	movl   $0x0,-0x114(%ebp)
  802714:	00 00 00 
	b.result = 0;
  802717:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80271e:	00 00 00 
	b.error = 1;
  802721:	c7 85 f4 fe ff ff 01 	movl   $0x1,-0x10c(%ebp)
  802728:	00 00 00 
	vprintfmt(putch, &b, fmt, ap);
  80272b:	ff 75 10             	pushl  0x10(%ebp)
  80272e:	ff 75 0c             	pushl  0xc(%ebp)
  802731:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802737:	50                   	push   %eax
  802738:	68 bc 26 80 00       	push   $0x8026bc
  80273d:	e8 8b e5 ff ff       	call   800ccd <vprintfmt>
	if (b.idx > 0)
  802742:	83 c4 10             	add    $0x10,%esp
  802745:	83 bd ec fe ff ff 00 	cmpl   $0x0,-0x114(%ebp)
  80274c:	7f 11                	jg     80275f <vfprintf+0x68>
		writebuf(&b);

	return (b.result ? b.result : b.error);
  80274e:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
  802754:	85 c0                	test   %eax,%eax
  802756:	0f 44 85 f4 fe ff ff 	cmove  -0x10c(%ebp),%eax
}
  80275d:	c9                   	leave  
  80275e:	c3                   	ret    
		writebuf(&b);
  80275f:	8d 85 e8 fe ff ff    	lea    -0x118(%ebp),%eax
  802765:	e8 13 ff ff ff       	call   80267d <writebuf>
  80276a:	eb e2                	jmp    80274e <vfprintf+0x57>

0080276c <fprintf>:

int
fprintf(int fd, const char *fmt, ...)
{
  80276c:	f3 0f 1e fb          	endbr32 
  802770:	55                   	push   %ebp
  802771:	89 e5                	mov    %esp,%ebp
  802773:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802776:	8d 45 10             	lea    0x10(%ebp),%eax
	cnt = vfprintf(fd, fmt, ap);
  802779:	50                   	push   %eax
  80277a:	ff 75 0c             	pushl  0xc(%ebp)
  80277d:	ff 75 08             	pushl  0x8(%ebp)
  802780:	e8 72 ff ff ff       	call   8026f7 <vfprintf>
	va_end(ap);

	return cnt;
}
  802785:	c9                   	leave  
  802786:	c3                   	ret    

00802787 <printf>:

int
printf(const char *fmt, ...)
{
  802787:	f3 0f 1e fb          	endbr32 
  80278b:	55                   	push   %ebp
  80278c:	89 e5                	mov    %esp,%ebp
  80278e:	83 ec 0c             	sub    $0xc,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  802791:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vfprintf(1, fmt, ap);
  802794:	50                   	push   %eax
  802795:	ff 75 08             	pushl  0x8(%ebp)
  802798:	6a 01                	push   $0x1
  80279a:	e8 58 ff ff ff       	call   8026f7 <vfprintf>
	va_end(ap);

	return cnt;
}
  80279f:	c9                   	leave  
  8027a0:	c3                   	ret    

008027a1 <copy_shared_pages>:
}

// Copy the mappings for shared pages into the child address space.
static int
copy_shared_pages(envid_t child)
{
  8027a1:	55                   	push   %ebp
  8027a2:	89 e5                	mov    %esp,%ebp
  8027a4:	56                   	push   %esi
  8027a5:	53                   	push   %ebx
  8027a6:	89 c6                	mov    %eax,%esi
	// LAB 5: Your code here.
	for(uint32_t addr = UTEXT; addr < UTOP; addr +=PGSIZE){
  8027a8:	bb 00 00 80 00       	mov    $0x800000,%ebx
  8027ad:	eb 33                	jmp    8027e2 <copy_shared_pages+0x41>
		if(addr != UXSTACKTOP - PGSIZE){
			if(((uvpd[PDX(addr)] & PTE_P) != 0) && ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U|PTE_SHARE))) == 0){
				sys_page_map(0, (void*)addr, child, (void*)addr, (uvpt[PGNUM(addr)] & PTE_SYSCALL));
  8027af:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8027b6:	83 ec 0c             	sub    $0xc,%esp
  8027b9:	25 07 0e 00 00       	and    $0xe07,%eax
  8027be:	50                   	push   %eax
  8027bf:	53                   	push   %ebx
  8027c0:	56                   	push   %esi
  8027c1:	53                   	push   %ebx
  8027c2:	6a 00                	push   $0x0
  8027c4:	e8 af ee ff ff       	call   801678 <sys_page_map>
  8027c9:	83 c4 20             	add    $0x20,%esp
	for(uint32_t addr = UTEXT; addr < UTOP; addr +=PGSIZE){
  8027cc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  8027d2:	81 fb ff ff bf ee    	cmp    $0xeebfffff,%ebx
  8027d8:	77 2f                	ja     802809 <copy_shared_pages+0x68>
		if(addr != UXSTACKTOP - PGSIZE){
  8027da:	81 fb 00 f0 bf ee    	cmp    $0xeebff000,%ebx
  8027e0:	74 ea                	je     8027cc <copy_shared_pages+0x2b>
			if(((uvpd[PDX(addr)] & PTE_P) != 0) && ((~uvpt[PGNUM(addr)] & (PTE_P | PTE_U|PTE_SHARE))) == 0){
  8027e2:	89 d8                	mov    %ebx,%eax
  8027e4:	c1 e8 16             	shr    $0x16,%eax
  8027e7:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8027ee:	a8 01                	test   $0x1,%al
  8027f0:	74 da                	je     8027cc <copy_shared_pages+0x2b>
  8027f2:	89 da                	mov    %ebx,%edx
  8027f4:	c1 ea 0c             	shr    $0xc,%edx
  8027f7:	8b 04 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%eax
  8027fe:	f7 d0                	not    %eax
  802800:	a9 05 04 00 00       	test   $0x405,%eax
  802805:	75 c5                	jne    8027cc <copy_shared_pages+0x2b>
  802807:	eb a6                	jmp    8027af <copy_shared_pages+0xe>
			}
		}
	}
	return 0;
}
  802809:	b8 00 00 00 00       	mov    $0x0,%eax
  80280e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802811:	5b                   	pop    %ebx
  802812:	5e                   	pop    %esi
  802813:	5d                   	pop    %ebp
  802814:	c3                   	ret    

00802815 <init_stack>:
{
  802815:	55                   	push   %ebp
  802816:	89 e5                	mov    %esp,%ebp
  802818:	57                   	push   %edi
  802819:	56                   	push   %esi
  80281a:	53                   	push   %ebx
  80281b:	83 ec 2c             	sub    $0x2c,%esp
  80281e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
  802821:	89 55 d0             	mov    %edx,-0x30(%ebp)
  802824:	89 4d cc             	mov    %ecx,-0x34(%ebp)
	for (argc = 0; argv[argc] != 0; argc++)
  802827:	bb 00 00 00 00       	mov    $0x0,%ebx
	string_size = 0;
  80282c:	be 00 00 00 00       	mov    $0x0,%esi
  802831:	89 d7                	mov    %edx,%edi
  802833:	8d 0c 9d 00 00 00 00 	lea    0x0(,%ebx,4),%ecx
	for (argc = 0; argv[argc] != 0; argc++)
  80283a:	8b 04 9f             	mov    (%edi,%ebx,4),%eax
  80283d:	85 c0                	test   %eax,%eax
  80283f:	74 15                	je     802856 <init_stack+0x41>
		string_size += strlen(argv[argc]) + 1;
  802841:	83 ec 0c             	sub    $0xc,%esp
  802844:	50                   	push   %eax
  802845:	e8 3b e9 ff ff       	call   801185 <strlen>
  80284a:	8d 74 06 01          	lea    0x1(%esi,%eax,1),%esi
	for (argc = 0; argv[argc] != 0; argc++)
  80284e:	83 c3 01             	add    $0x1,%ebx
  802851:	83 c4 10             	add    $0x10,%esp
  802854:	eb dd                	jmp    802833 <init_stack+0x1e>
  802856:	89 5d dc             	mov    %ebx,-0x24(%ebp)
  802859:	89 4d d8             	mov    %ecx,-0x28(%ebp)
	string_store = (char *) UTEMP + PGSIZE - string_size;
  80285c:	bf 00 10 40 00       	mov    $0x401000,%edi
  802861:	29 f7                	sub    %esi,%edi
	argv_store = (uintptr_t *) (ROUNDDOWN(string_store, 4) - 4 * (argc + 1));
  802863:	89 fa                	mov    %edi,%edx
  802865:	83 e2 fc             	and    $0xfffffffc,%edx
  802868:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
  80286f:	29 c2                	sub    %eax,%edx
  802871:	89 55 e4             	mov    %edx,-0x1c(%ebp)
	if ((void *) (argv_store - 2) < (void *) UTEMP)
  802874:	8d 42 f8             	lea    -0x8(%edx),%eax
  802877:	3d ff ff 3f 00       	cmp    $0x3fffff,%eax
  80287c:	0f 86 06 01 00 00    	jbe    802988 <init_stack+0x173>
	if ((r = sys_page_alloc(0, (void *) UTEMP, PTE_P | PTE_U | PTE_W)) < 0)
  802882:	83 ec 04             	sub    $0x4,%esp
  802885:	6a 07                	push   $0x7
  802887:	68 00 00 40 00       	push   $0x400000
  80288c:	6a 00                	push   $0x0
  80288e:	e8 bd ed ff ff       	call   801650 <sys_page_alloc>
  802893:	89 c6                	mov    %eax,%esi
  802895:	83 c4 10             	add    $0x10,%esp
  802898:	85 c0                	test   %eax,%eax
  80289a:	0f 88 de 00 00 00    	js     80297e <init_stack+0x169>
	for (i = 0; i < argc; i++) {
  8028a0:	be 00 00 00 00       	mov    $0x0,%esi
  8028a5:	89 5d e0             	mov    %ebx,-0x20(%ebp)
  8028a8:	8b 5d d0             	mov    -0x30(%ebp),%ebx
  8028ab:	39 75 e0             	cmp    %esi,-0x20(%ebp)
  8028ae:	7e 2f                	jle    8028df <init_stack+0xca>
		argv_store[i] = UTEMP2USTACK(string_store);
  8028b0:	8d 87 00 d0 7f ee    	lea    -0x11803000(%edi),%eax
  8028b6:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  8028b9:	89 04 b1             	mov    %eax,(%ecx,%esi,4)
		strcpy(string_store, argv[i]);
  8028bc:	83 ec 08             	sub    $0x8,%esp
  8028bf:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8028c2:	57                   	push   %edi
  8028c3:	e8 00 e9 ff ff       	call   8011c8 <strcpy>
		string_store += strlen(argv[i]) + 1;
  8028c8:	83 c4 04             	add    $0x4,%esp
  8028cb:	ff 34 b3             	pushl  (%ebx,%esi,4)
  8028ce:	e8 b2 e8 ff ff       	call   801185 <strlen>
  8028d3:	8d 7c 07 01          	lea    0x1(%edi,%eax,1),%edi
	for (i = 0; i < argc; i++) {
  8028d7:	83 c6 01             	add    $0x1,%esi
  8028da:	83 c4 10             	add    $0x10,%esp
  8028dd:	eb cc                	jmp    8028ab <init_stack+0x96>
	argv_store[argc] = 0;
  8028df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  8028e2:	8b 4d d8             	mov    -0x28(%ebp),%ecx
  8028e5:	c7 04 08 00 00 00 00 	movl   $0x0,(%eax,%ecx,1)
	assert(string_store == (char *) UTEMP + PGSIZE);
  8028ec:	81 ff 00 10 40 00    	cmp    $0x401000,%edi
  8028f2:	75 5f                	jne    802953 <init_stack+0x13e>
	argv_store[-1] = UTEMP2USTACK(argv_store);
  8028f4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8028f7:	8d 82 00 d0 7f ee    	lea    -0x11803000(%edx),%eax
  8028fd:	89 42 fc             	mov    %eax,-0x4(%edx)
	argv_store[-2] = argc;
  802900:	89 d0                	mov    %edx,%eax
  802902:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  802905:	89 4a f8             	mov    %ecx,-0x8(%edx)
	*init_esp = UTEMP2USTACK(&argv_store[-2]);
  802908:	2d 08 30 80 11       	sub    $0x11803008,%eax
  80290d:	8b 4d cc             	mov    -0x34(%ebp),%ecx
  802910:	89 01                	mov    %eax,(%ecx)
	if ((r = sys_page_map(0,
  802912:	83 ec 0c             	sub    $0xc,%esp
  802915:	6a 07                	push   $0x7
  802917:	68 00 d0 bf ee       	push   $0xeebfd000
  80291c:	ff 75 d4             	pushl  -0x2c(%ebp)
  80291f:	68 00 00 40 00       	push   $0x400000
  802924:	6a 00                	push   $0x0
  802926:	e8 4d ed ff ff       	call   801678 <sys_page_map>
  80292b:	89 c6                	mov    %eax,%esi
  80292d:	83 c4 20             	add    $0x20,%esp
  802930:	85 c0                	test   %eax,%eax
  802932:	78 38                	js     80296c <init_stack+0x157>
	if ((r = sys_page_unmap(0, UTEMP)) < 0)
  802934:	83 ec 08             	sub    $0x8,%esp
  802937:	68 00 00 40 00       	push   $0x400000
  80293c:	6a 00                	push   $0x0
  80293e:	e8 5f ed ff ff       	call   8016a2 <sys_page_unmap>
  802943:	89 c6                	mov    %eax,%esi
  802945:	83 c4 10             	add    $0x10,%esp
  802948:	85 c0                	test   %eax,%eax
  80294a:	78 20                	js     80296c <init_stack+0x157>
	return 0;
  80294c:	be 00 00 00 00       	mov    $0x0,%esi
  802951:	eb 2b                	jmp    80297e <init_stack+0x169>
	assert(string_store == (char *) UTEMP + PGSIZE);
  802953:	68 ac 3d 80 00       	push   $0x803dac
  802958:	68 da 36 80 00       	push   $0x8036da
  80295d:	68 fc 00 00 00       	push   $0xfc
  802962:	68 d4 3d 80 00       	push   $0x803dd4
  802967:	e8 17 e1 ff ff       	call   800a83 <_panic>
	sys_page_unmap(0, UTEMP);
  80296c:	83 ec 08             	sub    $0x8,%esp
  80296f:	68 00 00 40 00       	push   $0x400000
  802974:	6a 00                	push   $0x0
  802976:	e8 27 ed ff ff       	call   8016a2 <sys_page_unmap>
	return r;
  80297b:	83 c4 10             	add    $0x10,%esp
}
  80297e:	89 f0                	mov    %esi,%eax
  802980:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802983:	5b                   	pop    %ebx
  802984:	5e                   	pop    %esi
  802985:	5f                   	pop    %edi
  802986:	5d                   	pop    %ebp
  802987:	c3                   	ret    
		return -E_NO_MEM;
  802988:	be fc ff ff ff       	mov    $0xfffffffc,%esi
  80298d:	eb ef                	jmp    80297e <init_stack+0x169>

0080298f <map_segment>:
{
  80298f:	55                   	push   %ebp
  802990:	89 e5                	mov    %esp,%ebp
  802992:	57                   	push   %edi
  802993:	56                   	push   %esi
  802994:	53                   	push   %ebx
  802995:	83 ec 1c             	sub    $0x1c,%esp
  802998:	89 45 dc             	mov    %eax,-0x24(%ebp)
  80299b:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80299e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  8029a1:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((i = PGOFF(va))) {
  8029a4:	89 d0                	mov    %edx,%eax
  8029a6:	25 ff 0f 00 00       	and    $0xfff,%eax
  8029ab:	74 0f                	je     8029bc <map_segment+0x2d>
		va -= i;
  8029ad:	29 c2                	sub    %eax,%edx
  8029af:	89 55 e0             	mov    %edx,-0x20(%ebp)
		memsz += i;
  8029b2:	01 c1                	add    %eax,%ecx
  8029b4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		filesz += i;
  8029b7:	01 c7                	add    %eax,%edi
		fileoffset -= i;
  8029b9:	29 45 10             	sub    %eax,0x10(%ebp)
	for (i = 0; i < memsz; i += PGSIZE) {
  8029bc:	bb 00 00 00 00       	mov    $0x0,%ebx
  8029c1:	e9 99 00 00 00       	jmp    802a5f <map_segment+0xd0>
			if ((r = sys_page_alloc(0, UTEMP, PTE_P | PTE_U | PTE_W)) <
  8029c6:	83 ec 04             	sub    $0x4,%esp
  8029c9:	6a 07                	push   $0x7
  8029cb:	68 00 00 40 00       	push   $0x400000
  8029d0:	6a 00                	push   $0x0
  8029d2:	e8 79 ec ff ff       	call   801650 <sys_page_alloc>
  8029d7:	83 c4 10             	add    $0x10,%esp
  8029da:	85 c0                	test   %eax,%eax
  8029dc:	0f 88 c1 00 00 00    	js     802aa3 <map_segment+0x114>
			if ((r = seek(fd, fileoffset + i)) < 0)
  8029e2:	83 ec 08             	sub    $0x8,%esp
  8029e5:	89 f0                	mov    %esi,%eax
  8029e7:	03 45 10             	add    0x10(%ebp),%eax
  8029ea:	50                   	push   %eax
  8029eb:	ff 75 08             	pushl  0x8(%ebp)
  8029ee:	e8 a4 f8 ff ff       	call   802297 <seek>
  8029f3:	83 c4 10             	add    $0x10,%esp
  8029f6:	85 c0                	test   %eax,%eax
  8029f8:	0f 88 a5 00 00 00    	js     802aa3 <map_segment+0x114>
			if ((r = readn(fd, UTEMP, MIN(PGSIZE, filesz - i))) < 0)
  8029fe:	83 ec 04             	sub    $0x4,%esp
  802a01:	89 f8                	mov    %edi,%eax
  802a03:	29 f0                	sub    %esi,%eax
  802a05:	3d 00 10 00 00       	cmp    $0x1000,%eax
  802a0a:	ba 00 10 00 00       	mov    $0x1000,%edx
  802a0f:	0f 47 c2             	cmova  %edx,%eax
  802a12:	50                   	push   %eax
  802a13:	68 00 00 40 00       	push   $0x400000
  802a18:	ff 75 08             	pushl  0x8(%ebp)
  802a1b:	e8 a6 f7 ff ff       	call   8021c6 <readn>
  802a20:	83 c4 10             	add    $0x10,%esp
  802a23:	85 c0                	test   %eax,%eax
  802a25:	78 7c                	js     802aa3 <map_segment+0x114>
			if ((r = sys_page_map(
  802a27:	83 ec 0c             	sub    $0xc,%esp
  802a2a:	ff 75 14             	pushl  0x14(%ebp)
  802a2d:	03 75 e0             	add    -0x20(%ebp),%esi
  802a30:	56                   	push   %esi
  802a31:	ff 75 dc             	pushl  -0x24(%ebp)
  802a34:	68 00 00 40 00       	push   $0x400000
  802a39:	6a 00                	push   $0x0
  802a3b:	e8 38 ec ff ff       	call   801678 <sys_page_map>
  802a40:	83 c4 20             	add    $0x20,%esp
  802a43:	85 c0                	test   %eax,%eax
  802a45:	78 42                	js     802a89 <map_segment+0xfa>
			sys_page_unmap(0, UTEMP);
  802a47:	83 ec 08             	sub    $0x8,%esp
  802a4a:	68 00 00 40 00       	push   $0x400000
  802a4f:	6a 00                	push   $0x0
  802a51:	e8 4c ec ff ff       	call   8016a2 <sys_page_unmap>
  802a56:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < memsz; i += PGSIZE) {
  802a59:	81 c3 00 10 00 00    	add    $0x1000,%ebx
  802a5f:	89 de                	mov    %ebx,%esi
  802a61:	39 5d e4             	cmp    %ebx,-0x1c(%ebp)
  802a64:	76 38                	jbe    802a9e <map_segment+0x10f>
		if (i >= filesz) {
  802a66:	39 df                	cmp    %ebx,%edi
  802a68:	0f 87 58 ff ff ff    	ja     8029c6 <map_segment+0x37>
			if ((r = sys_page_alloc(child, (void *) (va + i), perm)) < 0)
  802a6e:	83 ec 04             	sub    $0x4,%esp
  802a71:	ff 75 14             	pushl  0x14(%ebp)
  802a74:	03 75 e0             	add    -0x20(%ebp),%esi
  802a77:	56                   	push   %esi
  802a78:	ff 75 dc             	pushl  -0x24(%ebp)
  802a7b:	e8 d0 eb ff ff       	call   801650 <sys_page_alloc>
  802a80:	83 c4 10             	add    $0x10,%esp
  802a83:	85 c0                	test   %eax,%eax
  802a85:	79 d2                	jns    802a59 <map_segment+0xca>
  802a87:	eb 1a                	jmp    802aa3 <map_segment+0x114>
				panic("spawn: sys_page_map data: %e", r);
  802a89:	50                   	push   %eax
  802a8a:	68 e0 3d 80 00       	push   $0x803de0
  802a8f:	68 3a 01 00 00       	push   $0x13a
  802a94:	68 d4 3d 80 00       	push   $0x803dd4
  802a99:	e8 e5 df ff ff       	call   800a83 <_panic>
	return 0;
  802a9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802aa3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802aa6:	5b                   	pop    %ebx
  802aa7:	5e                   	pop    %esi
  802aa8:	5f                   	pop    %edi
  802aa9:	5d                   	pop    %ebp
  802aaa:	c3                   	ret    

00802aab <spawn>:
{
  802aab:	f3 0f 1e fb          	endbr32 
  802aaf:	55                   	push   %ebp
  802ab0:	89 e5                	mov    %esp,%ebp
  802ab2:	57                   	push   %edi
  802ab3:	56                   	push   %esi
  802ab4:	53                   	push   %ebx
  802ab5:	81 ec 74 02 00 00    	sub    $0x274,%esp
	if ((r = open(prog, O_RDONLY)) < 0)
  802abb:	6a 00                	push   $0x0
  802abd:	ff 75 08             	pushl  0x8(%ebp)
  802ac0:	e8 0b fb ff ff       	call   8025d0 <open>
  802ac5:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802acb:	83 c4 10             	add    $0x10,%esp
  802ace:	85 c0                	test   %eax,%eax
  802ad0:	0f 88 0b 02 00 00    	js     802ce1 <spawn+0x236>
  802ad6:	89 c7                	mov    %eax,%edi
	if (readn(fd, elf_buf, sizeof(elf_buf)) != sizeof(elf_buf) ||
  802ad8:	83 ec 04             	sub    $0x4,%esp
  802adb:	68 00 02 00 00       	push   $0x200
  802ae0:	8d 85 e8 fd ff ff    	lea    -0x218(%ebp),%eax
  802ae6:	50                   	push   %eax
  802ae7:	57                   	push   %edi
  802ae8:	e8 d9 f6 ff ff       	call   8021c6 <readn>
  802aed:	83 c4 10             	add    $0x10,%esp
  802af0:	3d 00 02 00 00       	cmp    $0x200,%eax
  802af5:	0f 85 85 00 00 00    	jne    802b80 <spawn+0xd5>
  802afb:	81 bd e8 fd ff ff 7f 	cmpl   $0x464c457f,-0x218(%ebp)
  802b02:	45 4c 46 
  802b05:	75 79                	jne    802b80 <spawn+0xd5>
  802b07:	b8 07 00 00 00       	mov    $0x7,%eax
  802b0c:	cd 30                	int    $0x30
  802b0e:	89 85 8c fd ff ff    	mov    %eax,-0x274(%ebp)
  802b14:	89 85 90 fd ff ff    	mov    %eax,-0x270(%ebp)
	if ((r = sys_exofork()) < 0)
  802b1a:	89 c3                	mov    %eax,%ebx
  802b1c:	85 c0                	test   %eax,%eax
  802b1e:	0f 88 b1 01 00 00    	js     802cd5 <spawn+0x22a>
	child_tf = envs[ENVX(child)].env_tf;
  802b24:	89 c6                	mov    %eax,%esi
  802b26:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
  802b2c:	6b f6 7c             	imul   $0x7c,%esi,%esi
  802b2f:	81 c6 00 00 c0 ee    	add    $0xeec00000,%esi
  802b35:	8d bd a4 fd ff ff    	lea    -0x25c(%ebp),%edi
  802b3b:	b9 11 00 00 00       	mov    $0x11,%ecx
  802b40:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
	child_tf.tf_eip = elf->e_entry;
  802b42:	8b 85 00 fe ff ff    	mov    -0x200(%ebp),%eax
  802b48:	89 85 d4 fd ff ff    	mov    %eax,-0x22c(%ebp)
	if ((r = init_stack(child, argv, &child_tf.tf_esp)) < 0)
  802b4e:	8d 8d e0 fd ff ff    	lea    -0x220(%ebp),%ecx
  802b54:	8b 55 0c             	mov    0xc(%ebp),%edx
  802b57:	89 d8                	mov    %ebx,%eax
  802b59:	e8 b7 fc ff ff       	call   802815 <init_stack>
  802b5e:	85 c0                	test   %eax,%eax
  802b60:	0f 88 89 01 00 00    	js     802cef <spawn+0x244>
	ph = (struct Proghdr *) (elf_buf + elf->e_phoff);
  802b66:	8b 85 04 fe ff ff    	mov    -0x1fc(%ebp),%eax
  802b6c:	8d 9c 05 e8 fd ff ff 	lea    -0x218(%ebp,%eax,1),%ebx
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802b73:	be 00 00 00 00       	mov    $0x0,%esi
  802b78:	8b bd 94 fd ff ff    	mov    -0x26c(%ebp),%edi
  802b7e:	eb 3e                	jmp    802bbe <spawn+0x113>
		close(fd);
  802b80:	83 ec 0c             	sub    $0xc,%esp
  802b83:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  802b89:	e8 63 f4 ff ff       	call   801ff1 <close>
		cprintf("elf magic %08x want %08x\n", elf->e_magic, ELF_MAGIC);
  802b8e:	83 c4 0c             	add    $0xc,%esp
  802b91:	68 7f 45 4c 46       	push   $0x464c457f
  802b96:	ff b5 e8 fd ff ff    	pushl  -0x218(%ebp)
  802b9c:	68 fd 3d 80 00       	push   $0x803dfd
  802ba1:	e8 c4 df ff ff       	call   800b6a <cprintf>
		return -E_NOT_EXEC;
  802ba6:	83 c4 10             	add    $0x10,%esp
  802ba9:	c7 85 94 fd ff ff f2 	movl   $0xfffffff2,-0x26c(%ebp)
  802bb0:	ff ff ff 
  802bb3:	e9 29 01 00 00       	jmp    802ce1 <spawn+0x236>
	for (i = 0; i < elf->e_phnum; i++, ph++) {
  802bb8:	83 c6 01             	add    $0x1,%esi
  802bbb:	83 c3 20             	add    $0x20,%ebx
  802bbe:	0f b7 85 14 fe ff ff 	movzwl -0x1ec(%ebp),%eax
  802bc5:	39 f0                	cmp    %esi,%eax
  802bc7:	7e 62                	jle    802c2b <spawn+0x180>
		if (ph->p_type != ELF_PROG_LOAD)
  802bc9:	83 3b 01             	cmpl   $0x1,(%ebx)
  802bcc:	75 ea                	jne    802bb8 <spawn+0x10d>
		if (ph->p_flags & ELF_PROG_FLAG_WRITE)
  802bce:	8b 43 18             	mov    0x18(%ebx),%eax
  802bd1:	83 e0 02             	and    $0x2,%eax
			perm |= PTE_W;
  802bd4:	83 f8 01             	cmp    $0x1,%eax
  802bd7:	19 c0                	sbb    %eax,%eax
  802bd9:	83 e0 fe             	and    $0xfffffffe,%eax
  802bdc:	83 c0 07             	add    $0x7,%eax
		if ((r = map_segment(child,
  802bdf:	8b 4b 14             	mov    0x14(%ebx),%ecx
  802be2:	8b 53 08             	mov    0x8(%ebx),%edx
  802be5:	50                   	push   %eax
  802be6:	ff 73 04             	pushl  0x4(%ebx)
  802be9:	ff 73 10             	pushl  0x10(%ebx)
  802bec:	57                   	push   %edi
  802bed:	8b 85 90 fd ff ff    	mov    -0x270(%ebp),%eax
  802bf3:	e8 97 fd ff ff       	call   80298f <map_segment>
  802bf8:	83 c4 10             	add    $0x10,%esp
  802bfb:	85 c0                	test   %eax,%eax
  802bfd:	79 b9                	jns    802bb8 <spawn+0x10d>
  802bff:	89 c7                	mov    %eax,%edi
	sys_env_destroy(child);
  802c01:	83 ec 0c             	sub    $0xc,%esp
  802c04:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802c0a:	e8 c8 e9 ff ff       	call   8015d7 <sys_env_destroy>
	close(fd);
  802c0f:	83 c4 04             	add    $0x4,%esp
  802c12:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  802c18:	e8 d4 f3 ff ff       	call   801ff1 <close>
	return r;
  802c1d:	83 c4 10             	add    $0x10,%esp
		if ((r = map_segment(child,
  802c20:	89 bd 94 fd ff ff    	mov    %edi,-0x26c(%ebp)
	return r;
  802c26:	e9 b6 00 00 00       	jmp    802ce1 <spawn+0x236>
	close(fd);
  802c2b:	83 ec 0c             	sub    $0xc,%esp
  802c2e:	ff b5 94 fd ff ff    	pushl  -0x26c(%ebp)
  802c34:	e8 b8 f3 ff ff       	call   801ff1 <close>
	if ((r = copy_shared_pages(child)) < 0)
  802c39:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  802c3f:	e8 5d fb ff ff       	call   8027a1 <copy_shared_pages>
  802c44:	83 c4 10             	add    $0x10,%esp
  802c47:	85 c0                	test   %eax,%eax
  802c49:	78 4b                	js     802c96 <spawn+0x1eb>
	child_tf.tf_eflags |= FL_IOPL_3;  // devious: see user/faultio.c
  802c4b:	81 8d dc fd ff ff 00 	orl    $0x3000,-0x224(%ebp)
  802c52:	30 00 00 
	if ((r = sys_env_set_trapframe(child, &child_tf)) < 0)
  802c55:	83 ec 08             	sub    $0x8,%esp
  802c58:	8d 85 a4 fd ff ff    	lea    -0x25c(%ebp),%eax
  802c5e:	50                   	push   %eax
  802c5f:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802c65:	e8 86 ea ff ff       	call   8016f0 <sys_env_set_trapframe>
  802c6a:	83 c4 10             	add    $0x10,%esp
  802c6d:	85 c0                	test   %eax,%eax
  802c6f:	78 3a                	js     802cab <spawn+0x200>
	if ((r = sys_env_set_status(child, ENV_RUNNABLE)) < 0)
  802c71:	83 ec 08             	sub    $0x8,%esp
  802c74:	6a 02                	push   $0x2
  802c76:	ff b5 8c fd ff ff    	pushl  -0x274(%ebp)
  802c7c:	e8 48 ea ff ff       	call   8016c9 <sys_env_set_status>
  802c81:	83 c4 10             	add    $0x10,%esp
  802c84:	85 c0                	test   %eax,%eax
  802c86:	78 38                	js     802cc0 <spawn+0x215>
	return child;
  802c88:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  802c8e:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802c94:	eb 4b                	jmp    802ce1 <spawn+0x236>
		panic("copy_shared_pages: %e", r);
  802c96:	50                   	push   %eax
  802c97:	68 17 3e 80 00       	push   $0x803e17
  802c9c:	68 8c 00 00 00       	push   $0x8c
  802ca1:	68 d4 3d 80 00       	push   $0x803dd4
  802ca6:	e8 d8 dd ff ff       	call   800a83 <_panic>
		panic("sys_env_set_trapframe: %e", r);
  802cab:	50                   	push   %eax
  802cac:	68 2d 3e 80 00       	push   $0x803e2d
  802cb1:	68 90 00 00 00       	push   $0x90
  802cb6:	68 d4 3d 80 00       	push   $0x803dd4
  802cbb:	e8 c3 dd ff ff       	call   800a83 <_panic>
		panic("sys_env_set_status: %e", r);
  802cc0:	50                   	push   %eax
  802cc1:	68 47 3e 80 00       	push   $0x803e47
  802cc6:	68 93 00 00 00       	push   $0x93
  802ccb:	68 d4 3d 80 00       	push   $0x803dd4
  802cd0:	e8 ae dd ff ff       	call   800a83 <_panic>
		return r;
  802cd5:	8b 85 8c fd ff ff    	mov    -0x274(%ebp),%eax
  802cdb:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
}
  802ce1:	8b 85 94 fd ff ff    	mov    -0x26c(%ebp),%eax
  802ce7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802cea:	5b                   	pop    %ebx
  802ceb:	5e                   	pop    %esi
  802cec:	5f                   	pop    %edi
  802ced:	5d                   	pop    %ebp
  802cee:	c3                   	ret    
		return r;
  802cef:	89 85 94 fd ff ff    	mov    %eax,-0x26c(%ebp)
  802cf5:	eb ea                	jmp    802ce1 <spawn+0x236>

00802cf7 <spawnl>:
{
  802cf7:	f3 0f 1e fb          	endbr32 
  802cfb:	55                   	push   %ebp
  802cfc:	89 e5                	mov    %esp,%ebp
  802cfe:	57                   	push   %edi
  802cff:	56                   	push   %esi
  802d00:	53                   	push   %ebx
  802d01:	83 ec 0c             	sub    $0xc,%esp
	va_start(vl, arg0);
  802d04:	8d 55 10             	lea    0x10(%ebp),%edx
	int argc = 0;
  802d07:	b8 00 00 00 00       	mov    $0x0,%eax
	while (va_arg(vl, void *) != NULL)
  802d0c:	8d 4a 04             	lea    0x4(%edx),%ecx
  802d0f:	83 3a 00             	cmpl   $0x0,(%edx)
  802d12:	74 07                	je     802d1b <spawnl+0x24>
		argc++;
  802d14:	83 c0 01             	add    $0x1,%eax
	while (va_arg(vl, void *) != NULL)
  802d17:	89 ca                	mov    %ecx,%edx
  802d19:	eb f1                	jmp    802d0c <spawnl+0x15>
	const char *argv[argc + 2];
  802d1b:	8d 14 85 17 00 00 00 	lea    0x17(,%eax,4),%edx
  802d22:	89 d1                	mov    %edx,%ecx
  802d24:	83 e1 f0             	and    $0xfffffff0,%ecx
  802d27:	81 e2 00 f0 ff ff    	and    $0xfffff000,%edx
  802d2d:	89 e6                	mov    %esp,%esi
  802d2f:	29 d6                	sub    %edx,%esi
  802d31:	89 f2                	mov    %esi,%edx
  802d33:	39 d4                	cmp    %edx,%esp
  802d35:	74 10                	je     802d47 <spawnl+0x50>
  802d37:	81 ec 00 10 00 00    	sub    $0x1000,%esp
  802d3d:	83 8c 24 fc 0f 00 00 	orl    $0x0,0xffc(%esp)
  802d44:	00 
  802d45:	eb ec                	jmp    802d33 <spawnl+0x3c>
  802d47:	89 ca                	mov    %ecx,%edx
  802d49:	81 e2 ff 0f 00 00    	and    $0xfff,%edx
  802d4f:	29 d4                	sub    %edx,%esp
  802d51:	85 d2                	test   %edx,%edx
  802d53:	74 05                	je     802d5a <spawnl+0x63>
  802d55:	83 4c 14 fc 00       	orl    $0x0,-0x4(%esp,%edx,1)
  802d5a:	8d 74 24 03          	lea    0x3(%esp),%esi
  802d5e:	89 f2                	mov    %esi,%edx
  802d60:	c1 ea 02             	shr    $0x2,%edx
  802d63:	83 e6 fc             	and    $0xfffffffc,%esi
  802d66:	89 f3                	mov    %esi,%ebx
	argv[0] = arg0;
  802d68:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802d6b:	89 0c 95 00 00 00 00 	mov    %ecx,0x0(,%edx,4)
	argv[argc + 1] = NULL;
  802d72:	c7 44 86 04 00 00 00 	movl   $0x0,0x4(%esi,%eax,4)
  802d79:	00 
	va_start(vl, arg0);
  802d7a:	8d 4d 10             	lea    0x10(%ebp),%ecx
  802d7d:	89 c2                	mov    %eax,%edx
	for (i = 0; i < argc; i++)
  802d7f:	b8 00 00 00 00       	mov    $0x0,%eax
  802d84:	eb 0b                	jmp    802d91 <spawnl+0x9a>
		argv[i + 1] = va_arg(vl, const char *);
  802d86:	83 c0 01             	add    $0x1,%eax
  802d89:	8b 39                	mov    (%ecx),%edi
  802d8b:	89 3c 83             	mov    %edi,(%ebx,%eax,4)
  802d8e:	8d 49 04             	lea    0x4(%ecx),%ecx
	for (i = 0; i < argc; i++)
  802d91:	39 d0                	cmp    %edx,%eax
  802d93:	75 f1                	jne    802d86 <spawnl+0x8f>
	return spawn(prog, argv);
  802d95:	83 ec 08             	sub    $0x8,%esp
  802d98:	56                   	push   %esi
  802d99:	ff 75 08             	pushl  0x8(%ebp)
  802d9c:	e8 0a fd ff ff       	call   802aab <spawn>
}
  802da1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802da4:	5b                   	pop    %ebx
  802da5:	5e                   	pop    %esi
  802da6:	5f                   	pop    %edi
  802da7:	5d                   	pop    %ebp
  802da8:	c3                   	ret    

00802da9 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  802da9:	f3 0f 1e fb          	endbr32 
  802dad:	55                   	push   %ebp
  802dae:	89 e5                	mov    %esp,%ebp
  802db0:	56                   	push   %esi
  802db1:	53                   	push   %ebx
  802db2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  802db5:	83 ec 0c             	sub    $0xc,%esp
  802db8:	ff 75 08             	pushl  0x8(%ebp)
  802dbb:	e8 83 f0 ff ff       	call   801e43 <fd2data>
  802dc0:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  802dc2:	83 c4 08             	add    $0x8,%esp
  802dc5:	68 5e 3e 80 00       	push   $0x803e5e
  802dca:	53                   	push   %ebx
  802dcb:	e8 f8 e3 ff ff       	call   8011c8 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  802dd0:	8b 46 04             	mov    0x4(%esi),%eax
  802dd3:	2b 06                	sub    (%esi),%eax
  802dd5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  802ddb:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  802de2:	00 00 00 
	stat->st_dev = &devpipe;
  802de5:	c7 83 88 00 00 00 3c 	movl   $0x80403c,0x88(%ebx)
  802dec:	40 80 00 
	return 0;
}
  802def:	b8 00 00 00 00       	mov    $0x0,%eax
  802df4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  802df7:	5b                   	pop    %ebx
  802df8:	5e                   	pop    %esi
  802df9:	5d                   	pop    %ebp
  802dfa:	c3                   	ret    

00802dfb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  802dfb:	f3 0f 1e fb          	endbr32 
  802dff:	55                   	push   %ebp
  802e00:	89 e5                	mov    %esp,%ebp
  802e02:	53                   	push   %ebx
  802e03:	83 ec 0c             	sub    $0xc,%esp
  802e06:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  802e09:	53                   	push   %ebx
  802e0a:	6a 00                	push   $0x0
  802e0c:	e8 91 e8 ff ff       	call   8016a2 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  802e11:	89 1c 24             	mov    %ebx,(%esp)
  802e14:	e8 2a f0 ff ff       	call   801e43 <fd2data>
  802e19:	83 c4 08             	add    $0x8,%esp
  802e1c:	50                   	push   %eax
  802e1d:	6a 00                	push   $0x0
  802e1f:	e8 7e e8 ff ff       	call   8016a2 <sys_page_unmap>
}
  802e24:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  802e27:	c9                   	leave  
  802e28:	c3                   	ret    

00802e29 <_pipeisclosed>:
{
  802e29:	55                   	push   %ebp
  802e2a:	89 e5                	mov    %esp,%ebp
  802e2c:	57                   	push   %edi
  802e2d:	56                   	push   %esi
  802e2e:	53                   	push   %ebx
  802e2f:	83 ec 1c             	sub    $0x1c,%esp
  802e32:	89 c7                	mov    %eax,%edi
  802e34:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  802e36:	a1 24 54 80 00       	mov    0x805424,%eax
  802e3b:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  802e3e:	83 ec 0c             	sub    $0xc,%esp
  802e41:	57                   	push   %edi
  802e42:	e8 ae 04 00 00       	call   8032f5 <pageref>
  802e47:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  802e4a:	89 34 24             	mov    %esi,(%esp)
  802e4d:	e8 a3 04 00 00       	call   8032f5 <pageref>
		nn = thisenv->env_runs;
  802e52:	8b 15 24 54 80 00    	mov    0x805424,%edx
  802e58:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  802e5b:	83 c4 10             	add    $0x10,%esp
  802e5e:	39 cb                	cmp    %ecx,%ebx
  802e60:	74 1b                	je     802e7d <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  802e62:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802e65:	75 cf                	jne    802e36 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  802e67:	8b 42 58             	mov    0x58(%edx),%eax
  802e6a:	6a 01                	push   $0x1
  802e6c:	50                   	push   %eax
  802e6d:	53                   	push   %ebx
  802e6e:	68 65 3e 80 00       	push   $0x803e65
  802e73:	e8 f2 dc ff ff       	call   800b6a <cprintf>
  802e78:	83 c4 10             	add    $0x10,%esp
  802e7b:	eb b9                	jmp    802e36 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  802e7d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  802e80:	0f 94 c0             	sete   %al
  802e83:	0f b6 c0             	movzbl %al,%eax
}
  802e86:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802e89:	5b                   	pop    %ebx
  802e8a:	5e                   	pop    %esi
  802e8b:	5f                   	pop    %edi
  802e8c:	5d                   	pop    %ebp
  802e8d:	c3                   	ret    

00802e8e <devpipe_write>:
{
  802e8e:	f3 0f 1e fb          	endbr32 
  802e92:	55                   	push   %ebp
  802e93:	89 e5                	mov    %esp,%ebp
  802e95:	57                   	push   %edi
  802e96:	56                   	push   %esi
  802e97:	53                   	push   %ebx
  802e98:	83 ec 28             	sub    $0x28,%esp
  802e9b:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  802e9e:	56                   	push   %esi
  802e9f:	e8 9f ef ff ff       	call   801e43 <fd2data>
  802ea4:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802ea6:	83 c4 10             	add    $0x10,%esp
  802ea9:	bf 00 00 00 00       	mov    $0x0,%edi
  802eae:	3b 7d 10             	cmp    0x10(%ebp),%edi
  802eb1:	74 4f                	je     802f02 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  802eb3:	8b 43 04             	mov    0x4(%ebx),%eax
  802eb6:	8b 0b                	mov    (%ebx),%ecx
  802eb8:	8d 51 20             	lea    0x20(%ecx),%edx
  802ebb:	39 d0                	cmp    %edx,%eax
  802ebd:	72 14                	jb     802ed3 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  802ebf:	89 da                	mov    %ebx,%edx
  802ec1:	89 f0                	mov    %esi,%eax
  802ec3:	e8 61 ff ff ff       	call   802e29 <_pipeisclosed>
  802ec8:	85 c0                	test   %eax,%eax
  802eca:	75 3b                	jne    802f07 <devpipe_write+0x79>
			sys_yield();
  802ecc:	e8 54 e7 ff ff       	call   801625 <sys_yield>
  802ed1:	eb e0                	jmp    802eb3 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  802ed3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802ed6:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  802eda:	88 4d e7             	mov    %cl,-0x19(%ebp)
  802edd:	89 c2                	mov    %eax,%edx
  802edf:	c1 fa 1f             	sar    $0x1f,%edx
  802ee2:	89 d1                	mov    %edx,%ecx
  802ee4:	c1 e9 1b             	shr    $0x1b,%ecx
  802ee7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  802eea:	83 e2 1f             	and    $0x1f,%edx
  802eed:	29 ca                	sub    %ecx,%edx
  802eef:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  802ef3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  802ef7:	83 c0 01             	add    $0x1,%eax
  802efa:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  802efd:	83 c7 01             	add    $0x1,%edi
  802f00:	eb ac                	jmp    802eae <devpipe_write+0x20>
	return i;
  802f02:	8b 45 10             	mov    0x10(%ebp),%eax
  802f05:	eb 05                	jmp    802f0c <devpipe_write+0x7e>
				return 0;
  802f07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  802f0c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802f0f:	5b                   	pop    %ebx
  802f10:	5e                   	pop    %esi
  802f11:	5f                   	pop    %edi
  802f12:	5d                   	pop    %ebp
  802f13:	c3                   	ret    

00802f14 <devpipe_read>:
{
  802f14:	f3 0f 1e fb          	endbr32 
  802f18:	55                   	push   %ebp
  802f19:	89 e5                	mov    %esp,%ebp
  802f1b:	57                   	push   %edi
  802f1c:	56                   	push   %esi
  802f1d:	53                   	push   %ebx
  802f1e:	83 ec 18             	sub    $0x18,%esp
  802f21:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  802f24:	57                   	push   %edi
  802f25:	e8 19 ef ff ff       	call   801e43 <fd2data>
  802f2a:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  802f2c:	83 c4 10             	add    $0x10,%esp
  802f2f:	be 00 00 00 00       	mov    $0x0,%esi
  802f34:	3b 75 10             	cmp    0x10(%ebp),%esi
  802f37:	75 14                	jne    802f4d <devpipe_read+0x39>
	return i;
  802f39:	8b 45 10             	mov    0x10(%ebp),%eax
  802f3c:	eb 02                	jmp    802f40 <devpipe_read+0x2c>
				return i;
  802f3e:	89 f0                	mov    %esi,%eax
}
  802f40:	8d 65 f4             	lea    -0xc(%ebp),%esp
  802f43:	5b                   	pop    %ebx
  802f44:	5e                   	pop    %esi
  802f45:	5f                   	pop    %edi
  802f46:	5d                   	pop    %ebp
  802f47:	c3                   	ret    
			sys_yield();
  802f48:	e8 d8 e6 ff ff       	call   801625 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  802f4d:	8b 03                	mov    (%ebx),%eax
  802f4f:	3b 43 04             	cmp    0x4(%ebx),%eax
  802f52:	75 18                	jne    802f6c <devpipe_read+0x58>
			if (i > 0)
  802f54:	85 f6                	test   %esi,%esi
  802f56:	75 e6                	jne    802f3e <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  802f58:	89 da                	mov    %ebx,%edx
  802f5a:	89 f8                	mov    %edi,%eax
  802f5c:	e8 c8 fe ff ff       	call   802e29 <_pipeisclosed>
  802f61:	85 c0                	test   %eax,%eax
  802f63:	74 e3                	je     802f48 <devpipe_read+0x34>
				return 0;
  802f65:	b8 00 00 00 00       	mov    $0x0,%eax
  802f6a:	eb d4                	jmp    802f40 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  802f6c:	99                   	cltd   
  802f6d:	c1 ea 1b             	shr    $0x1b,%edx
  802f70:	01 d0                	add    %edx,%eax
  802f72:	83 e0 1f             	and    $0x1f,%eax
  802f75:	29 d0                	sub    %edx,%eax
  802f77:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  802f7c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  802f7f:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  802f82:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  802f85:	83 c6 01             	add    $0x1,%esi
  802f88:	eb aa                	jmp    802f34 <devpipe_read+0x20>

00802f8a <pipe>:
{
  802f8a:	f3 0f 1e fb          	endbr32 
  802f8e:	55                   	push   %ebp
  802f8f:	89 e5                	mov    %esp,%ebp
  802f91:	56                   	push   %esi
  802f92:	53                   	push   %ebx
  802f93:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  802f96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  802f99:	50                   	push   %eax
  802f9a:	e8 c3 ee ff ff       	call   801e62 <fd_alloc>
  802f9f:	89 c3                	mov    %eax,%ebx
  802fa1:	83 c4 10             	add    $0x10,%esp
  802fa4:	85 c0                	test   %eax,%eax
  802fa6:	0f 88 23 01 00 00    	js     8030cf <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802fac:	83 ec 04             	sub    $0x4,%esp
  802faf:	68 07 04 00 00       	push   $0x407
  802fb4:	ff 75 f4             	pushl  -0xc(%ebp)
  802fb7:	6a 00                	push   $0x0
  802fb9:	e8 92 e6 ff ff       	call   801650 <sys_page_alloc>
  802fbe:	89 c3                	mov    %eax,%ebx
  802fc0:	83 c4 10             	add    $0x10,%esp
  802fc3:	85 c0                	test   %eax,%eax
  802fc5:	0f 88 04 01 00 00    	js     8030cf <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  802fcb:	83 ec 0c             	sub    $0xc,%esp
  802fce:	8d 45 f0             	lea    -0x10(%ebp),%eax
  802fd1:	50                   	push   %eax
  802fd2:	e8 8b ee ff ff       	call   801e62 <fd_alloc>
  802fd7:	89 c3                	mov    %eax,%ebx
  802fd9:	83 c4 10             	add    $0x10,%esp
  802fdc:	85 c0                	test   %eax,%eax
  802fde:	0f 88 db 00 00 00    	js     8030bf <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  802fe4:	83 ec 04             	sub    $0x4,%esp
  802fe7:	68 07 04 00 00       	push   $0x407
  802fec:	ff 75 f0             	pushl  -0x10(%ebp)
  802fef:	6a 00                	push   $0x0
  802ff1:	e8 5a e6 ff ff       	call   801650 <sys_page_alloc>
  802ff6:	89 c3                	mov    %eax,%ebx
  802ff8:	83 c4 10             	add    $0x10,%esp
  802ffb:	85 c0                	test   %eax,%eax
  802ffd:	0f 88 bc 00 00 00    	js     8030bf <pipe+0x135>
	va = fd2data(fd0);
  803003:	83 ec 0c             	sub    $0xc,%esp
  803006:	ff 75 f4             	pushl  -0xc(%ebp)
  803009:	e8 35 ee ff ff       	call   801e43 <fd2data>
  80300e:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  803010:	83 c4 0c             	add    $0xc,%esp
  803013:	68 07 04 00 00       	push   $0x407
  803018:	50                   	push   %eax
  803019:	6a 00                	push   $0x0
  80301b:	e8 30 e6 ff ff       	call   801650 <sys_page_alloc>
  803020:	89 c3                	mov    %eax,%ebx
  803022:	83 c4 10             	add    $0x10,%esp
  803025:	85 c0                	test   %eax,%eax
  803027:	0f 88 82 00 00 00    	js     8030af <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  80302d:	83 ec 0c             	sub    $0xc,%esp
  803030:	ff 75 f0             	pushl  -0x10(%ebp)
  803033:	e8 0b ee ff ff       	call   801e43 <fd2data>
  803038:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  80303f:	50                   	push   %eax
  803040:	6a 00                	push   $0x0
  803042:	56                   	push   %esi
  803043:	6a 00                	push   $0x0
  803045:	e8 2e e6 ff ff       	call   801678 <sys_page_map>
  80304a:	89 c3                	mov    %eax,%ebx
  80304c:	83 c4 20             	add    $0x20,%esp
  80304f:	85 c0                	test   %eax,%eax
  803051:	78 4e                	js     8030a1 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  803053:	a1 3c 40 80 00       	mov    0x80403c,%eax
  803058:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80305b:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  80305d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  803060:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  803067:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80306a:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  80306c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80306f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  803076:	83 ec 0c             	sub    $0xc,%esp
  803079:	ff 75 f4             	pushl  -0xc(%ebp)
  80307c:	e8 ae ed ff ff       	call   801e2f <fd2num>
  803081:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803084:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  803086:	83 c4 04             	add    $0x4,%esp
  803089:	ff 75 f0             	pushl  -0x10(%ebp)
  80308c:	e8 9e ed ff ff       	call   801e2f <fd2num>
  803091:	8b 4d 08             	mov    0x8(%ebp),%ecx
  803094:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  803097:	83 c4 10             	add    $0x10,%esp
  80309a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80309f:	eb 2e                	jmp    8030cf <pipe+0x145>
	sys_page_unmap(0, va);
  8030a1:	83 ec 08             	sub    $0x8,%esp
  8030a4:	56                   	push   %esi
  8030a5:	6a 00                	push   $0x0
  8030a7:	e8 f6 e5 ff ff       	call   8016a2 <sys_page_unmap>
  8030ac:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  8030af:	83 ec 08             	sub    $0x8,%esp
  8030b2:	ff 75 f0             	pushl  -0x10(%ebp)
  8030b5:	6a 00                	push   $0x0
  8030b7:	e8 e6 e5 ff ff       	call   8016a2 <sys_page_unmap>
  8030bc:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  8030bf:	83 ec 08             	sub    $0x8,%esp
  8030c2:	ff 75 f4             	pushl  -0xc(%ebp)
  8030c5:	6a 00                	push   $0x0
  8030c7:	e8 d6 e5 ff ff       	call   8016a2 <sys_page_unmap>
  8030cc:	83 c4 10             	add    $0x10,%esp
}
  8030cf:	89 d8                	mov    %ebx,%eax
  8030d1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8030d4:	5b                   	pop    %ebx
  8030d5:	5e                   	pop    %esi
  8030d6:	5d                   	pop    %ebp
  8030d7:	c3                   	ret    

008030d8 <pipeisclosed>:
{
  8030d8:	f3 0f 1e fb          	endbr32 
  8030dc:	55                   	push   %ebp
  8030dd:	89 e5                	mov    %esp,%ebp
  8030df:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8030e2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8030e5:	50                   	push   %eax
  8030e6:	ff 75 08             	pushl  0x8(%ebp)
  8030e9:	e8 ca ed ff ff       	call   801eb8 <fd_lookup>
  8030ee:	83 c4 10             	add    $0x10,%esp
  8030f1:	85 c0                	test   %eax,%eax
  8030f3:	78 18                	js     80310d <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  8030f5:	83 ec 0c             	sub    $0xc,%esp
  8030f8:	ff 75 f4             	pushl  -0xc(%ebp)
  8030fb:	e8 43 ed ff ff       	call   801e43 <fd2data>
  803100:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  803102:	8b 45 f4             	mov    -0xc(%ebp),%eax
  803105:	e8 1f fd ff ff       	call   802e29 <_pipeisclosed>
  80310a:	83 c4 10             	add    $0x10,%esp
}
  80310d:	c9                   	leave  
  80310e:	c3                   	ret    

0080310f <wait>:
#include <inc/lib.h>

// Waits until 'envid' exits.
void
wait(envid_t envid)
{
  80310f:	f3 0f 1e fb          	endbr32 
  803113:	55                   	push   %ebp
  803114:	89 e5                	mov    %esp,%ebp
  803116:	56                   	push   %esi
  803117:	53                   	push   %ebx
  803118:	8b 75 08             	mov    0x8(%ebp),%esi
	const volatile struct Env *e;

	assert(envid != 0);
  80311b:	85 f6                	test   %esi,%esi
  80311d:	74 13                	je     803132 <wait+0x23>
	e = &envs[ENVX(envid)];
  80311f:	89 f3                	mov    %esi,%ebx
  803121:	81 e3 ff 03 00 00    	and    $0x3ff,%ebx
	while (e->env_id == envid && e->env_status != ENV_FREE)
  803127:	6b db 7c             	imul   $0x7c,%ebx,%ebx
  80312a:	81 c3 00 00 c0 ee    	add    $0xeec00000,%ebx
  803130:	eb 1b                	jmp    80314d <wait+0x3e>
	assert(envid != 0);
  803132:	68 7d 3e 80 00       	push   $0x803e7d
  803137:	68 da 36 80 00       	push   $0x8036da
  80313c:	6a 09                	push   $0x9
  80313e:	68 88 3e 80 00       	push   $0x803e88
  803143:	e8 3b d9 ff ff       	call   800a83 <_panic>
		sys_yield();
  803148:	e8 d8 e4 ff ff       	call   801625 <sys_yield>
	while (e->env_id == envid && e->env_status != ENV_FREE)
  80314d:	8b 43 48             	mov    0x48(%ebx),%eax
  803150:	39 f0                	cmp    %esi,%eax
  803152:	75 07                	jne    80315b <wait+0x4c>
  803154:	8b 43 54             	mov    0x54(%ebx),%eax
  803157:	85 c0                	test   %eax,%eax
  803159:	75 ed                	jne    803148 <wait+0x39>
}
  80315b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80315e:	5b                   	pop    %ebx
  80315f:	5e                   	pop    %esi
  803160:	5d                   	pop    %ebp
  803161:	c3                   	ret    

00803162 <set_pgfault_handler>:
// at UXSTACKTOP), and tell the kernel to call the assembly-language
// _pgfault_upcall routine when a page fault occurs.
//
void
set_pgfault_handler(void (*handler)(struct UTrapframe *utf))
{
  803162:	f3 0f 1e fb          	endbr32 
  803166:	55                   	push   %ebp
  803167:	89 e5                	mov    %esp,%ebp
  803169:	83 ec 08             	sub    $0x8,%esp
	int r;

	if (_pgfault_handler == 0) {
  80316c:	83 3d 00 70 80 00 00 	cmpl   $0x0,0x807000
  803173:	74 1c                	je     803191 <set_pgfault_handler+0x2f>
		// LAB 4: Your code here.
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
	}

	// Save handler pointer for assembly to call.
	_pgfault_handler = handler;
  803175:	8b 45 08             	mov    0x8(%ebp),%eax
  803178:	a3 00 70 80 00       	mov    %eax,0x807000

	//Indicarle al kerne que _pgfault_upcall va a ser el manejador de pgfaults de un proceso
	sys_env_set_pgfault_upcall(0, &(_pgfault_upcall));
  80317d:	83 ec 08             	sub    $0x8,%esp
  803180:	68 bd 31 80 00       	push   $0x8031bd
  803185:	6a 00                	push   $0x0
  803187:	e8 8b e5 ff ff       	call   801717 <sys_env_set_pgfault_upcall>
}
  80318c:	83 c4 10             	add    $0x10,%esp
  80318f:	c9                   	leave  
  803190:	c3                   	ret    
		if((r = sys_page_alloc(0, (void *)(UXSTACKTOP - PGSIZE), PTE_W)) < 0) panic("set_pgfault_handler failed");
  803191:	83 ec 04             	sub    $0x4,%esp
  803194:	6a 02                	push   $0x2
  803196:	68 00 f0 bf ee       	push   $0xeebff000
  80319b:	6a 00                	push   $0x0
  80319d:	e8 ae e4 ff ff       	call   801650 <sys_page_alloc>
  8031a2:	83 c4 10             	add    $0x10,%esp
  8031a5:	85 c0                	test   %eax,%eax
  8031a7:	79 cc                	jns    803175 <set_pgfault_handler+0x13>
  8031a9:	83 ec 04             	sub    $0x4,%esp
  8031ac:	68 93 3e 80 00       	push   $0x803e93
  8031b1:	6a 20                	push   $0x20
  8031b3:	68 ae 3e 80 00       	push   $0x803eae
  8031b8:	e8 c6 d8 ff ff       	call   800a83 <_panic>

008031bd <_pgfault_upcall>:

.text
.globl _pgfault_upcall
_pgfault_upcall:
	// Call the C page fault handler.
	pushl %esp			// function argument: pointer to UTF
  8031bd:	54                   	push   %esp
	movl _pgfault_handler, %eax
  8031be:	a1 00 70 80 00       	mov    0x807000,%eax
	call *%eax
  8031c3:	ff d0                	call   *%eax
	addl $4, %esp			// pop function argument
  8031c5:	83 c4 04             	add    $0x4,%esp
	// registers are available for intermediate calculations.  You
	// may find that you have to rearrange your code in non-obvious
	// ways as registers become unavailable as scratch space.
	//
	// LAB 4: Your code here.
	movl 40(%esp), %eax
  8031c8:	8b 44 24 28          	mov    0x28(%esp),%eax
	movl 48(%esp), %ebx	
  8031cc:	8b 5c 24 30          	mov    0x30(%esp),%ebx
	subl $4, %ebx
  8031d0:	83 eb 04             	sub    $0x4,%ebx
	movl %eax, (%ebx)
  8031d3:	89 03                	mov    %eax,(%ebx)
	movl %ebx, 48(%esp)
  8031d5:	89 5c 24 30          	mov    %ebx,0x30(%esp)

	// Restore the trap-time registers.  After you do this, you
	// can no longer modify any general-purpose registers.
	// LAB 4: Your code here.
	addl $8, %esp
  8031d9:	83 c4 08             	add    $0x8,%esp
	popal
  8031dc:	61                   	popa   

	// Restore eflags from the stack.  After you do this, you can
	// no longer use arithmetic operations or anything else that
	// modifies eflags.
	// LAB 4: Your code here.
	addl $4, %esp
  8031dd:	83 c4 04             	add    $0x4,%esp
	popfl
  8031e0:	9d                   	popf   

	// Switch back to the adjusted trap-time stack.
	// LAB 4: Your code here.
	movl (%esp), %esp
  8031e1:	8b 24 24             	mov    (%esp),%esp

	// Return to re-execute the instruction that faulted.
	// LAB 4: Your code here.
  8031e4:	c3                   	ret    

008031e5 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  8031e5:	f3 0f 1e fb          	endbr32 
  8031e9:	55                   	push   %ebp
  8031ea:	89 e5                	mov    %esp,%ebp
  8031ec:	56                   	push   %esi
  8031ed:	53                   	push   %ebx
  8031ee:	8b 75 08             	mov    0x8(%ebp),%esi
  8031f1:	8b 45 0c             	mov    0xc(%ebp),%eax
  8031f4:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  8031f7:	85 c0                	test   %eax,%eax
  8031f9:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  8031fe:	0f 44 c2             	cmove  %edx,%eax
  803201:	83 ec 0c             	sub    $0xc,%esp
  803204:	50                   	push   %eax
  803205:	e8 5d e5 ff ff       	call   801767 <sys_ipc_recv>

	if (from_env_store != NULL)
  80320a:	83 c4 10             	add    $0x10,%esp
  80320d:	85 f6                	test   %esi,%esi
  80320f:	74 15                	je     803226 <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  803211:	ba 00 00 00 00       	mov    $0x0,%edx
  803216:	83 f8 fd             	cmp    $0xfffffffd,%eax
  803219:	74 09                	je     803224 <ipc_recv+0x3f>
  80321b:	8b 15 24 54 80 00    	mov    0x805424,%edx
  803221:	8b 52 74             	mov    0x74(%edx),%edx
  803224:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  803226:	85 db                	test   %ebx,%ebx
  803228:	74 15                	je     80323f <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  80322a:	ba 00 00 00 00       	mov    $0x0,%edx
  80322f:	83 f8 fd             	cmp    $0xfffffffd,%eax
  803232:	74 09                	je     80323d <ipc_recv+0x58>
  803234:	8b 15 24 54 80 00    	mov    0x805424,%edx
  80323a:	8b 52 78             	mov    0x78(%edx),%edx
  80323d:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  80323f:	83 f8 fd             	cmp    $0xfffffffd,%eax
  803242:	74 08                	je     80324c <ipc_recv+0x67>
  803244:	a1 24 54 80 00       	mov    0x805424,%eax
  803249:	8b 40 70             	mov    0x70(%eax),%eax
}
  80324c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80324f:	5b                   	pop    %ebx
  803250:	5e                   	pop    %esi
  803251:	5d                   	pop    %ebp
  803252:	c3                   	ret    

00803253 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  803253:	f3 0f 1e fb          	endbr32 
  803257:	55                   	push   %ebp
  803258:	89 e5                	mov    %esp,%ebp
  80325a:	57                   	push   %edi
  80325b:	56                   	push   %esi
  80325c:	53                   	push   %ebx
  80325d:	83 ec 0c             	sub    $0xc,%esp
  803260:	8b 7d 08             	mov    0x8(%ebp),%edi
  803263:	8b 75 0c             	mov    0xc(%ebp),%esi
  803266:	8b 5d 10             	mov    0x10(%ebp),%ebx
  803269:	eb 1f                	jmp    80328a <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  80326b:	6a 00                	push   $0x0
  80326d:	68 00 00 c0 ee       	push   $0xeec00000
  803272:	56                   	push   %esi
  803273:	57                   	push   %edi
  803274:	e8 c5 e4 ff ff       	call   80173e <sys_ipc_try_send>
  803279:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  80327c:	85 c0                	test   %eax,%eax
  80327e:	74 30                	je     8032b0 <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  803280:	83 f8 f9             	cmp    $0xfffffff9,%eax
  803283:	75 19                	jne    80329e <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  803285:	e8 9b e3 ff ff       	call   801625 <sys_yield>
		if (pg != NULL) {
  80328a:	85 db                	test   %ebx,%ebx
  80328c:	74 dd                	je     80326b <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  80328e:	ff 75 14             	pushl  0x14(%ebp)
  803291:	53                   	push   %ebx
  803292:	56                   	push   %esi
  803293:	57                   	push   %edi
  803294:	e8 a5 e4 ff ff       	call   80173e <sys_ipc_try_send>
  803299:	83 c4 10             	add    $0x10,%esp
  80329c:	eb de                	jmp    80327c <ipc_send+0x29>
			panic("ipc_send: %d", res);
  80329e:	50                   	push   %eax
  80329f:	68 bc 3e 80 00       	push   $0x803ebc
  8032a4:	6a 3e                	push   $0x3e
  8032a6:	68 c9 3e 80 00       	push   $0x803ec9
  8032ab:	e8 d3 d7 ff ff       	call   800a83 <_panic>
	}
}
  8032b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8032b3:	5b                   	pop    %ebx
  8032b4:	5e                   	pop    %esi
  8032b5:	5f                   	pop    %edi
  8032b6:	5d                   	pop    %ebp
  8032b7:	c3                   	ret    

008032b8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8032b8:	f3 0f 1e fb          	endbr32 
  8032bc:	55                   	push   %ebp
  8032bd:	89 e5                	mov    %esp,%ebp
  8032bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8032c2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8032c7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8032ca:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8032d0:	8b 52 50             	mov    0x50(%edx),%edx
  8032d3:	39 ca                	cmp    %ecx,%edx
  8032d5:	74 11                	je     8032e8 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8032d7:	83 c0 01             	add    $0x1,%eax
  8032da:	3d 00 04 00 00       	cmp    $0x400,%eax
  8032df:	75 e6                	jne    8032c7 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  8032e1:	b8 00 00 00 00       	mov    $0x0,%eax
  8032e6:	eb 0b                	jmp    8032f3 <ipc_find_env+0x3b>
			return envs[i].env_id;
  8032e8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8032eb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8032f0:	8b 40 48             	mov    0x48(%eax),%eax
}
  8032f3:	5d                   	pop    %ebp
  8032f4:	c3                   	ret    

008032f5 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  8032f5:	f3 0f 1e fb          	endbr32 
  8032f9:	55                   	push   %ebp
  8032fa:	89 e5                	mov    %esp,%ebp
  8032fc:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  8032ff:	89 c2                	mov    %eax,%edx
  803301:	c1 ea 16             	shr    $0x16,%edx
  803304:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80330b:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  803310:	f6 c1 01             	test   $0x1,%cl
  803313:	74 1c                	je     803331 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  803315:	c1 e8 0c             	shr    $0xc,%eax
  803318:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80331f:	a8 01                	test   $0x1,%al
  803321:	74 0e                	je     803331 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  803323:	c1 e8 0c             	shr    $0xc,%eax
  803326:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80332d:	ef 
  80332e:	0f b7 d2             	movzwl %dx,%edx
}
  803331:	89 d0                	mov    %edx,%eax
  803333:	5d                   	pop    %ebp
  803334:	c3                   	ret    
  803335:	66 90                	xchg   %ax,%ax
  803337:	66 90                	xchg   %ax,%ax
  803339:	66 90                	xchg   %ax,%ax
  80333b:	66 90                	xchg   %ax,%ax
  80333d:	66 90                	xchg   %ax,%ax
  80333f:	90                   	nop

00803340 <__udivdi3>:
  803340:	f3 0f 1e fb          	endbr32 
  803344:	55                   	push   %ebp
  803345:	57                   	push   %edi
  803346:	56                   	push   %esi
  803347:	53                   	push   %ebx
  803348:	83 ec 1c             	sub    $0x1c,%esp
  80334b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  80334f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  803353:	8b 74 24 34          	mov    0x34(%esp),%esi
  803357:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  80335b:	85 d2                	test   %edx,%edx
  80335d:	75 19                	jne    803378 <__udivdi3+0x38>
  80335f:	39 f3                	cmp    %esi,%ebx
  803361:	76 4d                	jbe    8033b0 <__udivdi3+0x70>
  803363:	31 ff                	xor    %edi,%edi
  803365:	89 e8                	mov    %ebp,%eax
  803367:	89 f2                	mov    %esi,%edx
  803369:	f7 f3                	div    %ebx
  80336b:	89 fa                	mov    %edi,%edx
  80336d:	83 c4 1c             	add    $0x1c,%esp
  803370:	5b                   	pop    %ebx
  803371:	5e                   	pop    %esi
  803372:	5f                   	pop    %edi
  803373:	5d                   	pop    %ebp
  803374:	c3                   	ret    
  803375:	8d 76 00             	lea    0x0(%esi),%esi
  803378:	39 f2                	cmp    %esi,%edx
  80337a:	76 14                	jbe    803390 <__udivdi3+0x50>
  80337c:	31 ff                	xor    %edi,%edi
  80337e:	31 c0                	xor    %eax,%eax
  803380:	89 fa                	mov    %edi,%edx
  803382:	83 c4 1c             	add    $0x1c,%esp
  803385:	5b                   	pop    %ebx
  803386:	5e                   	pop    %esi
  803387:	5f                   	pop    %edi
  803388:	5d                   	pop    %ebp
  803389:	c3                   	ret    
  80338a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  803390:	0f bd fa             	bsr    %edx,%edi
  803393:	83 f7 1f             	xor    $0x1f,%edi
  803396:	75 48                	jne    8033e0 <__udivdi3+0xa0>
  803398:	39 f2                	cmp    %esi,%edx
  80339a:	72 06                	jb     8033a2 <__udivdi3+0x62>
  80339c:	31 c0                	xor    %eax,%eax
  80339e:	39 eb                	cmp    %ebp,%ebx
  8033a0:	77 de                	ja     803380 <__udivdi3+0x40>
  8033a2:	b8 01 00 00 00       	mov    $0x1,%eax
  8033a7:	eb d7                	jmp    803380 <__udivdi3+0x40>
  8033a9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8033b0:	89 d9                	mov    %ebx,%ecx
  8033b2:	85 db                	test   %ebx,%ebx
  8033b4:	75 0b                	jne    8033c1 <__udivdi3+0x81>
  8033b6:	b8 01 00 00 00       	mov    $0x1,%eax
  8033bb:	31 d2                	xor    %edx,%edx
  8033bd:	f7 f3                	div    %ebx
  8033bf:	89 c1                	mov    %eax,%ecx
  8033c1:	31 d2                	xor    %edx,%edx
  8033c3:	89 f0                	mov    %esi,%eax
  8033c5:	f7 f1                	div    %ecx
  8033c7:	89 c6                	mov    %eax,%esi
  8033c9:	89 e8                	mov    %ebp,%eax
  8033cb:	89 f7                	mov    %esi,%edi
  8033cd:	f7 f1                	div    %ecx
  8033cf:	89 fa                	mov    %edi,%edx
  8033d1:	83 c4 1c             	add    $0x1c,%esp
  8033d4:	5b                   	pop    %ebx
  8033d5:	5e                   	pop    %esi
  8033d6:	5f                   	pop    %edi
  8033d7:	5d                   	pop    %ebp
  8033d8:	c3                   	ret    
  8033d9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8033e0:	89 f9                	mov    %edi,%ecx
  8033e2:	b8 20 00 00 00       	mov    $0x20,%eax
  8033e7:	29 f8                	sub    %edi,%eax
  8033e9:	d3 e2                	shl    %cl,%edx
  8033eb:	89 54 24 08          	mov    %edx,0x8(%esp)
  8033ef:	89 c1                	mov    %eax,%ecx
  8033f1:	89 da                	mov    %ebx,%edx
  8033f3:	d3 ea                	shr    %cl,%edx
  8033f5:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  8033f9:	09 d1                	or     %edx,%ecx
  8033fb:	89 f2                	mov    %esi,%edx
  8033fd:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803401:	89 f9                	mov    %edi,%ecx
  803403:	d3 e3                	shl    %cl,%ebx
  803405:	89 c1                	mov    %eax,%ecx
  803407:	d3 ea                	shr    %cl,%edx
  803409:	89 f9                	mov    %edi,%ecx
  80340b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80340f:	89 eb                	mov    %ebp,%ebx
  803411:	d3 e6                	shl    %cl,%esi
  803413:	89 c1                	mov    %eax,%ecx
  803415:	d3 eb                	shr    %cl,%ebx
  803417:	09 de                	or     %ebx,%esi
  803419:	89 f0                	mov    %esi,%eax
  80341b:	f7 74 24 08          	divl   0x8(%esp)
  80341f:	89 d6                	mov    %edx,%esi
  803421:	89 c3                	mov    %eax,%ebx
  803423:	f7 64 24 0c          	mull   0xc(%esp)
  803427:	39 d6                	cmp    %edx,%esi
  803429:	72 15                	jb     803440 <__udivdi3+0x100>
  80342b:	89 f9                	mov    %edi,%ecx
  80342d:	d3 e5                	shl    %cl,%ebp
  80342f:	39 c5                	cmp    %eax,%ebp
  803431:	73 04                	jae    803437 <__udivdi3+0xf7>
  803433:	39 d6                	cmp    %edx,%esi
  803435:	74 09                	je     803440 <__udivdi3+0x100>
  803437:	89 d8                	mov    %ebx,%eax
  803439:	31 ff                	xor    %edi,%edi
  80343b:	e9 40 ff ff ff       	jmp    803380 <__udivdi3+0x40>
  803440:	8d 43 ff             	lea    -0x1(%ebx),%eax
  803443:	31 ff                	xor    %edi,%edi
  803445:	e9 36 ff ff ff       	jmp    803380 <__udivdi3+0x40>
  80344a:	66 90                	xchg   %ax,%ax
  80344c:	66 90                	xchg   %ax,%ax
  80344e:	66 90                	xchg   %ax,%ax

00803450 <__umoddi3>:
  803450:	f3 0f 1e fb          	endbr32 
  803454:	55                   	push   %ebp
  803455:	57                   	push   %edi
  803456:	56                   	push   %esi
  803457:	53                   	push   %ebx
  803458:	83 ec 1c             	sub    $0x1c,%esp
  80345b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  80345f:	8b 74 24 30          	mov    0x30(%esp),%esi
  803463:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  803467:	8b 7c 24 38          	mov    0x38(%esp),%edi
  80346b:	85 c0                	test   %eax,%eax
  80346d:	75 19                	jne    803488 <__umoddi3+0x38>
  80346f:	39 df                	cmp    %ebx,%edi
  803471:	76 5d                	jbe    8034d0 <__umoddi3+0x80>
  803473:	89 f0                	mov    %esi,%eax
  803475:	89 da                	mov    %ebx,%edx
  803477:	f7 f7                	div    %edi
  803479:	89 d0                	mov    %edx,%eax
  80347b:	31 d2                	xor    %edx,%edx
  80347d:	83 c4 1c             	add    $0x1c,%esp
  803480:	5b                   	pop    %ebx
  803481:	5e                   	pop    %esi
  803482:	5f                   	pop    %edi
  803483:	5d                   	pop    %ebp
  803484:	c3                   	ret    
  803485:	8d 76 00             	lea    0x0(%esi),%esi
  803488:	89 f2                	mov    %esi,%edx
  80348a:	39 d8                	cmp    %ebx,%eax
  80348c:	76 12                	jbe    8034a0 <__umoddi3+0x50>
  80348e:	89 f0                	mov    %esi,%eax
  803490:	89 da                	mov    %ebx,%edx
  803492:	83 c4 1c             	add    $0x1c,%esp
  803495:	5b                   	pop    %ebx
  803496:	5e                   	pop    %esi
  803497:	5f                   	pop    %edi
  803498:	5d                   	pop    %ebp
  803499:	c3                   	ret    
  80349a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  8034a0:	0f bd e8             	bsr    %eax,%ebp
  8034a3:	83 f5 1f             	xor    $0x1f,%ebp
  8034a6:	75 50                	jne    8034f8 <__umoddi3+0xa8>
  8034a8:	39 d8                	cmp    %ebx,%eax
  8034aa:	0f 82 e0 00 00 00    	jb     803590 <__umoddi3+0x140>
  8034b0:	89 d9                	mov    %ebx,%ecx
  8034b2:	39 f7                	cmp    %esi,%edi
  8034b4:	0f 86 d6 00 00 00    	jbe    803590 <__umoddi3+0x140>
  8034ba:	89 d0                	mov    %edx,%eax
  8034bc:	89 ca                	mov    %ecx,%edx
  8034be:	83 c4 1c             	add    $0x1c,%esp
  8034c1:	5b                   	pop    %ebx
  8034c2:	5e                   	pop    %esi
  8034c3:	5f                   	pop    %edi
  8034c4:	5d                   	pop    %ebp
  8034c5:	c3                   	ret    
  8034c6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8034cd:	8d 76 00             	lea    0x0(%esi),%esi
  8034d0:	89 fd                	mov    %edi,%ebp
  8034d2:	85 ff                	test   %edi,%edi
  8034d4:	75 0b                	jne    8034e1 <__umoddi3+0x91>
  8034d6:	b8 01 00 00 00       	mov    $0x1,%eax
  8034db:	31 d2                	xor    %edx,%edx
  8034dd:	f7 f7                	div    %edi
  8034df:	89 c5                	mov    %eax,%ebp
  8034e1:	89 d8                	mov    %ebx,%eax
  8034e3:	31 d2                	xor    %edx,%edx
  8034e5:	f7 f5                	div    %ebp
  8034e7:	89 f0                	mov    %esi,%eax
  8034e9:	f7 f5                	div    %ebp
  8034eb:	89 d0                	mov    %edx,%eax
  8034ed:	31 d2                	xor    %edx,%edx
  8034ef:	eb 8c                	jmp    80347d <__umoddi3+0x2d>
  8034f1:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8034f8:	89 e9                	mov    %ebp,%ecx
  8034fa:	ba 20 00 00 00       	mov    $0x20,%edx
  8034ff:	29 ea                	sub    %ebp,%edx
  803501:	d3 e0                	shl    %cl,%eax
  803503:	89 44 24 08          	mov    %eax,0x8(%esp)
  803507:	89 d1                	mov    %edx,%ecx
  803509:	89 f8                	mov    %edi,%eax
  80350b:	d3 e8                	shr    %cl,%eax
  80350d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  803511:	89 54 24 04          	mov    %edx,0x4(%esp)
  803515:	8b 54 24 04          	mov    0x4(%esp),%edx
  803519:	09 c1                	or     %eax,%ecx
  80351b:	89 d8                	mov    %ebx,%eax
  80351d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  803521:	89 e9                	mov    %ebp,%ecx
  803523:	d3 e7                	shl    %cl,%edi
  803525:	89 d1                	mov    %edx,%ecx
  803527:	d3 e8                	shr    %cl,%eax
  803529:	89 e9                	mov    %ebp,%ecx
  80352b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80352f:	d3 e3                	shl    %cl,%ebx
  803531:	89 c7                	mov    %eax,%edi
  803533:	89 d1                	mov    %edx,%ecx
  803535:	89 f0                	mov    %esi,%eax
  803537:	d3 e8                	shr    %cl,%eax
  803539:	89 e9                	mov    %ebp,%ecx
  80353b:	89 fa                	mov    %edi,%edx
  80353d:	d3 e6                	shl    %cl,%esi
  80353f:	09 d8                	or     %ebx,%eax
  803541:	f7 74 24 08          	divl   0x8(%esp)
  803545:	89 d1                	mov    %edx,%ecx
  803547:	89 f3                	mov    %esi,%ebx
  803549:	f7 64 24 0c          	mull   0xc(%esp)
  80354d:	89 c6                	mov    %eax,%esi
  80354f:	89 d7                	mov    %edx,%edi
  803551:	39 d1                	cmp    %edx,%ecx
  803553:	72 06                	jb     80355b <__umoddi3+0x10b>
  803555:	75 10                	jne    803567 <__umoddi3+0x117>
  803557:	39 c3                	cmp    %eax,%ebx
  803559:	73 0c                	jae    803567 <__umoddi3+0x117>
  80355b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  80355f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  803563:	89 d7                	mov    %edx,%edi
  803565:	89 c6                	mov    %eax,%esi
  803567:	89 ca                	mov    %ecx,%edx
  803569:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  80356e:	29 f3                	sub    %esi,%ebx
  803570:	19 fa                	sbb    %edi,%edx
  803572:	89 d0                	mov    %edx,%eax
  803574:	d3 e0                	shl    %cl,%eax
  803576:	89 e9                	mov    %ebp,%ecx
  803578:	d3 eb                	shr    %cl,%ebx
  80357a:	d3 ea                	shr    %cl,%edx
  80357c:	09 d8                	or     %ebx,%eax
  80357e:	83 c4 1c             	add    $0x1c,%esp
  803581:	5b                   	pop    %ebx
  803582:	5e                   	pop    %esi
  803583:	5f                   	pop    %edi
  803584:	5d                   	pop    %ebp
  803585:	c3                   	ret    
  803586:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80358d:	8d 76 00             	lea    0x0(%esi),%esi
  803590:	29 fe                	sub    %edi,%esi
  803592:	19 c3                	sbb    %eax,%ebx
  803594:	89 f2                	mov    %esi,%edx
  803596:	89 d9                	mov    %ebx,%ecx
  803598:	e9 1d ff ff ff       	jmp    8034ba <__umoddi3+0x6a>
