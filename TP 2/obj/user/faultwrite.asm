
obj/user/faultwrite.debug:     formato del fichero elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	*(unsigned*)0 = 0;
  800037:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003e:	00 00 00 
}
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	f3 0f 1e fb          	endbr32 
  800046:	55                   	push   %ebp
  800047:	89 e5                	mov    %esp,%ebp
  800049:	56                   	push   %esi
  80004a:	53                   	push   %ebx
  80004b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800051:	e8 19 01 00 00       	call   80016f <sys_getenvid>
	if (id >= 0)
  800056:	85 c0                	test   %eax,%eax
  800058:	78 12                	js     80006c <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  80005a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800062:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800067:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80006c:	85 db                	test   %ebx,%ebx
  80006e:	7e 07                	jle    800077 <libmain+0x35>
		binaryname = argv[0];
  800070:	8b 06                	mov    (%esi),%eax
  800072:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800077:	83 ec 08             	sub    $0x8,%esp
  80007a:	56                   	push   %esi
  80007b:	53                   	push   %ebx
  80007c:	e8 b2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800081:	e8 0a 00 00 00       	call   800090 <exit>
}
  800086:	83 c4 10             	add    $0x10,%esp
  800089:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80008c:	5b                   	pop    %ebx
  80008d:	5e                   	pop    %esi
  80008e:	5d                   	pop    %ebp
  80008f:	c3                   	ret    

00800090 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800090:	f3 0f 1e fb          	endbr32 
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 53 04 00 00       	call   8004f2 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 a0 00 00 00       	call   800149 <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
  8000b4:	83 ec 1c             	sub    $0x1c,%esp
  8000b7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000ba:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000bd:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000bf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000c2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000c5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000c8:	8b 75 14             	mov    0x14(%ebp),%esi
  8000cb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000cd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000d1:	74 04                	je     8000d7 <syscall+0x29>
  8000d3:	85 c0                	test   %eax,%eax
  8000d5:	7f 08                	jg     8000df <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000df:	83 ec 0c             	sub    $0xc,%esp
  8000e2:	50                   	push   %eax
  8000e3:	ff 75 e0             	pushl  -0x20(%ebp)
  8000e6:	68 ca 1d 80 00       	push   $0x801dca
  8000eb:	6a 23                	push   $0x23
  8000ed:	68 e7 1d 80 00       	push   $0x801de7
  8000f2:	e8 51 0f 00 00       	call   801048 <_panic>

008000f7 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000f7:	f3 0f 1e fb          	endbr32 
  8000fb:	55                   	push   %ebp
  8000fc:	89 e5                	mov    %esp,%ebp
  8000fe:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800101:	6a 00                	push   $0x0
  800103:	6a 00                	push   $0x0
  800105:	6a 00                	push   $0x0
  800107:	ff 75 0c             	pushl  0xc(%ebp)
  80010a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80010d:	ba 00 00 00 00       	mov    $0x0,%edx
  800112:	b8 00 00 00 00       	mov    $0x0,%eax
  800117:	e8 92 ff ff ff       	call   8000ae <syscall>
}
  80011c:	83 c4 10             	add    $0x10,%esp
  80011f:	c9                   	leave  
  800120:	c3                   	ret    

00800121 <sys_cgetc>:

int
sys_cgetc(void)
{
  800121:	f3 0f 1e fb          	endbr32 
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80012b:	6a 00                	push   $0x0
  80012d:	6a 00                	push   $0x0
  80012f:	6a 00                	push   $0x0
  800131:	6a 00                	push   $0x0
  800133:	b9 00 00 00 00       	mov    $0x0,%ecx
  800138:	ba 00 00 00 00       	mov    $0x0,%edx
  80013d:	b8 01 00 00 00       	mov    $0x1,%eax
  800142:	e8 67 ff ff ff       	call   8000ae <syscall>
}
  800147:	c9                   	leave  
  800148:	c3                   	ret    

00800149 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800149:	f3 0f 1e fb          	endbr32 
  80014d:	55                   	push   %ebp
  80014e:	89 e5                	mov    %esp,%ebp
  800150:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800153:	6a 00                	push   $0x0
  800155:	6a 00                	push   $0x0
  800157:	6a 00                	push   $0x0
  800159:	6a 00                	push   $0x0
  80015b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80015e:	ba 01 00 00 00       	mov    $0x1,%edx
  800163:	b8 03 00 00 00       	mov    $0x3,%eax
  800168:	e8 41 ff ff ff       	call   8000ae <syscall>
}
  80016d:	c9                   	leave  
  80016e:	c3                   	ret    

0080016f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80016f:	f3 0f 1e fb          	endbr32 
  800173:	55                   	push   %ebp
  800174:	89 e5                	mov    %esp,%ebp
  800176:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800179:	6a 00                	push   $0x0
  80017b:	6a 00                	push   $0x0
  80017d:	6a 00                	push   $0x0
  80017f:	6a 00                	push   $0x0
  800181:	b9 00 00 00 00       	mov    $0x0,%ecx
  800186:	ba 00 00 00 00       	mov    $0x0,%edx
  80018b:	b8 02 00 00 00       	mov    $0x2,%eax
  800190:	e8 19 ff ff ff       	call   8000ae <syscall>
}
  800195:	c9                   	leave  
  800196:	c3                   	ret    

00800197 <sys_yield>:

void
sys_yield(void)
{
  800197:	f3 0f 1e fb          	endbr32 
  80019b:	55                   	push   %ebp
  80019c:	89 e5                	mov    %esp,%ebp
  80019e:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8001a1:	6a 00                	push   $0x0
  8001a3:	6a 00                	push   $0x0
  8001a5:	6a 00                	push   $0x0
  8001a7:	6a 00                	push   $0x0
  8001a9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001ae:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001b8:	e8 f1 fe ff ff       	call   8000ae <syscall>
}
  8001bd:	83 c4 10             	add    $0x10,%esp
  8001c0:	c9                   	leave  
  8001c1:	c3                   	ret    

008001c2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001c2:	f3 0f 1e fb          	endbr32 
  8001c6:	55                   	push   %ebp
  8001c7:	89 e5                	mov    %esp,%ebp
  8001c9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001cc:	6a 00                	push   $0x0
  8001ce:	6a 00                	push   $0x0
  8001d0:	ff 75 10             	pushl  0x10(%ebp)
  8001d3:	ff 75 0c             	pushl  0xc(%ebp)
  8001d6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d9:	ba 01 00 00 00       	mov    $0x1,%edx
  8001de:	b8 04 00 00 00       	mov    $0x4,%eax
  8001e3:	e8 c6 fe ff ff       	call   8000ae <syscall>
}
  8001e8:	c9                   	leave  
  8001e9:	c3                   	ret    

008001ea <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ea:	f3 0f 1e fb          	endbr32 
  8001ee:	55                   	push   %ebp
  8001ef:	89 e5                	mov    %esp,%ebp
  8001f1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001f4:	ff 75 18             	pushl  0x18(%ebp)
  8001f7:	ff 75 14             	pushl  0x14(%ebp)
  8001fa:	ff 75 10             	pushl  0x10(%ebp)
  8001fd:	ff 75 0c             	pushl  0xc(%ebp)
  800200:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800203:	ba 01 00 00 00       	mov    $0x1,%edx
  800208:	b8 05 00 00 00       	mov    $0x5,%eax
  80020d:	e8 9c fe ff ff       	call   8000ae <syscall>
}
  800212:	c9                   	leave  
  800213:	c3                   	ret    

00800214 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800214:	f3 0f 1e fb          	endbr32 
  800218:	55                   	push   %ebp
  800219:	89 e5                	mov    %esp,%ebp
  80021b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80021e:	6a 00                	push   $0x0
  800220:	6a 00                	push   $0x0
  800222:	6a 00                	push   $0x0
  800224:	ff 75 0c             	pushl  0xc(%ebp)
  800227:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80022a:	ba 01 00 00 00       	mov    $0x1,%edx
  80022f:	b8 06 00 00 00       	mov    $0x6,%eax
  800234:	e8 75 fe ff ff       	call   8000ae <syscall>
}
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80023b:	f3 0f 1e fb          	endbr32 
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800245:	6a 00                	push   $0x0
  800247:	6a 00                	push   $0x0
  800249:	6a 00                	push   $0x0
  80024b:	ff 75 0c             	pushl  0xc(%ebp)
  80024e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800251:	ba 01 00 00 00       	mov    $0x1,%edx
  800256:	b8 08 00 00 00       	mov    $0x8,%eax
  80025b:	e8 4e fe ff ff       	call   8000ae <syscall>
}
  800260:	c9                   	leave  
  800261:	c3                   	ret    

00800262 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800262:	f3 0f 1e fb          	endbr32 
  800266:	55                   	push   %ebp
  800267:	89 e5                	mov    %esp,%ebp
  800269:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  80026c:	6a 00                	push   $0x0
  80026e:	6a 00                	push   $0x0
  800270:	6a 00                	push   $0x0
  800272:	ff 75 0c             	pushl  0xc(%ebp)
  800275:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800278:	ba 01 00 00 00       	mov    $0x1,%edx
  80027d:	b8 09 00 00 00       	mov    $0x9,%eax
  800282:	e8 27 fe ff ff       	call   8000ae <syscall>
}
  800287:	c9                   	leave  
  800288:	c3                   	ret    

00800289 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800289:	f3 0f 1e fb          	endbr32 
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  800293:	6a 00                	push   $0x0
  800295:	6a 00                	push   $0x0
  800297:	6a 00                	push   $0x0
  800299:	ff 75 0c             	pushl  0xc(%ebp)
  80029c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029f:	ba 01 00 00 00       	mov    $0x1,%edx
  8002a4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002a9:	e8 00 fe ff ff       	call   8000ae <syscall>
}
  8002ae:	c9                   	leave  
  8002af:	c3                   	ret    

008002b0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b0:	f3 0f 1e fb          	endbr32 
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8002ba:	6a 00                	push   $0x0
  8002bc:	ff 75 14             	pushl  0x14(%ebp)
  8002bf:	ff 75 10             	pushl  0x10(%ebp)
  8002c2:	ff 75 0c             	pushl  0xc(%ebp)
  8002c5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002cd:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002d2:	e8 d7 fd ff ff       	call   8000ae <syscall>
}
  8002d7:	c9                   	leave  
  8002d8:	c3                   	ret    

008002d9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d9:	f3 0f 1e fb          	endbr32 
  8002dd:	55                   	push   %ebp
  8002de:	89 e5                	mov    %esp,%ebp
  8002e0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002e3:	6a 00                	push   $0x0
  8002e5:	6a 00                	push   $0x0
  8002e7:	6a 00                	push   $0x0
  8002e9:	6a 00                	push   $0x0
  8002eb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ee:	ba 01 00 00 00       	mov    $0x1,%edx
  8002f3:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002f8:	e8 b1 fd ff ff       	call   8000ae <syscall>
}
  8002fd:	c9                   	leave  
  8002fe:	c3                   	ret    

008002ff <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8002ff:	f3 0f 1e fb          	endbr32 
  800303:	55                   	push   %ebp
  800304:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800306:	8b 45 08             	mov    0x8(%ebp),%eax
  800309:	05 00 00 00 30       	add    $0x30000000,%eax
  80030e:	c1 e8 0c             	shr    $0xc,%eax
}
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800313:	f3 0f 1e fb          	endbr32 
  800317:	55                   	push   %ebp
  800318:	89 e5                	mov    %esp,%ebp
  80031a:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  80031d:	ff 75 08             	pushl  0x8(%ebp)
  800320:	e8 da ff ff ff       	call   8002ff <fd2num>
  800325:	83 c4 10             	add    $0x10,%esp
  800328:	c1 e0 0c             	shl    $0xc,%eax
  80032b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800330:	c9                   	leave  
  800331:	c3                   	ret    

00800332 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800332:	f3 0f 1e fb          	endbr32 
  800336:	55                   	push   %ebp
  800337:	89 e5                	mov    %esp,%ebp
  800339:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80033e:	89 c2                	mov    %eax,%edx
  800340:	c1 ea 16             	shr    $0x16,%edx
  800343:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80034a:	f6 c2 01             	test   $0x1,%dl
  80034d:	74 2d                	je     80037c <fd_alloc+0x4a>
  80034f:	89 c2                	mov    %eax,%edx
  800351:	c1 ea 0c             	shr    $0xc,%edx
  800354:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80035b:	f6 c2 01             	test   $0x1,%dl
  80035e:	74 1c                	je     80037c <fd_alloc+0x4a>
  800360:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800365:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80036a:	75 d2                	jne    80033e <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80036c:	8b 45 08             	mov    0x8(%ebp),%eax
  80036f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800375:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80037a:	eb 0a                	jmp    800386 <fd_alloc+0x54>
			*fd_store = fd;
  80037c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800381:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800386:	5d                   	pop    %ebp
  800387:	c3                   	ret    

00800388 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800388:	f3 0f 1e fb          	endbr32 
  80038c:	55                   	push   %ebp
  80038d:	89 e5                	mov    %esp,%ebp
  80038f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  800392:	83 f8 1f             	cmp    $0x1f,%eax
  800395:	77 30                	ja     8003c7 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  800397:	c1 e0 0c             	shl    $0xc,%eax
  80039a:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  80039f:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8003a5:	f6 c2 01             	test   $0x1,%dl
  8003a8:	74 24                	je     8003ce <fd_lookup+0x46>
  8003aa:	89 c2                	mov    %eax,%edx
  8003ac:	c1 ea 0c             	shr    $0xc,%edx
  8003af:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003b6:	f6 c2 01             	test   $0x1,%dl
  8003b9:	74 1a                	je     8003d5 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003bb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003be:	89 02                	mov    %eax,(%edx)
	return 0;
  8003c0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003c5:	5d                   	pop    %ebp
  8003c6:	c3                   	ret    
		return -E_INVAL;
  8003c7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003cc:	eb f7                	jmp    8003c5 <fd_lookup+0x3d>
		return -E_INVAL;
  8003ce:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003d3:	eb f0                	jmp    8003c5 <fd_lookup+0x3d>
  8003d5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003da:	eb e9                	jmp    8003c5 <fd_lookup+0x3d>

008003dc <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003dc:	f3 0f 1e fb          	endbr32 
  8003e0:	55                   	push   %ebp
  8003e1:	89 e5                	mov    %esp,%ebp
  8003e3:	83 ec 08             	sub    $0x8,%esp
  8003e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e9:	ba 74 1e 80 00       	mov    $0x801e74,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8003ee:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8003f3:	39 08                	cmp    %ecx,(%eax)
  8003f5:	74 33                	je     80042a <dev_lookup+0x4e>
  8003f7:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8003fa:	8b 02                	mov    (%edx),%eax
  8003fc:	85 c0                	test   %eax,%eax
  8003fe:	75 f3                	jne    8003f3 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800400:	a1 04 40 80 00       	mov    0x804004,%eax
  800405:	8b 40 48             	mov    0x48(%eax),%eax
  800408:	83 ec 04             	sub    $0x4,%esp
  80040b:	51                   	push   %ecx
  80040c:	50                   	push   %eax
  80040d:	68 f8 1d 80 00       	push   $0x801df8
  800412:	e8 18 0d 00 00       	call   80112f <cprintf>
	*dev = 0;
  800417:	8b 45 0c             	mov    0xc(%ebp),%eax
  80041a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800420:	83 c4 10             	add    $0x10,%esp
  800423:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800428:	c9                   	leave  
  800429:	c3                   	ret    
			*dev = devtab[i];
  80042a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80042d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80042f:	b8 00 00 00 00       	mov    $0x0,%eax
  800434:	eb f2                	jmp    800428 <dev_lookup+0x4c>

00800436 <fd_close>:
{
  800436:	f3 0f 1e fb          	endbr32 
  80043a:	55                   	push   %ebp
  80043b:	89 e5                	mov    %esp,%ebp
  80043d:	57                   	push   %edi
  80043e:	56                   	push   %esi
  80043f:	53                   	push   %ebx
  800440:	83 ec 28             	sub    $0x28,%esp
  800443:	8b 75 08             	mov    0x8(%ebp),%esi
  800446:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800449:	56                   	push   %esi
  80044a:	e8 b0 fe ff ff       	call   8002ff <fd2num>
  80044f:	83 c4 08             	add    $0x8,%esp
  800452:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800455:	52                   	push   %edx
  800456:	50                   	push   %eax
  800457:	e8 2c ff ff ff       	call   800388 <fd_lookup>
  80045c:	89 c3                	mov    %eax,%ebx
  80045e:	83 c4 10             	add    $0x10,%esp
  800461:	85 c0                	test   %eax,%eax
  800463:	78 05                	js     80046a <fd_close+0x34>
	    || fd != fd2)
  800465:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800468:	74 16                	je     800480 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80046a:	89 f8                	mov    %edi,%eax
  80046c:	84 c0                	test   %al,%al
  80046e:	b8 00 00 00 00       	mov    $0x0,%eax
  800473:	0f 44 d8             	cmove  %eax,%ebx
}
  800476:	89 d8                	mov    %ebx,%eax
  800478:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80047b:	5b                   	pop    %ebx
  80047c:	5e                   	pop    %esi
  80047d:	5f                   	pop    %edi
  80047e:	5d                   	pop    %ebp
  80047f:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800480:	83 ec 08             	sub    $0x8,%esp
  800483:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800486:	50                   	push   %eax
  800487:	ff 36                	pushl  (%esi)
  800489:	e8 4e ff ff ff       	call   8003dc <dev_lookup>
  80048e:	89 c3                	mov    %eax,%ebx
  800490:	83 c4 10             	add    $0x10,%esp
  800493:	85 c0                	test   %eax,%eax
  800495:	78 1a                	js     8004b1 <fd_close+0x7b>
		if (dev->dev_close)
  800497:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80049a:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  80049d:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8004a2:	85 c0                	test   %eax,%eax
  8004a4:	74 0b                	je     8004b1 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8004a6:	83 ec 0c             	sub    $0xc,%esp
  8004a9:	56                   	push   %esi
  8004aa:	ff d0                	call   *%eax
  8004ac:	89 c3                	mov    %eax,%ebx
  8004ae:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004b1:	83 ec 08             	sub    $0x8,%esp
  8004b4:	56                   	push   %esi
  8004b5:	6a 00                	push   $0x0
  8004b7:	e8 58 fd ff ff       	call   800214 <sys_page_unmap>
	return r;
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	eb b5                	jmp    800476 <fd_close+0x40>

008004c1 <close>:

int
close(int fdnum)
{
  8004c1:	f3 0f 1e fb          	endbr32 
  8004c5:	55                   	push   %ebp
  8004c6:	89 e5                	mov    %esp,%ebp
  8004c8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004cb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004ce:	50                   	push   %eax
  8004cf:	ff 75 08             	pushl  0x8(%ebp)
  8004d2:	e8 b1 fe ff ff       	call   800388 <fd_lookup>
  8004d7:	83 c4 10             	add    $0x10,%esp
  8004da:	85 c0                	test   %eax,%eax
  8004dc:	79 02                	jns    8004e0 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8004de:	c9                   	leave  
  8004df:	c3                   	ret    
		return fd_close(fd, 1);
  8004e0:	83 ec 08             	sub    $0x8,%esp
  8004e3:	6a 01                	push   $0x1
  8004e5:	ff 75 f4             	pushl  -0xc(%ebp)
  8004e8:	e8 49 ff ff ff       	call   800436 <fd_close>
  8004ed:	83 c4 10             	add    $0x10,%esp
  8004f0:	eb ec                	jmp    8004de <close+0x1d>

008004f2 <close_all>:

void
close_all(void)
{
  8004f2:	f3 0f 1e fb          	endbr32 
  8004f6:	55                   	push   %ebp
  8004f7:	89 e5                	mov    %esp,%ebp
  8004f9:	53                   	push   %ebx
  8004fa:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8004fd:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800502:	83 ec 0c             	sub    $0xc,%esp
  800505:	53                   	push   %ebx
  800506:	e8 b6 ff ff ff       	call   8004c1 <close>
	for (i = 0; i < MAXFD; i++)
  80050b:	83 c3 01             	add    $0x1,%ebx
  80050e:	83 c4 10             	add    $0x10,%esp
  800511:	83 fb 20             	cmp    $0x20,%ebx
  800514:	75 ec                	jne    800502 <close_all+0x10>
}
  800516:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800519:	c9                   	leave  
  80051a:	c3                   	ret    

0080051b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80051b:	f3 0f 1e fb          	endbr32 
  80051f:	55                   	push   %ebp
  800520:	89 e5                	mov    %esp,%ebp
  800522:	57                   	push   %edi
  800523:	56                   	push   %esi
  800524:	53                   	push   %ebx
  800525:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800528:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80052b:	50                   	push   %eax
  80052c:	ff 75 08             	pushl  0x8(%ebp)
  80052f:	e8 54 fe ff ff       	call   800388 <fd_lookup>
  800534:	89 c3                	mov    %eax,%ebx
  800536:	83 c4 10             	add    $0x10,%esp
  800539:	85 c0                	test   %eax,%eax
  80053b:	0f 88 81 00 00 00    	js     8005c2 <dup+0xa7>
		return r;
	close(newfdnum);
  800541:	83 ec 0c             	sub    $0xc,%esp
  800544:	ff 75 0c             	pushl  0xc(%ebp)
  800547:	e8 75 ff ff ff       	call   8004c1 <close>

	newfd = INDEX2FD(newfdnum);
  80054c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80054f:	c1 e6 0c             	shl    $0xc,%esi
  800552:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800558:	83 c4 04             	add    $0x4,%esp
  80055b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80055e:	e8 b0 fd ff ff       	call   800313 <fd2data>
  800563:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800565:	89 34 24             	mov    %esi,(%esp)
  800568:	e8 a6 fd ff ff       	call   800313 <fd2data>
  80056d:	83 c4 10             	add    $0x10,%esp
  800570:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800572:	89 d8                	mov    %ebx,%eax
  800574:	c1 e8 16             	shr    $0x16,%eax
  800577:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80057e:	a8 01                	test   $0x1,%al
  800580:	74 11                	je     800593 <dup+0x78>
  800582:	89 d8                	mov    %ebx,%eax
  800584:	c1 e8 0c             	shr    $0xc,%eax
  800587:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80058e:	f6 c2 01             	test   $0x1,%dl
  800591:	75 39                	jne    8005cc <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800593:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  800596:	89 d0                	mov    %edx,%eax
  800598:	c1 e8 0c             	shr    $0xc,%eax
  80059b:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005a2:	83 ec 0c             	sub    $0xc,%esp
  8005a5:	25 07 0e 00 00       	and    $0xe07,%eax
  8005aa:	50                   	push   %eax
  8005ab:	56                   	push   %esi
  8005ac:	6a 00                	push   $0x0
  8005ae:	52                   	push   %edx
  8005af:	6a 00                	push   $0x0
  8005b1:	e8 34 fc ff ff       	call   8001ea <sys_page_map>
  8005b6:	89 c3                	mov    %eax,%ebx
  8005b8:	83 c4 20             	add    $0x20,%esp
  8005bb:	85 c0                	test   %eax,%eax
  8005bd:	78 31                	js     8005f0 <dup+0xd5>
		goto err;

	return newfdnum;
  8005bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005c2:	89 d8                	mov    %ebx,%eax
  8005c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005c7:	5b                   	pop    %ebx
  8005c8:	5e                   	pop    %esi
  8005c9:	5f                   	pop    %edi
  8005ca:	5d                   	pop    %ebp
  8005cb:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005cc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005d3:	83 ec 0c             	sub    $0xc,%esp
  8005d6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005db:	50                   	push   %eax
  8005dc:	57                   	push   %edi
  8005dd:	6a 00                	push   $0x0
  8005df:	53                   	push   %ebx
  8005e0:	6a 00                	push   $0x0
  8005e2:	e8 03 fc ff ff       	call   8001ea <sys_page_map>
  8005e7:	89 c3                	mov    %eax,%ebx
  8005e9:	83 c4 20             	add    $0x20,%esp
  8005ec:	85 c0                	test   %eax,%eax
  8005ee:	79 a3                	jns    800593 <dup+0x78>
	sys_page_unmap(0, newfd);
  8005f0:	83 ec 08             	sub    $0x8,%esp
  8005f3:	56                   	push   %esi
  8005f4:	6a 00                	push   $0x0
  8005f6:	e8 19 fc ff ff       	call   800214 <sys_page_unmap>
	sys_page_unmap(0, nva);
  8005fb:	83 c4 08             	add    $0x8,%esp
  8005fe:	57                   	push   %edi
  8005ff:	6a 00                	push   $0x0
  800601:	e8 0e fc ff ff       	call   800214 <sys_page_unmap>
	return r;
  800606:	83 c4 10             	add    $0x10,%esp
  800609:	eb b7                	jmp    8005c2 <dup+0xa7>

0080060b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80060b:	f3 0f 1e fb          	endbr32 
  80060f:	55                   	push   %ebp
  800610:	89 e5                	mov    %esp,%ebp
  800612:	53                   	push   %ebx
  800613:	83 ec 1c             	sub    $0x1c,%esp
  800616:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800619:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80061c:	50                   	push   %eax
  80061d:	53                   	push   %ebx
  80061e:	e8 65 fd ff ff       	call   800388 <fd_lookup>
  800623:	83 c4 10             	add    $0x10,%esp
  800626:	85 c0                	test   %eax,%eax
  800628:	78 3f                	js     800669 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80062a:	83 ec 08             	sub    $0x8,%esp
  80062d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800630:	50                   	push   %eax
  800631:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800634:	ff 30                	pushl  (%eax)
  800636:	e8 a1 fd ff ff       	call   8003dc <dev_lookup>
  80063b:	83 c4 10             	add    $0x10,%esp
  80063e:	85 c0                	test   %eax,%eax
  800640:	78 27                	js     800669 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800642:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800645:	8b 42 08             	mov    0x8(%edx),%eax
  800648:	83 e0 03             	and    $0x3,%eax
  80064b:	83 f8 01             	cmp    $0x1,%eax
  80064e:	74 1e                	je     80066e <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800650:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800653:	8b 40 08             	mov    0x8(%eax),%eax
  800656:	85 c0                	test   %eax,%eax
  800658:	74 35                	je     80068f <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80065a:	83 ec 04             	sub    $0x4,%esp
  80065d:	ff 75 10             	pushl  0x10(%ebp)
  800660:	ff 75 0c             	pushl  0xc(%ebp)
  800663:	52                   	push   %edx
  800664:	ff d0                	call   *%eax
  800666:	83 c4 10             	add    $0x10,%esp
}
  800669:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80066c:	c9                   	leave  
  80066d:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80066e:	a1 04 40 80 00       	mov    0x804004,%eax
  800673:	8b 40 48             	mov    0x48(%eax),%eax
  800676:	83 ec 04             	sub    $0x4,%esp
  800679:	53                   	push   %ebx
  80067a:	50                   	push   %eax
  80067b:	68 39 1e 80 00       	push   $0x801e39
  800680:	e8 aa 0a 00 00       	call   80112f <cprintf>
		return -E_INVAL;
  800685:	83 c4 10             	add    $0x10,%esp
  800688:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80068d:	eb da                	jmp    800669 <read+0x5e>
		return -E_NOT_SUPP;
  80068f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800694:	eb d3                	jmp    800669 <read+0x5e>

00800696 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  800696:	f3 0f 1e fb          	endbr32 
  80069a:	55                   	push   %ebp
  80069b:	89 e5                	mov    %esp,%ebp
  80069d:	57                   	push   %edi
  80069e:	56                   	push   %esi
  80069f:	53                   	push   %ebx
  8006a0:	83 ec 0c             	sub    $0xc,%esp
  8006a3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006a6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006a9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006ae:	eb 02                	jmp    8006b2 <readn+0x1c>
  8006b0:	01 c3                	add    %eax,%ebx
  8006b2:	39 f3                	cmp    %esi,%ebx
  8006b4:	73 21                	jae    8006d7 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006b6:	83 ec 04             	sub    $0x4,%esp
  8006b9:	89 f0                	mov    %esi,%eax
  8006bb:	29 d8                	sub    %ebx,%eax
  8006bd:	50                   	push   %eax
  8006be:	89 d8                	mov    %ebx,%eax
  8006c0:	03 45 0c             	add    0xc(%ebp),%eax
  8006c3:	50                   	push   %eax
  8006c4:	57                   	push   %edi
  8006c5:	e8 41 ff ff ff       	call   80060b <read>
		if (m < 0)
  8006ca:	83 c4 10             	add    $0x10,%esp
  8006cd:	85 c0                	test   %eax,%eax
  8006cf:	78 04                	js     8006d5 <readn+0x3f>
			return m;
		if (m == 0)
  8006d1:	75 dd                	jne    8006b0 <readn+0x1a>
  8006d3:	eb 02                	jmp    8006d7 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d5:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006d7:	89 d8                	mov    %ebx,%eax
  8006d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006dc:	5b                   	pop    %ebx
  8006dd:	5e                   	pop    %esi
  8006de:	5f                   	pop    %edi
  8006df:	5d                   	pop    %ebp
  8006e0:	c3                   	ret    

008006e1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006e1:	f3 0f 1e fb          	endbr32 
  8006e5:	55                   	push   %ebp
  8006e6:	89 e5                	mov    %esp,%ebp
  8006e8:	53                   	push   %ebx
  8006e9:	83 ec 1c             	sub    $0x1c,%esp
  8006ec:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006ef:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006f2:	50                   	push   %eax
  8006f3:	53                   	push   %ebx
  8006f4:	e8 8f fc ff ff       	call   800388 <fd_lookup>
  8006f9:	83 c4 10             	add    $0x10,%esp
  8006fc:	85 c0                	test   %eax,%eax
  8006fe:	78 3a                	js     80073a <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800700:	83 ec 08             	sub    $0x8,%esp
  800703:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800706:	50                   	push   %eax
  800707:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80070a:	ff 30                	pushl  (%eax)
  80070c:	e8 cb fc ff ff       	call   8003dc <dev_lookup>
  800711:	83 c4 10             	add    $0x10,%esp
  800714:	85 c0                	test   %eax,%eax
  800716:	78 22                	js     80073a <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800718:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80071b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80071f:	74 1e                	je     80073f <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800721:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800724:	8b 52 0c             	mov    0xc(%edx),%edx
  800727:	85 d2                	test   %edx,%edx
  800729:	74 35                	je     800760 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80072b:	83 ec 04             	sub    $0x4,%esp
  80072e:	ff 75 10             	pushl  0x10(%ebp)
  800731:	ff 75 0c             	pushl  0xc(%ebp)
  800734:	50                   	push   %eax
  800735:	ff d2                	call   *%edx
  800737:	83 c4 10             	add    $0x10,%esp
}
  80073a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80073d:	c9                   	leave  
  80073e:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073f:	a1 04 40 80 00       	mov    0x804004,%eax
  800744:	8b 40 48             	mov    0x48(%eax),%eax
  800747:	83 ec 04             	sub    $0x4,%esp
  80074a:	53                   	push   %ebx
  80074b:	50                   	push   %eax
  80074c:	68 55 1e 80 00       	push   $0x801e55
  800751:	e8 d9 09 00 00       	call   80112f <cprintf>
		return -E_INVAL;
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80075e:	eb da                	jmp    80073a <write+0x59>
		return -E_NOT_SUPP;
  800760:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800765:	eb d3                	jmp    80073a <write+0x59>

00800767 <seek>:

int
seek(int fdnum, off_t offset)
{
  800767:	f3 0f 1e fb          	endbr32 
  80076b:	55                   	push   %ebp
  80076c:	89 e5                	mov    %esp,%ebp
  80076e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800771:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800774:	50                   	push   %eax
  800775:	ff 75 08             	pushl  0x8(%ebp)
  800778:	e8 0b fc ff ff       	call   800388 <fd_lookup>
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	85 c0                	test   %eax,%eax
  800782:	78 0e                	js     800792 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  800784:	8b 55 0c             	mov    0xc(%ebp),%edx
  800787:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80078a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80078d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800792:	c9                   	leave  
  800793:	c3                   	ret    

00800794 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  800794:	f3 0f 1e fb          	endbr32 
  800798:	55                   	push   %ebp
  800799:	89 e5                	mov    %esp,%ebp
  80079b:	53                   	push   %ebx
  80079c:	83 ec 1c             	sub    $0x1c,%esp
  80079f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007a2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007a5:	50                   	push   %eax
  8007a6:	53                   	push   %ebx
  8007a7:	e8 dc fb ff ff       	call   800388 <fd_lookup>
  8007ac:	83 c4 10             	add    $0x10,%esp
  8007af:	85 c0                	test   %eax,%eax
  8007b1:	78 37                	js     8007ea <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007b3:	83 ec 08             	sub    $0x8,%esp
  8007b6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007b9:	50                   	push   %eax
  8007ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007bd:	ff 30                	pushl  (%eax)
  8007bf:	e8 18 fc ff ff       	call   8003dc <dev_lookup>
  8007c4:	83 c4 10             	add    $0x10,%esp
  8007c7:	85 c0                	test   %eax,%eax
  8007c9:	78 1f                	js     8007ea <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007cb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ce:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007d2:	74 1b                	je     8007ef <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007d7:	8b 52 18             	mov    0x18(%edx),%edx
  8007da:	85 d2                	test   %edx,%edx
  8007dc:	74 32                	je     800810 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007de:	83 ec 08             	sub    $0x8,%esp
  8007e1:	ff 75 0c             	pushl  0xc(%ebp)
  8007e4:	50                   	push   %eax
  8007e5:	ff d2                	call   *%edx
  8007e7:	83 c4 10             	add    $0x10,%esp
}
  8007ea:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007ed:	c9                   	leave  
  8007ee:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007ef:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f4:	8b 40 48             	mov    0x48(%eax),%eax
  8007f7:	83 ec 04             	sub    $0x4,%esp
  8007fa:	53                   	push   %ebx
  8007fb:	50                   	push   %eax
  8007fc:	68 18 1e 80 00       	push   $0x801e18
  800801:	e8 29 09 00 00       	call   80112f <cprintf>
		return -E_INVAL;
  800806:	83 c4 10             	add    $0x10,%esp
  800809:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80080e:	eb da                	jmp    8007ea <ftruncate+0x56>
		return -E_NOT_SUPP;
  800810:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800815:	eb d3                	jmp    8007ea <ftruncate+0x56>

00800817 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800817:	f3 0f 1e fb          	endbr32 
  80081b:	55                   	push   %ebp
  80081c:	89 e5                	mov    %esp,%ebp
  80081e:	53                   	push   %ebx
  80081f:	83 ec 1c             	sub    $0x1c,%esp
  800822:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800825:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800828:	50                   	push   %eax
  800829:	ff 75 08             	pushl  0x8(%ebp)
  80082c:	e8 57 fb ff ff       	call   800388 <fd_lookup>
  800831:	83 c4 10             	add    $0x10,%esp
  800834:	85 c0                	test   %eax,%eax
  800836:	78 4b                	js     800883 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800838:	83 ec 08             	sub    $0x8,%esp
  80083b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80083e:	50                   	push   %eax
  80083f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800842:	ff 30                	pushl  (%eax)
  800844:	e8 93 fb ff ff       	call   8003dc <dev_lookup>
  800849:	83 c4 10             	add    $0x10,%esp
  80084c:	85 c0                	test   %eax,%eax
  80084e:	78 33                	js     800883 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  800850:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800853:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800857:	74 2f                	je     800888 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800859:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80085c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800863:	00 00 00 
	stat->st_isdir = 0;
  800866:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80086d:	00 00 00 
	stat->st_dev = dev;
  800870:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800876:	83 ec 08             	sub    $0x8,%esp
  800879:	53                   	push   %ebx
  80087a:	ff 75 f0             	pushl  -0x10(%ebp)
  80087d:	ff 50 14             	call   *0x14(%eax)
  800880:	83 c4 10             	add    $0x10,%esp
}
  800883:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800886:	c9                   	leave  
  800887:	c3                   	ret    
		return -E_NOT_SUPP;
  800888:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80088d:	eb f4                	jmp    800883 <fstat+0x6c>

0080088f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80088f:	f3 0f 1e fb          	endbr32 
  800893:	55                   	push   %ebp
  800894:	89 e5                	mov    %esp,%ebp
  800896:	56                   	push   %esi
  800897:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800898:	83 ec 08             	sub    $0x8,%esp
  80089b:	6a 00                	push   $0x0
  80089d:	ff 75 08             	pushl  0x8(%ebp)
  8008a0:	e8 fb 01 00 00       	call   800aa0 <open>
  8008a5:	89 c3                	mov    %eax,%ebx
  8008a7:	83 c4 10             	add    $0x10,%esp
  8008aa:	85 c0                	test   %eax,%eax
  8008ac:	78 1b                	js     8008c9 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8008ae:	83 ec 08             	sub    $0x8,%esp
  8008b1:	ff 75 0c             	pushl  0xc(%ebp)
  8008b4:	50                   	push   %eax
  8008b5:	e8 5d ff ff ff       	call   800817 <fstat>
  8008ba:	89 c6                	mov    %eax,%esi
	close(fd);
  8008bc:	89 1c 24             	mov    %ebx,(%esp)
  8008bf:	e8 fd fb ff ff       	call   8004c1 <close>
	return r;
  8008c4:	83 c4 10             	add    $0x10,%esp
  8008c7:	89 f3                	mov    %esi,%ebx
}
  8008c9:	89 d8                	mov    %ebx,%eax
  8008cb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ce:	5b                   	pop    %ebx
  8008cf:	5e                   	pop    %esi
  8008d0:	5d                   	pop    %ebp
  8008d1:	c3                   	ret    

008008d2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008d2:	55                   	push   %ebp
  8008d3:	89 e5                	mov    %esp,%ebp
  8008d5:	56                   	push   %esi
  8008d6:	53                   	push   %ebx
  8008d7:	89 c6                	mov    %eax,%esi
  8008d9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008db:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008e2:	74 27                	je     80090b <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008e4:	6a 07                	push   $0x7
  8008e6:	68 00 50 80 00       	push   $0x805000
  8008eb:	56                   	push   %esi
  8008ec:	ff 35 00 40 80 00    	pushl  0x804000
  8008f2:	e8 84 11 00 00       	call   801a7b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8008f7:	83 c4 0c             	add    $0xc,%esp
  8008fa:	6a 00                	push   $0x0
  8008fc:	53                   	push   %ebx
  8008fd:	6a 00                	push   $0x0
  8008ff:	e8 09 11 00 00       	call   801a0d <ipc_recv>
}
  800904:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800907:	5b                   	pop    %ebx
  800908:	5e                   	pop    %esi
  800909:	5d                   	pop    %ebp
  80090a:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80090b:	83 ec 0c             	sub    $0xc,%esp
  80090e:	6a 01                	push   $0x1
  800910:	e8 cb 11 00 00       	call   801ae0 <ipc_find_env>
  800915:	a3 00 40 80 00       	mov    %eax,0x804000
  80091a:	83 c4 10             	add    $0x10,%esp
  80091d:	eb c5                	jmp    8008e4 <fsipc+0x12>

0080091f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80091f:	f3 0f 1e fb          	endbr32 
  800923:	55                   	push   %ebp
  800924:	89 e5                	mov    %esp,%ebp
  800926:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800929:	8b 45 08             	mov    0x8(%ebp),%eax
  80092c:	8b 40 0c             	mov    0xc(%eax),%eax
  80092f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800934:	8b 45 0c             	mov    0xc(%ebp),%eax
  800937:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80093c:	ba 00 00 00 00       	mov    $0x0,%edx
  800941:	b8 02 00 00 00       	mov    $0x2,%eax
  800946:	e8 87 ff ff ff       	call   8008d2 <fsipc>
}
  80094b:	c9                   	leave  
  80094c:	c3                   	ret    

0080094d <devfile_flush>:
{
  80094d:	f3 0f 1e fb          	endbr32 
  800951:	55                   	push   %ebp
  800952:	89 e5                	mov    %esp,%ebp
  800954:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800957:	8b 45 08             	mov    0x8(%ebp),%eax
  80095a:	8b 40 0c             	mov    0xc(%eax),%eax
  80095d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800962:	ba 00 00 00 00       	mov    $0x0,%edx
  800967:	b8 06 00 00 00       	mov    $0x6,%eax
  80096c:	e8 61 ff ff ff       	call   8008d2 <fsipc>
}
  800971:	c9                   	leave  
  800972:	c3                   	ret    

00800973 <devfile_stat>:
{
  800973:	f3 0f 1e fb          	endbr32 
  800977:	55                   	push   %ebp
  800978:	89 e5                	mov    %esp,%ebp
  80097a:	53                   	push   %ebx
  80097b:	83 ec 04             	sub    $0x4,%esp
  80097e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800981:	8b 45 08             	mov    0x8(%ebp),%eax
  800984:	8b 40 0c             	mov    0xc(%eax),%eax
  800987:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80098c:	ba 00 00 00 00       	mov    $0x0,%edx
  800991:	b8 05 00 00 00       	mov    $0x5,%eax
  800996:	e8 37 ff ff ff       	call   8008d2 <fsipc>
  80099b:	85 c0                	test   %eax,%eax
  80099d:	78 2c                	js     8009cb <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  80099f:	83 ec 08             	sub    $0x8,%esp
  8009a2:	68 00 50 80 00       	push   $0x805000
  8009a7:	53                   	push   %ebx
  8009a8:	e8 ec 0c 00 00       	call   801699 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009ad:	a1 80 50 80 00       	mov    0x805080,%eax
  8009b2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009b8:	a1 84 50 80 00       	mov    0x805084,%eax
  8009bd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009c3:	83 c4 10             	add    $0x10,%esp
  8009c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009cb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ce:	c9                   	leave  
  8009cf:	c3                   	ret    

008009d0 <devfile_write>:
{
  8009d0:	f3 0f 1e fb          	endbr32 
  8009d4:	55                   	push   %ebp
  8009d5:	89 e5                	mov    %esp,%ebp
  8009d7:	83 ec 0c             	sub    $0xc,%esp
  8009da:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009dd:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e0:	8b 52 0c             	mov    0xc(%edx),%edx
  8009e3:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009e9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009ee:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009f3:	0f 47 c2             	cmova  %edx,%eax
  8009f6:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8009fb:	50                   	push   %eax
  8009fc:	ff 75 0c             	pushl  0xc(%ebp)
  8009ff:	68 08 50 80 00       	push   $0x805008
  800a04:	e8 48 0e 00 00       	call   801851 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a09:	ba 00 00 00 00       	mov    $0x0,%edx
  800a0e:	b8 04 00 00 00       	mov    $0x4,%eax
  800a13:	e8 ba fe ff ff       	call   8008d2 <fsipc>
}
  800a18:	c9                   	leave  
  800a19:	c3                   	ret    

00800a1a <devfile_read>:
{
  800a1a:	f3 0f 1e fb          	endbr32 
  800a1e:	55                   	push   %ebp
  800a1f:	89 e5                	mov    %esp,%ebp
  800a21:	56                   	push   %esi
  800a22:	53                   	push   %ebx
  800a23:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a26:	8b 45 08             	mov    0x8(%ebp),%eax
  800a29:	8b 40 0c             	mov    0xc(%eax),%eax
  800a2c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a31:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a37:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3c:	b8 03 00 00 00       	mov    $0x3,%eax
  800a41:	e8 8c fe ff ff       	call   8008d2 <fsipc>
  800a46:	89 c3                	mov    %eax,%ebx
  800a48:	85 c0                	test   %eax,%eax
  800a4a:	78 1f                	js     800a6b <devfile_read+0x51>
	assert(r <= n);
  800a4c:	39 f0                	cmp    %esi,%eax
  800a4e:	77 24                	ja     800a74 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800a50:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a55:	7f 33                	jg     800a8a <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a57:	83 ec 04             	sub    $0x4,%esp
  800a5a:	50                   	push   %eax
  800a5b:	68 00 50 80 00       	push   $0x805000
  800a60:	ff 75 0c             	pushl  0xc(%ebp)
  800a63:	e8 e9 0d 00 00       	call   801851 <memmove>
	return r;
  800a68:	83 c4 10             	add    $0x10,%esp
}
  800a6b:	89 d8                	mov    %ebx,%eax
  800a6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a70:	5b                   	pop    %ebx
  800a71:	5e                   	pop    %esi
  800a72:	5d                   	pop    %ebp
  800a73:	c3                   	ret    
	assert(r <= n);
  800a74:	68 84 1e 80 00       	push   $0x801e84
  800a79:	68 8b 1e 80 00       	push   $0x801e8b
  800a7e:	6a 7c                	push   $0x7c
  800a80:	68 a0 1e 80 00       	push   $0x801ea0
  800a85:	e8 be 05 00 00       	call   801048 <_panic>
	assert(r <= PGSIZE);
  800a8a:	68 ab 1e 80 00       	push   $0x801eab
  800a8f:	68 8b 1e 80 00       	push   $0x801e8b
  800a94:	6a 7d                	push   $0x7d
  800a96:	68 a0 1e 80 00       	push   $0x801ea0
  800a9b:	e8 a8 05 00 00       	call   801048 <_panic>

00800aa0 <open>:
{
  800aa0:	f3 0f 1e fb          	endbr32 
  800aa4:	55                   	push   %ebp
  800aa5:	89 e5                	mov    %esp,%ebp
  800aa7:	56                   	push   %esi
  800aa8:	53                   	push   %ebx
  800aa9:	83 ec 1c             	sub    $0x1c,%esp
  800aac:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800aaf:	56                   	push   %esi
  800ab0:	e8 a1 0b 00 00       	call   801656 <strlen>
  800ab5:	83 c4 10             	add    $0x10,%esp
  800ab8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800abd:	7f 6c                	jg     800b2b <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800abf:	83 ec 0c             	sub    $0xc,%esp
  800ac2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ac5:	50                   	push   %eax
  800ac6:	e8 67 f8 ff ff       	call   800332 <fd_alloc>
  800acb:	89 c3                	mov    %eax,%ebx
  800acd:	83 c4 10             	add    $0x10,%esp
  800ad0:	85 c0                	test   %eax,%eax
  800ad2:	78 3c                	js     800b10 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800ad4:	83 ec 08             	sub    $0x8,%esp
  800ad7:	56                   	push   %esi
  800ad8:	68 00 50 80 00       	push   $0x805000
  800add:	e8 b7 0b 00 00       	call   801699 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ae2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800ae5:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800aea:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800aed:	b8 01 00 00 00       	mov    $0x1,%eax
  800af2:	e8 db fd ff ff       	call   8008d2 <fsipc>
  800af7:	89 c3                	mov    %eax,%ebx
  800af9:	83 c4 10             	add    $0x10,%esp
  800afc:	85 c0                	test   %eax,%eax
  800afe:	78 19                	js     800b19 <open+0x79>
	return fd2num(fd);
  800b00:	83 ec 0c             	sub    $0xc,%esp
  800b03:	ff 75 f4             	pushl  -0xc(%ebp)
  800b06:	e8 f4 f7 ff ff       	call   8002ff <fd2num>
  800b0b:	89 c3                	mov    %eax,%ebx
  800b0d:	83 c4 10             	add    $0x10,%esp
}
  800b10:	89 d8                	mov    %ebx,%eax
  800b12:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b15:	5b                   	pop    %ebx
  800b16:	5e                   	pop    %esi
  800b17:	5d                   	pop    %ebp
  800b18:	c3                   	ret    
		fd_close(fd, 0);
  800b19:	83 ec 08             	sub    $0x8,%esp
  800b1c:	6a 00                	push   $0x0
  800b1e:	ff 75 f4             	pushl  -0xc(%ebp)
  800b21:	e8 10 f9 ff ff       	call   800436 <fd_close>
		return r;
  800b26:	83 c4 10             	add    $0x10,%esp
  800b29:	eb e5                	jmp    800b10 <open+0x70>
		return -E_BAD_PATH;
  800b2b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b30:	eb de                	jmp    800b10 <open+0x70>

00800b32 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b32:	f3 0f 1e fb          	endbr32 
  800b36:	55                   	push   %ebp
  800b37:	89 e5                	mov    %esp,%ebp
  800b39:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b41:	b8 08 00 00 00       	mov    $0x8,%eax
  800b46:	e8 87 fd ff ff       	call   8008d2 <fsipc>
}
  800b4b:	c9                   	leave  
  800b4c:	c3                   	ret    

00800b4d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b4d:	f3 0f 1e fb          	endbr32 
  800b51:	55                   	push   %ebp
  800b52:	89 e5                	mov    %esp,%ebp
  800b54:	56                   	push   %esi
  800b55:	53                   	push   %ebx
  800b56:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b59:	83 ec 0c             	sub    $0xc,%esp
  800b5c:	ff 75 08             	pushl  0x8(%ebp)
  800b5f:	e8 af f7 ff ff       	call   800313 <fd2data>
  800b64:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b66:	83 c4 08             	add    $0x8,%esp
  800b69:	68 b7 1e 80 00       	push   $0x801eb7
  800b6e:	53                   	push   %ebx
  800b6f:	e8 25 0b 00 00       	call   801699 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b74:	8b 46 04             	mov    0x4(%esi),%eax
  800b77:	2b 06                	sub    (%esi),%eax
  800b79:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b7f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b86:	00 00 00 
	stat->st_dev = &devpipe;
  800b89:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b90:	30 80 00 
	return 0;
}
  800b93:	b8 00 00 00 00       	mov    $0x0,%eax
  800b98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b9b:	5b                   	pop    %ebx
  800b9c:	5e                   	pop    %esi
  800b9d:	5d                   	pop    %ebp
  800b9e:	c3                   	ret    

00800b9f <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b9f:	f3 0f 1e fb          	endbr32 
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
  800ba6:	53                   	push   %ebx
  800ba7:	83 ec 0c             	sub    $0xc,%esp
  800baa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bad:	53                   	push   %ebx
  800bae:	6a 00                	push   $0x0
  800bb0:	e8 5f f6 ff ff       	call   800214 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bb5:	89 1c 24             	mov    %ebx,(%esp)
  800bb8:	e8 56 f7 ff ff       	call   800313 <fd2data>
  800bbd:	83 c4 08             	add    $0x8,%esp
  800bc0:	50                   	push   %eax
  800bc1:	6a 00                	push   $0x0
  800bc3:	e8 4c f6 ff ff       	call   800214 <sys_page_unmap>
}
  800bc8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bcb:	c9                   	leave  
  800bcc:	c3                   	ret    

00800bcd <_pipeisclosed>:
{
  800bcd:	55                   	push   %ebp
  800bce:	89 e5                	mov    %esp,%ebp
  800bd0:	57                   	push   %edi
  800bd1:	56                   	push   %esi
  800bd2:	53                   	push   %ebx
  800bd3:	83 ec 1c             	sub    $0x1c,%esp
  800bd6:	89 c7                	mov    %eax,%edi
  800bd8:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bda:	a1 04 40 80 00       	mov    0x804004,%eax
  800bdf:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800be2:	83 ec 0c             	sub    $0xc,%esp
  800be5:	57                   	push   %edi
  800be6:	e8 32 0f 00 00       	call   801b1d <pageref>
  800beb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bee:	89 34 24             	mov    %esi,(%esp)
  800bf1:	e8 27 0f 00 00       	call   801b1d <pageref>
		nn = thisenv->env_runs;
  800bf6:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bfc:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bff:	83 c4 10             	add    $0x10,%esp
  800c02:	39 cb                	cmp    %ecx,%ebx
  800c04:	74 1b                	je     800c21 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c06:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c09:	75 cf                	jne    800bda <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c0b:	8b 42 58             	mov    0x58(%edx),%eax
  800c0e:	6a 01                	push   $0x1
  800c10:	50                   	push   %eax
  800c11:	53                   	push   %ebx
  800c12:	68 be 1e 80 00       	push   $0x801ebe
  800c17:	e8 13 05 00 00       	call   80112f <cprintf>
  800c1c:	83 c4 10             	add    $0x10,%esp
  800c1f:	eb b9                	jmp    800bda <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c21:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c24:	0f 94 c0             	sete   %al
  800c27:	0f b6 c0             	movzbl %al,%eax
}
  800c2a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2d:	5b                   	pop    %ebx
  800c2e:	5e                   	pop    %esi
  800c2f:	5f                   	pop    %edi
  800c30:	5d                   	pop    %ebp
  800c31:	c3                   	ret    

00800c32 <devpipe_write>:
{
  800c32:	f3 0f 1e fb          	endbr32 
  800c36:	55                   	push   %ebp
  800c37:	89 e5                	mov    %esp,%ebp
  800c39:	57                   	push   %edi
  800c3a:	56                   	push   %esi
  800c3b:	53                   	push   %ebx
  800c3c:	83 ec 28             	sub    $0x28,%esp
  800c3f:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c42:	56                   	push   %esi
  800c43:	e8 cb f6 ff ff       	call   800313 <fd2data>
  800c48:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c4a:	83 c4 10             	add    $0x10,%esp
  800c4d:	bf 00 00 00 00       	mov    $0x0,%edi
  800c52:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c55:	74 4f                	je     800ca6 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c57:	8b 43 04             	mov    0x4(%ebx),%eax
  800c5a:	8b 0b                	mov    (%ebx),%ecx
  800c5c:	8d 51 20             	lea    0x20(%ecx),%edx
  800c5f:	39 d0                	cmp    %edx,%eax
  800c61:	72 14                	jb     800c77 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800c63:	89 da                	mov    %ebx,%edx
  800c65:	89 f0                	mov    %esi,%eax
  800c67:	e8 61 ff ff ff       	call   800bcd <_pipeisclosed>
  800c6c:	85 c0                	test   %eax,%eax
  800c6e:	75 3b                	jne    800cab <devpipe_write+0x79>
			sys_yield();
  800c70:	e8 22 f5 ff ff       	call   800197 <sys_yield>
  800c75:	eb e0                	jmp    800c57 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c77:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c7e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c81:	89 c2                	mov    %eax,%edx
  800c83:	c1 fa 1f             	sar    $0x1f,%edx
  800c86:	89 d1                	mov    %edx,%ecx
  800c88:	c1 e9 1b             	shr    $0x1b,%ecx
  800c8b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c8e:	83 e2 1f             	and    $0x1f,%edx
  800c91:	29 ca                	sub    %ecx,%edx
  800c93:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c97:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c9b:	83 c0 01             	add    $0x1,%eax
  800c9e:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800ca1:	83 c7 01             	add    $0x1,%edi
  800ca4:	eb ac                	jmp    800c52 <devpipe_write+0x20>
	return i;
  800ca6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca9:	eb 05                	jmp    800cb0 <devpipe_write+0x7e>
				return 0;
  800cab:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cb0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb3:	5b                   	pop    %ebx
  800cb4:	5e                   	pop    %esi
  800cb5:	5f                   	pop    %edi
  800cb6:	5d                   	pop    %ebp
  800cb7:	c3                   	ret    

00800cb8 <devpipe_read>:
{
  800cb8:	f3 0f 1e fb          	endbr32 
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	83 ec 18             	sub    $0x18,%esp
  800cc5:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800cc8:	57                   	push   %edi
  800cc9:	e8 45 f6 ff ff       	call   800313 <fd2data>
  800cce:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cd0:	83 c4 10             	add    $0x10,%esp
  800cd3:	be 00 00 00 00       	mov    $0x0,%esi
  800cd8:	3b 75 10             	cmp    0x10(%ebp),%esi
  800cdb:	75 14                	jne    800cf1 <devpipe_read+0x39>
	return i;
  800cdd:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce0:	eb 02                	jmp    800ce4 <devpipe_read+0x2c>
				return i;
  800ce2:	89 f0                	mov    %esi,%eax
}
  800ce4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800ce7:	5b                   	pop    %ebx
  800ce8:	5e                   	pop    %esi
  800ce9:	5f                   	pop    %edi
  800cea:	5d                   	pop    %ebp
  800ceb:	c3                   	ret    
			sys_yield();
  800cec:	e8 a6 f4 ff ff       	call   800197 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800cf1:	8b 03                	mov    (%ebx),%eax
  800cf3:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cf6:	75 18                	jne    800d10 <devpipe_read+0x58>
			if (i > 0)
  800cf8:	85 f6                	test   %esi,%esi
  800cfa:	75 e6                	jne    800ce2 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800cfc:	89 da                	mov    %ebx,%edx
  800cfe:	89 f8                	mov    %edi,%eax
  800d00:	e8 c8 fe ff ff       	call   800bcd <_pipeisclosed>
  800d05:	85 c0                	test   %eax,%eax
  800d07:	74 e3                	je     800cec <devpipe_read+0x34>
				return 0;
  800d09:	b8 00 00 00 00       	mov    $0x0,%eax
  800d0e:	eb d4                	jmp    800ce4 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d10:	99                   	cltd   
  800d11:	c1 ea 1b             	shr    $0x1b,%edx
  800d14:	01 d0                	add    %edx,%eax
  800d16:	83 e0 1f             	and    $0x1f,%eax
  800d19:	29 d0                	sub    %edx,%eax
  800d1b:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d23:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d26:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d29:	83 c6 01             	add    $0x1,%esi
  800d2c:	eb aa                	jmp    800cd8 <devpipe_read+0x20>

00800d2e <pipe>:
{
  800d2e:	f3 0f 1e fb          	endbr32 
  800d32:	55                   	push   %ebp
  800d33:	89 e5                	mov    %esp,%ebp
  800d35:	56                   	push   %esi
  800d36:	53                   	push   %ebx
  800d37:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d3a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d3d:	50                   	push   %eax
  800d3e:	e8 ef f5 ff ff       	call   800332 <fd_alloc>
  800d43:	89 c3                	mov    %eax,%ebx
  800d45:	83 c4 10             	add    $0x10,%esp
  800d48:	85 c0                	test   %eax,%eax
  800d4a:	0f 88 23 01 00 00    	js     800e73 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d50:	83 ec 04             	sub    $0x4,%esp
  800d53:	68 07 04 00 00       	push   $0x407
  800d58:	ff 75 f4             	pushl  -0xc(%ebp)
  800d5b:	6a 00                	push   $0x0
  800d5d:	e8 60 f4 ff ff       	call   8001c2 <sys_page_alloc>
  800d62:	89 c3                	mov    %eax,%ebx
  800d64:	83 c4 10             	add    $0x10,%esp
  800d67:	85 c0                	test   %eax,%eax
  800d69:	0f 88 04 01 00 00    	js     800e73 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800d6f:	83 ec 0c             	sub    $0xc,%esp
  800d72:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d75:	50                   	push   %eax
  800d76:	e8 b7 f5 ff ff       	call   800332 <fd_alloc>
  800d7b:	89 c3                	mov    %eax,%ebx
  800d7d:	83 c4 10             	add    $0x10,%esp
  800d80:	85 c0                	test   %eax,%eax
  800d82:	0f 88 db 00 00 00    	js     800e63 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d88:	83 ec 04             	sub    $0x4,%esp
  800d8b:	68 07 04 00 00       	push   $0x407
  800d90:	ff 75 f0             	pushl  -0x10(%ebp)
  800d93:	6a 00                	push   $0x0
  800d95:	e8 28 f4 ff ff       	call   8001c2 <sys_page_alloc>
  800d9a:	89 c3                	mov    %eax,%ebx
  800d9c:	83 c4 10             	add    $0x10,%esp
  800d9f:	85 c0                	test   %eax,%eax
  800da1:	0f 88 bc 00 00 00    	js     800e63 <pipe+0x135>
	va = fd2data(fd0);
  800da7:	83 ec 0c             	sub    $0xc,%esp
  800daa:	ff 75 f4             	pushl  -0xc(%ebp)
  800dad:	e8 61 f5 ff ff       	call   800313 <fd2data>
  800db2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db4:	83 c4 0c             	add    $0xc,%esp
  800db7:	68 07 04 00 00       	push   $0x407
  800dbc:	50                   	push   %eax
  800dbd:	6a 00                	push   $0x0
  800dbf:	e8 fe f3 ff ff       	call   8001c2 <sys_page_alloc>
  800dc4:	89 c3                	mov    %eax,%ebx
  800dc6:	83 c4 10             	add    $0x10,%esp
  800dc9:	85 c0                	test   %eax,%eax
  800dcb:	0f 88 82 00 00 00    	js     800e53 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd1:	83 ec 0c             	sub    $0xc,%esp
  800dd4:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd7:	e8 37 f5 ff ff       	call   800313 <fd2data>
  800ddc:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800de3:	50                   	push   %eax
  800de4:	6a 00                	push   $0x0
  800de6:	56                   	push   %esi
  800de7:	6a 00                	push   $0x0
  800de9:	e8 fc f3 ff ff       	call   8001ea <sys_page_map>
  800dee:	89 c3                	mov    %eax,%ebx
  800df0:	83 c4 20             	add    $0x20,%esp
  800df3:	85 c0                	test   %eax,%eax
  800df5:	78 4e                	js     800e45 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800df7:	a1 20 30 80 00       	mov    0x803020,%eax
  800dfc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800dff:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e01:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e04:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e0b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e0e:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e10:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e13:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e1a:	83 ec 0c             	sub    $0xc,%esp
  800e1d:	ff 75 f4             	pushl  -0xc(%ebp)
  800e20:	e8 da f4 ff ff       	call   8002ff <fd2num>
  800e25:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e28:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e2a:	83 c4 04             	add    $0x4,%esp
  800e2d:	ff 75 f0             	pushl  -0x10(%ebp)
  800e30:	e8 ca f4 ff ff       	call   8002ff <fd2num>
  800e35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e38:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e3b:	83 c4 10             	add    $0x10,%esp
  800e3e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e43:	eb 2e                	jmp    800e73 <pipe+0x145>
	sys_page_unmap(0, va);
  800e45:	83 ec 08             	sub    $0x8,%esp
  800e48:	56                   	push   %esi
  800e49:	6a 00                	push   $0x0
  800e4b:	e8 c4 f3 ff ff       	call   800214 <sys_page_unmap>
  800e50:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e53:	83 ec 08             	sub    $0x8,%esp
  800e56:	ff 75 f0             	pushl  -0x10(%ebp)
  800e59:	6a 00                	push   $0x0
  800e5b:	e8 b4 f3 ff ff       	call   800214 <sys_page_unmap>
  800e60:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800e63:	83 ec 08             	sub    $0x8,%esp
  800e66:	ff 75 f4             	pushl  -0xc(%ebp)
  800e69:	6a 00                	push   $0x0
  800e6b:	e8 a4 f3 ff ff       	call   800214 <sys_page_unmap>
  800e70:	83 c4 10             	add    $0x10,%esp
}
  800e73:	89 d8                	mov    %ebx,%eax
  800e75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e78:	5b                   	pop    %ebx
  800e79:	5e                   	pop    %esi
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <pipeisclosed>:
{
  800e7c:	f3 0f 1e fb          	endbr32 
  800e80:	55                   	push   %ebp
  800e81:	89 e5                	mov    %esp,%ebp
  800e83:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e86:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e89:	50                   	push   %eax
  800e8a:	ff 75 08             	pushl  0x8(%ebp)
  800e8d:	e8 f6 f4 ff ff       	call   800388 <fd_lookup>
  800e92:	83 c4 10             	add    $0x10,%esp
  800e95:	85 c0                	test   %eax,%eax
  800e97:	78 18                	js     800eb1 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800e99:	83 ec 0c             	sub    $0xc,%esp
  800e9c:	ff 75 f4             	pushl  -0xc(%ebp)
  800e9f:	e8 6f f4 ff ff       	call   800313 <fd2data>
  800ea4:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800ea6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ea9:	e8 1f fd ff ff       	call   800bcd <_pipeisclosed>
  800eae:	83 c4 10             	add    $0x10,%esp
}
  800eb1:	c9                   	leave  
  800eb2:	c3                   	ret    

00800eb3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eb3:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800eb7:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebc:	c3                   	ret    

00800ebd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ebd:	f3 0f 1e fb          	endbr32 
  800ec1:	55                   	push   %ebp
  800ec2:	89 e5                	mov    %esp,%ebp
  800ec4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ec7:	68 d6 1e 80 00       	push   $0x801ed6
  800ecc:	ff 75 0c             	pushl  0xc(%ebp)
  800ecf:	e8 c5 07 00 00       	call   801699 <strcpy>
	return 0;
}
  800ed4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed9:	c9                   	leave  
  800eda:	c3                   	ret    

00800edb <devcons_write>:
{
  800edb:	f3 0f 1e fb          	endbr32 
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	57                   	push   %edi
  800ee3:	56                   	push   %esi
  800ee4:	53                   	push   %ebx
  800ee5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800eeb:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800ef0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800ef6:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ef9:	73 31                	jae    800f2c <devcons_write+0x51>
		m = n - tot;
  800efb:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800efe:	29 f3                	sub    %esi,%ebx
  800f00:	83 fb 7f             	cmp    $0x7f,%ebx
  800f03:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f08:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f0b:	83 ec 04             	sub    $0x4,%esp
  800f0e:	53                   	push   %ebx
  800f0f:	89 f0                	mov    %esi,%eax
  800f11:	03 45 0c             	add    0xc(%ebp),%eax
  800f14:	50                   	push   %eax
  800f15:	57                   	push   %edi
  800f16:	e8 36 09 00 00       	call   801851 <memmove>
		sys_cputs(buf, m);
  800f1b:	83 c4 08             	add    $0x8,%esp
  800f1e:	53                   	push   %ebx
  800f1f:	57                   	push   %edi
  800f20:	e8 d2 f1 ff ff       	call   8000f7 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f25:	01 de                	add    %ebx,%esi
  800f27:	83 c4 10             	add    $0x10,%esp
  800f2a:	eb ca                	jmp    800ef6 <devcons_write+0x1b>
}
  800f2c:	89 f0                	mov    %esi,%eax
  800f2e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f31:	5b                   	pop    %ebx
  800f32:	5e                   	pop    %esi
  800f33:	5f                   	pop    %edi
  800f34:	5d                   	pop    %ebp
  800f35:	c3                   	ret    

00800f36 <devcons_read>:
{
  800f36:	f3 0f 1e fb          	endbr32 
  800f3a:	55                   	push   %ebp
  800f3b:	89 e5                	mov    %esp,%ebp
  800f3d:	83 ec 08             	sub    $0x8,%esp
  800f40:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f45:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f49:	74 21                	je     800f6c <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800f4b:	e8 d1 f1 ff ff       	call   800121 <sys_cgetc>
  800f50:	85 c0                	test   %eax,%eax
  800f52:	75 07                	jne    800f5b <devcons_read+0x25>
		sys_yield();
  800f54:	e8 3e f2 ff ff       	call   800197 <sys_yield>
  800f59:	eb f0                	jmp    800f4b <devcons_read+0x15>
	if (c < 0)
  800f5b:	78 0f                	js     800f6c <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800f5d:	83 f8 04             	cmp    $0x4,%eax
  800f60:	74 0c                	je     800f6e <devcons_read+0x38>
	*(char*)vbuf = c;
  800f62:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f65:	88 02                	mov    %al,(%edx)
	return 1;
  800f67:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800f6c:	c9                   	leave  
  800f6d:	c3                   	ret    
		return 0;
  800f6e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f73:	eb f7                	jmp    800f6c <devcons_read+0x36>

00800f75 <cputchar>:
{
  800f75:	f3 0f 1e fb          	endbr32 
  800f79:	55                   	push   %ebp
  800f7a:	89 e5                	mov    %esp,%ebp
  800f7c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f7f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f82:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f85:	6a 01                	push   $0x1
  800f87:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f8a:	50                   	push   %eax
  800f8b:	e8 67 f1 ff ff       	call   8000f7 <sys_cputs>
}
  800f90:	83 c4 10             	add    $0x10,%esp
  800f93:	c9                   	leave  
  800f94:	c3                   	ret    

00800f95 <getchar>:
{
  800f95:	f3 0f 1e fb          	endbr32 
  800f99:	55                   	push   %ebp
  800f9a:	89 e5                	mov    %esp,%ebp
  800f9c:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f9f:	6a 01                	push   $0x1
  800fa1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fa4:	50                   	push   %eax
  800fa5:	6a 00                	push   $0x0
  800fa7:	e8 5f f6 ff ff       	call   80060b <read>
	if (r < 0)
  800fac:	83 c4 10             	add    $0x10,%esp
  800faf:	85 c0                	test   %eax,%eax
  800fb1:	78 06                	js     800fb9 <getchar+0x24>
	if (r < 1)
  800fb3:	74 06                	je     800fbb <getchar+0x26>
	return c;
  800fb5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800fb9:	c9                   	leave  
  800fba:	c3                   	ret    
		return -E_EOF;
  800fbb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800fc0:	eb f7                	jmp    800fb9 <getchar+0x24>

00800fc2 <iscons>:
{
  800fc2:	f3 0f 1e fb          	endbr32 
  800fc6:	55                   	push   %ebp
  800fc7:	89 e5                	mov    %esp,%ebp
  800fc9:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fcc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fcf:	50                   	push   %eax
  800fd0:	ff 75 08             	pushl  0x8(%ebp)
  800fd3:	e8 b0 f3 ff ff       	call   800388 <fd_lookup>
  800fd8:	83 c4 10             	add    $0x10,%esp
  800fdb:	85 c0                	test   %eax,%eax
  800fdd:	78 11                	js     800ff0 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  800fdf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fe2:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fe8:	39 10                	cmp    %edx,(%eax)
  800fea:	0f 94 c0             	sete   %al
  800fed:	0f b6 c0             	movzbl %al,%eax
}
  800ff0:	c9                   	leave  
  800ff1:	c3                   	ret    

00800ff2 <opencons>:
{
  800ff2:	f3 0f 1e fb          	endbr32 
  800ff6:	55                   	push   %ebp
  800ff7:	89 e5                	mov    %esp,%ebp
  800ff9:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800ffc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fff:	50                   	push   %eax
  801000:	e8 2d f3 ff ff       	call   800332 <fd_alloc>
  801005:	83 c4 10             	add    $0x10,%esp
  801008:	85 c0                	test   %eax,%eax
  80100a:	78 3a                	js     801046 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80100c:	83 ec 04             	sub    $0x4,%esp
  80100f:	68 07 04 00 00       	push   $0x407
  801014:	ff 75 f4             	pushl  -0xc(%ebp)
  801017:	6a 00                	push   $0x0
  801019:	e8 a4 f1 ff ff       	call   8001c2 <sys_page_alloc>
  80101e:	83 c4 10             	add    $0x10,%esp
  801021:	85 c0                	test   %eax,%eax
  801023:	78 21                	js     801046 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801025:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801028:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80102e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801030:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801033:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80103a:	83 ec 0c             	sub    $0xc,%esp
  80103d:	50                   	push   %eax
  80103e:	e8 bc f2 ff ff       	call   8002ff <fd2num>
  801043:	83 c4 10             	add    $0x10,%esp
}
  801046:	c9                   	leave  
  801047:	c3                   	ret    

00801048 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801048:	f3 0f 1e fb          	endbr32 
  80104c:	55                   	push   %ebp
  80104d:	89 e5                	mov    %esp,%ebp
  80104f:	56                   	push   %esi
  801050:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801051:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801054:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80105a:	e8 10 f1 ff ff       	call   80016f <sys_getenvid>
  80105f:	83 ec 0c             	sub    $0xc,%esp
  801062:	ff 75 0c             	pushl  0xc(%ebp)
  801065:	ff 75 08             	pushl  0x8(%ebp)
  801068:	56                   	push   %esi
  801069:	50                   	push   %eax
  80106a:	68 e4 1e 80 00       	push   $0x801ee4
  80106f:	e8 bb 00 00 00       	call   80112f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801074:	83 c4 18             	add    $0x18,%esp
  801077:	53                   	push   %ebx
  801078:	ff 75 10             	pushl  0x10(%ebp)
  80107b:	e8 5a 00 00 00       	call   8010da <vcprintf>
	cprintf("\n");
  801080:	c7 04 24 cf 1e 80 00 	movl   $0x801ecf,(%esp)
  801087:	e8 a3 00 00 00       	call   80112f <cprintf>
  80108c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80108f:	cc                   	int3   
  801090:	eb fd                	jmp    80108f <_panic+0x47>

00801092 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801092:	f3 0f 1e fb          	endbr32 
  801096:	55                   	push   %ebp
  801097:	89 e5                	mov    %esp,%ebp
  801099:	53                   	push   %ebx
  80109a:	83 ec 04             	sub    $0x4,%esp
  80109d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010a0:	8b 13                	mov    (%ebx),%edx
  8010a2:	8d 42 01             	lea    0x1(%edx),%eax
  8010a5:	89 03                	mov    %eax,(%ebx)
  8010a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010aa:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010ae:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010b3:	74 09                	je     8010be <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8010b5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010bc:	c9                   	leave  
  8010bd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8010be:	83 ec 08             	sub    $0x8,%esp
  8010c1:	68 ff 00 00 00       	push   $0xff
  8010c6:	8d 43 08             	lea    0x8(%ebx),%eax
  8010c9:	50                   	push   %eax
  8010ca:	e8 28 f0 ff ff       	call   8000f7 <sys_cputs>
		b->idx = 0;
  8010cf:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010d5:	83 c4 10             	add    $0x10,%esp
  8010d8:	eb db                	jmp    8010b5 <putch+0x23>

008010da <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010da:	f3 0f 1e fb          	endbr32 
  8010de:	55                   	push   %ebp
  8010df:	89 e5                	mov    %esp,%ebp
  8010e1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010e7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010ee:	00 00 00 
	b.cnt = 0;
  8010f1:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010f8:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010fb:	ff 75 0c             	pushl  0xc(%ebp)
  8010fe:	ff 75 08             	pushl  0x8(%ebp)
  801101:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801107:	50                   	push   %eax
  801108:	68 92 10 80 00       	push   $0x801092
  80110d:	e8 80 01 00 00       	call   801292 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801112:	83 c4 08             	add    $0x8,%esp
  801115:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80111b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801121:	50                   	push   %eax
  801122:	e8 d0 ef ff ff       	call   8000f7 <sys_cputs>

	return b.cnt;
}
  801127:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80112d:	c9                   	leave  
  80112e:	c3                   	ret    

0080112f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80112f:	f3 0f 1e fb          	endbr32 
  801133:	55                   	push   %ebp
  801134:	89 e5                	mov    %esp,%ebp
  801136:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801139:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80113c:	50                   	push   %eax
  80113d:	ff 75 08             	pushl  0x8(%ebp)
  801140:	e8 95 ff ff ff       	call   8010da <vcprintf>
	va_end(ap);

	return cnt;
}
  801145:	c9                   	leave  
  801146:	c3                   	ret    

00801147 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801147:	55                   	push   %ebp
  801148:	89 e5                	mov    %esp,%ebp
  80114a:	57                   	push   %edi
  80114b:	56                   	push   %esi
  80114c:	53                   	push   %ebx
  80114d:	83 ec 1c             	sub    $0x1c,%esp
  801150:	89 c7                	mov    %eax,%edi
  801152:	89 d6                	mov    %edx,%esi
  801154:	8b 45 08             	mov    0x8(%ebp),%eax
  801157:	8b 55 0c             	mov    0xc(%ebp),%edx
  80115a:	89 d1                	mov    %edx,%ecx
  80115c:	89 c2                	mov    %eax,%edx
  80115e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801161:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801164:	8b 45 10             	mov    0x10(%ebp),%eax
  801167:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80116a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80116d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801174:	39 c2                	cmp    %eax,%edx
  801176:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801179:	72 3e                	jb     8011b9 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80117b:	83 ec 0c             	sub    $0xc,%esp
  80117e:	ff 75 18             	pushl  0x18(%ebp)
  801181:	83 eb 01             	sub    $0x1,%ebx
  801184:	53                   	push   %ebx
  801185:	50                   	push   %eax
  801186:	83 ec 08             	sub    $0x8,%esp
  801189:	ff 75 e4             	pushl  -0x1c(%ebp)
  80118c:	ff 75 e0             	pushl  -0x20(%ebp)
  80118f:	ff 75 dc             	pushl  -0x24(%ebp)
  801192:	ff 75 d8             	pushl  -0x28(%ebp)
  801195:	e8 c6 09 00 00       	call   801b60 <__udivdi3>
  80119a:	83 c4 18             	add    $0x18,%esp
  80119d:	52                   	push   %edx
  80119e:	50                   	push   %eax
  80119f:	89 f2                	mov    %esi,%edx
  8011a1:	89 f8                	mov    %edi,%eax
  8011a3:	e8 9f ff ff ff       	call   801147 <printnum>
  8011a8:	83 c4 20             	add    $0x20,%esp
  8011ab:	eb 13                	jmp    8011c0 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011ad:	83 ec 08             	sub    $0x8,%esp
  8011b0:	56                   	push   %esi
  8011b1:	ff 75 18             	pushl  0x18(%ebp)
  8011b4:	ff d7                	call   *%edi
  8011b6:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8011b9:	83 eb 01             	sub    $0x1,%ebx
  8011bc:	85 db                	test   %ebx,%ebx
  8011be:	7f ed                	jg     8011ad <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011c0:	83 ec 08             	sub    $0x8,%esp
  8011c3:	56                   	push   %esi
  8011c4:	83 ec 04             	sub    $0x4,%esp
  8011c7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ca:	ff 75 e0             	pushl  -0x20(%ebp)
  8011cd:	ff 75 dc             	pushl  -0x24(%ebp)
  8011d0:	ff 75 d8             	pushl  -0x28(%ebp)
  8011d3:	e8 98 0a 00 00       	call   801c70 <__umoddi3>
  8011d8:	83 c4 14             	add    $0x14,%esp
  8011db:	0f be 80 07 1f 80 00 	movsbl 0x801f07(%eax),%eax
  8011e2:	50                   	push   %eax
  8011e3:	ff d7                	call   *%edi
}
  8011e5:	83 c4 10             	add    $0x10,%esp
  8011e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011eb:	5b                   	pop    %ebx
  8011ec:	5e                   	pop    %esi
  8011ed:	5f                   	pop    %edi
  8011ee:	5d                   	pop    %ebp
  8011ef:	c3                   	ret    

008011f0 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8011f0:	83 fa 01             	cmp    $0x1,%edx
  8011f3:	7f 13                	jg     801208 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8011f5:	85 d2                	test   %edx,%edx
  8011f7:	74 1c                	je     801215 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8011f9:	8b 10                	mov    (%eax),%edx
  8011fb:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011fe:	89 08                	mov    %ecx,(%eax)
  801200:	8b 02                	mov    (%edx),%eax
  801202:	ba 00 00 00 00       	mov    $0x0,%edx
  801207:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  801208:	8b 10                	mov    (%eax),%edx
  80120a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80120d:	89 08                	mov    %ecx,(%eax)
  80120f:	8b 02                	mov    (%edx),%eax
  801211:	8b 52 04             	mov    0x4(%edx),%edx
  801214:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  801215:	8b 10                	mov    (%eax),%edx
  801217:	8d 4a 04             	lea    0x4(%edx),%ecx
  80121a:	89 08                	mov    %ecx,(%eax)
  80121c:	8b 02                	mov    (%edx),%eax
  80121e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801223:	c3                   	ret    

00801224 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801224:	83 fa 01             	cmp    $0x1,%edx
  801227:	7f 0f                	jg     801238 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  801229:	85 d2                	test   %edx,%edx
  80122b:	74 18                	je     801245 <getint+0x21>
		return va_arg(*ap, long);
  80122d:	8b 10                	mov    (%eax),%edx
  80122f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801232:	89 08                	mov    %ecx,(%eax)
  801234:	8b 02                	mov    (%edx),%eax
  801236:	99                   	cltd   
  801237:	c3                   	ret    
		return va_arg(*ap, long long);
  801238:	8b 10                	mov    (%eax),%edx
  80123a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80123d:	89 08                	mov    %ecx,(%eax)
  80123f:	8b 02                	mov    (%edx),%eax
  801241:	8b 52 04             	mov    0x4(%edx),%edx
  801244:	c3                   	ret    
	else
		return va_arg(*ap, int);
  801245:	8b 10                	mov    (%eax),%edx
  801247:	8d 4a 04             	lea    0x4(%edx),%ecx
  80124a:	89 08                	mov    %ecx,(%eax)
  80124c:	8b 02                	mov    (%edx),%eax
  80124e:	99                   	cltd   
}
  80124f:	c3                   	ret    

00801250 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801250:	f3 0f 1e fb          	endbr32 
  801254:	55                   	push   %ebp
  801255:	89 e5                	mov    %esp,%ebp
  801257:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80125a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80125e:	8b 10                	mov    (%eax),%edx
  801260:	3b 50 04             	cmp    0x4(%eax),%edx
  801263:	73 0a                	jae    80126f <sprintputch+0x1f>
		*b->buf++ = ch;
  801265:	8d 4a 01             	lea    0x1(%edx),%ecx
  801268:	89 08                	mov    %ecx,(%eax)
  80126a:	8b 45 08             	mov    0x8(%ebp),%eax
  80126d:	88 02                	mov    %al,(%edx)
}
  80126f:	5d                   	pop    %ebp
  801270:	c3                   	ret    

00801271 <printfmt>:
{
  801271:	f3 0f 1e fb          	endbr32 
  801275:	55                   	push   %ebp
  801276:	89 e5                	mov    %esp,%ebp
  801278:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80127b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80127e:	50                   	push   %eax
  80127f:	ff 75 10             	pushl  0x10(%ebp)
  801282:	ff 75 0c             	pushl  0xc(%ebp)
  801285:	ff 75 08             	pushl  0x8(%ebp)
  801288:	e8 05 00 00 00       	call   801292 <vprintfmt>
}
  80128d:	83 c4 10             	add    $0x10,%esp
  801290:	c9                   	leave  
  801291:	c3                   	ret    

00801292 <vprintfmt>:
{
  801292:	f3 0f 1e fb          	endbr32 
  801296:	55                   	push   %ebp
  801297:	89 e5                	mov    %esp,%ebp
  801299:	57                   	push   %edi
  80129a:	56                   	push   %esi
  80129b:	53                   	push   %ebx
  80129c:	83 ec 2c             	sub    $0x2c,%esp
  80129f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012a2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012a5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012a8:	e9 86 02 00 00       	jmp    801533 <vprintfmt+0x2a1>
		padc = ' ';
  8012ad:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012b1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012b8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012bf:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012c6:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012cb:	8d 47 01             	lea    0x1(%edi),%eax
  8012ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012d1:	0f b6 17             	movzbl (%edi),%edx
  8012d4:	8d 42 dd             	lea    -0x23(%edx),%eax
  8012d7:	3c 55                	cmp    $0x55,%al
  8012d9:	0f 87 df 02 00 00    	ja     8015be <vprintfmt+0x32c>
  8012df:	0f b6 c0             	movzbl %al,%eax
  8012e2:	3e ff 24 85 40 20 80 	notrack jmp *0x802040(,%eax,4)
  8012e9:	00 
  8012ea:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8012ed:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8012f1:	eb d8                	jmp    8012cb <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8012f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012f6:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8012fa:	eb cf                	jmp    8012cb <vprintfmt+0x39>
  8012fc:	0f b6 d2             	movzbl %dl,%edx
  8012ff:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801302:	b8 00 00 00 00       	mov    $0x0,%eax
  801307:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80130a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80130d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801311:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801314:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801317:	83 f9 09             	cmp    $0x9,%ecx
  80131a:	77 52                	ja     80136e <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  80131c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80131f:	eb e9                	jmp    80130a <vprintfmt+0x78>
			precision = va_arg(ap, int);
  801321:	8b 45 14             	mov    0x14(%ebp),%eax
  801324:	8d 50 04             	lea    0x4(%eax),%edx
  801327:	89 55 14             	mov    %edx,0x14(%ebp)
  80132a:	8b 00                	mov    (%eax),%eax
  80132c:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80132f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801332:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801336:	79 93                	jns    8012cb <vprintfmt+0x39>
				width = precision, precision = -1;
  801338:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80133b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80133e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801345:	eb 84                	jmp    8012cb <vprintfmt+0x39>
  801347:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80134a:	85 c0                	test   %eax,%eax
  80134c:	ba 00 00 00 00       	mov    $0x0,%edx
  801351:	0f 49 d0             	cmovns %eax,%edx
  801354:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801357:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80135a:	e9 6c ff ff ff       	jmp    8012cb <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80135f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801362:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801369:	e9 5d ff ff ff       	jmp    8012cb <vprintfmt+0x39>
  80136e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801371:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801374:	eb bc                	jmp    801332 <vprintfmt+0xa0>
			lflag++;
  801376:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801379:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80137c:	e9 4a ff ff ff       	jmp    8012cb <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  801381:	8b 45 14             	mov    0x14(%ebp),%eax
  801384:	8d 50 04             	lea    0x4(%eax),%edx
  801387:	89 55 14             	mov    %edx,0x14(%ebp)
  80138a:	83 ec 08             	sub    $0x8,%esp
  80138d:	56                   	push   %esi
  80138e:	ff 30                	pushl  (%eax)
  801390:	ff d3                	call   *%ebx
			break;
  801392:	83 c4 10             	add    $0x10,%esp
  801395:	e9 96 01 00 00       	jmp    801530 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  80139a:	8b 45 14             	mov    0x14(%ebp),%eax
  80139d:	8d 50 04             	lea    0x4(%eax),%edx
  8013a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8013a3:	8b 00                	mov    (%eax),%eax
  8013a5:	99                   	cltd   
  8013a6:	31 d0                	xor    %edx,%eax
  8013a8:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013aa:	83 f8 0f             	cmp    $0xf,%eax
  8013ad:	7f 20                	jg     8013cf <vprintfmt+0x13d>
  8013af:	8b 14 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%edx
  8013b6:	85 d2                	test   %edx,%edx
  8013b8:	74 15                	je     8013cf <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8013ba:	52                   	push   %edx
  8013bb:	68 9d 1e 80 00       	push   $0x801e9d
  8013c0:	56                   	push   %esi
  8013c1:	53                   	push   %ebx
  8013c2:	e8 aa fe ff ff       	call   801271 <printfmt>
  8013c7:	83 c4 10             	add    $0x10,%esp
  8013ca:	e9 61 01 00 00       	jmp    801530 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8013cf:	50                   	push   %eax
  8013d0:	68 1f 1f 80 00       	push   $0x801f1f
  8013d5:	56                   	push   %esi
  8013d6:	53                   	push   %ebx
  8013d7:	e8 95 fe ff ff       	call   801271 <printfmt>
  8013dc:	83 c4 10             	add    $0x10,%esp
  8013df:	e9 4c 01 00 00       	jmp    801530 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8013e4:	8b 45 14             	mov    0x14(%ebp),%eax
  8013e7:	8d 50 04             	lea    0x4(%eax),%edx
  8013ea:	89 55 14             	mov    %edx,0x14(%ebp)
  8013ed:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8013ef:	85 c9                	test   %ecx,%ecx
  8013f1:	b8 18 1f 80 00       	mov    $0x801f18,%eax
  8013f6:	0f 45 c1             	cmovne %ecx,%eax
  8013f9:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8013fc:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801400:	7e 06                	jle    801408 <vprintfmt+0x176>
  801402:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801406:	75 0d                	jne    801415 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  801408:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80140b:	89 c7                	mov    %eax,%edi
  80140d:	03 45 e0             	add    -0x20(%ebp),%eax
  801410:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801413:	eb 57                	jmp    80146c <vprintfmt+0x1da>
  801415:	83 ec 08             	sub    $0x8,%esp
  801418:	ff 75 d8             	pushl  -0x28(%ebp)
  80141b:	ff 75 cc             	pushl  -0x34(%ebp)
  80141e:	e8 4f 02 00 00       	call   801672 <strnlen>
  801423:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801426:	29 c2                	sub    %eax,%edx
  801428:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80142b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80142e:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801432:	89 5d 08             	mov    %ebx,0x8(%ebp)
  801435:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  801437:	85 db                	test   %ebx,%ebx
  801439:	7e 10                	jle    80144b <vprintfmt+0x1b9>
					putch(padc, putdat);
  80143b:	83 ec 08             	sub    $0x8,%esp
  80143e:	56                   	push   %esi
  80143f:	57                   	push   %edi
  801440:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801443:	83 eb 01             	sub    $0x1,%ebx
  801446:	83 c4 10             	add    $0x10,%esp
  801449:	eb ec                	jmp    801437 <vprintfmt+0x1a5>
  80144b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80144e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801451:	85 d2                	test   %edx,%edx
  801453:	b8 00 00 00 00       	mov    $0x0,%eax
  801458:	0f 49 c2             	cmovns %edx,%eax
  80145b:	29 c2                	sub    %eax,%edx
  80145d:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801460:	eb a6                	jmp    801408 <vprintfmt+0x176>
					putch(ch, putdat);
  801462:	83 ec 08             	sub    $0x8,%esp
  801465:	56                   	push   %esi
  801466:	52                   	push   %edx
  801467:	ff d3                	call   *%ebx
  801469:	83 c4 10             	add    $0x10,%esp
  80146c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80146f:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801471:	83 c7 01             	add    $0x1,%edi
  801474:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801478:	0f be d0             	movsbl %al,%edx
  80147b:	85 d2                	test   %edx,%edx
  80147d:	74 42                	je     8014c1 <vprintfmt+0x22f>
  80147f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801483:	78 06                	js     80148b <vprintfmt+0x1f9>
  801485:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  801489:	78 1e                	js     8014a9 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  80148b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80148f:	74 d1                	je     801462 <vprintfmt+0x1d0>
  801491:	0f be c0             	movsbl %al,%eax
  801494:	83 e8 20             	sub    $0x20,%eax
  801497:	83 f8 5e             	cmp    $0x5e,%eax
  80149a:	76 c6                	jbe    801462 <vprintfmt+0x1d0>
					putch('?', putdat);
  80149c:	83 ec 08             	sub    $0x8,%esp
  80149f:	56                   	push   %esi
  8014a0:	6a 3f                	push   $0x3f
  8014a2:	ff d3                	call   *%ebx
  8014a4:	83 c4 10             	add    $0x10,%esp
  8014a7:	eb c3                	jmp    80146c <vprintfmt+0x1da>
  8014a9:	89 cf                	mov    %ecx,%edi
  8014ab:	eb 0e                	jmp    8014bb <vprintfmt+0x229>
				putch(' ', putdat);
  8014ad:	83 ec 08             	sub    $0x8,%esp
  8014b0:	56                   	push   %esi
  8014b1:	6a 20                	push   $0x20
  8014b3:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8014b5:	83 ef 01             	sub    $0x1,%edi
  8014b8:	83 c4 10             	add    $0x10,%esp
  8014bb:	85 ff                	test   %edi,%edi
  8014bd:	7f ee                	jg     8014ad <vprintfmt+0x21b>
  8014bf:	eb 6f                	jmp    801530 <vprintfmt+0x29e>
  8014c1:	89 cf                	mov    %ecx,%edi
  8014c3:	eb f6                	jmp    8014bb <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8014c5:	89 ca                	mov    %ecx,%edx
  8014c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8014ca:	e8 55 fd ff ff       	call   801224 <getint>
  8014cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014d2:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8014d5:	85 d2                	test   %edx,%edx
  8014d7:	78 0b                	js     8014e4 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8014d9:	89 d1                	mov    %edx,%ecx
  8014db:	89 c2                	mov    %eax,%edx
			base = 10;
  8014dd:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014e2:	eb 32                	jmp    801516 <vprintfmt+0x284>
				putch('-', putdat);
  8014e4:	83 ec 08             	sub    $0x8,%esp
  8014e7:	56                   	push   %esi
  8014e8:	6a 2d                	push   $0x2d
  8014ea:	ff d3                	call   *%ebx
				num = -(long long) num;
  8014ec:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014ef:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8014f2:	f7 da                	neg    %edx
  8014f4:	83 d1 00             	adc    $0x0,%ecx
  8014f7:	f7 d9                	neg    %ecx
  8014f9:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8014fc:	b8 0a 00 00 00       	mov    $0xa,%eax
  801501:	eb 13                	jmp    801516 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  801503:	89 ca                	mov    %ecx,%edx
  801505:	8d 45 14             	lea    0x14(%ebp),%eax
  801508:	e8 e3 fc ff ff       	call   8011f0 <getuint>
  80150d:	89 d1                	mov    %edx,%ecx
  80150f:	89 c2                	mov    %eax,%edx
			base = 10;
  801511:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  801516:	83 ec 0c             	sub    $0xc,%esp
  801519:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80151d:	57                   	push   %edi
  80151e:	ff 75 e0             	pushl  -0x20(%ebp)
  801521:	50                   	push   %eax
  801522:	51                   	push   %ecx
  801523:	52                   	push   %edx
  801524:	89 f2                	mov    %esi,%edx
  801526:	89 d8                	mov    %ebx,%eax
  801528:	e8 1a fc ff ff       	call   801147 <printnum>
			break;
  80152d:	83 c4 20             	add    $0x20,%esp
{
  801530:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801533:	83 c7 01             	add    $0x1,%edi
  801536:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80153a:	83 f8 25             	cmp    $0x25,%eax
  80153d:	0f 84 6a fd ff ff    	je     8012ad <vprintfmt+0x1b>
			if (ch == '\0')
  801543:	85 c0                	test   %eax,%eax
  801545:	0f 84 93 00 00 00    	je     8015de <vprintfmt+0x34c>
			putch(ch, putdat);
  80154b:	83 ec 08             	sub    $0x8,%esp
  80154e:	56                   	push   %esi
  80154f:	50                   	push   %eax
  801550:	ff d3                	call   *%ebx
  801552:	83 c4 10             	add    $0x10,%esp
  801555:	eb dc                	jmp    801533 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  801557:	89 ca                	mov    %ecx,%edx
  801559:	8d 45 14             	lea    0x14(%ebp),%eax
  80155c:	e8 8f fc ff ff       	call   8011f0 <getuint>
  801561:	89 d1                	mov    %edx,%ecx
  801563:	89 c2                	mov    %eax,%edx
			base = 8;
  801565:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80156a:	eb aa                	jmp    801516 <vprintfmt+0x284>
			putch('0', putdat);
  80156c:	83 ec 08             	sub    $0x8,%esp
  80156f:	56                   	push   %esi
  801570:	6a 30                	push   $0x30
  801572:	ff d3                	call   *%ebx
			putch('x', putdat);
  801574:	83 c4 08             	add    $0x8,%esp
  801577:	56                   	push   %esi
  801578:	6a 78                	push   $0x78
  80157a:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  80157c:	8b 45 14             	mov    0x14(%ebp),%eax
  80157f:	8d 50 04             	lea    0x4(%eax),%edx
  801582:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  801585:	8b 10                	mov    (%eax),%edx
  801587:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80158c:	83 c4 10             	add    $0x10,%esp
			base = 16;
  80158f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  801594:	eb 80                	jmp    801516 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  801596:	89 ca                	mov    %ecx,%edx
  801598:	8d 45 14             	lea    0x14(%ebp),%eax
  80159b:	e8 50 fc ff ff       	call   8011f0 <getuint>
  8015a0:	89 d1                	mov    %edx,%ecx
  8015a2:	89 c2                	mov    %eax,%edx
			base = 16;
  8015a4:	b8 10 00 00 00       	mov    $0x10,%eax
  8015a9:	e9 68 ff ff ff       	jmp    801516 <vprintfmt+0x284>
			putch(ch, putdat);
  8015ae:	83 ec 08             	sub    $0x8,%esp
  8015b1:	56                   	push   %esi
  8015b2:	6a 25                	push   $0x25
  8015b4:	ff d3                	call   *%ebx
			break;
  8015b6:	83 c4 10             	add    $0x10,%esp
  8015b9:	e9 72 ff ff ff       	jmp    801530 <vprintfmt+0x29e>
			putch('%', putdat);
  8015be:	83 ec 08             	sub    $0x8,%esp
  8015c1:	56                   	push   %esi
  8015c2:	6a 25                	push   $0x25
  8015c4:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015c6:	83 c4 10             	add    $0x10,%esp
  8015c9:	89 f8                	mov    %edi,%eax
  8015cb:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8015cf:	74 05                	je     8015d6 <vprintfmt+0x344>
  8015d1:	83 e8 01             	sub    $0x1,%eax
  8015d4:	eb f5                	jmp    8015cb <vprintfmt+0x339>
  8015d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015d9:	e9 52 ff ff ff       	jmp    801530 <vprintfmt+0x29e>
}
  8015de:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015e1:	5b                   	pop    %ebx
  8015e2:	5e                   	pop    %esi
  8015e3:	5f                   	pop    %edi
  8015e4:	5d                   	pop    %ebp
  8015e5:	c3                   	ret    

008015e6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015e6:	f3 0f 1e fb          	endbr32 
  8015ea:	55                   	push   %ebp
  8015eb:	89 e5                	mov    %esp,%ebp
  8015ed:	83 ec 18             	sub    $0x18,%esp
  8015f0:	8b 45 08             	mov    0x8(%ebp),%eax
  8015f3:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015f6:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015f9:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015fd:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801600:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801607:	85 c0                	test   %eax,%eax
  801609:	74 26                	je     801631 <vsnprintf+0x4b>
  80160b:	85 d2                	test   %edx,%edx
  80160d:	7e 22                	jle    801631 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80160f:	ff 75 14             	pushl  0x14(%ebp)
  801612:	ff 75 10             	pushl  0x10(%ebp)
  801615:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801618:	50                   	push   %eax
  801619:	68 50 12 80 00       	push   $0x801250
  80161e:	e8 6f fc ff ff       	call   801292 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801623:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801626:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801629:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80162c:	83 c4 10             	add    $0x10,%esp
}
  80162f:	c9                   	leave  
  801630:	c3                   	ret    
		return -E_INVAL;
  801631:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801636:	eb f7                	jmp    80162f <vsnprintf+0x49>

00801638 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801638:	f3 0f 1e fb          	endbr32 
  80163c:	55                   	push   %ebp
  80163d:	89 e5                	mov    %esp,%ebp
  80163f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801642:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801645:	50                   	push   %eax
  801646:	ff 75 10             	pushl  0x10(%ebp)
  801649:	ff 75 0c             	pushl  0xc(%ebp)
  80164c:	ff 75 08             	pushl  0x8(%ebp)
  80164f:	e8 92 ff ff ff       	call   8015e6 <vsnprintf>
	va_end(ap);

	return rc;
}
  801654:	c9                   	leave  
  801655:	c3                   	ret    

00801656 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801656:	f3 0f 1e fb          	endbr32 
  80165a:	55                   	push   %ebp
  80165b:	89 e5                	mov    %esp,%ebp
  80165d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801660:	b8 00 00 00 00       	mov    $0x0,%eax
  801665:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801669:	74 05                	je     801670 <strlen+0x1a>
		n++;
  80166b:	83 c0 01             	add    $0x1,%eax
  80166e:	eb f5                	jmp    801665 <strlen+0xf>
	return n;
}
  801670:	5d                   	pop    %ebp
  801671:	c3                   	ret    

00801672 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801672:	f3 0f 1e fb          	endbr32 
  801676:	55                   	push   %ebp
  801677:	89 e5                	mov    %esp,%ebp
  801679:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80167c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80167f:	b8 00 00 00 00       	mov    $0x0,%eax
  801684:	39 d0                	cmp    %edx,%eax
  801686:	74 0d                	je     801695 <strnlen+0x23>
  801688:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80168c:	74 05                	je     801693 <strnlen+0x21>
		n++;
  80168e:	83 c0 01             	add    $0x1,%eax
  801691:	eb f1                	jmp    801684 <strnlen+0x12>
  801693:	89 c2                	mov    %eax,%edx
	return n;
}
  801695:	89 d0                	mov    %edx,%eax
  801697:	5d                   	pop    %ebp
  801698:	c3                   	ret    

00801699 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801699:	f3 0f 1e fb          	endbr32 
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
  8016a0:	53                   	push   %ebx
  8016a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016a4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ac:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8016b0:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8016b3:	83 c0 01             	add    $0x1,%eax
  8016b6:	84 d2                	test   %dl,%dl
  8016b8:	75 f2                	jne    8016ac <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8016ba:	89 c8                	mov    %ecx,%eax
  8016bc:	5b                   	pop    %ebx
  8016bd:	5d                   	pop    %ebp
  8016be:	c3                   	ret    

008016bf <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016bf:	f3 0f 1e fb          	endbr32 
  8016c3:	55                   	push   %ebp
  8016c4:	89 e5                	mov    %esp,%ebp
  8016c6:	53                   	push   %ebx
  8016c7:	83 ec 10             	sub    $0x10,%esp
  8016ca:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016cd:	53                   	push   %ebx
  8016ce:	e8 83 ff ff ff       	call   801656 <strlen>
  8016d3:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8016d6:	ff 75 0c             	pushl  0xc(%ebp)
  8016d9:	01 d8                	add    %ebx,%eax
  8016db:	50                   	push   %eax
  8016dc:	e8 b8 ff ff ff       	call   801699 <strcpy>
	return dst;
}
  8016e1:	89 d8                	mov    %ebx,%eax
  8016e3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016e6:	c9                   	leave  
  8016e7:	c3                   	ret    

008016e8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016e8:	f3 0f 1e fb          	endbr32 
  8016ec:	55                   	push   %ebp
  8016ed:	89 e5                	mov    %esp,%ebp
  8016ef:	56                   	push   %esi
  8016f0:	53                   	push   %ebx
  8016f1:	8b 75 08             	mov    0x8(%ebp),%esi
  8016f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016f7:	89 f3                	mov    %esi,%ebx
  8016f9:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016fc:	89 f0                	mov    %esi,%eax
  8016fe:	39 d8                	cmp    %ebx,%eax
  801700:	74 11                	je     801713 <strncpy+0x2b>
		*dst++ = *src;
  801702:	83 c0 01             	add    $0x1,%eax
  801705:	0f b6 0a             	movzbl (%edx),%ecx
  801708:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80170b:	80 f9 01             	cmp    $0x1,%cl
  80170e:	83 da ff             	sbb    $0xffffffff,%edx
  801711:	eb eb                	jmp    8016fe <strncpy+0x16>
	}
	return ret;
}
  801713:	89 f0                	mov    %esi,%eax
  801715:	5b                   	pop    %ebx
  801716:	5e                   	pop    %esi
  801717:	5d                   	pop    %ebp
  801718:	c3                   	ret    

00801719 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801719:	f3 0f 1e fb          	endbr32 
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	56                   	push   %esi
  801721:	53                   	push   %ebx
  801722:	8b 75 08             	mov    0x8(%ebp),%esi
  801725:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801728:	8b 55 10             	mov    0x10(%ebp),%edx
  80172b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80172d:	85 d2                	test   %edx,%edx
  80172f:	74 21                	je     801752 <strlcpy+0x39>
  801731:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801735:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801737:	39 c2                	cmp    %eax,%edx
  801739:	74 14                	je     80174f <strlcpy+0x36>
  80173b:	0f b6 19             	movzbl (%ecx),%ebx
  80173e:	84 db                	test   %bl,%bl
  801740:	74 0b                	je     80174d <strlcpy+0x34>
			*dst++ = *src++;
  801742:	83 c1 01             	add    $0x1,%ecx
  801745:	83 c2 01             	add    $0x1,%edx
  801748:	88 5a ff             	mov    %bl,-0x1(%edx)
  80174b:	eb ea                	jmp    801737 <strlcpy+0x1e>
  80174d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80174f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801752:	29 f0                	sub    %esi,%eax
}
  801754:	5b                   	pop    %ebx
  801755:	5e                   	pop    %esi
  801756:	5d                   	pop    %ebp
  801757:	c3                   	ret    

00801758 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801758:	f3 0f 1e fb          	endbr32 
  80175c:	55                   	push   %ebp
  80175d:	89 e5                	mov    %esp,%ebp
  80175f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801762:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801765:	0f b6 01             	movzbl (%ecx),%eax
  801768:	84 c0                	test   %al,%al
  80176a:	74 0c                	je     801778 <strcmp+0x20>
  80176c:	3a 02                	cmp    (%edx),%al
  80176e:	75 08                	jne    801778 <strcmp+0x20>
		p++, q++;
  801770:	83 c1 01             	add    $0x1,%ecx
  801773:	83 c2 01             	add    $0x1,%edx
  801776:	eb ed                	jmp    801765 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801778:	0f b6 c0             	movzbl %al,%eax
  80177b:	0f b6 12             	movzbl (%edx),%edx
  80177e:	29 d0                	sub    %edx,%eax
}
  801780:	5d                   	pop    %ebp
  801781:	c3                   	ret    

00801782 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801782:	f3 0f 1e fb          	endbr32 
  801786:	55                   	push   %ebp
  801787:	89 e5                	mov    %esp,%ebp
  801789:	53                   	push   %ebx
  80178a:	8b 45 08             	mov    0x8(%ebp),%eax
  80178d:	8b 55 0c             	mov    0xc(%ebp),%edx
  801790:	89 c3                	mov    %eax,%ebx
  801792:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  801795:	eb 06                	jmp    80179d <strncmp+0x1b>
		n--, p++, q++;
  801797:	83 c0 01             	add    $0x1,%eax
  80179a:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  80179d:	39 d8                	cmp    %ebx,%eax
  80179f:	74 16                	je     8017b7 <strncmp+0x35>
  8017a1:	0f b6 08             	movzbl (%eax),%ecx
  8017a4:	84 c9                	test   %cl,%cl
  8017a6:	74 04                	je     8017ac <strncmp+0x2a>
  8017a8:	3a 0a                	cmp    (%edx),%cl
  8017aa:	74 eb                	je     801797 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ac:	0f b6 00             	movzbl (%eax),%eax
  8017af:	0f b6 12             	movzbl (%edx),%edx
  8017b2:	29 d0                	sub    %edx,%eax
}
  8017b4:	5b                   	pop    %ebx
  8017b5:	5d                   	pop    %ebp
  8017b6:	c3                   	ret    
		return 0;
  8017b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8017bc:	eb f6                	jmp    8017b4 <strncmp+0x32>

008017be <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017be:	f3 0f 1e fb          	endbr32 
  8017c2:	55                   	push   %ebp
  8017c3:	89 e5                	mov    %esp,%ebp
  8017c5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017cc:	0f b6 10             	movzbl (%eax),%edx
  8017cf:	84 d2                	test   %dl,%dl
  8017d1:	74 09                	je     8017dc <strchr+0x1e>
		if (*s == c)
  8017d3:	38 ca                	cmp    %cl,%dl
  8017d5:	74 0a                	je     8017e1 <strchr+0x23>
	for (; *s; s++)
  8017d7:	83 c0 01             	add    $0x1,%eax
  8017da:	eb f0                	jmp    8017cc <strchr+0xe>
			return (char *) s;
	return 0;
  8017dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017e1:	5d                   	pop    %ebp
  8017e2:	c3                   	ret    

008017e3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017e3:	f3 0f 1e fb          	endbr32 
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ed:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017f1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017f4:	38 ca                	cmp    %cl,%dl
  8017f6:	74 09                	je     801801 <strfind+0x1e>
  8017f8:	84 d2                	test   %dl,%dl
  8017fa:	74 05                	je     801801 <strfind+0x1e>
	for (; *s; s++)
  8017fc:	83 c0 01             	add    $0x1,%eax
  8017ff:	eb f0                	jmp    8017f1 <strfind+0xe>
			break;
	return (char *) s;
}
  801801:	5d                   	pop    %ebp
  801802:	c3                   	ret    

00801803 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801803:	f3 0f 1e fb          	endbr32 
  801807:	55                   	push   %ebp
  801808:	89 e5                	mov    %esp,%ebp
  80180a:	57                   	push   %edi
  80180b:	56                   	push   %esi
  80180c:	53                   	push   %ebx
  80180d:	8b 55 08             	mov    0x8(%ebp),%edx
  801810:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  801813:	85 c9                	test   %ecx,%ecx
  801815:	74 33                	je     80184a <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801817:	89 d0                	mov    %edx,%eax
  801819:	09 c8                	or     %ecx,%eax
  80181b:	a8 03                	test   $0x3,%al
  80181d:	75 23                	jne    801842 <memset+0x3f>
		c &= 0xFF;
  80181f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801823:	89 d8                	mov    %ebx,%eax
  801825:	c1 e0 08             	shl    $0x8,%eax
  801828:	89 df                	mov    %ebx,%edi
  80182a:	c1 e7 18             	shl    $0x18,%edi
  80182d:	89 de                	mov    %ebx,%esi
  80182f:	c1 e6 10             	shl    $0x10,%esi
  801832:	09 f7                	or     %esi,%edi
  801834:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  801836:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801839:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  80183b:	89 d7                	mov    %edx,%edi
  80183d:	fc                   	cld    
  80183e:	f3 ab                	rep stos %eax,%es:(%edi)
  801840:	eb 08                	jmp    80184a <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801842:	89 d7                	mov    %edx,%edi
  801844:	8b 45 0c             	mov    0xc(%ebp),%eax
  801847:	fc                   	cld    
  801848:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  80184a:	89 d0                	mov    %edx,%eax
  80184c:	5b                   	pop    %ebx
  80184d:	5e                   	pop    %esi
  80184e:	5f                   	pop    %edi
  80184f:	5d                   	pop    %ebp
  801850:	c3                   	ret    

00801851 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801851:	f3 0f 1e fb          	endbr32 
  801855:	55                   	push   %ebp
  801856:	89 e5                	mov    %esp,%ebp
  801858:	57                   	push   %edi
  801859:	56                   	push   %esi
  80185a:	8b 45 08             	mov    0x8(%ebp),%eax
  80185d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801860:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801863:	39 c6                	cmp    %eax,%esi
  801865:	73 32                	jae    801899 <memmove+0x48>
  801867:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80186a:	39 c2                	cmp    %eax,%edx
  80186c:	76 2b                	jbe    801899 <memmove+0x48>
		s += n;
		d += n;
  80186e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801871:	89 fe                	mov    %edi,%esi
  801873:	09 ce                	or     %ecx,%esi
  801875:	09 d6                	or     %edx,%esi
  801877:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80187d:	75 0e                	jne    80188d <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80187f:	83 ef 04             	sub    $0x4,%edi
  801882:	8d 72 fc             	lea    -0x4(%edx),%esi
  801885:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801888:	fd                   	std    
  801889:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80188b:	eb 09                	jmp    801896 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80188d:	83 ef 01             	sub    $0x1,%edi
  801890:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  801893:	fd                   	std    
  801894:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  801896:	fc                   	cld    
  801897:	eb 1a                	jmp    8018b3 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801899:	89 c2                	mov    %eax,%edx
  80189b:	09 ca                	or     %ecx,%edx
  80189d:	09 f2                	or     %esi,%edx
  80189f:	f6 c2 03             	test   $0x3,%dl
  8018a2:	75 0a                	jne    8018ae <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018a4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018a7:	89 c7                	mov    %eax,%edi
  8018a9:	fc                   	cld    
  8018aa:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ac:	eb 05                	jmp    8018b3 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8018ae:	89 c7                	mov    %eax,%edi
  8018b0:	fc                   	cld    
  8018b1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018b3:	5e                   	pop    %esi
  8018b4:	5f                   	pop    %edi
  8018b5:	5d                   	pop    %ebp
  8018b6:	c3                   	ret    

008018b7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018b7:	f3 0f 1e fb          	endbr32 
  8018bb:	55                   	push   %ebp
  8018bc:	89 e5                	mov    %esp,%ebp
  8018be:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8018c1:	ff 75 10             	pushl  0x10(%ebp)
  8018c4:	ff 75 0c             	pushl  0xc(%ebp)
  8018c7:	ff 75 08             	pushl  0x8(%ebp)
  8018ca:	e8 82 ff ff ff       	call   801851 <memmove>
}
  8018cf:	c9                   	leave  
  8018d0:	c3                   	ret    

008018d1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018d1:	f3 0f 1e fb          	endbr32 
  8018d5:	55                   	push   %ebp
  8018d6:	89 e5                	mov    %esp,%ebp
  8018d8:	56                   	push   %esi
  8018d9:	53                   	push   %ebx
  8018da:	8b 45 08             	mov    0x8(%ebp),%eax
  8018dd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018e0:	89 c6                	mov    %eax,%esi
  8018e2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018e5:	39 f0                	cmp    %esi,%eax
  8018e7:	74 1c                	je     801905 <memcmp+0x34>
		if (*s1 != *s2)
  8018e9:	0f b6 08             	movzbl (%eax),%ecx
  8018ec:	0f b6 1a             	movzbl (%edx),%ebx
  8018ef:	38 d9                	cmp    %bl,%cl
  8018f1:	75 08                	jne    8018fb <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8018f3:	83 c0 01             	add    $0x1,%eax
  8018f6:	83 c2 01             	add    $0x1,%edx
  8018f9:	eb ea                	jmp    8018e5 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8018fb:	0f b6 c1             	movzbl %cl,%eax
  8018fe:	0f b6 db             	movzbl %bl,%ebx
  801901:	29 d8                	sub    %ebx,%eax
  801903:	eb 05                	jmp    80190a <memcmp+0x39>
	}

	return 0;
  801905:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80190a:	5b                   	pop    %ebx
  80190b:	5e                   	pop    %esi
  80190c:	5d                   	pop    %ebp
  80190d:	c3                   	ret    

0080190e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80190e:	f3 0f 1e fb          	endbr32 
  801912:	55                   	push   %ebp
  801913:	89 e5                	mov    %esp,%ebp
  801915:	8b 45 08             	mov    0x8(%ebp),%eax
  801918:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80191b:	89 c2                	mov    %eax,%edx
  80191d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801920:	39 d0                	cmp    %edx,%eax
  801922:	73 09                	jae    80192d <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801924:	38 08                	cmp    %cl,(%eax)
  801926:	74 05                	je     80192d <memfind+0x1f>
	for (; s < ends; s++)
  801928:	83 c0 01             	add    $0x1,%eax
  80192b:	eb f3                	jmp    801920 <memfind+0x12>
			break;
	return (void *) s;
}
  80192d:	5d                   	pop    %ebp
  80192e:	c3                   	ret    

0080192f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80192f:	f3 0f 1e fb          	endbr32 
  801933:	55                   	push   %ebp
  801934:	89 e5                	mov    %esp,%ebp
  801936:	57                   	push   %edi
  801937:	56                   	push   %esi
  801938:	53                   	push   %ebx
  801939:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80193c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80193f:	eb 03                	jmp    801944 <strtol+0x15>
		s++;
  801941:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801944:	0f b6 01             	movzbl (%ecx),%eax
  801947:	3c 20                	cmp    $0x20,%al
  801949:	74 f6                	je     801941 <strtol+0x12>
  80194b:	3c 09                	cmp    $0x9,%al
  80194d:	74 f2                	je     801941 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  80194f:	3c 2b                	cmp    $0x2b,%al
  801951:	74 2a                	je     80197d <strtol+0x4e>
	int neg = 0;
  801953:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801958:	3c 2d                	cmp    $0x2d,%al
  80195a:	74 2b                	je     801987 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80195c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801962:	75 0f                	jne    801973 <strtol+0x44>
  801964:	80 39 30             	cmpb   $0x30,(%ecx)
  801967:	74 28                	je     801991 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801969:	85 db                	test   %ebx,%ebx
  80196b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801970:	0f 44 d8             	cmove  %eax,%ebx
  801973:	b8 00 00 00 00       	mov    $0x0,%eax
  801978:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80197b:	eb 46                	jmp    8019c3 <strtol+0x94>
		s++;
  80197d:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801980:	bf 00 00 00 00       	mov    $0x0,%edi
  801985:	eb d5                	jmp    80195c <strtol+0x2d>
		s++, neg = 1;
  801987:	83 c1 01             	add    $0x1,%ecx
  80198a:	bf 01 00 00 00       	mov    $0x1,%edi
  80198f:	eb cb                	jmp    80195c <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801991:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801995:	74 0e                	je     8019a5 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  801997:	85 db                	test   %ebx,%ebx
  801999:	75 d8                	jne    801973 <strtol+0x44>
		s++, base = 8;
  80199b:	83 c1 01             	add    $0x1,%ecx
  80199e:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019a3:	eb ce                	jmp    801973 <strtol+0x44>
		s += 2, base = 16;
  8019a5:	83 c1 02             	add    $0x2,%ecx
  8019a8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019ad:	eb c4                	jmp    801973 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8019af:	0f be d2             	movsbl %dl,%edx
  8019b2:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019b5:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019b8:	7d 3a                	jge    8019f4 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8019ba:	83 c1 01             	add    $0x1,%ecx
  8019bd:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019c1:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8019c3:	0f b6 11             	movzbl (%ecx),%edx
  8019c6:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019c9:	89 f3                	mov    %esi,%ebx
  8019cb:	80 fb 09             	cmp    $0x9,%bl
  8019ce:	76 df                	jbe    8019af <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  8019d0:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019d3:	89 f3                	mov    %esi,%ebx
  8019d5:	80 fb 19             	cmp    $0x19,%bl
  8019d8:	77 08                	ja     8019e2 <strtol+0xb3>
			dig = *s - 'a' + 10;
  8019da:	0f be d2             	movsbl %dl,%edx
  8019dd:	83 ea 57             	sub    $0x57,%edx
  8019e0:	eb d3                	jmp    8019b5 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  8019e2:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019e5:	89 f3                	mov    %esi,%ebx
  8019e7:	80 fb 19             	cmp    $0x19,%bl
  8019ea:	77 08                	ja     8019f4 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8019ec:	0f be d2             	movsbl %dl,%edx
  8019ef:	83 ea 37             	sub    $0x37,%edx
  8019f2:	eb c1                	jmp    8019b5 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  8019f4:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019f8:	74 05                	je     8019ff <strtol+0xd0>
		*endptr = (char *) s;
  8019fa:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019fd:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8019ff:	89 c2                	mov    %eax,%edx
  801a01:	f7 da                	neg    %edx
  801a03:	85 ff                	test   %edi,%edi
  801a05:	0f 45 c2             	cmovne %edx,%eax
}
  801a08:	5b                   	pop    %ebx
  801a09:	5e                   	pop    %esi
  801a0a:	5f                   	pop    %edi
  801a0b:	5d                   	pop    %ebp
  801a0c:	c3                   	ret    

00801a0d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a0d:	f3 0f 1e fb          	endbr32 
  801a11:	55                   	push   %ebp
  801a12:	89 e5                	mov    %esp,%ebp
  801a14:	56                   	push   %esi
  801a15:	53                   	push   %ebx
  801a16:	8b 75 08             	mov    0x8(%ebp),%esi
  801a19:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a1c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  801a1f:	85 c0                	test   %eax,%eax
  801a21:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a26:	0f 44 c2             	cmove  %edx,%eax
  801a29:	83 ec 0c             	sub    $0xc,%esp
  801a2c:	50                   	push   %eax
  801a2d:	e8 a7 e8 ff ff       	call   8002d9 <sys_ipc_recv>

	if (from_env_store != NULL)
  801a32:	83 c4 10             	add    $0x10,%esp
  801a35:	85 f6                	test   %esi,%esi
  801a37:	74 15                	je     801a4e <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  801a39:	ba 00 00 00 00       	mov    $0x0,%edx
  801a3e:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a41:	74 09                	je     801a4c <ipc_recv+0x3f>
  801a43:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a49:	8b 52 74             	mov    0x74(%edx),%edx
  801a4c:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  801a4e:	85 db                	test   %ebx,%ebx
  801a50:	74 15                	je     801a67 <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  801a52:	ba 00 00 00 00       	mov    $0x0,%edx
  801a57:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a5a:	74 09                	je     801a65 <ipc_recv+0x58>
  801a5c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a62:	8b 52 78             	mov    0x78(%edx),%edx
  801a65:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  801a67:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a6a:	74 08                	je     801a74 <ipc_recv+0x67>
  801a6c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a71:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a74:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a77:	5b                   	pop    %ebx
  801a78:	5e                   	pop    %esi
  801a79:	5d                   	pop    %ebp
  801a7a:	c3                   	ret    

00801a7b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a7b:	f3 0f 1e fb          	endbr32 
  801a7f:	55                   	push   %ebp
  801a80:	89 e5                	mov    %esp,%ebp
  801a82:	57                   	push   %edi
  801a83:	56                   	push   %esi
  801a84:	53                   	push   %ebx
  801a85:	83 ec 0c             	sub    $0xc,%esp
  801a88:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a8b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a8e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a91:	eb 1f                	jmp    801ab2 <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  801a93:	6a 00                	push   $0x0
  801a95:	68 00 00 c0 ee       	push   $0xeec00000
  801a9a:	56                   	push   %esi
  801a9b:	57                   	push   %edi
  801a9c:	e8 0f e8 ff ff       	call   8002b0 <sys_ipc_try_send>
  801aa1:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  801aa4:	85 c0                	test   %eax,%eax
  801aa6:	74 30                	je     801ad8 <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  801aa8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aab:	75 19                	jne    801ac6 <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  801aad:	e8 e5 e6 ff ff       	call   800197 <sys_yield>
		if (pg != NULL) {
  801ab2:	85 db                	test   %ebx,%ebx
  801ab4:	74 dd                	je     801a93 <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  801ab6:	ff 75 14             	pushl  0x14(%ebp)
  801ab9:	53                   	push   %ebx
  801aba:	56                   	push   %esi
  801abb:	57                   	push   %edi
  801abc:	e8 ef e7 ff ff       	call   8002b0 <sys_ipc_try_send>
  801ac1:	83 c4 10             	add    $0x10,%esp
  801ac4:	eb de                	jmp    801aa4 <ipc_send+0x29>
			panic("ipc_send: %d", res);
  801ac6:	50                   	push   %eax
  801ac7:	68 ff 21 80 00       	push   $0x8021ff
  801acc:	6a 3e                	push   $0x3e
  801ace:	68 0c 22 80 00       	push   $0x80220c
  801ad3:	e8 70 f5 ff ff       	call   801048 <_panic>
	}
}
  801ad8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801adb:	5b                   	pop    %ebx
  801adc:	5e                   	pop    %esi
  801add:	5f                   	pop    %edi
  801ade:	5d                   	pop    %ebp
  801adf:	c3                   	ret    

00801ae0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ae0:	f3 0f 1e fb          	endbr32 
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801aea:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801aef:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801af2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801af8:	8b 52 50             	mov    0x50(%edx),%edx
  801afb:	39 ca                	cmp    %ecx,%edx
  801afd:	74 11                	je     801b10 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801aff:	83 c0 01             	add    $0x1,%eax
  801b02:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b07:	75 e6                	jne    801aef <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801b09:	b8 00 00 00 00       	mov    $0x0,%eax
  801b0e:	eb 0b                	jmp    801b1b <ipc_find_env+0x3b>
			return envs[i].env_id;
  801b10:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b13:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b18:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b1b:	5d                   	pop    %ebp
  801b1c:	c3                   	ret    

00801b1d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b1d:	f3 0f 1e fb          	endbr32 
  801b21:	55                   	push   %ebp
  801b22:	89 e5                	mov    %esp,%ebp
  801b24:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b27:	89 c2                	mov    %eax,%edx
  801b29:	c1 ea 16             	shr    $0x16,%edx
  801b2c:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b33:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b38:	f6 c1 01             	test   $0x1,%cl
  801b3b:	74 1c                	je     801b59 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801b3d:	c1 e8 0c             	shr    $0xc,%eax
  801b40:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b47:	a8 01                	test   $0x1,%al
  801b49:	74 0e                	je     801b59 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b4b:	c1 e8 0c             	shr    $0xc,%eax
  801b4e:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b55:	ef 
  801b56:	0f b7 d2             	movzwl %dx,%edx
}
  801b59:	89 d0                	mov    %edx,%eax
  801b5b:	5d                   	pop    %ebp
  801b5c:	c3                   	ret    
  801b5d:	66 90                	xchg   %ax,%ax
  801b5f:	90                   	nop

00801b60 <__udivdi3>:
  801b60:	f3 0f 1e fb          	endbr32 
  801b64:	55                   	push   %ebp
  801b65:	57                   	push   %edi
  801b66:	56                   	push   %esi
  801b67:	53                   	push   %ebx
  801b68:	83 ec 1c             	sub    $0x1c,%esp
  801b6b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801b6f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b73:	8b 74 24 34          	mov    0x34(%esp),%esi
  801b77:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801b7b:	85 d2                	test   %edx,%edx
  801b7d:	75 19                	jne    801b98 <__udivdi3+0x38>
  801b7f:	39 f3                	cmp    %esi,%ebx
  801b81:	76 4d                	jbe    801bd0 <__udivdi3+0x70>
  801b83:	31 ff                	xor    %edi,%edi
  801b85:	89 e8                	mov    %ebp,%eax
  801b87:	89 f2                	mov    %esi,%edx
  801b89:	f7 f3                	div    %ebx
  801b8b:	89 fa                	mov    %edi,%edx
  801b8d:	83 c4 1c             	add    $0x1c,%esp
  801b90:	5b                   	pop    %ebx
  801b91:	5e                   	pop    %esi
  801b92:	5f                   	pop    %edi
  801b93:	5d                   	pop    %ebp
  801b94:	c3                   	ret    
  801b95:	8d 76 00             	lea    0x0(%esi),%esi
  801b98:	39 f2                	cmp    %esi,%edx
  801b9a:	76 14                	jbe    801bb0 <__udivdi3+0x50>
  801b9c:	31 ff                	xor    %edi,%edi
  801b9e:	31 c0                	xor    %eax,%eax
  801ba0:	89 fa                	mov    %edi,%edx
  801ba2:	83 c4 1c             	add    $0x1c,%esp
  801ba5:	5b                   	pop    %ebx
  801ba6:	5e                   	pop    %esi
  801ba7:	5f                   	pop    %edi
  801ba8:	5d                   	pop    %ebp
  801ba9:	c3                   	ret    
  801baa:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bb0:	0f bd fa             	bsr    %edx,%edi
  801bb3:	83 f7 1f             	xor    $0x1f,%edi
  801bb6:	75 48                	jne    801c00 <__udivdi3+0xa0>
  801bb8:	39 f2                	cmp    %esi,%edx
  801bba:	72 06                	jb     801bc2 <__udivdi3+0x62>
  801bbc:	31 c0                	xor    %eax,%eax
  801bbe:	39 eb                	cmp    %ebp,%ebx
  801bc0:	77 de                	ja     801ba0 <__udivdi3+0x40>
  801bc2:	b8 01 00 00 00       	mov    $0x1,%eax
  801bc7:	eb d7                	jmp    801ba0 <__udivdi3+0x40>
  801bc9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bd0:	89 d9                	mov    %ebx,%ecx
  801bd2:	85 db                	test   %ebx,%ebx
  801bd4:	75 0b                	jne    801be1 <__udivdi3+0x81>
  801bd6:	b8 01 00 00 00       	mov    $0x1,%eax
  801bdb:	31 d2                	xor    %edx,%edx
  801bdd:	f7 f3                	div    %ebx
  801bdf:	89 c1                	mov    %eax,%ecx
  801be1:	31 d2                	xor    %edx,%edx
  801be3:	89 f0                	mov    %esi,%eax
  801be5:	f7 f1                	div    %ecx
  801be7:	89 c6                	mov    %eax,%esi
  801be9:	89 e8                	mov    %ebp,%eax
  801beb:	89 f7                	mov    %esi,%edi
  801bed:	f7 f1                	div    %ecx
  801bef:	89 fa                	mov    %edi,%edx
  801bf1:	83 c4 1c             	add    $0x1c,%esp
  801bf4:	5b                   	pop    %ebx
  801bf5:	5e                   	pop    %esi
  801bf6:	5f                   	pop    %edi
  801bf7:	5d                   	pop    %ebp
  801bf8:	c3                   	ret    
  801bf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c00:	89 f9                	mov    %edi,%ecx
  801c02:	b8 20 00 00 00       	mov    $0x20,%eax
  801c07:	29 f8                	sub    %edi,%eax
  801c09:	d3 e2                	shl    %cl,%edx
  801c0b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c0f:	89 c1                	mov    %eax,%ecx
  801c11:	89 da                	mov    %ebx,%edx
  801c13:	d3 ea                	shr    %cl,%edx
  801c15:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c19:	09 d1                	or     %edx,%ecx
  801c1b:	89 f2                	mov    %esi,%edx
  801c1d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c21:	89 f9                	mov    %edi,%ecx
  801c23:	d3 e3                	shl    %cl,%ebx
  801c25:	89 c1                	mov    %eax,%ecx
  801c27:	d3 ea                	shr    %cl,%edx
  801c29:	89 f9                	mov    %edi,%ecx
  801c2b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c2f:	89 eb                	mov    %ebp,%ebx
  801c31:	d3 e6                	shl    %cl,%esi
  801c33:	89 c1                	mov    %eax,%ecx
  801c35:	d3 eb                	shr    %cl,%ebx
  801c37:	09 de                	or     %ebx,%esi
  801c39:	89 f0                	mov    %esi,%eax
  801c3b:	f7 74 24 08          	divl   0x8(%esp)
  801c3f:	89 d6                	mov    %edx,%esi
  801c41:	89 c3                	mov    %eax,%ebx
  801c43:	f7 64 24 0c          	mull   0xc(%esp)
  801c47:	39 d6                	cmp    %edx,%esi
  801c49:	72 15                	jb     801c60 <__udivdi3+0x100>
  801c4b:	89 f9                	mov    %edi,%ecx
  801c4d:	d3 e5                	shl    %cl,%ebp
  801c4f:	39 c5                	cmp    %eax,%ebp
  801c51:	73 04                	jae    801c57 <__udivdi3+0xf7>
  801c53:	39 d6                	cmp    %edx,%esi
  801c55:	74 09                	je     801c60 <__udivdi3+0x100>
  801c57:	89 d8                	mov    %ebx,%eax
  801c59:	31 ff                	xor    %edi,%edi
  801c5b:	e9 40 ff ff ff       	jmp    801ba0 <__udivdi3+0x40>
  801c60:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c63:	31 ff                	xor    %edi,%edi
  801c65:	e9 36 ff ff ff       	jmp    801ba0 <__udivdi3+0x40>
  801c6a:	66 90                	xchg   %ax,%ax
  801c6c:	66 90                	xchg   %ax,%ax
  801c6e:	66 90                	xchg   %ax,%ax

00801c70 <__umoddi3>:
  801c70:	f3 0f 1e fb          	endbr32 
  801c74:	55                   	push   %ebp
  801c75:	57                   	push   %edi
  801c76:	56                   	push   %esi
  801c77:	53                   	push   %ebx
  801c78:	83 ec 1c             	sub    $0x1c,%esp
  801c7b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801c7f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801c83:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801c87:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c8b:	85 c0                	test   %eax,%eax
  801c8d:	75 19                	jne    801ca8 <__umoddi3+0x38>
  801c8f:	39 df                	cmp    %ebx,%edi
  801c91:	76 5d                	jbe    801cf0 <__umoddi3+0x80>
  801c93:	89 f0                	mov    %esi,%eax
  801c95:	89 da                	mov    %ebx,%edx
  801c97:	f7 f7                	div    %edi
  801c99:	89 d0                	mov    %edx,%eax
  801c9b:	31 d2                	xor    %edx,%edx
  801c9d:	83 c4 1c             	add    $0x1c,%esp
  801ca0:	5b                   	pop    %ebx
  801ca1:	5e                   	pop    %esi
  801ca2:	5f                   	pop    %edi
  801ca3:	5d                   	pop    %ebp
  801ca4:	c3                   	ret    
  801ca5:	8d 76 00             	lea    0x0(%esi),%esi
  801ca8:	89 f2                	mov    %esi,%edx
  801caa:	39 d8                	cmp    %ebx,%eax
  801cac:	76 12                	jbe    801cc0 <__umoddi3+0x50>
  801cae:	89 f0                	mov    %esi,%eax
  801cb0:	89 da                	mov    %ebx,%edx
  801cb2:	83 c4 1c             	add    $0x1c,%esp
  801cb5:	5b                   	pop    %ebx
  801cb6:	5e                   	pop    %esi
  801cb7:	5f                   	pop    %edi
  801cb8:	5d                   	pop    %ebp
  801cb9:	c3                   	ret    
  801cba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cc0:	0f bd e8             	bsr    %eax,%ebp
  801cc3:	83 f5 1f             	xor    $0x1f,%ebp
  801cc6:	75 50                	jne    801d18 <__umoddi3+0xa8>
  801cc8:	39 d8                	cmp    %ebx,%eax
  801cca:	0f 82 e0 00 00 00    	jb     801db0 <__umoddi3+0x140>
  801cd0:	89 d9                	mov    %ebx,%ecx
  801cd2:	39 f7                	cmp    %esi,%edi
  801cd4:	0f 86 d6 00 00 00    	jbe    801db0 <__umoddi3+0x140>
  801cda:	89 d0                	mov    %edx,%eax
  801cdc:	89 ca                	mov    %ecx,%edx
  801cde:	83 c4 1c             	add    $0x1c,%esp
  801ce1:	5b                   	pop    %ebx
  801ce2:	5e                   	pop    %esi
  801ce3:	5f                   	pop    %edi
  801ce4:	5d                   	pop    %ebp
  801ce5:	c3                   	ret    
  801ce6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ced:	8d 76 00             	lea    0x0(%esi),%esi
  801cf0:	89 fd                	mov    %edi,%ebp
  801cf2:	85 ff                	test   %edi,%edi
  801cf4:	75 0b                	jne    801d01 <__umoddi3+0x91>
  801cf6:	b8 01 00 00 00       	mov    $0x1,%eax
  801cfb:	31 d2                	xor    %edx,%edx
  801cfd:	f7 f7                	div    %edi
  801cff:	89 c5                	mov    %eax,%ebp
  801d01:	89 d8                	mov    %ebx,%eax
  801d03:	31 d2                	xor    %edx,%edx
  801d05:	f7 f5                	div    %ebp
  801d07:	89 f0                	mov    %esi,%eax
  801d09:	f7 f5                	div    %ebp
  801d0b:	89 d0                	mov    %edx,%eax
  801d0d:	31 d2                	xor    %edx,%edx
  801d0f:	eb 8c                	jmp    801c9d <__umoddi3+0x2d>
  801d11:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d18:	89 e9                	mov    %ebp,%ecx
  801d1a:	ba 20 00 00 00       	mov    $0x20,%edx
  801d1f:	29 ea                	sub    %ebp,%edx
  801d21:	d3 e0                	shl    %cl,%eax
  801d23:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d27:	89 d1                	mov    %edx,%ecx
  801d29:	89 f8                	mov    %edi,%eax
  801d2b:	d3 e8                	shr    %cl,%eax
  801d2d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d31:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d35:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d39:	09 c1                	or     %eax,%ecx
  801d3b:	89 d8                	mov    %ebx,%eax
  801d3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d41:	89 e9                	mov    %ebp,%ecx
  801d43:	d3 e7                	shl    %cl,%edi
  801d45:	89 d1                	mov    %edx,%ecx
  801d47:	d3 e8                	shr    %cl,%eax
  801d49:	89 e9                	mov    %ebp,%ecx
  801d4b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d4f:	d3 e3                	shl    %cl,%ebx
  801d51:	89 c7                	mov    %eax,%edi
  801d53:	89 d1                	mov    %edx,%ecx
  801d55:	89 f0                	mov    %esi,%eax
  801d57:	d3 e8                	shr    %cl,%eax
  801d59:	89 e9                	mov    %ebp,%ecx
  801d5b:	89 fa                	mov    %edi,%edx
  801d5d:	d3 e6                	shl    %cl,%esi
  801d5f:	09 d8                	or     %ebx,%eax
  801d61:	f7 74 24 08          	divl   0x8(%esp)
  801d65:	89 d1                	mov    %edx,%ecx
  801d67:	89 f3                	mov    %esi,%ebx
  801d69:	f7 64 24 0c          	mull   0xc(%esp)
  801d6d:	89 c6                	mov    %eax,%esi
  801d6f:	89 d7                	mov    %edx,%edi
  801d71:	39 d1                	cmp    %edx,%ecx
  801d73:	72 06                	jb     801d7b <__umoddi3+0x10b>
  801d75:	75 10                	jne    801d87 <__umoddi3+0x117>
  801d77:	39 c3                	cmp    %eax,%ebx
  801d79:	73 0c                	jae    801d87 <__umoddi3+0x117>
  801d7b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801d7f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801d83:	89 d7                	mov    %edx,%edi
  801d85:	89 c6                	mov    %eax,%esi
  801d87:	89 ca                	mov    %ecx,%edx
  801d89:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d8e:	29 f3                	sub    %esi,%ebx
  801d90:	19 fa                	sbb    %edi,%edx
  801d92:	89 d0                	mov    %edx,%eax
  801d94:	d3 e0                	shl    %cl,%eax
  801d96:	89 e9                	mov    %ebp,%ecx
  801d98:	d3 eb                	shr    %cl,%ebx
  801d9a:	d3 ea                	shr    %cl,%edx
  801d9c:	09 d8                	or     %ebx,%eax
  801d9e:	83 c4 1c             	add    $0x1c,%esp
  801da1:	5b                   	pop    %ebx
  801da2:	5e                   	pop    %esi
  801da3:	5f                   	pop    %edi
  801da4:	5d                   	pop    %ebp
  801da5:	c3                   	ret    
  801da6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dad:	8d 76 00             	lea    0x0(%esi),%esi
  801db0:	29 fe                	sub    %edi,%esi
  801db2:	19 c3                	sbb    %eax,%ebx
  801db4:	89 f2                	mov    %esi,%edx
  801db6:	89 d9                	mov    %ebx,%ecx
  801db8:	e9 1d ff ff ff       	jmp    801cda <__umoddi3+0x6a>
