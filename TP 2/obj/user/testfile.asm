
obj/user/testfile.debug:     formato del fichero elf32-i386


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
  80002c:	e8 58 06 00 00       	call   800689 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <xopen>:

#define FVA ((struct Fd*)0xCCCCC000)

static int
xopen(const char *path, int mode)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	53                   	push   %ebx
  800037:	83 ec 0c             	sub    $0xc,%esp
  80003a:	89 d3                	mov    %edx,%ebx
	extern union Fsipc fsipcbuf;
	envid_t fsenv;
	
	strcpy(fsipcbuf.open.req_path, path);
  80003c:	50                   	push   %eax
  80003d:	68 00 50 80 00       	push   $0x805000
  800042:	e8 ff 0c 00 00       	call   800d46 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800047:	89 1d 00 54 80 00    	mov    %ebx,0x805400

	fsenv = ipc_find_env(ENV_TYPE_FS);
  80004d:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
  800054:	e8 85 13 00 00       	call   8013de <ipc_find_env>
	ipc_send(fsenv, FSREQ_OPEN, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800059:	6a 07                	push   $0x7
  80005b:	68 00 50 80 00       	push   $0x805000
  800060:	6a 01                	push   $0x1
  800062:	50                   	push   %eax
  800063:	e8 11 13 00 00       	call   801379 <ipc_send>
	return ipc_recv(NULL, FVA, NULL);
  800068:	83 c4 1c             	add    $0x1c,%esp
  80006b:	6a 00                	push   $0x0
  80006d:	68 00 c0 cc cc       	push   $0xccccc000
  800072:	6a 00                	push   $0x0
  800074:	e8 92 12 00 00       	call   80130b <ipc_recv>
}
  800079:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80007c:	c9                   	leave  
  80007d:	c3                   	ret    

0080007e <umain>:

void
umain(int argc, char **argv)
{
  80007e:	f3 0f 1e fb          	endbr32 
  800082:	55                   	push   %ebp
  800083:	89 e5                	mov    %esp,%ebp
  800085:	57                   	push   %edi
  800086:	56                   	push   %esi
  800087:	53                   	push   %ebx
  800088:	81 ec ac 02 00 00    	sub    $0x2ac,%esp
	struct Fd fdcopy;
	struct Stat st;
	char buf[512];

	// We open files manually first, to avoid the FD layer
	if ((r = xopen("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80008e:	ba 00 00 00 00       	mov    $0x0,%edx
  800093:	b8 20 24 80 00       	mov    $0x802420,%eax
  800098:	e8 96 ff ff ff       	call   800033 <xopen>
  80009d:	83 f8 f5             	cmp    $0xfffffff5,%eax
  8000a0:	74 08                	je     8000aa <umain+0x2c>
  8000a2:	85 c0                	test   %eax,%eax
  8000a4:	0f 88 e9 03 00 00    	js     800493 <umain+0x415>
		panic("serve_open /not-found: %e", r);
	else if (r >= 0)
  8000aa:	85 c0                	test   %eax,%eax
  8000ac:	0f 89 f3 03 00 00    	jns    8004a5 <umain+0x427>
		panic("serve_open /not-found succeeded!");

	if ((r = xopen("/newmotd", O_RDONLY)) < 0)
  8000b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000b7:	b8 55 24 80 00       	mov    $0x802455,%eax
  8000bc:	e8 72 ff ff ff       	call   800033 <xopen>
  8000c1:	85 c0                	test   %eax,%eax
  8000c3:	0f 88 f0 03 00 00    	js     8004b9 <umain+0x43b>
		panic("serve_open /newmotd: %e", r);
	if (FVA->fd_dev_id != 'f' || FVA->fd_offset != 0 || FVA->fd_omode != O_RDONLY)
  8000c9:	83 3d 00 c0 cc cc 66 	cmpl   $0x66,0xccccc000
  8000d0:	0f 85 f5 03 00 00    	jne    8004cb <umain+0x44d>
  8000d6:	83 3d 04 c0 cc cc 00 	cmpl   $0x0,0xccccc004
  8000dd:	0f 85 e8 03 00 00    	jne    8004cb <umain+0x44d>
  8000e3:	83 3d 08 c0 cc cc 00 	cmpl   $0x0,0xccccc008
  8000ea:	0f 85 db 03 00 00    	jne    8004cb <umain+0x44d>
		panic("serve_open did not fill struct Fd correctly\n");
	cprintf("serve_open is good\n");
  8000f0:	83 ec 0c             	sub    $0xc,%esp
  8000f3:	68 76 24 80 00       	push   $0x802476
  8000f8:	e8 df 06 00 00       	call   8007dc <cprintf>

	if ((r = devfile.dev_stat(FVA, &st)) < 0)
  8000fd:	83 c4 08             	add    $0x8,%esp
  800100:	8d 85 4c ff ff ff    	lea    -0xb4(%ebp),%eax
  800106:	50                   	push   %eax
  800107:	68 00 c0 cc cc       	push   $0xccccc000
  80010c:	ff 15 1c 30 80 00    	call   *0x80301c
  800112:	83 c4 10             	add    $0x10,%esp
  800115:	85 c0                	test   %eax,%eax
  800117:	0f 88 c2 03 00 00    	js     8004df <umain+0x461>
		panic("file_stat: %e", r);
	if (strlen(msg) != st.st_size)
  80011d:	83 ec 0c             	sub    $0xc,%esp
  800120:	ff 35 00 30 80 00    	pushl  0x803000
  800126:	e8 d8 0b 00 00       	call   800d03 <strlen>
  80012b:	83 c4 10             	add    $0x10,%esp
  80012e:	3b 45 cc             	cmp    -0x34(%ebp),%eax
  800131:	0f 85 ba 03 00 00    	jne    8004f1 <umain+0x473>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
	cprintf("file_stat is good\n");
  800137:	83 ec 0c             	sub    $0xc,%esp
  80013a:	68 98 24 80 00       	push   $0x802498
  80013f:	e8 98 06 00 00       	call   8007dc <cprintf>

	memset(buf, 0, sizeof buf);
  800144:	83 c4 0c             	add    $0xc,%esp
  800147:	68 00 02 00 00       	push   $0x200
  80014c:	6a 00                	push   $0x0
  80014e:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  800154:	53                   	push   %ebx
  800155:	e8 56 0d 00 00       	call   800eb0 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  80015a:	83 c4 0c             	add    $0xc,%esp
  80015d:	68 00 02 00 00       	push   $0x200
  800162:	53                   	push   %ebx
  800163:	68 00 c0 cc cc       	push   $0xccccc000
  800168:	ff 15 10 30 80 00    	call   *0x803010
  80016e:	83 c4 10             	add    $0x10,%esp
  800171:	85 c0                	test   %eax,%eax
  800173:	0f 88 9d 03 00 00    	js     800516 <umain+0x498>
		panic("file_read: %e", r);
	if (strcmp(buf, msg) != 0)
  800179:	83 ec 08             	sub    $0x8,%esp
  80017c:	ff 35 00 30 80 00    	pushl  0x803000
  800182:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800188:	50                   	push   %eax
  800189:	e8 77 0c 00 00       	call   800e05 <strcmp>
  80018e:	83 c4 10             	add    $0x10,%esp
  800191:	85 c0                	test   %eax,%eax
  800193:	0f 85 8f 03 00 00    	jne    800528 <umain+0x4aa>
		panic("file_read returned wrong data");
	cprintf("file_read is good\n");
  800199:	83 ec 0c             	sub    $0xc,%esp
  80019c:	68 d7 24 80 00       	push   $0x8024d7
  8001a1:	e8 36 06 00 00       	call   8007dc <cprintf>

	if ((r = devfile.dev_close(FVA)) < 0)
  8001a6:	c7 04 24 00 c0 cc cc 	movl   $0xccccc000,(%esp)
  8001ad:	ff 15 18 30 80 00    	call   *0x803018
  8001b3:	83 c4 10             	add    $0x10,%esp
  8001b6:	85 c0                	test   %eax,%eax
  8001b8:	0f 88 7e 03 00 00    	js     80053c <umain+0x4be>
		panic("file_close: %e", r);
	cprintf("file_close is good\n");
  8001be:	83 ec 0c             	sub    $0xc,%esp
  8001c1:	68 f9 24 80 00       	push   $0x8024f9
  8001c6:	e8 11 06 00 00       	call   8007dc <cprintf>

	// We're about to unmap the FD, but still need a way to get
	// the stale filenum to serve_read, so we make a local copy.
	// The file server won't think it's stale until we unmap the
	// FD page.
	fdcopy = *FVA;
  8001cb:	a1 00 c0 cc cc       	mov    0xccccc000,%eax
  8001d0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8001d3:	a1 04 c0 cc cc       	mov    0xccccc004,%eax
  8001d8:	89 45 dc             	mov    %eax,-0x24(%ebp)
  8001db:	a1 08 c0 cc cc       	mov    0xccccc008,%eax
  8001e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8001e3:	a1 0c c0 cc cc       	mov    0xccccc00c,%eax
  8001e8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
	sys_page_unmap(0, FVA);
  8001eb:	83 c4 08             	add    $0x8,%esp
  8001ee:	68 00 c0 cc cc       	push   $0xccccc000
  8001f3:	6a 00                	push   $0x0
  8001f5:	e8 26 10 00 00       	call   801220 <sys_page_unmap>

	if ((r = devfile.dev_read(&fdcopy, buf, sizeof buf)) != -E_INVAL)
  8001fa:	83 c4 0c             	add    $0xc,%esp
  8001fd:	68 00 02 00 00       	push   $0x200
  800202:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  800208:	50                   	push   %eax
  800209:	8d 45 d8             	lea    -0x28(%ebp),%eax
  80020c:	50                   	push   %eax
  80020d:	ff 15 10 30 80 00    	call   *0x803010
  800213:	83 c4 10             	add    $0x10,%esp
  800216:	83 f8 fd             	cmp    $0xfffffffd,%eax
  800219:	0f 85 2f 03 00 00    	jne    80054e <umain+0x4d0>
		panic("serve_read does not handle stale fileids correctly: %e", r);
	cprintf("stale fileid is good\n");
  80021f:	83 ec 0c             	sub    $0xc,%esp
  800222:	68 0d 25 80 00       	push   $0x80250d
  800227:	e8 b0 05 00 00       	call   8007dc <cprintf>

	// Try writing
	if ((r = xopen("/new-file", O_RDWR|O_CREAT)) < 0)
  80022c:	ba 02 01 00 00       	mov    $0x102,%edx
  800231:	b8 23 25 80 00       	mov    $0x802523,%eax
  800236:	e8 f8 fd ff ff       	call   800033 <xopen>
  80023b:	83 c4 10             	add    $0x10,%esp
  80023e:	85 c0                	test   %eax,%eax
  800240:	0f 88 1a 03 00 00    	js     800560 <umain+0x4e2>
		panic("serve_open /new-file: %e", r);

	if ((r = devfile.dev_write(FVA, msg, strlen(msg))) != strlen(msg))
  800246:	8b 1d 14 30 80 00    	mov    0x803014,%ebx
  80024c:	83 ec 0c             	sub    $0xc,%esp
  80024f:	ff 35 00 30 80 00    	pushl  0x803000
  800255:	e8 a9 0a 00 00       	call   800d03 <strlen>
  80025a:	83 c4 0c             	add    $0xc,%esp
  80025d:	50                   	push   %eax
  80025e:	ff 35 00 30 80 00    	pushl  0x803000
  800264:	68 00 c0 cc cc       	push   $0xccccc000
  800269:	ff d3                	call   *%ebx
  80026b:	89 c3                	mov    %eax,%ebx
  80026d:	83 c4 04             	add    $0x4,%esp
  800270:	ff 35 00 30 80 00    	pushl  0x803000
  800276:	e8 88 0a 00 00       	call   800d03 <strlen>
  80027b:	83 c4 10             	add    $0x10,%esp
  80027e:	39 d8                	cmp    %ebx,%eax
  800280:	0f 85 ec 02 00 00    	jne    800572 <umain+0x4f4>
		panic("file_write: %e", r);
	cprintf("file_write is good\n");
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	68 55 25 80 00       	push   $0x802555
  80028e:	e8 49 05 00 00       	call   8007dc <cprintf>

	FVA->fd_offset = 0;
  800293:	c7 05 04 c0 cc cc 00 	movl   $0x0,0xccccc004
  80029a:	00 00 00 
	memset(buf, 0, sizeof buf);
  80029d:	83 c4 0c             	add    $0xc,%esp
  8002a0:	68 00 02 00 00       	push   $0x200
  8002a5:	6a 00                	push   $0x0
  8002a7:	8d 9d 4c fd ff ff    	lea    -0x2b4(%ebp),%ebx
  8002ad:	53                   	push   %ebx
  8002ae:	e8 fd 0b 00 00       	call   800eb0 <memset>
	if ((r = devfile.dev_read(FVA, buf, sizeof buf)) < 0)
  8002b3:	83 c4 0c             	add    $0xc,%esp
  8002b6:	68 00 02 00 00       	push   $0x200
  8002bb:	53                   	push   %ebx
  8002bc:	68 00 c0 cc cc       	push   $0xccccc000
  8002c1:	ff 15 10 30 80 00    	call   *0x803010
  8002c7:	89 c3                	mov    %eax,%ebx
  8002c9:	83 c4 10             	add    $0x10,%esp
  8002cc:	85 c0                	test   %eax,%eax
  8002ce:	0f 88 b0 02 00 00    	js     800584 <umain+0x506>
		panic("file_read after file_write: %e", r);
	if (r != strlen(msg))
  8002d4:	83 ec 0c             	sub    $0xc,%esp
  8002d7:	ff 35 00 30 80 00    	pushl  0x803000
  8002dd:	e8 21 0a 00 00       	call   800d03 <strlen>
  8002e2:	83 c4 10             	add    $0x10,%esp
  8002e5:	39 d8                	cmp    %ebx,%eax
  8002e7:	0f 85 a9 02 00 00    	jne    800596 <umain+0x518>
		panic("file_read after file_write returned wrong length: %d", r);
	if (strcmp(buf, msg) != 0)
  8002ed:	83 ec 08             	sub    $0x8,%esp
  8002f0:	ff 35 00 30 80 00    	pushl  0x803000
  8002f6:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8002fc:	50                   	push   %eax
  8002fd:	e8 03 0b 00 00       	call   800e05 <strcmp>
  800302:	83 c4 10             	add    $0x10,%esp
  800305:	85 c0                	test   %eax,%eax
  800307:	0f 85 9b 02 00 00    	jne    8005a8 <umain+0x52a>
		panic("file_read after file_write returned wrong data");
	cprintf("file_read after file_write is good\n");
  80030d:	83 ec 0c             	sub    $0xc,%esp
  800310:	68 1c 27 80 00       	push   $0x80271c
  800315:	e8 c2 04 00 00       	call   8007dc <cprintf>

	// Now we'll try out open
	if ((r = open("/not-found", O_RDONLY)) < 0 && r != -E_NOT_FOUND)
  80031a:	83 c4 08             	add    $0x8,%esp
  80031d:	6a 00                	push   $0x0
  80031f:	68 20 24 80 00       	push   $0x802420
  800324:	e8 93 18 00 00       	call   801bbc <open>
  800329:	83 c4 10             	add    $0x10,%esp
  80032c:	83 f8 f5             	cmp    $0xfffffff5,%eax
  80032f:	74 08                	je     800339 <umain+0x2bb>
  800331:	85 c0                	test   %eax,%eax
  800333:	0f 88 83 02 00 00    	js     8005bc <umain+0x53e>
		panic("open /not-found: %e", r);
	else if (r >= 0)
  800339:	85 c0                	test   %eax,%eax
  80033b:	0f 89 8d 02 00 00    	jns    8005ce <umain+0x550>
		panic("open /not-found succeeded!");

	if ((r = open("/newmotd", O_RDONLY)) < 0)
  800341:	83 ec 08             	sub    $0x8,%esp
  800344:	6a 00                	push   $0x0
  800346:	68 55 24 80 00       	push   $0x802455
  80034b:	e8 6c 18 00 00       	call   801bbc <open>
  800350:	83 c4 10             	add    $0x10,%esp
  800353:	85 c0                	test   %eax,%eax
  800355:	0f 88 87 02 00 00    	js     8005e2 <umain+0x564>
		panic("open /newmotd: %e", r);
	fd = (struct Fd*) (0xD0000000 + r*PGSIZE);
  80035b:	c1 e0 0c             	shl    $0xc,%eax
	if (fd->fd_dev_id != 'f' || fd->fd_offset != 0 || fd->fd_omode != O_RDONLY)
  80035e:	83 b8 00 00 00 d0 66 	cmpl   $0x66,-0x30000000(%eax)
  800365:	0f 85 89 02 00 00    	jne    8005f4 <umain+0x576>
  80036b:	83 b8 04 00 00 d0 00 	cmpl   $0x0,-0x2ffffffc(%eax)
  800372:	0f 85 7c 02 00 00    	jne    8005f4 <umain+0x576>
  800378:	8b 98 08 00 00 d0    	mov    -0x2ffffff8(%eax),%ebx
  80037e:	85 db                	test   %ebx,%ebx
  800380:	0f 85 6e 02 00 00    	jne    8005f4 <umain+0x576>
		panic("open did not fill struct Fd correctly\n");
	cprintf("open is good\n");
  800386:	83 ec 0c             	sub    $0xc,%esp
  800389:	68 7c 24 80 00       	push   $0x80247c
  80038e:	e8 49 04 00 00       	call   8007dc <cprintf>

	// Try files with indirect blocks
	if ((f = open("/big", O_WRONLY|O_CREAT)) < 0)
  800393:	83 c4 08             	add    $0x8,%esp
  800396:	68 01 01 00 00       	push   $0x101
  80039b:	68 84 25 80 00       	push   $0x802584
  8003a0:	e8 17 18 00 00       	call   801bbc <open>
  8003a5:	89 c7                	mov    %eax,%edi
  8003a7:	83 c4 10             	add    $0x10,%esp
  8003aa:	85 c0                	test   %eax,%eax
  8003ac:	0f 88 56 02 00 00    	js     800608 <umain+0x58a>
		panic("creat /big: %e", f);
	memset(buf, 0, sizeof(buf));
  8003b2:	83 ec 04             	sub    $0x4,%esp
  8003b5:	68 00 02 00 00       	push   $0x200
  8003ba:	6a 00                	push   $0x0
  8003bc:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003c2:	50                   	push   %eax
  8003c3:	e8 e8 0a 00 00       	call   800eb0 <memset>
  8003c8:	83 c4 10             	add    $0x10,%esp
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8003cb:	89 de                	mov    %ebx,%esi
		*(int*)buf = i;
  8003cd:	89 b5 4c fd ff ff    	mov    %esi,-0x2b4(%ebp)
		if ((r = write(f, buf, sizeof(buf))) < 0)
  8003d3:	83 ec 04             	sub    $0x4,%esp
  8003d6:	68 00 02 00 00       	push   $0x200
  8003db:	8d 85 4c fd ff ff    	lea    -0x2b4(%ebp),%eax
  8003e1:	50                   	push   %eax
  8003e2:	57                   	push   %edi
  8003e3:	e8 15 14 00 00       	call   8017fd <write>
  8003e8:	83 c4 10             	add    $0x10,%esp
  8003eb:	85 c0                	test   %eax,%eax
  8003ed:	0f 88 27 02 00 00    	js     80061a <umain+0x59c>
  8003f3:	81 c6 00 02 00 00    	add    $0x200,%esi
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  8003f9:	81 fe 00 e0 01 00    	cmp    $0x1e000,%esi
  8003ff:	75 cc                	jne    8003cd <umain+0x34f>
			panic("write /big@%d: %e", i, r);
	}
	close(f);
  800401:	83 ec 0c             	sub    $0xc,%esp
  800404:	57                   	push   %edi
  800405:	e8 d3 11 00 00       	call   8015dd <close>

	if ((f = open("/big", O_RDONLY)) < 0)
  80040a:	83 c4 08             	add    $0x8,%esp
  80040d:	6a 00                	push   $0x0
  80040f:	68 84 25 80 00       	push   $0x802584
  800414:	e8 a3 17 00 00       	call   801bbc <open>
  800419:	89 c6                	mov    %eax,%esi
  80041b:	83 c4 10             	add    $0x10,%esp
  80041e:	85 c0                	test   %eax,%eax
  800420:	0f 88 0a 02 00 00    	js     800630 <umain+0x5b2>
		panic("open /big: %e", f);
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
		*(int*)buf = i;
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800426:	8d bd 4c fd ff ff    	lea    -0x2b4(%ebp),%edi
		*(int*)buf = i;
  80042c:	89 9d 4c fd ff ff    	mov    %ebx,-0x2b4(%ebp)
		if ((r = readn(f, buf, sizeof(buf))) < 0)
  800432:	83 ec 04             	sub    $0x4,%esp
  800435:	68 00 02 00 00       	push   $0x200
  80043a:	57                   	push   %edi
  80043b:	56                   	push   %esi
  80043c:	e8 71 13 00 00       	call   8017b2 <readn>
  800441:	83 c4 10             	add    $0x10,%esp
  800444:	85 c0                	test   %eax,%eax
  800446:	0f 88 f6 01 00 00    	js     800642 <umain+0x5c4>
			panic("read /big@%d: %e", i, r);
		if (r != sizeof(buf))
  80044c:	3d 00 02 00 00       	cmp    $0x200,%eax
  800451:	0f 85 01 02 00 00    	jne    800658 <umain+0x5da>
			panic("read /big from %d returned %d < %d bytes",
			      i, r, sizeof(buf));
		if (*(int*)buf != i)
  800457:	8b 85 4c fd ff ff    	mov    -0x2b4(%ebp),%eax
  80045d:	39 d8                	cmp    %ebx,%eax
  80045f:	0f 85 0e 02 00 00    	jne    800673 <umain+0x5f5>
  800465:	81 c3 00 02 00 00    	add    $0x200,%ebx
	for (i = 0; i < (NDIRECT*3)*BLKSIZE; i += sizeof(buf)) {
  80046b:	81 fb 00 e0 01 00    	cmp    $0x1e000,%ebx
  800471:	75 b9                	jne    80042c <umain+0x3ae>
			panic("read /big from %d returned bad data %d",
			      i, *(int*)buf);
	}
	close(f);
  800473:	83 ec 0c             	sub    $0xc,%esp
  800476:	56                   	push   %esi
  800477:	e8 61 11 00 00       	call   8015dd <close>
	cprintf("large file is good\n");
  80047c:	c7 04 24 c9 25 80 00 	movl   $0x8025c9,(%esp)
  800483:	e8 54 03 00 00       	call   8007dc <cprintf>
}
  800488:	83 c4 10             	add    $0x10,%esp
  80048b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80048e:	5b                   	pop    %ebx
  80048f:	5e                   	pop    %esi
  800490:	5f                   	pop    %edi
  800491:	5d                   	pop    %ebp
  800492:	c3                   	ret    
		panic("serve_open /not-found: %e", r);
  800493:	50                   	push   %eax
  800494:	68 2b 24 80 00       	push   $0x80242b
  800499:	6a 20                	push   $0x20
  80049b:	68 45 24 80 00       	push   $0x802445
  8004a0:	e8 50 02 00 00       	call   8006f5 <_panic>
		panic("serve_open /not-found succeeded!");
  8004a5:	83 ec 04             	sub    $0x4,%esp
  8004a8:	68 e0 25 80 00       	push   $0x8025e0
  8004ad:	6a 22                	push   $0x22
  8004af:	68 45 24 80 00       	push   $0x802445
  8004b4:	e8 3c 02 00 00       	call   8006f5 <_panic>
		panic("serve_open /newmotd: %e", r);
  8004b9:	50                   	push   %eax
  8004ba:	68 5e 24 80 00       	push   $0x80245e
  8004bf:	6a 25                	push   $0x25
  8004c1:	68 45 24 80 00       	push   $0x802445
  8004c6:	e8 2a 02 00 00       	call   8006f5 <_panic>
		panic("serve_open did not fill struct Fd correctly\n");
  8004cb:	83 ec 04             	sub    $0x4,%esp
  8004ce:	68 04 26 80 00       	push   $0x802604
  8004d3:	6a 27                	push   $0x27
  8004d5:	68 45 24 80 00       	push   $0x802445
  8004da:	e8 16 02 00 00       	call   8006f5 <_panic>
		panic("file_stat: %e", r);
  8004df:	50                   	push   %eax
  8004e0:	68 8a 24 80 00       	push   $0x80248a
  8004e5:	6a 2b                	push   $0x2b
  8004e7:	68 45 24 80 00       	push   $0x802445
  8004ec:	e8 04 02 00 00       	call   8006f5 <_panic>
		panic("file_stat returned size %d wanted %d\n", st.st_size, strlen(msg));
  8004f1:	83 ec 0c             	sub    $0xc,%esp
  8004f4:	ff 35 00 30 80 00    	pushl  0x803000
  8004fa:	e8 04 08 00 00       	call   800d03 <strlen>
  8004ff:	89 04 24             	mov    %eax,(%esp)
  800502:	ff 75 cc             	pushl  -0x34(%ebp)
  800505:	68 34 26 80 00       	push   $0x802634
  80050a:	6a 2d                	push   $0x2d
  80050c:	68 45 24 80 00       	push   $0x802445
  800511:	e8 df 01 00 00       	call   8006f5 <_panic>
		panic("file_read: %e", r);
  800516:	50                   	push   %eax
  800517:	68 ab 24 80 00       	push   $0x8024ab
  80051c:	6a 32                	push   $0x32
  80051e:	68 45 24 80 00       	push   $0x802445
  800523:	e8 cd 01 00 00       	call   8006f5 <_panic>
		panic("file_read returned wrong data");
  800528:	83 ec 04             	sub    $0x4,%esp
  80052b:	68 b9 24 80 00       	push   $0x8024b9
  800530:	6a 34                	push   $0x34
  800532:	68 45 24 80 00       	push   $0x802445
  800537:	e8 b9 01 00 00       	call   8006f5 <_panic>
		panic("file_close: %e", r);
  80053c:	50                   	push   %eax
  80053d:	68 ea 24 80 00       	push   $0x8024ea
  800542:	6a 38                	push   $0x38
  800544:	68 45 24 80 00       	push   $0x802445
  800549:	e8 a7 01 00 00       	call   8006f5 <_panic>
		panic("serve_read does not handle stale fileids correctly: %e", r);
  80054e:	50                   	push   %eax
  80054f:	68 5c 26 80 00       	push   $0x80265c
  800554:	6a 43                	push   $0x43
  800556:	68 45 24 80 00       	push   $0x802445
  80055b:	e8 95 01 00 00       	call   8006f5 <_panic>
		panic("serve_open /new-file: %e", r);
  800560:	50                   	push   %eax
  800561:	68 2d 25 80 00       	push   $0x80252d
  800566:	6a 48                	push   $0x48
  800568:	68 45 24 80 00       	push   $0x802445
  80056d:	e8 83 01 00 00       	call   8006f5 <_panic>
		panic("file_write: %e", r);
  800572:	53                   	push   %ebx
  800573:	68 46 25 80 00       	push   $0x802546
  800578:	6a 4b                	push   $0x4b
  80057a:	68 45 24 80 00       	push   $0x802445
  80057f:	e8 71 01 00 00       	call   8006f5 <_panic>
		panic("file_read after file_write: %e", r);
  800584:	50                   	push   %eax
  800585:	68 94 26 80 00       	push   $0x802694
  80058a:	6a 51                	push   $0x51
  80058c:	68 45 24 80 00       	push   $0x802445
  800591:	e8 5f 01 00 00       	call   8006f5 <_panic>
		panic("file_read after file_write returned wrong length: %d", r);
  800596:	53                   	push   %ebx
  800597:	68 b4 26 80 00       	push   $0x8026b4
  80059c:	6a 53                	push   $0x53
  80059e:	68 45 24 80 00       	push   $0x802445
  8005a3:	e8 4d 01 00 00       	call   8006f5 <_panic>
		panic("file_read after file_write returned wrong data");
  8005a8:	83 ec 04             	sub    $0x4,%esp
  8005ab:	68 ec 26 80 00       	push   $0x8026ec
  8005b0:	6a 55                	push   $0x55
  8005b2:	68 45 24 80 00       	push   $0x802445
  8005b7:	e8 39 01 00 00       	call   8006f5 <_panic>
		panic("open /not-found: %e", r);
  8005bc:	50                   	push   %eax
  8005bd:	68 31 24 80 00       	push   $0x802431
  8005c2:	6a 5a                	push   $0x5a
  8005c4:	68 45 24 80 00       	push   $0x802445
  8005c9:	e8 27 01 00 00       	call   8006f5 <_panic>
		panic("open /not-found succeeded!");
  8005ce:	83 ec 04             	sub    $0x4,%esp
  8005d1:	68 69 25 80 00       	push   $0x802569
  8005d6:	6a 5c                	push   $0x5c
  8005d8:	68 45 24 80 00       	push   $0x802445
  8005dd:	e8 13 01 00 00       	call   8006f5 <_panic>
		panic("open /newmotd: %e", r);
  8005e2:	50                   	push   %eax
  8005e3:	68 64 24 80 00       	push   $0x802464
  8005e8:	6a 5f                	push   $0x5f
  8005ea:	68 45 24 80 00       	push   $0x802445
  8005ef:	e8 01 01 00 00       	call   8006f5 <_panic>
		panic("open did not fill struct Fd correctly\n");
  8005f4:	83 ec 04             	sub    $0x4,%esp
  8005f7:	68 40 27 80 00       	push   $0x802740
  8005fc:	6a 62                	push   $0x62
  8005fe:	68 45 24 80 00       	push   $0x802445
  800603:	e8 ed 00 00 00       	call   8006f5 <_panic>
		panic("creat /big: %e", f);
  800608:	50                   	push   %eax
  800609:	68 89 25 80 00       	push   $0x802589
  80060e:	6a 67                	push   $0x67
  800610:	68 45 24 80 00       	push   $0x802445
  800615:	e8 db 00 00 00       	call   8006f5 <_panic>
			panic("write /big@%d: %e", i, r);
  80061a:	83 ec 0c             	sub    $0xc,%esp
  80061d:	50                   	push   %eax
  80061e:	56                   	push   %esi
  80061f:	68 98 25 80 00       	push   $0x802598
  800624:	6a 6c                	push   $0x6c
  800626:	68 45 24 80 00       	push   $0x802445
  80062b:	e8 c5 00 00 00       	call   8006f5 <_panic>
		panic("open /big: %e", f);
  800630:	50                   	push   %eax
  800631:	68 aa 25 80 00       	push   $0x8025aa
  800636:	6a 71                	push   $0x71
  800638:	68 45 24 80 00       	push   $0x802445
  80063d:	e8 b3 00 00 00       	call   8006f5 <_panic>
			panic("read /big@%d: %e", i, r);
  800642:	83 ec 0c             	sub    $0xc,%esp
  800645:	50                   	push   %eax
  800646:	53                   	push   %ebx
  800647:	68 b8 25 80 00       	push   $0x8025b8
  80064c:	6a 75                	push   $0x75
  80064e:	68 45 24 80 00       	push   $0x802445
  800653:	e8 9d 00 00 00       	call   8006f5 <_panic>
			panic("read /big from %d returned %d < %d bytes",
  800658:	83 ec 08             	sub    $0x8,%esp
  80065b:	68 00 02 00 00       	push   $0x200
  800660:	50                   	push   %eax
  800661:	53                   	push   %ebx
  800662:	68 68 27 80 00       	push   $0x802768
  800667:	6a 77                	push   $0x77
  800669:	68 45 24 80 00       	push   $0x802445
  80066e:	e8 82 00 00 00       	call   8006f5 <_panic>
			panic("read /big from %d returned bad data %d",
  800673:	83 ec 0c             	sub    $0xc,%esp
  800676:	50                   	push   %eax
  800677:	53                   	push   %ebx
  800678:	68 94 27 80 00       	push   $0x802794
  80067d:	6a 7a                	push   $0x7a
  80067f:	68 45 24 80 00       	push   $0x802445
  800684:	e8 6c 00 00 00       	call   8006f5 <_panic>

00800689 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800689:	f3 0f 1e fb          	endbr32 
  80068d:	55                   	push   %ebp
  80068e:	89 e5                	mov    %esp,%ebp
  800690:	56                   	push   %esi
  800691:	53                   	push   %ebx
  800692:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800695:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800698:	e8 de 0a 00 00       	call   80117b <sys_getenvid>
	if (id >= 0)
  80069d:	85 c0                	test   %eax,%eax
  80069f:	78 12                	js     8006b3 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  8006a1:	25 ff 03 00 00       	and    $0x3ff,%eax
  8006a6:	6b c0 7c             	imul   $0x7c,%eax,%eax
  8006a9:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  8006ae:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  8006b3:	85 db                	test   %ebx,%ebx
  8006b5:	7e 07                	jle    8006be <libmain+0x35>
		binaryname = argv[0];
  8006b7:	8b 06                	mov    (%esi),%eax
  8006b9:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  8006be:	83 ec 08             	sub    $0x8,%esp
  8006c1:	56                   	push   %esi
  8006c2:	53                   	push   %ebx
  8006c3:	e8 b6 f9 ff ff       	call   80007e <umain>

	// exit gracefully
	exit();
  8006c8:	e8 0a 00 00 00       	call   8006d7 <exit>
}
  8006cd:	83 c4 10             	add    $0x10,%esp
  8006d0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8006d3:	5b                   	pop    %ebx
  8006d4:	5e                   	pop    %esi
  8006d5:	5d                   	pop    %ebp
  8006d6:	c3                   	ret    

008006d7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8006d7:	f3 0f 1e fb          	endbr32 
  8006db:	55                   	push   %ebp
  8006dc:	89 e5                	mov    %esp,%ebp
  8006de:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8006e1:	e8 28 0f 00 00       	call   80160e <close_all>
	sys_env_destroy(0);
  8006e6:	83 ec 0c             	sub    $0xc,%esp
  8006e9:	6a 00                	push   $0x0
  8006eb:	e8 65 0a 00 00       	call   801155 <sys_env_destroy>
}
  8006f0:	83 c4 10             	add    $0x10,%esp
  8006f3:	c9                   	leave  
  8006f4:	c3                   	ret    

008006f5 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  8006f5:	f3 0f 1e fb          	endbr32 
  8006f9:	55                   	push   %ebp
  8006fa:	89 e5                	mov    %esp,%ebp
  8006fc:	56                   	push   %esi
  8006fd:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  8006fe:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800701:	8b 35 04 30 80 00    	mov    0x803004,%esi
  800707:	e8 6f 0a 00 00       	call   80117b <sys_getenvid>
  80070c:	83 ec 0c             	sub    $0xc,%esp
  80070f:	ff 75 0c             	pushl  0xc(%ebp)
  800712:	ff 75 08             	pushl  0x8(%ebp)
  800715:	56                   	push   %esi
  800716:	50                   	push   %eax
  800717:	68 ec 27 80 00       	push   $0x8027ec
  80071c:	e8 bb 00 00 00       	call   8007dc <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800721:	83 c4 18             	add    $0x18,%esp
  800724:	53                   	push   %ebx
  800725:	ff 75 10             	pushl  0x10(%ebp)
  800728:	e8 5a 00 00 00       	call   800787 <vcprintf>
	cprintf("\n");
  80072d:	c7 04 24 3b 2c 80 00 	movl   $0x802c3b,(%esp)
  800734:	e8 a3 00 00 00       	call   8007dc <cprintf>
  800739:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80073c:	cc                   	int3   
  80073d:	eb fd                	jmp    80073c <_panic+0x47>

0080073f <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80073f:	f3 0f 1e fb          	endbr32 
  800743:	55                   	push   %ebp
  800744:	89 e5                	mov    %esp,%ebp
  800746:	53                   	push   %ebx
  800747:	83 ec 04             	sub    $0x4,%esp
  80074a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80074d:	8b 13                	mov    (%ebx),%edx
  80074f:	8d 42 01             	lea    0x1(%edx),%eax
  800752:	89 03                	mov    %eax,(%ebx)
  800754:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800757:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80075b:	3d ff 00 00 00       	cmp    $0xff,%eax
  800760:	74 09                	je     80076b <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  800762:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800766:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800769:	c9                   	leave  
  80076a:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  80076b:	83 ec 08             	sub    $0x8,%esp
  80076e:	68 ff 00 00 00       	push   $0xff
  800773:	8d 43 08             	lea    0x8(%ebx),%eax
  800776:	50                   	push   %eax
  800777:	e8 87 09 00 00       	call   801103 <sys_cputs>
		b->idx = 0;
  80077c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  800782:	83 c4 10             	add    $0x10,%esp
  800785:	eb db                	jmp    800762 <putch+0x23>

00800787 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800787:	f3 0f 1e fb          	endbr32 
  80078b:	55                   	push   %ebp
  80078c:	89 e5                	mov    %esp,%ebp
  80078e:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  800794:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  80079b:	00 00 00 
	b.cnt = 0;
  80079e:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8007a5:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8007a8:	ff 75 0c             	pushl  0xc(%ebp)
  8007ab:	ff 75 08             	pushl  0x8(%ebp)
  8007ae:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8007b4:	50                   	push   %eax
  8007b5:	68 3f 07 80 00       	push   $0x80073f
  8007ba:	e8 80 01 00 00       	call   80093f <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8007bf:	83 c4 08             	add    $0x8,%esp
  8007c2:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8007c8:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8007ce:	50                   	push   %eax
  8007cf:	e8 2f 09 00 00       	call   801103 <sys_cputs>

	return b.cnt;
}
  8007d4:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8007da:	c9                   	leave  
  8007db:	c3                   	ret    

008007dc <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8007dc:	f3 0f 1e fb          	endbr32 
  8007e0:	55                   	push   %ebp
  8007e1:	89 e5                	mov    %esp,%ebp
  8007e3:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8007e6:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8007e9:	50                   	push   %eax
  8007ea:	ff 75 08             	pushl  0x8(%ebp)
  8007ed:	e8 95 ff ff ff       	call   800787 <vcprintf>
	va_end(ap);

	return cnt;
}
  8007f2:	c9                   	leave  
  8007f3:	c3                   	ret    

008007f4 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8007f4:	55                   	push   %ebp
  8007f5:	89 e5                	mov    %esp,%ebp
  8007f7:	57                   	push   %edi
  8007f8:	56                   	push   %esi
  8007f9:	53                   	push   %ebx
  8007fa:	83 ec 1c             	sub    $0x1c,%esp
  8007fd:	89 c7                	mov    %eax,%edi
  8007ff:	89 d6                	mov    %edx,%esi
  800801:	8b 45 08             	mov    0x8(%ebp),%eax
  800804:	8b 55 0c             	mov    0xc(%ebp),%edx
  800807:	89 d1                	mov    %edx,%ecx
  800809:	89 c2                	mov    %eax,%edx
  80080b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80080e:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  800811:	8b 45 10             	mov    0x10(%ebp),%eax
  800814:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800817:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80081a:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  800821:	39 c2                	cmp    %eax,%edx
  800823:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  800826:	72 3e                	jb     800866 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  800828:	83 ec 0c             	sub    $0xc,%esp
  80082b:	ff 75 18             	pushl  0x18(%ebp)
  80082e:	83 eb 01             	sub    $0x1,%ebx
  800831:	53                   	push   %ebx
  800832:	50                   	push   %eax
  800833:	83 ec 08             	sub    $0x8,%esp
  800836:	ff 75 e4             	pushl  -0x1c(%ebp)
  800839:	ff 75 e0             	pushl  -0x20(%ebp)
  80083c:	ff 75 dc             	pushl  -0x24(%ebp)
  80083f:	ff 75 d8             	pushl  -0x28(%ebp)
  800842:	e8 69 19 00 00       	call   8021b0 <__udivdi3>
  800847:	83 c4 18             	add    $0x18,%esp
  80084a:	52                   	push   %edx
  80084b:	50                   	push   %eax
  80084c:	89 f2                	mov    %esi,%edx
  80084e:	89 f8                	mov    %edi,%eax
  800850:	e8 9f ff ff ff       	call   8007f4 <printnum>
  800855:	83 c4 20             	add    $0x20,%esp
  800858:	eb 13                	jmp    80086d <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80085a:	83 ec 08             	sub    $0x8,%esp
  80085d:	56                   	push   %esi
  80085e:	ff 75 18             	pushl  0x18(%ebp)
  800861:	ff d7                	call   *%edi
  800863:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  800866:	83 eb 01             	sub    $0x1,%ebx
  800869:	85 db                	test   %ebx,%ebx
  80086b:	7f ed                	jg     80085a <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80086d:	83 ec 08             	sub    $0x8,%esp
  800870:	56                   	push   %esi
  800871:	83 ec 04             	sub    $0x4,%esp
  800874:	ff 75 e4             	pushl  -0x1c(%ebp)
  800877:	ff 75 e0             	pushl  -0x20(%ebp)
  80087a:	ff 75 dc             	pushl  -0x24(%ebp)
  80087d:	ff 75 d8             	pushl  -0x28(%ebp)
  800880:	e8 3b 1a 00 00       	call   8022c0 <__umoddi3>
  800885:	83 c4 14             	add    $0x14,%esp
  800888:	0f be 80 0f 28 80 00 	movsbl 0x80280f(%eax),%eax
  80088f:	50                   	push   %eax
  800890:	ff d7                	call   *%edi
}
  800892:	83 c4 10             	add    $0x10,%esp
  800895:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800898:	5b                   	pop    %ebx
  800899:	5e                   	pop    %esi
  80089a:	5f                   	pop    %edi
  80089b:	5d                   	pop    %ebp
  80089c:	c3                   	ret    

0080089d <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80089d:	83 fa 01             	cmp    $0x1,%edx
  8008a0:	7f 13                	jg     8008b5 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8008a2:	85 d2                	test   %edx,%edx
  8008a4:	74 1c                	je     8008c2 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8008a6:	8b 10                	mov    (%eax),%edx
  8008a8:	8d 4a 04             	lea    0x4(%edx),%ecx
  8008ab:	89 08                	mov    %ecx,(%eax)
  8008ad:	8b 02                	mov    (%edx),%eax
  8008af:	ba 00 00 00 00       	mov    $0x0,%edx
  8008b4:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  8008b5:	8b 10                	mov    (%eax),%edx
  8008b7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8008ba:	89 08                	mov    %ecx,(%eax)
  8008bc:	8b 02                	mov    (%edx),%eax
  8008be:	8b 52 04             	mov    0x4(%edx),%edx
  8008c1:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  8008c2:	8b 10                	mov    (%eax),%edx
  8008c4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8008c7:	89 08                	mov    %ecx,(%eax)
  8008c9:	8b 02                	mov    (%edx),%eax
  8008cb:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8008d0:	c3                   	ret    

008008d1 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8008d1:	83 fa 01             	cmp    $0x1,%edx
  8008d4:	7f 0f                	jg     8008e5 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  8008d6:	85 d2                	test   %edx,%edx
  8008d8:	74 18                	je     8008f2 <getint+0x21>
		return va_arg(*ap, long);
  8008da:	8b 10                	mov    (%eax),%edx
  8008dc:	8d 4a 04             	lea    0x4(%edx),%ecx
  8008df:	89 08                	mov    %ecx,(%eax)
  8008e1:	8b 02                	mov    (%edx),%eax
  8008e3:	99                   	cltd   
  8008e4:	c3                   	ret    
		return va_arg(*ap, long long);
  8008e5:	8b 10                	mov    (%eax),%edx
  8008e7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8008ea:	89 08                	mov    %ecx,(%eax)
  8008ec:	8b 02                	mov    (%edx),%eax
  8008ee:	8b 52 04             	mov    0x4(%edx),%edx
  8008f1:	c3                   	ret    
	else
		return va_arg(*ap, int);
  8008f2:	8b 10                	mov    (%eax),%edx
  8008f4:	8d 4a 04             	lea    0x4(%edx),%ecx
  8008f7:	89 08                	mov    %ecx,(%eax)
  8008f9:	8b 02                	mov    (%edx),%eax
  8008fb:	99                   	cltd   
}
  8008fc:	c3                   	ret    

008008fd <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8008fd:	f3 0f 1e fb          	endbr32 
  800901:	55                   	push   %ebp
  800902:	89 e5                	mov    %esp,%ebp
  800904:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  800907:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80090b:	8b 10                	mov    (%eax),%edx
  80090d:	3b 50 04             	cmp    0x4(%eax),%edx
  800910:	73 0a                	jae    80091c <sprintputch+0x1f>
		*b->buf++ = ch;
  800912:	8d 4a 01             	lea    0x1(%edx),%ecx
  800915:	89 08                	mov    %ecx,(%eax)
  800917:	8b 45 08             	mov    0x8(%ebp),%eax
  80091a:	88 02                	mov    %al,(%edx)
}
  80091c:	5d                   	pop    %ebp
  80091d:	c3                   	ret    

0080091e <printfmt>:
{
  80091e:	f3 0f 1e fb          	endbr32 
  800922:	55                   	push   %ebp
  800923:	89 e5                	mov    %esp,%ebp
  800925:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  800928:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80092b:	50                   	push   %eax
  80092c:	ff 75 10             	pushl  0x10(%ebp)
  80092f:	ff 75 0c             	pushl  0xc(%ebp)
  800932:	ff 75 08             	pushl  0x8(%ebp)
  800935:	e8 05 00 00 00       	call   80093f <vprintfmt>
}
  80093a:	83 c4 10             	add    $0x10,%esp
  80093d:	c9                   	leave  
  80093e:	c3                   	ret    

0080093f <vprintfmt>:
{
  80093f:	f3 0f 1e fb          	endbr32 
  800943:	55                   	push   %ebp
  800944:	89 e5                	mov    %esp,%ebp
  800946:	57                   	push   %edi
  800947:	56                   	push   %esi
  800948:	53                   	push   %ebx
  800949:	83 ec 2c             	sub    $0x2c,%esp
  80094c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80094f:	8b 75 0c             	mov    0xc(%ebp),%esi
  800952:	8b 7d 10             	mov    0x10(%ebp),%edi
  800955:	e9 86 02 00 00       	jmp    800be0 <vprintfmt+0x2a1>
		padc = ' ';
  80095a:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  80095e:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  800965:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  80096c:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  800973:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800978:	8d 47 01             	lea    0x1(%edi),%eax
  80097b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80097e:	0f b6 17             	movzbl (%edi),%edx
  800981:	8d 42 dd             	lea    -0x23(%edx),%eax
  800984:	3c 55                	cmp    $0x55,%al
  800986:	0f 87 df 02 00 00    	ja     800c6b <vprintfmt+0x32c>
  80098c:	0f b6 c0             	movzbl %al,%eax
  80098f:	3e ff 24 85 60 29 80 	notrack jmp *0x802960(,%eax,4)
  800996:	00 
  800997:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  80099a:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  80099e:	eb d8                	jmp    800978 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8009a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8009a3:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8009a7:	eb cf                	jmp    800978 <vprintfmt+0x39>
  8009a9:	0f b6 d2             	movzbl %dl,%edx
  8009ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8009af:	b8 00 00 00 00       	mov    $0x0,%eax
  8009b4:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  8009b7:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8009ba:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  8009be:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  8009c1:	8d 4a d0             	lea    -0x30(%edx),%ecx
  8009c4:	83 f9 09             	cmp    $0x9,%ecx
  8009c7:	77 52                	ja     800a1b <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  8009c9:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  8009cc:	eb e9                	jmp    8009b7 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  8009ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8009d1:	8d 50 04             	lea    0x4(%eax),%edx
  8009d4:	89 55 14             	mov    %edx,0x14(%ebp)
  8009d7:	8b 00                	mov    (%eax),%eax
  8009d9:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  8009dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  8009df:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8009e3:	79 93                	jns    800978 <vprintfmt+0x39>
				width = precision, precision = -1;
  8009e5:	8b 45 d8             	mov    -0x28(%ebp),%eax
  8009e8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8009eb:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  8009f2:	eb 84                	jmp    800978 <vprintfmt+0x39>
  8009f4:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8009f7:	85 c0                	test   %eax,%eax
  8009f9:	ba 00 00 00 00       	mov    $0x0,%edx
  8009fe:	0f 49 d0             	cmovns %eax,%edx
  800a01:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  800a04:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800a07:	e9 6c ff ff ff       	jmp    800978 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  800a0c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  800a0f:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  800a16:	e9 5d ff ff ff       	jmp    800978 <vprintfmt+0x39>
  800a1b:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800a1e:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  800a21:	eb bc                	jmp    8009df <vprintfmt+0xa0>
			lflag++;
  800a23:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  800a26:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  800a29:	e9 4a ff ff ff       	jmp    800978 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  800a2e:	8b 45 14             	mov    0x14(%ebp),%eax
  800a31:	8d 50 04             	lea    0x4(%eax),%edx
  800a34:	89 55 14             	mov    %edx,0x14(%ebp)
  800a37:	83 ec 08             	sub    $0x8,%esp
  800a3a:	56                   	push   %esi
  800a3b:	ff 30                	pushl  (%eax)
  800a3d:	ff d3                	call   *%ebx
			break;
  800a3f:	83 c4 10             	add    $0x10,%esp
  800a42:	e9 96 01 00 00       	jmp    800bdd <vprintfmt+0x29e>
			err = va_arg(ap, int);
  800a47:	8b 45 14             	mov    0x14(%ebp),%eax
  800a4a:	8d 50 04             	lea    0x4(%eax),%edx
  800a4d:	89 55 14             	mov    %edx,0x14(%ebp)
  800a50:	8b 00                	mov    (%eax),%eax
  800a52:	99                   	cltd   
  800a53:	31 d0                	xor    %edx,%eax
  800a55:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800a57:	83 f8 0f             	cmp    $0xf,%eax
  800a5a:	7f 20                	jg     800a7c <vprintfmt+0x13d>
  800a5c:	8b 14 85 c0 2a 80 00 	mov    0x802ac0(,%eax,4),%edx
  800a63:	85 d2                	test   %edx,%edx
  800a65:	74 15                	je     800a7c <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  800a67:	52                   	push   %edx
  800a68:	68 09 2c 80 00       	push   $0x802c09
  800a6d:	56                   	push   %esi
  800a6e:	53                   	push   %ebx
  800a6f:	e8 aa fe ff ff       	call   80091e <printfmt>
  800a74:	83 c4 10             	add    $0x10,%esp
  800a77:	e9 61 01 00 00       	jmp    800bdd <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  800a7c:	50                   	push   %eax
  800a7d:	68 27 28 80 00       	push   $0x802827
  800a82:	56                   	push   %esi
  800a83:	53                   	push   %ebx
  800a84:	e8 95 fe ff ff       	call   80091e <printfmt>
  800a89:	83 c4 10             	add    $0x10,%esp
  800a8c:	e9 4c 01 00 00       	jmp    800bdd <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  800a91:	8b 45 14             	mov    0x14(%ebp),%eax
  800a94:	8d 50 04             	lea    0x4(%eax),%edx
  800a97:	89 55 14             	mov    %edx,0x14(%ebp)
  800a9a:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  800a9c:	85 c9                	test   %ecx,%ecx
  800a9e:	b8 20 28 80 00       	mov    $0x802820,%eax
  800aa3:	0f 45 c1             	cmovne %ecx,%eax
  800aa6:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  800aa9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800aad:	7e 06                	jle    800ab5 <vprintfmt+0x176>
  800aaf:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  800ab3:	75 0d                	jne    800ac2 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  800ab5:	8b 45 cc             	mov    -0x34(%ebp),%eax
  800ab8:	89 c7                	mov    %eax,%edi
  800aba:	03 45 e0             	add    -0x20(%ebp),%eax
  800abd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800ac0:	eb 57                	jmp    800b19 <vprintfmt+0x1da>
  800ac2:	83 ec 08             	sub    $0x8,%esp
  800ac5:	ff 75 d8             	pushl  -0x28(%ebp)
  800ac8:	ff 75 cc             	pushl  -0x34(%ebp)
  800acb:	e8 4f 02 00 00       	call   800d1f <strnlen>
  800ad0:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800ad3:	29 c2                	sub    %eax,%edx
  800ad5:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800ad8:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  800adb:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800adf:	89 5d 08             	mov    %ebx,0x8(%ebp)
  800ae2:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  800ae4:	85 db                	test   %ebx,%ebx
  800ae6:	7e 10                	jle    800af8 <vprintfmt+0x1b9>
					putch(padc, putdat);
  800ae8:	83 ec 08             	sub    $0x8,%esp
  800aeb:	56                   	push   %esi
  800aec:	57                   	push   %edi
  800aed:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  800af0:	83 eb 01             	sub    $0x1,%ebx
  800af3:	83 c4 10             	add    $0x10,%esp
  800af6:	eb ec                	jmp    800ae4 <vprintfmt+0x1a5>
  800af8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800afb:	8b 55 e0             	mov    -0x20(%ebp),%edx
  800afe:	85 d2                	test   %edx,%edx
  800b00:	b8 00 00 00 00       	mov    $0x0,%eax
  800b05:	0f 49 c2             	cmovns %edx,%eax
  800b08:	29 c2                	sub    %eax,%edx
  800b0a:	89 55 e0             	mov    %edx,-0x20(%ebp)
  800b0d:	eb a6                	jmp    800ab5 <vprintfmt+0x176>
					putch(ch, putdat);
  800b0f:	83 ec 08             	sub    $0x8,%esp
  800b12:	56                   	push   %esi
  800b13:	52                   	push   %edx
  800b14:	ff d3                	call   *%ebx
  800b16:	83 c4 10             	add    $0x10,%esp
  800b19:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  800b1c:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800b1e:	83 c7 01             	add    $0x1,%edi
  800b21:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800b25:	0f be d0             	movsbl %al,%edx
  800b28:	85 d2                	test   %edx,%edx
  800b2a:	74 42                	je     800b6e <vprintfmt+0x22f>
  800b2c:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800b30:	78 06                	js     800b38 <vprintfmt+0x1f9>
  800b32:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  800b36:	78 1e                	js     800b56 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  800b38:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  800b3c:	74 d1                	je     800b0f <vprintfmt+0x1d0>
  800b3e:	0f be c0             	movsbl %al,%eax
  800b41:	83 e8 20             	sub    $0x20,%eax
  800b44:	83 f8 5e             	cmp    $0x5e,%eax
  800b47:	76 c6                	jbe    800b0f <vprintfmt+0x1d0>
					putch('?', putdat);
  800b49:	83 ec 08             	sub    $0x8,%esp
  800b4c:	56                   	push   %esi
  800b4d:	6a 3f                	push   $0x3f
  800b4f:	ff d3                	call   *%ebx
  800b51:	83 c4 10             	add    $0x10,%esp
  800b54:	eb c3                	jmp    800b19 <vprintfmt+0x1da>
  800b56:	89 cf                	mov    %ecx,%edi
  800b58:	eb 0e                	jmp    800b68 <vprintfmt+0x229>
				putch(' ', putdat);
  800b5a:	83 ec 08             	sub    $0x8,%esp
  800b5d:	56                   	push   %esi
  800b5e:	6a 20                	push   $0x20
  800b60:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  800b62:	83 ef 01             	sub    $0x1,%edi
  800b65:	83 c4 10             	add    $0x10,%esp
  800b68:	85 ff                	test   %edi,%edi
  800b6a:	7f ee                	jg     800b5a <vprintfmt+0x21b>
  800b6c:	eb 6f                	jmp    800bdd <vprintfmt+0x29e>
  800b6e:	89 cf                	mov    %ecx,%edi
  800b70:	eb f6                	jmp    800b68 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  800b72:	89 ca                	mov    %ecx,%edx
  800b74:	8d 45 14             	lea    0x14(%ebp),%eax
  800b77:	e8 55 fd ff ff       	call   8008d1 <getint>
  800b7c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800b7f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  800b82:	85 d2                	test   %edx,%edx
  800b84:	78 0b                	js     800b91 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  800b86:	89 d1                	mov    %edx,%ecx
  800b88:	89 c2                	mov    %eax,%edx
			base = 10;
  800b8a:	b8 0a 00 00 00       	mov    $0xa,%eax
  800b8f:	eb 32                	jmp    800bc3 <vprintfmt+0x284>
				putch('-', putdat);
  800b91:	83 ec 08             	sub    $0x8,%esp
  800b94:	56                   	push   %esi
  800b95:	6a 2d                	push   $0x2d
  800b97:	ff d3                	call   *%ebx
				num = -(long long) num;
  800b99:	8b 55 d8             	mov    -0x28(%ebp),%edx
  800b9c:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  800b9f:	f7 da                	neg    %edx
  800ba1:	83 d1 00             	adc    $0x0,%ecx
  800ba4:	f7 d9                	neg    %ecx
  800ba6:	83 c4 10             	add    $0x10,%esp
			base = 10;
  800ba9:	b8 0a 00 00 00       	mov    $0xa,%eax
  800bae:	eb 13                	jmp    800bc3 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800bb0:	89 ca                	mov    %ecx,%edx
  800bb2:	8d 45 14             	lea    0x14(%ebp),%eax
  800bb5:	e8 e3 fc ff ff       	call   80089d <getuint>
  800bba:	89 d1                	mov    %edx,%ecx
  800bbc:	89 c2                	mov    %eax,%edx
			base = 10;
  800bbe:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  800bc3:	83 ec 0c             	sub    $0xc,%esp
  800bc6:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  800bca:	57                   	push   %edi
  800bcb:	ff 75 e0             	pushl  -0x20(%ebp)
  800bce:	50                   	push   %eax
  800bcf:	51                   	push   %ecx
  800bd0:	52                   	push   %edx
  800bd1:	89 f2                	mov    %esi,%edx
  800bd3:	89 d8                	mov    %ebx,%eax
  800bd5:	e8 1a fc ff ff       	call   8007f4 <printnum>
			break;
  800bda:	83 c4 20             	add    $0x20,%esp
{
  800bdd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800be0:	83 c7 01             	add    $0x1,%edi
  800be3:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800be7:	83 f8 25             	cmp    $0x25,%eax
  800bea:	0f 84 6a fd ff ff    	je     80095a <vprintfmt+0x1b>
			if (ch == '\0')
  800bf0:	85 c0                	test   %eax,%eax
  800bf2:	0f 84 93 00 00 00    	je     800c8b <vprintfmt+0x34c>
			putch(ch, putdat);
  800bf8:	83 ec 08             	sub    $0x8,%esp
  800bfb:	56                   	push   %esi
  800bfc:	50                   	push   %eax
  800bfd:	ff d3                	call   *%ebx
  800bff:	83 c4 10             	add    $0x10,%esp
  800c02:	eb dc                	jmp    800be0 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  800c04:	89 ca                	mov    %ecx,%edx
  800c06:	8d 45 14             	lea    0x14(%ebp),%eax
  800c09:	e8 8f fc ff ff       	call   80089d <getuint>
  800c0e:	89 d1                	mov    %edx,%ecx
  800c10:	89 c2                	mov    %eax,%edx
			base = 8;
  800c12:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  800c17:	eb aa                	jmp    800bc3 <vprintfmt+0x284>
			putch('0', putdat);
  800c19:	83 ec 08             	sub    $0x8,%esp
  800c1c:	56                   	push   %esi
  800c1d:	6a 30                	push   $0x30
  800c1f:	ff d3                	call   *%ebx
			putch('x', putdat);
  800c21:	83 c4 08             	add    $0x8,%esp
  800c24:	56                   	push   %esi
  800c25:	6a 78                	push   $0x78
  800c27:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  800c29:	8b 45 14             	mov    0x14(%ebp),%eax
  800c2c:	8d 50 04             	lea    0x4(%eax),%edx
  800c2f:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  800c32:	8b 10                	mov    (%eax),%edx
  800c34:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  800c39:	83 c4 10             	add    $0x10,%esp
			base = 16;
  800c3c:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800c41:	eb 80                	jmp    800bc3 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  800c43:	89 ca                	mov    %ecx,%edx
  800c45:	8d 45 14             	lea    0x14(%ebp),%eax
  800c48:	e8 50 fc ff ff       	call   80089d <getuint>
  800c4d:	89 d1                	mov    %edx,%ecx
  800c4f:	89 c2                	mov    %eax,%edx
			base = 16;
  800c51:	b8 10 00 00 00       	mov    $0x10,%eax
  800c56:	e9 68 ff ff ff       	jmp    800bc3 <vprintfmt+0x284>
			putch(ch, putdat);
  800c5b:	83 ec 08             	sub    $0x8,%esp
  800c5e:	56                   	push   %esi
  800c5f:	6a 25                	push   $0x25
  800c61:	ff d3                	call   *%ebx
			break;
  800c63:	83 c4 10             	add    $0x10,%esp
  800c66:	e9 72 ff ff ff       	jmp    800bdd <vprintfmt+0x29e>
			putch('%', putdat);
  800c6b:	83 ec 08             	sub    $0x8,%esp
  800c6e:	56                   	push   %esi
  800c6f:	6a 25                	push   $0x25
  800c71:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  800c73:	83 c4 10             	add    $0x10,%esp
  800c76:	89 f8                	mov    %edi,%eax
  800c78:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  800c7c:	74 05                	je     800c83 <vprintfmt+0x344>
  800c7e:	83 e8 01             	sub    $0x1,%eax
  800c81:	eb f5                	jmp    800c78 <vprintfmt+0x339>
  800c83:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c86:	e9 52 ff ff ff       	jmp    800bdd <vprintfmt+0x29e>
}
  800c8b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c8e:	5b                   	pop    %ebx
  800c8f:	5e                   	pop    %esi
  800c90:	5f                   	pop    %edi
  800c91:	5d                   	pop    %ebp
  800c92:	c3                   	ret    

00800c93 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800c93:	f3 0f 1e fb          	endbr32 
  800c97:	55                   	push   %ebp
  800c98:	89 e5                	mov    %esp,%ebp
  800c9a:	83 ec 18             	sub    $0x18,%esp
  800c9d:	8b 45 08             	mov    0x8(%ebp),%eax
  800ca0:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800ca3:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800ca6:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  800caa:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  800cad:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800cb4:	85 c0                	test   %eax,%eax
  800cb6:	74 26                	je     800cde <vsnprintf+0x4b>
  800cb8:	85 d2                	test   %edx,%edx
  800cba:	7e 22                	jle    800cde <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  800cbc:	ff 75 14             	pushl  0x14(%ebp)
  800cbf:	ff 75 10             	pushl  0x10(%ebp)
  800cc2:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800cc5:	50                   	push   %eax
  800cc6:	68 fd 08 80 00       	push   $0x8008fd
  800ccb:	e8 6f fc ff ff       	call   80093f <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800cd0:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800cd3:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800cd6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800cd9:	83 c4 10             	add    $0x10,%esp
}
  800cdc:	c9                   	leave  
  800cdd:	c3                   	ret    
		return -E_INVAL;
  800cde:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800ce3:	eb f7                	jmp    800cdc <vsnprintf+0x49>

00800ce5 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800ce5:	f3 0f 1e fb          	endbr32 
  800ce9:	55                   	push   %ebp
  800cea:	89 e5                	mov    %esp,%ebp
  800cec:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  800cef:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  800cf2:	50                   	push   %eax
  800cf3:	ff 75 10             	pushl  0x10(%ebp)
  800cf6:	ff 75 0c             	pushl  0xc(%ebp)
  800cf9:	ff 75 08             	pushl  0x8(%ebp)
  800cfc:	e8 92 ff ff ff       	call   800c93 <vsnprintf>
	va_end(ap);

	return rc;
}
  800d01:	c9                   	leave  
  800d02:	c3                   	ret    

00800d03 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800d03:	f3 0f 1e fb          	endbr32 
  800d07:	55                   	push   %ebp
  800d08:	89 e5                	mov    %esp,%ebp
  800d0a:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800d0d:	b8 00 00 00 00       	mov    $0x0,%eax
  800d12:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800d16:	74 05                	je     800d1d <strlen+0x1a>
		n++;
  800d18:	83 c0 01             	add    $0x1,%eax
  800d1b:	eb f5                	jmp    800d12 <strlen+0xf>
	return n;
}
  800d1d:	5d                   	pop    %ebp
  800d1e:	c3                   	ret    

00800d1f <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800d1f:	f3 0f 1e fb          	endbr32 
  800d23:	55                   	push   %ebp
  800d24:	89 e5                	mov    %esp,%ebp
  800d26:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d29:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800d2c:	b8 00 00 00 00       	mov    $0x0,%eax
  800d31:	39 d0                	cmp    %edx,%eax
  800d33:	74 0d                	je     800d42 <strnlen+0x23>
  800d35:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  800d39:	74 05                	je     800d40 <strnlen+0x21>
		n++;
  800d3b:	83 c0 01             	add    $0x1,%eax
  800d3e:	eb f1                	jmp    800d31 <strnlen+0x12>
  800d40:	89 c2                	mov    %eax,%edx
	return n;
}
  800d42:	89 d0                	mov    %edx,%eax
  800d44:	5d                   	pop    %ebp
  800d45:	c3                   	ret    

00800d46 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  800d46:	f3 0f 1e fb          	endbr32 
  800d4a:	55                   	push   %ebp
  800d4b:	89 e5                	mov    %esp,%ebp
  800d4d:	53                   	push   %ebx
  800d4e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800d51:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  800d54:	b8 00 00 00 00       	mov    $0x0,%eax
  800d59:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  800d5d:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  800d60:	83 c0 01             	add    $0x1,%eax
  800d63:	84 d2                	test   %dl,%dl
  800d65:	75 f2                	jne    800d59 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  800d67:	89 c8                	mov    %ecx,%eax
  800d69:	5b                   	pop    %ebx
  800d6a:	5d                   	pop    %ebp
  800d6b:	c3                   	ret    

00800d6c <strcat>:

char *
strcat(char *dst, const char *src)
{
  800d6c:	f3 0f 1e fb          	endbr32 
  800d70:	55                   	push   %ebp
  800d71:	89 e5                	mov    %esp,%ebp
  800d73:	53                   	push   %ebx
  800d74:	83 ec 10             	sub    $0x10,%esp
  800d77:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  800d7a:	53                   	push   %ebx
  800d7b:	e8 83 ff ff ff       	call   800d03 <strlen>
  800d80:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  800d83:	ff 75 0c             	pushl  0xc(%ebp)
  800d86:	01 d8                	add    %ebx,%eax
  800d88:	50                   	push   %eax
  800d89:	e8 b8 ff ff ff       	call   800d46 <strcpy>
	return dst;
}
  800d8e:	89 d8                	mov    %ebx,%eax
  800d90:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800d93:	c9                   	leave  
  800d94:	c3                   	ret    

00800d95 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  800d95:	f3 0f 1e fb          	endbr32 
  800d99:	55                   	push   %ebp
  800d9a:	89 e5                	mov    %esp,%ebp
  800d9c:	56                   	push   %esi
  800d9d:	53                   	push   %ebx
  800d9e:	8b 75 08             	mov    0x8(%ebp),%esi
  800da1:	8b 55 0c             	mov    0xc(%ebp),%edx
  800da4:	89 f3                	mov    %esi,%ebx
  800da6:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800da9:	89 f0                	mov    %esi,%eax
  800dab:	39 d8                	cmp    %ebx,%eax
  800dad:	74 11                	je     800dc0 <strncpy+0x2b>
		*dst++ = *src;
  800daf:	83 c0 01             	add    $0x1,%eax
  800db2:	0f b6 0a             	movzbl (%edx),%ecx
  800db5:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800db8:	80 f9 01             	cmp    $0x1,%cl
  800dbb:	83 da ff             	sbb    $0xffffffff,%edx
  800dbe:	eb eb                	jmp    800dab <strncpy+0x16>
	}
	return ret;
}
  800dc0:	89 f0                	mov    %esi,%eax
  800dc2:	5b                   	pop    %ebx
  800dc3:	5e                   	pop    %esi
  800dc4:	5d                   	pop    %ebp
  800dc5:	c3                   	ret    

00800dc6 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800dc6:	f3 0f 1e fb          	endbr32 
  800dca:	55                   	push   %ebp
  800dcb:	89 e5                	mov    %esp,%ebp
  800dcd:	56                   	push   %esi
  800dce:	53                   	push   %ebx
  800dcf:	8b 75 08             	mov    0x8(%ebp),%esi
  800dd2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800dd5:	8b 55 10             	mov    0x10(%ebp),%edx
  800dd8:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800dda:	85 d2                	test   %edx,%edx
  800ddc:	74 21                	je     800dff <strlcpy+0x39>
  800dde:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800de2:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  800de4:	39 c2                	cmp    %eax,%edx
  800de6:	74 14                	je     800dfc <strlcpy+0x36>
  800de8:	0f b6 19             	movzbl (%ecx),%ebx
  800deb:	84 db                	test   %bl,%bl
  800ded:	74 0b                	je     800dfa <strlcpy+0x34>
			*dst++ = *src++;
  800def:	83 c1 01             	add    $0x1,%ecx
  800df2:	83 c2 01             	add    $0x1,%edx
  800df5:	88 5a ff             	mov    %bl,-0x1(%edx)
  800df8:	eb ea                	jmp    800de4 <strlcpy+0x1e>
  800dfa:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  800dfc:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800dff:	29 f0                	sub    %esi,%eax
}
  800e01:	5b                   	pop    %ebx
  800e02:	5e                   	pop    %esi
  800e03:	5d                   	pop    %ebp
  800e04:	c3                   	ret    

00800e05 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800e05:	f3 0f 1e fb          	endbr32 
  800e09:	55                   	push   %ebp
  800e0a:	89 e5                	mov    %esp,%ebp
  800e0c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e0f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800e12:	0f b6 01             	movzbl (%ecx),%eax
  800e15:	84 c0                	test   %al,%al
  800e17:	74 0c                	je     800e25 <strcmp+0x20>
  800e19:	3a 02                	cmp    (%edx),%al
  800e1b:	75 08                	jne    800e25 <strcmp+0x20>
		p++, q++;
  800e1d:	83 c1 01             	add    $0x1,%ecx
  800e20:	83 c2 01             	add    $0x1,%edx
  800e23:	eb ed                	jmp    800e12 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800e25:	0f b6 c0             	movzbl %al,%eax
  800e28:	0f b6 12             	movzbl (%edx),%edx
  800e2b:	29 d0                	sub    %edx,%eax
}
  800e2d:	5d                   	pop    %ebp
  800e2e:	c3                   	ret    

00800e2f <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800e2f:	f3 0f 1e fb          	endbr32 
  800e33:	55                   	push   %ebp
  800e34:	89 e5                	mov    %esp,%ebp
  800e36:	53                   	push   %ebx
  800e37:	8b 45 08             	mov    0x8(%ebp),%eax
  800e3a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800e3d:	89 c3                	mov    %eax,%ebx
  800e3f:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800e42:	eb 06                	jmp    800e4a <strncmp+0x1b>
		n--, p++, q++;
  800e44:	83 c0 01             	add    $0x1,%eax
  800e47:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  800e4a:	39 d8                	cmp    %ebx,%eax
  800e4c:	74 16                	je     800e64 <strncmp+0x35>
  800e4e:	0f b6 08             	movzbl (%eax),%ecx
  800e51:	84 c9                	test   %cl,%cl
  800e53:	74 04                	je     800e59 <strncmp+0x2a>
  800e55:	3a 0a                	cmp    (%edx),%cl
  800e57:	74 eb                	je     800e44 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800e59:	0f b6 00             	movzbl (%eax),%eax
  800e5c:	0f b6 12             	movzbl (%edx),%edx
  800e5f:	29 d0                	sub    %edx,%eax
}
  800e61:	5b                   	pop    %ebx
  800e62:	5d                   	pop    %ebp
  800e63:	c3                   	ret    
		return 0;
  800e64:	b8 00 00 00 00       	mov    $0x0,%eax
  800e69:	eb f6                	jmp    800e61 <strncmp+0x32>

00800e6b <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800e6b:	f3 0f 1e fb          	endbr32 
  800e6f:	55                   	push   %ebp
  800e70:	89 e5                	mov    %esp,%ebp
  800e72:	8b 45 08             	mov    0x8(%ebp),%eax
  800e75:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e79:	0f b6 10             	movzbl (%eax),%edx
  800e7c:	84 d2                	test   %dl,%dl
  800e7e:	74 09                	je     800e89 <strchr+0x1e>
		if (*s == c)
  800e80:	38 ca                	cmp    %cl,%dl
  800e82:	74 0a                	je     800e8e <strchr+0x23>
	for (; *s; s++)
  800e84:	83 c0 01             	add    $0x1,%eax
  800e87:	eb f0                	jmp    800e79 <strchr+0xe>
			return (char *) s;
	return 0;
  800e89:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800e8e:	5d                   	pop    %ebp
  800e8f:	c3                   	ret    

00800e90 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800e90:	f3 0f 1e fb          	endbr32 
  800e94:	55                   	push   %ebp
  800e95:	89 e5                	mov    %esp,%ebp
  800e97:	8b 45 08             	mov    0x8(%ebp),%eax
  800e9a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800e9e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ea1:	38 ca                	cmp    %cl,%dl
  800ea3:	74 09                	je     800eae <strfind+0x1e>
  800ea5:	84 d2                	test   %dl,%dl
  800ea7:	74 05                	je     800eae <strfind+0x1e>
	for (; *s; s++)
  800ea9:	83 c0 01             	add    $0x1,%eax
  800eac:	eb f0                	jmp    800e9e <strfind+0xe>
			break;
	return (char *) s;
}
  800eae:	5d                   	pop    %ebp
  800eaf:	c3                   	ret    

00800eb0 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800eb0:	f3 0f 1e fb          	endbr32 
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
  800eb7:	57                   	push   %edi
  800eb8:	56                   	push   %esi
  800eb9:	53                   	push   %ebx
  800eba:	8b 55 08             	mov    0x8(%ebp),%edx
  800ebd:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  800ec0:	85 c9                	test   %ecx,%ecx
  800ec2:	74 33                	je     800ef7 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800ec4:	89 d0                	mov    %edx,%eax
  800ec6:	09 c8                	or     %ecx,%eax
  800ec8:	a8 03                	test   $0x3,%al
  800eca:	75 23                	jne    800eef <memset+0x3f>
		c &= 0xFF;
  800ecc:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ed0:	89 d8                	mov    %ebx,%eax
  800ed2:	c1 e0 08             	shl    $0x8,%eax
  800ed5:	89 df                	mov    %ebx,%edi
  800ed7:	c1 e7 18             	shl    $0x18,%edi
  800eda:	89 de                	mov    %ebx,%esi
  800edc:	c1 e6 10             	shl    $0x10,%esi
  800edf:	09 f7                	or     %esi,%edi
  800ee1:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  800ee3:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800ee6:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  800ee8:	89 d7                	mov    %edx,%edi
  800eea:	fc                   	cld    
  800eeb:	f3 ab                	rep stos %eax,%es:(%edi)
  800eed:	eb 08                	jmp    800ef7 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800eef:	89 d7                	mov    %edx,%edi
  800ef1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ef4:	fc                   	cld    
  800ef5:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  800ef7:	89 d0                	mov    %edx,%eax
  800ef9:	5b                   	pop    %ebx
  800efa:	5e                   	pop    %esi
  800efb:	5f                   	pop    %edi
  800efc:	5d                   	pop    %ebp
  800efd:	c3                   	ret    

00800efe <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800efe:	f3 0f 1e fb          	endbr32 
  800f02:	55                   	push   %ebp
  800f03:	89 e5                	mov    %esp,%ebp
  800f05:	57                   	push   %edi
  800f06:	56                   	push   %esi
  800f07:	8b 45 08             	mov    0x8(%ebp),%eax
  800f0a:	8b 75 0c             	mov    0xc(%ebp),%esi
  800f0d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800f10:	39 c6                	cmp    %eax,%esi
  800f12:	73 32                	jae    800f46 <memmove+0x48>
  800f14:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800f17:	39 c2                	cmp    %eax,%edx
  800f19:	76 2b                	jbe    800f46 <memmove+0x48>
		s += n;
		d += n;
  800f1b:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f1e:	89 fe                	mov    %edi,%esi
  800f20:	09 ce                	or     %ecx,%esi
  800f22:	09 d6                	or     %edx,%esi
  800f24:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800f2a:	75 0e                	jne    800f3a <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  800f2c:	83 ef 04             	sub    $0x4,%edi
  800f2f:	8d 72 fc             	lea    -0x4(%edx),%esi
  800f32:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  800f35:	fd                   	std    
  800f36:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f38:	eb 09                	jmp    800f43 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  800f3a:	83 ef 01             	sub    $0x1,%edi
  800f3d:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  800f40:	fd                   	std    
  800f41:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800f43:	fc                   	cld    
  800f44:	eb 1a                	jmp    800f60 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800f46:	89 c2                	mov    %eax,%edx
  800f48:	09 ca                	or     %ecx,%edx
  800f4a:	09 f2                	or     %esi,%edx
  800f4c:	f6 c2 03             	test   $0x3,%dl
  800f4f:	75 0a                	jne    800f5b <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  800f51:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  800f54:	89 c7                	mov    %eax,%edi
  800f56:	fc                   	cld    
  800f57:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800f59:	eb 05                	jmp    800f60 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  800f5b:	89 c7                	mov    %eax,%edi
  800f5d:	fc                   	cld    
  800f5e:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800f60:	5e                   	pop    %esi
  800f61:	5f                   	pop    %edi
  800f62:	5d                   	pop    %ebp
  800f63:	c3                   	ret    

00800f64 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800f64:	f3 0f 1e fb          	endbr32 
  800f68:	55                   	push   %ebp
  800f69:	89 e5                	mov    %esp,%ebp
  800f6b:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  800f6e:	ff 75 10             	pushl  0x10(%ebp)
  800f71:	ff 75 0c             	pushl  0xc(%ebp)
  800f74:	ff 75 08             	pushl  0x8(%ebp)
  800f77:	e8 82 ff ff ff       	call   800efe <memmove>
}
  800f7c:	c9                   	leave  
  800f7d:	c3                   	ret    

00800f7e <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800f7e:	f3 0f 1e fb          	endbr32 
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	56                   	push   %esi
  800f86:	53                   	push   %ebx
  800f87:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8d:	89 c6                	mov    %eax,%esi
  800f8f:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800f92:	39 f0                	cmp    %esi,%eax
  800f94:	74 1c                	je     800fb2 <memcmp+0x34>
		if (*s1 != *s2)
  800f96:	0f b6 08             	movzbl (%eax),%ecx
  800f99:	0f b6 1a             	movzbl (%edx),%ebx
  800f9c:	38 d9                	cmp    %bl,%cl
  800f9e:	75 08                	jne    800fa8 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  800fa0:	83 c0 01             	add    $0x1,%eax
  800fa3:	83 c2 01             	add    $0x1,%edx
  800fa6:	eb ea                	jmp    800f92 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  800fa8:	0f b6 c1             	movzbl %cl,%eax
  800fab:	0f b6 db             	movzbl %bl,%ebx
  800fae:	29 d8                	sub    %ebx,%eax
  800fb0:	eb 05                	jmp    800fb7 <memcmp+0x39>
	}

	return 0;
  800fb2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800fb7:	5b                   	pop    %ebx
  800fb8:	5e                   	pop    %esi
  800fb9:	5d                   	pop    %ebp
  800fba:	c3                   	ret    

00800fbb <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800fbb:	f3 0f 1e fb          	endbr32 
  800fbf:	55                   	push   %ebp
  800fc0:	89 e5                	mov    %esp,%ebp
  800fc2:	8b 45 08             	mov    0x8(%ebp),%eax
  800fc5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  800fc8:	89 c2                	mov    %eax,%edx
  800fca:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  800fcd:	39 d0                	cmp    %edx,%eax
  800fcf:	73 09                	jae    800fda <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  800fd1:	38 08                	cmp    %cl,(%eax)
  800fd3:	74 05                	je     800fda <memfind+0x1f>
	for (; s < ends; s++)
  800fd5:	83 c0 01             	add    $0x1,%eax
  800fd8:	eb f3                	jmp    800fcd <memfind+0x12>
			break;
	return (void *) s;
}
  800fda:	5d                   	pop    %ebp
  800fdb:	c3                   	ret    

00800fdc <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800fdc:	f3 0f 1e fb          	endbr32 
  800fe0:	55                   	push   %ebp
  800fe1:	89 e5                	mov    %esp,%ebp
  800fe3:	57                   	push   %edi
  800fe4:	56                   	push   %esi
  800fe5:	53                   	push   %ebx
  800fe6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800fe9:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800fec:	eb 03                	jmp    800ff1 <strtol+0x15>
		s++;
  800fee:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  800ff1:	0f b6 01             	movzbl (%ecx),%eax
  800ff4:	3c 20                	cmp    $0x20,%al
  800ff6:	74 f6                	je     800fee <strtol+0x12>
  800ff8:	3c 09                	cmp    $0x9,%al
  800ffa:	74 f2                	je     800fee <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  800ffc:	3c 2b                	cmp    $0x2b,%al
  800ffe:	74 2a                	je     80102a <strtol+0x4e>
	int neg = 0;
  801000:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801005:	3c 2d                	cmp    $0x2d,%al
  801007:	74 2b                	je     801034 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801009:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80100f:	75 0f                	jne    801020 <strtol+0x44>
  801011:	80 39 30             	cmpb   $0x30,(%ecx)
  801014:	74 28                	je     80103e <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801016:	85 db                	test   %ebx,%ebx
  801018:	b8 0a 00 00 00       	mov    $0xa,%eax
  80101d:	0f 44 d8             	cmove  %eax,%ebx
  801020:	b8 00 00 00 00       	mov    $0x0,%eax
  801025:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801028:	eb 46                	jmp    801070 <strtol+0x94>
		s++;
  80102a:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  80102d:	bf 00 00 00 00       	mov    $0x0,%edi
  801032:	eb d5                	jmp    801009 <strtol+0x2d>
		s++, neg = 1;
  801034:	83 c1 01             	add    $0x1,%ecx
  801037:	bf 01 00 00 00       	mov    $0x1,%edi
  80103c:	eb cb                	jmp    801009 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80103e:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801042:	74 0e                	je     801052 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801044:	85 db                	test   %ebx,%ebx
  801046:	75 d8                	jne    801020 <strtol+0x44>
		s++, base = 8;
  801048:	83 c1 01             	add    $0x1,%ecx
  80104b:	bb 08 00 00 00       	mov    $0x8,%ebx
  801050:	eb ce                	jmp    801020 <strtol+0x44>
		s += 2, base = 16;
  801052:	83 c1 02             	add    $0x2,%ecx
  801055:	bb 10 00 00 00       	mov    $0x10,%ebx
  80105a:	eb c4                	jmp    801020 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  80105c:	0f be d2             	movsbl %dl,%edx
  80105f:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  801062:	3b 55 10             	cmp    0x10(%ebp),%edx
  801065:	7d 3a                	jge    8010a1 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  801067:	83 c1 01             	add    $0x1,%ecx
  80106a:	0f af 45 10          	imul   0x10(%ebp),%eax
  80106e:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  801070:	0f b6 11             	movzbl (%ecx),%edx
  801073:	8d 72 d0             	lea    -0x30(%edx),%esi
  801076:	89 f3                	mov    %esi,%ebx
  801078:	80 fb 09             	cmp    $0x9,%bl
  80107b:	76 df                	jbe    80105c <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  80107d:	8d 72 9f             	lea    -0x61(%edx),%esi
  801080:	89 f3                	mov    %esi,%ebx
  801082:	80 fb 19             	cmp    $0x19,%bl
  801085:	77 08                	ja     80108f <strtol+0xb3>
			dig = *s - 'a' + 10;
  801087:	0f be d2             	movsbl %dl,%edx
  80108a:	83 ea 57             	sub    $0x57,%edx
  80108d:	eb d3                	jmp    801062 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  80108f:	8d 72 bf             	lea    -0x41(%edx),%esi
  801092:	89 f3                	mov    %esi,%ebx
  801094:	80 fb 19             	cmp    $0x19,%bl
  801097:	77 08                	ja     8010a1 <strtol+0xc5>
			dig = *s - 'A' + 10;
  801099:	0f be d2             	movsbl %dl,%edx
  80109c:	83 ea 37             	sub    $0x37,%edx
  80109f:	eb c1                	jmp    801062 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  8010a1:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8010a5:	74 05                	je     8010ac <strtol+0xd0>
		*endptr = (char *) s;
  8010a7:	8b 75 0c             	mov    0xc(%ebp),%esi
  8010aa:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8010ac:	89 c2                	mov    %eax,%edx
  8010ae:	f7 da                	neg    %edx
  8010b0:	85 ff                	test   %edi,%edi
  8010b2:	0f 45 c2             	cmovne %edx,%eax
}
  8010b5:	5b                   	pop    %ebx
  8010b6:	5e                   	pop    %esi
  8010b7:	5f                   	pop    %edi
  8010b8:	5d                   	pop    %ebp
  8010b9:	c3                   	ret    

008010ba <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8010ba:	55                   	push   %ebp
  8010bb:	89 e5                	mov    %esp,%ebp
  8010bd:	57                   	push   %edi
  8010be:	56                   	push   %esi
  8010bf:	53                   	push   %ebx
  8010c0:	83 ec 1c             	sub    $0x1c,%esp
  8010c3:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8010c6:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8010c9:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8010cb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ce:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8010d1:	8b 7d 10             	mov    0x10(%ebp),%edi
  8010d4:	8b 75 14             	mov    0x14(%ebp),%esi
  8010d7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8010d9:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8010dd:	74 04                	je     8010e3 <syscall+0x29>
  8010df:	85 c0                	test   %eax,%eax
  8010e1:	7f 08                	jg     8010eb <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8010e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8010e6:	5b                   	pop    %ebx
  8010e7:	5e                   	pop    %esi
  8010e8:	5f                   	pop    %edi
  8010e9:	5d                   	pop    %ebp
  8010ea:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8010eb:	83 ec 0c             	sub    $0xc,%esp
  8010ee:	50                   	push   %eax
  8010ef:	ff 75 e0             	pushl  -0x20(%ebp)
  8010f2:	68 1f 2b 80 00       	push   $0x802b1f
  8010f7:	6a 23                	push   $0x23
  8010f9:	68 3c 2b 80 00       	push   $0x802b3c
  8010fe:	e8 f2 f5 ff ff       	call   8006f5 <_panic>

00801103 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  801103:	f3 0f 1e fb          	endbr32 
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80110d:	6a 00                	push   $0x0
  80110f:	6a 00                	push   $0x0
  801111:	6a 00                	push   $0x0
  801113:	ff 75 0c             	pushl  0xc(%ebp)
  801116:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801119:	ba 00 00 00 00       	mov    $0x0,%edx
  80111e:	b8 00 00 00 00       	mov    $0x0,%eax
  801123:	e8 92 ff ff ff       	call   8010ba <syscall>
}
  801128:	83 c4 10             	add    $0x10,%esp
  80112b:	c9                   	leave  
  80112c:	c3                   	ret    

0080112d <sys_cgetc>:

int
sys_cgetc(void)
{
  80112d:	f3 0f 1e fb          	endbr32 
  801131:	55                   	push   %ebp
  801132:	89 e5                	mov    %esp,%ebp
  801134:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  801137:	6a 00                	push   $0x0
  801139:	6a 00                	push   $0x0
  80113b:	6a 00                	push   $0x0
  80113d:	6a 00                	push   $0x0
  80113f:	b9 00 00 00 00       	mov    $0x0,%ecx
  801144:	ba 00 00 00 00       	mov    $0x0,%edx
  801149:	b8 01 00 00 00       	mov    $0x1,%eax
  80114e:	e8 67 ff ff ff       	call   8010ba <syscall>
}
  801153:	c9                   	leave  
  801154:	c3                   	ret    

00801155 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  801155:	f3 0f 1e fb          	endbr32 
  801159:	55                   	push   %ebp
  80115a:	89 e5                	mov    %esp,%ebp
  80115c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80115f:	6a 00                	push   $0x0
  801161:	6a 00                	push   $0x0
  801163:	6a 00                	push   $0x0
  801165:	6a 00                	push   $0x0
  801167:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80116a:	ba 01 00 00 00       	mov    $0x1,%edx
  80116f:	b8 03 00 00 00       	mov    $0x3,%eax
  801174:	e8 41 ff ff ff       	call   8010ba <syscall>
}
  801179:	c9                   	leave  
  80117a:	c3                   	ret    

0080117b <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80117b:	f3 0f 1e fb          	endbr32 
  80117f:	55                   	push   %ebp
  801180:	89 e5                	mov    %esp,%ebp
  801182:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  801185:	6a 00                	push   $0x0
  801187:	6a 00                	push   $0x0
  801189:	6a 00                	push   $0x0
  80118b:	6a 00                	push   $0x0
  80118d:	b9 00 00 00 00       	mov    $0x0,%ecx
  801192:	ba 00 00 00 00       	mov    $0x0,%edx
  801197:	b8 02 00 00 00       	mov    $0x2,%eax
  80119c:	e8 19 ff ff ff       	call   8010ba <syscall>
}
  8011a1:	c9                   	leave  
  8011a2:	c3                   	ret    

008011a3 <sys_yield>:

void
sys_yield(void)
{
  8011a3:	f3 0f 1e fb          	endbr32 
  8011a7:	55                   	push   %ebp
  8011a8:	89 e5                	mov    %esp,%ebp
  8011aa:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8011ad:	6a 00                	push   $0x0
  8011af:	6a 00                	push   $0x0
  8011b1:	6a 00                	push   $0x0
  8011b3:	6a 00                	push   $0x0
  8011b5:	b9 00 00 00 00       	mov    $0x0,%ecx
  8011ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8011bf:	b8 0b 00 00 00       	mov    $0xb,%eax
  8011c4:	e8 f1 fe ff ff       	call   8010ba <syscall>
}
  8011c9:	83 c4 10             	add    $0x10,%esp
  8011cc:	c9                   	leave  
  8011cd:	c3                   	ret    

008011ce <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8011ce:	f3 0f 1e fb          	endbr32 
  8011d2:	55                   	push   %ebp
  8011d3:	89 e5                	mov    %esp,%ebp
  8011d5:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8011d8:	6a 00                	push   $0x0
  8011da:	6a 00                	push   $0x0
  8011dc:	ff 75 10             	pushl  0x10(%ebp)
  8011df:	ff 75 0c             	pushl  0xc(%ebp)
  8011e2:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8011e5:	ba 01 00 00 00       	mov    $0x1,%edx
  8011ea:	b8 04 00 00 00       	mov    $0x4,%eax
  8011ef:	e8 c6 fe ff ff       	call   8010ba <syscall>
}
  8011f4:	c9                   	leave  
  8011f5:	c3                   	ret    

008011f6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8011f6:	f3 0f 1e fb          	endbr32 
  8011fa:	55                   	push   %ebp
  8011fb:	89 e5                	mov    %esp,%ebp
  8011fd:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  801200:	ff 75 18             	pushl  0x18(%ebp)
  801203:	ff 75 14             	pushl  0x14(%ebp)
  801206:	ff 75 10             	pushl  0x10(%ebp)
  801209:	ff 75 0c             	pushl  0xc(%ebp)
  80120c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80120f:	ba 01 00 00 00       	mov    $0x1,%edx
  801214:	b8 05 00 00 00       	mov    $0x5,%eax
  801219:	e8 9c fe ff ff       	call   8010ba <syscall>
}
  80121e:	c9                   	leave  
  80121f:	c3                   	ret    

00801220 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  801220:	f3 0f 1e fb          	endbr32 
  801224:	55                   	push   %ebp
  801225:	89 e5                	mov    %esp,%ebp
  801227:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80122a:	6a 00                	push   $0x0
  80122c:	6a 00                	push   $0x0
  80122e:	6a 00                	push   $0x0
  801230:	ff 75 0c             	pushl  0xc(%ebp)
  801233:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801236:	ba 01 00 00 00       	mov    $0x1,%edx
  80123b:	b8 06 00 00 00       	mov    $0x6,%eax
  801240:	e8 75 fe ff ff       	call   8010ba <syscall>
}
  801245:	c9                   	leave  
  801246:	c3                   	ret    

00801247 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  801247:	f3 0f 1e fb          	endbr32 
  80124b:	55                   	push   %ebp
  80124c:	89 e5                	mov    %esp,%ebp
  80124e:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  801251:	6a 00                	push   $0x0
  801253:	6a 00                	push   $0x0
  801255:	6a 00                	push   $0x0
  801257:	ff 75 0c             	pushl  0xc(%ebp)
  80125a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80125d:	ba 01 00 00 00       	mov    $0x1,%edx
  801262:	b8 08 00 00 00       	mov    $0x8,%eax
  801267:	e8 4e fe ff ff       	call   8010ba <syscall>
}
  80126c:	c9                   	leave  
  80126d:	c3                   	ret    

0080126e <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80126e:	f3 0f 1e fb          	endbr32 
  801272:	55                   	push   %ebp
  801273:	89 e5                	mov    %esp,%ebp
  801275:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  801278:	6a 00                	push   $0x0
  80127a:	6a 00                	push   $0x0
  80127c:	6a 00                	push   $0x0
  80127e:	ff 75 0c             	pushl  0xc(%ebp)
  801281:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801284:	ba 01 00 00 00       	mov    $0x1,%edx
  801289:	b8 09 00 00 00       	mov    $0x9,%eax
  80128e:	e8 27 fe ff ff       	call   8010ba <syscall>
}
  801293:	c9                   	leave  
  801294:	c3                   	ret    

00801295 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  801295:	f3 0f 1e fb          	endbr32 
  801299:	55                   	push   %ebp
  80129a:	89 e5                	mov    %esp,%ebp
  80129c:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80129f:	6a 00                	push   $0x0
  8012a1:	6a 00                	push   $0x0
  8012a3:	6a 00                	push   $0x0
  8012a5:	ff 75 0c             	pushl  0xc(%ebp)
  8012a8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012ab:	ba 01 00 00 00       	mov    $0x1,%edx
  8012b0:	b8 0a 00 00 00       	mov    $0xa,%eax
  8012b5:	e8 00 fe ff ff       	call   8010ba <syscall>
}
  8012ba:	c9                   	leave  
  8012bb:	c3                   	ret    

008012bc <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8012bc:	f3 0f 1e fb          	endbr32 
  8012c0:	55                   	push   %ebp
  8012c1:	89 e5                	mov    %esp,%ebp
  8012c3:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8012c6:	6a 00                	push   $0x0
  8012c8:	ff 75 14             	pushl  0x14(%ebp)
  8012cb:	ff 75 10             	pushl  0x10(%ebp)
  8012ce:	ff 75 0c             	pushl  0xc(%ebp)
  8012d1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012d4:	ba 00 00 00 00       	mov    $0x0,%edx
  8012d9:	b8 0c 00 00 00       	mov    $0xc,%eax
  8012de:	e8 d7 fd ff ff       	call   8010ba <syscall>
}
  8012e3:	c9                   	leave  
  8012e4:	c3                   	ret    

008012e5 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8012e5:	f3 0f 1e fb          	endbr32 
  8012e9:	55                   	push   %ebp
  8012ea:	89 e5                	mov    %esp,%ebp
  8012ec:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8012ef:	6a 00                	push   $0x0
  8012f1:	6a 00                	push   $0x0
  8012f3:	6a 00                	push   $0x0
  8012f5:	6a 00                	push   $0x0
  8012f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8012fa:	ba 01 00 00 00       	mov    $0x1,%edx
  8012ff:	b8 0d 00 00 00       	mov    $0xd,%eax
  801304:	e8 b1 fd ff ff       	call   8010ba <syscall>
}
  801309:	c9                   	leave  
  80130a:	c3                   	ret    

0080130b <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  80130b:	f3 0f 1e fb          	endbr32 
  80130f:	55                   	push   %ebp
  801310:	89 e5                	mov    %esp,%ebp
  801312:	56                   	push   %esi
  801313:	53                   	push   %ebx
  801314:	8b 75 08             	mov    0x8(%ebp),%esi
  801317:	8b 45 0c             	mov    0xc(%ebp),%eax
  80131a:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  80131d:	85 c0                	test   %eax,%eax
  80131f:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801324:	0f 44 c2             	cmove  %edx,%eax
  801327:	83 ec 0c             	sub    $0xc,%esp
  80132a:	50                   	push   %eax
  80132b:	e8 b5 ff ff ff       	call   8012e5 <sys_ipc_recv>

	if (from_env_store != NULL)
  801330:	83 c4 10             	add    $0x10,%esp
  801333:	85 f6                	test   %esi,%esi
  801335:	74 15                	je     80134c <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  801337:	ba 00 00 00 00       	mov    $0x0,%edx
  80133c:	83 f8 fd             	cmp    $0xfffffffd,%eax
  80133f:	74 09                	je     80134a <ipc_recv+0x3f>
  801341:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801347:	8b 52 74             	mov    0x74(%edx),%edx
  80134a:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  80134c:	85 db                	test   %ebx,%ebx
  80134e:	74 15                	je     801365 <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  801350:	ba 00 00 00 00       	mov    $0x0,%edx
  801355:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801358:	74 09                	je     801363 <ipc_recv+0x58>
  80135a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801360:	8b 52 78             	mov    0x78(%edx),%edx
  801363:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  801365:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801368:	74 08                	je     801372 <ipc_recv+0x67>
  80136a:	a1 04 40 80 00       	mov    0x804004,%eax
  80136f:	8b 40 70             	mov    0x70(%eax),%eax
}
  801372:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801375:	5b                   	pop    %ebx
  801376:	5e                   	pop    %esi
  801377:	5d                   	pop    %ebp
  801378:	c3                   	ret    

00801379 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801379:	f3 0f 1e fb          	endbr32 
  80137d:	55                   	push   %ebp
  80137e:	89 e5                	mov    %esp,%ebp
  801380:	57                   	push   %edi
  801381:	56                   	push   %esi
  801382:	53                   	push   %ebx
  801383:	83 ec 0c             	sub    $0xc,%esp
  801386:	8b 7d 08             	mov    0x8(%ebp),%edi
  801389:	8b 75 0c             	mov    0xc(%ebp),%esi
  80138c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80138f:	eb 1f                	jmp    8013b0 <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  801391:	6a 00                	push   $0x0
  801393:	68 00 00 c0 ee       	push   $0xeec00000
  801398:	56                   	push   %esi
  801399:	57                   	push   %edi
  80139a:	e8 1d ff ff ff       	call   8012bc <sys_ipc_try_send>
  80139f:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  8013a2:	85 c0                	test   %eax,%eax
  8013a4:	74 30                	je     8013d6 <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  8013a6:	83 f8 f9             	cmp    $0xfffffff9,%eax
  8013a9:	75 19                	jne    8013c4 <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  8013ab:	e8 f3 fd ff ff       	call   8011a3 <sys_yield>
		if (pg != NULL) {
  8013b0:	85 db                	test   %ebx,%ebx
  8013b2:	74 dd                	je     801391 <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  8013b4:	ff 75 14             	pushl  0x14(%ebp)
  8013b7:	53                   	push   %ebx
  8013b8:	56                   	push   %esi
  8013b9:	57                   	push   %edi
  8013ba:	e8 fd fe ff ff       	call   8012bc <sys_ipc_try_send>
  8013bf:	83 c4 10             	add    $0x10,%esp
  8013c2:	eb de                	jmp    8013a2 <ipc_send+0x29>
			panic("ipc_send: %d", res);
  8013c4:	50                   	push   %eax
  8013c5:	68 4a 2b 80 00       	push   $0x802b4a
  8013ca:	6a 3e                	push   $0x3e
  8013cc:	68 57 2b 80 00       	push   $0x802b57
  8013d1:	e8 1f f3 ff ff       	call   8006f5 <_panic>
	}
}
  8013d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8013d9:	5b                   	pop    %ebx
  8013da:	5e                   	pop    %esi
  8013db:	5f                   	pop    %edi
  8013dc:	5d                   	pop    %ebp
  8013dd:	c3                   	ret    

008013de <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  8013de:	f3 0f 1e fb          	endbr32 
  8013e2:	55                   	push   %ebp
  8013e3:	89 e5                	mov    %esp,%ebp
  8013e5:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  8013e8:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  8013ed:	6b d0 7c             	imul   $0x7c,%eax,%edx
  8013f0:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  8013f6:	8b 52 50             	mov    0x50(%edx),%edx
  8013f9:	39 ca                	cmp    %ecx,%edx
  8013fb:	74 11                	je     80140e <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  8013fd:	83 c0 01             	add    $0x1,%eax
  801400:	3d 00 04 00 00       	cmp    $0x400,%eax
  801405:	75 e6                	jne    8013ed <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801407:	b8 00 00 00 00       	mov    $0x0,%eax
  80140c:	eb 0b                	jmp    801419 <ipc_find_env+0x3b>
			return envs[i].env_id;
  80140e:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801411:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801416:	8b 40 48             	mov    0x48(%eax),%eax
}
  801419:	5d                   	pop    %ebp
  80141a:	c3                   	ret    

0080141b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80141b:	f3 0f 1e fb          	endbr32 
  80141f:	55                   	push   %ebp
  801420:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  801422:	8b 45 08             	mov    0x8(%ebp),%eax
  801425:	05 00 00 00 30       	add    $0x30000000,%eax
  80142a:	c1 e8 0c             	shr    $0xc,%eax
}
  80142d:	5d                   	pop    %ebp
  80142e:	c3                   	ret    

0080142f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80142f:	f3 0f 1e fb          	endbr32 
  801433:	55                   	push   %ebp
  801434:	89 e5                	mov    %esp,%ebp
  801436:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  801439:	ff 75 08             	pushl  0x8(%ebp)
  80143c:	e8 da ff ff ff       	call   80141b <fd2num>
  801441:	83 c4 10             	add    $0x10,%esp
  801444:	c1 e0 0c             	shl    $0xc,%eax
  801447:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  80144c:	c9                   	leave  
  80144d:	c3                   	ret    

0080144e <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80144e:	f3 0f 1e fb          	endbr32 
  801452:	55                   	push   %ebp
  801453:	89 e5                	mov    %esp,%ebp
  801455:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80145a:	89 c2                	mov    %eax,%edx
  80145c:	c1 ea 16             	shr    $0x16,%edx
  80145f:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  801466:	f6 c2 01             	test   $0x1,%dl
  801469:	74 2d                	je     801498 <fd_alloc+0x4a>
  80146b:	89 c2                	mov    %eax,%edx
  80146d:	c1 ea 0c             	shr    $0xc,%edx
  801470:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  801477:	f6 c2 01             	test   $0x1,%dl
  80147a:	74 1c                	je     801498 <fd_alloc+0x4a>
  80147c:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  801481:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  801486:	75 d2                	jne    80145a <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  801488:	8b 45 08             	mov    0x8(%ebp),%eax
  80148b:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  801491:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  801496:	eb 0a                	jmp    8014a2 <fd_alloc+0x54>
			*fd_store = fd;
  801498:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80149b:	89 01                	mov    %eax,(%ecx)
			return 0;
  80149d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014a2:	5d                   	pop    %ebp
  8014a3:	c3                   	ret    

008014a4 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8014a4:	f3 0f 1e fb          	endbr32 
  8014a8:	55                   	push   %ebp
  8014a9:	89 e5                	mov    %esp,%ebp
  8014ab:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8014ae:	83 f8 1f             	cmp    $0x1f,%eax
  8014b1:	77 30                	ja     8014e3 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8014b3:	c1 e0 0c             	shl    $0xc,%eax
  8014b6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8014bb:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8014c1:	f6 c2 01             	test   $0x1,%dl
  8014c4:	74 24                	je     8014ea <fd_lookup+0x46>
  8014c6:	89 c2                	mov    %eax,%edx
  8014c8:	c1 ea 0c             	shr    $0xc,%edx
  8014cb:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8014d2:	f6 c2 01             	test   $0x1,%dl
  8014d5:	74 1a                	je     8014f1 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8014d7:	8b 55 0c             	mov    0xc(%ebp),%edx
  8014da:	89 02                	mov    %eax,(%edx)
	return 0;
  8014dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8014e1:	5d                   	pop    %ebp
  8014e2:	c3                   	ret    
		return -E_INVAL;
  8014e3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014e8:	eb f7                	jmp    8014e1 <fd_lookup+0x3d>
		return -E_INVAL;
  8014ea:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014ef:	eb f0                	jmp    8014e1 <fd_lookup+0x3d>
  8014f1:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8014f6:	eb e9                	jmp    8014e1 <fd_lookup+0x3d>

008014f8 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8014f8:	f3 0f 1e fb          	endbr32 
  8014fc:	55                   	push   %ebp
  8014fd:	89 e5                	mov    %esp,%ebp
  8014ff:	83 ec 08             	sub    $0x8,%esp
  801502:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801505:	ba e0 2b 80 00       	mov    $0x802be0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80150a:	b8 08 30 80 00       	mov    $0x803008,%eax
		if (devtab[i]->dev_id == dev_id) {
  80150f:	39 08                	cmp    %ecx,(%eax)
  801511:	74 33                	je     801546 <dev_lookup+0x4e>
  801513:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  801516:	8b 02                	mov    (%edx),%eax
  801518:	85 c0                	test   %eax,%eax
  80151a:	75 f3                	jne    80150f <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  80151c:	a1 04 40 80 00       	mov    0x804004,%eax
  801521:	8b 40 48             	mov    0x48(%eax),%eax
  801524:	83 ec 04             	sub    $0x4,%esp
  801527:	51                   	push   %ecx
  801528:	50                   	push   %eax
  801529:	68 64 2b 80 00       	push   $0x802b64
  80152e:	e8 a9 f2 ff ff       	call   8007dc <cprintf>
	*dev = 0;
  801533:	8b 45 0c             	mov    0xc(%ebp),%eax
  801536:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  80153c:	83 c4 10             	add    $0x10,%esp
  80153f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  801544:	c9                   	leave  
  801545:	c3                   	ret    
			*dev = devtab[i];
  801546:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801549:	89 01                	mov    %eax,(%ecx)
			return 0;
  80154b:	b8 00 00 00 00       	mov    $0x0,%eax
  801550:	eb f2                	jmp    801544 <dev_lookup+0x4c>

00801552 <fd_close>:
{
  801552:	f3 0f 1e fb          	endbr32 
  801556:	55                   	push   %ebp
  801557:	89 e5                	mov    %esp,%ebp
  801559:	57                   	push   %edi
  80155a:	56                   	push   %esi
  80155b:	53                   	push   %ebx
  80155c:	83 ec 28             	sub    $0x28,%esp
  80155f:	8b 75 08             	mov    0x8(%ebp),%esi
  801562:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  801565:	56                   	push   %esi
  801566:	e8 b0 fe ff ff       	call   80141b <fd2num>
  80156b:	83 c4 08             	add    $0x8,%esp
  80156e:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  801571:	52                   	push   %edx
  801572:	50                   	push   %eax
  801573:	e8 2c ff ff ff       	call   8014a4 <fd_lookup>
  801578:	89 c3                	mov    %eax,%ebx
  80157a:	83 c4 10             	add    $0x10,%esp
  80157d:	85 c0                	test   %eax,%eax
  80157f:	78 05                	js     801586 <fd_close+0x34>
	    || fd != fd2)
  801581:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  801584:	74 16                	je     80159c <fd_close+0x4a>
		return (must_exist ? r : 0);
  801586:	89 f8                	mov    %edi,%eax
  801588:	84 c0                	test   %al,%al
  80158a:	b8 00 00 00 00       	mov    $0x0,%eax
  80158f:	0f 44 d8             	cmove  %eax,%ebx
}
  801592:	89 d8                	mov    %ebx,%eax
  801594:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801597:	5b                   	pop    %ebx
  801598:	5e                   	pop    %esi
  801599:	5f                   	pop    %edi
  80159a:	5d                   	pop    %ebp
  80159b:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  80159c:	83 ec 08             	sub    $0x8,%esp
  80159f:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8015a2:	50                   	push   %eax
  8015a3:	ff 36                	pushl  (%esi)
  8015a5:	e8 4e ff ff ff       	call   8014f8 <dev_lookup>
  8015aa:	89 c3                	mov    %eax,%ebx
  8015ac:	83 c4 10             	add    $0x10,%esp
  8015af:	85 c0                	test   %eax,%eax
  8015b1:	78 1a                	js     8015cd <fd_close+0x7b>
		if (dev->dev_close)
  8015b3:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8015b6:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8015b9:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8015be:	85 c0                	test   %eax,%eax
  8015c0:	74 0b                	je     8015cd <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8015c2:	83 ec 0c             	sub    $0xc,%esp
  8015c5:	56                   	push   %esi
  8015c6:	ff d0                	call   *%eax
  8015c8:	89 c3                	mov    %eax,%ebx
  8015ca:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8015cd:	83 ec 08             	sub    $0x8,%esp
  8015d0:	56                   	push   %esi
  8015d1:	6a 00                	push   $0x0
  8015d3:	e8 48 fc ff ff       	call   801220 <sys_page_unmap>
	return r;
  8015d8:	83 c4 10             	add    $0x10,%esp
  8015db:	eb b5                	jmp    801592 <fd_close+0x40>

008015dd <close>:

int
close(int fdnum)
{
  8015dd:	f3 0f 1e fb          	endbr32 
  8015e1:	55                   	push   %ebp
  8015e2:	89 e5                	mov    %esp,%ebp
  8015e4:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8015e7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8015ea:	50                   	push   %eax
  8015eb:	ff 75 08             	pushl  0x8(%ebp)
  8015ee:	e8 b1 fe ff ff       	call   8014a4 <fd_lookup>
  8015f3:	83 c4 10             	add    $0x10,%esp
  8015f6:	85 c0                	test   %eax,%eax
  8015f8:	79 02                	jns    8015fc <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8015fa:	c9                   	leave  
  8015fb:	c3                   	ret    
		return fd_close(fd, 1);
  8015fc:	83 ec 08             	sub    $0x8,%esp
  8015ff:	6a 01                	push   $0x1
  801601:	ff 75 f4             	pushl  -0xc(%ebp)
  801604:	e8 49 ff ff ff       	call   801552 <fd_close>
  801609:	83 c4 10             	add    $0x10,%esp
  80160c:	eb ec                	jmp    8015fa <close+0x1d>

0080160e <close_all>:

void
close_all(void)
{
  80160e:	f3 0f 1e fb          	endbr32 
  801612:	55                   	push   %ebp
  801613:	89 e5                	mov    %esp,%ebp
  801615:	53                   	push   %ebx
  801616:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  801619:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80161e:	83 ec 0c             	sub    $0xc,%esp
  801621:	53                   	push   %ebx
  801622:	e8 b6 ff ff ff       	call   8015dd <close>
	for (i = 0; i < MAXFD; i++)
  801627:	83 c3 01             	add    $0x1,%ebx
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	83 fb 20             	cmp    $0x20,%ebx
  801630:	75 ec                	jne    80161e <close_all+0x10>
}
  801632:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801635:	c9                   	leave  
  801636:	c3                   	ret    

00801637 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  801637:	f3 0f 1e fb          	endbr32 
  80163b:	55                   	push   %ebp
  80163c:	89 e5                	mov    %esp,%ebp
  80163e:	57                   	push   %edi
  80163f:	56                   	push   %esi
  801640:	53                   	push   %ebx
  801641:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  801644:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  801647:	50                   	push   %eax
  801648:	ff 75 08             	pushl  0x8(%ebp)
  80164b:	e8 54 fe ff ff       	call   8014a4 <fd_lookup>
  801650:	89 c3                	mov    %eax,%ebx
  801652:	83 c4 10             	add    $0x10,%esp
  801655:	85 c0                	test   %eax,%eax
  801657:	0f 88 81 00 00 00    	js     8016de <dup+0xa7>
		return r;
	close(newfdnum);
  80165d:	83 ec 0c             	sub    $0xc,%esp
  801660:	ff 75 0c             	pushl  0xc(%ebp)
  801663:	e8 75 ff ff ff       	call   8015dd <close>

	newfd = INDEX2FD(newfdnum);
  801668:	8b 75 0c             	mov    0xc(%ebp),%esi
  80166b:	c1 e6 0c             	shl    $0xc,%esi
  80166e:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  801674:	83 c4 04             	add    $0x4,%esp
  801677:	ff 75 e4             	pushl  -0x1c(%ebp)
  80167a:	e8 b0 fd ff ff       	call   80142f <fd2data>
  80167f:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  801681:	89 34 24             	mov    %esi,(%esp)
  801684:	e8 a6 fd ff ff       	call   80142f <fd2data>
  801689:	83 c4 10             	add    $0x10,%esp
  80168c:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80168e:	89 d8                	mov    %ebx,%eax
  801690:	c1 e8 16             	shr    $0x16,%eax
  801693:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80169a:	a8 01                	test   $0x1,%al
  80169c:	74 11                	je     8016af <dup+0x78>
  80169e:	89 d8                	mov    %ebx,%eax
  8016a0:	c1 e8 0c             	shr    $0xc,%eax
  8016a3:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8016aa:	f6 c2 01             	test   $0x1,%dl
  8016ad:	75 39                	jne    8016e8 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8016af:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8016b2:	89 d0                	mov    %edx,%eax
  8016b4:	c1 e8 0c             	shr    $0xc,%eax
  8016b7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016be:	83 ec 0c             	sub    $0xc,%esp
  8016c1:	25 07 0e 00 00       	and    $0xe07,%eax
  8016c6:	50                   	push   %eax
  8016c7:	56                   	push   %esi
  8016c8:	6a 00                	push   $0x0
  8016ca:	52                   	push   %edx
  8016cb:	6a 00                	push   $0x0
  8016cd:	e8 24 fb ff ff       	call   8011f6 <sys_page_map>
  8016d2:	89 c3                	mov    %eax,%ebx
  8016d4:	83 c4 20             	add    $0x20,%esp
  8016d7:	85 c0                	test   %eax,%eax
  8016d9:	78 31                	js     80170c <dup+0xd5>
		goto err;

	return newfdnum;
  8016db:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8016de:	89 d8                	mov    %ebx,%eax
  8016e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8016e3:	5b                   	pop    %ebx
  8016e4:	5e                   	pop    %esi
  8016e5:	5f                   	pop    %edi
  8016e6:	5d                   	pop    %ebp
  8016e7:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8016e8:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8016ef:	83 ec 0c             	sub    $0xc,%esp
  8016f2:	25 07 0e 00 00       	and    $0xe07,%eax
  8016f7:	50                   	push   %eax
  8016f8:	57                   	push   %edi
  8016f9:	6a 00                	push   $0x0
  8016fb:	53                   	push   %ebx
  8016fc:	6a 00                	push   $0x0
  8016fe:	e8 f3 fa ff ff       	call   8011f6 <sys_page_map>
  801703:	89 c3                	mov    %eax,%ebx
  801705:	83 c4 20             	add    $0x20,%esp
  801708:	85 c0                	test   %eax,%eax
  80170a:	79 a3                	jns    8016af <dup+0x78>
	sys_page_unmap(0, newfd);
  80170c:	83 ec 08             	sub    $0x8,%esp
  80170f:	56                   	push   %esi
  801710:	6a 00                	push   $0x0
  801712:	e8 09 fb ff ff       	call   801220 <sys_page_unmap>
	sys_page_unmap(0, nva);
  801717:	83 c4 08             	add    $0x8,%esp
  80171a:	57                   	push   %edi
  80171b:	6a 00                	push   $0x0
  80171d:	e8 fe fa ff ff       	call   801220 <sys_page_unmap>
	return r;
  801722:	83 c4 10             	add    $0x10,%esp
  801725:	eb b7                	jmp    8016de <dup+0xa7>

00801727 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  801727:	f3 0f 1e fb          	endbr32 
  80172b:	55                   	push   %ebp
  80172c:	89 e5                	mov    %esp,%ebp
  80172e:	53                   	push   %ebx
  80172f:	83 ec 1c             	sub    $0x1c,%esp
  801732:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801735:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801738:	50                   	push   %eax
  801739:	53                   	push   %ebx
  80173a:	e8 65 fd ff ff       	call   8014a4 <fd_lookup>
  80173f:	83 c4 10             	add    $0x10,%esp
  801742:	85 c0                	test   %eax,%eax
  801744:	78 3f                	js     801785 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801746:	83 ec 08             	sub    $0x8,%esp
  801749:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80174c:	50                   	push   %eax
  80174d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801750:	ff 30                	pushl  (%eax)
  801752:	e8 a1 fd ff ff       	call   8014f8 <dev_lookup>
  801757:	83 c4 10             	add    $0x10,%esp
  80175a:	85 c0                	test   %eax,%eax
  80175c:	78 27                	js     801785 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80175e:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801761:	8b 42 08             	mov    0x8(%edx),%eax
  801764:	83 e0 03             	and    $0x3,%eax
  801767:	83 f8 01             	cmp    $0x1,%eax
  80176a:	74 1e                	je     80178a <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  80176c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80176f:	8b 40 08             	mov    0x8(%eax),%eax
  801772:	85 c0                	test   %eax,%eax
  801774:	74 35                	je     8017ab <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  801776:	83 ec 04             	sub    $0x4,%esp
  801779:	ff 75 10             	pushl  0x10(%ebp)
  80177c:	ff 75 0c             	pushl  0xc(%ebp)
  80177f:	52                   	push   %edx
  801780:	ff d0                	call   *%eax
  801782:	83 c4 10             	add    $0x10,%esp
}
  801785:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801788:	c9                   	leave  
  801789:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80178a:	a1 04 40 80 00       	mov    0x804004,%eax
  80178f:	8b 40 48             	mov    0x48(%eax),%eax
  801792:	83 ec 04             	sub    $0x4,%esp
  801795:	53                   	push   %ebx
  801796:	50                   	push   %eax
  801797:	68 a5 2b 80 00       	push   $0x802ba5
  80179c:	e8 3b f0 ff ff       	call   8007dc <cprintf>
		return -E_INVAL;
  8017a1:	83 c4 10             	add    $0x10,%esp
  8017a4:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8017a9:	eb da                	jmp    801785 <read+0x5e>
		return -E_NOT_SUPP;
  8017ab:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8017b0:	eb d3                	jmp    801785 <read+0x5e>

008017b2 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8017b2:	f3 0f 1e fb          	endbr32 
  8017b6:	55                   	push   %ebp
  8017b7:	89 e5                	mov    %esp,%ebp
  8017b9:	57                   	push   %edi
  8017ba:	56                   	push   %esi
  8017bb:	53                   	push   %ebx
  8017bc:	83 ec 0c             	sub    $0xc,%esp
  8017bf:	8b 7d 08             	mov    0x8(%ebp),%edi
  8017c2:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8017c5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8017ca:	eb 02                	jmp    8017ce <readn+0x1c>
  8017cc:	01 c3                	add    %eax,%ebx
  8017ce:	39 f3                	cmp    %esi,%ebx
  8017d0:	73 21                	jae    8017f3 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017d2:	83 ec 04             	sub    $0x4,%esp
  8017d5:	89 f0                	mov    %esi,%eax
  8017d7:	29 d8                	sub    %ebx,%eax
  8017d9:	50                   	push   %eax
  8017da:	89 d8                	mov    %ebx,%eax
  8017dc:	03 45 0c             	add    0xc(%ebp),%eax
  8017df:	50                   	push   %eax
  8017e0:	57                   	push   %edi
  8017e1:	e8 41 ff ff ff       	call   801727 <read>
		if (m < 0)
  8017e6:	83 c4 10             	add    $0x10,%esp
  8017e9:	85 c0                	test   %eax,%eax
  8017eb:	78 04                	js     8017f1 <readn+0x3f>
			return m;
		if (m == 0)
  8017ed:	75 dd                	jne    8017cc <readn+0x1a>
  8017ef:	eb 02                	jmp    8017f3 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8017f1:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8017f3:	89 d8                	mov    %ebx,%eax
  8017f5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8017f8:	5b                   	pop    %ebx
  8017f9:	5e                   	pop    %esi
  8017fa:	5f                   	pop    %edi
  8017fb:	5d                   	pop    %ebp
  8017fc:	c3                   	ret    

008017fd <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8017fd:	f3 0f 1e fb          	endbr32 
  801801:	55                   	push   %ebp
  801802:	89 e5                	mov    %esp,%ebp
  801804:	53                   	push   %ebx
  801805:	83 ec 1c             	sub    $0x1c,%esp
  801808:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80180b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80180e:	50                   	push   %eax
  80180f:	53                   	push   %ebx
  801810:	e8 8f fc ff ff       	call   8014a4 <fd_lookup>
  801815:	83 c4 10             	add    $0x10,%esp
  801818:	85 c0                	test   %eax,%eax
  80181a:	78 3a                	js     801856 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80181c:	83 ec 08             	sub    $0x8,%esp
  80181f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801822:	50                   	push   %eax
  801823:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801826:	ff 30                	pushl  (%eax)
  801828:	e8 cb fc ff ff       	call   8014f8 <dev_lookup>
  80182d:	83 c4 10             	add    $0x10,%esp
  801830:	85 c0                	test   %eax,%eax
  801832:	78 22                	js     801856 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  801834:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801837:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80183b:	74 1e                	je     80185b <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80183d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801840:	8b 52 0c             	mov    0xc(%edx),%edx
  801843:	85 d2                	test   %edx,%edx
  801845:	74 35                	je     80187c <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  801847:	83 ec 04             	sub    $0x4,%esp
  80184a:	ff 75 10             	pushl  0x10(%ebp)
  80184d:	ff 75 0c             	pushl  0xc(%ebp)
  801850:	50                   	push   %eax
  801851:	ff d2                	call   *%edx
  801853:	83 c4 10             	add    $0x10,%esp
}
  801856:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801859:	c9                   	leave  
  80185a:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80185b:	a1 04 40 80 00       	mov    0x804004,%eax
  801860:	8b 40 48             	mov    0x48(%eax),%eax
  801863:	83 ec 04             	sub    $0x4,%esp
  801866:	53                   	push   %ebx
  801867:	50                   	push   %eax
  801868:	68 c1 2b 80 00       	push   $0x802bc1
  80186d:	e8 6a ef ff ff       	call   8007dc <cprintf>
		return -E_INVAL;
  801872:	83 c4 10             	add    $0x10,%esp
  801875:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80187a:	eb da                	jmp    801856 <write+0x59>
		return -E_NOT_SUPP;
  80187c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801881:	eb d3                	jmp    801856 <write+0x59>

00801883 <seek>:

int
seek(int fdnum, off_t offset)
{
  801883:	f3 0f 1e fb          	endbr32 
  801887:	55                   	push   %ebp
  801888:	89 e5                	mov    %esp,%ebp
  80188a:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80188d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801890:	50                   	push   %eax
  801891:	ff 75 08             	pushl  0x8(%ebp)
  801894:	e8 0b fc ff ff       	call   8014a4 <fd_lookup>
  801899:	83 c4 10             	add    $0x10,%esp
  80189c:	85 c0                	test   %eax,%eax
  80189e:	78 0e                	js     8018ae <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8018a0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018a3:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8018a6:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8018a9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8018ae:	c9                   	leave  
  8018af:	c3                   	ret    

008018b0 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8018b0:	f3 0f 1e fb          	endbr32 
  8018b4:	55                   	push   %ebp
  8018b5:	89 e5                	mov    %esp,%ebp
  8018b7:	53                   	push   %ebx
  8018b8:	83 ec 1c             	sub    $0x1c,%esp
  8018bb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8018be:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8018c1:	50                   	push   %eax
  8018c2:	53                   	push   %ebx
  8018c3:	e8 dc fb ff ff       	call   8014a4 <fd_lookup>
  8018c8:	83 c4 10             	add    $0x10,%esp
  8018cb:	85 c0                	test   %eax,%eax
  8018cd:	78 37                	js     801906 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8018cf:	83 ec 08             	sub    $0x8,%esp
  8018d2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8018d5:	50                   	push   %eax
  8018d6:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018d9:	ff 30                	pushl  (%eax)
  8018db:	e8 18 fc ff ff       	call   8014f8 <dev_lookup>
  8018e0:	83 c4 10             	add    $0x10,%esp
  8018e3:	85 c0                	test   %eax,%eax
  8018e5:	78 1f                	js     801906 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8018e7:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8018ea:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8018ee:	74 1b                	je     80190b <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8018f0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8018f3:	8b 52 18             	mov    0x18(%edx),%edx
  8018f6:	85 d2                	test   %edx,%edx
  8018f8:	74 32                	je     80192c <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8018fa:	83 ec 08             	sub    $0x8,%esp
  8018fd:	ff 75 0c             	pushl  0xc(%ebp)
  801900:	50                   	push   %eax
  801901:	ff d2                	call   *%edx
  801903:	83 c4 10             	add    $0x10,%esp
}
  801906:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801909:	c9                   	leave  
  80190a:	c3                   	ret    
			thisenv->env_id, fdnum);
  80190b:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  801910:	8b 40 48             	mov    0x48(%eax),%eax
  801913:	83 ec 04             	sub    $0x4,%esp
  801916:	53                   	push   %ebx
  801917:	50                   	push   %eax
  801918:	68 84 2b 80 00       	push   $0x802b84
  80191d:	e8 ba ee ff ff       	call   8007dc <cprintf>
		return -E_INVAL;
  801922:	83 c4 10             	add    $0x10,%esp
  801925:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80192a:	eb da                	jmp    801906 <ftruncate+0x56>
		return -E_NOT_SUPP;
  80192c:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  801931:	eb d3                	jmp    801906 <ftruncate+0x56>

00801933 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  801933:	f3 0f 1e fb          	endbr32 
  801937:	55                   	push   %ebp
  801938:	89 e5                	mov    %esp,%ebp
  80193a:	53                   	push   %ebx
  80193b:	83 ec 1c             	sub    $0x1c,%esp
  80193e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  801941:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801944:	50                   	push   %eax
  801945:	ff 75 08             	pushl  0x8(%ebp)
  801948:	e8 57 fb ff ff       	call   8014a4 <fd_lookup>
  80194d:	83 c4 10             	add    $0x10,%esp
  801950:	85 c0                	test   %eax,%eax
  801952:	78 4b                	js     80199f <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  801954:	83 ec 08             	sub    $0x8,%esp
  801957:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80195a:	50                   	push   %eax
  80195b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80195e:	ff 30                	pushl  (%eax)
  801960:	e8 93 fb ff ff       	call   8014f8 <dev_lookup>
  801965:	83 c4 10             	add    $0x10,%esp
  801968:	85 c0                	test   %eax,%eax
  80196a:	78 33                	js     80199f <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  80196c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80196f:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  801973:	74 2f                	je     8019a4 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  801975:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  801978:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80197f:	00 00 00 
	stat->st_isdir = 0;
  801982:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801989:	00 00 00 
	stat->st_dev = dev;
  80198c:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  801992:	83 ec 08             	sub    $0x8,%esp
  801995:	53                   	push   %ebx
  801996:	ff 75 f0             	pushl  -0x10(%ebp)
  801999:	ff 50 14             	call   *0x14(%eax)
  80199c:	83 c4 10             	add    $0x10,%esp
}
  80199f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8019a2:	c9                   	leave  
  8019a3:	c3                   	ret    
		return -E_NOT_SUPP;
  8019a4:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8019a9:	eb f4                	jmp    80199f <fstat+0x6c>

008019ab <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8019ab:	f3 0f 1e fb          	endbr32 
  8019af:	55                   	push   %ebp
  8019b0:	89 e5                	mov    %esp,%ebp
  8019b2:	56                   	push   %esi
  8019b3:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8019b4:	83 ec 08             	sub    $0x8,%esp
  8019b7:	6a 00                	push   $0x0
  8019b9:	ff 75 08             	pushl  0x8(%ebp)
  8019bc:	e8 fb 01 00 00       	call   801bbc <open>
  8019c1:	89 c3                	mov    %eax,%ebx
  8019c3:	83 c4 10             	add    $0x10,%esp
  8019c6:	85 c0                	test   %eax,%eax
  8019c8:	78 1b                	js     8019e5 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8019ca:	83 ec 08             	sub    $0x8,%esp
  8019cd:	ff 75 0c             	pushl  0xc(%ebp)
  8019d0:	50                   	push   %eax
  8019d1:	e8 5d ff ff ff       	call   801933 <fstat>
  8019d6:	89 c6                	mov    %eax,%esi
	close(fd);
  8019d8:	89 1c 24             	mov    %ebx,(%esp)
  8019db:	e8 fd fb ff ff       	call   8015dd <close>
	return r;
  8019e0:	83 c4 10             	add    $0x10,%esp
  8019e3:	89 f3                	mov    %esi,%ebx
}
  8019e5:	89 d8                	mov    %ebx,%eax
  8019e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8019ea:	5b                   	pop    %ebx
  8019eb:	5e                   	pop    %esi
  8019ec:	5d                   	pop    %ebp
  8019ed:	c3                   	ret    

008019ee <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8019ee:	55                   	push   %ebp
  8019ef:	89 e5                	mov    %esp,%ebp
  8019f1:	56                   	push   %esi
  8019f2:	53                   	push   %ebx
  8019f3:	89 c6                	mov    %eax,%esi
  8019f5:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8019f7:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8019fe:	74 27                	je     801a27 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  801a00:	6a 07                	push   $0x7
  801a02:	68 00 50 80 00       	push   $0x805000
  801a07:	56                   	push   %esi
  801a08:	ff 35 00 40 80 00    	pushl  0x804000
  801a0e:	e8 66 f9 ff ff       	call   801379 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  801a13:	83 c4 0c             	add    $0xc,%esp
  801a16:	6a 00                	push   $0x0
  801a18:	53                   	push   %ebx
  801a19:	6a 00                	push   $0x0
  801a1b:	e8 eb f8 ff ff       	call   80130b <ipc_recv>
}
  801a20:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a23:	5b                   	pop    %ebx
  801a24:	5e                   	pop    %esi
  801a25:	5d                   	pop    %ebp
  801a26:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  801a27:	83 ec 0c             	sub    $0xc,%esp
  801a2a:	6a 01                	push   $0x1
  801a2c:	e8 ad f9 ff ff       	call   8013de <ipc_find_env>
  801a31:	a3 00 40 80 00       	mov    %eax,0x804000
  801a36:	83 c4 10             	add    $0x10,%esp
  801a39:	eb c5                	jmp    801a00 <fsipc+0x12>

00801a3b <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  801a3b:	f3 0f 1e fb          	endbr32 
  801a3f:	55                   	push   %ebp
  801a40:	89 e5                	mov    %esp,%ebp
  801a42:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  801a45:	8b 45 08             	mov    0x8(%ebp),%eax
  801a48:	8b 40 0c             	mov    0xc(%eax),%eax
  801a4b:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  801a50:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a53:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  801a58:	ba 00 00 00 00       	mov    $0x0,%edx
  801a5d:	b8 02 00 00 00       	mov    $0x2,%eax
  801a62:	e8 87 ff ff ff       	call   8019ee <fsipc>
}
  801a67:	c9                   	leave  
  801a68:	c3                   	ret    

00801a69 <devfile_flush>:
{
  801a69:	f3 0f 1e fb          	endbr32 
  801a6d:	55                   	push   %ebp
  801a6e:	89 e5                	mov    %esp,%ebp
  801a70:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  801a73:	8b 45 08             	mov    0x8(%ebp),%eax
  801a76:	8b 40 0c             	mov    0xc(%eax),%eax
  801a79:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  801a7e:	ba 00 00 00 00       	mov    $0x0,%edx
  801a83:	b8 06 00 00 00       	mov    $0x6,%eax
  801a88:	e8 61 ff ff ff       	call   8019ee <fsipc>
}
  801a8d:	c9                   	leave  
  801a8e:	c3                   	ret    

00801a8f <devfile_stat>:
{
  801a8f:	f3 0f 1e fb          	endbr32 
  801a93:	55                   	push   %ebp
  801a94:	89 e5                	mov    %esp,%ebp
  801a96:	53                   	push   %ebx
  801a97:	83 ec 04             	sub    $0x4,%esp
  801a9a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  801a9d:	8b 45 08             	mov    0x8(%ebp),%eax
  801aa0:	8b 40 0c             	mov    0xc(%eax),%eax
  801aa3:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  801aa8:	ba 00 00 00 00       	mov    $0x0,%edx
  801aad:	b8 05 00 00 00       	mov    $0x5,%eax
  801ab2:	e8 37 ff ff ff       	call   8019ee <fsipc>
  801ab7:	85 c0                	test   %eax,%eax
  801ab9:	78 2c                	js     801ae7 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  801abb:	83 ec 08             	sub    $0x8,%esp
  801abe:	68 00 50 80 00       	push   $0x805000
  801ac3:	53                   	push   %ebx
  801ac4:	e8 7d f2 ff ff       	call   800d46 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  801ac9:	a1 80 50 80 00       	mov    0x805080,%eax
  801ace:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  801ad4:	a1 84 50 80 00       	mov    0x805084,%eax
  801ad9:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  801adf:	83 c4 10             	add    $0x10,%esp
  801ae2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801ae7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801aea:	c9                   	leave  
  801aeb:	c3                   	ret    

00801aec <devfile_write>:
{
  801aec:	f3 0f 1e fb          	endbr32 
  801af0:	55                   	push   %ebp
  801af1:	89 e5                	mov    %esp,%ebp
  801af3:	83 ec 0c             	sub    $0xc,%esp
  801af6:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  801af9:	8b 55 08             	mov    0x8(%ebp),%edx
  801afc:	8b 52 0c             	mov    0xc(%edx),%edx
  801aff:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  801b05:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  801b0a:	ba f8 0f 00 00       	mov    $0xff8,%edx
  801b0f:	0f 47 c2             	cmova  %edx,%eax
  801b12:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  801b17:	50                   	push   %eax
  801b18:	ff 75 0c             	pushl  0xc(%ebp)
  801b1b:	68 08 50 80 00       	push   $0x805008
  801b20:	e8 d9 f3 ff ff       	call   800efe <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  801b25:	ba 00 00 00 00       	mov    $0x0,%edx
  801b2a:	b8 04 00 00 00       	mov    $0x4,%eax
  801b2f:	e8 ba fe ff ff       	call   8019ee <fsipc>
}
  801b34:	c9                   	leave  
  801b35:	c3                   	ret    

00801b36 <devfile_read>:
{
  801b36:	f3 0f 1e fb          	endbr32 
  801b3a:	55                   	push   %ebp
  801b3b:	89 e5                	mov    %esp,%ebp
  801b3d:	56                   	push   %esi
  801b3e:	53                   	push   %ebx
  801b3f:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  801b42:	8b 45 08             	mov    0x8(%ebp),%eax
  801b45:	8b 40 0c             	mov    0xc(%eax),%eax
  801b48:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  801b4d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  801b53:	ba 00 00 00 00       	mov    $0x0,%edx
  801b58:	b8 03 00 00 00       	mov    $0x3,%eax
  801b5d:	e8 8c fe ff ff       	call   8019ee <fsipc>
  801b62:	89 c3                	mov    %eax,%ebx
  801b64:	85 c0                	test   %eax,%eax
  801b66:	78 1f                	js     801b87 <devfile_read+0x51>
	assert(r <= n);
  801b68:	39 f0                	cmp    %esi,%eax
  801b6a:	77 24                	ja     801b90 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  801b6c:	3d 00 10 00 00       	cmp    $0x1000,%eax
  801b71:	7f 33                	jg     801ba6 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  801b73:	83 ec 04             	sub    $0x4,%esp
  801b76:	50                   	push   %eax
  801b77:	68 00 50 80 00       	push   $0x805000
  801b7c:	ff 75 0c             	pushl  0xc(%ebp)
  801b7f:	e8 7a f3 ff ff       	call   800efe <memmove>
	return r;
  801b84:	83 c4 10             	add    $0x10,%esp
}
  801b87:	89 d8                	mov    %ebx,%eax
  801b89:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801b8c:	5b                   	pop    %ebx
  801b8d:	5e                   	pop    %esi
  801b8e:	5d                   	pop    %ebp
  801b8f:	c3                   	ret    
	assert(r <= n);
  801b90:	68 f0 2b 80 00       	push   $0x802bf0
  801b95:	68 f7 2b 80 00       	push   $0x802bf7
  801b9a:	6a 7c                	push   $0x7c
  801b9c:	68 0c 2c 80 00       	push   $0x802c0c
  801ba1:	e8 4f eb ff ff       	call   8006f5 <_panic>
	assert(r <= PGSIZE);
  801ba6:	68 17 2c 80 00       	push   $0x802c17
  801bab:	68 f7 2b 80 00       	push   $0x802bf7
  801bb0:	6a 7d                	push   $0x7d
  801bb2:	68 0c 2c 80 00       	push   $0x802c0c
  801bb7:	e8 39 eb ff ff       	call   8006f5 <_panic>

00801bbc <open>:
{
  801bbc:	f3 0f 1e fb          	endbr32 
  801bc0:	55                   	push   %ebp
  801bc1:	89 e5                	mov    %esp,%ebp
  801bc3:	56                   	push   %esi
  801bc4:	53                   	push   %ebx
  801bc5:	83 ec 1c             	sub    $0x1c,%esp
  801bc8:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  801bcb:	56                   	push   %esi
  801bcc:	e8 32 f1 ff ff       	call   800d03 <strlen>
  801bd1:	83 c4 10             	add    $0x10,%esp
  801bd4:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  801bd9:	7f 6c                	jg     801c47 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  801bdb:	83 ec 0c             	sub    $0xc,%esp
  801bde:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801be1:	50                   	push   %eax
  801be2:	e8 67 f8 ff ff       	call   80144e <fd_alloc>
  801be7:	89 c3                	mov    %eax,%ebx
  801be9:	83 c4 10             	add    $0x10,%esp
  801bec:	85 c0                	test   %eax,%eax
  801bee:	78 3c                	js     801c2c <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  801bf0:	83 ec 08             	sub    $0x8,%esp
  801bf3:	56                   	push   %esi
  801bf4:	68 00 50 80 00       	push   $0x805000
  801bf9:	e8 48 f1 ff ff       	call   800d46 <strcpy>
	fsipcbuf.open.req_omode = mode;
  801bfe:	8b 45 0c             	mov    0xc(%ebp),%eax
  801c01:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  801c06:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801c09:	b8 01 00 00 00       	mov    $0x1,%eax
  801c0e:	e8 db fd ff ff       	call   8019ee <fsipc>
  801c13:	89 c3                	mov    %eax,%ebx
  801c15:	83 c4 10             	add    $0x10,%esp
  801c18:	85 c0                	test   %eax,%eax
  801c1a:	78 19                	js     801c35 <open+0x79>
	return fd2num(fd);
  801c1c:	83 ec 0c             	sub    $0xc,%esp
  801c1f:	ff 75 f4             	pushl  -0xc(%ebp)
  801c22:	e8 f4 f7 ff ff       	call   80141b <fd2num>
  801c27:	89 c3                	mov    %eax,%ebx
  801c29:	83 c4 10             	add    $0x10,%esp
}
  801c2c:	89 d8                	mov    %ebx,%eax
  801c2e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801c31:	5b                   	pop    %ebx
  801c32:	5e                   	pop    %esi
  801c33:	5d                   	pop    %ebp
  801c34:	c3                   	ret    
		fd_close(fd, 0);
  801c35:	83 ec 08             	sub    $0x8,%esp
  801c38:	6a 00                	push   $0x0
  801c3a:	ff 75 f4             	pushl  -0xc(%ebp)
  801c3d:	e8 10 f9 ff ff       	call   801552 <fd_close>
		return r;
  801c42:	83 c4 10             	add    $0x10,%esp
  801c45:	eb e5                	jmp    801c2c <open+0x70>
		return -E_BAD_PATH;
  801c47:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  801c4c:	eb de                	jmp    801c2c <open+0x70>

00801c4e <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  801c4e:	f3 0f 1e fb          	endbr32 
  801c52:	55                   	push   %ebp
  801c53:	89 e5                	mov    %esp,%ebp
  801c55:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  801c58:	ba 00 00 00 00       	mov    $0x0,%edx
  801c5d:	b8 08 00 00 00       	mov    $0x8,%eax
  801c62:	e8 87 fd ff ff       	call   8019ee <fsipc>
}
  801c67:	c9                   	leave  
  801c68:	c3                   	ret    

00801c69 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  801c69:	f3 0f 1e fb          	endbr32 
  801c6d:	55                   	push   %ebp
  801c6e:	89 e5                	mov    %esp,%ebp
  801c70:	56                   	push   %esi
  801c71:	53                   	push   %ebx
  801c72:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  801c75:	83 ec 0c             	sub    $0xc,%esp
  801c78:	ff 75 08             	pushl  0x8(%ebp)
  801c7b:	e8 af f7 ff ff       	call   80142f <fd2data>
  801c80:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  801c82:	83 c4 08             	add    $0x8,%esp
  801c85:	68 23 2c 80 00       	push   $0x802c23
  801c8a:	53                   	push   %ebx
  801c8b:	e8 b6 f0 ff ff       	call   800d46 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  801c90:	8b 46 04             	mov    0x4(%esi),%eax
  801c93:	2b 06                	sub    (%esi),%eax
  801c95:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  801c9b:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  801ca2:	00 00 00 
	stat->st_dev = &devpipe;
  801ca5:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  801cac:	30 80 00 
	return 0;
}
  801caf:	b8 00 00 00 00       	mov    $0x0,%eax
  801cb4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801cb7:	5b                   	pop    %ebx
  801cb8:	5e                   	pop    %esi
  801cb9:	5d                   	pop    %ebp
  801cba:	c3                   	ret    

00801cbb <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  801cbb:	f3 0f 1e fb          	endbr32 
  801cbf:	55                   	push   %ebp
  801cc0:	89 e5                	mov    %esp,%ebp
  801cc2:	53                   	push   %ebx
  801cc3:	83 ec 0c             	sub    $0xc,%esp
  801cc6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  801cc9:	53                   	push   %ebx
  801cca:	6a 00                	push   $0x0
  801ccc:	e8 4f f5 ff ff       	call   801220 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  801cd1:	89 1c 24             	mov    %ebx,(%esp)
  801cd4:	e8 56 f7 ff ff       	call   80142f <fd2data>
  801cd9:	83 c4 08             	add    $0x8,%esp
  801cdc:	50                   	push   %eax
  801cdd:	6a 00                	push   $0x0
  801cdf:	e8 3c f5 ff ff       	call   801220 <sys_page_unmap>
}
  801ce4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801ce7:	c9                   	leave  
  801ce8:	c3                   	ret    

00801ce9 <_pipeisclosed>:
{
  801ce9:	55                   	push   %ebp
  801cea:	89 e5                	mov    %esp,%ebp
  801cec:	57                   	push   %edi
  801ced:	56                   	push   %esi
  801cee:	53                   	push   %ebx
  801cef:	83 ec 1c             	sub    $0x1c,%esp
  801cf2:	89 c7                	mov    %eax,%edi
  801cf4:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  801cf6:	a1 04 40 80 00       	mov    0x804004,%eax
  801cfb:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  801cfe:	83 ec 0c             	sub    $0xc,%esp
  801d01:	57                   	push   %edi
  801d02:	e8 5d 04 00 00       	call   802164 <pageref>
  801d07:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801d0a:	89 34 24             	mov    %esi,(%esp)
  801d0d:	e8 52 04 00 00       	call   802164 <pageref>
		nn = thisenv->env_runs;
  801d12:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801d18:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  801d1b:	83 c4 10             	add    $0x10,%esp
  801d1e:	39 cb                	cmp    %ecx,%ebx
  801d20:	74 1b                	je     801d3d <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  801d22:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d25:	75 cf                	jne    801cf6 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  801d27:	8b 42 58             	mov    0x58(%edx),%eax
  801d2a:	6a 01                	push   $0x1
  801d2c:	50                   	push   %eax
  801d2d:	53                   	push   %ebx
  801d2e:	68 2a 2c 80 00       	push   $0x802c2a
  801d33:	e8 a4 ea ff ff       	call   8007dc <cprintf>
  801d38:	83 c4 10             	add    $0x10,%esp
  801d3b:	eb b9                	jmp    801cf6 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  801d3d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  801d40:	0f 94 c0             	sete   %al
  801d43:	0f b6 c0             	movzbl %al,%eax
}
  801d46:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801d49:	5b                   	pop    %ebx
  801d4a:	5e                   	pop    %esi
  801d4b:	5f                   	pop    %edi
  801d4c:	5d                   	pop    %ebp
  801d4d:	c3                   	ret    

00801d4e <devpipe_write>:
{
  801d4e:	f3 0f 1e fb          	endbr32 
  801d52:	55                   	push   %ebp
  801d53:	89 e5                	mov    %esp,%ebp
  801d55:	57                   	push   %edi
  801d56:	56                   	push   %esi
  801d57:	53                   	push   %ebx
  801d58:	83 ec 28             	sub    $0x28,%esp
  801d5b:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  801d5e:	56                   	push   %esi
  801d5f:	e8 cb f6 ff ff       	call   80142f <fd2data>
  801d64:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801d66:	83 c4 10             	add    $0x10,%esp
  801d69:	bf 00 00 00 00       	mov    $0x0,%edi
  801d6e:	3b 7d 10             	cmp    0x10(%ebp),%edi
  801d71:	74 4f                	je     801dc2 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  801d73:	8b 43 04             	mov    0x4(%ebx),%eax
  801d76:	8b 0b                	mov    (%ebx),%ecx
  801d78:	8d 51 20             	lea    0x20(%ecx),%edx
  801d7b:	39 d0                	cmp    %edx,%eax
  801d7d:	72 14                	jb     801d93 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  801d7f:	89 da                	mov    %ebx,%edx
  801d81:	89 f0                	mov    %esi,%eax
  801d83:	e8 61 ff ff ff       	call   801ce9 <_pipeisclosed>
  801d88:	85 c0                	test   %eax,%eax
  801d8a:	75 3b                	jne    801dc7 <devpipe_write+0x79>
			sys_yield();
  801d8c:	e8 12 f4 ff ff       	call   8011a3 <sys_yield>
  801d91:	eb e0                	jmp    801d73 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  801d93:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801d96:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  801d9a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  801d9d:	89 c2                	mov    %eax,%edx
  801d9f:	c1 fa 1f             	sar    $0x1f,%edx
  801da2:	89 d1                	mov    %edx,%ecx
  801da4:	c1 e9 1b             	shr    $0x1b,%ecx
  801da7:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  801daa:	83 e2 1f             	and    $0x1f,%edx
  801dad:	29 ca                	sub    %ecx,%edx
  801daf:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  801db3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  801db7:	83 c0 01             	add    $0x1,%eax
  801dba:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  801dbd:	83 c7 01             	add    $0x1,%edi
  801dc0:	eb ac                	jmp    801d6e <devpipe_write+0x20>
	return i;
  801dc2:	8b 45 10             	mov    0x10(%ebp),%eax
  801dc5:	eb 05                	jmp    801dcc <devpipe_write+0x7e>
				return 0;
  801dc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801dcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801dcf:	5b                   	pop    %ebx
  801dd0:	5e                   	pop    %esi
  801dd1:	5f                   	pop    %edi
  801dd2:	5d                   	pop    %ebp
  801dd3:	c3                   	ret    

00801dd4 <devpipe_read>:
{
  801dd4:	f3 0f 1e fb          	endbr32 
  801dd8:	55                   	push   %ebp
  801dd9:	89 e5                	mov    %esp,%ebp
  801ddb:	57                   	push   %edi
  801ddc:	56                   	push   %esi
  801ddd:	53                   	push   %ebx
  801dde:	83 ec 18             	sub    $0x18,%esp
  801de1:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  801de4:	57                   	push   %edi
  801de5:	e8 45 f6 ff ff       	call   80142f <fd2data>
  801dea:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  801dec:	83 c4 10             	add    $0x10,%esp
  801def:	be 00 00 00 00       	mov    $0x0,%esi
  801df4:	3b 75 10             	cmp    0x10(%ebp),%esi
  801df7:	75 14                	jne    801e0d <devpipe_read+0x39>
	return i;
  801df9:	8b 45 10             	mov    0x10(%ebp),%eax
  801dfc:	eb 02                	jmp    801e00 <devpipe_read+0x2c>
				return i;
  801dfe:	89 f0                	mov    %esi,%eax
}
  801e00:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801e03:	5b                   	pop    %ebx
  801e04:	5e                   	pop    %esi
  801e05:	5f                   	pop    %edi
  801e06:	5d                   	pop    %ebp
  801e07:	c3                   	ret    
			sys_yield();
  801e08:	e8 96 f3 ff ff       	call   8011a3 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  801e0d:	8b 03                	mov    (%ebx),%eax
  801e0f:	3b 43 04             	cmp    0x4(%ebx),%eax
  801e12:	75 18                	jne    801e2c <devpipe_read+0x58>
			if (i > 0)
  801e14:	85 f6                	test   %esi,%esi
  801e16:	75 e6                	jne    801dfe <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  801e18:	89 da                	mov    %ebx,%edx
  801e1a:	89 f8                	mov    %edi,%eax
  801e1c:	e8 c8 fe ff ff       	call   801ce9 <_pipeisclosed>
  801e21:	85 c0                	test   %eax,%eax
  801e23:	74 e3                	je     801e08 <devpipe_read+0x34>
				return 0;
  801e25:	b8 00 00 00 00       	mov    $0x0,%eax
  801e2a:	eb d4                	jmp    801e00 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  801e2c:	99                   	cltd   
  801e2d:	c1 ea 1b             	shr    $0x1b,%edx
  801e30:	01 d0                	add    %edx,%eax
  801e32:	83 e0 1f             	and    $0x1f,%eax
  801e35:	29 d0                	sub    %edx,%eax
  801e37:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  801e3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801e3f:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  801e42:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  801e45:	83 c6 01             	add    $0x1,%esi
  801e48:	eb aa                	jmp    801df4 <devpipe_read+0x20>

00801e4a <pipe>:
{
  801e4a:	f3 0f 1e fb          	endbr32 
  801e4e:	55                   	push   %ebp
  801e4f:	89 e5                	mov    %esp,%ebp
  801e51:	56                   	push   %esi
  801e52:	53                   	push   %ebx
  801e53:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  801e56:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801e59:	50                   	push   %eax
  801e5a:	e8 ef f5 ff ff       	call   80144e <fd_alloc>
  801e5f:	89 c3                	mov    %eax,%ebx
  801e61:	83 c4 10             	add    $0x10,%esp
  801e64:	85 c0                	test   %eax,%eax
  801e66:	0f 88 23 01 00 00    	js     801f8f <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801e6c:	83 ec 04             	sub    $0x4,%esp
  801e6f:	68 07 04 00 00       	push   $0x407
  801e74:	ff 75 f4             	pushl  -0xc(%ebp)
  801e77:	6a 00                	push   $0x0
  801e79:	e8 50 f3 ff ff       	call   8011ce <sys_page_alloc>
  801e7e:	89 c3                	mov    %eax,%ebx
  801e80:	83 c4 10             	add    $0x10,%esp
  801e83:	85 c0                	test   %eax,%eax
  801e85:	0f 88 04 01 00 00    	js     801f8f <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  801e8b:	83 ec 0c             	sub    $0xc,%esp
  801e8e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  801e91:	50                   	push   %eax
  801e92:	e8 b7 f5 ff ff       	call   80144e <fd_alloc>
  801e97:	89 c3                	mov    %eax,%ebx
  801e99:	83 c4 10             	add    $0x10,%esp
  801e9c:	85 c0                	test   %eax,%eax
  801e9e:	0f 88 db 00 00 00    	js     801f7f <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ea4:	83 ec 04             	sub    $0x4,%esp
  801ea7:	68 07 04 00 00       	push   $0x407
  801eac:	ff 75 f0             	pushl  -0x10(%ebp)
  801eaf:	6a 00                	push   $0x0
  801eb1:	e8 18 f3 ff ff       	call   8011ce <sys_page_alloc>
  801eb6:	89 c3                	mov    %eax,%ebx
  801eb8:	83 c4 10             	add    $0x10,%esp
  801ebb:	85 c0                	test   %eax,%eax
  801ebd:	0f 88 bc 00 00 00    	js     801f7f <pipe+0x135>
	va = fd2data(fd0);
  801ec3:	83 ec 0c             	sub    $0xc,%esp
  801ec6:	ff 75 f4             	pushl  -0xc(%ebp)
  801ec9:	e8 61 f5 ff ff       	call   80142f <fd2data>
  801ece:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801ed0:	83 c4 0c             	add    $0xc,%esp
  801ed3:	68 07 04 00 00       	push   $0x407
  801ed8:	50                   	push   %eax
  801ed9:	6a 00                	push   $0x0
  801edb:	e8 ee f2 ff ff       	call   8011ce <sys_page_alloc>
  801ee0:	89 c3                	mov    %eax,%ebx
  801ee2:	83 c4 10             	add    $0x10,%esp
  801ee5:	85 c0                	test   %eax,%eax
  801ee7:	0f 88 82 00 00 00    	js     801f6f <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  801eed:	83 ec 0c             	sub    $0xc,%esp
  801ef0:	ff 75 f0             	pushl  -0x10(%ebp)
  801ef3:	e8 37 f5 ff ff       	call   80142f <fd2data>
  801ef8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  801eff:	50                   	push   %eax
  801f00:	6a 00                	push   $0x0
  801f02:	56                   	push   %esi
  801f03:	6a 00                	push   $0x0
  801f05:	e8 ec f2 ff ff       	call   8011f6 <sys_page_map>
  801f0a:	89 c3                	mov    %eax,%ebx
  801f0c:	83 c4 20             	add    $0x20,%esp
  801f0f:	85 c0                	test   %eax,%eax
  801f11:	78 4e                	js     801f61 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  801f13:	a1 24 30 80 00       	mov    0x803024,%eax
  801f18:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f1b:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  801f1d:	8b 55 f4             	mov    -0xc(%ebp),%edx
  801f20:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  801f27:	8b 55 f0             	mov    -0x10(%ebp),%edx
  801f2a:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  801f2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  801f2f:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  801f36:	83 ec 0c             	sub    $0xc,%esp
  801f39:	ff 75 f4             	pushl  -0xc(%ebp)
  801f3c:	e8 da f4 ff ff       	call   80141b <fd2num>
  801f41:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f44:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  801f46:	83 c4 04             	add    $0x4,%esp
  801f49:	ff 75 f0             	pushl  -0x10(%ebp)
  801f4c:	e8 ca f4 ff ff       	call   80141b <fd2num>
  801f51:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801f54:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  801f57:	83 c4 10             	add    $0x10,%esp
  801f5a:	bb 00 00 00 00       	mov    $0x0,%ebx
  801f5f:	eb 2e                	jmp    801f8f <pipe+0x145>
	sys_page_unmap(0, va);
  801f61:	83 ec 08             	sub    $0x8,%esp
  801f64:	56                   	push   %esi
  801f65:	6a 00                	push   $0x0
  801f67:	e8 b4 f2 ff ff       	call   801220 <sys_page_unmap>
  801f6c:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  801f6f:	83 ec 08             	sub    $0x8,%esp
  801f72:	ff 75 f0             	pushl  -0x10(%ebp)
  801f75:	6a 00                	push   $0x0
  801f77:	e8 a4 f2 ff ff       	call   801220 <sys_page_unmap>
  801f7c:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  801f7f:	83 ec 08             	sub    $0x8,%esp
  801f82:	ff 75 f4             	pushl  -0xc(%ebp)
  801f85:	6a 00                	push   $0x0
  801f87:	e8 94 f2 ff ff       	call   801220 <sys_page_unmap>
  801f8c:	83 c4 10             	add    $0x10,%esp
}
  801f8f:	89 d8                	mov    %ebx,%eax
  801f91:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801f94:	5b                   	pop    %ebx
  801f95:	5e                   	pop    %esi
  801f96:	5d                   	pop    %ebp
  801f97:	c3                   	ret    

00801f98 <pipeisclosed>:
{
  801f98:	f3 0f 1e fb          	endbr32 
  801f9c:	55                   	push   %ebp
  801f9d:	89 e5                	mov    %esp,%ebp
  801f9f:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  801fa2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801fa5:	50                   	push   %eax
  801fa6:	ff 75 08             	pushl  0x8(%ebp)
  801fa9:	e8 f6 f4 ff ff       	call   8014a4 <fd_lookup>
  801fae:	83 c4 10             	add    $0x10,%esp
  801fb1:	85 c0                	test   %eax,%eax
  801fb3:	78 18                	js     801fcd <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  801fb5:	83 ec 0c             	sub    $0xc,%esp
  801fb8:	ff 75 f4             	pushl  -0xc(%ebp)
  801fbb:	e8 6f f4 ff ff       	call   80142f <fd2data>
  801fc0:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  801fc2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801fc5:	e8 1f fd ff ff       	call   801ce9 <_pipeisclosed>
  801fca:	83 c4 10             	add    $0x10,%esp
}
  801fcd:	c9                   	leave  
  801fce:	c3                   	ret    

00801fcf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  801fcf:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  801fd3:	b8 00 00 00 00       	mov    $0x0,%eax
  801fd8:	c3                   	ret    

00801fd9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  801fd9:	f3 0f 1e fb          	endbr32 
  801fdd:	55                   	push   %ebp
  801fde:	89 e5                	mov    %esp,%ebp
  801fe0:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  801fe3:	68 42 2c 80 00       	push   $0x802c42
  801fe8:	ff 75 0c             	pushl  0xc(%ebp)
  801feb:	e8 56 ed ff ff       	call   800d46 <strcpy>
	return 0;
}
  801ff0:	b8 00 00 00 00       	mov    $0x0,%eax
  801ff5:	c9                   	leave  
  801ff6:	c3                   	ret    

00801ff7 <devcons_write>:
{
  801ff7:	f3 0f 1e fb          	endbr32 
  801ffb:	55                   	push   %ebp
  801ffc:	89 e5                	mov    %esp,%ebp
  801ffe:	57                   	push   %edi
  801fff:	56                   	push   %esi
  802000:	53                   	push   %ebx
  802001:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  802007:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  80200c:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  802012:	3b 75 10             	cmp    0x10(%ebp),%esi
  802015:	73 31                	jae    802048 <devcons_write+0x51>
		m = n - tot;
  802017:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80201a:	29 f3                	sub    %esi,%ebx
  80201c:	83 fb 7f             	cmp    $0x7f,%ebx
  80201f:	b8 7f 00 00 00       	mov    $0x7f,%eax
  802024:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  802027:	83 ec 04             	sub    $0x4,%esp
  80202a:	53                   	push   %ebx
  80202b:	89 f0                	mov    %esi,%eax
  80202d:	03 45 0c             	add    0xc(%ebp),%eax
  802030:	50                   	push   %eax
  802031:	57                   	push   %edi
  802032:	e8 c7 ee ff ff       	call   800efe <memmove>
		sys_cputs(buf, m);
  802037:	83 c4 08             	add    $0x8,%esp
  80203a:	53                   	push   %ebx
  80203b:	57                   	push   %edi
  80203c:	e8 c2 f0 ff ff       	call   801103 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  802041:	01 de                	add    %ebx,%esi
  802043:	83 c4 10             	add    $0x10,%esp
  802046:	eb ca                	jmp    802012 <devcons_write+0x1b>
}
  802048:	89 f0                	mov    %esi,%eax
  80204a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80204d:	5b                   	pop    %ebx
  80204e:	5e                   	pop    %esi
  80204f:	5f                   	pop    %edi
  802050:	5d                   	pop    %ebp
  802051:	c3                   	ret    

00802052 <devcons_read>:
{
  802052:	f3 0f 1e fb          	endbr32 
  802056:	55                   	push   %ebp
  802057:	89 e5                	mov    %esp,%ebp
  802059:	83 ec 08             	sub    $0x8,%esp
  80205c:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  802061:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  802065:	74 21                	je     802088 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  802067:	e8 c1 f0 ff ff       	call   80112d <sys_cgetc>
  80206c:	85 c0                	test   %eax,%eax
  80206e:	75 07                	jne    802077 <devcons_read+0x25>
		sys_yield();
  802070:	e8 2e f1 ff ff       	call   8011a3 <sys_yield>
  802075:	eb f0                	jmp    802067 <devcons_read+0x15>
	if (c < 0)
  802077:	78 0f                	js     802088 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  802079:	83 f8 04             	cmp    $0x4,%eax
  80207c:	74 0c                	je     80208a <devcons_read+0x38>
	*(char*)vbuf = c;
  80207e:	8b 55 0c             	mov    0xc(%ebp),%edx
  802081:	88 02                	mov    %al,(%edx)
	return 1;
  802083:	b8 01 00 00 00       	mov    $0x1,%eax
}
  802088:	c9                   	leave  
  802089:	c3                   	ret    
		return 0;
  80208a:	b8 00 00 00 00       	mov    $0x0,%eax
  80208f:	eb f7                	jmp    802088 <devcons_read+0x36>

00802091 <cputchar>:
{
  802091:	f3 0f 1e fb          	endbr32 
  802095:	55                   	push   %ebp
  802096:	89 e5                	mov    %esp,%ebp
  802098:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  80209b:	8b 45 08             	mov    0x8(%ebp),%eax
  80209e:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  8020a1:	6a 01                	push   $0x1
  8020a3:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020a6:	50                   	push   %eax
  8020a7:	e8 57 f0 ff ff       	call   801103 <sys_cputs>
}
  8020ac:	83 c4 10             	add    $0x10,%esp
  8020af:	c9                   	leave  
  8020b0:	c3                   	ret    

008020b1 <getchar>:
{
  8020b1:	f3 0f 1e fb          	endbr32 
  8020b5:	55                   	push   %ebp
  8020b6:	89 e5                	mov    %esp,%ebp
  8020b8:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  8020bb:	6a 01                	push   $0x1
  8020bd:	8d 45 f7             	lea    -0x9(%ebp),%eax
  8020c0:	50                   	push   %eax
  8020c1:	6a 00                	push   $0x0
  8020c3:	e8 5f f6 ff ff       	call   801727 <read>
	if (r < 0)
  8020c8:	83 c4 10             	add    $0x10,%esp
  8020cb:	85 c0                	test   %eax,%eax
  8020cd:	78 06                	js     8020d5 <getchar+0x24>
	if (r < 1)
  8020cf:	74 06                	je     8020d7 <getchar+0x26>
	return c;
  8020d1:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  8020d5:	c9                   	leave  
  8020d6:	c3                   	ret    
		return -E_EOF;
  8020d7:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  8020dc:	eb f7                	jmp    8020d5 <getchar+0x24>

008020de <iscons>:
{
  8020de:	f3 0f 1e fb          	endbr32 
  8020e2:	55                   	push   %ebp
  8020e3:	89 e5                	mov    %esp,%ebp
  8020e5:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8020e8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8020eb:	50                   	push   %eax
  8020ec:	ff 75 08             	pushl  0x8(%ebp)
  8020ef:	e8 b0 f3 ff ff       	call   8014a4 <fd_lookup>
  8020f4:	83 c4 10             	add    $0x10,%esp
  8020f7:	85 c0                	test   %eax,%eax
  8020f9:	78 11                	js     80210c <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  8020fb:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8020fe:	8b 15 40 30 80 00    	mov    0x803040,%edx
  802104:	39 10                	cmp    %edx,(%eax)
  802106:	0f 94 c0             	sete   %al
  802109:	0f b6 c0             	movzbl %al,%eax
}
  80210c:	c9                   	leave  
  80210d:	c3                   	ret    

0080210e <opencons>:
{
  80210e:	f3 0f 1e fb          	endbr32 
  802112:	55                   	push   %ebp
  802113:	89 e5                	mov    %esp,%ebp
  802115:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  802118:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80211b:	50                   	push   %eax
  80211c:	e8 2d f3 ff ff       	call   80144e <fd_alloc>
  802121:	83 c4 10             	add    $0x10,%esp
  802124:	85 c0                	test   %eax,%eax
  802126:	78 3a                	js     802162 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  802128:	83 ec 04             	sub    $0x4,%esp
  80212b:	68 07 04 00 00       	push   $0x407
  802130:	ff 75 f4             	pushl  -0xc(%ebp)
  802133:	6a 00                	push   $0x0
  802135:	e8 94 f0 ff ff       	call   8011ce <sys_page_alloc>
  80213a:	83 c4 10             	add    $0x10,%esp
  80213d:	85 c0                	test   %eax,%eax
  80213f:	78 21                	js     802162 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  802141:	8b 45 f4             	mov    -0xc(%ebp),%eax
  802144:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80214a:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80214c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80214f:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  802156:	83 ec 0c             	sub    $0xc,%esp
  802159:	50                   	push   %eax
  80215a:	e8 bc f2 ff ff       	call   80141b <fd2num>
  80215f:	83 c4 10             	add    $0x10,%esp
}
  802162:	c9                   	leave  
  802163:	c3                   	ret    

00802164 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  802164:	f3 0f 1e fb          	endbr32 
  802168:	55                   	push   %ebp
  802169:	89 e5                	mov    %esp,%ebp
  80216b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  80216e:	89 c2                	mov    %eax,%edx
  802170:	c1 ea 16             	shr    $0x16,%edx
  802173:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  80217a:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  80217f:	f6 c1 01             	test   $0x1,%cl
  802182:	74 1c                	je     8021a0 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  802184:	c1 e8 0c             	shr    $0xc,%eax
  802187:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  80218e:	a8 01                	test   $0x1,%al
  802190:	74 0e                	je     8021a0 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  802192:	c1 e8 0c             	shr    $0xc,%eax
  802195:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  80219c:	ef 
  80219d:	0f b7 d2             	movzwl %dx,%edx
}
  8021a0:	89 d0                	mov    %edx,%eax
  8021a2:	5d                   	pop    %ebp
  8021a3:	c3                   	ret    
  8021a4:	66 90                	xchg   %ax,%ax
  8021a6:	66 90                	xchg   %ax,%ax
  8021a8:	66 90                	xchg   %ax,%ax
  8021aa:	66 90                	xchg   %ax,%ax
  8021ac:	66 90                	xchg   %ax,%ax
  8021ae:	66 90                	xchg   %ax,%ax

008021b0 <__udivdi3>:
  8021b0:	f3 0f 1e fb          	endbr32 
  8021b4:	55                   	push   %ebp
  8021b5:	57                   	push   %edi
  8021b6:	56                   	push   %esi
  8021b7:	53                   	push   %ebx
  8021b8:	83 ec 1c             	sub    $0x1c,%esp
  8021bb:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  8021bf:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  8021c3:	8b 74 24 34          	mov    0x34(%esp),%esi
  8021c7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  8021cb:	85 d2                	test   %edx,%edx
  8021cd:	75 19                	jne    8021e8 <__udivdi3+0x38>
  8021cf:	39 f3                	cmp    %esi,%ebx
  8021d1:	76 4d                	jbe    802220 <__udivdi3+0x70>
  8021d3:	31 ff                	xor    %edi,%edi
  8021d5:	89 e8                	mov    %ebp,%eax
  8021d7:	89 f2                	mov    %esi,%edx
  8021d9:	f7 f3                	div    %ebx
  8021db:	89 fa                	mov    %edi,%edx
  8021dd:	83 c4 1c             	add    $0x1c,%esp
  8021e0:	5b                   	pop    %ebx
  8021e1:	5e                   	pop    %esi
  8021e2:	5f                   	pop    %edi
  8021e3:	5d                   	pop    %ebp
  8021e4:	c3                   	ret    
  8021e5:	8d 76 00             	lea    0x0(%esi),%esi
  8021e8:	39 f2                	cmp    %esi,%edx
  8021ea:	76 14                	jbe    802200 <__udivdi3+0x50>
  8021ec:	31 ff                	xor    %edi,%edi
  8021ee:	31 c0                	xor    %eax,%eax
  8021f0:	89 fa                	mov    %edi,%edx
  8021f2:	83 c4 1c             	add    $0x1c,%esp
  8021f5:	5b                   	pop    %ebx
  8021f6:	5e                   	pop    %esi
  8021f7:	5f                   	pop    %edi
  8021f8:	5d                   	pop    %ebp
  8021f9:	c3                   	ret    
  8021fa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802200:	0f bd fa             	bsr    %edx,%edi
  802203:	83 f7 1f             	xor    $0x1f,%edi
  802206:	75 48                	jne    802250 <__udivdi3+0xa0>
  802208:	39 f2                	cmp    %esi,%edx
  80220a:	72 06                	jb     802212 <__udivdi3+0x62>
  80220c:	31 c0                	xor    %eax,%eax
  80220e:	39 eb                	cmp    %ebp,%ebx
  802210:	77 de                	ja     8021f0 <__udivdi3+0x40>
  802212:	b8 01 00 00 00       	mov    $0x1,%eax
  802217:	eb d7                	jmp    8021f0 <__udivdi3+0x40>
  802219:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802220:	89 d9                	mov    %ebx,%ecx
  802222:	85 db                	test   %ebx,%ebx
  802224:	75 0b                	jne    802231 <__udivdi3+0x81>
  802226:	b8 01 00 00 00       	mov    $0x1,%eax
  80222b:	31 d2                	xor    %edx,%edx
  80222d:	f7 f3                	div    %ebx
  80222f:	89 c1                	mov    %eax,%ecx
  802231:	31 d2                	xor    %edx,%edx
  802233:	89 f0                	mov    %esi,%eax
  802235:	f7 f1                	div    %ecx
  802237:	89 c6                	mov    %eax,%esi
  802239:	89 e8                	mov    %ebp,%eax
  80223b:	89 f7                	mov    %esi,%edi
  80223d:	f7 f1                	div    %ecx
  80223f:	89 fa                	mov    %edi,%edx
  802241:	83 c4 1c             	add    $0x1c,%esp
  802244:	5b                   	pop    %ebx
  802245:	5e                   	pop    %esi
  802246:	5f                   	pop    %edi
  802247:	5d                   	pop    %ebp
  802248:	c3                   	ret    
  802249:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802250:	89 f9                	mov    %edi,%ecx
  802252:	b8 20 00 00 00       	mov    $0x20,%eax
  802257:	29 f8                	sub    %edi,%eax
  802259:	d3 e2                	shl    %cl,%edx
  80225b:	89 54 24 08          	mov    %edx,0x8(%esp)
  80225f:	89 c1                	mov    %eax,%ecx
  802261:	89 da                	mov    %ebx,%edx
  802263:	d3 ea                	shr    %cl,%edx
  802265:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802269:	09 d1                	or     %edx,%ecx
  80226b:	89 f2                	mov    %esi,%edx
  80226d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802271:	89 f9                	mov    %edi,%ecx
  802273:	d3 e3                	shl    %cl,%ebx
  802275:	89 c1                	mov    %eax,%ecx
  802277:	d3 ea                	shr    %cl,%edx
  802279:	89 f9                	mov    %edi,%ecx
  80227b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  80227f:	89 eb                	mov    %ebp,%ebx
  802281:	d3 e6                	shl    %cl,%esi
  802283:	89 c1                	mov    %eax,%ecx
  802285:	d3 eb                	shr    %cl,%ebx
  802287:	09 de                	or     %ebx,%esi
  802289:	89 f0                	mov    %esi,%eax
  80228b:	f7 74 24 08          	divl   0x8(%esp)
  80228f:	89 d6                	mov    %edx,%esi
  802291:	89 c3                	mov    %eax,%ebx
  802293:	f7 64 24 0c          	mull   0xc(%esp)
  802297:	39 d6                	cmp    %edx,%esi
  802299:	72 15                	jb     8022b0 <__udivdi3+0x100>
  80229b:	89 f9                	mov    %edi,%ecx
  80229d:	d3 e5                	shl    %cl,%ebp
  80229f:	39 c5                	cmp    %eax,%ebp
  8022a1:	73 04                	jae    8022a7 <__udivdi3+0xf7>
  8022a3:	39 d6                	cmp    %edx,%esi
  8022a5:	74 09                	je     8022b0 <__udivdi3+0x100>
  8022a7:	89 d8                	mov    %ebx,%eax
  8022a9:	31 ff                	xor    %edi,%edi
  8022ab:	e9 40 ff ff ff       	jmp    8021f0 <__udivdi3+0x40>
  8022b0:	8d 43 ff             	lea    -0x1(%ebx),%eax
  8022b3:	31 ff                	xor    %edi,%edi
  8022b5:	e9 36 ff ff ff       	jmp    8021f0 <__udivdi3+0x40>
  8022ba:	66 90                	xchg   %ax,%ax
  8022bc:	66 90                	xchg   %ax,%ax
  8022be:	66 90                	xchg   %ax,%ax

008022c0 <__umoddi3>:
  8022c0:	f3 0f 1e fb          	endbr32 
  8022c4:	55                   	push   %ebp
  8022c5:	57                   	push   %edi
  8022c6:	56                   	push   %esi
  8022c7:	53                   	push   %ebx
  8022c8:	83 ec 1c             	sub    $0x1c,%esp
  8022cb:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  8022cf:	8b 74 24 30          	mov    0x30(%esp),%esi
  8022d3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  8022d7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  8022db:	85 c0                	test   %eax,%eax
  8022dd:	75 19                	jne    8022f8 <__umoddi3+0x38>
  8022df:	39 df                	cmp    %ebx,%edi
  8022e1:	76 5d                	jbe    802340 <__umoddi3+0x80>
  8022e3:	89 f0                	mov    %esi,%eax
  8022e5:	89 da                	mov    %ebx,%edx
  8022e7:	f7 f7                	div    %edi
  8022e9:	89 d0                	mov    %edx,%eax
  8022eb:	31 d2                	xor    %edx,%edx
  8022ed:	83 c4 1c             	add    $0x1c,%esp
  8022f0:	5b                   	pop    %ebx
  8022f1:	5e                   	pop    %esi
  8022f2:	5f                   	pop    %edi
  8022f3:	5d                   	pop    %ebp
  8022f4:	c3                   	ret    
  8022f5:	8d 76 00             	lea    0x0(%esi),%esi
  8022f8:	89 f2                	mov    %esi,%edx
  8022fa:	39 d8                	cmp    %ebx,%eax
  8022fc:	76 12                	jbe    802310 <__umoddi3+0x50>
  8022fe:	89 f0                	mov    %esi,%eax
  802300:	89 da                	mov    %ebx,%edx
  802302:	83 c4 1c             	add    $0x1c,%esp
  802305:	5b                   	pop    %ebx
  802306:	5e                   	pop    %esi
  802307:	5f                   	pop    %edi
  802308:	5d                   	pop    %ebp
  802309:	c3                   	ret    
  80230a:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  802310:	0f bd e8             	bsr    %eax,%ebp
  802313:	83 f5 1f             	xor    $0x1f,%ebp
  802316:	75 50                	jne    802368 <__umoddi3+0xa8>
  802318:	39 d8                	cmp    %ebx,%eax
  80231a:	0f 82 e0 00 00 00    	jb     802400 <__umoddi3+0x140>
  802320:	89 d9                	mov    %ebx,%ecx
  802322:	39 f7                	cmp    %esi,%edi
  802324:	0f 86 d6 00 00 00    	jbe    802400 <__umoddi3+0x140>
  80232a:	89 d0                	mov    %edx,%eax
  80232c:	89 ca                	mov    %ecx,%edx
  80232e:	83 c4 1c             	add    $0x1c,%esp
  802331:	5b                   	pop    %ebx
  802332:	5e                   	pop    %esi
  802333:	5f                   	pop    %edi
  802334:	5d                   	pop    %ebp
  802335:	c3                   	ret    
  802336:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  80233d:	8d 76 00             	lea    0x0(%esi),%esi
  802340:	89 fd                	mov    %edi,%ebp
  802342:	85 ff                	test   %edi,%edi
  802344:	75 0b                	jne    802351 <__umoddi3+0x91>
  802346:	b8 01 00 00 00       	mov    $0x1,%eax
  80234b:	31 d2                	xor    %edx,%edx
  80234d:	f7 f7                	div    %edi
  80234f:	89 c5                	mov    %eax,%ebp
  802351:	89 d8                	mov    %ebx,%eax
  802353:	31 d2                	xor    %edx,%edx
  802355:	f7 f5                	div    %ebp
  802357:	89 f0                	mov    %esi,%eax
  802359:	f7 f5                	div    %ebp
  80235b:	89 d0                	mov    %edx,%eax
  80235d:	31 d2                	xor    %edx,%edx
  80235f:	eb 8c                	jmp    8022ed <__umoddi3+0x2d>
  802361:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  802368:	89 e9                	mov    %ebp,%ecx
  80236a:	ba 20 00 00 00       	mov    $0x20,%edx
  80236f:	29 ea                	sub    %ebp,%edx
  802371:	d3 e0                	shl    %cl,%eax
  802373:	89 44 24 08          	mov    %eax,0x8(%esp)
  802377:	89 d1                	mov    %edx,%ecx
  802379:	89 f8                	mov    %edi,%eax
  80237b:	d3 e8                	shr    %cl,%eax
  80237d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  802381:	89 54 24 04          	mov    %edx,0x4(%esp)
  802385:	8b 54 24 04          	mov    0x4(%esp),%edx
  802389:	09 c1                	or     %eax,%ecx
  80238b:	89 d8                	mov    %ebx,%eax
  80238d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  802391:	89 e9                	mov    %ebp,%ecx
  802393:	d3 e7                	shl    %cl,%edi
  802395:	89 d1                	mov    %edx,%ecx
  802397:	d3 e8                	shr    %cl,%eax
  802399:	89 e9                	mov    %ebp,%ecx
  80239b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  80239f:	d3 e3                	shl    %cl,%ebx
  8023a1:	89 c7                	mov    %eax,%edi
  8023a3:	89 d1                	mov    %edx,%ecx
  8023a5:	89 f0                	mov    %esi,%eax
  8023a7:	d3 e8                	shr    %cl,%eax
  8023a9:	89 e9                	mov    %ebp,%ecx
  8023ab:	89 fa                	mov    %edi,%edx
  8023ad:	d3 e6                	shl    %cl,%esi
  8023af:	09 d8                	or     %ebx,%eax
  8023b1:	f7 74 24 08          	divl   0x8(%esp)
  8023b5:	89 d1                	mov    %edx,%ecx
  8023b7:	89 f3                	mov    %esi,%ebx
  8023b9:	f7 64 24 0c          	mull   0xc(%esp)
  8023bd:	89 c6                	mov    %eax,%esi
  8023bf:	89 d7                	mov    %edx,%edi
  8023c1:	39 d1                	cmp    %edx,%ecx
  8023c3:	72 06                	jb     8023cb <__umoddi3+0x10b>
  8023c5:	75 10                	jne    8023d7 <__umoddi3+0x117>
  8023c7:	39 c3                	cmp    %eax,%ebx
  8023c9:	73 0c                	jae    8023d7 <__umoddi3+0x117>
  8023cb:	2b 44 24 0c          	sub    0xc(%esp),%eax
  8023cf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  8023d3:	89 d7                	mov    %edx,%edi
  8023d5:	89 c6                	mov    %eax,%esi
  8023d7:	89 ca                	mov    %ecx,%edx
  8023d9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  8023de:	29 f3                	sub    %esi,%ebx
  8023e0:	19 fa                	sbb    %edi,%edx
  8023e2:	89 d0                	mov    %edx,%eax
  8023e4:	d3 e0                	shl    %cl,%eax
  8023e6:	89 e9                	mov    %ebp,%ecx
  8023e8:	d3 eb                	shr    %cl,%ebx
  8023ea:	d3 ea                	shr    %cl,%edx
  8023ec:	09 d8                	or     %ebx,%eax
  8023ee:	83 c4 1c             	add    $0x1c,%esp
  8023f1:	5b                   	pop    %ebx
  8023f2:	5e                   	pop    %esi
  8023f3:	5f                   	pop    %edi
  8023f4:	5d                   	pop    %ebp
  8023f5:	c3                   	ret    
  8023f6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  8023fd:	8d 76 00             	lea    0x0(%esi),%esi
  802400:	29 fe                	sub    %edi,%esi
  802402:	19 c3                	sbb    %eax,%ebx
  802404:	89 f2                	mov    %esi,%edx
  802406:	89 d9                	mov    %ebx,%ecx
  802408:	e9 1d ff ff ff       	jmp    80232a <__umoddi3+0x6a>
