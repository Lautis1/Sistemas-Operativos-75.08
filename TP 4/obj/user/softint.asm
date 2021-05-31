
obj/user/softint.debug:     formato del fichero elf32-i386


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
  80002c:	e8 09 00 00 00       	call   80003a <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
	asm volatile("int $14");	// page fault
  800037:	cd 0e                	int    $0xe
}
  800039:	c3                   	ret    

0080003a <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003a:	f3 0f 1e fb          	endbr32 
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800049:	e8 19 01 00 00       	call   800167 <sys_getenvid>
	if (id >= 0)
  80004e:	85 c0                	test   %eax,%eax
  800050:	78 12                	js     800064 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x35>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
}
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	f3 0f 1e fb          	endbr32 
  80008c:	55                   	push   %ebp
  80008d:	89 e5                	mov    %esp,%ebp
  80008f:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800092:	e8 53 04 00 00       	call   8004ea <close_all>
	sys_env_destroy(0);
  800097:	83 ec 0c             	sub    $0xc,%esp
  80009a:	6a 00                	push   $0x0
  80009c:	e8 a0 00 00 00       	call   800141 <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	57                   	push   %edi
  8000aa:	56                   	push   %esi
  8000ab:	53                   	push   %ebx
  8000ac:	83 ec 1c             	sub    $0x1c,%esp
  8000af:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000b2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000b5:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000ba:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000bd:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000c0:	8b 75 14             	mov    0x14(%ebp),%esi
  8000c3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000c5:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000c9:	74 04                	je     8000cf <syscall+0x29>
  8000cb:	85 c0                	test   %eax,%eax
  8000cd:	7f 08                	jg     8000d7 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000d2:	5b                   	pop    %ebx
  8000d3:	5e                   	pop    %esi
  8000d4:	5f                   	pop    %edi
  8000d5:	5d                   	pop    %ebp
  8000d6:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000d7:	83 ec 0c             	sub    $0xc,%esp
  8000da:	50                   	push   %eax
  8000db:	ff 75 e0             	pushl  -0x20(%ebp)
  8000de:	68 ca 1d 80 00       	push   $0x801dca
  8000e3:	6a 23                	push   $0x23
  8000e5:	68 e7 1d 80 00       	push   $0x801de7
  8000ea:	e8 51 0f 00 00       	call   801040 <_panic>

008000ef <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  8000ef:	f3 0f 1e fb          	endbr32 
  8000f3:	55                   	push   %ebp
  8000f4:	89 e5                	mov    %esp,%ebp
  8000f6:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  8000f9:	6a 00                	push   $0x0
  8000fb:	6a 00                	push   $0x0
  8000fd:	6a 00                	push   $0x0
  8000ff:	ff 75 0c             	pushl  0xc(%ebp)
  800102:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800105:	ba 00 00 00 00       	mov    $0x0,%edx
  80010a:	b8 00 00 00 00       	mov    $0x0,%eax
  80010f:	e8 92 ff ff ff       	call   8000a6 <syscall>
}
  800114:	83 c4 10             	add    $0x10,%esp
  800117:	c9                   	leave  
  800118:	c3                   	ret    

00800119 <sys_cgetc>:

int
sys_cgetc(void)
{
  800119:	f3 0f 1e fb          	endbr32 
  80011d:	55                   	push   %ebp
  80011e:	89 e5                	mov    %esp,%ebp
  800120:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800123:	6a 00                	push   $0x0
  800125:	6a 00                	push   $0x0
  800127:	6a 00                	push   $0x0
  800129:	6a 00                	push   $0x0
  80012b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800130:	ba 00 00 00 00       	mov    $0x0,%edx
  800135:	b8 01 00 00 00       	mov    $0x1,%eax
  80013a:	e8 67 ff ff ff       	call   8000a6 <syscall>
}
  80013f:	c9                   	leave  
  800140:	c3                   	ret    

00800141 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800141:	f3 0f 1e fb          	endbr32 
  800145:	55                   	push   %ebp
  800146:	89 e5                	mov    %esp,%ebp
  800148:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80014b:	6a 00                	push   $0x0
  80014d:	6a 00                	push   $0x0
  80014f:	6a 00                	push   $0x0
  800151:	6a 00                	push   $0x0
  800153:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800156:	ba 01 00 00 00       	mov    $0x1,%edx
  80015b:	b8 03 00 00 00       	mov    $0x3,%eax
  800160:	e8 41 ff ff ff       	call   8000a6 <syscall>
}
  800165:	c9                   	leave  
  800166:	c3                   	ret    

00800167 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800167:	f3 0f 1e fb          	endbr32 
  80016b:	55                   	push   %ebp
  80016c:	89 e5                	mov    %esp,%ebp
  80016e:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800171:	6a 00                	push   $0x0
  800173:	6a 00                	push   $0x0
  800175:	6a 00                	push   $0x0
  800177:	6a 00                	push   $0x0
  800179:	b9 00 00 00 00       	mov    $0x0,%ecx
  80017e:	ba 00 00 00 00       	mov    $0x0,%edx
  800183:	b8 02 00 00 00       	mov    $0x2,%eax
  800188:	e8 19 ff ff ff       	call   8000a6 <syscall>
}
  80018d:	c9                   	leave  
  80018e:	c3                   	ret    

0080018f <sys_yield>:

void
sys_yield(void)
{
  80018f:	f3 0f 1e fb          	endbr32 
  800193:	55                   	push   %ebp
  800194:	89 e5                	mov    %esp,%ebp
  800196:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  800199:	6a 00                	push   $0x0
  80019b:	6a 00                	push   $0x0
  80019d:	6a 00                	push   $0x0
  80019f:	6a 00                	push   $0x0
  8001a1:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8001ab:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001b0:	e8 f1 fe ff ff       	call   8000a6 <syscall>
}
  8001b5:	83 c4 10             	add    $0x10,%esp
  8001b8:	c9                   	leave  
  8001b9:	c3                   	ret    

008001ba <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001ba:	f3 0f 1e fb          	endbr32 
  8001be:	55                   	push   %ebp
  8001bf:	89 e5                	mov    %esp,%ebp
  8001c1:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001c4:	6a 00                	push   $0x0
  8001c6:	6a 00                	push   $0x0
  8001c8:	ff 75 10             	pushl  0x10(%ebp)
  8001cb:	ff 75 0c             	pushl  0xc(%ebp)
  8001ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001d1:	ba 01 00 00 00       	mov    $0x1,%edx
  8001d6:	b8 04 00 00 00       	mov    $0x4,%eax
  8001db:	e8 c6 fe ff ff       	call   8000a6 <syscall>
}
  8001e0:	c9                   	leave  
  8001e1:	c3                   	ret    

008001e2 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001e2:	f3 0f 1e fb          	endbr32 
  8001e6:	55                   	push   %ebp
  8001e7:	89 e5                	mov    %esp,%ebp
  8001e9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001ec:	ff 75 18             	pushl  0x18(%ebp)
  8001ef:	ff 75 14             	pushl  0x14(%ebp)
  8001f2:	ff 75 10             	pushl  0x10(%ebp)
  8001f5:	ff 75 0c             	pushl  0xc(%ebp)
  8001f8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001fb:	ba 01 00 00 00       	mov    $0x1,%edx
  800200:	b8 05 00 00 00       	mov    $0x5,%eax
  800205:	e8 9c fe ff ff       	call   8000a6 <syscall>
}
  80020a:	c9                   	leave  
  80020b:	c3                   	ret    

0080020c <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80020c:	f3 0f 1e fb          	endbr32 
  800210:	55                   	push   %ebp
  800211:	89 e5                	mov    %esp,%ebp
  800213:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800216:	6a 00                	push   $0x0
  800218:	6a 00                	push   $0x0
  80021a:	6a 00                	push   $0x0
  80021c:	ff 75 0c             	pushl  0xc(%ebp)
  80021f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800222:	ba 01 00 00 00       	mov    $0x1,%edx
  800227:	b8 06 00 00 00       	mov    $0x6,%eax
  80022c:	e8 75 fe ff ff       	call   8000a6 <syscall>
}
  800231:	c9                   	leave  
  800232:	c3                   	ret    

00800233 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800233:	f3 0f 1e fb          	endbr32 
  800237:	55                   	push   %ebp
  800238:	89 e5                	mov    %esp,%ebp
  80023a:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80023d:	6a 00                	push   $0x0
  80023f:	6a 00                	push   $0x0
  800241:	6a 00                	push   $0x0
  800243:	ff 75 0c             	pushl  0xc(%ebp)
  800246:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800249:	ba 01 00 00 00       	mov    $0x1,%edx
  80024e:	b8 08 00 00 00       	mov    $0x8,%eax
  800253:	e8 4e fe ff ff       	call   8000a6 <syscall>
}
  800258:	c9                   	leave  
  800259:	c3                   	ret    

0080025a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80025a:	f3 0f 1e fb          	endbr32 
  80025e:	55                   	push   %ebp
  80025f:	89 e5                	mov    %esp,%ebp
  800261:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800264:	6a 00                	push   $0x0
  800266:	6a 00                	push   $0x0
  800268:	6a 00                	push   $0x0
  80026a:	ff 75 0c             	pushl  0xc(%ebp)
  80026d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800270:	ba 01 00 00 00       	mov    $0x1,%edx
  800275:	b8 09 00 00 00       	mov    $0x9,%eax
  80027a:	e8 27 fe ff ff       	call   8000a6 <syscall>
}
  80027f:	c9                   	leave  
  800280:	c3                   	ret    

00800281 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800281:	f3 0f 1e fb          	endbr32 
  800285:	55                   	push   %ebp
  800286:	89 e5                	mov    %esp,%ebp
  800288:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80028b:	6a 00                	push   $0x0
  80028d:	6a 00                	push   $0x0
  80028f:	6a 00                	push   $0x0
  800291:	ff 75 0c             	pushl  0xc(%ebp)
  800294:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800297:	ba 01 00 00 00       	mov    $0x1,%edx
  80029c:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002a1:	e8 00 fe ff ff       	call   8000a6 <syscall>
}
  8002a6:	c9                   	leave  
  8002a7:	c3                   	ret    

008002a8 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002a8:	f3 0f 1e fb          	endbr32 
  8002ac:	55                   	push   %ebp
  8002ad:	89 e5                	mov    %esp,%ebp
  8002af:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8002b2:	6a 00                	push   $0x0
  8002b4:	ff 75 14             	pushl  0x14(%ebp)
  8002b7:	ff 75 10             	pushl  0x10(%ebp)
  8002ba:	ff 75 0c             	pushl  0xc(%ebp)
  8002bd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8002c5:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002ca:	e8 d7 fd ff ff       	call   8000a6 <syscall>
}
  8002cf:	c9                   	leave  
  8002d0:	c3                   	ret    

008002d1 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d1:	f3 0f 1e fb          	endbr32 
  8002d5:	55                   	push   %ebp
  8002d6:	89 e5                	mov    %esp,%ebp
  8002d8:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002db:	6a 00                	push   $0x0
  8002dd:	6a 00                	push   $0x0
  8002df:	6a 00                	push   $0x0
  8002e1:	6a 00                	push   $0x0
  8002e3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002e6:	ba 01 00 00 00       	mov    $0x1,%edx
  8002eb:	b8 0d 00 00 00       	mov    $0xd,%eax
  8002f0:	e8 b1 fd ff ff       	call   8000a6 <syscall>
}
  8002f5:	c9                   	leave  
  8002f6:	c3                   	ret    

008002f7 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  8002f7:	f3 0f 1e fb          	endbr32 
  8002fb:	55                   	push   %ebp
  8002fc:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  8002fe:	8b 45 08             	mov    0x8(%ebp),%eax
  800301:	05 00 00 00 30       	add    $0x30000000,%eax
  800306:	c1 e8 0c             	shr    $0xc,%eax
}
  800309:	5d                   	pop    %ebp
  80030a:	c3                   	ret    

0080030b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80030b:	f3 0f 1e fb          	endbr32 
  80030f:	55                   	push   %ebp
  800310:	89 e5                	mov    %esp,%ebp
  800312:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800315:	ff 75 08             	pushl  0x8(%ebp)
  800318:	e8 da ff ff ff       	call   8002f7 <fd2num>
  80031d:	83 c4 10             	add    $0x10,%esp
  800320:	c1 e0 0c             	shl    $0xc,%eax
  800323:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800328:	c9                   	leave  
  800329:	c3                   	ret    

0080032a <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80032a:	f3 0f 1e fb          	endbr32 
  80032e:	55                   	push   %ebp
  80032f:	89 e5                	mov    %esp,%ebp
  800331:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800336:	89 c2                	mov    %eax,%edx
  800338:	c1 ea 16             	shr    $0x16,%edx
  80033b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800342:	f6 c2 01             	test   $0x1,%dl
  800345:	74 2d                	je     800374 <fd_alloc+0x4a>
  800347:	89 c2                	mov    %eax,%edx
  800349:	c1 ea 0c             	shr    $0xc,%edx
  80034c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800353:	f6 c2 01             	test   $0x1,%dl
  800356:	74 1c                	je     800374 <fd_alloc+0x4a>
  800358:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80035d:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800362:	75 d2                	jne    800336 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800364:	8b 45 08             	mov    0x8(%ebp),%eax
  800367:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80036d:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800372:	eb 0a                	jmp    80037e <fd_alloc+0x54>
			*fd_store = fd;
  800374:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800377:	89 01                	mov    %eax,(%ecx)
			return 0;
  800379:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80037e:	5d                   	pop    %ebp
  80037f:	c3                   	ret    

00800380 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800380:	f3 0f 1e fb          	endbr32 
  800384:	55                   	push   %ebp
  800385:	89 e5                	mov    %esp,%ebp
  800387:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80038a:	83 f8 1f             	cmp    $0x1f,%eax
  80038d:	77 30                	ja     8003bf <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  80038f:	c1 e0 0c             	shl    $0xc,%eax
  800392:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  800397:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  80039d:	f6 c2 01             	test   $0x1,%dl
  8003a0:	74 24                	je     8003c6 <fd_lookup+0x46>
  8003a2:	89 c2                	mov    %eax,%edx
  8003a4:	c1 ea 0c             	shr    $0xc,%edx
  8003a7:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003ae:	f6 c2 01             	test   $0x1,%dl
  8003b1:	74 1a                	je     8003cd <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003b3:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003b6:	89 02                	mov    %eax,(%edx)
	return 0;
  8003b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003bd:	5d                   	pop    %ebp
  8003be:	c3                   	ret    
		return -E_INVAL;
  8003bf:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003c4:	eb f7                	jmp    8003bd <fd_lookup+0x3d>
		return -E_INVAL;
  8003c6:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003cb:	eb f0                	jmp    8003bd <fd_lookup+0x3d>
  8003cd:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003d2:	eb e9                	jmp    8003bd <fd_lookup+0x3d>

008003d4 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003d4:	f3 0f 1e fb          	endbr32 
  8003d8:	55                   	push   %ebp
  8003d9:	89 e5                	mov    %esp,%ebp
  8003db:	83 ec 08             	sub    $0x8,%esp
  8003de:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003e1:	ba 74 1e 80 00       	mov    $0x801e74,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8003e6:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8003eb:	39 08                	cmp    %ecx,(%eax)
  8003ed:	74 33                	je     800422 <dev_lookup+0x4e>
  8003ef:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  8003f2:	8b 02                	mov    (%edx),%eax
  8003f4:	85 c0                	test   %eax,%eax
  8003f6:	75 f3                	jne    8003eb <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  8003f8:	a1 04 40 80 00       	mov    0x804004,%eax
  8003fd:	8b 40 48             	mov    0x48(%eax),%eax
  800400:	83 ec 04             	sub    $0x4,%esp
  800403:	51                   	push   %ecx
  800404:	50                   	push   %eax
  800405:	68 f8 1d 80 00       	push   $0x801df8
  80040a:	e8 18 0d 00 00       	call   801127 <cprintf>
	*dev = 0;
  80040f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800412:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800418:	83 c4 10             	add    $0x10,%esp
  80041b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800420:	c9                   	leave  
  800421:	c3                   	ret    
			*dev = devtab[i];
  800422:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800425:	89 01                	mov    %eax,(%ecx)
			return 0;
  800427:	b8 00 00 00 00       	mov    $0x0,%eax
  80042c:	eb f2                	jmp    800420 <dev_lookup+0x4c>

0080042e <fd_close>:
{
  80042e:	f3 0f 1e fb          	endbr32 
  800432:	55                   	push   %ebp
  800433:	89 e5                	mov    %esp,%ebp
  800435:	57                   	push   %edi
  800436:	56                   	push   %esi
  800437:	53                   	push   %ebx
  800438:	83 ec 28             	sub    $0x28,%esp
  80043b:	8b 75 08             	mov    0x8(%ebp),%esi
  80043e:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800441:	56                   	push   %esi
  800442:	e8 b0 fe ff ff       	call   8002f7 <fd2num>
  800447:	83 c4 08             	add    $0x8,%esp
  80044a:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80044d:	52                   	push   %edx
  80044e:	50                   	push   %eax
  80044f:	e8 2c ff ff ff       	call   800380 <fd_lookup>
  800454:	89 c3                	mov    %eax,%ebx
  800456:	83 c4 10             	add    $0x10,%esp
  800459:	85 c0                	test   %eax,%eax
  80045b:	78 05                	js     800462 <fd_close+0x34>
	    || fd != fd2)
  80045d:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800460:	74 16                	je     800478 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800462:	89 f8                	mov    %edi,%eax
  800464:	84 c0                	test   %al,%al
  800466:	b8 00 00 00 00       	mov    $0x0,%eax
  80046b:	0f 44 d8             	cmove  %eax,%ebx
}
  80046e:	89 d8                	mov    %ebx,%eax
  800470:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800473:	5b                   	pop    %ebx
  800474:	5e                   	pop    %esi
  800475:	5f                   	pop    %edi
  800476:	5d                   	pop    %ebp
  800477:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800478:	83 ec 08             	sub    $0x8,%esp
  80047b:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80047e:	50                   	push   %eax
  80047f:	ff 36                	pushl  (%esi)
  800481:	e8 4e ff ff ff       	call   8003d4 <dev_lookup>
  800486:	89 c3                	mov    %eax,%ebx
  800488:	83 c4 10             	add    $0x10,%esp
  80048b:	85 c0                	test   %eax,%eax
  80048d:	78 1a                	js     8004a9 <fd_close+0x7b>
		if (dev->dev_close)
  80048f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  800492:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  800495:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  80049a:	85 c0                	test   %eax,%eax
  80049c:	74 0b                	je     8004a9 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  80049e:	83 ec 0c             	sub    $0xc,%esp
  8004a1:	56                   	push   %esi
  8004a2:	ff d0                	call   *%eax
  8004a4:	89 c3                	mov    %eax,%ebx
  8004a6:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004a9:	83 ec 08             	sub    $0x8,%esp
  8004ac:	56                   	push   %esi
  8004ad:	6a 00                	push   $0x0
  8004af:	e8 58 fd ff ff       	call   80020c <sys_page_unmap>
	return r;
  8004b4:	83 c4 10             	add    $0x10,%esp
  8004b7:	eb b5                	jmp    80046e <fd_close+0x40>

008004b9 <close>:

int
close(int fdnum)
{
  8004b9:	f3 0f 1e fb          	endbr32 
  8004bd:	55                   	push   %ebp
  8004be:	89 e5                	mov    %esp,%ebp
  8004c0:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004c3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004c6:	50                   	push   %eax
  8004c7:	ff 75 08             	pushl  0x8(%ebp)
  8004ca:	e8 b1 fe ff ff       	call   800380 <fd_lookup>
  8004cf:	83 c4 10             	add    $0x10,%esp
  8004d2:	85 c0                	test   %eax,%eax
  8004d4:	79 02                	jns    8004d8 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8004d6:	c9                   	leave  
  8004d7:	c3                   	ret    
		return fd_close(fd, 1);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	6a 01                	push   $0x1
  8004dd:	ff 75 f4             	pushl  -0xc(%ebp)
  8004e0:	e8 49 ff ff ff       	call   80042e <fd_close>
  8004e5:	83 c4 10             	add    $0x10,%esp
  8004e8:	eb ec                	jmp    8004d6 <close+0x1d>

008004ea <close_all>:

void
close_all(void)
{
  8004ea:	f3 0f 1e fb          	endbr32 
  8004ee:	55                   	push   %ebp
  8004ef:	89 e5                	mov    %esp,%ebp
  8004f1:	53                   	push   %ebx
  8004f2:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  8004f5:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  8004fa:	83 ec 0c             	sub    $0xc,%esp
  8004fd:	53                   	push   %ebx
  8004fe:	e8 b6 ff ff ff       	call   8004b9 <close>
	for (i = 0; i < MAXFD; i++)
  800503:	83 c3 01             	add    $0x1,%ebx
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	83 fb 20             	cmp    $0x20,%ebx
  80050c:	75 ec                	jne    8004fa <close_all+0x10>
}
  80050e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800511:	c9                   	leave  
  800512:	c3                   	ret    

00800513 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800513:	f3 0f 1e fb          	endbr32 
  800517:	55                   	push   %ebp
  800518:	89 e5                	mov    %esp,%ebp
  80051a:	57                   	push   %edi
  80051b:	56                   	push   %esi
  80051c:	53                   	push   %ebx
  80051d:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800520:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800523:	50                   	push   %eax
  800524:	ff 75 08             	pushl  0x8(%ebp)
  800527:	e8 54 fe ff ff       	call   800380 <fd_lookup>
  80052c:	89 c3                	mov    %eax,%ebx
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	85 c0                	test   %eax,%eax
  800533:	0f 88 81 00 00 00    	js     8005ba <dup+0xa7>
		return r;
	close(newfdnum);
  800539:	83 ec 0c             	sub    $0xc,%esp
  80053c:	ff 75 0c             	pushl  0xc(%ebp)
  80053f:	e8 75 ff ff ff       	call   8004b9 <close>

	newfd = INDEX2FD(newfdnum);
  800544:	8b 75 0c             	mov    0xc(%ebp),%esi
  800547:	c1 e6 0c             	shl    $0xc,%esi
  80054a:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800550:	83 c4 04             	add    $0x4,%esp
  800553:	ff 75 e4             	pushl  -0x1c(%ebp)
  800556:	e8 b0 fd ff ff       	call   80030b <fd2data>
  80055b:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80055d:	89 34 24             	mov    %esi,(%esp)
  800560:	e8 a6 fd ff ff       	call   80030b <fd2data>
  800565:	83 c4 10             	add    $0x10,%esp
  800568:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80056a:	89 d8                	mov    %ebx,%eax
  80056c:	c1 e8 16             	shr    $0x16,%eax
  80056f:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800576:	a8 01                	test   $0x1,%al
  800578:	74 11                	je     80058b <dup+0x78>
  80057a:	89 d8                	mov    %ebx,%eax
  80057c:	c1 e8 0c             	shr    $0xc,%eax
  80057f:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800586:	f6 c2 01             	test   $0x1,%dl
  800589:	75 39                	jne    8005c4 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80058b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80058e:	89 d0                	mov    %edx,%eax
  800590:	c1 e8 0c             	shr    $0xc,%eax
  800593:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80059a:	83 ec 0c             	sub    $0xc,%esp
  80059d:	25 07 0e 00 00       	and    $0xe07,%eax
  8005a2:	50                   	push   %eax
  8005a3:	56                   	push   %esi
  8005a4:	6a 00                	push   $0x0
  8005a6:	52                   	push   %edx
  8005a7:	6a 00                	push   $0x0
  8005a9:	e8 34 fc ff ff       	call   8001e2 <sys_page_map>
  8005ae:	89 c3                	mov    %eax,%ebx
  8005b0:	83 c4 20             	add    $0x20,%esp
  8005b3:	85 c0                	test   %eax,%eax
  8005b5:	78 31                	js     8005e8 <dup+0xd5>
		goto err;

	return newfdnum;
  8005b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005ba:	89 d8                	mov    %ebx,%eax
  8005bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005bf:	5b                   	pop    %ebx
  8005c0:	5e                   	pop    %esi
  8005c1:	5f                   	pop    %edi
  8005c2:	5d                   	pop    %ebp
  8005c3:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005c4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005cb:	83 ec 0c             	sub    $0xc,%esp
  8005ce:	25 07 0e 00 00       	and    $0xe07,%eax
  8005d3:	50                   	push   %eax
  8005d4:	57                   	push   %edi
  8005d5:	6a 00                	push   $0x0
  8005d7:	53                   	push   %ebx
  8005d8:	6a 00                	push   $0x0
  8005da:	e8 03 fc ff ff       	call   8001e2 <sys_page_map>
  8005df:	89 c3                	mov    %eax,%ebx
  8005e1:	83 c4 20             	add    $0x20,%esp
  8005e4:	85 c0                	test   %eax,%eax
  8005e6:	79 a3                	jns    80058b <dup+0x78>
	sys_page_unmap(0, newfd);
  8005e8:	83 ec 08             	sub    $0x8,%esp
  8005eb:	56                   	push   %esi
  8005ec:	6a 00                	push   $0x0
  8005ee:	e8 19 fc ff ff       	call   80020c <sys_page_unmap>
	sys_page_unmap(0, nva);
  8005f3:	83 c4 08             	add    $0x8,%esp
  8005f6:	57                   	push   %edi
  8005f7:	6a 00                	push   $0x0
  8005f9:	e8 0e fc ff ff       	call   80020c <sys_page_unmap>
	return r;
  8005fe:	83 c4 10             	add    $0x10,%esp
  800601:	eb b7                	jmp    8005ba <dup+0xa7>

00800603 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800603:	f3 0f 1e fb          	endbr32 
  800607:	55                   	push   %ebp
  800608:	89 e5                	mov    %esp,%ebp
  80060a:	53                   	push   %ebx
  80060b:	83 ec 1c             	sub    $0x1c,%esp
  80060e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800611:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800614:	50                   	push   %eax
  800615:	53                   	push   %ebx
  800616:	e8 65 fd ff ff       	call   800380 <fd_lookup>
  80061b:	83 c4 10             	add    $0x10,%esp
  80061e:	85 c0                	test   %eax,%eax
  800620:	78 3f                	js     800661 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800622:	83 ec 08             	sub    $0x8,%esp
  800625:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800628:	50                   	push   %eax
  800629:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80062c:	ff 30                	pushl  (%eax)
  80062e:	e8 a1 fd ff ff       	call   8003d4 <dev_lookup>
  800633:	83 c4 10             	add    $0x10,%esp
  800636:	85 c0                	test   %eax,%eax
  800638:	78 27                	js     800661 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80063a:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80063d:	8b 42 08             	mov    0x8(%edx),%eax
  800640:	83 e0 03             	and    $0x3,%eax
  800643:	83 f8 01             	cmp    $0x1,%eax
  800646:	74 1e                	je     800666 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800648:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80064b:	8b 40 08             	mov    0x8(%eax),%eax
  80064e:	85 c0                	test   %eax,%eax
  800650:	74 35                	je     800687 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800652:	83 ec 04             	sub    $0x4,%esp
  800655:	ff 75 10             	pushl  0x10(%ebp)
  800658:	ff 75 0c             	pushl  0xc(%ebp)
  80065b:	52                   	push   %edx
  80065c:	ff d0                	call   *%eax
  80065e:	83 c4 10             	add    $0x10,%esp
}
  800661:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800664:	c9                   	leave  
  800665:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800666:	a1 04 40 80 00       	mov    0x804004,%eax
  80066b:	8b 40 48             	mov    0x48(%eax),%eax
  80066e:	83 ec 04             	sub    $0x4,%esp
  800671:	53                   	push   %ebx
  800672:	50                   	push   %eax
  800673:	68 39 1e 80 00       	push   $0x801e39
  800678:	e8 aa 0a 00 00       	call   801127 <cprintf>
		return -E_INVAL;
  80067d:	83 c4 10             	add    $0x10,%esp
  800680:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800685:	eb da                	jmp    800661 <read+0x5e>
		return -E_NOT_SUPP;
  800687:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80068c:	eb d3                	jmp    800661 <read+0x5e>

0080068e <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80068e:	f3 0f 1e fb          	endbr32 
  800692:	55                   	push   %ebp
  800693:	89 e5                	mov    %esp,%ebp
  800695:	57                   	push   %edi
  800696:	56                   	push   %esi
  800697:	53                   	push   %ebx
  800698:	83 ec 0c             	sub    $0xc,%esp
  80069b:	8b 7d 08             	mov    0x8(%ebp),%edi
  80069e:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006a1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006a6:	eb 02                	jmp    8006aa <readn+0x1c>
  8006a8:	01 c3                	add    %eax,%ebx
  8006aa:	39 f3                	cmp    %esi,%ebx
  8006ac:	73 21                	jae    8006cf <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ae:	83 ec 04             	sub    $0x4,%esp
  8006b1:	89 f0                	mov    %esi,%eax
  8006b3:	29 d8                	sub    %ebx,%eax
  8006b5:	50                   	push   %eax
  8006b6:	89 d8                	mov    %ebx,%eax
  8006b8:	03 45 0c             	add    0xc(%ebp),%eax
  8006bb:	50                   	push   %eax
  8006bc:	57                   	push   %edi
  8006bd:	e8 41 ff ff ff       	call   800603 <read>
		if (m < 0)
  8006c2:	83 c4 10             	add    $0x10,%esp
  8006c5:	85 c0                	test   %eax,%eax
  8006c7:	78 04                	js     8006cd <readn+0x3f>
			return m;
		if (m == 0)
  8006c9:	75 dd                	jne    8006a8 <readn+0x1a>
  8006cb:	eb 02                	jmp    8006cf <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006cd:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006cf:	89 d8                	mov    %ebx,%eax
  8006d1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006d4:	5b                   	pop    %ebx
  8006d5:	5e                   	pop    %esi
  8006d6:	5f                   	pop    %edi
  8006d7:	5d                   	pop    %ebp
  8006d8:	c3                   	ret    

008006d9 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006d9:	f3 0f 1e fb          	endbr32 
  8006dd:	55                   	push   %ebp
  8006de:	89 e5                	mov    %esp,%ebp
  8006e0:	53                   	push   %ebx
  8006e1:	83 ec 1c             	sub    $0x1c,%esp
  8006e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006ea:	50                   	push   %eax
  8006eb:	53                   	push   %ebx
  8006ec:	e8 8f fc ff ff       	call   800380 <fd_lookup>
  8006f1:	83 c4 10             	add    $0x10,%esp
  8006f4:	85 c0                	test   %eax,%eax
  8006f6:	78 3a                	js     800732 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006f8:	83 ec 08             	sub    $0x8,%esp
  8006fb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8006fe:	50                   	push   %eax
  8006ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800702:	ff 30                	pushl  (%eax)
  800704:	e8 cb fc ff ff       	call   8003d4 <dev_lookup>
  800709:	83 c4 10             	add    $0x10,%esp
  80070c:	85 c0                	test   %eax,%eax
  80070e:	78 22                	js     800732 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800710:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800713:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800717:	74 1e                	je     800737 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800719:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80071c:	8b 52 0c             	mov    0xc(%edx),%edx
  80071f:	85 d2                	test   %edx,%edx
  800721:	74 35                	je     800758 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800723:	83 ec 04             	sub    $0x4,%esp
  800726:	ff 75 10             	pushl  0x10(%ebp)
  800729:	ff 75 0c             	pushl  0xc(%ebp)
  80072c:	50                   	push   %eax
  80072d:	ff d2                	call   *%edx
  80072f:	83 c4 10             	add    $0x10,%esp
}
  800732:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800735:	c9                   	leave  
  800736:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800737:	a1 04 40 80 00       	mov    0x804004,%eax
  80073c:	8b 40 48             	mov    0x48(%eax),%eax
  80073f:	83 ec 04             	sub    $0x4,%esp
  800742:	53                   	push   %ebx
  800743:	50                   	push   %eax
  800744:	68 55 1e 80 00       	push   $0x801e55
  800749:	e8 d9 09 00 00       	call   801127 <cprintf>
		return -E_INVAL;
  80074e:	83 c4 10             	add    $0x10,%esp
  800751:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800756:	eb da                	jmp    800732 <write+0x59>
		return -E_NOT_SUPP;
  800758:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80075d:	eb d3                	jmp    800732 <write+0x59>

0080075f <seek>:

int
seek(int fdnum, off_t offset)
{
  80075f:	f3 0f 1e fb          	endbr32 
  800763:	55                   	push   %ebp
  800764:	89 e5                	mov    %esp,%ebp
  800766:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800769:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80076c:	50                   	push   %eax
  80076d:	ff 75 08             	pushl  0x8(%ebp)
  800770:	e8 0b fc ff ff       	call   800380 <fd_lookup>
  800775:	83 c4 10             	add    $0x10,%esp
  800778:	85 c0                	test   %eax,%eax
  80077a:	78 0e                	js     80078a <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80077c:	8b 55 0c             	mov    0xc(%ebp),%edx
  80077f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800782:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800785:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80078a:	c9                   	leave  
  80078b:	c3                   	ret    

0080078c <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80078c:	f3 0f 1e fb          	endbr32 
  800790:	55                   	push   %ebp
  800791:	89 e5                	mov    %esp,%ebp
  800793:	53                   	push   %ebx
  800794:	83 ec 1c             	sub    $0x1c,%esp
  800797:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  80079a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80079d:	50                   	push   %eax
  80079e:	53                   	push   %ebx
  80079f:	e8 dc fb ff ff       	call   800380 <fd_lookup>
  8007a4:	83 c4 10             	add    $0x10,%esp
  8007a7:	85 c0                	test   %eax,%eax
  8007a9:	78 37                	js     8007e2 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007ab:	83 ec 08             	sub    $0x8,%esp
  8007ae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007b1:	50                   	push   %eax
  8007b2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007b5:	ff 30                	pushl  (%eax)
  8007b7:	e8 18 fc ff ff       	call   8003d4 <dev_lookup>
  8007bc:	83 c4 10             	add    $0x10,%esp
  8007bf:	85 c0                	test   %eax,%eax
  8007c1:	78 1f                	js     8007e2 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c6:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007ca:	74 1b                	je     8007e7 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007cc:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007cf:	8b 52 18             	mov    0x18(%edx),%edx
  8007d2:	85 d2                	test   %edx,%edx
  8007d4:	74 32                	je     800808 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007d6:	83 ec 08             	sub    $0x8,%esp
  8007d9:	ff 75 0c             	pushl  0xc(%ebp)
  8007dc:	50                   	push   %eax
  8007dd:	ff d2                	call   *%edx
  8007df:	83 c4 10             	add    $0x10,%esp
}
  8007e2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007e5:	c9                   	leave  
  8007e6:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007e7:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007ec:	8b 40 48             	mov    0x48(%eax),%eax
  8007ef:	83 ec 04             	sub    $0x4,%esp
  8007f2:	53                   	push   %ebx
  8007f3:	50                   	push   %eax
  8007f4:	68 18 1e 80 00       	push   $0x801e18
  8007f9:	e8 29 09 00 00       	call   801127 <cprintf>
		return -E_INVAL;
  8007fe:	83 c4 10             	add    $0x10,%esp
  800801:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800806:	eb da                	jmp    8007e2 <ftruncate+0x56>
		return -E_NOT_SUPP;
  800808:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80080d:	eb d3                	jmp    8007e2 <ftruncate+0x56>

0080080f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80080f:	f3 0f 1e fb          	endbr32 
  800813:	55                   	push   %ebp
  800814:	89 e5                	mov    %esp,%ebp
  800816:	53                   	push   %ebx
  800817:	83 ec 1c             	sub    $0x1c,%esp
  80081a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80081d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800820:	50                   	push   %eax
  800821:	ff 75 08             	pushl  0x8(%ebp)
  800824:	e8 57 fb ff ff       	call   800380 <fd_lookup>
  800829:	83 c4 10             	add    $0x10,%esp
  80082c:	85 c0                	test   %eax,%eax
  80082e:	78 4b                	js     80087b <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800830:	83 ec 08             	sub    $0x8,%esp
  800833:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800836:	50                   	push   %eax
  800837:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80083a:	ff 30                	pushl  (%eax)
  80083c:	e8 93 fb ff ff       	call   8003d4 <dev_lookup>
  800841:	83 c4 10             	add    $0x10,%esp
  800844:	85 c0                	test   %eax,%eax
  800846:	78 33                	js     80087b <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  800848:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80084b:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80084f:	74 2f                	je     800880 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800851:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800854:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80085b:	00 00 00 
	stat->st_isdir = 0;
  80085e:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800865:	00 00 00 
	stat->st_dev = dev;
  800868:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	53                   	push   %ebx
  800872:	ff 75 f0             	pushl  -0x10(%ebp)
  800875:	ff 50 14             	call   *0x14(%eax)
  800878:	83 c4 10             	add    $0x10,%esp
}
  80087b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80087e:	c9                   	leave  
  80087f:	c3                   	ret    
		return -E_NOT_SUPP;
  800880:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800885:	eb f4                	jmp    80087b <fstat+0x6c>

00800887 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800887:	f3 0f 1e fb          	endbr32 
  80088b:	55                   	push   %ebp
  80088c:	89 e5                	mov    %esp,%ebp
  80088e:	56                   	push   %esi
  80088f:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  800890:	83 ec 08             	sub    $0x8,%esp
  800893:	6a 00                	push   $0x0
  800895:	ff 75 08             	pushl  0x8(%ebp)
  800898:	e8 fb 01 00 00       	call   800a98 <open>
  80089d:	89 c3                	mov    %eax,%ebx
  80089f:	83 c4 10             	add    $0x10,%esp
  8008a2:	85 c0                	test   %eax,%eax
  8008a4:	78 1b                	js     8008c1 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8008a6:	83 ec 08             	sub    $0x8,%esp
  8008a9:	ff 75 0c             	pushl  0xc(%ebp)
  8008ac:	50                   	push   %eax
  8008ad:	e8 5d ff ff ff       	call   80080f <fstat>
  8008b2:	89 c6                	mov    %eax,%esi
	close(fd);
  8008b4:	89 1c 24             	mov    %ebx,(%esp)
  8008b7:	e8 fd fb ff ff       	call   8004b9 <close>
	return r;
  8008bc:	83 c4 10             	add    $0x10,%esp
  8008bf:	89 f3                	mov    %esi,%ebx
}
  8008c1:	89 d8                	mov    %ebx,%eax
  8008c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008c6:	5b                   	pop    %ebx
  8008c7:	5e                   	pop    %esi
  8008c8:	5d                   	pop    %ebp
  8008c9:	c3                   	ret    

008008ca <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008ca:	55                   	push   %ebp
  8008cb:	89 e5                	mov    %esp,%ebp
  8008cd:	56                   	push   %esi
  8008ce:	53                   	push   %ebx
  8008cf:	89 c6                	mov    %eax,%esi
  8008d1:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008d3:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008da:	74 27                	je     800903 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008dc:	6a 07                	push   $0x7
  8008de:	68 00 50 80 00       	push   $0x805000
  8008e3:	56                   	push   %esi
  8008e4:	ff 35 00 40 80 00    	pushl  0x804000
  8008ea:	e8 84 11 00 00       	call   801a73 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  8008ef:	83 c4 0c             	add    $0xc,%esp
  8008f2:	6a 00                	push   $0x0
  8008f4:	53                   	push   %ebx
  8008f5:	6a 00                	push   $0x0
  8008f7:	e8 09 11 00 00       	call   801a05 <ipc_recv>
}
  8008fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800903:	83 ec 0c             	sub    $0xc,%esp
  800906:	6a 01                	push   $0x1
  800908:	e8 cb 11 00 00       	call   801ad8 <ipc_find_env>
  80090d:	a3 00 40 80 00       	mov    %eax,0x804000
  800912:	83 c4 10             	add    $0x10,%esp
  800915:	eb c5                	jmp    8008dc <fsipc+0x12>

00800917 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800917:	f3 0f 1e fb          	endbr32 
  80091b:	55                   	push   %ebp
  80091c:	89 e5                	mov    %esp,%ebp
  80091e:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800921:	8b 45 08             	mov    0x8(%ebp),%eax
  800924:	8b 40 0c             	mov    0xc(%eax),%eax
  800927:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80092c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80092f:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800934:	ba 00 00 00 00       	mov    $0x0,%edx
  800939:	b8 02 00 00 00       	mov    $0x2,%eax
  80093e:	e8 87 ff ff ff       	call   8008ca <fsipc>
}
  800943:	c9                   	leave  
  800944:	c3                   	ret    

00800945 <devfile_flush>:
{
  800945:	f3 0f 1e fb          	endbr32 
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	8b 40 0c             	mov    0xc(%eax),%eax
  800955:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80095a:	ba 00 00 00 00       	mov    $0x0,%edx
  80095f:	b8 06 00 00 00       	mov    $0x6,%eax
  800964:	e8 61 ff ff ff       	call   8008ca <fsipc>
}
  800969:	c9                   	leave  
  80096a:	c3                   	ret    

0080096b <devfile_stat>:
{
  80096b:	f3 0f 1e fb          	endbr32 
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	53                   	push   %ebx
  800973:	83 ec 04             	sub    $0x4,%esp
  800976:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 40 0c             	mov    0xc(%eax),%eax
  80097f:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800984:	ba 00 00 00 00       	mov    $0x0,%edx
  800989:	b8 05 00 00 00       	mov    $0x5,%eax
  80098e:	e8 37 ff ff ff       	call   8008ca <fsipc>
  800993:	85 c0                	test   %eax,%eax
  800995:	78 2c                	js     8009c3 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  800997:	83 ec 08             	sub    $0x8,%esp
  80099a:	68 00 50 80 00       	push   $0x805000
  80099f:	53                   	push   %ebx
  8009a0:	e8 ec 0c 00 00       	call   801691 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009a5:	a1 80 50 80 00       	mov    0x805080,%eax
  8009aa:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009b0:	a1 84 50 80 00       	mov    0x805084,%eax
  8009b5:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009bb:	83 c4 10             	add    $0x10,%esp
  8009be:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009c6:	c9                   	leave  
  8009c7:	c3                   	ret    

008009c8 <devfile_write>:
{
  8009c8:	f3 0f 1e fb          	endbr32 
  8009cc:	55                   	push   %ebp
  8009cd:	89 e5                	mov    %esp,%ebp
  8009cf:	83 ec 0c             	sub    $0xc,%esp
  8009d2:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8009d8:	8b 52 0c             	mov    0xc(%edx),%edx
  8009db:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009e1:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009e6:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009eb:	0f 47 c2             	cmova  %edx,%eax
  8009ee:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  8009f3:	50                   	push   %eax
  8009f4:	ff 75 0c             	pushl  0xc(%ebp)
  8009f7:	68 08 50 80 00       	push   $0x805008
  8009fc:	e8 48 0e 00 00       	call   801849 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a01:	ba 00 00 00 00       	mov    $0x0,%edx
  800a06:	b8 04 00 00 00       	mov    $0x4,%eax
  800a0b:	e8 ba fe ff ff       	call   8008ca <fsipc>
}
  800a10:	c9                   	leave  
  800a11:	c3                   	ret    

00800a12 <devfile_read>:
{
  800a12:	f3 0f 1e fb          	endbr32 
  800a16:	55                   	push   %ebp
  800a17:	89 e5                	mov    %esp,%ebp
  800a19:	56                   	push   %esi
  800a1a:	53                   	push   %ebx
  800a1b:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a1e:	8b 45 08             	mov    0x8(%ebp),%eax
  800a21:	8b 40 0c             	mov    0xc(%eax),%eax
  800a24:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a29:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a2f:	ba 00 00 00 00       	mov    $0x0,%edx
  800a34:	b8 03 00 00 00       	mov    $0x3,%eax
  800a39:	e8 8c fe ff ff       	call   8008ca <fsipc>
  800a3e:	89 c3                	mov    %eax,%ebx
  800a40:	85 c0                	test   %eax,%eax
  800a42:	78 1f                	js     800a63 <devfile_read+0x51>
	assert(r <= n);
  800a44:	39 f0                	cmp    %esi,%eax
  800a46:	77 24                	ja     800a6c <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800a48:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a4d:	7f 33                	jg     800a82 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a4f:	83 ec 04             	sub    $0x4,%esp
  800a52:	50                   	push   %eax
  800a53:	68 00 50 80 00       	push   $0x805000
  800a58:	ff 75 0c             	pushl  0xc(%ebp)
  800a5b:	e8 e9 0d 00 00       	call   801849 <memmove>
	return r;
  800a60:	83 c4 10             	add    $0x10,%esp
}
  800a63:	89 d8                	mov    %ebx,%eax
  800a65:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a68:	5b                   	pop    %ebx
  800a69:	5e                   	pop    %esi
  800a6a:	5d                   	pop    %ebp
  800a6b:	c3                   	ret    
	assert(r <= n);
  800a6c:	68 84 1e 80 00       	push   $0x801e84
  800a71:	68 8b 1e 80 00       	push   $0x801e8b
  800a76:	6a 7c                	push   $0x7c
  800a78:	68 a0 1e 80 00       	push   $0x801ea0
  800a7d:	e8 be 05 00 00       	call   801040 <_panic>
	assert(r <= PGSIZE);
  800a82:	68 ab 1e 80 00       	push   $0x801eab
  800a87:	68 8b 1e 80 00       	push   $0x801e8b
  800a8c:	6a 7d                	push   $0x7d
  800a8e:	68 a0 1e 80 00       	push   $0x801ea0
  800a93:	e8 a8 05 00 00       	call   801040 <_panic>

00800a98 <open>:
{
  800a98:	f3 0f 1e fb          	endbr32 
  800a9c:	55                   	push   %ebp
  800a9d:	89 e5                	mov    %esp,%ebp
  800a9f:	56                   	push   %esi
  800aa0:	53                   	push   %ebx
  800aa1:	83 ec 1c             	sub    $0x1c,%esp
  800aa4:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800aa7:	56                   	push   %esi
  800aa8:	e8 a1 0b 00 00       	call   80164e <strlen>
  800aad:	83 c4 10             	add    $0x10,%esp
  800ab0:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ab5:	7f 6c                	jg     800b23 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800ab7:	83 ec 0c             	sub    $0xc,%esp
  800aba:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800abd:	50                   	push   %eax
  800abe:	e8 67 f8 ff ff       	call   80032a <fd_alloc>
  800ac3:	89 c3                	mov    %eax,%ebx
  800ac5:	83 c4 10             	add    $0x10,%esp
  800ac8:	85 c0                	test   %eax,%eax
  800aca:	78 3c                	js     800b08 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800acc:	83 ec 08             	sub    $0x8,%esp
  800acf:	56                   	push   %esi
  800ad0:	68 00 50 80 00       	push   $0x805000
  800ad5:	e8 b7 0b 00 00       	call   801691 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ada:	8b 45 0c             	mov    0xc(%ebp),%eax
  800add:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800ae2:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800ae5:	b8 01 00 00 00       	mov    $0x1,%eax
  800aea:	e8 db fd ff ff       	call   8008ca <fsipc>
  800aef:	89 c3                	mov    %eax,%ebx
  800af1:	83 c4 10             	add    $0x10,%esp
  800af4:	85 c0                	test   %eax,%eax
  800af6:	78 19                	js     800b11 <open+0x79>
	return fd2num(fd);
  800af8:	83 ec 0c             	sub    $0xc,%esp
  800afb:	ff 75 f4             	pushl  -0xc(%ebp)
  800afe:	e8 f4 f7 ff ff       	call   8002f7 <fd2num>
  800b03:	89 c3                	mov    %eax,%ebx
  800b05:	83 c4 10             	add    $0x10,%esp
}
  800b08:	89 d8                	mov    %ebx,%eax
  800b0a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b0d:	5b                   	pop    %ebx
  800b0e:	5e                   	pop    %esi
  800b0f:	5d                   	pop    %ebp
  800b10:	c3                   	ret    
		fd_close(fd, 0);
  800b11:	83 ec 08             	sub    $0x8,%esp
  800b14:	6a 00                	push   $0x0
  800b16:	ff 75 f4             	pushl  -0xc(%ebp)
  800b19:	e8 10 f9 ff ff       	call   80042e <fd_close>
		return r;
  800b1e:	83 c4 10             	add    $0x10,%esp
  800b21:	eb e5                	jmp    800b08 <open+0x70>
		return -E_BAD_PATH;
  800b23:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b28:	eb de                	jmp    800b08 <open+0x70>

00800b2a <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b2a:	f3 0f 1e fb          	endbr32 
  800b2e:	55                   	push   %ebp
  800b2f:	89 e5                	mov    %esp,%ebp
  800b31:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b34:	ba 00 00 00 00       	mov    $0x0,%edx
  800b39:	b8 08 00 00 00       	mov    $0x8,%eax
  800b3e:	e8 87 fd ff ff       	call   8008ca <fsipc>
}
  800b43:	c9                   	leave  
  800b44:	c3                   	ret    

00800b45 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b45:	f3 0f 1e fb          	endbr32 
  800b49:	55                   	push   %ebp
  800b4a:	89 e5                	mov    %esp,%ebp
  800b4c:	56                   	push   %esi
  800b4d:	53                   	push   %ebx
  800b4e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b51:	83 ec 0c             	sub    $0xc,%esp
  800b54:	ff 75 08             	pushl  0x8(%ebp)
  800b57:	e8 af f7 ff ff       	call   80030b <fd2data>
  800b5c:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b5e:	83 c4 08             	add    $0x8,%esp
  800b61:	68 b7 1e 80 00       	push   $0x801eb7
  800b66:	53                   	push   %ebx
  800b67:	e8 25 0b 00 00       	call   801691 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b6c:	8b 46 04             	mov    0x4(%esi),%eax
  800b6f:	2b 06                	sub    (%esi),%eax
  800b71:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b77:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b7e:	00 00 00 
	stat->st_dev = &devpipe;
  800b81:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b88:	30 80 00 
	return 0;
}
  800b8b:	b8 00 00 00 00       	mov    $0x0,%eax
  800b90:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b93:	5b                   	pop    %ebx
  800b94:	5e                   	pop    %esi
  800b95:	5d                   	pop    %ebp
  800b96:	c3                   	ret    

00800b97 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b97:	f3 0f 1e fb          	endbr32 
  800b9b:	55                   	push   %ebp
  800b9c:	89 e5                	mov    %esp,%ebp
  800b9e:	53                   	push   %ebx
  800b9f:	83 ec 0c             	sub    $0xc,%esp
  800ba2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800ba5:	53                   	push   %ebx
  800ba6:	6a 00                	push   $0x0
  800ba8:	e8 5f f6 ff ff       	call   80020c <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bad:	89 1c 24             	mov    %ebx,(%esp)
  800bb0:	e8 56 f7 ff ff       	call   80030b <fd2data>
  800bb5:	83 c4 08             	add    $0x8,%esp
  800bb8:	50                   	push   %eax
  800bb9:	6a 00                	push   $0x0
  800bbb:	e8 4c f6 ff ff       	call   80020c <sys_page_unmap>
}
  800bc0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bc3:	c9                   	leave  
  800bc4:	c3                   	ret    

00800bc5 <_pipeisclosed>:
{
  800bc5:	55                   	push   %ebp
  800bc6:	89 e5                	mov    %esp,%ebp
  800bc8:	57                   	push   %edi
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
  800bcb:	83 ec 1c             	sub    $0x1c,%esp
  800bce:	89 c7                	mov    %eax,%edi
  800bd0:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bd2:	a1 04 40 80 00       	mov    0x804004,%eax
  800bd7:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bda:	83 ec 0c             	sub    $0xc,%esp
  800bdd:	57                   	push   %edi
  800bde:	e8 32 0f 00 00       	call   801b15 <pageref>
  800be3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800be6:	89 34 24             	mov    %esi,(%esp)
  800be9:	e8 27 0f 00 00       	call   801b15 <pageref>
		nn = thisenv->env_runs;
  800bee:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800bf4:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800bf7:	83 c4 10             	add    $0x10,%esp
  800bfa:	39 cb                	cmp    %ecx,%ebx
  800bfc:	74 1b                	je     800c19 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800bfe:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c01:	75 cf                	jne    800bd2 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c03:	8b 42 58             	mov    0x58(%edx),%eax
  800c06:	6a 01                	push   $0x1
  800c08:	50                   	push   %eax
  800c09:	53                   	push   %ebx
  800c0a:	68 be 1e 80 00       	push   $0x801ebe
  800c0f:	e8 13 05 00 00       	call   801127 <cprintf>
  800c14:	83 c4 10             	add    $0x10,%esp
  800c17:	eb b9                	jmp    800bd2 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c19:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c1c:	0f 94 c0             	sete   %al
  800c1f:	0f b6 c0             	movzbl %al,%eax
}
  800c22:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c25:	5b                   	pop    %ebx
  800c26:	5e                   	pop    %esi
  800c27:	5f                   	pop    %edi
  800c28:	5d                   	pop    %ebp
  800c29:	c3                   	ret    

00800c2a <devpipe_write>:
{
  800c2a:	f3 0f 1e fb          	endbr32 
  800c2e:	55                   	push   %ebp
  800c2f:	89 e5                	mov    %esp,%ebp
  800c31:	57                   	push   %edi
  800c32:	56                   	push   %esi
  800c33:	53                   	push   %ebx
  800c34:	83 ec 28             	sub    $0x28,%esp
  800c37:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c3a:	56                   	push   %esi
  800c3b:	e8 cb f6 ff ff       	call   80030b <fd2data>
  800c40:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c42:	83 c4 10             	add    $0x10,%esp
  800c45:	bf 00 00 00 00       	mov    $0x0,%edi
  800c4a:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c4d:	74 4f                	je     800c9e <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c4f:	8b 43 04             	mov    0x4(%ebx),%eax
  800c52:	8b 0b                	mov    (%ebx),%ecx
  800c54:	8d 51 20             	lea    0x20(%ecx),%edx
  800c57:	39 d0                	cmp    %edx,%eax
  800c59:	72 14                	jb     800c6f <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800c5b:	89 da                	mov    %ebx,%edx
  800c5d:	89 f0                	mov    %esi,%eax
  800c5f:	e8 61 ff ff ff       	call   800bc5 <_pipeisclosed>
  800c64:	85 c0                	test   %eax,%eax
  800c66:	75 3b                	jne    800ca3 <devpipe_write+0x79>
			sys_yield();
  800c68:	e8 22 f5 ff ff       	call   80018f <sys_yield>
  800c6d:	eb e0                	jmp    800c4f <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c72:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c76:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c79:	89 c2                	mov    %eax,%edx
  800c7b:	c1 fa 1f             	sar    $0x1f,%edx
  800c7e:	89 d1                	mov    %edx,%ecx
  800c80:	c1 e9 1b             	shr    $0x1b,%ecx
  800c83:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c86:	83 e2 1f             	and    $0x1f,%edx
  800c89:	29 ca                	sub    %ecx,%edx
  800c8b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c8f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c93:	83 c0 01             	add    $0x1,%eax
  800c96:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800c99:	83 c7 01             	add    $0x1,%edi
  800c9c:	eb ac                	jmp    800c4a <devpipe_write+0x20>
	return i;
  800c9e:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca1:	eb 05                	jmp    800ca8 <devpipe_write+0x7e>
				return 0;
  800ca3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ca8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cab:	5b                   	pop    %ebx
  800cac:	5e                   	pop    %esi
  800cad:	5f                   	pop    %edi
  800cae:	5d                   	pop    %ebp
  800caf:	c3                   	ret    

00800cb0 <devpipe_read>:
{
  800cb0:	f3 0f 1e fb          	endbr32 
  800cb4:	55                   	push   %ebp
  800cb5:	89 e5                	mov    %esp,%ebp
  800cb7:	57                   	push   %edi
  800cb8:	56                   	push   %esi
  800cb9:	53                   	push   %ebx
  800cba:	83 ec 18             	sub    $0x18,%esp
  800cbd:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800cc0:	57                   	push   %edi
  800cc1:	e8 45 f6 ff ff       	call   80030b <fd2data>
  800cc6:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cc8:	83 c4 10             	add    $0x10,%esp
  800ccb:	be 00 00 00 00       	mov    $0x0,%esi
  800cd0:	3b 75 10             	cmp    0x10(%ebp),%esi
  800cd3:	75 14                	jne    800ce9 <devpipe_read+0x39>
	return i;
  800cd5:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd8:	eb 02                	jmp    800cdc <devpipe_read+0x2c>
				return i;
  800cda:	89 f0                	mov    %esi,%eax
}
  800cdc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cdf:	5b                   	pop    %ebx
  800ce0:	5e                   	pop    %esi
  800ce1:	5f                   	pop    %edi
  800ce2:	5d                   	pop    %ebp
  800ce3:	c3                   	ret    
			sys_yield();
  800ce4:	e8 a6 f4 ff ff       	call   80018f <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800ce9:	8b 03                	mov    (%ebx),%eax
  800ceb:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cee:	75 18                	jne    800d08 <devpipe_read+0x58>
			if (i > 0)
  800cf0:	85 f6                	test   %esi,%esi
  800cf2:	75 e6                	jne    800cda <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800cf4:	89 da                	mov    %ebx,%edx
  800cf6:	89 f8                	mov    %edi,%eax
  800cf8:	e8 c8 fe ff ff       	call   800bc5 <_pipeisclosed>
  800cfd:	85 c0                	test   %eax,%eax
  800cff:	74 e3                	je     800ce4 <devpipe_read+0x34>
				return 0;
  800d01:	b8 00 00 00 00       	mov    $0x0,%eax
  800d06:	eb d4                	jmp    800cdc <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d08:	99                   	cltd   
  800d09:	c1 ea 1b             	shr    $0x1b,%edx
  800d0c:	01 d0                	add    %edx,%eax
  800d0e:	83 e0 1f             	and    $0x1f,%eax
  800d11:	29 d0                	sub    %edx,%eax
  800d13:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d18:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d1b:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d1e:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d21:	83 c6 01             	add    $0x1,%esi
  800d24:	eb aa                	jmp    800cd0 <devpipe_read+0x20>

00800d26 <pipe>:
{
  800d26:	f3 0f 1e fb          	endbr32 
  800d2a:	55                   	push   %ebp
  800d2b:	89 e5                	mov    %esp,%ebp
  800d2d:	56                   	push   %esi
  800d2e:	53                   	push   %ebx
  800d2f:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d32:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d35:	50                   	push   %eax
  800d36:	e8 ef f5 ff ff       	call   80032a <fd_alloc>
  800d3b:	89 c3                	mov    %eax,%ebx
  800d3d:	83 c4 10             	add    $0x10,%esp
  800d40:	85 c0                	test   %eax,%eax
  800d42:	0f 88 23 01 00 00    	js     800e6b <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d48:	83 ec 04             	sub    $0x4,%esp
  800d4b:	68 07 04 00 00       	push   $0x407
  800d50:	ff 75 f4             	pushl  -0xc(%ebp)
  800d53:	6a 00                	push   $0x0
  800d55:	e8 60 f4 ff ff       	call   8001ba <sys_page_alloc>
  800d5a:	89 c3                	mov    %eax,%ebx
  800d5c:	83 c4 10             	add    $0x10,%esp
  800d5f:	85 c0                	test   %eax,%eax
  800d61:	0f 88 04 01 00 00    	js     800e6b <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800d67:	83 ec 0c             	sub    $0xc,%esp
  800d6a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d6d:	50                   	push   %eax
  800d6e:	e8 b7 f5 ff ff       	call   80032a <fd_alloc>
  800d73:	89 c3                	mov    %eax,%ebx
  800d75:	83 c4 10             	add    $0x10,%esp
  800d78:	85 c0                	test   %eax,%eax
  800d7a:	0f 88 db 00 00 00    	js     800e5b <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d80:	83 ec 04             	sub    $0x4,%esp
  800d83:	68 07 04 00 00       	push   $0x407
  800d88:	ff 75 f0             	pushl  -0x10(%ebp)
  800d8b:	6a 00                	push   $0x0
  800d8d:	e8 28 f4 ff ff       	call   8001ba <sys_page_alloc>
  800d92:	89 c3                	mov    %eax,%ebx
  800d94:	83 c4 10             	add    $0x10,%esp
  800d97:	85 c0                	test   %eax,%eax
  800d99:	0f 88 bc 00 00 00    	js     800e5b <pipe+0x135>
	va = fd2data(fd0);
  800d9f:	83 ec 0c             	sub    $0xc,%esp
  800da2:	ff 75 f4             	pushl  -0xc(%ebp)
  800da5:	e8 61 f5 ff ff       	call   80030b <fd2data>
  800daa:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dac:	83 c4 0c             	add    $0xc,%esp
  800daf:	68 07 04 00 00       	push   $0x407
  800db4:	50                   	push   %eax
  800db5:	6a 00                	push   $0x0
  800db7:	e8 fe f3 ff ff       	call   8001ba <sys_page_alloc>
  800dbc:	89 c3                	mov    %eax,%ebx
  800dbe:	83 c4 10             	add    $0x10,%esp
  800dc1:	85 c0                	test   %eax,%eax
  800dc3:	0f 88 82 00 00 00    	js     800e4b <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc9:	83 ec 0c             	sub    $0xc,%esp
  800dcc:	ff 75 f0             	pushl  -0x10(%ebp)
  800dcf:	e8 37 f5 ff ff       	call   80030b <fd2data>
  800dd4:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800ddb:	50                   	push   %eax
  800ddc:	6a 00                	push   $0x0
  800dde:	56                   	push   %esi
  800ddf:	6a 00                	push   $0x0
  800de1:	e8 fc f3 ff ff       	call   8001e2 <sys_page_map>
  800de6:	89 c3                	mov    %eax,%ebx
  800de8:	83 c4 20             	add    $0x20,%esp
  800deb:	85 c0                	test   %eax,%eax
  800ded:	78 4e                	js     800e3d <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800def:	a1 20 30 80 00       	mov    0x803020,%eax
  800df4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800df7:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800df9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800dfc:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e03:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e06:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e08:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e0b:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e12:	83 ec 0c             	sub    $0xc,%esp
  800e15:	ff 75 f4             	pushl  -0xc(%ebp)
  800e18:	e8 da f4 ff ff       	call   8002f7 <fd2num>
  800e1d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e20:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e22:	83 c4 04             	add    $0x4,%esp
  800e25:	ff 75 f0             	pushl  -0x10(%ebp)
  800e28:	e8 ca f4 ff ff       	call   8002f7 <fd2num>
  800e2d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e30:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e33:	83 c4 10             	add    $0x10,%esp
  800e36:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e3b:	eb 2e                	jmp    800e6b <pipe+0x145>
	sys_page_unmap(0, va);
  800e3d:	83 ec 08             	sub    $0x8,%esp
  800e40:	56                   	push   %esi
  800e41:	6a 00                	push   $0x0
  800e43:	e8 c4 f3 ff ff       	call   80020c <sys_page_unmap>
  800e48:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e4b:	83 ec 08             	sub    $0x8,%esp
  800e4e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e51:	6a 00                	push   $0x0
  800e53:	e8 b4 f3 ff ff       	call   80020c <sys_page_unmap>
  800e58:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800e5b:	83 ec 08             	sub    $0x8,%esp
  800e5e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e61:	6a 00                	push   $0x0
  800e63:	e8 a4 f3 ff ff       	call   80020c <sys_page_unmap>
  800e68:	83 c4 10             	add    $0x10,%esp
}
  800e6b:	89 d8                	mov    %ebx,%eax
  800e6d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e70:	5b                   	pop    %ebx
  800e71:	5e                   	pop    %esi
  800e72:	5d                   	pop    %ebp
  800e73:	c3                   	ret    

00800e74 <pipeisclosed>:
{
  800e74:	f3 0f 1e fb          	endbr32 
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e81:	50                   	push   %eax
  800e82:	ff 75 08             	pushl  0x8(%ebp)
  800e85:	e8 f6 f4 ff ff       	call   800380 <fd_lookup>
  800e8a:	83 c4 10             	add    $0x10,%esp
  800e8d:	85 c0                	test   %eax,%eax
  800e8f:	78 18                	js     800ea9 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800e91:	83 ec 0c             	sub    $0xc,%esp
  800e94:	ff 75 f4             	pushl  -0xc(%ebp)
  800e97:	e8 6f f4 ff ff       	call   80030b <fd2data>
  800e9c:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ea1:	e8 1f fd ff ff       	call   800bc5 <_pipeisclosed>
  800ea6:	83 c4 10             	add    $0x10,%esp
}
  800ea9:	c9                   	leave  
  800eaa:	c3                   	ret    

00800eab <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eab:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800eaf:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb4:	c3                   	ret    

00800eb5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eb5:	f3 0f 1e fb          	endbr32 
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ebf:	68 d6 1e 80 00       	push   $0x801ed6
  800ec4:	ff 75 0c             	pushl  0xc(%ebp)
  800ec7:	e8 c5 07 00 00       	call   801691 <strcpy>
	return 0;
}
  800ecc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed1:	c9                   	leave  
  800ed2:	c3                   	ret    

00800ed3 <devcons_write>:
{
  800ed3:	f3 0f 1e fb          	endbr32 
  800ed7:	55                   	push   %ebp
  800ed8:	89 e5                	mov    %esp,%ebp
  800eda:	57                   	push   %edi
  800edb:	56                   	push   %esi
  800edc:	53                   	push   %ebx
  800edd:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ee3:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800ee8:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800eee:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ef1:	73 31                	jae    800f24 <devcons_write+0x51>
		m = n - tot;
  800ef3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef6:	29 f3                	sub    %esi,%ebx
  800ef8:	83 fb 7f             	cmp    $0x7f,%ebx
  800efb:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f00:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f03:	83 ec 04             	sub    $0x4,%esp
  800f06:	53                   	push   %ebx
  800f07:	89 f0                	mov    %esi,%eax
  800f09:	03 45 0c             	add    0xc(%ebp),%eax
  800f0c:	50                   	push   %eax
  800f0d:	57                   	push   %edi
  800f0e:	e8 36 09 00 00       	call   801849 <memmove>
		sys_cputs(buf, m);
  800f13:	83 c4 08             	add    $0x8,%esp
  800f16:	53                   	push   %ebx
  800f17:	57                   	push   %edi
  800f18:	e8 d2 f1 ff ff       	call   8000ef <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f1d:	01 de                	add    %ebx,%esi
  800f1f:	83 c4 10             	add    $0x10,%esp
  800f22:	eb ca                	jmp    800eee <devcons_write+0x1b>
}
  800f24:	89 f0                	mov    %esi,%eax
  800f26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f29:	5b                   	pop    %ebx
  800f2a:	5e                   	pop    %esi
  800f2b:	5f                   	pop    %edi
  800f2c:	5d                   	pop    %ebp
  800f2d:	c3                   	ret    

00800f2e <devcons_read>:
{
  800f2e:	f3 0f 1e fb          	endbr32 
  800f32:	55                   	push   %ebp
  800f33:	89 e5                	mov    %esp,%ebp
  800f35:	83 ec 08             	sub    $0x8,%esp
  800f38:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f3d:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f41:	74 21                	je     800f64 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800f43:	e8 d1 f1 ff ff       	call   800119 <sys_cgetc>
  800f48:	85 c0                	test   %eax,%eax
  800f4a:	75 07                	jne    800f53 <devcons_read+0x25>
		sys_yield();
  800f4c:	e8 3e f2 ff ff       	call   80018f <sys_yield>
  800f51:	eb f0                	jmp    800f43 <devcons_read+0x15>
	if (c < 0)
  800f53:	78 0f                	js     800f64 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800f55:	83 f8 04             	cmp    $0x4,%eax
  800f58:	74 0c                	je     800f66 <devcons_read+0x38>
	*(char*)vbuf = c;
  800f5a:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f5d:	88 02                	mov    %al,(%edx)
	return 1;
  800f5f:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800f64:	c9                   	leave  
  800f65:	c3                   	ret    
		return 0;
  800f66:	b8 00 00 00 00       	mov    $0x0,%eax
  800f6b:	eb f7                	jmp    800f64 <devcons_read+0x36>

00800f6d <cputchar>:
{
  800f6d:	f3 0f 1e fb          	endbr32 
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f77:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7a:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f7d:	6a 01                	push   $0x1
  800f7f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f82:	50                   	push   %eax
  800f83:	e8 67 f1 ff ff       	call   8000ef <sys_cputs>
}
  800f88:	83 c4 10             	add    $0x10,%esp
  800f8b:	c9                   	leave  
  800f8c:	c3                   	ret    

00800f8d <getchar>:
{
  800f8d:	f3 0f 1e fb          	endbr32 
  800f91:	55                   	push   %ebp
  800f92:	89 e5                	mov    %esp,%ebp
  800f94:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800f97:	6a 01                	push   $0x1
  800f99:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f9c:	50                   	push   %eax
  800f9d:	6a 00                	push   $0x0
  800f9f:	e8 5f f6 ff ff       	call   800603 <read>
	if (r < 0)
  800fa4:	83 c4 10             	add    $0x10,%esp
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	78 06                	js     800fb1 <getchar+0x24>
	if (r < 1)
  800fab:	74 06                	je     800fb3 <getchar+0x26>
	return c;
  800fad:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800fb1:	c9                   	leave  
  800fb2:	c3                   	ret    
		return -E_EOF;
  800fb3:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800fb8:	eb f7                	jmp    800fb1 <getchar+0x24>

00800fba <iscons>:
{
  800fba:	f3 0f 1e fb          	endbr32 
  800fbe:	55                   	push   %ebp
  800fbf:	89 e5                	mov    %esp,%ebp
  800fc1:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fc4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc7:	50                   	push   %eax
  800fc8:	ff 75 08             	pushl  0x8(%ebp)
  800fcb:	e8 b0 f3 ff ff       	call   800380 <fd_lookup>
  800fd0:	83 c4 10             	add    $0x10,%esp
  800fd3:	85 c0                	test   %eax,%eax
  800fd5:	78 11                	js     800fe8 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  800fd7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fda:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fe0:	39 10                	cmp    %edx,(%eax)
  800fe2:	0f 94 c0             	sete   %al
  800fe5:	0f b6 c0             	movzbl %al,%eax
}
  800fe8:	c9                   	leave  
  800fe9:	c3                   	ret    

00800fea <opencons>:
{
  800fea:	f3 0f 1e fb          	endbr32 
  800fee:	55                   	push   %ebp
  800fef:	89 e5                	mov    %esp,%ebp
  800ff1:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  800ff4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff7:	50                   	push   %eax
  800ff8:	e8 2d f3 ff ff       	call   80032a <fd_alloc>
  800ffd:	83 c4 10             	add    $0x10,%esp
  801000:	85 c0                	test   %eax,%eax
  801002:	78 3a                	js     80103e <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801004:	83 ec 04             	sub    $0x4,%esp
  801007:	68 07 04 00 00       	push   $0x407
  80100c:	ff 75 f4             	pushl  -0xc(%ebp)
  80100f:	6a 00                	push   $0x0
  801011:	e8 a4 f1 ff ff       	call   8001ba <sys_page_alloc>
  801016:	83 c4 10             	add    $0x10,%esp
  801019:	85 c0                	test   %eax,%eax
  80101b:	78 21                	js     80103e <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80101d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801020:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801026:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801028:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80102b:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801032:	83 ec 0c             	sub    $0xc,%esp
  801035:	50                   	push   %eax
  801036:	e8 bc f2 ff ff       	call   8002f7 <fd2num>
  80103b:	83 c4 10             	add    $0x10,%esp
}
  80103e:	c9                   	leave  
  80103f:	c3                   	ret    

00801040 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801040:	f3 0f 1e fb          	endbr32 
  801044:	55                   	push   %ebp
  801045:	89 e5                	mov    %esp,%ebp
  801047:	56                   	push   %esi
  801048:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801049:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80104c:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801052:	e8 10 f1 ff ff       	call   800167 <sys_getenvid>
  801057:	83 ec 0c             	sub    $0xc,%esp
  80105a:	ff 75 0c             	pushl  0xc(%ebp)
  80105d:	ff 75 08             	pushl  0x8(%ebp)
  801060:	56                   	push   %esi
  801061:	50                   	push   %eax
  801062:	68 e4 1e 80 00       	push   $0x801ee4
  801067:	e8 bb 00 00 00       	call   801127 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80106c:	83 c4 18             	add    $0x18,%esp
  80106f:	53                   	push   %ebx
  801070:	ff 75 10             	pushl  0x10(%ebp)
  801073:	e8 5a 00 00 00       	call   8010d2 <vcprintf>
	cprintf("\n");
  801078:	c7 04 24 cf 1e 80 00 	movl   $0x801ecf,(%esp)
  80107f:	e8 a3 00 00 00       	call   801127 <cprintf>
  801084:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801087:	cc                   	int3   
  801088:	eb fd                	jmp    801087 <_panic+0x47>

0080108a <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80108a:	f3 0f 1e fb          	endbr32 
  80108e:	55                   	push   %ebp
  80108f:	89 e5                	mov    %esp,%ebp
  801091:	53                   	push   %ebx
  801092:	83 ec 04             	sub    $0x4,%esp
  801095:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801098:	8b 13                	mov    (%ebx),%edx
  80109a:	8d 42 01             	lea    0x1(%edx),%eax
  80109d:	89 03                	mov    %eax,(%ebx)
  80109f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010a2:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010a6:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010ab:	74 09                	je     8010b6 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8010ad:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b4:	c9                   	leave  
  8010b5:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8010b6:	83 ec 08             	sub    $0x8,%esp
  8010b9:	68 ff 00 00 00       	push   $0xff
  8010be:	8d 43 08             	lea    0x8(%ebx),%eax
  8010c1:	50                   	push   %eax
  8010c2:	e8 28 f0 ff ff       	call   8000ef <sys_cputs>
		b->idx = 0;
  8010c7:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010cd:	83 c4 10             	add    $0x10,%esp
  8010d0:	eb db                	jmp    8010ad <putch+0x23>

008010d2 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010d2:	f3 0f 1e fb          	endbr32 
  8010d6:	55                   	push   %ebp
  8010d7:	89 e5                	mov    %esp,%ebp
  8010d9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010df:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010e6:	00 00 00 
	b.cnt = 0;
  8010e9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010f0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010f3:	ff 75 0c             	pushl  0xc(%ebp)
  8010f6:	ff 75 08             	pushl  0x8(%ebp)
  8010f9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010ff:	50                   	push   %eax
  801100:	68 8a 10 80 00       	push   $0x80108a
  801105:	e8 80 01 00 00       	call   80128a <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80110a:	83 c4 08             	add    $0x8,%esp
  80110d:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801113:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801119:	50                   	push   %eax
  80111a:	e8 d0 ef ff ff       	call   8000ef <sys_cputs>

	return b.cnt;
}
  80111f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801125:	c9                   	leave  
  801126:	c3                   	ret    

00801127 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801127:	f3 0f 1e fb          	endbr32 
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801131:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801134:	50                   	push   %eax
  801135:	ff 75 08             	pushl  0x8(%ebp)
  801138:	e8 95 ff ff ff       	call   8010d2 <vcprintf>
	va_end(ap);

	return cnt;
}
  80113d:	c9                   	leave  
  80113e:	c3                   	ret    

0080113f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80113f:	55                   	push   %ebp
  801140:	89 e5                	mov    %esp,%ebp
  801142:	57                   	push   %edi
  801143:	56                   	push   %esi
  801144:	53                   	push   %ebx
  801145:	83 ec 1c             	sub    $0x1c,%esp
  801148:	89 c7                	mov    %eax,%edi
  80114a:	89 d6                	mov    %edx,%esi
  80114c:	8b 45 08             	mov    0x8(%ebp),%eax
  80114f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801152:	89 d1                	mov    %edx,%ecx
  801154:	89 c2                	mov    %eax,%edx
  801156:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801159:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80115c:	8b 45 10             	mov    0x10(%ebp),%eax
  80115f:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801162:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801165:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80116c:	39 c2                	cmp    %eax,%edx
  80116e:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801171:	72 3e                	jb     8011b1 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801173:	83 ec 0c             	sub    $0xc,%esp
  801176:	ff 75 18             	pushl  0x18(%ebp)
  801179:	83 eb 01             	sub    $0x1,%ebx
  80117c:	53                   	push   %ebx
  80117d:	50                   	push   %eax
  80117e:	83 ec 08             	sub    $0x8,%esp
  801181:	ff 75 e4             	pushl  -0x1c(%ebp)
  801184:	ff 75 e0             	pushl  -0x20(%ebp)
  801187:	ff 75 dc             	pushl  -0x24(%ebp)
  80118a:	ff 75 d8             	pushl  -0x28(%ebp)
  80118d:	e8 ce 09 00 00       	call   801b60 <__udivdi3>
  801192:	83 c4 18             	add    $0x18,%esp
  801195:	52                   	push   %edx
  801196:	50                   	push   %eax
  801197:	89 f2                	mov    %esi,%edx
  801199:	89 f8                	mov    %edi,%eax
  80119b:	e8 9f ff ff ff       	call   80113f <printnum>
  8011a0:	83 c4 20             	add    $0x20,%esp
  8011a3:	eb 13                	jmp    8011b8 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011a5:	83 ec 08             	sub    $0x8,%esp
  8011a8:	56                   	push   %esi
  8011a9:	ff 75 18             	pushl  0x18(%ebp)
  8011ac:	ff d7                	call   *%edi
  8011ae:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8011b1:	83 eb 01             	sub    $0x1,%ebx
  8011b4:	85 db                	test   %ebx,%ebx
  8011b6:	7f ed                	jg     8011a5 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011b8:	83 ec 08             	sub    $0x8,%esp
  8011bb:	56                   	push   %esi
  8011bc:	83 ec 04             	sub    $0x4,%esp
  8011bf:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011c2:	ff 75 e0             	pushl  -0x20(%ebp)
  8011c5:	ff 75 dc             	pushl  -0x24(%ebp)
  8011c8:	ff 75 d8             	pushl  -0x28(%ebp)
  8011cb:	e8 a0 0a 00 00       	call   801c70 <__umoddi3>
  8011d0:	83 c4 14             	add    $0x14,%esp
  8011d3:	0f be 80 07 1f 80 00 	movsbl 0x801f07(%eax),%eax
  8011da:	50                   	push   %eax
  8011db:	ff d7                	call   *%edi
}
  8011dd:	83 c4 10             	add    $0x10,%esp
  8011e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011e3:	5b                   	pop    %ebx
  8011e4:	5e                   	pop    %esi
  8011e5:	5f                   	pop    %edi
  8011e6:	5d                   	pop    %ebp
  8011e7:	c3                   	ret    

008011e8 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8011e8:	83 fa 01             	cmp    $0x1,%edx
  8011eb:	7f 13                	jg     801200 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8011ed:	85 d2                	test   %edx,%edx
  8011ef:	74 1c                	je     80120d <getuint+0x25>
		return va_arg(*ap, unsigned long);
  8011f1:	8b 10                	mov    (%eax),%edx
  8011f3:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011f6:	89 08                	mov    %ecx,(%eax)
  8011f8:	8b 02                	mov    (%edx),%eax
  8011fa:	ba 00 00 00 00       	mov    $0x0,%edx
  8011ff:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  801200:	8b 10                	mov    (%eax),%edx
  801202:	8d 4a 08             	lea    0x8(%edx),%ecx
  801205:	89 08                	mov    %ecx,(%eax)
  801207:	8b 02                	mov    (%edx),%eax
  801209:	8b 52 04             	mov    0x4(%edx),%edx
  80120c:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  80120d:	8b 10                	mov    (%eax),%edx
  80120f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801212:	89 08                	mov    %ecx,(%eax)
  801214:	8b 02                	mov    (%edx),%eax
  801216:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80121b:	c3                   	ret    

0080121c <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80121c:	83 fa 01             	cmp    $0x1,%edx
  80121f:	7f 0f                	jg     801230 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  801221:	85 d2                	test   %edx,%edx
  801223:	74 18                	je     80123d <getint+0x21>
		return va_arg(*ap, long);
  801225:	8b 10                	mov    (%eax),%edx
  801227:	8d 4a 04             	lea    0x4(%edx),%ecx
  80122a:	89 08                	mov    %ecx,(%eax)
  80122c:	8b 02                	mov    (%edx),%eax
  80122e:	99                   	cltd   
  80122f:	c3                   	ret    
		return va_arg(*ap, long long);
  801230:	8b 10                	mov    (%eax),%edx
  801232:	8d 4a 08             	lea    0x8(%edx),%ecx
  801235:	89 08                	mov    %ecx,(%eax)
  801237:	8b 02                	mov    (%edx),%eax
  801239:	8b 52 04             	mov    0x4(%edx),%edx
  80123c:	c3                   	ret    
	else
		return va_arg(*ap, int);
  80123d:	8b 10                	mov    (%eax),%edx
  80123f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801242:	89 08                	mov    %ecx,(%eax)
  801244:	8b 02                	mov    (%edx),%eax
  801246:	99                   	cltd   
}
  801247:	c3                   	ret    

00801248 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801248:	f3 0f 1e fb          	endbr32 
  80124c:	55                   	push   %ebp
  80124d:	89 e5                	mov    %esp,%ebp
  80124f:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801252:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801256:	8b 10                	mov    (%eax),%edx
  801258:	3b 50 04             	cmp    0x4(%eax),%edx
  80125b:	73 0a                	jae    801267 <sprintputch+0x1f>
		*b->buf++ = ch;
  80125d:	8d 4a 01             	lea    0x1(%edx),%ecx
  801260:	89 08                	mov    %ecx,(%eax)
  801262:	8b 45 08             	mov    0x8(%ebp),%eax
  801265:	88 02                	mov    %al,(%edx)
}
  801267:	5d                   	pop    %ebp
  801268:	c3                   	ret    

00801269 <printfmt>:
{
  801269:	f3 0f 1e fb          	endbr32 
  80126d:	55                   	push   %ebp
  80126e:	89 e5                	mov    %esp,%ebp
  801270:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801273:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801276:	50                   	push   %eax
  801277:	ff 75 10             	pushl  0x10(%ebp)
  80127a:	ff 75 0c             	pushl  0xc(%ebp)
  80127d:	ff 75 08             	pushl  0x8(%ebp)
  801280:	e8 05 00 00 00       	call   80128a <vprintfmt>
}
  801285:	83 c4 10             	add    $0x10,%esp
  801288:	c9                   	leave  
  801289:	c3                   	ret    

0080128a <vprintfmt>:
{
  80128a:	f3 0f 1e fb          	endbr32 
  80128e:	55                   	push   %ebp
  80128f:	89 e5                	mov    %esp,%ebp
  801291:	57                   	push   %edi
  801292:	56                   	push   %esi
  801293:	53                   	push   %ebx
  801294:	83 ec 2c             	sub    $0x2c,%esp
  801297:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80129a:	8b 75 0c             	mov    0xc(%ebp),%esi
  80129d:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012a0:	e9 86 02 00 00       	jmp    80152b <vprintfmt+0x2a1>
		padc = ' ';
  8012a5:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012a9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012b0:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012b7:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012be:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012c3:	8d 47 01             	lea    0x1(%edi),%eax
  8012c6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012c9:	0f b6 17             	movzbl (%edi),%edx
  8012cc:	8d 42 dd             	lea    -0x23(%edx),%eax
  8012cf:	3c 55                	cmp    $0x55,%al
  8012d1:	0f 87 df 02 00 00    	ja     8015b6 <vprintfmt+0x32c>
  8012d7:	0f b6 c0             	movzbl %al,%eax
  8012da:	3e ff 24 85 40 20 80 	notrack jmp *0x802040(,%eax,4)
  8012e1:	00 
  8012e2:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8012e5:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8012e9:	eb d8                	jmp    8012c3 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8012eb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012ee:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  8012f2:	eb cf                	jmp    8012c3 <vprintfmt+0x39>
  8012f4:	0f b6 d2             	movzbl %dl,%edx
  8012f7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  8012fa:	b8 00 00 00 00       	mov    $0x0,%eax
  8012ff:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801302:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801305:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801309:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80130c:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80130f:	83 f9 09             	cmp    $0x9,%ecx
  801312:	77 52                	ja     801366 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  801314:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801317:	eb e9                	jmp    801302 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  801319:	8b 45 14             	mov    0x14(%ebp),%eax
  80131c:	8d 50 04             	lea    0x4(%eax),%edx
  80131f:	89 55 14             	mov    %edx,0x14(%ebp)
  801322:	8b 00                	mov    (%eax),%eax
  801324:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801327:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80132a:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80132e:	79 93                	jns    8012c3 <vprintfmt+0x39>
				width = precision, precision = -1;
  801330:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801333:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801336:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80133d:	eb 84                	jmp    8012c3 <vprintfmt+0x39>
  80133f:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801342:	85 c0                	test   %eax,%eax
  801344:	ba 00 00 00 00       	mov    $0x0,%edx
  801349:	0f 49 d0             	cmovns %eax,%edx
  80134c:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80134f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801352:	e9 6c ff ff ff       	jmp    8012c3 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801357:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80135a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801361:	e9 5d ff ff ff       	jmp    8012c3 <vprintfmt+0x39>
  801366:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801369:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80136c:	eb bc                	jmp    80132a <vprintfmt+0xa0>
			lflag++;
  80136e:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801371:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801374:	e9 4a ff ff ff       	jmp    8012c3 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  801379:	8b 45 14             	mov    0x14(%ebp),%eax
  80137c:	8d 50 04             	lea    0x4(%eax),%edx
  80137f:	89 55 14             	mov    %edx,0x14(%ebp)
  801382:	83 ec 08             	sub    $0x8,%esp
  801385:	56                   	push   %esi
  801386:	ff 30                	pushl  (%eax)
  801388:	ff d3                	call   *%ebx
			break;
  80138a:	83 c4 10             	add    $0x10,%esp
  80138d:	e9 96 01 00 00       	jmp    801528 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  801392:	8b 45 14             	mov    0x14(%ebp),%eax
  801395:	8d 50 04             	lea    0x4(%eax),%edx
  801398:	89 55 14             	mov    %edx,0x14(%ebp)
  80139b:	8b 00                	mov    (%eax),%eax
  80139d:	99                   	cltd   
  80139e:	31 d0                	xor    %edx,%eax
  8013a0:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013a2:	83 f8 0f             	cmp    $0xf,%eax
  8013a5:	7f 20                	jg     8013c7 <vprintfmt+0x13d>
  8013a7:	8b 14 85 a0 21 80 00 	mov    0x8021a0(,%eax,4),%edx
  8013ae:	85 d2                	test   %edx,%edx
  8013b0:	74 15                	je     8013c7 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8013b2:	52                   	push   %edx
  8013b3:	68 9d 1e 80 00       	push   $0x801e9d
  8013b8:	56                   	push   %esi
  8013b9:	53                   	push   %ebx
  8013ba:	e8 aa fe ff ff       	call   801269 <printfmt>
  8013bf:	83 c4 10             	add    $0x10,%esp
  8013c2:	e9 61 01 00 00       	jmp    801528 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8013c7:	50                   	push   %eax
  8013c8:	68 1f 1f 80 00       	push   $0x801f1f
  8013cd:	56                   	push   %esi
  8013ce:	53                   	push   %ebx
  8013cf:	e8 95 fe ff ff       	call   801269 <printfmt>
  8013d4:	83 c4 10             	add    $0x10,%esp
  8013d7:	e9 4c 01 00 00       	jmp    801528 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8013dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8013df:	8d 50 04             	lea    0x4(%eax),%edx
  8013e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8013e5:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8013e7:	85 c9                	test   %ecx,%ecx
  8013e9:	b8 18 1f 80 00       	mov    $0x801f18,%eax
  8013ee:	0f 45 c1             	cmovne %ecx,%eax
  8013f1:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  8013f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013f8:	7e 06                	jle    801400 <vprintfmt+0x176>
  8013fa:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  8013fe:	75 0d                	jne    80140d <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  801400:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801403:	89 c7                	mov    %eax,%edi
  801405:	03 45 e0             	add    -0x20(%ebp),%eax
  801408:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80140b:	eb 57                	jmp    801464 <vprintfmt+0x1da>
  80140d:	83 ec 08             	sub    $0x8,%esp
  801410:	ff 75 d8             	pushl  -0x28(%ebp)
  801413:	ff 75 cc             	pushl  -0x34(%ebp)
  801416:	e8 4f 02 00 00       	call   80166a <strnlen>
  80141b:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80141e:	29 c2                	sub    %eax,%edx
  801420:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801423:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801426:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80142a:	89 5d 08             	mov    %ebx,0x8(%ebp)
  80142d:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80142f:	85 db                	test   %ebx,%ebx
  801431:	7e 10                	jle    801443 <vprintfmt+0x1b9>
					putch(padc, putdat);
  801433:	83 ec 08             	sub    $0x8,%esp
  801436:	56                   	push   %esi
  801437:	57                   	push   %edi
  801438:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80143b:	83 eb 01             	sub    $0x1,%ebx
  80143e:	83 c4 10             	add    $0x10,%esp
  801441:	eb ec                	jmp    80142f <vprintfmt+0x1a5>
  801443:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801446:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801449:	85 d2                	test   %edx,%edx
  80144b:	b8 00 00 00 00       	mov    $0x0,%eax
  801450:	0f 49 c2             	cmovns %edx,%eax
  801453:	29 c2                	sub    %eax,%edx
  801455:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801458:	eb a6                	jmp    801400 <vprintfmt+0x176>
					putch(ch, putdat);
  80145a:	83 ec 08             	sub    $0x8,%esp
  80145d:	56                   	push   %esi
  80145e:	52                   	push   %edx
  80145f:	ff d3                	call   *%ebx
  801461:	83 c4 10             	add    $0x10,%esp
  801464:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801467:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801469:	83 c7 01             	add    $0x1,%edi
  80146c:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801470:	0f be d0             	movsbl %al,%edx
  801473:	85 d2                	test   %edx,%edx
  801475:	74 42                	je     8014b9 <vprintfmt+0x22f>
  801477:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80147b:	78 06                	js     801483 <vprintfmt+0x1f9>
  80147d:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  801481:	78 1e                	js     8014a1 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  801483:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801487:	74 d1                	je     80145a <vprintfmt+0x1d0>
  801489:	0f be c0             	movsbl %al,%eax
  80148c:	83 e8 20             	sub    $0x20,%eax
  80148f:	83 f8 5e             	cmp    $0x5e,%eax
  801492:	76 c6                	jbe    80145a <vprintfmt+0x1d0>
					putch('?', putdat);
  801494:	83 ec 08             	sub    $0x8,%esp
  801497:	56                   	push   %esi
  801498:	6a 3f                	push   $0x3f
  80149a:	ff d3                	call   *%ebx
  80149c:	83 c4 10             	add    $0x10,%esp
  80149f:	eb c3                	jmp    801464 <vprintfmt+0x1da>
  8014a1:	89 cf                	mov    %ecx,%edi
  8014a3:	eb 0e                	jmp    8014b3 <vprintfmt+0x229>
				putch(' ', putdat);
  8014a5:	83 ec 08             	sub    $0x8,%esp
  8014a8:	56                   	push   %esi
  8014a9:	6a 20                	push   $0x20
  8014ab:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8014ad:	83 ef 01             	sub    $0x1,%edi
  8014b0:	83 c4 10             	add    $0x10,%esp
  8014b3:	85 ff                	test   %edi,%edi
  8014b5:	7f ee                	jg     8014a5 <vprintfmt+0x21b>
  8014b7:	eb 6f                	jmp    801528 <vprintfmt+0x29e>
  8014b9:	89 cf                	mov    %ecx,%edi
  8014bb:	eb f6                	jmp    8014b3 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8014bd:	89 ca                	mov    %ecx,%edx
  8014bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8014c2:	e8 55 fd ff ff       	call   80121c <getint>
  8014c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014ca:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8014cd:	85 d2                	test   %edx,%edx
  8014cf:	78 0b                	js     8014dc <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8014d1:	89 d1                	mov    %edx,%ecx
  8014d3:	89 c2                	mov    %eax,%edx
			base = 10;
  8014d5:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014da:	eb 32                	jmp    80150e <vprintfmt+0x284>
				putch('-', putdat);
  8014dc:	83 ec 08             	sub    $0x8,%esp
  8014df:	56                   	push   %esi
  8014e0:	6a 2d                	push   $0x2d
  8014e2:	ff d3                	call   *%ebx
				num = -(long long) num;
  8014e4:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014e7:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8014ea:	f7 da                	neg    %edx
  8014ec:	83 d1 00             	adc    $0x0,%ecx
  8014ef:	f7 d9                	neg    %ecx
  8014f1:	83 c4 10             	add    $0x10,%esp
			base = 10;
  8014f4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014f9:	eb 13                	jmp    80150e <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8014fb:	89 ca                	mov    %ecx,%edx
  8014fd:	8d 45 14             	lea    0x14(%ebp),%eax
  801500:	e8 e3 fc ff ff       	call   8011e8 <getuint>
  801505:	89 d1                	mov    %edx,%ecx
  801507:	89 c2                	mov    %eax,%edx
			base = 10;
  801509:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  80150e:	83 ec 0c             	sub    $0xc,%esp
  801511:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801515:	57                   	push   %edi
  801516:	ff 75 e0             	pushl  -0x20(%ebp)
  801519:	50                   	push   %eax
  80151a:	51                   	push   %ecx
  80151b:	52                   	push   %edx
  80151c:	89 f2                	mov    %esi,%edx
  80151e:	89 d8                	mov    %ebx,%eax
  801520:	e8 1a fc ff ff       	call   80113f <printnum>
			break;
  801525:	83 c4 20             	add    $0x20,%esp
{
  801528:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80152b:	83 c7 01             	add    $0x1,%edi
  80152e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801532:	83 f8 25             	cmp    $0x25,%eax
  801535:	0f 84 6a fd ff ff    	je     8012a5 <vprintfmt+0x1b>
			if (ch == '\0')
  80153b:	85 c0                	test   %eax,%eax
  80153d:	0f 84 93 00 00 00    	je     8015d6 <vprintfmt+0x34c>
			putch(ch, putdat);
  801543:	83 ec 08             	sub    $0x8,%esp
  801546:	56                   	push   %esi
  801547:	50                   	push   %eax
  801548:	ff d3                	call   *%ebx
  80154a:	83 c4 10             	add    $0x10,%esp
  80154d:	eb dc                	jmp    80152b <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  80154f:	89 ca                	mov    %ecx,%edx
  801551:	8d 45 14             	lea    0x14(%ebp),%eax
  801554:	e8 8f fc ff ff       	call   8011e8 <getuint>
  801559:	89 d1                	mov    %edx,%ecx
  80155b:	89 c2                	mov    %eax,%edx
			base = 8;
  80155d:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  801562:	eb aa                	jmp    80150e <vprintfmt+0x284>
			putch('0', putdat);
  801564:	83 ec 08             	sub    $0x8,%esp
  801567:	56                   	push   %esi
  801568:	6a 30                	push   $0x30
  80156a:	ff d3                	call   *%ebx
			putch('x', putdat);
  80156c:	83 c4 08             	add    $0x8,%esp
  80156f:	56                   	push   %esi
  801570:	6a 78                	push   $0x78
  801572:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  801574:	8b 45 14             	mov    0x14(%ebp),%eax
  801577:	8d 50 04             	lea    0x4(%eax),%edx
  80157a:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  80157d:	8b 10                	mov    (%eax),%edx
  80157f:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801584:	83 c4 10             	add    $0x10,%esp
			base = 16;
  801587:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80158c:	eb 80                	jmp    80150e <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  80158e:	89 ca                	mov    %ecx,%edx
  801590:	8d 45 14             	lea    0x14(%ebp),%eax
  801593:	e8 50 fc ff ff       	call   8011e8 <getuint>
  801598:	89 d1                	mov    %edx,%ecx
  80159a:	89 c2                	mov    %eax,%edx
			base = 16;
  80159c:	b8 10 00 00 00       	mov    $0x10,%eax
  8015a1:	e9 68 ff ff ff       	jmp    80150e <vprintfmt+0x284>
			putch(ch, putdat);
  8015a6:	83 ec 08             	sub    $0x8,%esp
  8015a9:	56                   	push   %esi
  8015aa:	6a 25                	push   $0x25
  8015ac:	ff d3                	call   *%ebx
			break;
  8015ae:	83 c4 10             	add    $0x10,%esp
  8015b1:	e9 72 ff ff ff       	jmp    801528 <vprintfmt+0x29e>
			putch('%', putdat);
  8015b6:	83 ec 08             	sub    $0x8,%esp
  8015b9:	56                   	push   %esi
  8015ba:	6a 25                	push   $0x25
  8015bc:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015be:	83 c4 10             	add    $0x10,%esp
  8015c1:	89 f8                	mov    %edi,%eax
  8015c3:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8015c7:	74 05                	je     8015ce <vprintfmt+0x344>
  8015c9:	83 e8 01             	sub    $0x1,%eax
  8015cc:	eb f5                	jmp    8015c3 <vprintfmt+0x339>
  8015ce:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015d1:	e9 52 ff ff ff       	jmp    801528 <vprintfmt+0x29e>
}
  8015d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015d9:	5b                   	pop    %ebx
  8015da:	5e                   	pop    %esi
  8015db:	5f                   	pop    %edi
  8015dc:	5d                   	pop    %ebp
  8015dd:	c3                   	ret    

008015de <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015de:	f3 0f 1e fb          	endbr32 
  8015e2:	55                   	push   %ebp
  8015e3:	89 e5                	mov    %esp,%ebp
  8015e5:	83 ec 18             	sub    $0x18,%esp
  8015e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8015eb:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015ee:	89 45 ec             	mov    %eax,-0x14(%ebp)
  8015f1:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  8015f5:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  8015f8:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  8015ff:	85 c0                	test   %eax,%eax
  801601:	74 26                	je     801629 <vsnprintf+0x4b>
  801603:	85 d2                	test   %edx,%edx
  801605:	7e 22                	jle    801629 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801607:	ff 75 14             	pushl  0x14(%ebp)
  80160a:	ff 75 10             	pushl  0x10(%ebp)
  80160d:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801610:	50                   	push   %eax
  801611:	68 48 12 80 00       	push   $0x801248
  801616:	e8 6f fc ff ff       	call   80128a <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80161b:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80161e:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801621:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801624:	83 c4 10             	add    $0x10,%esp
}
  801627:	c9                   	leave  
  801628:	c3                   	ret    
		return -E_INVAL;
  801629:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80162e:	eb f7                	jmp    801627 <vsnprintf+0x49>

00801630 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801630:	f3 0f 1e fb          	endbr32 
  801634:	55                   	push   %ebp
  801635:	89 e5                	mov    %esp,%ebp
  801637:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80163a:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80163d:	50                   	push   %eax
  80163e:	ff 75 10             	pushl  0x10(%ebp)
  801641:	ff 75 0c             	pushl  0xc(%ebp)
  801644:	ff 75 08             	pushl  0x8(%ebp)
  801647:	e8 92 ff ff ff       	call   8015de <vsnprintf>
	va_end(ap);

	return rc;
}
  80164c:	c9                   	leave  
  80164d:	c3                   	ret    

0080164e <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80164e:	f3 0f 1e fb          	endbr32 
  801652:	55                   	push   %ebp
  801653:	89 e5                	mov    %esp,%ebp
  801655:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801658:	b8 00 00 00 00       	mov    $0x0,%eax
  80165d:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801661:	74 05                	je     801668 <strlen+0x1a>
		n++;
  801663:	83 c0 01             	add    $0x1,%eax
  801666:	eb f5                	jmp    80165d <strlen+0xf>
	return n;
}
  801668:	5d                   	pop    %ebp
  801669:	c3                   	ret    

0080166a <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80166a:	f3 0f 1e fb          	endbr32 
  80166e:	55                   	push   %ebp
  80166f:	89 e5                	mov    %esp,%ebp
  801671:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801674:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801677:	b8 00 00 00 00       	mov    $0x0,%eax
  80167c:	39 d0                	cmp    %edx,%eax
  80167e:	74 0d                	je     80168d <strnlen+0x23>
  801680:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801684:	74 05                	je     80168b <strnlen+0x21>
		n++;
  801686:	83 c0 01             	add    $0x1,%eax
  801689:	eb f1                	jmp    80167c <strnlen+0x12>
  80168b:	89 c2                	mov    %eax,%edx
	return n;
}
  80168d:	89 d0                	mov    %edx,%eax
  80168f:	5d                   	pop    %ebp
  801690:	c3                   	ret    

00801691 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  801691:	f3 0f 1e fb          	endbr32 
  801695:	55                   	push   %ebp
  801696:	89 e5                	mov    %esp,%ebp
  801698:	53                   	push   %ebx
  801699:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80169c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  80169f:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a4:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8016a8:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8016ab:	83 c0 01             	add    $0x1,%eax
  8016ae:	84 d2                	test   %dl,%dl
  8016b0:	75 f2                	jne    8016a4 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8016b2:	89 c8                	mov    %ecx,%eax
  8016b4:	5b                   	pop    %ebx
  8016b5:	5d                   	pop    %ebp
  8016b6:	c3                   	ret    

008016b7 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016b7:	f3 0f 1e fb          	endbr32 
  8016bb:	55                   	push   %ebp
  8016bc:	89 e5                	mov    %esp,%ebp
  8016be:	53                   	push   %ebx
  8016bf:	83 ec 10             	sub    $0x10,%esp
  8016c2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016c5:	53                   	push   %ebx
  8016c6:	e8 83 ff ff ff       	call   80164e <strlen>
  8016cb:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8016ce:	ff 75 0c             	pushl  0xc(%ebp)
  8016d1:	01 d8                	add    %ebx,%eax
  8016d3:	50                   	push   %eax
  8016d4:	e8 b8 ff ff ff       	call   801691 <strcpy>
	return dst;
}
  8016d9:	89 d8                	mov    %ebx,%eax
  8016db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016de:	c9                   	leave  
  8016df:	c3                   	ret    

008016e0 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016e0:	f3 0f 1e fb          	endbr32 
  8016e4:	55                   	push   %ebp
  8016e5:	89 e5                	mov    %esp,%ebp
  8016e7:	56                   	push   %esi
  8016e8:	53                   	push   %ebx
  8016e9:	8b 75 08             	mov    0x8(%ebp),%esi
  8016ec:	8b 55 0c             	mov    0xc(%ebp),%edx
  8016ef:	89 f3                	mov    %esi,%ebx
  8016f1:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8016f4:	89 f0                	mov    %esi,%eax
  8016f6:	39 d8                	cmp    %ebx,%eax
  8016f8:	74 11                	je     80170b <strncpy+0x2b>
		*dst++ = *src;
  8016fa:	83 c0 01             	add    $0x1,%eax
  8016fd:	0f b6 0a             	movzbl (%edx),%ecx
  801700:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801703:	80 f9 01             	cmp    $0x1,%cl
  801706:	83 da ff             	sbb    $0xffffffff,%edx
  801709:	eb eb                	jmp    8016f6 <strncpy+0x16>
	}
	return ret;
}
  80170b:	89 f0                	mov    %esi,%eax
  80170d:	5b                   	pop    %ebx
  80170e:	5e                   	pop    %esi
  80170f:	5d                   	pop    %ebp
  801710:	c3                   	ret    

00801711 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801711:	f3 0f 1e fb          	endbr32 
  801715:	55                   	push   %ebp
  801716:	89 e5                	mov    %esp,%ebp
  801718:	56                   	push   %esi
  801719:	53                   	push   %ebx
  80171a:	8b 75 08             	mov    0x8(%ebp),%esi
  80171d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801720:	8b 55 10             	mov    0x10(%ebp),%edx
  801723:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801725:	85 d2                	test   %edx,%edx
  801727:	74 21                	je     80174a <strlcpy+0x39>
  801729:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80172d:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80172f:	39 c2                	cmp    %eax,%edx
  801731:	74 14                	je     801747 <strlcpy+0x36>
  801733:	0f b6 19             	movzbl (%ecx),%ebx
  801736:	84 db                	test   %bl,%bl
  801738:	74 0b                	je     801745 <strlcpy+0x34>
			*dst++ = *src++;
  80173a:	83 c1 01             	add    $0x1,%ecx
  80173d:	83 c2 01             	add    $0x1,%edx
  801740:	88 5a ff             	mov    %bl,-0x1(%edx)
  801743:	eb ea                	jmp    80172f <strlcpy+0x1e>
  801745:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801747:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80174a:	29 f0                	sub    %esi,%eax
}
  80174c:	5b                   	pop    %ebx
  80174d:	5e                   	pop    %esi
  80174e:	5d                   	pop    %ebp
  80174f:	c3                   	ret    

00801750 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801750:	f3 0f 1e fb          	endbr32 
  801754:	55                   	push   %ebp
  801755:	89 e5                	mov    %esp,%ebp
  801757:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80175a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80175d:	0f b6 01             	movzbl (%ecx),%eax
  801760:	84 c0                	test   %al,%al
  801762:	74 0c                	je     801770 <strcmp+0x20>
  801764:	3a 02                	cmp    (%edx),%al
  801766:	75 08                	jne    801770 <strcmp+0x20>
		p++, q++;
  801768:	83 c1 01             	add    $0x1,%ecx
  80176b:	83 c2 01             	add    $0x1,%edx
  80176e:	eb ed                	jmp    80175d <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801770:	0f b6 c0             	movzbl %al,%eax
  801773:	0f b6 12             	movzbl (%edx),%edx
  801776:	29 d0                	sub    %edx,%eax
}
  801778:	5d                   	pop    %ebp
  801779:	c3                   	ret    

0080177a <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80177a:	f3 0f 1e fb          	endbr32 
  80177e:	55                   	push   %ebp
  80177f:	89 e5                	mov    %esp,%ebp
  801781:	53                   	push   %ebx
  801782:	8b 45 08             	mov    0x8(%ebp),%eax
  801785:	8b 55 0c             	mov    0xc(%ebp),%edx
  801788:	89 c3                	mov    %eax,%ebx
  80178a:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80178d:	eb 06                	jmp    801795 <strncmp+0x1b>
		n--, p++, q++;
  80178f:	83 c0 01             	add    $0x1,%eax
  801792:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  801795:	39 d8                	cmp    %ebx,%eax
  801797:	74 16                	je     8017af <strncmp+0x35>
  801799:	0f b6 08             	movzbl (%eax),%ecx
  80179c:	84 c9                	test   %cl,%cl
  80179e:	74 04                	je     8017a4 <strncmp+0x2a>
  8017a0:	3a 0a                	cmp    (%edx),%cl
  8017a2:	74 eb                	je     80178f <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017a4:	0f b6 00             	movzbl (%eax),%eax
  8017a7:	0f b6 12             	movzbl (%edx),%edx
  8017aa:	29 d0                	sub    %edx,%eax
}
  8017ac:	5b                   	pop    %ebx
  8017ad:	5d                   	pop    %ebp
  8017ae:	c3                   	ret    
		return 0;
  8017af:	b8 00 00 00 00       	mov    $0x0,%eax
  8017b4:	eb f6                	jmp    8017ac <strncmp+0x32>

008017b6 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017b6:	f3 0f 1e fb          	endbr32 
  8017ba:	55                   	push   %ebp
  8017bb:	89 e5                	mov    %esp,%ebp
  8017bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8017c0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017c4:	0f b6 10             	movzbl (%eax),%edx
  8017c7:	84 d2                	test   %dl,%dl
  8017c9:	74 09                	je     8017d4 <strchr+0x1e>
		if (*s == c)
  8017cb:	38 ca                	cmp    %cl,%dl
  8017cd:	74 0a                	je     8017d9 <strchr+0x23>
	for (; *s; s++)
  8017cf:	83 c0 01             	add    $0x1,%eax
  8017d2:	eb f0                	jmp    8017c4 <strchr+0xe>
			return (char *) s;
	return 0;
  8017d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017d9:	5d                   	pop    %ebp
  8017da:	c3                   	ret    

008017db <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017db:	f3 0f 1e fb          	endbr32 
  8017df:	55                   	push   %ebp
  8017e0:	89 e5                	mov    %esp,%ebp
  8017e2:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e5:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017e9:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017ec:	38 ca                	cmp    %cl,%dl
  8017ee:	74 09                	je     8017f9 <strfind+0x1e>
  8017f0:	84 d2                	test   %dl,%dl
  8017f2:	74 05                	je     8017f9 <strfind+0x1e>
	for (; *s; s++)
  8017f4:	83 c0 01             	add    $0x1,%eax
  8017f7:	eb f0                	jmp    8017e9 <strfind+0xe>
			break;
	return (char *) s;
}
  8017f9:	5d                   	pop    %ebp
  8017fa:	c3                   	ret    

008017fb <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  8017fb:	f3 0f 1e fb          	endbr32 
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	57                   	push   %edi
  801803:	56                   	push   %esi
  801804:	53                   	push   %ebx
  801805:	8b 55 08             	mov    0x8(%ebp),%edx
  801808:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  80180b:	85 c9                	test   %ecx,%ecx
  80180d:	74 33                	je     801842 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80180f:	89 d0                	mov    %edx,%eax
  801811:	09 c8                	or     %ecx,%eax
  801813:	a8 03                	test   $0x3,%al
  801815:	75 23                	jne    80183a <memset+0x3f>
		c &= 0xFF;
  801817:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80181b:	89 d8                	mov    %ebx,%eax
  80181d:	c1 e0 08             	shl    $0x8,%eax
  801820:	89 df                	mov    %ebx,%edi
  801822:	c1 e7 18             	shl    $0x18,%edi
  801825:	89 de                	mov    %ebx,%esi
  801827:	c1 e6 10             	shl    $0x10,%esi
  80182a:	09 f7                	or     %esi,%edi
  80182c:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  80182e:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801831:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  801833:	89 d7                	mov    %edx,%edi
  801835:	fc                   	cld    
  801836:	f3 ab                	rep stos %eax,%es:(%edi)
  801838:	eb 08                	jmp    801842 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80183a:	89 d7                	mov    %edx,%edi
  80183c:	8b 45 0c             	mov    0xc(%ebp),%eax
  80183f:	fc                   	cld    
  801840:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  801842:	89 d0                	mov    %edx,%eax
  801844:	5b                   	pop    %ebx
  801845:	5e                   	pop    %esi
  801846:	5f                   	pop    %edi
  801847:	5d                   	pop    %ebp
  801848:	c3                   	ret    

00801849 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801849:	f3 0f 1e fb          	endbr32 
  80184d:	55                   	push   %ebp
  80184e:	89 e5                	mov    %esp,%ebp
  801850:	57                   	push   %edi
  801851:	56                   	push   %esi
  801852:	8b 45 08             	mov    0x8(%ebp),%eax
  801855:	8b 75 0c             	mov    0xc(%ebp),%esi
  801858:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80185b:	39 c6                	cmp    %eax,%esi
  80185d:	73 32                	jae    801891 <memmove+0x48>
  80185f:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801862:	39 c2                	cmp    %eax,%edx
  801864:	76 2b                	jbe    801891 <memmove+0x48>
		s += n;
		d += n;
  801866:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801869:	89 fe                	mov    %edi,%esi
  80186b:	09 ce                	or     %ecx,%esi
  80186d:	09 d6                	or     %edx,%esi
  80186f:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801875:	75 0e                	jne    801885 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801877:	83 ef 04             	sub    $0x4,%edi
  80187a:	8d 72 fc             	lea    -0x4(%edx),%esi
  80187d:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801880:	fd                   	std    
  801881:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801883:	eb 09                	jmp    80188e <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801885:	83 ef 01             	sub    $0x1,%edi
  801888:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80188b:	fd                   	std    
  80188c:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80188e:	fc                   	cld    
  80188f:	eb 1a                	jmp    8018ab <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801891:	89 c2                	mov    %eax,%edx
  801893:	09 ca                	or     %ecx,%edx
  801895:	09 f2                	or     %esi,%edx
  801897:	f6 c2 03             	test   $0x3,%dl
  80189a:	75 0a                	jne    8018a6 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  80189c:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  80189f:	89 c7                	mov    %eax,%edi
  8018a1:	fc                   	cld    
  8018a2:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a4:	eb 05                	jmp    8018ab <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8018a6:	89 c7                	mov    %eax,%edi
  8018a8:	fc                   	cld    
  8018a9:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018ab:	5e                   	pop    %esi
  8018ac:	5f                   	pop    %edi
  8018ad:	5d                   	pop    %ebp
  8018ae:	c3                   	ret    

008018af <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018af:	f3 0f 1e fb          	endbr32 
  8018b3:	55                   	push   %ebp
  8018b4:	89 e5                	mov    %esp,%ebp
  8018b6:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8018b9:	ff 75 10             	pushl  0x10(%ebp)
  8018bc:	ff 75 0c             	pushl  0xc(%ebp)
  8018bf:	ff 75 08             	pushl  0x8(%ebp)
  8018c2:	e8 82 ff ff ff       	call   801849 <memmove>
}
  8018c7:	c9                   	leave  
  8018c8:	c3                   	ret    

008018c9 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018c9:	f3 0f 1e fb          	endbr32 
  8018cd:	55                   	push   %ebp
  8018ce:	89 e5                	mov    %esp,%ebp
  8018d0:	56                   	push   %esi
  8018d1:	53                   	push   %ebx
  8018d2:	8b 45 08             	mov    0x8(%ebp),%eax
  8018d5:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018d8:	89 c6                	mov    %eax,%esi
  8018da:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018dd:	39 f0                	cmp    %esi,%eax
  8018df:	74 1c                	je     8018fd <memcmp+0x34>
		if (*s1 != *s2)
  8018e1:	0f b6 08             	movzbl (%eax),%ecx
  8018e4:	0f b6 1a             	movzbl (%edx),%ebx
  8018e7:	38 d9                	cmp    %bl,%cl
  8018e9:	75 08                	jne    8018f3 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8018eb:	83 c0 01             	add    $0x1,%eax
  8018ee:	83 c2 01             	add    $0x1,%edx
  8018f1:	eb ea                	jmp    8018dd <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  8018f3:	0f b6 c1             	movzbl %cl,%eax
  8018f6:	0f b6 db             	movzbl %bl,%ebx
  8018f9:	29 d8                	sub    %ebx,%eax
  8018fb:	eb 05                	jmp    801902 <memcmp+0x39>
	}

	return 0;
  8018fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801902:	5b                   	pop    %ebx
  801903:	5e                   	pop    %esi
  801904:	5d                   	pop    %ebp
  801905:	c3                   	ret    

00801906 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801906:	f3 0f 1e fb          	endbr32 
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	8b 45 08             	mov    0x8(%ebp),%eax
  801910:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801913:	89 c2                	mov    %eax,%edx
  801915:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801918:	39 d0                	cmp    %edx,%eax
  80191a:	73 09                	jae    801925 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  80191c:	38 08                	cmp    %cl,(%eax)
  80191e:	74 05                	je     801925 <memfind+0x1f>
	for (; s < ends; s++)
  801920:	83 c0 01             	add    $0x1,%eax
  801923:	eb f3                	jmp    801918 <memfind+0x12>
			break;
	return (void *) s;
}
  801925:	5d                   	pop    %ebp
  801926:	c3                   	ret    

00801927 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801927:	f3 0f 1e fb          	endbr32 
  80192b:	55                   	push   %ebp
  80192c:	89 e5                	mov    %esp,%ebp
  80192e:	57                   	push   %edi
  80192f:	56                   	push   %esi
  801930:	53                   	push   %ebx
  801931:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801934:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801937:	eb 03                	jmp    80193c <strtol+0x15>
		s++;
  801939:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  80193c:	0f b6 01             	movzbl (%ecx),%eax
  80193f:	3c 20                	cmp    $0x20,%al
  801941:	74 f6                	je     801939 <strtol+0x12>
  801943:	3c 09                	cmp    $0x9,%al
  801945:	74 f2                	je     801939 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801947:	3c 2b                	cmp    $0x2b,%al
  801949:	74 2a                	je     801975 <strtol+0x4e>
	int neg = 0;
  80194b:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801950:	3c 2d                	cmp    $0x2d,%al
  801952:	74 2b                	je     80197f <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801954:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80195a:	75 0f                	jne    80196b <strtol+0x44>
  80195c:	80 39 30             	cmpb   $0x30,(%ecx)
  80195f:	74 28                	je     801989 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801961:	85 db                	test   %ebx,%ebx
  801963:	b8 0a 00 00 00       	mov    $0xa,%eax
  801968:	0f 44 d8             	cmove  %eax,%ebx
  80196b:	b8 00 00 00 00       	mov    $0x0,%eax
  801970:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801973:	eb 46                	jmp    8019bb <strtol+0x94>
		s++;
  801975:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801978:	bf 00 00 00 00       	mov    $0x0,%edi
  80197d:	eb d5                	jmp    801954 <strtol+0x2d>
		s++, neg = 1;
  80197f:	83 c1 01             	add    $0x1,%ecx
  801982:	bf 01 00 00 00       	mov    $0x1,%edi
  801987:	eb cb                	jmp    801954 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801989:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80198d:	74 0e                	je     80199d <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  80198f:	85 db                	test   %ebx,%ebx
  801991:	75 d8                	jne    80196b <strtol+0x44>
		s++, base = 8;
  801993:	83 c1 01             	add    $0x1,%ecx
  801996:	bb 08 00 00 00       	mov    $0x8,%ebx
  80199b:	eb ce                	jmp    80196b <strtol+0x44>
		s += 2, base = 16;
  80199d:	83 c1 02             	add    $0x2,%ecx
  8019a0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019a5:	eb c4                	jmp    80196b <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8019a7:	0f be d2             	movsbl %dl,%edx
  8019aa:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019ad:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019b0:	7d 3a                	jge    8019ec <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8019b2:	83 c1 01             	add    $0x1,%ecx
  8019b5:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019b9:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8019bb:	0f b6 11             	movzbl (%ecx),%edx
  8019be:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019c1:	89 f3                	mov    %esi,%ebx
  8019c3:	80 fb 09             	cmp    $0x9,%bl
  8019c6:	76 df                	jbe    8019a7 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  8019c8:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019cb:	89 f3                	mov    %esi,%ebx
  8019cd:	80 fb 19             	cmp    $0x19,%bl
  8019d0:	77 08                	ja     8019da <strtol+0xb3>
			dig = *s - 'a' + 10;
  8019d2:	0f be d2             	movsbl %dl,%edx
  8019d5:	83 ea 57             	sub    $0x57,%edx
  8019d8:	eb d3                	jmp    8019ad <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  8019da:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019dd:	89 f3                	mov    %esi,%ebx
  8019df:	80 fb 19             	cmp    $0x19,%bl
  8019e2:	77 08                	ja     8019ec <strtol+0xc5>
			dig = *s - 'A' + 10;
  8019e4:	0f be d2             	movsbl %dl,%edx
  8019e7:	83 ea 37             	sub    $0x37,%edx
  8019ea:	eb c1                	jmp    8019ad <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  8019ec:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  8019f0:	74 05                	je     8019f7 <strtol+0xd0>
		*endptr = (char *) s;
  8019f2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8019f5:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  8019f7:	89 c2                	mov    %eax,%edx
  8019f9:	f7 da                	neg    %edx
  8019fb:	85 ff                	test   %edi,%edi
  8019fd:	0f 45 c2             	cmovne %edx,%eax
}
  801a00:	5b                   	pop    %ebx
  801a01:	5e                   	pop    %esi
  801a02:	5f                   	pop    %edi
  801a03:	5d                   	pop    %ebp
  801a04:	c3                   	ret    

00801a05 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a05:	f3 0f 1e fb          	endbr32 
  801a09:	55                   	push   %ebp
  801a0a:	89 e5                	mov    %esp,%ebp
  801a0c:	56                   	push   %esi
  801a0d:	53                   	push   %ebx
  801a0e:	8b 75 08             	mov    0x8(%ebp),%esi
  801a11:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a14:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  801a17:	85 c0                	test   %eax,%eax
  801a19:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a1e:	0f 44 c2             	cmove  %edx,%eax
  801a21:	83 ec 0c             	sub    $0xc,%esp
  801a24:	50                   	push   %eax
  801a25:	e8 a7 e8 ff ff       	call   8002d1 <sys_ipc_recv>

	if (from_env_store != NULL)
  801a2a:	83 c4 10             	add    $0x10,%esp
  801a2d:	85 f6                	test   %esi,%esi
  801a2f:	74 15                	je     801a46 <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  801a31:	ba 00 00 00 00       	mov    $0x0,%edx
  801a36:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a39:	74 09                	je     801a44 <ipc_recv+0x3f>
  801a3b:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a41:	8b 52 74             	mov    0x74(%edx),%edx
  801a44:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  801a46:	85 db                	test   %ebx,%ebx
  801a48:	74 15                	je     801a5f <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  801a4a:	ba 00 00 00 00       	mov    $0x0,%edx
  801a4f:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a52:	74 09                	je     801a5d <ipc_recv+0x58>
  801a54:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a5a:	8b 52 78             	mov    0x78(%edx),%edx
  801a5d:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  801a5f:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a62:	74 08                	je     801a6c <ipc_recv+0x67>
  801a64:	a1 04 40 80 00       	mov    0x804004,%eax
  801a69:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a6c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a6f:	5b                   	pop    %ebx
  801a70:	5e                   	pop    %esi
  801a71:	5d                   	pop    %ebp
  801a72:	c3                   	ret    

00801a73 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a73:	f3 0f 1e fb          	endbr32 
  801a77:	55                   	push   %ebp
  801a78:	89 e5                	mov    %esp,%ebp
  801a7a:	57                   	push   %edi
  801a7b:	56                   	push   %esi
  801a7c:	53                   	push   %ebx
  801a7d:	83 ec 0c             	sub    $0xc,%esp
  801a80:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a83:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a86:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a89:	eb 1f                	jmp    801aaa <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  801a8b:	6a 00                	push   $0x0
  801a8d:	68 00 00 c0 ee       	push   $0xeec00000
  801a92:	56                   	push   %esi
  801a93:	57                   	push   %edi
  801a94:	e8 0f e8 ff ff       	call   8002a8 <sys_ipc_try_send>
  801a99:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  801a9c:	85 c0                	test   %eax,%eax
  801a9e:	74 30                	je     801ad0 <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  801aa0:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801aa3:	75 19                	jne    801abe <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  801aa5:	e8 e5 e6 ff ff       	call   80018f <sys_yield>
		if (pg != NULL) {
  801aaa:	85 db                	test   %ebx,%ebx
  801aac:	74 dd                	je     801a8b <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  801aae:	ff 75 14             	pushl  0x14(%ebp)
  801ab1:	53                   	push   %ebx
  801ab2:	56                   	push   %esi
  801ab3:	57                   	push   %edi
  801ab4:	e8 ef e7 ff ff       	call   8002a8 <sys_ipc_try_send>
  801ab9:	83 c4 10             	add    $0x10,%esp
  801abc:	eb de                	jmp    801a9c <ipc_send+0x29>
			panic("ipc_send: %d", res);
  801abe:	50                   	push   %eax
  801abf:	68 ff 21 80 00       	push   $0x8021ff
  801ac4:	6a 3e                	push   $0x3e
  801ac6:	68 0c 22 80 00       	push   $0x80220c
  801acb:	e8 70 f5 ff ff       	call   801040 <_panic>
	}
}
  801ad0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ad3:	5b                   	pop    %ebx
  801ad4:	5e                   	pop    %esi
  801ad5:	5f                   	pop    %edi
  801ad6:	5d                   	pop    %ebp
  801ad7:	c3                   	ret    

00801ad8 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ad8:	f3 0f 1e fb          	endbr32 
  801adc:	55                   	push   %ebp
  801add:	89 e5                	mov    %esp,%ebp
  801adf:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ae2:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ae7:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801aea:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801af0:	8b 52 50             	mov    0x50(%edx),%edx
  801af3:	39 ca                	cmp    %ecx,%edx
  801af5:	74 11                	je     801b08 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801af7:	83 c0 01             	add    $0x1,%eax
  801afa:	3d 00 04 00 00       	cmp    $0x400,%eax
  801aff:	75 e6                	jne    801ae7 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801b01:	b8 00 00 00 00       	mov    $0x0,%eax
  801b06:	eb 0b                	jmp    801b13 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801b08:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b0b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b10:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b13:	5d                   	pop    %ebp
  801b14:	c3                   	ret    

00801b15 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b15:	f3 0f 1e fb          	endbr32 
  801b19:	55                   	push   %ebp
  801b1a:	89 e5                	mov    %esp,%ebp
  801b1c:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b1f:	89 c2                	mov    %eax,%edx
  801b21:	c1 ea 16             	shr    $0x16,%edx
  801b24:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b2b:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b30:	f6 c1 01             	test   $0x1,%cl
  801b33:	74 1c                	je     801b51 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801b35:	c1 e8 0c             	shr    $0xc,%eax
  801b38:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b3f:	a8 01                	test   $0x1,%al
  801b41:	74 0e                	je     801b51 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b43:	c1 e8 0c             	shr    $0xc,%eax
  801b46:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b4d:	ef 
  801b4e:	0f b7 d2             	movzwl %dx,%edx
}
  801b51:	89 d0                	mov    %edx,%eax
  801b53:	5d                   	pop    %ebp
  801b54:	c3                   	ret    
  801b55:	66 90                	xchg   %ax,%ax
  801b57:	66 90                	xchg   %ax,%ax
  801b59:	66 90                	xchg   %ax,%ax
  801b5b:	66 90                	xchg   %ax,%ax
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
