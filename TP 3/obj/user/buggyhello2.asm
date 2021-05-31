
obj/user/buggyhello2.debug:     formato del fichero elf32-i386


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
  80002c:	e8 21 00 00 00       	call   800052 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	f3 0f 1e fb          	endbr32 
  800037:	55                   	push   %ebp
  800038:	89 e5                	mov    %esp,%ebp
  80003a:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  80003d:	68 00 00 10 00       	push   $0x100000
  800042:	ff 35 00 30 80 00    	pushl  0x803000
  800048:	e8 ba 00 00 00       	call   800107 <sys_cputs>
}
  80004d:	83 c4 10             	add    $0x10,%esp
  800050:	c9                   	leave  
  800051:	c3                   	ret    

00800052 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800052:	f3 0f 1e fb          	endbr32 
  800056:	55                   	push   %ebp
  800057:	89 e5                	mov    %esp,%ebp
  800059:	56                   	push   %esi
  80005a:	53                   	push   %ebx
  80005b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80005e:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800061:	e8 19 01 00 00       	call   80017f <sys_getenvid>
	if (id >= 0)
  800066:	85 c0                	test   %eax,%eax
  800068:	78 12                	js     80007c <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  80006a:	25 ff 03 00 00       	and    $0x3ff,%eax
  80006f:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800072:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800077:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  80007c:	85 db                	test   %ebx,%ebx
  80007e:	7e 07                	jle    800087 <libmain+0x35>
		binaryname = argv[0];
  800080:	8b 06                	mov    (%esi),%eax
  800082:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  800087:	83 ec 08             	sub    $0x8,%esp
  80008a:	56                   	push   %esi
  80008b:	53                   	push   %ebx
  80008c:	e8 a2 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800091:	e8 0a 00 00 00       	call   8000a0 <exit>
}
  800096:	83 c4 10             	add    $0x10,%esp
  800099:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80009c:	5b                   	pop    %ebx
  80009d:	5e                   	pop    %esi
  80009e:	5d                   	pop    %ebp
  80009f:	c3                   	ret    

008000a0 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000a0:	f3 0f 1e fb          	endbr32 
  8000a4:	55                   	push   %ebp
  8000a5:	89 e5                	mov    %esp,%ebp
  8000a7:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000aa:	e8 53 04 00 00       	call   800502 <close_all>
	sys_env_destroy(0);
  8000af:	83 ec 0c             	sub    $0xc,%esp
  8000b2:	6a 00                	push   $0x0
  8000b4:	e8 a0 00 00 00       	call   800159 <sys_env_destroy>
}
  8000b9:	83 c4 10             	add    $0x10,%esp
  8000bc:	c9                   	leave  
  8000bd:	c3                   	ret    

008000be <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000be:	55                   	push   %ebp
  8000bf:	89 e5                	mov    %esp,%ebp
  8000c1:	57                   	push   %edi
  8000c2:	56                   	push   %esi
  8000c3:	53                   	push   %ebx
  8000c4:	83 ec 1c             	sub    $0x1c,%esp
  8000c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000ca:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000cd:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000cf:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000d2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000d5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000d8:	8b 75 14             	mov    0x14(%ebp),%esi
  8000db:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000dd:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000e1:	74 04                	je     8000e7 <syscall+0x29>
  8000e3:	85 c0                	test   %eax,%eax
  8000e5:	7f 08                	jg     8000ef <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000ea:	5b                   	pop    %ebx
  8000eb:	5e                   	pop    %esi
  8000ec:	5f                   	pop    %edi
  8000ed:	5d                   	pop    %ebp
  8000ee:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000ef:	83 ec 0c             	sub    $0xc,%esp
  8000f2:	50                   	push   %eax
  8000f3:	ff 75 e0             	pushl  -0x20(%ebp)
  8000f6:	68 f8 1d 80 00       	push   $0x801df8
  8000fb:	6a 23                	push   $0x23
  8000fd:	68 15 1e 80 00       	push   $0x801e15
  800102:	e8 51 0f 00 00       	call   801058 <_panic>

00800107 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800107:	f3 0f 1e fb          	endbr32 
  80010b:	55                   	push   %ebp
  80010c:	89 e5                	mov    %esp,%ebp
  80010e:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800111:	6a 00                	push   $0x0
  800113:	6a 00                	push   $0x0
  800115:	6a 00                	push   $0x0
  800117:	ff 75 0c             	pushl  0xc(%ebp)
  80011a:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80011d:	ba 00 00 00 00       	mov    $0x0,%edx
  800122:	b8 00 00 00 00       	mov    $0x0,%eax
  800127:	e8 92 ff ff ff       	call   8000be <syscall>
}
  80012c:	83 c4 10             	add    $0x10,%esp
  80012f:	c9                   	leave  
  800130:	c3                   	ret    

00800131 <sys_cgetc>:

int
sys_cgetc(void)
{
  800131:	f3 0f 1e fb          	endbr32 
  800135:	55                   	push   %ebp
  800136:	89 e5                	mov    %esp,%ebp
  800138:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  80013b:	6a 00                	push   $0x0
  80013d:	6a 00                	push   $0x0
  80013f:	6a 00                	push   $0x0
  800141:	6a 00                	push   $0x0
  800143:	b9 00 00 00 00       	mov    $0x0,%ecx
  800148:	ba 00 00 00 00       	mov    $0x0,%edx
  80014d:	b8 01 00 00 00       	mov    $0x1,%eax
  800152:	e8 67 ff ff ff       	call   8000be <syscall>
}
  800157:	c9                   	leave  
  800158:	c3                   	ret    

00800159 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800159:	f3 0f 1e fb          	endbr32 
  80015d:	55                   	push   %ebp
  80015e:	89 e5                	mov    %esp,%ebp
  800160:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  800163:	6a 00                	push   $0x0
  800165:	6a 00                	push   $0x0
  800167:	6a 00                	push   $0x0
  800169:	6a 00                	push   $0x0
  80016b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80016e:	ba 01 00 00 00       	mov    $0x1,%edx
  800173:	b8 03 00 00 00       	mov    $0x3,%eax
  800178:	e8 41 ff ff ff       	call   8000be <syscall>
}
  80017d:	c9                   	leave  
  80017e:	c3                   	ret    

0080017f <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80017f:	f3 0f 1e fb          	endbr32 
  800183:	55                   	push   %ebp
  800184:	89 e5                	mov    %esp,%ebp
  800186:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800189:	6a 00                	push   $0x0
  80018b:	6a 00                	push   $0x0
  80018d:	6a 00                	push   $0x0
  80018f:	6a 00                	push   $0x0
  800191:	b9 00 00 00 00       	mov    $0x0,%ecx
  800196:	ba 00 00 00 00       	mov    $0x0,%edx
  80019b:	b8 02 00 00 00       	mov    $0x2,%eax
  8001a0:	e8 19 ff ff ff       	call   8000be <syscall>
}
  8001a5:	c9                   	leave  
  8001a6:	c3                   	ret    

008001a7 <sys_yield>:

void
sys_yield(void)
{
  8001a7:	f3 0f 1e fb          	endbr32 
  8001ab:	55                   	push   %ebp
  8001ac:	89 e5                	mov    %esp,%ebp
  8001ae:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8001b1:	6a 00                	push   $0x0
  8001b3:	6a 00                	push   $0x0
  8001b5:	6a 00                	push   $0x0
  8001b7:	6a 00                	push   $0x0
  8001b9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001be:	ba 00 00 00 00       	mov    $0x0,%edx
  8001c3:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001c8:	e8 f1 fe ff ff       	call   8000be <syscall>
}
  8001cd:	83 c4 10             	add    $0x10,%esp
  8001d0:	c9                   	leave  
  8001d1:	c3                   	ret    

008001d2 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001d2:	f3 0f 1e fb          	endbr32 
  8001d6:	55                   	push   %ebp
  8001d7:	89 e5                	mov    %esp,%ebp
  8001d9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001dc:	6a 00                	push   $0x0
  8001de:	6a 00                	push   $0x0
  8001e0:	ff 75 10             	pushl  0x10(%ebp)
  8001e3:	ff 75 0c             	pushl  0xc(%ebp)
  8001e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e9:	ba 01 00 00 00       	mov    $0x1,%edx
  8001ee:	b8 04 00 00 00       	mov    $0x4,%eax
  8001f3:	e8 c6 fe ff ff       	call   8000be <syscall>
}
  8001f8:	c9                   	leave  
  8001f9:	c3                   	ret    

008001fa <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001fa:	f3 0f 1e fb          	endbr32 
  8001fe:	55                   	push   %ebp
  8001ff:	89 e5                	mov    %esp,%ebp
  800201:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  800204:	ff 75 18             	pushl  0x18(%ebp)
  800207:	ff 75 14             	pushl  0x14(%ebp)
  80020a:	ff 75 10             	pushl  0x10(%ebp)
  80020d:	ff 75 0c             	pushl  0xc(%ebp)
  800210:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800213:	ba 01 00 00 00       	mov    $0x1,%edx
  800218:	b8 05 00 00 00       	mov    $0x5,%eax
  80021d:	e8 9c fe ff ff       	call   8000be <syscall>
}
  800222:	c9                   	leave  
  800223:	c3                   	ret    

00800224 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800224:	f3 0f 1e fb          	endbr32 
  800228:	55                   	push   %ebp
  800229:	89 e5                	mov    %esp,%ebp
  80022b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  80022e:	6a 00                	push   $0x0
  800230:	6a 00                	push   $0x0
  800232:	6a 00                	push   $0x0
  800234:	ff 75 0c             	pushl  0xc(%ebp)
  800237:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80023a:	ba 01 00 00 00       	mov    $0x1,%edx
  80023f:	b8 06 00 00 00       	mov    $0x6,%eax
  800244:	e8 75 fe ff ff       	call   8000be <syscall>
}
  800249:	c9                   	leave  
  80024a:	c3                   	ret    

0080024b <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80024b:	f3 0f 1e fb          	endbr32 
  80024f:	55                   	push   %ebp
  800250:	89 e5                	mov    %esp,%ebp
  800252:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  800255:	6a 00                	push   $0x0
  800257:	6a 00                	push   $0x0
  800259:	6a 00                	push   $0x0
  80025b:	ff 75 0c             	pushl  0xc(%ebp)
  80025e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800261:	ba 01 00 00 00       	mov    $0x1,%edx
  800266:	b8 08 00 00 00       	mov    $0x8,%eax
  80026b:	e8 4e fe ff ff       	call   8000be <syscall>
}
  800270:	c9                   	leave  
  800271:	c3                   	ret    

00800272 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800272:	f3 0f 1e fb          	endbr32 
  800276:	55                   	push   %ebp
  800277:	89 e5                	mov    %esp,%ebp
  800279:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  80027c:	6a 00                	push   $0x0
  80027e:	6a 00                	push   $0x0
  800280:	6a 00                	push   $0x0
  800282:	ff 75 0c             	pushl  0xc(%ebp)
  800285:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800288:	ba 01 00 00 00       	mov    $0x1,%edx
  80028d:	b8 09 00 00 00       	mov    $0x9,%eax
  800292:	e8 27 fe ff ff       	call   8000be <syscall>
}
  800297:	c9                   	leave  
  800298:	c3                   	ret    

00800299 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800299:	f3 0f 1e fb          	endbr32 
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8002a3:	6a 00                	push   $0x0
  8002a5:	6a 00                	push   $0x0
  8002a7:	6a 00                	push   $0x0
  8002a9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002af:	ba 01 00 00 00       	mov    $0x1,%edx
  8002b4:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b9:	e8 00 fe ff ff       	call   8000be <syscall>
}
  8002be:	c9                   	leave  
  8002bf:	c3                   	ret    

008002c0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002c0:	f3 0f 1e fb          	endbr32 
  8002c4:	55                   	push   %ebp
  8002c5:	89 e5                	mov    %esp,%ebp
  8002c7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8002ca:	6a 00                	push   $0x0
  8002cc:	ff 75 14             	pushl  0x14(%ebp)
  8002cf:	ff 75 10             	pushl  0x10(%ebp)
  8002d2:	ff 75 0c             	pushl  0xc(%ebp)
  8002d5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d8:	ba 00 00 00 00       	mov    $0x0,%edx
  8002dd:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e2:	e8 d7 fd ff ff       	call   8000be <syscall>
}
  8002e7:	c9                   	leave  
  8002e8:	c3                   	ret    

008002e9 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002e9:	f3 0f 1e fb          	endbr32 
  8002ed:	55                   	push   %ebp
  8002ee:	89 e5                	mov    %esp,%ebp
  8002f0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002f3:	6a 00                	push   $0x0
  8002f5:	6a 00                	push   $0x0
  8002f7:	6a 00                	push   $0x0
  8002f9:	6a 00                	push   $0x0
  8002fb:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002fe:	ba 01 00 00 00       	mov    $0x1,%edx
  800303:	b8 0d 00 00 00       	mov    $0xd,%eax
  800308:	e8 b1 fd ff ff       	call   8000be <syscall>
}
  80030d:	c9                   	leave  
  80030e:	c3                   	ret    

0080030f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80030f:	f3 0f 1e fb          	endbr32 
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800316:	8b 45 08             	mov    0x8(%ebp),%eax
  800319:	05 00 00 00 30       	add    $0x30000000,%eax
  80031e:	c1 e8 0c             	shr    $0xc,%eax
}
  800321:	5d                   	pop    %ebp
  800322:	c3                   	ret    

00800323 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800323:	f3 0f 1e fb          	endbr32 
  800327:	55                   	push   %ebp
  800328:	89 e5                	mov    %esp,%ebp
  80032a:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  80032d:	ff 75 08             	pushl  0x8(%ebp)
  800330:	e8 da ff ff ff       	call   80030f <fd2num>
  800335:	83 c4 10             	add    $0x10,%esp
  800338:	c1 e0 0c             	shl    $0xc,%eax
  80033b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800340:	c9                   	leave  
  800341:	c3                   	ret    

00800342 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800342:	f3 0f 1e fb          	endbr32 
  800346:	55                   	push   %ebp
  800347:	89 e5                	mov    %esp,%ebp
  800349:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80034e:	89 c2                	mov    %eax,%edx
  800350:	c1 ea 16             	shr    $0x16,%edx
  800353:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80035a:	f6 c2 01             	test   $0x1,%dl
  80035d:	74 2d                	je     80038c <fd_alloc+0x4a>
  80035f:	89 c2                	mov    %eax,%edx
  800361:	c1 ea 0c             	shr    $0xc,%edx
  800364:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80036b:	f6 c2 01             	test   $0x1,%dl
  80036e:	74 1c                	je     80038c <fd_alloc+0x4a>
  800370:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  800375:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  80037a:	75 d2                	jne    80034e <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  80037c:	8b 45 08             	mov    0x8(%ebp),%eax
  80037f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  800385:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  80038a:	eb 0a                	jmp    800396 <fd_alloc+0x54>
			*fd_store = fd;
  80038c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80038f:	89 01                	mov    %eax,(%ecx)
			return 0;
  800391:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800396:	5d                   	pop    %ebp
  800397:	c3                   	ret    

00800398 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800398:	f3 0f 1e fb          	endbr32 
  80039c:	55                   	push   %ebp
  80039d:	89 e5                	mov    %esp,%ebp
  80039f:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003a2:	83 f8 1f             	cmp    $0x1f,%eax
  8003a5:	77 30                	ja     8003d7 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003a7:	c1 e0 0c             	shl    $0xc,%eax
  8003aa:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003af:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8003b5:	f6 c2 01             	test   $0x1,%dl
  8003b8:	74 24                	je     8003de <fd_lookup+0x46>
  8003ba:	89 c2                	mov    %eax,%edx
  8003bc:	c1 ea 0c             	shr    $0xc,%edx
  8003bf:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c6:	f6 c2 01             	test   $0x1,%dl
  8003c9:	74 1a                	je     8003e5 <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003cb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003ce:	89 02                	mov    %eax,(%edx)
	return 0;
  8003d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003d5:	5d                   	pop    %ebp
  8003d6:	c3                   	ret    
		return -E_INVAL;
  8003d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003dc:	eb f7                	jmp    8003d5 <fd_lookup+0x3d>
		return -E_INVAL;
  8003de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003e3:	eb f0                	jmp    8003d5 <fd_lookup+0x3d>
  8003e5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003ea:	eb e9                	jmp    8003d5 <fd_lookup+0x3d>

008003ec <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003ec:	f3 0f 1e fb          	endbr32 
  8003f0:	55                   	push   %ebp
  8003f1:	89 e5                	mov    %esp,%ebp
  8003f3:	83 ec 08             	sub    $0x8,%esp
  8003f6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f9:	ba a0 1e 80 00       	mov    $0x801ea0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8003fe:	b8 08 30 80 00       	mov    $0x803008,%eax
		if (devtab[i]->dev_id == dev_id) {
  800403:	39 08                	cmp    %ecx,(%eax)
  800405:	74 33                	je     80043a <dev_lookup+0x4e>
  800407:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  80040a:	8b 02                	mov    (%edx),%eax
  80040c:	85 c0                	test   %eax,%eax
  80040e:	75 f3                	jne    800403 <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800410:	a1 04 40 80 00       	mov    0x804004,%eax
  800415:	8b 40 48             	mov    0x48(%eax),%eax
  800418:	83 ec 04             	sub    $0x4,%esp
  80041b:	51                   	push   %ecx
  80041c:	50                   	push   %eax
  80041d:	68 24 1e 80 00       	push   $0x801e24
  800422:	e8 18 0d 00 00       	call   80113f <cprintf>
	*dev = 0;
  800427:	8b 45 0c             	mov    0xc(%ebp),%eax
  80042a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800430:	83 c4 10             	add    $0x10,%esp
  800433:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800438:	c9                   	leave  
  800439:	c3                   	ret    
			*dev = devtab[i];
  80043a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043d:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043f:	b8 00 00 00 00       	mov    $0x0,%eax
  800444:	eb f2                	jmp    800438 <dev_lookup+0x4c>

00800446 <fd_close>:
{
  800446:	f3 0f 1e fb          	endbr32 
  80044a:	55                   	push   %ebp
  80044b:	89 e5                	mov    %esp,%ebp
  80044d:	57                   	push   %edi
  80044e:	56                   	push   %esi
  80044f:	53                   	push   %ebx
  800450:	83 ec 28             	sub    $0x28,%esp
  800453:	8b 75 08             	mov    0x8(%ebp),%esi
  800456:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800459:	56                   	push   %esi
  80045a:	e8 b0 fe ff ff       	call   80030f <fd2num>
  80045f:	83 c4 08             	add    $0x8,%esp
  800462:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  800465:	52                   	push   %edx
  800466:	50                   	push   %eax
  800467:	e8 2c ff ff ff       	call   800398 <fd_lookup>
  80046c:	89 c3                	mov    %eax,%ebx
  80046e:	83 c4 10             	add    $0x10,%esp
  800471:	85 c0                	test   %eax,%eax
  800473:	78 05                	js     80047a <fd_close+0x34>
	    || fd != fd2)
  800475:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800478:	74 16                	je     800490 <fd_close+0x4a>
		return (must_exist ? r : 0);
  80047a:	89 f8                	mov    %edi,%eax
  80047c:	84 c0                	test   %al,%al
  80047e:	b8 00 00 00 00       	mov    $0x0,%eax
  800483:	0f 44 d8             	cmove  %eax,%ebx
}
  800486:	89 d8                	mov    %ebx,%eax
  800488:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80048b:	5b                   	pop    %ebx
  80048c:	5e                   	pop    %esi
  80048d:	5f                   	pop    %edi
  80048e:	5d                   	pop    %ebp
  80048f:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800490:	83 ec 08             	sub    $0x8,%esp
  800493:	8d 45 e0             	lea    -0x20(%ebp),%eax
  800496:	50                   	push   %eax
  800497:	ff 36                	pushl  (%esi)
  800499:	e8 4e ff ff ff       	call   8003ec <dev_lookup>
  80049e:	89 c3                	mov    %eax,%ebx
  8004a0:	83 c4 10             	add    $0x10,%esp
  8004a3:	85 c0                	test   %eax,%eax
  8004a5:	78 1a                	js     8004c1 <fd_close+0x7b>
		if (dev->dev_close)
  8004a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004aa:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8004ad:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8004b2:	85 c0                	test   %eax,%eax
  8004b4:	74 0b                	je     8004c1 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8004b6:	83 ec 0c             	sub    $0xc,%esp
  8004b9:	56                   	push   %esi
  8004ba:	ff d0                	call   *%eax
  8004bc:	89 c3                	mov    %eax,%ebx
  8004be:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004c1:	83 ec 08             	sub    $0x8,%esp
  8004c4:	56                   	push   %esi
  8004c5:	6a 00                	push   $0x0
  8004c7:	e8 58 fd ff ff       	call   800224 <sys_page_unmap>
	return r;
  8004cc:	83 c4 10             	add    $0x10,%esp
  8004cf:	eb b5                	jmp    800486 <fd_close+0x40>

008004d1 <close>:

int
close(int fdnum)
{
  8004d1:	f3 0f 1e fb          	endbr32 
  8004d5:	55                   	push   %ebp
  8004d6:	89 e5                	mov    %esp,%ebp
  8004d8:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004db:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004de:	50                   	push   %eax
  8004df:	ff 75 08             	pushl  0x8(%ebp)
  8004e2:	e8 b1 fe ff ff       	call   800398 <fd_lookup>
  8004e7:	83 c4 10             	add    $0x10,%esp
  8004ea:	85 c0                	test   %eax,%eax
  8004ec:	79 02                	jns    8004f0 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8004ee:	c9                   	leave  
  8004ef:	c3                   	ret    
		return fd_close(fd, 1);
  8004f0:	83 ec 08             	sub    $0x8,%esp
  8004f3:	6a 01                	push   $0x1
  8004f5:	ff 75 f4             	pushl  -0xc(%ebp)
  8004f8:	e8 49 ff ff ff       	call   800446 <fd_close>
  8004fd:	83 c4 10             	add    $0x10,%esp
  800500:	eb ec                	jmp    8004ee <close+0x1d>

00800502 <close_all>:

void
close_all(void)
{
  800502:	f3 0f 1e fb          	endbr32 
  800506:	55                   	push   %ebp
  800507:	89 e5                	mov    %esp,%ebp
  800509:	53                   	push   %ebx
  80050a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80050d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800512:	83 ec 0c             	sub    $0xc,%esp
  800515:	53                   	push   %ebx
  800516:	e8 b6 ff ff ff       	call   8004d1 <close>
	for (i = 0; i < MAXFD; i++)
  80051b:	83 c3 01             	add    $0x1,%ebx
  80051e:	83 c4 10             	add    $0x10,%esp
  800521:	83 fb 20             	cmp    $0x20,%ebx
  800524:	75 ec                	jne    800512 <close_all+0x10>
}
  800526:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800529:	c9                   	leave  
  80052a:	c3                   	ret    

0080052b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80052b:	f3 0f 1e fb          	endbr32 
  80052f:	55                   	push   %ebp
  800530:	89 e5                	mov    %esp,%ebp
  800532:	57                   	push   %edi
  800533:	56                   	push   %esi
  800534:	53                   	push   %ebx
  800535:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800538:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80053b:	50                   	push   %eax
  80053c:	ff 75 08             	pushl  0x8(%ebp)
  80053f:	e8 54 fe ff ff       	call   800398 <fd_lookup>
  800544:	89 c3                	mov    %eax,%ebx
  800546:	83 c4 10             	add    $0x10,%esp
  800549:	85 c0                	test   %eax,%eax
  80054b:	0f 88 81 00 00 00    	js     8005d2 <dup+0xa7>
		return r;
	close(newfdnum);
  800551:	83 ec 0c             	sub    $0xc,%esp
  800554:	ff 75 0c             	pushl  0xc(%ebp)
  800557:	e8 75 ff ff ff       	call   8004d1 <close>

	newfd = INDEX2FD(newfdnum);
  80055c:	8b 75 0c             	mov    0xc(%ebp),%esi
  80055f:	c1 e6 0c             	shl    $0xc,%esi
  800562:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800568:	83 c4 04             	add    $0x4,%esp
  80056b:	ff 75 e4             	pushl  -0x1c(%ebp)
  80056e:	e8 b0 fd ff ff       	call   800323 <fd2data>
  800573:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  800575:	89 34 24             	mov    %esi,(%esp)
  800578:	e8 a6 fd ff ff       	call   800323 <fd2data>
  80057d:	83 c4 10             	add    $0x10,%esp
  800580:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800582:	89 d8                	mov    %ebx,%eax
  800584:	c1 e8 16             	shr    $0x16,%eax
  800587:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80058e:	a8 01                	test   $0x1,%al
  800590:	74 11                	je     8005a3 <dup+0x78>
  800592:	89 d8                	mov    %ebx,%eax
  800594:	c1 e8 0c             	shr    $0xc,%eax
  800597:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  80059e:	f6 c2 01             	test   $0x1,%dl
  8005a1:	75 39                	jne    8005dc <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005a3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005a6:	89 d0                	mov    %edx,%eax
  8005a8:	c1 e8 0c             	shr    $0xc,%eax
  8005ab:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b2:	83 ec 0c             	sub    $0xc,%esp
  8005b5:	25 07 0e 00 00       	and    $0xe07,%eax
  8005ba:	50                   	push   %eax
  8005bb:	56                   	push   %esi
  8005bc:	6a 00                	push   $0x0
  8005be:	52                   	push   %edx
  8005bf:	6a 00                	push   $0x0
  8005c1:	e8 34 fc ff ff       	call   8001fa <sys_page_map>
  8005c6:	89 c3                	mov    %eax,%ebx
  8005c8:	83 c4 20             	add    $0x20,%esp
  8005cb:	85 c0                	test   %eax,%eax
  8005cd:	78 31                	js     800600 <dup+0xd5>
		goto err;

	return newfdnum;
  8005cf:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005d2:	89 d8                	mov    %ebx,%eax
  8005d4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005d7:	5b                   	pop    %ebx
  8005d8:	5e                   	pop    %esi
  8005d9:	5f                   	pop    %edi
  8005da:	5d                   	pop    %ebp
  8005db:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005dc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005eb:	50                   	push   %eax
  8005ec:	57                   	push   %edi
  8005ed:	6a 00                	push   $0x0
  8005ef:	53                   	push   %ebx
  8005f0:	6a 00                	push   $0x0
  8005f2:	e8 03 fc ff ff       	call   8001fa <sys_page_map>
  8005f7:	89 c3                	mov    %eax,%ebx
  8005f9:	83 c4 20             	add    $0x20,%esp
  8005fc:	85 c0                	test   %eax,%eax
  8005fe:	79 a3                	jns    8005a3 <dup+0x78>
	sys_page_unmap(0, newfd);
  800600:	83 ec 08             	sub    $0x8,%esp
  800603:	56                   	push   %esi
  800604:	6a 00                	push   $0x0
  800606:	e8 19 fc ff ff       	call   800224 <sys_page_unmap>
	sys_page_unmap(0, nva);
  80060b:	83 c4 08             	add    $0x8,%esp
  80060e:	57                   	push   %edi
  80060f:	6a 00                	push   $0x0
  800611:	e8 0e fc ff ff       	call   800224 <sys_page_unmap>
	return r;
  800616:	83 c4 10             	add    $0x10,%esp
  800619:	eb b7                	jmp    8005d2 <dup+0xa7>

0080061b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80061b:	f3 0f 1e fb          	endbr32 
  80061f:	55                   	push   %ebp
  800620:	89 e5                	mov    %esp,%ebp
  800622:	53                   	push   %ebx
  800623:	83 ec 1c             	sub    $0x1c,%esp
  800626:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800629:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80062c:	50                   	push   %eax
  80062d:	53                   	push   %ebx
  80062e:	e8 65 fd ff ff       	call   800398 <fd_lookup>
  800633:	83 c4 10             	add    $0x10,%esp
  800636:	85 c0                	test   %eax,%eax
  800638:	78 3f                	js     800679 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80063a:	83 ec 08             	sub    $0x8,%esp
  80063d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800640:	50                   	push   %eax
  800641:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800644:	ff 30                	pushl  (%eax)
  800646:	e8 a1 fd ff ff       	call   8003ec <dev_lookup>
  80064b:	83 c4 10             	add    $0x10,%esp
  80064e:	85 c0                	test   %eax,%eax
  800650:	78 27                	js     800679 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800652:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800655:	8b 42 08             	mov    0x8(%edx),%eax
  800658:	83 e0 03             	and    $0x3,%eax
  80065b:	83 f8 01             	cmp    $0x1,%eax
  80065e:	74 1e                	je     80067e <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800660:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800663:	8b 40 08             	mov    0x8(%eax),%eax
  800666:	85 c0                	test   %eax,%eax
  800668:	74 35                	je     80069f <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80066a:	83 ec 04             	sub    $0x4,%esp
  80066d:	ff 75 10             	pushl  0x10(%ebp)
  800670:	ff 75 0c             	pushl  0xc(%ebp)
  800673:	52                   	push   %edx
  800674:	ff d0                	call   *%eax
  800676:	83 c4 10             	add    $0x10,%esp
}
  800679:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80067c:	c9                   	leave  
  80067d:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80067e:	a1 04 40 80 00       	mov    0x804004,%eax
  800683:	8b 40 48             	mov    0x48(%eax),%eax
  800686:	83 ec 04             	sub    $0x4,%esp
  800689:	53                   	push   %ebx
  80068a:	50                   	push   %eax
  80068b:	68 65 1e 80 00       	push   $0x801e65
  800690:	e8 aa 0a 00 00       	call   80113f <cprintf>
		return -E_INVAL;
  800695:	83 c4 10             	add    $0x10,%esp
  800698:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80069d:	eb da                	jmp    800679 <read+0x5e>
		return -E_NOT_SUPP;
  80069f:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006a4:	eb d3                	jmp    800679 <read+0x5e>

008006a6 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006a6:	f3 0f 1e fb          	endbr32 
  8006aa:	55                   	push   %ebp
  8006ab:	89 e5                	mov    %esp,%ebp
  8006ad:	57                   	push   %edi
  8006ae:	56                   	push   %esi
  8006af:	53                   	push   %ebx
  8006b0:	83 ec 0c             	sub    $0xc,%esp
  8006b3:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006b6:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006b9:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006be:	eb 02                	jmp    8006c2 <readn+0x1c>
  8006c0:	01 c3                	add    %eax,%ebx
  8006c2:	39 f3                	cmp    %esi,%ebx
  8006c4:	73 21                	jae    8006e7 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006c6:	83 ec 04             	sub    $0x4,%esp
  8006c9:	89 f0                	mov    %esi,%eax
  8006cb:	29 d8                	sub    %ebx,%eax
  8006cd:	50                   	push   %eax
  8006ce:	89 d8                	mov    %ebx,%eax
  8006d0:	03 45 0c             	add    0xc(%ebp),%eax
  8006d3:	50                   	push   %eax
  8006d4:	57                   	push   %edi
  8006d5:	e8 41 ff ff ff       	call   80061b <read>
		if (m < 0)
  8006da:	83 c4 10             	add    $0x10,%esp
  8006dd:	85 c0                	test   %eax,%eax
  8006df:	78 04                	js     8006e5 <readn+0x3f>
			return m;
		if (m == 0)
  8006e1:	75 dd                	jne    8006c0 <readn+0x1a>
  8006e3:	eb 02                	jmp    8006e7 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006e5:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006e7:	89 d8                	mov    %ebx,%eax
  8006e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006ec:	5b                   	pop    %ebx
  8006ed:	5e                   	pop    %esi
  8006ee:	5f                   	pop    %edi
  8006ef:	5d                   	pop    %ebp
  8006f0:	c3                   	ret    

008006f1 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006f1:	f3 0f 1e fb          	endbr32 
  8006f5:	55                   	push   %ebp
  8006f6:	89 e5                	mov    %esp,%ebp
  8006f8:	53                   	push   %ebx
  8006f9:	83 ec 1c             	sub    $0x1c,%esp
  8006fc:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006ff:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800702:	50                   	push   %eax
  800703:	53                   	push   %ebx
  800704:	e8 8f fc ff ff       	call   800398 <fd_lookup>
  800709:	83 c4 10             	add    $0x10,%esp
  80070c:	85 c0                	test   %eax,%eax
  80070e:	78 3a                	js     80074a <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800710:	83 ec 08             	sub    $0x8,%esp
  800713:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800716:	50                   	push   %eax
  800717:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80071a:	ff 30                	pushl  (%eax)
  80071c:	e8 cb fc ff ff       	call   8003ec <dev_lookup>
  800721:	83 c4 10             	add    $0x10,%esp
  800724:	85 c0                	test   %eax,%eax
  800726:	78 22                	js     80074a <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800728:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072b:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80072f:	74 1e                	je     80074f <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800731:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800734:	8b 52 0c             	mov    0xc(%edx),%edx
  800737:	85 d2                	test   %edx,%edx
  800739:	74 35                	je     800770 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80073b:	83 ec 04             	sub    $0x4,%esp
  80073e:	ff 75 10             	pushl  0x10(%ebp)
  800741:	ff 75 0c             	pushl  0xc(%ebp)
  800744:	50                   	push   %eax
  800745:	ff d2                	call   *%edx
  800747:	83 c4 10             	add    $0x10,%esp
}
  80074a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80074d:	c9                   	leave  
  80074e:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074f:	a1 04 40 80 00       	mov    0x804004,%eax
  800754:	8b 40 48             	mov    0x48(%eax),%eax
  800757:	83 ec 04             	sub    $0x4,%esp
  80075a:	53                   	push   %ebx
  80075b:	50                   	push   %eax
  80075c:	68 81 1e 80 00       	push   $0x801e81
  800761:	e8 d9 09 00 00       	call   80113f <cprintf>
		return -E_INVAL;
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80076e:	eb da                	jmp    80074a <write+0x59>
		return -E_NOT_SUPP;
  800770:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800775:	eb d3                	jmp    80074a <write+0x59>

00800777 <seek>:

int
seek(int fdnum, off_t offset)
{
  800777:	f3 0f 1e fb          	endbr32 
  80077b:	55                   	push   %ebp
  80077c:	89 e5                	mov    %esp,%ebp
  80077e:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800781:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800784:	50                   	push   %eax
  800785:	ff 75 08             	pushl  0x8(%ebp)
  800788:	e8 0b fc ff ff       	call   800398 <fd_lookup>
  80078d:	83 c4 10             	add    $0x10,%esp
  800790:	85 c0                	test   %eax,%eax
  800792:	78 0e                	js     8007a2 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  800794:	8b 55 0c             	mov    0xc(%ebp),%edx
  800797:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80079a:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  80079d:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007a2:	c9                   	leave  
  8007a3:	c3                   	ret    

008007a4 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007a4:	f3 0f 1e fb          	endbr32 
  8007a8:	55                   	push   %ebp
  8007a9:	89 e5                	mov    %esp,%ebp
  8007ab:	53                   	push   %ebx
  8007ac:	83 ec 1c             	sub    $0x1c,%esp
  8007af:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007b5:	50                   	push   %eax
  8007b6:	53                   	push   %ebx
  8007b7:	e8 dc fb ff ff       	call   800398 <fd_lookup>
  8007bc:	83 c4 10             	add    $0x10,%esp
  8007bf:	85 c0                	test   %eax,%eax
  8007c1:	78 37                	js     8007fa <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007c3:	83 ec 08             	sub    $0x8,%esp
  8007c6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007c9:	50                   	push   %eax
  8007ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007cd:	ff 30                	pushl  (%eax)
  8007cf:	e8 18 fc ff ff       	call   8003ec <dev_lookup>
  8007d4:	83 c4 10             	add    $0x10,%esp
  8007d7:	85 c0                	test   %eax,%eax
  8007d9:	78 1f                	js     8007fa <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007db:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007de:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007e2:	74 1b                	je     8007ff <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007e4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007e7:	8b 52 18             	mov    0x18(%edx),%edx
  8007ea:	85 d2                	test   %edx,%edx
  8007ec:	74 32                	je     800820 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007ee:	83 ec 08             	sub    $0x8,%esp
  8007f1:	ff 75 0c             	pushl  0xc(%ebp)
  8007f4:	50                   	push   %eax
  8007f5:	ff d2                	call   *%edx
  8007f7:	83 c4 10             	add    $0x10,%esp
}
  8007fa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007fd:	c9                   	leave  
  8007fe:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007ff:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800804:	8b 40 48             	mov    0x48(%eax),%eax
  800807:	83 ec 04             	sub    $0x4,%esp
  80080a:	53                   	push   %ebx
  80080b:	50                   	push   %eax
  80080c:	68 44 1e 80 00       	push   $0x801e44
  800811:	e8 29 09 00 00       	call   80113f <cprintf>
		return -E_INVAL;
  800816:	83 c4 10             	add    $0x10,%esp
  800819:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80081e:	eb da                	jmp    8007fa <ftruncate+0x56>
		return -E_NOT_SUPP;
  800820:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800825:	eb d3                	jmp    8007fa <ftruncate+0x56>

00800827 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800827:	f3 0f 1e fb          	endbr32 
  80082b:	55                   	push   %ebp
  80082c:	89 e5                	mov    %esp,%ebp
  80082e:	53                   	push   %ebx
  80082f:	83 ec 1c             	sub    $0x1c,%esp
  800832:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800835:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800838:	50                   	push   %eax
  800839:	ff 75 08             	pushl  0x8(%ebp)
  80083c:	e8 57 fb ff ff       	call   800398 <fd_lookup>
  800841:	83 c4 10             	add    $0x10,%esp
  800844:	85 c0                	test   %eax,%eax
  800846:	78 4b                	js     800893 <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800848:	83 ec 08             	sub    $0x8,%esp
  80084b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80084e:	50                   	push   %eax
  80084f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800852:	ff 30                	pushl  (%eax)
  800854:	e8 93 fb ff ff       	call   8003ec <dev_lookup>
  800859:	83 c4 10             	add    $0x10,%esp
  80085c:	85 c0                	test   %eax,%eax
  80085e:	78 33                	js     800893 <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  800860:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800863:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800867:	74 2f                	je     800898 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800869:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80086c:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800873:	00 00 00 
	stat->st_isdir = 0;
  800876:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80087d:	00 00 00 
	stat->st_dev = dev;
  800880:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  800886:	83 ec 08             	sub    $0x8,%esp
  800889:	53                   	push   %ebx
  80088a:	ff 75 f0             	pushl  -0x10(%ebp)
  80088d:	ff 50 14             	call   *0x14(%eax)
  800890:	83 c4 10             	add    $0x10,%esp
}
  800893:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800896:	c9                   	leave  
  800897:	c3                   	ret    
		return -E_NOT_SUPP;
  800898:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80089d:	eb f4                	jmp    800893 <fstat+0x6c>

0080089f <stat>:

int
stat(const char *path, struct Stat *stat)
{
  80089f:	f3 0f 1e fb          	endbr32 
  8008a3:	55                   	push   %ebp
  8008a4:	89 e5                	mov    %esp,%ebp
  8008a6:	56                   	push   %esi
  8008a7:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008a8:	83 ec 08             	sub    $0x8,%esp
  8008ab:	6a 00                	push   $0x0
  8008ad:	ff 75 08             	pushl  0x8(%ebp)
  8008b0:	e8 fb 01 00 00       	call   800ab0 <open>
  8008b5:	89 c3                	mov    %eax,%ebx
  8008b7:	83 c4 10             	add    $0x10,%esp
  8008ba:	85 c0                	test   %eax,%eax
  8008bc:	78 1b                	js     8008d9 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8008be:	83 ec 08             	sub    $0x8,%esp
  8008c1:	ff 75 0c             	pushl  0xc(%ebp)
  8008c4:	50                   	push   %eax
  8008c5:	e8 5d ff ff ff       	call   800827 <fstat>
  8008ca:	89 c6                	mov    %eax,%esi
	close(fd);
  8008cc:	89 1c 24             	mov    %ebx,(%esp)
  8008cf:	e8 fd fb ff ff       	call   8004d1 <close>
	return r;
  8008d4:	83 c4 10             	add    $0x10,%esp
  8008d7:	89 f3                	mov    %esi,%ebx
}
  8008d9:	89 d8                	mov    %ebx,%eax
  8008db:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008de:	5b                   	pop    %ebx
  8008df:	5e                   	pop    %esi
  8008e0:	5d                   	pop    %ebp
  8008e1:	c3                   	ret    

008008e2 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008e2:	55                   	push   %ebp
  8008e3:	89 e5                	mov    %esp,%ebp
  8008e5:	56                   	push   %esi
  8008e6:	53                   	push   %ebx
  8008e7:	89 c6                	mov    %eax,%esi
  8008e9:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008eb:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008f2:	74 27                	je     80091b <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008f4:	6a 07                	push   $0x7
  8008f6:	68 00 50 80 00       	push   $0x805000
  8008fb:	56                   	push   %esi
  8008fc:	ff 35 00 40 80 00    	pushl  0x804000
  800902:	e8 84 11 00 00       	call   801a8b <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800907:	83 c4 0c             	add    $0xc,%esp
  80090a:	6a 00                	push   $0x0
  80090c:	53                   	push   %ebx
  80090d:	6a 00                	push   $0x0
  80090f:	e8 09 11 00 00       	call   801a1d <ipc_recv>
}
  800914:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800917:	5b                   	pop    %ebx
  800918:	5e                   	pop    %esi
  800919:	5d                   	pop    %ebp
  80091a:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80091b:	83 ec 0c             	sub    $0xc,%esp
  80091e:	6a 01                	push   $0x1
  800920:	e8 cb 11 00 00       	call   801af0 <ipc_find_env>
  800925:	a3 00 40 80 00       	mov    %eax,0x804000
  80092a:	83 c4 10             	add    $0x10,%esp
  80092d:	eb c5                	jmp    8008f4 <fsipc+0x12>

0080092f <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80092f:	f3 0f 1e fb          	endbr32 
  800933:	55                   	push   %ebp
  800934:	89 e5                	mov    %esp,%ebp
  800936:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800939:	8b 45 08             	mov    0x8(%ebp),%eax
  80093c:	8b 40 0c             	mov    0xc(%eax),%eax
  80093f:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800944:	8b 45 0c             	mov    0xc(%ebp),%eax
  800947:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80094c:	ba 00 00 00 00       	mov    $0x0,%edx
  800951:	b8 02 00 00 00       	mov    $0x2,%eax
  800956:	e8 87 ff ff ff       	call   8008e2 <fsipc>
}
  80095b:	c9                   	leave  
  80095c:	c3                   	ret    

0080095d <devfile_flush>:
{
  80095d:	f3 0f 1e fb          	endbr32 
  800961:	55                   	push   %ebp
  800962:	89 e5                	mov    %esp,%ebp
  800964:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800967:	8b 45 08             	mov    0x8(%ebp),%eax
  80096a:	8b 40 0c             	mov    0xc(%eax),%eax
  80096d:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800972:	ba 00 00 00 00       	mov    $0x0,%edx
  800977:	b8 06 00 00 00       	mov    $0x6,%eax
  80097c:	e8 61 ff ff ff       	call   8008e2 <fsipc>
}
  800981:	c9                   	leave  
  800982:	c3                   	ret    

00800983 <devfile_stat>:
{
  800983:	f3 0f 1e fb          	endbr32 
  800987:	55                   	push   %ebp
  800988:	89 e5                	mov    %esp,%ebp
  80098a:	53                   	push   %ebx
  80098b:	83 ec 04             	sub    $0x4,%esp
  80098e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  800991:	8b 45 08             	mov    0x8(%ebp),%eax
  800994:	8b 40 0c             	mov    0xc(%eax),%eax
  800997:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  80099c:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a1:	b8 05 00 00 00       	mov    $0x5,%eax
  8009a6:	e8 37 ff ff ff       	call   8008e2 <fsipc>
  8009ab:	85 c0                	test   %eax,%eax
  8009ad:	78 2c                	js     8009db <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009af:	83 ec 08             	sub    $0x8,%esp
  8009b2:	68 00 50 80 00       	push   $0x805000
  8009b7:	53                   	push   %ebx
  8009b8:	e8 ec 0c 00 00       	call   8016a9 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009bd:	a1 80 50 80 00       	mov    0x805080,%eax
  8009c2:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009c8:	a1 84 50 80 00       	mov    0x805084,%eax
  8009cd:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009d3:	83 c4 10             	add    $0x10,%esp
  8009d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009db:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009de:	c9                   	leave  
  8009df:	c3                   	ret    

008009e0 <devfile_write>:
{
  8009e0:	f3 0f 1e fb          	endbr32 
  8009e4:	55                   	push   %ebp
  8009e5:	89 e5                	mov    %esp,%ebp
  8009e7:	83 ec 0c             	sub    $0xc,%esp
  8009ea:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f0:	8b 52 0c             	mov    0xc(%edx),%edx
  8009f3:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009f9:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009fe:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a03:	0f 47 c2             	cmova  %edx,%eax
  800a06:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800a0b:	50                   	push   %eax
  800a0c:	ff 75 0c             	pushl  0xc(%ebp)
  800a0f:	68 08 50 80 00       	push   $0x805008
  800a14:	e8 48 0e 00 00       	call   801861 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a19:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1e:	b8 04 00 00 00       	mov    $0x4,%eax
  800a23:	e8 ba fe ff ff       	call   8008e2 <fsipc>
}
  800a28:	c9                   	leave  
  800a29:	c3                   	ret    

00800a2a <devfile_read>:
{
  800a2a:	f3 0f 1e fb          	endbr32 
  800a2e:	55                   	push   %ebp
  800a2f:	89 e5                	mov    %esp,%ebp
  800a31:	56                   	push   %esi
  800a32:	53                   	push   %ebx
  800a33:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a36:	8b 45 08             	mov    0x8(%ebp),%eax
  800a39:	8b 40 0c             	mov    0xc(%eax),%eax
  800a3c:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a41:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a47:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4c:	b8 03 00 00 00       	mov    $0x3,%eax
  800a51:	e8 8c fe ff ff       	call   8008e2 <fsipc>
  800a56:	89 c3                	mov    %eax,%ebx
  800a58:	85 c0                	test   %eax,%eax
  800a5a:	78 1f                	js     800a7b <devfile_read+0x51>
	assert(r <= n);
  800a5c:	39 f0                	cmp    %esi,%eax
  800a5e:	77 24                	ja     800a84 <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800a60:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a65:	7f 33                	jg     800a9a <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a67:	83 ec 04             	sub    $0x4,%esp
  800a6a:	50                   	push   %eax
  800a6b:	68 00 50 80 00       	push   $0x805000
  800a70:	ff 75 0c             	pushl  0xc(%ebp)
  800a73:	e8 e9 0d 00 00       	call   801861 <memmove>
	return r;
  800a78:	83 c4 10             	add    $0x10,%esp
}
  800a7b:	89 d8                	mov    %ebx,%eax
  800a7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a80:	5b                   	pop    %ebx
  800a81:	5e                   	pop    %esi
  800a82:	5d                   	pop    %ebp
  800a83:	c3                   	ret    
	assert(r <= n);
  800a84:	68 b0 1e 80 00       	push   $0x801eb0
  800a89:	68 b7 1e 80 00       	push   $0x801eb7
  800a8e:	6a 7c                	push   $0x7c
  800a90:	68 cc 1e 80 00       	push   $0x801ecc
  800a95:	e8 be 05 00 00       	call   801058 <_panic>
	assert(r <= PGSIZE);
  800a9a:	68 d7 1e 80 00       	push   $0x801ed7
  800a9f:	68 b7 1e 80 00       	push   $0x801eb7
  800aa4:	6a 7d                	push   $0x7d
  800aa6:	68 cc 1e 80 00       	push   $0x801ecc
  800aab:	e8 a8 05 00 00       	call   801058 <_panic>

00800ab0 <open>:
{
  800ab0:	f3 0f 1e fb          	endbr32 
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	56                   	push   %esi
  800ab8:	53                   	push   %ebx
  800ab9:	83 ec 1c             	sub    $0x1c,%esp
  800abc:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800abf:	56                   	push   %esi
  800ac0:	e8 a1 0b 00 00       	call   801666 <strlen>
  800ac5:	83 c4 10             	add    $0x10,%esp
  800ac8:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800acd:	7f 6c                	jg     800b3b <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800acf:	83 ec 0c             	sub    $0xc,%esp
  800ad2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ad5:	50                   	push   %eax
  800ad6:	e8 67 f8 ff ff       	call   800342 <fd_alloc>
  800adb:	89 c3                	mov    %eax,%ebx
  800add:	83 c4 10             	add    $0x10,%esp
  800ae0:	85 c0                	test   %eax,%eax
  800ae2:	78 3c                	js     800b20 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800ae4:	83 ec 08             	sub    $0x8,%esp
  800ae7:	56                   	push   %esi
  800ae8:	68 00 50 80 00       	push   $0x805000
  800aed:	e8 b7 0b 00 00       	call   8016a9 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800af2:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af5:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800afa:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800afd:	b8 01 00 00 00       	mov    $0x1,%eax
  800b02:	e8 db fd ff ff       	call   8008e2 <fsipc>
  800b07:	89 c3                	mov    %eax,%ebx
  800b09:	83 c4 10             	add    $0x10,%esp
  800b0c:	85 c0                	test   %eax,%eax
  800b0e:	78 19                	js     800b29 <open+0x79>
	return fd2num(fd);
  800b10:	83 ec 0c             	sub    $0xc,%esp
  800b13:	ff 75 f4             	pushl  -0xc(%ebp)
  800b16:	e8 f4 f7 ff ff       	call   80030f <fd2num>
  800b1b:	89 c3                	mov    %eax,%ebx
  800b1d:	83 c4 10             	add    $0x10,%esp
}
  800b20:	89 d8                	mov    %ebx,%eax
  800b22:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b25:	5b                   	pop    %ebx
  800b26:	5e                   	pop    %esi
  800b27:	5d                   	pop    %ebp
  800b28:	c3                   	ret    
		fd_close(fd, 0);
  800b29:	83 ec 08             	sub    $0x8,%esp
  800b2c:	6a 00                	push   $0x0
  800b2e:	ff 75 f4             	pushl  -0xc(%ebp)
  800b31:	e8 10 f9 ff ff       	call   800446 <fd_close>
		return r;
  800b36:	83 c4 10             	add    $0x10,%esp
  800b39:	eb e5                	jmp    800b20 <open+0x70>
		return -E_BAD_PATH;
  800b3b:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b40:	eb de                	jmp    800b20 <open+0x70>

00800b42 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b42:	f3 0f 1e fb          	endbr32 
  800b46:	55                   	push   %ebp
  800b47:	89 e5                	mov    %esp,%ebp
  800b49:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800b51:	b8 08 00 00 00       	mov    $0x8,%eax
  800b56:	e8 87 fd ff ff       	call   8008e2 <fsipc>
}
  800b5b:	c9                   	leave  
  800b5c:	c3                   	ret    

00800b5d <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b5d:	f3 0f 1e fb          	endbr32 
  800b61:	55                   	push   %ebp
  800b62:	89 e5                	mov    %esp,%ebp
  800b64:	56                   	push   %esi
  800b65:	53                   	push   %ebx
  800b66:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b69:	83 ec 0c             	sub    $0xc,%esp
  800b6c:	ff 75 08             	pushl  0x8(%ebp)
  800b6f:	e8 af f7 ff ff       	call   800323 <fd2data>
  800b74:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b76:	83 c4 08             	add    $0x8,%esp
  800b79:	68 e3 1e 80 00       	push   $0x801ee3
  800b7e:	53                   	push   %ebx
  800b7f:	e8 25 0b 00 00       	call   8016a9 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b84:	8b 46 04             	mov    0x4(%esi),%eax
  800b87:	2b 06                	sub    (%esi),%eax
  800b89:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b8f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b96:	00 00 00 
	stat->st_dev = &devpipe;
  800b99:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800ba0:	30 80 00 
	return 0;
}
  800ba3:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bab:	5b                   	pop    %ebx
  800bac:	5e                   	pop    %esi
  800bad:	5d                   	pop    %ebp
  800bae:	c3                   	ret    

00800baf <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800baf:	f3 0f 1e fb          	endbr32 
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
  800bb6:	53                   	push   %ebx
  800bb7:	83 ec 0c             	sub    $0xc,%esp
  800bba:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bbd:	53                   	push   %ebx
  800bbe:	6a 00                	push   $0x0
  800bc0:	e8 5f f6 ff ff       	call   800224 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bc5:	89 1c 24             	mov    %ebx,(%esp)
  800bc8:	e8 56 f7 ff ff       	call   800323 <fd2data>
  800bcd:	83 c4 08             	add    $0x8,%esp
  800bd0:	50                   	push   %eax
  800bd1:	6a 00                	push   $0x0
  800bd3:	e8 4c f6 ff ff       	call   800224 <sys_page_unmap>
}
  800bd8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bdb:	c9                   	leave  
  800bdc:	c3                   	ret    

00800bdd <_pipeisclosed>:
{
  800bdd:	55                   	push   %ebp
  800bde:	89 e5                	mov    %esp,%ebp
  800be0:	57                   	push   %edi
  800be1:	56                   	push   %esi
  800be2:	53                   	push   %ebx
  800be3:	83 ec 1c             	sub    $0x1c,%esp
  800be6:	89 c7                	mov    %eax,%edi
  800be8:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800bea:	a1 04 40 80 00       	mov    0x804004,%eax
  800bef:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800bf2:	83 ec 0c             	sub    $0xc,%esp
  800bf5:	57                   	push   %edi
  800bf6:	e8 32 0f 00 00       	call   801b2d <pageref>
  800bfb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bfe:	89 34 24             	mov    %esi,(%esp)
  800c01:	e8 27 0f 00 00       	call   801b2d <pageref>
		nn = thisenv->env_runs;
  800c06:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c0c:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c0f:	83 c4 10             	add    $0x10,%esp
  800c12:	39 cb                	cmp    %ecx,%ebx
  800c14:	74 1b                	je     800c31 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c16:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c19:	75 cf                	jne    800bea <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c1b:	8b 42 58             	mov    0x58(%edx),%eax
  800c1e:	6a 01                	push   $0x1
  800c20:	50                   	push   %eax
  800c21:	53                   	push   %ebx
  800c22:	68 ea 1e 80 00       	push   $0x801eea
  800c27:	e8 13 05 00 00       	call   80113f <cprintf>
  800c2c:	83 c4 10             	add    $0x10,%esp
  800c2f:	eb b9                	jmp    800bea <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c31:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c34:	0f 94 c0             	sete   %al
  800c37:	0f b6 c0             	movzbl %al,%eax
}
  800c3a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3d:	5b                   	pop    %ebx
  800c3e:	5e                   	pop    %esi
  800c3f:	5f                   	pop    %edi
  800c40:	5d                   	pop    %ebp
  800c41:	c3                   	ret    

00800c42 <devpipe_write>:
{
  800c42:	f3 0f 1e fb          	endbr32 
  800c46:	55                   	push   %ebp
  800c47:	89 e5                	mov    %esp,%ebp
  800c49:	57                   	push   %edi
  800c4a:	56                   	push   %esi
  800c4b:	53                   	push   %ebx
  800c4c:	83 ec 28             	sub    $0x28,%esp
  800c4f:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c52:	56                   	push   %esi
  800c53:	e8 cb f6 ff ff       	call   800323 <fd2data>
  800c58:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c5a:	83 c4 10             	add    $0x10,%esp
  800c5d:	bf 00 00 00 00       	mov    $0x0,%edi
  800c62:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c65:	74 4f                	je     800cb6 <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c67:	8b 43 04             	mov    0x4(%ebx),%eax
  800c6a:	8b 0b                	mov    (%ebx),%ecx
  800c6c:	8d 51 20             	lea    0x20(%ecx),%edx
  800c6f:	39 d0                	cmp    %edx,%eax
  800c71:	72 14                	jb     800c87 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800c73:	89 da                	mov    %ebx,%edx
  800c75:	89 f0                	mov    %esi,%eax
  800c77:	e8 61 ff ff ff       	call   800bdd <_pipeisclosed>
  800c7c:	85 c0                	test   %eax,%eax
  800c7e:	75 3b                	jne    800cbb <devpipe_write+0x79>
			sys_yield();
  800c80:	e8 22 f5 ff ff       	call   8001a7 <sys_yield>
  800c85:	eb e0                	jmp    800c67 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c87:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c8a:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c8e:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c91:	89 c2                	mov    %eax,%edx
  800c93:	c1 fa 1f             	sar    $0x1f,%edx
  800c96:	89 d1                	mov    %edx,%ecx
  800c98:	c1 e9 1b             	shr    $0x1b,%ecx
  800c9b:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c9e:	83 e2 1f             	and    $0x1f,%edx
  800ca1:	29 ca                	sub    %ecx,%edx
  800ca3:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ca7:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cab:	83 c0 01             	add    $0x1,%eax
  800cae:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800cb1:	83 c7 01             	add    $0x1,%edi
  800cb4:	eb ac                	jmp    800c62 <devpipe_write+0x20>
	return i;
  800cb6:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb9:	eb 05                	jmp    800cc0 <devpipe_write+0x7e>
				return 0;
  800cbb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cc0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cc3:	5b                   	pop    %ebx
  800cc4:	5e                   	pop    %esi
  800cc5:	5f                   	pop    %edi
  800cc6:	5d                   	pop    %ebp
  800cc7:	c3                   	ret    

00800cc8 <devpipe_read>:
{
  800cc8:	f3 0f 1e fb          	endbr32 
  800ccc:	55                   	push   %ebp
  800ccd:	89 e5                	mov    %esp,%ebp
  800ccf:	57                   	push   %edi
  800cd0:	56                   	push   %esi
  800cd1:	53                   	push   %ebx
  800cd2:	83 ec 18             	sub    $0x18,%esp
  800cd5:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800cd8:	57                   	push   %edi
  800cd9:	e8 45 f6 ff ff       	call   800323 <fd2data>
  800cde:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800ce0:	83 c4 10             	add    $0x10,%esp
  800ce3:	be 00 00 00 00       	mov    $0x0,%esi
  800ce8:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ceb:	75 14                	jne    800d01 <devpipe_read+0x39>
	return i;
  800ced:	8b 45 10             	mov    0x10(%ebp),%eax
  800cf0:	eb 02                	jmp    800cf4 <devpipe_read+0x2c>
				return i;
  800cf2:	89 f0                	mov    %esi,%eax
}
  800cf4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf7:	5b                   	pop    %ebx
  800cf8:	5e                   	pop    %esi
  800cf9:	5f                   	pop    %edi
  800cfa:	5d                   	pop    %ebp
  800cfb:	c3                   	ret    
			sys_yield();
  800cfc:	e8 a6 f4 ff ff       	call   8001a7 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d01:	8b 03                	mov    (%ebx),%eax
  800d03:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d06:	75 18                	jne    800d20 <devpipe_read+0x58>
			if (i > 0)
  800d08:	85 f6                	test   %esi,%esi
  800d0a:	75 e6                	jne    800cf2 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d0c:	89 da                	mov    %ebx,%edx
  800d0e:	89 f8                	mov    %edi,%eax
  800d10:	e8 c8 fe ff ff       	call   800bdd <_pipeisclosed>
  800d15:	85 c0                	test   %eax,%eax
  800d17:	74 e3                	je     800cfc <devpipe_read+0x34>
				return 0;
  800d19:	b8 00 00 00 00       	mov    $0x0,%eax
  800d1e:	eb d4                	jmp    800cf4 <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d20:	99                   	cltd   
  800d21:	c1 ea 1b             	shr    $0x1b,%edx
  800d24:	01 d0                	add    %edx,%eax
  800d26:	83 e0 1f             	and    $0x1f,%eax
  800d29:	29 d0                	sub    %edx,%eax
  800d2b:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d33:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d36:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d39:	83 c6 01             	add    $0x1,%esi
  800d3c:	eb aa                	jmp    800ce8 <devpipe_read+0x20>

00800d3e <pipe>:
{
  800d3e:	f3 0f 1e fb          	endbr32 
  800d42:	55                   	push   %ebp
  800d43:	89 e5                	mov    %esp,%ebp
  800d45:	56                   	push   %esi
  800d46:	53                   	push   %ebx
  800d47:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d4a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d4d:	50                   	push   %eax
  800d4e:	e8 ef f5 ff ff       	call   800342 <fd_alloc>
  800d53:	89 c3                	mov    %eax,%ebx
  800d55:	83 c4 10             	add    $0x10,%esp
  800d58:	85 c0                	test   %eax,%eax
  800d5a:	0f 88 23 01 00 00    	js     800e83 <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d60:	83 ec 04             	sub    $0x4,%esp
  800d63:	68 07 04 00 00       	push   $0x407
  800d68:	ff 75 f4             	pushl  -0xc(%ebp)
  800d6b:	6a 00                	push   $0x0
  800d6d:	e8 60 f4 ff ff       	call   8001d2 <sys_page_alloc>
  800d72:	89 c3                	mov    %eax,%ebx
  800d74:	83 c4 10             	add    $0x10,%esp
  800d77:	85 c0                	test   %eax,%eax
  800d79:	0f 88 04 01 00 00    	js     800e83 <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800d7f:	83 ec 0c             	sub    $0xc,%esp
  800d82:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d85:	50                   	push   %eax
  800d86:	e8 b7 f5 ff ff       	call   800342 <fd_alloc>
  800d8b:	89 c3                	mov    %eax,%ebx
  800d8d:	83 c4 10             	add    $0x10,%esp
  800d90:	85 c0                	test   %eax,%eax
  800d92:	0f 88 db 00 00 00    	js     800e73 <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d98:	83 ec 04             	sub    $0x4,%esp
  800d9b:	68 07 04 00 00       	push   $0x407
  800da0:	ff 75 f0             	pushl  -0x10(%ebp)
  800da3:	6a 00                	push   $0x0
  800da5:	e8 28 f4 ff ff       	call   8001d2 <sys_page_alloc>
  800daa:	89 c3                	mov    %eax,%ebx
  800dac:	83 c4 10             	add    $0x10,%esp
  800daf:	85 c0                	test   %eax,%eax
  800db1:	0f 88 bc 00 00 00    	js     800e73 <pipe+0x135>
	va = fd2data(fd0);
  800db7:	83 ec 0c             	sub    $0xc,%esp
  800dba:	ff 75 f4             	pushl  -0xc(%ebp)
  800dbd:	e8 61 f5 ff ff       	call   800323 <fd2data>
  800dc2:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc4:	83 c4 0c             	add    $0xc,%esp
  800dc7:	68 07 04 00 00       	push   $0x407
  800dcc:	50                   	push   %eax
  800dcd:	6a 00                	push   $0x0
  800dcf:	e8 fe f3 ff ff       	call   8001d2 <sys_page_alloc>
  800dd4:	89 c3                	mov    %eax,%ebx
  800dd6:	83 c4 10             	add    $0x10,%esp
  800dd9:	85 c0                	test   %eax,%eax
  800ddb:	0f 88 82 00 00 00    	js     800e63 <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800de1:	83 ec 0c             	sub    $0xc,%esp
  800de4:	ff 75 f0             	pushl  -0x10(%ebp)
  800de7:	e8 37 f5 ff ff       	call   800323 <fd2data>
  800dec:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800df3:	50                   	push   %eax
  800df4:	6a 00                	push   $0x0
  800df6:	56                   	push   %esi
  800df7:	6a 00                	push   $0x0
  800df9:	e8 fc f3 ff ff       	call   8001fa <sys_page_map>
  800dfe:	89 c3                	mov    %eax,%ebx
  800e00:	83 c4 20             	add    $0x20,%esp
  800e03:	85 c0                	test   %eax,%eax
  800e05:	78 4e                	js     800e55 <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e07:	a1 24 30 80 00       	mov    0x803024,%eax
  800e0c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e0f:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e11:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e14:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e1b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e1e:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e20:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e23:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e2a:	83 ec 0c             	sub    $0xc,%esp
  800e2d:	ff 75 f4             	pushl  -0xc(%ebp)
  800e30:	e8 da f4 ff ff       	call   80030f <fd2num>
  800e35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e38:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e3a:	83 c4 04             	add    $0x4,%esp
  800e3d:	ff 75 f0             	pushl  -0x10(%ebp)
  800e40:	e8 ca f4 ff ff       	call   80030f <fd2num>
  800e45:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e48:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e4b:	83 c4 10             	add    $0x10,%esp
  800e4e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e53:	eb 2e                	jmp    800e83 <pipe+0x145>
	sys_page_unmap(0, va);
  800e55:	83 ec 08             	sub    $0x8,%esp
  800e58:	56                   	push   %esi
  800e59:	6a 00                	push   $0x0
  800e5b:	e8 c4 f3 ff ff       	call   800224 <sys_page_unmap>
  800e60:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e63:	83 ec 08             	sub    $0x8,%esp
  800e66:	ff 75 f0             	pushl  -0x10(%ebp)
  800e69:	6a 00                	push   $0x0
  800e6b:	e8 b4 f3 ff ff       	call   800224 <sys_page_unmap>
  800e70:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800e73:	83 ec 08             	sub    $0x8,%esp
  800e76:	ff 75 f4             	pushl  -0xc(%ebp)
  800e79:	6a 00                	push   $0x0
  800e7b:	e8 a4 f3 ff ff       	call   800224 <sys_page_unmap>
  800e80:	83 c4 10             	add    $0x10,%esp
}
  800e83:	89 d8                	mov    %ebx,%eax
  800e85:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e88:	5b                   	pop    %ebx
  800e89:	5e                   	pop    %esi
  800e8a:	5d                   	pop    %ebp
  800e8b:	c3                   	ret    

00800e8c <pipeisclosed>:
{
  800e8c:	f3 0f 1e fb          	endbr32 
  800e90:	55                   	push   %ebp
  800e91:	89 e5                	mov    %esp,%ebp
  800e93:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e96:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e99:	50                   	push   %eax
  800e9a:	ff 75 08             	pushl  0x8(%ebp)
  800e9d:	e8 f6 f4 ff ff       	call   800398 <fd_lookup>
  800ea2:	83 c4 10             	add    $0x10,%esp
  800ea5:	85 c0                	test   %eax,%eax
  800ea7:	78 18                	js     800ec1 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800ea9:	83 ec 0c             	sub    $0xc,%esp
  800eac:	ff 75 f4             	pushl  -0xc(%ebp)
  800eaf:	e8 6f f4 ff ff       	call   800323 <fd2data>
  800eb4:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800eb6:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb9:	e8 1f fd ff ff       	call   800bdd <_pipeisclosed>
  800ebe:	83 c4 10             	add    $0x10,%esp
}
  800ec1:	c9                   	leave  
  800ec2:	c3                   	ret    

00800ec3 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ec3:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800ec7:	b8 00 00 00 00       	mov    $0x0,%eax
  800ecc:	c3                   	ret    

00800ecd <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ecd:	f3 0f 1e fb          	endbr32 
  800ed1:	55                   	push   %ebp
  800ed2:	89 e5                	mov    %esp,%ebp
  800ed4:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ed7:	68 02 1f 80 00       	push   $0x801f02
  800edc:	ff 75 0c             	pushl  0xc(%ebp)
  800edf:	e8 c5 07 00 00       	call   8016a9 <strcpy>
	return 0;
}
  800ee4:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee9:	c9                   	leave  
  800eea:	c3                   	ret    

00800eeb <devcons_write>:
{
  800eeb:	f3 0f 1e fb          	endbr32 
  800eef:	55                   	push   %ebp
  800ef0:	89 e5                	mov    %esp,%ebp
  800ef2:	57                   	push   %edi
  800ef3:	56                   	push   %esi
  800ef4:	53                   	push   %ebx
  800ef5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800efb:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f00:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f06:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f09:	73 31                	jae    800f3c <devcons_write+0x51>
		m = n - tot;
  800f0b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f0e:	29 f3                	sub    %esi,%ebx
  800f10:	83 fb 7f             	cmp    $0x7f,%ebx
  800f13:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f18:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f1b:	83 ec 04             	sub    $0x4,%esp
  800f1e:	53                   	push   %ebx
  800f1f:	89 f0                	mov    %esi,%eax
  800f21:	03 45 0c             	add    0xc(%ebp),%eax
  800f24:	50                   	push   %eax
  800f25:	57                   	push   %edi
  800f26:	e8 36 09 00 00       	call   801861 <memmove>
		sys_cputs(buf, m);
  800f2b:	83 c4 08             	add    $0x8,%esp
  800f2e:	53                   	push   %ebx
  800f2f:	57                   	push   %edi
  800f30:	e8 d2 f1 ff ff       	call   800107 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f35:	01 de                	add    %ebx,%esi
  800f37:	83 c4 10             	add    $0x10,%esp
  800f3a:	eb ca                	jmp    800f06 <devcons_write+0x1b>
}
  800f3c:	89 f0                	mov    %esi,%eax
  800f3e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f41:	5b                   	pop    %ebx
  800f42:	5e                   	pop    %esi
  800f43:	5f                   	pop    %edi
  800f44:	5d                   	pop    %ebp
  800f45:	c3                   	ret    

00800f46 <devcons_read>:
{
  800f46:	f3 0f 1e fb          	endbr32 
  800f4a:	55                   	push   %ebp
  800f4b:	89 e5                	mov    %esp,%ebp
  800f4d:	83 ec 08             	sub    $0x8,%esp
  800f50:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f55:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f59:	74 21                	je     800f7c <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800f5b:	e8 d1 f1 ff ff       	call   800131 <sys_cgetc>
  800f60:	85 c0                	test   %eax,%eax
  800f62:	75 07                	jne    800f6b <devcons_read+0x25>
		sys_yield();
  800f64:	e8 3e f2 ff ff       	call   8001a7 <sys_yield>
  800f69:	eb f0                	jmp    800f5b <devcons_read+0x15>
	if (c < 0)
  800f6b:	78 0f                	js     800f7c <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800f6d:	83 f8 04             	cmp    $0x4,%eax
  800f70:	74 0c                	je     800f7e <devcons_read+0x38>
	*(char*)vbuf = c;
  800f72:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f75:	88 02                	mov    %al,(%edx)
	return 1;
  800f77:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800f7c:	c9                   	leave  
  800f7d:	c3                   	ret    
		return 0;
  800f7e:	b8 00 00 00 00       	mov    $0x0,%eax
  800f83:	eb f7                	jmp    800f7c <devcons_read+0x36>

00800f85 <cputchar>:
{
  800f85:	f3 0f 1e fb          	endbr32 
  800f89:	55                   	push   %ebp
  800f8a:	89 e5                	mov    %esp,%ebp
  800f8c:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f8f:	8b 45 08             	mov    0x8(%ebp),%eax
  800f92:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f95:	6a 01                	push   $0x1
  800f97:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f9a:	50                   	push   %eax
  800f9b:	e8 67 f1 ff ff       	call   800107 <sys_cputs>
}
  800fa0:	83 c4 10             	add    $0x10,%esp
  800fa3:	c9                   	leave  
  800fa4:	c3                   	ret    

00800fa5 <getchar>:
{
  800fa5:	f3 0f 1e fb          	endbr32 
  800fa9:	55                   	push   %ebp
  800faa:	89 e5                	mov    %esp,%ebp
  800fac:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800faf:	6a 01                	push   $0x1
  800fb1:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fb4:	50                   	push   %eax
  800fb5:	6a 00                	push   $0x0
  800fb7:	e8 5f f6 ff ff       	call   80061b <read>
	if (r < 0)
  800fbc:	83 c4 10             	add    $0x10,%esp
  800fbf:	85 c0                	test   %eax,%eax
  800fc1:	78 06                	js     800fc9 <getchar+0x24>
	if (r < 1)
  800fc3:	74 06                	je     800fcb <getchar+0x26>
	return c;
  800fc5:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800fc9:	c9                   	leave  
  800fca:	c3                   	ret    
		return -E_EOF;
  800fcb:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800fd0:	eb f7                	jmp    800fc9 <getchar+0x24>

00800fd2 <iscons>:
{
  800fd2:	f3 0f 1e fb          	endbr32 
  800fd6:	55                   	push   %ebp
  800fd7:	89 e5                	mov    %esp,%ebp
  800fd9:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fdc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdf:	50                   	push   %eax
  800fe0:	ff 75 08             	pushl  0x8(%ebp)
  800fe3:	e8 b0 f3 ff ff       	call   800398 <fd_lookup>
  800fe8:	83 c4 10             	add    $0x10,%esp
  800feb:	85 c0                	test   %eax,%eax
  800fed:	78 11                	js     801000 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  800fef:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ff2:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800ff8:	39 10                	cmp    %edx,(%eax)
  800ffa:	0f 94 c0             	sete   %al
  800ffd:	0f b6 c0             	movzbl %al,%eax
}
  801000:	c9                   	leave  
  801001:	c3                   	ret    

00801002 <opencons>:
{
  801002:	f3 0f 1e fb          	endbr32 
  801006:	55                   	push   %ebp
  801007:	89 e5                	mov    %esp,%ebp
  801009:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  80100c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80100f:	50                   	push   %eax
  801010:	e8 2d f3 ff ff       	call   800342 <fd_alloc>
  801015:	83 c4 10             	add    $0x10,%esp
  801018:	85 c0                	test   %eax,%eax
  80101a:	78 3a                	js     801056 <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80101c:	83 ec 04             	sub    $0x4,%esp
  80101f:	68 07 04 00 00       	push   $0x407
  801024:	ff 75 f4             	pushl  -0xc(%ebp)
  801027:	6a 00                	push   $0x0
  801029:	e8 a4 f1 ff ff       	call   8001d2 <sys_page_alloc>
  80102e:	83 c4 10             	add    $0x10,%esp
  801031:	85 c0                	test   %eax,%eax
  801033:	78 21                	js     801056 <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  801035:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801038:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80103e:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801040:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801043:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80104a:	83 ec 0c             	sub    $0xc,%esp
  80104d:	50                   	push   %eax
  80104e:	e8 bc f2 ff ff       	call   80030f <fd2num>
  801053:	83 c4 10             	add    $0x10,%esp
}
  801056:	c9                   	leave  
  801057:	c3                   	ret    

00801058 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801058:	f3 0f 1e fb          	endbr32 
  80105c:	55                   	push   %ebp
  80105d:	89 e5                	mov    %esp,%ebp
  80105f:	56                   	push   %esi
  801060:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801061:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801064:	8b 35 04 30 80 00    	mov    0x803004,%esi
  80106a:	e8 10 f1 ff ff       	call   80017f <sys_getenvid>
  80106f:	83 ec 0c             	sub    $0xc,%esp
  801072:	ff 75 0c             	pushl  0xc(%ebp)
  801075:	ff 75 08             	pushl  0x8(%ebp)
  801078:	56                   	push   %esi
  801079:	50                   	push   %eax
  80107a:	68 10 1f 80 00       	push   $0x801f10
  80107f:	e8 bb 00 00 00       	call   80113f <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801084:	83 c4 18             	add    $0x18,%esp
  801087:	53                   	push   %ebx
  801088:	ff 75 10             	pushl  0x10(%ebp)
  80108b:	e8 5a 00 00 00       	call   8010ea <vcprintf>
	cprintf("\n");
  801090:	c7 04 24 fb 1e 80 00 	movl   $0x801efb,(%esp)
  801097:	e8 a3 00 00 00       	call   80113f <cprintf>
  80109c:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80109f:	cc                   	int3   
  8010a0:	eb fd                	jmp    80109f <_panic+0x47>

008010a2 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010a2:	f3 0f 1e fb          	endbr32 
  8010a6:	55                   	push   %ebp
  8010a7:	89 e5                	mov    %esp,%ebp
  8010a9:	53                   	push   %ebx
  8010aa:	83 ec 04             	sub    $0x4,%esp
  8010ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010b0:	8b 13                	mov    (%ebx),%edx
  8010b2:	8d 42 01             	lea    0x1(%edx),%eax
  8010b5:	89 03                	mov    %eax,(%ebx)
  8010b7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010ba:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010be:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010c3:	74 09                	je     8010ce <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8010c5:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010cc:	c9                   	leave  
  8010cd:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8010ce:	83 ec 08             	sub    $0x8,%esp
  8010d1:	68 ff 00 00 00       	push   $0xff
  8010d6:	8d 43 08             	lea    0x8(%ebx),%eax
  8010d9:	50                   	push   %eax
  8010da:	e8 28 f0 ff ff       	call   800107 <sys_cputs>
		b->idx = 0;
  8010df:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010e5:	83 c4 10             	add    $0x10,%esp
  8010e8:	eb db                	jmp    8010c5 <putch+0x23>

008010ea <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010ea:	f3 0f 1e fb          	endbr32 
  8010ee:	55                   	push   %ebp
  8010ef:	89 e5                	mov    %esp,%ebp
  8010f1:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010f7:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010fe:	00 00 00 
	b.cnt = 0;
  801101:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801108:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  80110b:	ff 75 0c             	pushl  0xc(%ebp)
  80110e:	ff 75 08             	pushl  0x8(%ebp)
  801111:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801117:	50                   	push   %eax
  801118:	68 a2 10 80 00       	push   $0x8010a2
  80111d:	e8 80 01 00 00       	call   8012a2 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801122:	83 c4 08             	add    $0x8,%esp
  801125:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80112b:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801131:	50                   	push   %eax
  801132:	e8 d0 ef ff ff       	call   800107 <sys_cputs>

	return b.cnt;
}
  801137:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80113d:	c9                   	leave  
  80113e:	c3                   	ret    

0080113f <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80113f:	f3 0f 1e fb          	endbr32 
  801143:	55                   	push   %ebp
  801144:	89 e5                	mov    %esp,%ebp
  801146:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801149:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  80114c:	50                   	push   %eax
  80114d:	ff 75 08             	pushl  0x8(%ebp)
  801150:	e8 95 ff ff ff       	call   8010ea <vcprintf>
	va_end(ap);

	return cnt;
}
  801155:	c9                   	leave  
  801156:	c3                   	ret    

00801157 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801157:	55                   	push   %ebp
  801158:	89 e5                	mov    %esp,%ebp
  80115a:	57                   	push   %edi
  80115b:	56                   	push   %esi
  80115c:	53                   	push   %ebx
  80115d:	83 ec 1c             	sub    $0x1c,%esp
  801160:	89 c7                	mov    %eax,%edi
  801162:	89 d6                	mov    %edx,%esi
  801164:	8b 45 08             	mov    0x8(%ebp),%eax
  801167:	8b 55 0c             	mov    0xc(%ebp),%edx
  80116a:	89 d1                	mov    %edx,%ecx
  80116c:	89 c2                	mov    %eax,%edx
  80116e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801171:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  801174:	8b 45 10             	mov    0x10(%ebp),%eax
  801177:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80117a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80117d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  801184:	39 c2                	cmp    %eax,%edx
  801186:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801189:	72 3e                	jb     8011c9 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80118b:	83 ec 0c             	sub    $0xc,%esp
  80118e:	ff 75 18             	pushl  0x18(%ebp)
  801191:	83 eb 01             	sub    $0x1,%ebx
  801194:	53                   	push   %ebx
  801195:	50                   	push   %eax
  801196:	83 ec 08             	sub    $0x8,%esp
  801199:	ff 75 e4             	pushl  -0x1c(%ebp)
  80119c:	ff 75 e0             	pushl  -0x20(%ebp)
  80119f:	ff 75 dc             	pushl  -0x24(%ebp)
  8011a2:	ff 75 d8             	pushl  -0x28(%ebp)
  8011a5:	e8 c6 09 00 00       	call   801b70 <__udivdi3>
  8011aa:	83 c4 18             	add    $0x18,%esp
  8011ad:	52                   	push   %edx
  8011ae:	50                   	push   %eax
  8011af:	89 f2                	mov    %esi,%edx
  8011b1:	89 f8                	mov    %edi,%eax
  8011b3:	e8 9f ff ff ff       	call   801157 <printnum>
  8011b8:	83 c4 20             	add    $0x20,%esp
  8011bb:	eb 13                	jmp    8011d0 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011bd:	83 ec 08             	sub    $0x8,%esp
  8011c0:	56                   	push   %esi
  8011c1:	ff 75 18             	pushl  0x18(%ebp)
  8011c4:	ff d7                	call   *%edi
  8011c6:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8011c9:	83 eb 01             	sub    $0x1,%ebx
  8011cc:	85 db                	test   %ebx,%ebx
  8011ce:	7f ed                	jg     8011bd <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011d0:	83 ec 08             	sub    $0x8,%esp
  8011d3:	56                   	push   %esi
  8011d4:	83 ec 04             	sub    $0x4,%esp
  8011d7:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011da:	ff 75 e0             	pushl  -0x20(%ebp)
  8011dd:	ff 75 dc             	pushl  -0x24(%ebp)
  8011e0:	ff 75 d8             	pushl  -0x28(%ebp)
  8011e3:	e8 98 0a 00 00       	call   801c80 <__umoddi3>
  8011e8:	83 c4 14             	add    $0x14,%esp
  8011eb:	0f be 80 33 1f 80 00 	movsbl 0x801f33(%eax),%eax
  8011f2:	50                   	push   %eax
  8011f3:	ff d7                	call   *%edi
}
  8011f5:	83 c4 10             	add    $0x10,%esp
  8011f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011fb:	5b                   	pop    %ebx
  8011fc:	5e                   	pop    %esi
  8011fd:	5f                   	pop    %edi
  8011fe:	5d                   	pop    %ebp
  8011ff:	c3                   	ret    

00801200 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801200:	83 fa 01             	cmp    $0x1,%edx
  801203:	7f 13                	jg     801218 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  801205:	85 d2                	test   %edx,%edx
  801207:	74 1c                	je     801225 <getuint+0x25>
		return va_arg(*ap, unsigned long);
  801209:	8b 10                	mov    (%eax),%edx
  80120b:	8d 4a 04             	lea    0x4(%edx),%ecx
  80120e:	89 08                	mov    %ecx,(%eax)
  801210:	8b 02                	mov    (%edx),%eax
  801212:	ba 00 00 00 00       	mov    $0x0,%edx
  801217:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  801218:	8b 10                	mov    (%eax),%edx
  80121a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80121d:	89 08                	mov    %ecx,(%eax)
  80121f:	8b 02                	mov    (%edx),%eax
  801221:	8b 52 04             	mov    0x4(%edx),%edx
  801224:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  801225:	8b 10                	mov    (%eax),%edx
  801227:	8d 4a 04             	lea    0x4(%edx),%ecx
  80122a:	89 08                	mov    %ecx,(%eax)
  80122c:	8b 02                	mov    (%edx),%eax
  80122e:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801233:	c3                   	ret    

00801234 <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801234:	83 fa 01             	cmp    $0x1,%edx
  801237:	7f 0f                	jg     801248 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  801239:	85 d2                	test   %edx,%edx
  80123b:	74 18                	je     801255 <getint+0x21>
		return va_arg(*ap, long);
  80123d:	8b 10                	mov    (%eax),%edx
  80123f:	8d 4a 04             	lea    0x4(%edx),%ecx
  801242:	89 08                	mov    %ecx,(%eax)
  801244:	8b 02                	mov    (%edx),%eax
  801246:	99                   	cltd   
  801247:	c3                   	ret    
		return va_arg(*ap, long long);
  801248:	8b 10                	mov    (%eax),%edx
  80124a:	8d 4a 08             	lea    0x8(%edx),%ecx
  80124d:	89 08                	mov    %ecx,(%eax)
  80124f:	8b 02                	mov    (%edx),%eax
  801251:	8b 52 04             	mov    0x4(%edx),%edx
  801254:	c3                   	ret    
	else
		return va_arg(*ap, int);
  801255:	8b 10                	mov    (%eax),%edx
  801257:	8d 4a 04             	lea    0x4(%edx),%ecx
  80125a:	89 08                	mov    %ecx,(%eax)
  80125c:	8b 02                	mov    (%edx),%eax
  80125e:	99                   	cltd   
}
  80125f:	c3                   	ret    

00801260 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801260:	f3 0f 1e fb          	endbr32 
  801264:	55                   	push   %ebp
  801265:	89 e5                	mov    %esp,%ebp
  801267:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80126a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80126e:	8b 10                	mov    (%eax),%edx
  801270:	3b 50 04             	cmp    0x4(%eax),%edx
  801273:	73 0a                	jae    80127f <sprintputch+0x1f>
		*b->buf++ = ch;
  801275:	8d 4a 01             	lea    0x1(%edx),%ecx
  801278:	89 08                	mov    %ecx,(%eax)
  80127a:	8b 45 08             	mov    0x8(%ebp),%eax
  80127d:	88 02                	mov    %al,(%edx)
}
  80127f:	5d                   	pop    %ebp
  801280:	c3                   	ret    

00801281 <printfmt>:
{
  801281:	f3 0f 1e fb          	endbr32 
  801285:	55                   	push   %ebp
  801286:	89 e5                	mov    %esp,%ebp
  801288:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  80128b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80128e:	50                   	push   %eax
  80128f:	ff 75 10             	pushl  0x10(%ebp)
  801292:	ff 75 0c             	pushl  0xc(%ebp)
  801295:	ff 75 08             	pushl  0x8(%ebp)
  801298:	e8 05 00 00 00       	call   8012a2 <vprintfmt>
}
  80129d:	83 c4 10             	add    $0x10,%esp
  8012a0:	c9                   	leave  
  8012a1:	c3                   	ret    

008012a2 <vprintfmt>:
{
  8012a2:	f3 0f 1e fb          	endbr32 
  8012a6:	55                   	push   %ebp
  8012a7:	89 e5                	mov    %esp,%ebp
  8012a9:	57                   	push   %edi
  8012aa:	56                   	push   %esi
  8012ab:	53                   	push   %ebx
  8012ac:	83 ec 2c             	sub    $0x2c,%esp
  8012af:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012b2:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012b5:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012b8:	e9 86 02 00 00       	jmp    801543 <vprintfmt+0x2a1>
		padc = ' ';
  8012bd:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012c1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012c8:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012cf:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012d6:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012db:	8d 47 01             	lea    0x1(%edi),%eax
  8012de:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012e1:	0f b6 17             	movzbl (%edi),%edx
  8012e4:	8d 42 dd             	lea    -0x23(%edx),%eax
  8012e7:	3c 55                	cmp    $0x55,%al
  8012e9:	0f 87 df 02 00 00    	ja     8015ce <vprintfmt+0x32c>
  8012ef:	0f b6 c0             	movzbl %al,%eax
  8012f2:	3e ff 24 85 80 20 80 	notrack jmp *0x802080(,%eax,4)
  8012f9:	00 
  8012fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8012fd:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801301:	eb d8                	jmp    8012db <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801303:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801306:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  80130a:	eb cf                	jmp    8012db <vprintfmt+0x39>
  80130c:	0f b6 d2             	movzbl %dl,%edx
  80130f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801312:	b8 00 00 00 00       	mov    $0x0,%eax
  801317:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  80131a:	8d 04 80             	lea    (%eax,%eax,4),%eax
  80131d:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801321:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  801324:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801327:	83 f9 09             	cmp    $0x9,%ecx
  80132a:	77 52                	ja     80137e <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  80132c:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  80132f:	eb e9                	jmp    80131a <vprintfmt+0x78>
			precision = va_arg(ap, int);
  801331:	8b 45 14             	mov    0x14(%ebp),%eax
  801334:	8d 50 04             	lea    0x4(%eax),%edx
  801337:	89 55 14             	mov    %edx,0x14(%ebp)
  80133a:	8b 00                	mov    (%eax),%eax
  80133c:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80133f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801342:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801346:	79 93                	jns    8012db <vprintfmt+0x39>
				width = precision, precision = -1;
  801348:	8b 45 d8             	mov    -0x28(%ebp),%eax
  80134b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80134e:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  801355:	eb 84                	jmp    8012db <vprintfmt+0x39>
  801357:	8b 45 e0             	mov    -0x20(%ebp),%eax
  80135a:	85 c0                	test   %eax,%eax
  80135c:	ba 00 00 00 00       	mov    $0x0,%edx
  801361:	0f 49 d0             	cmovns %eax,%edx
  801364:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801367:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80136a:	e9 6c ff ff ff       	jmp    8012db <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80136f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801372:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801379:	e9 5d ff ff ff       	jmp    8012db <vprintfmt+0x39>
  80137e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801381:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  801384:	eb bc                	jmp    801342 <vprintfmt+0xa0>
			lflag++;
  801386:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801389:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  80138c:	e9 4a ff ff ff       	jmp    8012db <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  801391:	8b 45 14             	mov    0x14(%ebp),%eax
  801394:	8d 50 04             	lea    0x4(%eax),%edx
  801397:	89 55 14             	mov    %edx,0x14(%ebp)
  80139a:	83 ec 08             	sub    $0x8,%esp
  80139d:	56                   	push   %esi
  80139e:	ff 30                	pushl  (%eax)
  8013a0:	ff d3                	call   *%ebx
			break;
  8013a2:	83 c4 10             	add    $0x10,%esp
  8013a5:	e9 96 01 00 00       	jmp    801540 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8013aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ad:	8d 50 04             	lea    0x4(%eax),%edx
  8013b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8013b3:	8b 00                	mov    (%eax),%eax
  8013b5:	99                   	cltd   
  8013b6:	31 d0                	xor    %edx,%eax
  8013b8:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013ba:	83 f8 0f             	cmp    $0xf,%eax
  8013bd:	7f 20                	jg     8013df <vprintfmt+0x13d>
  8013bf:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  8013c6:	85 d2                	test   %edx,%edx
  8013c8:	74 15                	je     8013df <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8013ca:	52                   	push   %edx
  8013cb:	68 c9 1e 80 00       	push   $0x801ec9
  8013d0:	56                   	push   %esi
  8013d1:	53                   	push   %ebx
  8013d2:	e8 aa fe ff ff       	call   801281 <printfmt>
  8013d7:	83 c4 10             	add    $0x10,%esp
  8013da:	e9 61 01 00 00       	jmp    801540 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8013df:	50                   	push   %eax
  8013e0:	68 4b 1f 80 00       	push   $0x801f4b
  8013e5:	56                   	push   %esi
  8013e6:	53                   	push   %ebx
  8013e7:	e8 95 fe ff ff       	call   801281 <printfmt>
  8013ec:	83 c4 10             	add    $0x10,%esp
  8013ef:	e9 4c 01 00 00       	jmp    801540 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8013f4:	8b 45 14             	mov    0x14(%ebp),%eax
  8013f7:	8d 50 04             	lea    0x4(%eax),%edx
  8013fa:	89 55 14             	mov    %edx,0x14(%ebp)
  8013fd:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8013ff:	85 c9                	test   %ecx,%ecx
  801401:	b8 44 1f 80 00       	mov    $0x801f44,%eax
  801406:	0f 45 c1             	cmovne %ecx,%eax
  801409:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  80140c:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801410:	7e 06                	jle    801418 <vprintfmt+0x176>
  801412:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  801416:	75 0d                	jne    801425 <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  801418:	8b 45 cc             	mov    -0x34(%ebp),%eax
  80141b:	89 c7                	mov    %eax,%edi
  80141d:	03 45 e0             	add    -0x20(%ebp),%eax
  801420:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801423:	eb 57                	jmp    80147c <vprintfmt+0x1da>
  801425:	83 ec 08             	sub    $0x8,%esp
  801428:	ff 75 d8             	pushl  -0x28(%ebp)
  80142b:	ff 75 cc             	pushl  -0x34(%ebp)
  80142e:	e8 4f 02 00 00       	call   801682 <strnlen>
  801433:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801436:	29 c2                	sub    %eax,%edx
  801438:	89 55 e0             	mov    %edx,-0x20(%ebp)
  80143b:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  80143e:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801442:	89 5d 08             	mov    %ebx,0x8(%ebp)
  801445:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  801447:	85 db                	test   %ebx,%ebx
  801449:	7e 10                	jle    80145b <vprintfmt+0x1b9>
					putch(padc, putdat);
  80144b:	83 ec 08             	sub    $0x8,%esp
  80144e:	56                   	push   %esi
  80144f:	57                   	push   %edi
  801450:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  801453:	83 eb 01             	sub    $0x1,%ebx
  801456:	83 c4 10             	add    $0x10,%esp
  801459:	eb ec                	jmp    801447 <vprintfmt+0x1a5>
  80145b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80145e:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801461:	85 d2                	test   %edx,%edx
  801463:	b8 00 00 00 00       	mov    $0x0,%eax
  801468:	0f 49 c2             	cmovns %edx,%eax
  80146b:	29 c2                	sub    %eax,%edx
  80146d:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801470:	eb a6                	jmp    801418 <vprintfmt+0x176>
					putch(ch, putdat);
  801472:	83 ec 08             	sub    $0x8,%esp
  801475:	56                   	push   %esi
  801476:	52                   	push   %edx
  801477:	ff d3                	call   *%ebx
  801479:	83 c4 10             	add    $0x10,%esp
  80147c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80147f:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801481:	83 c7 01             	add    $0x1,%edi
  801484:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801488:	0f be d0             	movsbl %al,%edx
  80148b:	85 d2                	test   %edx,%edx
  80148d:	74 42                	je     8014d1 <vprintfmt+0x22f>
  80148f:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801493:	78 06                	js     80149b <vprintfmt+0x1f9>
  801495:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  801499:	78 1e                	js     8014b9 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  80149b:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  80149f:	74 d1                	je     801472 <vprintfmt+0x1d0>
  8014a1:	0f be c0             	movsbl %al,%eax
  8014a4:	83 e8 20             	sub    $0x20,%eax
  8014a7:	83 f8 5e             	cmp    $0x5e,%eax
  8014aa:	76 c6                	jbe    801472 <vprintfmt+0x1d0>
					putch('?', putdat);
  8014ac:	83 ec 08             	sub    $0x8,%esp
  8014af:	56                   	push   %esi
  8014b0:	6a 3f                	push   $0x3f
  8014b2:	ff d3                	call   *%ebx
  8014b4:	83 c4 10             	add    $0x10,%esp
  8014b7:	eb c3                	jmp    80147c <vprintfmt+0x1da>
  8014b9:	89 cf                	mov    %ecx,%edi
  8014bb:	eb 0e                	jmp    8014cb <vprintfmt+0x229>
				putch(' ', putdat);
  8014bd:	83 ec 08             	sub    $0x8,%esp
  8014c0:	56                   	push   %esi
  8014c1:	6a 20                	push   $0x20
  8014c3:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8014c5:	83 ef 01             	sub    $0x1,%edi
  8014c8:	83 c4 10             	add    $0x10,%esp
  8014cb:	85 ff                	test   %edi,%edi
  8014cd:	7f ee                	jg     8014bd <vprintfmt+0x21b>
  8014cf:	eb 6f                	jmp    801540 <vprintfmt+0x29e>
  8014d1:	89 cf                	mov    %ecx,%edi
  8014d3:	eb f6                	jmp    8014cb <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8014d5:	89 ca                	mov    %ecx,%edx
  8014d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8014da:	e8 55 fd ff ff       	call   801234 <getint>
  8014df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014e2:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8014e5:	85 d2                	test   %edx,%edx
  8014e7:	78 0b                	js     8014f4 <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8014e9:	89 d1                	mov    %edx,%ecx
  8014eb:	89 c2                	mov    %eax,%edx
			base = 10;
  8014ed:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014f2:	eb 32                	jmp    801526 <vprintfmt+0x284>
				putch('-', putdat);
  8014f4:	83 ec 08             	sub    $0x8,%esp
  8014f7:	56                   	push   %esi
  8014f8:	6a 2d                	push   $0x2d
  8014fa:	ff d3                	call   *%ebx
				num = -(long long) num;
  8014fc:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014ff:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801502:	f7 da                	neg    %edx
  801504:	83 d1 00             	adc    $0x0,%ecx
  801507:	f7 d9                	neg    %ecx
  801509:	83 c4 10             	add    $0x10,%esp
			base = 10;
  80150c:	b8 0a 00 00 00       	mov    $0xa,%eax
  801511:	eb 13                	jmp    801526 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  801513:	89 ca                	mov    %ecx,%edx
  801515:	8d 45 14             	lea    0x14(%ebp),%eax
  801518:	e8 e3 fc ff ff       	call   801200 <getuint>
  80151d:	89 d1                	mov    %edx,%ecx
  80151f:	89 c2                	mov    %eax,%edx
			base = 10;
  801521:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  801526:	83 ec 0c             	sub    $0xc,%esp
  801529:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80152d:	57                   	push   %edi
  80152e:	ff 75 e0             	pushl  -0x20(%ebp)
  801531:	50                   	push   %eax
  801532:	51                   	push   %ecx
  801533:	52                   	push   %edx
  801534:	89 f2                	mov    %esi,%edx
  801536:	89 d8                	mov    %ebx,%eax
  801538:	e8 1a fc ff ff       	call   801157 <printnum>
			break;
  80153d:	83 c4 20             	add    $0x20,%esp
{
  801540:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801543:	83 c7 01             	add    $0x1,%edi
  801546:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80154a:	83 f8 25             	cmp    $0x25,%eax
  80154d:	0f 84 6a fd ff ff    	je     8012bd <vprintfmt+0x1b>
			if (ch == '\0')
  801553:	85 c0                	test   %eax,%eax
  801555:	0f 84 93 00 00 00    	je     8015ee <vprintfmt+0x34c>
			putch(ch, putdat);
  80155b:	83 ec 08             	sub    $0x8,%esp
  80155e:	56                   	push   %esi
  80155f:	50                   	push   %eax
  801560:	ff d3                	call   *%ebx
  801562:	83 c4 10             	add    $0x10,%esp
  801565:	eb dc                	jmp    801543 <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  801567:	89 ca                	mov    %ecx,%edx
  801569:	8d 45 14             	lea    0x14(%ebp),%eax
  80156c:	e8 8f fc ff ff       	call   801200 <getuint>
  801571:	89 d1                	mov    %edx,%ecx
  801573:	89 c2                	mov    %eax,%edx
			base = 8;
  801575:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  80157a:	eb aa                	jmp    801526 <vprintfmt+0x284>
			putch('0', putdat);
  80157c:	83 ec 08             	sub    $0x8,%esp
  80157f:	56                   	push   %esi
  801580:	6a 30                	push   $0x30
  801582:	ff d3                	call   *%ebx
			putch('x', putdat);
  801584:	83 c4 08             	add    $0x8,%esp
  801587:	56                   	push   %esi
  801588:	6a 78                	push   $0x78
  80158a:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  80158c:	8b 45 14             	mov    0x14(%ebp),%eax
  80158f:	8d 50 04             	lea    0x4(%eax),%edx
  801592:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  801595:	8b 10                	mov    (%eax),%edx
  801597:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  80159c:	83 c4 10             	add    $0x10,%esp
			base = 16;
  80159f:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015a4:	eb 80                	jmp    801526 <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8015a6:	89 ca                	mov    %ecx,%edx
  8015a8:	8d 45 14             	lea    0x14(%ebp),%eax
  8015ab:	e8 50 fc ff ff       	call   801200 <getuint>
  8015b0:	89 d1                	mov    %edx,%ecx
  8015b2:	89 c2                	mov    %eax,%edx
			base = 16;
  8015b4:	b8 10 00 00 00       	mov    $0x10,%eax
  8015b9:	e9 68 ff ff ff       	jmp    801526 <vprintfmt+0x284>
			putch(ch, putdat);
  8015be:	83 ec 08             	sub    $0x8,%esp
  8015c1:	56                   	push   %esi
  8015c2:	6a 25                	push   $0x25
  8015c4:	ff d3                	call   *%ebx
			break;
  8015c6:	83 c4 10             	add    $0x10,%esp
  8015c9:	e9 72 ff ff ff       	jmp    801540 <vprintfmt+0x29e>
			putch('%', putdat);
  8015ce:	83 ec 08             	sub    $0x8,%esp
  8015d1:	56                   	push   %esi
  8015d2:	6a 25                	push   $0x25
  8015d4:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015d6:	83 c4 10             	add    $0x10,%esp
  8015d9:	89 f8                	mov    %edi,%eax
  8015db:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8015df:	74 05                	je     8015e6 <vprintfmt+0x344>
  8015e1:	83 e8 01             	sub    $0x1,%eax
  8015e4:	eb f5                	jmp    8015db <vprintfmt+0x339>
  8015e6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015e9:	e9 52 ff ff ff       	jmp    801540 <vprintfmt+0x29e>
}
  8015ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015f1:	5b                   	pop    %ebx
  8015f2:	5e                   	pop    %esi
  8015f3:	5f                   	pop    %edi
  8015f4:	5d                   	pop    %ebp
  8015f5:	c3                   	ret    

008015f6 <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015f6:	f3 0f 1e fb          	endbr32 
  8015fa:	55                   	push   %ebp
  8015fb:	89 e5                	mov    %esp,%ebp
  8015fd:	83 ec 18             	sub    $0x18,%esp
  801600:	8b 45 08             	mov    0x8(%ebp),%eax
  801603:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801606:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801609:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80160d:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801610:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801617:	85 c0                	test   %eax,%eax
  801619:	74 26                	je     801641 <vsnprintf+0x4b>
  80161b:	85 d2                	test   %edx,%edx
  80161d:	7e 22                	jle    801641 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80161f:	ff 75 14             	pushl  0x14(%ebp)
  801622:	ff 75 10             	pushl  0x10(%ebp)
  801625:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801628:	50                   	push   %eax
  801629:	68 60 12 80 00       	push   $0x801260
  80162e:	e8 6f fc ff ff       	call   8012a2 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801633:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801636:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801639:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80163c:	83 c4 10             	add    $0x10,%esp
}
  80163f:	c9                   	leave  
  801640:	c3                   	ret    
		return -E_INVAL;
  801641:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  801646:	eb f7                	jmp    80163f <vsnprintf+0x49>

00801648 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801648:	f3 0f 1e fb          	endbr32 
  80164c:	55                   	push   %ebp
  80164d:	89 e5                	mov    %esp,%ebp
  80164f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801652:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801655:	50                   	push   %eax
  801656:	ff 75 10             	pushl  0x10(%ebp)
  801659:	ff 75 0c             	pushl  0xc(%ebp)
  80165c:	ff 75 08             	pushl  0x8(%ebp)
  80165f:	e8 92 ff ff ff       	call   8015f6 <vsnprintf>
	va_end(ap);

	return rc;
}
  801664:	c9                   	leave  
  801665:	c3                   	ret    

00801666 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  801666:	f3 0f 1e fb          	endbr32 
  80166a:	55                   	push   %ebp
  80166b:	89 e5                	mov    %esp,%ebp
  80166d:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801670:	b8 00 00 00 00       	mov    $0x0,%eax
  801675:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801679:	74 05                	je     801680 <strlen+0x1a>
		n++;
  80167b:	83 c0 01             	add    $0x1,%eax
  80167e:	eb f5                	jmp    801675 <strlen+0xf>
	return n;
}
  801680:	5d                   	pop    %ebp
  801681:	c3                   	ret    

00801682 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801682:	f3 0f 1e fb          	endbr32 
  801686:	55                   	push   %ebp
  801687:	89 e5                	mov    %esp,%ebp
  801689:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80168c:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80168f:	b8 00 00 00 00       	mov    $0x0,%eax
  801694:	39 d0                	cmp    %edx,%eax
  801696:	74 0d                	je     8016a5 <strnlen+0x23>
  801698:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  80169c:	74 05                	je     8016a3 <strnlen+0x21>
		n++;
  80169e:	83 c0 01             	add    $0x1,%eax
  8016a1:	eb f1                	jmp    801694 <strnlen+0x12>
  8016a3:	89 c2                	mov    %eax,%edx
	return n;
}
  8016a5:	89 d0                	mov    %edx,%eax
  8016a7:	5d                   	pop    %ebp
  8016a8:	c3                   	ret    

008016a9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016a9:	f3 0f 1e fb          	endbr32 
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	53                   	push   %ebx
  8016b1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016b4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016b7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016bc:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8016c0:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8016c3:	83 c0 01             	add    $0x1,%eax
  8016c6:	84 d2                	test   %dl,%dl
  8016c8:	75 f2                	jne    8016bc <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8016ca:	89 c8                	mov    %ecx,%eax
  8016cc:	5b                   	pop    %ebx
  8016cd:	5d                   	pop    %ebp
  8016ce:	c3                   	ret    

008016cf <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016cf:	f3 0f 1e fb          	endbr32 
  8016d3:	55                   	push   %ebp
  8016d4:	89 e5                	mov    %esp,%ebp
  8016d6:	53                   	push   %ebx
  8016d7:	83 ec 10             	sub    $0x10,%esp
  8016da:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016dd:	53                   	push   %ebx
  8016de:	e8 83 ff ff ff       	call   801666 <strlen>
  8016e3:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8016e6:	ff 75 0c             	pushl  0xc(%ebp)
  8016e9:	01 d8                	add    %ebx,%eax
  8016eb:	50                   	push   %eax
  8016ec:	e8 b8 ff ff ff       	call   8016a9 <strcpy>
	return dst;
}
  8016f1:	89 d8                	mov    %ebx,%eax
  8016f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016f6:	c9                   	leave  
  8016f7:	c3                   	ret    

008016f8 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016f8:	f3 0f 1e fb          	endbr32 
  8016fc:	55                   	push   %ebp
  8016fd:	89 e5                	mov    %esp,%ebp
  8016ff:	56                   	push   %esi
  801700:	53                   	push   %ebx
  801701:	8b 75 08             	mov    0x8(%ebp),%esi
  801704:	8b 55 0c             	mov    0xc(%ebp),%edx
  801707:	89 f3                	mov    %esi,%ebx
  801709:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80170c:	89 f0                	mov    %esi,%eax
  80170e:	39 d8                	cmp    %ebx,%eax
  801710:	74 11                	je     801723 <strncpy+0x2b>
		*dst++ = *src;
  801712:	83 c0 01             	add    $0x1,%eax
  801715:	0f b6 0a             	movzbl (%edx),%ecx
  801718:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80171b:	80 f9 01             	cmp    $0x1,%cl
  80171e:	83 da ff             	sbb    $0xffffffff,%edx
  801721:	eb eb                	jmp    80170e <strncpy+0x16>
	}
	return ret;
}
  801723:	89 f0                	mov    %esi,%eax
  801725:	5b                   	pop    %ebx
  801726:	5e                   	pop    %esi
  801727:	5d                   	pop    %ebp
  801728:	c3                   	ret    

00801729 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801729:	f3 0f 1e fb          	endbr32 
  80172d:	55                   	push   %ebp
  80172e:	89 e5                	mov    %esp,%ebp
  801730:	56                   	push   %esi
  801731:	53                   	push   %ebx
  801732:	8b 75 08             	mov    0x8(%ebp),%esi
  801735:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801738:	8b 55 10             	mov    0x10(%ebp),%edx
  80173b:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80173d:	85 d2                	test   %edx,%edx
  80173f:	74 21                	je     801762 <strlcpy+0x39>
  801741:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801745:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801747:	39 c2                	cmp    %eax,%edx
  801749:	74 14                	je     80175f <strlcpy+0x36>
  80174b:	0f b6 19             	movzbl (%ecx),%ebx
  80174e:	84 db                	test   %bl,%bl
  801750:	74 0b                	je     80175d <strlcpy+0x34>
			*dst++ = *src++;
  801752:	83 c1 01             	add    $0x1,%ecx
  801755:	83 c2 01             	add    $0x1,%edx
  801758:	88 5a ff             	mov    %bl,-0x1(%edx)
  80175b:	eb ea                	jmp    801747 <strlcpy+0x1e>
  80175d:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  80175f:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801762:	29 f0                	sub    %esi,%eax
}
  801764:	5b                   	pop    %ebx
  801765:	5e                   	pop    %esi
  801766:	5d                   	pop    %ebp
  801767:	c3                   	ret    

00801768 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801768:	f3 0f 1e fb          	endbr32 
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801772:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801775:	0f b6 01             	movzbl (%ecx),%eax
  801778:	84 c0                	test   %al,%al
  80177a:	74 0c                	je     801788 <strcmp+0x20>
  80177c:	3a 02                	cmp    (%edx),%al
  80177e:	75 08                	jne    801788 <strcmp+0x20>
		p++, q++;
  801780:	83 c1 01             	add    $0x1,%ecx
  801783:	83 c2 01             	add    $0x1,%edx
  801786:	eb ed                	jmp    801775 <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801788:	0f b6 c0             	movzbl %al,%eax
  80178b:	0f b6 12             	movzbl (%edx),%edx
  80178e:	29 d0                	sub    %edx,%eax
}
  801790:	5d                   	pop    %ebp
  801791:	c3                   	ret    

00801792 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  801792:	f3 0f 1e fb          	endbr32 
  801796:	55                   	push   %ebp
  801797:	89 e5                	mov    %esp,%ebp
  801799:	53                   	push   %ebx
  80179a:	8b 45 08             	mov    0x8(%ebp),%eax
  80179d:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017a0:	89 c3                	mov    %eax,%ebx
  8017a2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017a5:	eb 06                	jmp    8017ad <strncmp+0x1b>
		n--, p++, q++;
  8017a7:	83 c0 01             	add    $0x1,%eax
  8017aa:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017ad:	39 d8                	cmp    %ebx,%eax
  8017af:	74 16                	je     8017c7 <strncmp+0x35>
  8017b1:	0f b6 08             	movzbl (%eax),%ecx
  8017b4:	84 c9                	test   %cl,%cl
  8017b6:	74 04                	je     8017bc <strncmp+0x2a>
  8017b8:	3a 0a                	cmp    (%edx),%cl
  8017ba:	74 eb                	je     8017a7 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017bc:	0f b6 00             	movzbl (%eax),%eax
  8017bf:	0f b6 12             	movzbl (%edx),%edx
  8017c2:	29 d0                	sub    %edx,%eax
}
  8017c4:	5b                   	pop    %ebx
  8017c5:	5d                   	pop    %ebp
  8017c6:	c3                   	ret    
		return 0;
  8017c7:	b8 00 00 00 00       	mov    $0x0,%eax
  8017cc:	eb f6                	jmp    8017c4 <strncmp+0x32>

008017ce <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017ce:	f3 0f 1e fb          	endbr32 
  8017d2:	55                   	push   %ebp
  8017d3:	89 e5                	mov    %esp,%ebp
  8017d5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017dc:	0f b6 10             	movzbl (%eax),%edx
  8017df:	84 d2                	test   %dl,%dl
  8017e1:	74 09                	je     8017ec <strchr+0x1e>
		if (*s == c)
  8017e3:	38 ca                	cmp    %cl,%dl
  8017e5:	74 0a                	je     8017f1 <strchr+0x23>
	for (; *s; s++)
  8017e7:	83 c0 01             	add    $0x1,%eax
  8017ea:	eb f0                	jmp    8017dc <strchr+0xe>
			return (char *) s;
	return 0;
  8017ec:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017f1:	5d                   	pop    %ebp
  8017f2:	c3                   	ret    

008017f3 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017f3:	f3 0f 1e fb          	endbr32 
  8017f7:	55                   	push   %ebp
  8017f8:	89 e5                	mov    %esp,%ebp
  8017fa:	8b 45 08             	mov    0x8(%ebp),%eax
  8017fd:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801801:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801804:	38 ca                	cmp    %cl,%dl
  801806:	74 09                	je     801811 <strfind+0x1e>
  801808:	84 d2                	test   %dl,%dl
  80180a:	74 05                	je     801811 <strfind+0x1e>
	for (; *s; s++)
  80180c:	83 c0 01             	add    $0x1,%eax
  80180f:	eb f0                	jmp    801801 <strfind+0xe>
			break;
	return (char *) s;
}
  801811:	5d                   	pop    %ebp
  801812:	c3                   	ret    

00801813 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801813:	f3 0f 1e fb          	endbr32 
  801817:	55                   	push   %ebp
  801818:	89 e5                	mov    %esp,%ebp
  80181a:	57                   	push   %edi
  80181b:	56                   	push   %esi
  80181c:	53                   	push   %ebx
  80181d:	8b 55 08             	mov    0x8(%ebp),%edx
  801820:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  801823:	85 c9                	test   %ecx,%ecx
  801825:	74 33                	je     80185a <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801827:	89 d0                	mov    %edx,%eax
  801829:	09 c8                	or     %ecx,%eax
  80182b:	a8 03                	test   $0x3,%al
  80182d:	75 23                	jne    801852 <memset+0x3f>
		c &= 0xFF;
  80182f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801833:	89 d8                	mov    %ebx,%eax
  801835:	c1 e0 08             	shl    $0x8,%eax
  801838:	89 df                	mov    %ebx,%edi
  80183a:	c1 e7 18             	shl    $0x18,%edi
  80183d:	89 de                	mov    %ebx,%esi
  80183f:	c1 e6 10             	shl    $0x10,%esi
  801842:	09 f7                	or     %esi,%edi
  801844:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  801846:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801849:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  80184b:	89 d7                	mov    %edx,%edi
  80184d:	fc                   	cld    
  80184e:	f3 ab                	rep stos %eax,%es:(%edi)
  801850:	eb 08                	jmp    80185a <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801852:	89 d7                	mov    %edx,%edi
  801854:	8b 45 0c             	mov    0xc(%ebp),%eax
  801857:	fc                   	cld    
  801858:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  80185a:	89 d0                	mov    %edx,%eax
  80185c:	5b                   	pop    %ebx
  80185d:	5e                   	pop    %esi
  80185e:	5f                   	pop    %edi
  80185f:	5d                   	pop    %ebp
  801860:	c3                   	ret    

00801861 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801861:	f3 0f 1e fb          	endbr32 
  801865:	55                   	push   %ebp
  801866:	89 e5                	mov    %esp,%ebp
  801868:	57                   	push   %edi
  801869:	56                   	push   %esi
  80186a:	8b 45 08             	mov    0x8(%ebp),%eax
  80186d:	8b 75 0c             	mov    0xc(%ebp),%esi
  801870:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801873:	39 c6                	cmp    %eax,%esi
  801875:	73 32                	jae    8018a9 <memmove+0x48>
  801877:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80187a:	39 c2                	cmp    %eax,%edx
  80187c:	76 2b                	jbe    8018a9 <memmove+0x48>
		s += n;
		d += n;
  80187e:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801881:	89 fe                	mov    %edi,%esi
  801883:	09 ce                	or     %ecx,%esi
  801885:	09 d6                	or     %edx,%esi
  801887:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80188d:	75 0e                	jne    80189d <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  80188f:	83 ef 04             	sub    $0x4,%edi
  801892:	8d 72 fc             	lea    -0x4(%edx),%esi
  801895:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801898:	fd                   	std    
  801899:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  80189b:	eb 09                	jmp    8018a6 <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  80189d:	83 ef 01             	sub    $0x1,%edi
  8018a0:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018a3:	fd                   	std    
  8018a4:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018a6:	fc                   	cld    
  8018a7:	eb 1a                	jmp    8018c3 <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018a9:	89 c2                	mov    %eax,%edx
  8018ab:	09 ca                	or     %ecx,%edx
  8018ad:	09 f2                	or     %esi,%edx
  8018af:	f6 c2 03             	test   $0x3,%dl
  8018b2:	75 0a                	jne    8018be <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018b4:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018b7:	89 c7                	mov    %eax,%edi
  8018b9:	fc                   	cld    
  8018ba:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018bc:	eb 05                	jmp    8018c3 <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8018be:	89 c7                	mov    %eax,%edi
  8018c0:	fc                   	cld    
  8018c1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018c3:	5e                   	pop    %esi
  8018c4:	5f                   	pop    %edi
  8018c5:	5d                   	pop    %ebp
  8018c6:	c3                   	ret    

008018c7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018c7:	f3 0f 1e fb          	endbr32 
  8018cb:	55                   	push   %ebp
  8018cc:	89 e5                	mov    %esp,%ebp
  8018ce:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8018d1:	ff 75 10             	pushl  0x10(%ebp)
  8018d4:	ff 75 0c             	pushl  0xc(%ebp)
  8018d7:	ff 75 08             	pushl  0x8(%ebp)
  8018da:	e8 82 ff ff ff       	call   801861 <memmove>
}
  8018df:	c9                   	leave  
  8018e0:	c3                   	ret    

008018e1 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018e1:	f3 0f 1e fb          	endbr32 
  8018e5:	55                   	push   %ebp
  8018e6:	89 e5                	mov    %esp,%ebp
  8018e8:	56                   	push   %esi
  8018e9:	53                   	push   %ebx
  8018ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f0:	89 c6                	mov    %eax,%esi
  8018f2:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018f5:	39 f0                	cmp    %esi,%eax
  8018f7:	74 1c                	je     801915 <memcmp+0x34>
		if (*s1 != *s2)
  8018f9:	0f b6 08             	movzbl (%eax),%ecx
  8018fc:	0f b6 1a             	movzbl (%edx),%ebx
  8018ff:	38 d9                	cmp    %bl,%cl
  801901:	75 08                	jne    80190b <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  801903:	83 c0 01             	add    $0x1,%eax
  801906:	83 c2 01             	add    $0x1,%edx
  801909:	eb ea                	jmp    8018f5 <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  80190b:	0f b6 c1             	movzbl %cl,%eax
  80190e:	0f b6 db             	movzbl %bl,%ebx
  801911:	29 d8                	sub    %ebx,%eax
  801913:	eb 05                	jmp    80191a <memcmp+0x39>
	}

	return 0;
  801915:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80191a:	5b                   	pop    %ebx
  80191b:	5e                   	pop    %esi
  80191c:	5d                   	pop    %ebp
  80191d:	c3                   	ret    

0080191e <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80191e:	f3 0f 1e fb          	endbr32 
  801922:	55                   	push   %ebp
  801923:	89 e5                	mov    %esp,%ebp
  801925:	8b 45 08             	mov    0x8(%ebp),%eax
  801928:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  80192b:	89 c2                	mov    %eax,%edx
  80192d:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801930:	39 d0                	cmp    %edx,%eax
  801932:	73 09                	jae    80193d <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  801934:	38 08                	cmp    %cl,(%eax)
  801936:	74 05                	je     80193d <memfind+0x1f>
	for (; s < ends; s++)
  801938:	83 c0 01             	add    $0x1,%eax
  80193b:	eb f3                	jmp    801930 <memfind+0x12>
			break;
	return (void *) s;
}
  80193d:	5d                   	pop    %ebp
  80193e:	c3                   	ret    

0080193f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80193f:	f3 0f 1e fb          	endbr32 
  801943:	55                   	push   %ebp
  801944:	89 e5                	mov    %esp,%ebp
  801946:	57                   	push   %edi
  801947:	56                   	push   %esi
  801948:	53                   	push   %ebx
  801949:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80194c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80194f:	eb 03                	jmp    801954 <strtol+0x15>
		s++;
  801951:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  801954:	0f b6 01             	movzbl (%ecx),%eax
  801957:	3c 20                	cmp    $0x20,%al
  801959:	74 f6                	je     801951 <strtol+0x12>
  80195b:	3c 09                	cmp    $0x9,%al
  80195d:	74 f2                	je     801951 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  80195f:	3c 2b                	cmp    $0x2b,%al
  801961:	74 2a                	je     80198d <strtol+0x4e>
	int neg = 0;
  801963:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801968:	3c 2d                	cmp    $0x2d,%al
  80196a:	74 2b                	je     801997 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80196c:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801972:	75 0f                	jne    801983 <strtol+0x44>
  801974:	80 39 30             	cmpb   $0x30,(%ecx)
  801977:	74 28                	je     8019a1 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801979:	85 db                	test   %ebx,%ebx
  80197b:	b8 0a 00 00 00       	mov    $0xa,%eax
  801980:	0f 44 d8             	cmove  %eax,%ebx
  801983:	b8 00 00 00 00       	mov    $0x0,%eax
  801988:	89 5d 10             	mov    %ebx,0x10(%ebp)
  80198b:	eb 46                	jmp    8019d3 <strtol+0x94>
		s++;
  80198d:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801990:	bf 00 00 00 00       	mov    $0x0,%edi
  801995:	eb d5                	jmp    80196c <strtol+0x2d>
		s++, neg = 1;
  801997:	83 c1 01             	add    $0x1,%ecx
  80199a:	bf 01 00 00 00       	mov    $0x1,%edi
  80199f:	eb cb                	jmp    80196c <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019a1:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019a5:	74 0e                	je     8019b5 <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019a7:	85 db                	test   %ebx,%ebx
  8019a9:	75 d8                	jne    801983 <strtol+0x44>
		s++, base = 8;
  8019ab:	83 c1 01             	add    $0x1,%ecx
  8019ae:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019b3:	eb ce                	jmp    801983 <strtol+0x44>
		s += 2, base = 16;
  8019b5:	83 c1 02             	add    $0x2,%ecx
  8019b8:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019bd:	eb c4                	jmp    801983 <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8019bf:	0f be d2             	movsbl %dl,%edx
  8019c2:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019c5:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019c8:	7d 3a                	jge    801a04 <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8019ca:	83 c1 01             	add    $0x1,%ecx
  8019cd:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019d1:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8019d3:	0f b6 11             	movzbl (%ecx),%edx
  8019d6:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019d9:	89 f3                	mov    %esi,%ebx
  8019db:	80 fb 09             	cmp    $0x9,%bl
  8019de:	76 df                	jbe    8019bf <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  8019e0:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019e3:	89 f3                	mov    %esi,%ebx
  8019e5:	80 fb 19             	cmp    $0x19,%bl
  8019e8:	77 08                	ja     8019f2 <strtol+0xb3>
			dig = *s - 'a' + 10;
  8019ea:	0f be d2             	movsbl %dl,%edx
  8019ed:	83 ea 57             	sub    $0x57,%edx
  8019f0:	eb d3                	jmp    8019c5 <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  8019f2:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019f5:	89 f3                	mov    %esi,%ebx
  8019f7:	80 fb 19             	cmp    $0x19,%bl
  8019fa:	77 08                	ja     801a04 <strtol+0xc5>
			dig = *s - 'A' + 10;
  8019fc:	0f be d2             	movsbl %dl,%edx
  8019ff:	83 ea 37             	sub    $0x37,%edx
  801a02:	eb c1                	jmp    8019c5 <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a04:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a08:	74 05                	je     801a0f <strtol+0xd0>
		*endptr = (char *) s;
  801a0a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a0d:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a0f:	89 c2                	mov    %eax,%edx
  801a11:	f7 da                	neg    %edx
  801a13:	85 ff                	test   %edi,%edi
  801a15:	0f 45 c2             	cmovne %edx,%eax
}
  801a18:	5b                   	pop    %ebx
  801a19:	5e                   	pop    %esi
  801a1a:	5f                   	pop    %edi
  801a1b:	5d                   	pop    %ebp
  801a1c:	c3                   	ret    

00801a1d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a1d:	f3 0f 1e fb          	endbr32 
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	56                   	push   %esi
  801a25:	53                   	push   %ebx
  801a26:	8b 75 08             	mov    0x8(%ebp),%esi
  801a29:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a2c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  801a2f:	85 c0                	test   %eax,%eax
  801a31:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a36:	0f 44 c2             	cmove  %edx,%eax
  801a39:	83 ec 0c             	sub    $0xc,%esp
  801a3c:	50                   	push   %eax
  801a3d:	e8 a7 e8 ff ff       	call   8002e9 <sys_ipc_recv>

	if (from_env_store != NULL)
  801a42:	83 c4 10             	add    $0x10,%esp
  801a45:	85 f6                	test   %esi,%esi
  801a47:	74 15                	je     801a5e <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  801a49:	ba 00 00 00 00       	mov    $0x0,%edx
  801a4e:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a51:	74 09                	je     801a5c <ipc_recv+0x3f>
  801a53:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a59:	8b 52 74             	mov    0x74(%edx),%edx
  801a5c:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  801a5e:	85 db                	test   %ebx,%ebx
  801a60:	74 15                	je     801a77 <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  801a62:	ba 00 00 00 00       	mov    $0x0,%edx
  801a67:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a6a:	74 09                	je     801a75 <ipc_recv+0x58>
  801a6c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a72:	8b 52 78             	mov    0x78(%edx),%edx
  801a75:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  801a77:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a7a:	74 08                	je     801a84 <ipc_recv+0x67>
  801a7c:	a1 04 40 80 00       	mov    0x804004,%eax
  801a81:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a84:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a87:	5b                   	pop    %ebx
  801a88:	5e                   	pop    %esi
  801a89:	5d                   	pop    %ebp
  801a8a:	c3                   	ret    

00801a8b <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a8b:	f3 0f 1e fb          	endbr32 
  801a8f:	55                   	push   %ebp
  801a90:	89 e5                	mov    %esp,%ebp
  801a92:	57                   	push   %edi
  801a93:	56                   	push   %esi
  801a94:	53                   	push   %ebx
  801a95:	83 ec 0c             	sub    $0xc,%esp
  801a98:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a9b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a9e:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801aa1:	eb 1f                	jmp    801ac2 <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  801aa3:	6a 00                	push   $0x0
  801aa5:	68 00 00 c0 ee       	push   $0xeec00000
  801aaa:	56                   	push   %esi
  801aab:	57                   	push   %edi
  801aac:	e8 0f e8 ff ff       	call   8002c0 <sys_ipc_try_send>
  801ab1:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  801ab4:	85 c0                	test   %eax,%eax
  801ab6:	74 30                	je     801ae8 <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  801ab8:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801abb:	75 19                	jne    801ad6 <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  801abd:	e8 e5 e6 ff ff       	call   8001a7 <sys_yield>
		if (pg != NULL) {
  801ac2:	85 db                	test   %ebx,%ebx
  801ac4:	74 dd                	je     801aa3 <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  801ac6:	ff 75 14             	pushl  0x14(%ebp)
  801ac9:	53                   	push   %ebx
  801aca:	56                   	push   %esi
  801acb:	57                   	push   %edi
  801acc:	e8 ef e7 ff ff       	call   8002c0 <sys_ipc_try_send>
  801ad1:	83 c4 10             	add    $0x10,%esp
  801ad4:	eb de                	jmp    801ab4 <ipc_send+0x29>
			panic("ipc_send: %d", res);
  801ad6:	50                   	push   %eax
  801ad7:	68 3f 22 80 00       	push   $0x80223f
  801adc:	6a 3e                	push   $0x3e
  801ade:	68 4c 22 80 00       	push   $0x80224c
  801ae3:	e8 70 f5 ff ff       	call   801058 <_panic>
	}
}
  801ae8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801aeb:	5b                   	pop    %ebx
  801aec:	5e                   	pop    %esi
  801aed:	5f                   	pop    %edi
  801aee:	5d                   	pop    %ebp
  801aef:	c3                   	ret    

00801af0 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801af0:	f3 0f 1e fb          	endbr32 
  801af4:	55                   	push   %ebp
  801af5:	89 e5                	mov    %esp,%ebp
  801af7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801afa:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801aff:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b02:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b08:	8b 52 50             	mov    0x50(%edx),%edx
  801b0b:	39 ca                	cmp    %ecx,%edx
  801b0d:	74 11                	je     801b20 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801b0f:	83 c0 01             	add    $0x1,%eax
  801b12:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b17:	75 e6                	jne    801aff <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801b19:	b8 00 00 00 00       	mov    $0x0,%eax
  801b1e:	eb 0b                	jmp    801b2b <ipc_find_env+0x3b>
			return envs[i].env_id;
  801b20:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b23:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b28:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b2b:	5d                   	pop    %ebp
  801b2c:	c3                   	ret    

00801b2d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b2d:	f3 0f 1e fb          	endbr32 
  801b31:	55                   	push   %ebp
  801b32:	89 e5                	mov    %esp,%ebp
  801b34:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b37:	89 c2                	mov    %eax,%edx
  801b39:	c1 ea 16             	shr    $0x16,%edx
  801b3c:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b43:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b48:	f6 c1 01             	test   $0x1,%cl
  801b4b:	74 1c                	je     801b69 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801b4d:	c1 e8 0c             	shr    $0xc,%eax
  801b50:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b57:	a8 01                	test   $0x1,%al
  801b59:	74 0e                	je     801b69 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b5b:	c1 e8 0c             	shr    $0xc,%eax
  801b5e:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b65:	ef 
  801b66:	0f b7 d2             	movzwl %dx,%edx
}
  801b69:	89 d0                	mov    %edx,%eax
  801b6b:	5d                   	pop    %ebp
  801b6c:	c3                   	ret    
  801b6d:	66 90                	xchg   %ax,%ax
  801b6f:	90                   	nop

00801b70 <__udivdi3>:
  801b70:	f3 0f 1e fb          	endbr32 
  801b74:	55                   	push   %ebp
  801b75:	57                   	push   %edi
  801b76:	56                   	push   %esi
  801b77:	53                   	push   %ebx
  801b78:	83 ec 1c             	sub    $0x1c,%esp
  801b7b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801b7f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801b83:	8b 74 24 34          	mov    0x34(%esp),%esi
  801b87:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801b8b:	85 d2                	test   %edx,%edx
  801b8d:	75 19                	jne    801ba8 <__udivdi3+0x38>
  801b8f:	39 f3                	cmp    %esi,%ebx
  801b91:	76 4d                	jbe    801be0 <__udivdi3+0x70>
  801b93:	31 ff                	xor    %edi,%edi
  801b95:	89 e8                	mov    %ebp,%eax
  801b97:	89 f2                	mov    %esi,%edx
  801b99:	f7 f3                	div    %ebx
  801b9b:	89 fa                	mov    %edi,%edx
  801b9d:	83 c4 1c             	add    $0x1c,%esp
  801ba0:	5b                   	pop    %ebx
  801ba1:	5e                   	pop    %esi
  801ba2:	5f                   	pop    %edi
  801ba3:	5d                   	pop    %ebp
  801ba4:	c3                   	ret    
  801ba5:	8d 76 00             	lea    0x0(%esi),%esi
  801ba8:	39 f2                	cmp    %esi,%edx
  801baa:	76 14                	jbe    801bc0 <__udivdi3+0x50>
  801bac:	31 ff                	xor    %edi,%edi
  801bae:	31 c0                	xor    %eax,%eax
  801bb0:	89 fa                	mov    %edi,%edx
  801bb2:	83 c4 1c             	add    $0x1c,%esp
  801bb5:	5b                   	pop    %ebx
  801bb6:	5e                   	pop    %esi
  801bb7:	5f                   	pop    %edi
  801bb8:	5d                   	pop    %ebp
  801bb9:	c3                   	ret    
  801bba:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801bc0:	0f bd fa             	bsr    %edx,%edi
  801bc3:	83 f7 1f             	xor    $0x1f,%edi
  801bc6:	75 48                	jne    801c10 <__udivdi3+0xa0>
  801bc8:	39 f2                	cmp    %esi,%edx
  801bca:	72 06                	jb     801bd2 <__udivdi3+0x62>
  801bcc:	31 c0                	xor    %eax,%eax
  801bce:	39 eb                	cmp    %ebp,%ebx
  801bd0:	77 de                	ja     801bb0 <__udivdi3+0x40>
  801bd2:	b8 01 00 00 00       	mov    $0x1,%eax
  801bd7:	eb d7                	jmp    801bb0 <__udivdi3+0x40>
  801bd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801be0:	89 d9                	mov    %ebx,%ecx
  801be2:	85 db                	test   %ebx,%ebx
  801be4:	75 0b                	jne    801bf1 <__udivdi3+0x81>
  801be6:	b8 01 00 00 00       	mov    $0x1,%eax
  801beb:	31 d2                	xor    %edx,%edx
  801bed:	f7 f3                	div    %ebx
  801bef:	89 c1                	mov    %eax,%ecx
  801bf1:	31 d2                	xor    %edx,%edx
  801bf3:	89 f0                	mov    %esi,%eax
  801bf5:	f7 f1                	div    %ecx
  801bf7:	89 c6                	mov    %eax,%esi
  801bf9:	89 e8                	mov    %ebp,%eax
  801bfb:	89 f7                	mov    %esi,%edi
  801bfd:	f7 f1                	div    %ecx
  801bff:	89 fa                	mov    %edi,%edx
  801c01:	83 c4 1c             	add    $0x1c,%esp
  801c04:	5b                   	pop    %ebx
  801c05:	5e                   	pop    %esi
  801c06:	5f                   	pop    %edi
  801c07:	5d                   	pop    %ebp
  801c08:	c3                   	ret    
  801c09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c10:	89 f9                	mov    %edi,%ecx
  801c12:	b8 20 00 00 00       	mov    $0x20,%eax
  801c17:	29 f8                	sub    %edi,%eax
  801c19:	d3 e2                	shl    %cl,%edx
  801c1b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c1f:	89 c1                	mov    %eax,%ecx
  801c21:	89 da                	mov    %ebx,%edx
  801c23:	d3 ea                	shr    %cl,%edx
  801c25:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c29:	09 d1                	or     %edx,%ecx
  801c2b:	89 f2                	mov    %esi,%edx
  801c2d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c31:	89 f9                	mov    %edi,%ecx
  801c33:	d3 e3                	shl    %cl,%ebx
  801c35:	89 c1                	mov    %eax,%ecx
  801c37:	d3 ea                	shr    %cl,%edx
  801c39:	89 f9                	mov    %edi,%ecx
  801c3b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c3f:	89 eb                	mov    %ebp,%ebx
  801c41:	d3 e6                	shl    %cl,%esi
  801c43:	89 c1                	mov    %eax,%ecx
  801c45:	d3 eb                	shr    %cl,%ebx
  801c47:	09 de                	or     %ebx,%esi
  801c49:	89 f0                	mov    %esi,%eax
  801c4b:	f7 74 24 08          	divl   0x8(%esp)
  801c4f:	89 d6                	mov    %edx,%esi
  801c51:	89 c3                	mov    %eax,%ebx
  801c53:	f7 64 24 0c          	mull   0xc(%esp)
  801c57:	39 d6                	cmp    %edx,%esi
  801c59:	72 15                	jb     801c70 <__udivdi3+0x100>
  801c5b:	89 f9                	mov    %edi,%ecx
  801c5d:	d3 e5                	shl    %cl,%ebp
  801c5f:	39 c5                	cmp    %eax,%ebp
  801c61:	73 04                	jae    801c67 <__udivdi3+0xf7>
  801c63:	39 d6                	cmp    %edx,%esi
  801c65:	74 09                	je     801c70 <__udivdi3+0x100>
  801c67:	89 d8                	mov    %ebx,%eax
  801c69:	31 ff                	xor    %edi,%edi
  801c6b:	e9 40 ff ff ff       	jmp    801bb0 <__udivdi3+0x40>
  801c70:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c73:	31 ff                	xor    %edi,%edi
  801c75:	e9 36 ff ff ff       	jmp    801bb0 <__udivdi3+0x40>
  801c7a:	66 90                	xchg   %ax,%ax
  801c7c:	66 90                	xchg   %ax,%ax
  801c7e:	66 90                	xchg   %ax,%ax

00801c80 <__umoddi3>:
  801c80:	f3 0f 1e fb          	endbr32 
  801c84:	55                   	push   %ebp
  801c85:	57                   	push   %edi
  801c86:	56                   	push   %esi
  801c87:	53                   	push   %ebx
  801c88:	83 ec 1c             	sub    $0x1c,%esp
  801c8b:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801c8f:	8b 74 24 30          	mov    0x30(%esp),%esi
  801c93:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801c97:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c9b:	85 c0                	test   %eax,%eax
  801c9d:	75 19                	jne    801cb8 <__umoddi3+0x38>
  801c9f:	39 df                	cmp    %ebx,%edi
  801ca1:	76 5d                	jbe    801d00 <__umoddi3+0x80>
  801ca3:	89 f0                	mov    %esi,%eax
  801ca5:	89 da                	mov    %ebx,%edx
  801ca7:	f7 f7                	div    %edi
  801ca9:	89 d0                	mov    %edx,%eax
  801cab:	31 d2                	xor    %edx,%edx
  801cad:	83 c4 1c             	add    $0x1c,%esp
  801cb0:	5b                   	pop    %ebx
  801cb1:	5e                   	pop    %esi
  801cb2:	5f                   	pop    %edi
  801cb3:	5d                   	pop    %ebp
  801cb4:	c3                   	ret    
  801cb5:	8d 76 00             	lea    0x0(%esi),%esi
  801cb8:	89 f2                	mov    %esi,%edx
  801cba:	39 d8                	cmp    %ebx,%eax
  801cbc:	76 12                	jbe    801cd0 <__umoddi3+0x50>
  801cbe:	89 f0                	mov    %esi,%eax
  801cc0:	89 da                	mov    %ebx,%edx
  801cc2:	83 c4 1c             	add    $0x1c,%esp
  801cc5:	5b                   	pop    %ebx
  801cc6:	5e                   	pop    %esi
  801cc7:	5f                   	pop    %edi
  801cc8:	5d                   	pop    %ebp
  801cc9:	c3                   	ret    
  801cca:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cd0:	0f bd e8             	bsr    %eax,%ebp
  801cd3:	83 f5 1f             	xor    $0x1f,%ebp
  801cd6:	75 50                	jne    801d28 <__umoddi3+0xa8>
  801cd8:	39 d8                	cmp    %ebx,%eax
  801cda:	0f 82 e0 00 00 00    	jb     801dc0 <__umoddi3+0x140>
  801ce0:	89 d9                	mov    %ebx,%ecx
  801ce2:	39 f7                	cmp    %esi,%edi
  801ce4:	0f 86 d6 00 00 00    	jbe    801dc0 <__umoddi3+0x140>
  801cea:	89 d0                	mov    %edx,%eax
  801cec:	89 ca                	mov    %ecx,%edx
  801cee:	83 c4 1c             	add    $0x1c,%esp
  801cf1:	5b                   	pop    %ebx
  801cf2:	5e                   	pop    %esi
  801cf3:	5f                   	pop    %edi
  801cf4:	5d                   	pop    %ebp
  801cf5:	c3                   	ret    
  801cf6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801cfd:	8d 76 00             	lea    0x0(%esi),%esi
  801d00:	89 fd                	mov    %edi,%ebp
  801d02:	85 ff                	test   %edi,%edi
  801d04:	75 0b                	jne    801d11 <__umoddi3+0x91>
  801d06:	b8 01 00 00 00       	mov    $0x1,%eax
  801d0b:	31 d2                	xor    %edx,%edx
  801d0d:	f7 f7                	div    %edi
  801d0f:	89 c5                	mov    %eax,%ebp
  801d11:	89 d8                	mov    %ebx,%eax
  801d13:	31 d2                	xor    %edx,%edx
  801d15:	f7 f5                	div    %ebp
  801d17:	89 f0                	mov    %esi,%eax
  801d19:	f7 f5                	div    %ebp
  801d1b:	89 d0                	mov    %edx,%eax
  801d1d:	31 d2                	xor    %edx,%edx
  801d1f:	eb 8c                	jmp    801cad <__umoddi3+0x2d>
  801d21:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d28:	89 e9                	mov    %ebp,%ecx
  801d2a:	ba 20 00 00 00       	mov    $0x20,%edx
  801d2f:	29 ea                	sub    %ebp,%edx
  801d31:	d3 e0                	shl    %cl,%eax
  801d33:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d37:	89 d1                	mov    %edx,%ecx
  801d39:	89 f8                	mov    %edi,%eax
  801d3b:	d3 e8                	shr    %cl,%eax
  801d3d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d41:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d45:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d49:	09 c1                	or     %eax,%ecx
  801d4b:	89 d8                	mov    %ebx,%eax
  801d4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d51:	89 e9                	mov    %ebp,%ecx
  801d53:	d3 e7                	shl    %cl,%edi
  801d55:	89 d1                	mov    %edx,%ecx
  801d57:	d3 e8                	shr    %cl,%eax
  801d59:	89 e9                	mov    %ebp,%ecx
  801d5b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d5f:	d3 e3                	shl    %cl,%ebx
  801d61:	89 c7                	mov    %eax,%edi
  801d63:	89 d1                	mov    %edx,%ecx
  801d65:	89 f0                	mov    %esi,%eax
  801d67:	d3 e8                	shr    %cl,%eax
  801d69:	89 e9                	mov    %ebp,%ecx
  801d6b:	89 fa                	mov    %edi,%edx
  801d6d:	d3 e6                	shl    %cl,%esi
  801d6f:	09 d8                	or     %ebx,%eax
  801d71:	f7 74 24 08          	divl   0x8(%esp)
  801d75:	89 d1                	mov    %edx,%ecx
  801d77:	89 f3                	mov    %esi,%ebx
  801d79:	f7 64 24 0c          	mull   0xc(%esp)
  801d7d:	89 c6                	mov    %eax,%esi
  801d7f:	89 d7                	mov    %edx,%edi
  801d81:	39 d1                	cmp    %edx,%ecx
  801d83:	72 06                	jb     801d8b <__umoddi3+0x10b>
  801d85:	75 10                	jne    801d97 <__umoddi3+0x117>
  801d87:	39 c3                	cmp    %eax,%ebx
  801d89:	73 0c                	jae    801d97 <__umoddi3+0x117>
  801d8b:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801d8f:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801d93:	89 d7                	mov    %edx,%edi
  801d95:	89 c6                	mov    %eax,%esi
  801d97:	89 ca                	mov    %ecx,%edx
  801d99:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801d9e:	29 f3                	sub    %esi,%ebx
  801da0:	19 fa                	sbb    %edi,%edx
  801da2:	89 d0                	mov    %edx,%eax
  801da4:	d3 e0                	shl    %cl,%eax
  801da6:	89 e9                	mov    %ebp,%ecx
  801da8:	d3 eb                	shr    %cl,%ebx
  801daa:	d3 ea                	shr    %cl,%edx
  801dac:	09 d8                	or     %ebx,%eax
  801dae:	83 c4 1c             	add    $0x1c,%esp
  801db1:	5b                   	pop    %ebx
  801db2:	5e                   	pop    %esi
  801db3:	5f                   	pop    %edi
  801db4:	5d                   	pop    %ebp
  801db5:	c3                   	ret    
  801db6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801dbd:	8d 76 00             	lea    0x0(%esi),%esi
  801dc0:	29 fe                	sub    %edi,%esi
  801dc2:	19 c3                	sbb    %eax,%ebx
  801dc4:	89 f2                	mov    %esi,%edx
  801dc6:	89 d9                	mov    %ebx,%ecx
  801dc8:	e9 1d ff ff ff       	jmp    801cea <__umoddi3+0x6a>
