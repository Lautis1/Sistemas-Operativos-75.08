
obj/user/faultevilhandler.debug:     formato del fichero elf32-i386


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
  80002c:	e8 38 00 00 00       	call   800069 <libmain>
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
  80003a:	83 ec 0c             	sub    $0xc,%esp
	sys_page_alloc(0, (void*) (UXSTACKTOP - PGSIZE), PTE_P|PTE_U|PTE_W);
  80003d:	6a 07                	push   $0x7
  80003f:	68 00 f0 bf ee       	push   $0xeebff000
  800044:	6a 00                	push   $0x0
  800046:	e8 9e 01 00 00       	call   8001e9 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xF0100020);
  80004b:	83 c4 08             	add    $0x8,%esp
  80004e:	68 20 00 10 f0       	push   $0xf0100020
  800053:	6a 00                	push   $0x0
  800055:	e8 56 02 00 00       	call   8002b0 <sys_env_set_pgfault_upcall>
	*(int*)0 = 0;
  80005a:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  800061:	00 00 00 
}
  800064:	83 c4 10             	add    $0x10,%esp
  800067:	c9                   	leave  
  800068:	c3                   	ret    

00800069 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800069:	f3 0f 1e fb          	endbr32 
  80006d:	55                   	push   %ebp
  80006e:	89 e5                	mov    %esp,%ebp
  800070:	56                   	push   %esi
  800071:	53                   	push   %ebx
  800072:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800075:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  800078:	e8 19 01 00 00       	call   800196 <sys_getenvid>
	if (id >= 0)
  80007d:	85 c0                	test   %eax,%eax
  80007f:	78 12                	js     800093 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800081:	25 ff 03 00 00       	and    $0x3ff,%eax
  800086:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800089:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80008e:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800093:	85 db                	test   %ebx,%ebx
  800095:	7e 07                	jle    80009e <libmain+0x35>
		binaryname = argv[0];
  800097:	8b 06                	mov    (%esi),%eax
  800099:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80009e:	83 ec 08             	sub    $0x8,%esp
  8000a1:	56                   	push   %esi
  8000a2:	53                   	push   %ebx
  8000a3:	e8 8b ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  8000a8:	e8 0a 00 00 00       	call   8000b7 <exit>
}
  8000ad:	83 c4 10             	add    $0x10,%esp
  8000b0:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8000b3:	5b                   	pop    %ebx
  8000b4:	5e                   	pop    %esi
  8000b5:	5d                   	pop    %ebp
  8000b6:	c3                   	ret    

008000b7 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  8000b7:	f3 0f 1e fb          	endbr32 
  8000bb:	55                   	push   %ebp
  8000bc:	89 e5                	mov    %esp,%ebp
  8000be:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000c1:	e8 53 04 00 00       	call   800519 <close_all>
	sys_env_destroy(0);
  8000c6:	83 ec 0c             	sub    $0xc,%esp
  8000c9:	6a 00                	push   $0x0
  8000cb:	e8 a0 00 00 00       	call   800170 <sys_env_destroy>
}
  8000d0:	83 c4 10             	add    $0x10,%esp
  8000d3:	c9                   	leave  
  8000d4:	c3                   	ret    

008000d5 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000d5:	55                   	push   %ebp
  8000d6:	89 e5                	mov    %esp,%ebp
  8000d8:	57                   	push   %edi
  8000d9:	56                   	push   %esi
  8000da:	53                   	push   %ebx
  8000db:	83 ec 1c             	sub    $0x1c,%esp
  8000de:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000e1:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000e4:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000e6:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000ec:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000ef:	8b 75 14             	mov    0x14(%ebp),%esi
  8000f2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f4:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000f8:	74 04                	je     8000fe <syscall+0x29>
  8000fa:	85 c0                	test   %eax,%eax
  8000fc:	7f 08                	jg     800106 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800101:	5b                   	pop    %ebx
  800102:	5e                   	pop    %esi
  800103:	5f                   	pop    %edi
  800104:	5d                   	pop    %ebp
  800105:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	50                   	push   %eax
  80010a:	ff 75 e0             	pushl  -0x20(%ebp)
  80010d:	68 0a 1e 80 00       	push   $0x801e0a
  800112:	6a 23                	push   $0x23
  800114:	68 27 1e 80 00       	push   $0x801e27
  800119:	e8 51 0f 00 00       	call   80106f <_panic>

0080011e <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  80011e:	f3 0f 1e fb          	endbr32 
  800122:	55                   	push   %ebp
  800123:	89 e5                	mov    %esp,%ebp
  800125:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  800128:	6a 00                	push   $0x0
  80012a:	6a 00                	push   $0x0
  80012c:	6a 00                	push   $0x0
  80012e:	ff 75 0c             	pushl  0xc(%ebp)
  800131:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800134:	ba 00 00 00 00       	mov    $0x0,%edx
  800139:	b8 00 00 00 00       	mov    $0x0,%eax
  80013e:	e8 92 ff ff ff       	call   8000d5 <syscall>
}
  800143:	83 c4 10             	add    $0x10,%esp
  800146:	c9                   	leave  
  800147:	c3                   	ret    

00800148 <sys_cgetc>:

int
sys_cgetc(void)
{
  800148:	f3 0f 1e fb          	endbr32 
  80014c:	55                   	push   %ebp
  80014d:	89 e5                	mov    %esp,%ebp
  80014f:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800152:	6a 00                	push   $0x0
  800154:	6a 00                	push   $0x0
  800156:	6a 00                	push   $0x0
  800158:	6a 00                	push   $0x0
  80015a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80015f:	ba 00 00 00 00       	mov    $0x0,%edx
  800164:	b8 01 00 00 00       	mov    $0x1,%eax
  800169:	e8 67 ff ff ff       	call   8000d5 <syscall>
}
  80016e:	c9                   	leave  
  80016f:	c3                   	ret    

00800170 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800170:	f3 0f 1e fb          	endbr32 
  800174:	55                   	push   %ebp
  800175:	89 e5                	mov    %esp,%ebp
  800177:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80017a:	6a 00                	push   $0x0
  80017c:	6a 00                	push   $0x0
  80017e:	6a 00                	push   $0x0
  800180:	6a 00                	push   $0x0
  800182:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800185:	ba 01 00 00 00       	mov    $0x1,%edx
  80018a:	b8 03 00 00 00       	mov    $0x3,%eax
  80018f:	e8 41 ff ff ff       	call   8000d5 <syscall>
}
  800194:	c9                   	leave  
  800195:	c3                   	ret    

00800196 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800196:	f3 0f 1e fb          	endbr32 
  80019a:	55                   	push   %ebp
  80019b:	89 e5                	mov    %esp,%ebp
  80019d:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  8001a0:	6a 00                	push   $0x0
  8001a2:	6a 00                	push   $0x0
  8001a4:	6a 00                	push   $0x0
  8001a6:	6a 00                	push   $0x0
  8001a8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001ad:	ba 00 00 00 00       	mov    $0x0,%edx
  8001b2:	b8 02 00 00 00       	mov    $0x2,%eax
  8001b7:	e8 19 ff ff ff       	call   8000d5 <syscall>
}
  8001bc:	c9                   	leave  
  8001bd:	c3                   	ret    

008001be <sys_yield>:

void
sys_yield(void)
{
  8001be:	f3 0f 1e fb          	endbr32 
  8001c2:	55                   	push   %ebp
  8001c3:	89 e5                	mov    %esp,%ebp
  8001c5:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8001c8:	6a 00                	push   $0x0
  8001ca:	6a 00                	push   $0x0
  8001cc:	6a 00                	push   $0x0
  8001ce:	6a 00                	push   $0x0
  8001d0:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001d5:	ba 00 00 00 00       	mov    $0x0,%edx
  8001da:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001df:	e8 f1 fe ff ff       	call   8000d5 <syscall>
}
  8001e4:	83 c4 10             	add    $0x10,%esp
  8001e7:	c9                   	leave  
  8001e8:	c3                   	ret    

008001e9 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001e9:	f3 0f 1e fb          	endbr32 
  8001ed:	55                   	push   %ebp
  8001ee:	89 e5                	mov    %esp,%ebp
  8001f0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001f3:	6a 00                	push   $0x0
  8001f5:	6a 00                	push   $0x0
  8001f7:	ff 75 10             	pushl  0x10(%ebp)
  8001fa:	ff 75 0c             	pushl  0xc(%ebp)
  8001fd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800200:	ba 01 00 00 00       	mov    $0x1,%edx
  800205:	b8 04 00 00 00       	mov    $0x4,%eax
  80020a:	e8 c6 fe ff ff       	call   8000d5 <syscall>
}
  80020f:	c9                   	leave  
  800210:	c3                   	ret    

00800211 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800211:	f3 0f 1e fb          	endbr32 
  800215:	55                   	push   %ebp
  800216:	89 e5                	mov    %esp,%ebp
  800218:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  80021b:	ff 75 18             	pushl  0x18(%ebp)
  80021e:	ff 75 14             	pushl  0x14(%ebp)
  800221:	ff 75 10             	pushl  0x10(%ebp)
  800224:	ff 75 0c             	pushl  0xc(%ebp)
  800227:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80022a:	ba 01 00 00 00       	mov    $0x1,%edx
  80022f:	b8 05 00 00 00       	mov    $0x5,%eax
  800234:	e8 9c fe ff ff       	call   8000d5 <syscall>
}
  800239:	c9                   	leave  
  80023a:	c3                   	ret    

0080023b <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80023b:	f3 0f 1e fb          	endbr32 
  80023f:	55                   	push   %ebp
  800240:	89 e5                	mov    %esp,%ebp
  800242:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800245:	6a 00                	push   $0x0
  800247:	6a 00                	push   $0x0
  800249:	6a 00                	push   $0x0
  80024b:	ff 75 0c             	pushl  0xc(%ebp)
  80024e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800251:	ba 01 00 00 00       	mov    $0x1,%edx
  800256:	b8 06 00 00 00       	mov    $0x6,%eax
  80025b:	e8 75 fe ff ff       	call   8000d5 <syscall>
}
  800260:	c9                   	leave  
  800261:	c3                   	ret    

00800262 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800262:	f3 0f 1e fb          	endbr32 
  800266:	55                   	push   %ebp
  800267:	89 e5                	mov    %esp,%ebp
  800269:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80026c:	6a 00                	push   $0x0
  80026e:	6a 00                	push   $0x0
  800270:	6a 00                	push   $0x0
  800272:	ff 75 0c             	pushl  0xc(%ebp)
  800275:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800278:	ba 01 00 00 00       	mov    $0x1,%edx
  80027d:	b8 08 00 00 00       	mov    $0x8,%eax
  800282:	e8 4e fe ff ff       	call   8000d5 <syscall>
}
  800287:	c9                   	leave  
  800288:	c3                   	ret    

00800289 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800289:	f3 0f 1e fb          	endbr32 
  80028d:	55                   	push   %ebp
  80028e:	89 e5                	mov    %esp,%ebp
  800290:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800293:	6a 00                	push   $0x0
  800295:	6a 00                	push   $0x0
  800297:	6a 00                	push   $0x0
  800299:	ff 75 0c             	pushl  0xc(%ebp)
  80029c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80029f:	ba 01 00 00 00       	mov    $0x1,%edx
  8002a4:	b8 09 00 00 00       	mov    $0x9,%eax
  8002a9:	e8 27 fe ff ff       	call   8000d5 <syscall>
}
  8002ae:	c9                   	leave  
  8002af:	c3                   	ret    

008002b0 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b0:	f3 0f 1e fb          	endbr32 
  8002b4:	55                   	push   %ebp
  8002b5:	89 e5                	mov    %esp,%ebp
  8002b7:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  8002ba:	6a 00                	push   $0x0
  8002bc:	6a 00                	push   $0x0
  8002be:	6a 00                	push   $0x0
  8002c0:	ff 75 0c             	pushl  0xc(%ebp)
  8002c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002c6:	ba 01 00 00 00       	mov    $0x1,%edx
  8002cb:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002d0:	e8 00 fe ff ff       	call   8000d5 <syscall>
}
  8002d5:	c9                   	leave  
  8002d6:	c3                   	ret    

008002d7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002d7:	f3 0f 1e fb          	endbr32 
  8002db:	55                   	push   %ebp
  8002dc:	89 e5                	mov    %esp,%ebp
  8002de:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8002e1:	6a 00                	push   $0x0
  8002e3:	ff 75 14             	pushl  0x14(%ebp)
  8002e6:	ff 75 10             	pushl  0x10(%ebp)
  8002e9:	ff 75 0c             	pushl  0xc(%ebp)
  8002ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002ef:	ba 00 00 00 00       	mov    $0x0,%edx
  8002f4:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f9:	e8 d7 fd ff ff       	call   8000d5 <syscall>
}
  8002fe:	c9                   	leave  
  8002ff:	c3                   	ret    

00800300 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800300:	f3 0f 1e fb          	endbr32 
  800304:	55                   	push   %ebp
  800305:	89 e5                	mov    %esp,%ebp
  800307:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  80030a:	6a 00                	push   $0x0
  80030c:	6a 00                	push   $0x0
  80030e:	6a 00                	push   $0x0
  800310:	6a 00                	push   $0x0
  800312:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800315:	ba 01 00 00 00       	mov    $0x1,%edx
  80031a:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031f:	e8 b1 fd ff ff       	call   8000d5 <syscall>
}
  800324:	c9                   	leave  
  800325:	c3                   	ret    

00800326 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800326:	f3 0f 1e fb          	endbr32 
  80032a:	55                   	push   %ebp
  80032b:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80032d:	8b 45 08             	mov    0x8(%ebp),%eax
  800330:	05 00 00 00 30       	add    $0x30000000,%eax
  800335:	c1 e8 0c             	shr    $0xc,%eax
}
  800338:	5d                   	pop    %ebp
  800339:	c3                   	ret    

0080033a <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80033a:	f3 0f 1e fb          	endbr32 
  80033e:	55                   	push   %ebp
  80033f:	89 e5                	mov    %esp,%ebp
  800341:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800344:	ff 75 08             	pushl  0x8(%ebp)
  800347:	e8 da ff ff ff       	call   800326 <fd2num>
  80034c:	83 c4 10             	add    $0x10,%esp
  80034f:	c1 e0 0c             	shl    $0xc,%eax
  800352:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800357:	c9                   	leave  
  800358:	c3                   	ret    

00800359 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800359:	f3 0f 1e fb          	endbr32 
  80035d:	55                   	push   %ebp
  80035e:	89 e5                	mov    %esp,%ebp
  800360:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800365:	89 c2                	mov    %eax,%edx
  800367:	c1 ea 16             	shr    $0x16,%edx
  80036a:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800371:	f6 c2 01             	test   $0x1,%dl
  800374:	74 2d                	je     8003a3 <fd_alloc+0x4a>
  800376:	89 c2                	mov    %eax,%edx
  800378:	c1 ea 0c             	shr    $0xc,%edx
  80037b:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800382:	f6 c2 01             	test   $0x1,%dl
  800385:	74 1c                	je     8003a3 <fd_alloc+0x4a>
  800387:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80038c:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800391:	75 d2                	jne    800365 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800393:	8b 45 08             	mov    0x8(%ebp),%eax
  800396:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80039c:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  8003a1:	eb 0a                	jmp    8003ad <fd_alloc+0x54>
			*fd_store = fd;
  8003a3:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003a6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003a8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003ad:	5d                   	pop    %ebp
  8003ae:	c3                   	ret    

008003af <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003af:	f3 0f 1e fb          	endbr32 
  8003b3:	55                   	push   %ebp
  8003b4:	89 e5                	mov    %esp,%ebp
  8003b6:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003b9:	83 f8 1f             	cmp    $0x1f,%eax
  8003bc:	77 30                	ja     8003ee <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003be:	c1 e0 0c             	shl    $0xc,%eax
  8003c1:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003c6:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8003cc:	f6 c2 01             	test   $0x1,%dl
  8003cf:	74 24                	je     8003f5 <fd_lookup+0x46>
  8003d1:	89 c2                	mov    %eax,%edx
  8003d3:	c1 ea 0c             	shr    $0xc,%edx
  8003d6:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003dd:	f6 c2 01             	test   $0x1,%dl
  8003e0:	74 1a                	je     8003fc <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003e2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003e5:	89 02                	mov    %eax,(%edx)
	return 0;
  8003e7:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003ec:	5d                   	pop    %ebp
  8003ed:	c3                   	ret    
		return -E_INVAL;
  8003ee:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003f3:	eb f7                	jmp    8003ec <fd_lookup+0x3d>
		return -E_INVAL;
  8003f5:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003fa:	eb f0                	jmp    8003ec <fd_lookup+0x3d>
  8003fc:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800401:	eb e9                	jmp    8003ec <fd_lookup+0x3d>

00800403 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800403:	f3 0f 1e fb          	endbr32 
  800407:	55                   	push   %ebp
  800408:	89 e5                	mov    %esp,%ebp
  80040a:	83 ec 08             	sub    $0x8,%esp
  80040d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800410:	ba b4 1e 80 00       	mov    $0x801eb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800415:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  80041a:	39 08                	cmp    %ecx,(%eax)
  80041c:	74 33                	je     800451 <dev_lookup+0x4e>
  80041e:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800421:	8b 02                	mov    (%edx),%eax
  800423:	85 c0                	test   %eax,%eax
  800425:	75 f3                	jne    80041a <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800427:	a1 04 40 80 00       	mov    0x804004,%eax
  80042c:	8b 40 48             	mov    0x48(%eax),%eax
  80042f:	83 ec 04             	sub    $0x4,%esp
  800432:	51                   	push   %ecx
  800433:	50                   	push   %eax
  800434:	68 38 1e 80 00       	push   $0x801e38
  800439:	e8 18 0d 00 00       	call   801156 <cprintf>
	*dev = 0;
  80043e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800441:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800447:	83 c4 10             	add    $0x10,%esp
  80044a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80044f:	c9                   	leave  
  800450:	c3                   	ret    
			*dev = devtab[i];
  800451:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800454:	89 01                	mov    %eax,(%ecx)
			return 0;
  800456:	b8 00 00 00 00       	mov    $0x0,%eax
  80045b:	eb f2                	jmp    80044f <dev_lookup+0x4c>

0080045d <fd_close>:
{
  80045d:	f3 0f 1e fb          	endbr32 
  800461:	55                   	push   %ebp
  800462:	89 e5                	mov    %esp,%ebp
  800464:	57                   	push   %edi
  800465:	56                   	push   %esi
  800466:	53                   	push   %ebx
  800467:	83 ec 28             	sub    $0x28,%esp
  80046a:	8b 75 08             	mov    0x8(%ebp),%esi
  80046d:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800470:	56                   	push   %esi
  800471:	e8 b0 fe ff ff       	call   800326 <fd2num>
  800476:	83 c4 08             	add    $0x8,%esp
  800479:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80047c:	52                   	push   %edx
  80047d:	50                   	push   %eax
  80047e:	e8 2c ff ff ff       	call   8003af <fd_lookup>
  800483:	89 c3                	mov    %eax,%ebx
  800485:	83 c4 10             	add    $0x10,%esp
  800488:	85 c0                	test   %eax,%eax
  80048a:	78 05                	js     800491 <fd_close+0x34>
	    || fd != fd2)
  80048c:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  80048f:	74 16                	je     8004a7 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800491:	89 f8                	mov    %edi,%eax
  800493:	84 c0                	test   %al,%al
  800495:	b8 00 00 00 00       	mov    $0x0,%eax
  80049a:	0f 44 d8             	cmove  %eax,%ebx
}
  80049d:	89 d8                	mov    %ebx,%eax
  80049f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a2:	5b                   	pop    %ebx
  8004a3:	5e                   	pop    %esi
  8004a4:	5f                   	pop    %edi
  8004a5:	5d                   	pop    %ebp
  8004a6:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	8d 45 e0             	lea    -0x20(%ebp),%eax
  8004ad:	50                   	push   %eax
  8004ae:	ff 36                	pushl  (%esi)
  8004b0:	e8 4e ff ff ff       	call   800403 <dev_lookup>
  8004b5:	89 c3                	mov    %eax,%ebx
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	85 c0                	test   %eax,%eax
  8004bc:	78 1a                	js     8004d8 <fd_close+0x7b>
		if (dev->dev_close)
  8004be:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004c1:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8004c4:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8004c9:	85 c0                	test   %eax,%eax
  8004cb:	74 0b                	je     8004d8 <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8004cd:	83 ec 0c             	sub    $0xc,%esp
  8004d0:	56                   	push   %esi
  8004d1:	ff d0                	call   *%eax
  8004d3:	89 c3                	mov    %eax,%ebx
  8004d5:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	56                   	push   %esi
  8004dc:	6a 00                	push   $0x0
  8004de:	e8 58 fd ff ff       	call   80023b <sys_page_unmap>
	return r;
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	eb b5                	jmp    80049d <fd_close+0x40>

008004e8 <close>:

int
close(int fdnum)
{
  8004e8:	f3 0f 1e fb          	endbr32 
  8004ec:	55                   	push   %ebp
  8004ed:	89 e5                	mov    %esp,%ebp
  8004ef:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f5:	50                   	push   %eax
  8004f6:	ff 75 08             	pushl  0x8(%ebp)
  8004f9:	e8 b1 fe ff ff       	call   8003af <fd_lookup>
  8004fe:	83 c4 10             	add    $0x10,%esp
  800501:	85 c0                	test   %eax,%eax
  800503:	79 02                	jns    800507 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  800505:	c9                   	leave  
  800506:	c3                   	ret    
		return fd_close(fd, 1);
  800507:	83 ec 08             	sub    $0x8,%esp
  80050a:	6a 01                	push   $0x1
  80050c:	ff 75 f4             	pushl  -0xc(%ebp)
  80050f:	e8 49 ff ff ff       	call   80045d <fd_close>
  800514:	83 c4 10             	add    $0x10,%esp
  800517:	eb ec                	jmp    800505 <close+0x1d>

00800519 <close_all>:

void
close_all(void)
{
  800519:	f3 0f 1e fb          	endbr32 
  80051d:	55                   	push   %ebp
  80051e:	89 e5                	mov    %esp,%ebp
  800520:	53                   	push   %ebx
  800521:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800524:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800529:	83 ec 0c             	sub    $0xc,%esp
  80052c:	53                   	push   %ebx
  80052d:	e8 b6 ff ff ff       	call   8004e8 <close>
	for (i = 0; i < MAXFD; i++)
  800532:	83 c3 01             	add    $0x1,%ebx
  800535:	83 c4 10             	add    $0x10,%esp
  800538:	83 fb 20             	cmp    $0x20,%ebx
  80053b:	75 ec                	jne    800529 <close_all+0x10>
}
  80053d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800540:	c9                   	leave  
  800541:	c3                   	ret    

00800542 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800542:	f3 0f 1e fb          	endbr32 
  800546:	55                   	push   %ebp
  800547:	89 e5                	mov    %esp,%ebp
  800549:	57                   	push   %edi
  80054a:	56                   	push   %esi
  80054b:	53                   	push   %ebx
  80054c:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80054f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800552:	50                   	push   %eax
  800553:	ff 75 08             	pushl  0x8(%ebp)
  800556:	e8 54 fe ff ff       	call   8003af <fd_lookup>
  80055b:	89 c3                	mov    %eax,%ebx
  80055d:	83 c4 10             	add    $0x10,%esp
  800560:	85 c0                	test   %eax,%eax
  800562:	0f 88 81 00 00 00    	js     8005e9 <dup+0xa7>
		return r;
	close(newfdnum);
  800568:	83 ec 0c             	sub    $0xc,%esp
  80056b:	ff 75 0c             	pushl  0xc(%ebp)
  80056e:	e8 75 ff ff ff       	call   8004e8 <close>

	newfd = INDEX2FD(newfdnum);
  800573:	8b 75 0c             	mov    0xc(%ebp),%esi
  800576:	c1 e6 0c             	shl    $0xc,%esi
  800579:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  80057f:	83 c4 04             	add    $0x4,%esp
  800582:	ff 75 e4             	pushl  -0x1c(%ebp)
  800585:	e8 b0 fd ff ff       	call   80033a <fd2data>
  80058a:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80058c:	89 34 24             	mov    %esi,(%esp)
  80058f:	e8 a6 fd ff ff       	call   80033a <fd2data>
  800594:	83 c4 10             	add    $0x10,%esp
  800597:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800599:	89 d8                	mov    %ebx,%eax
  80059b:	c1 e8 16             	shr    $0x16,%eax
  80059e:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a5:	a8 01                	test   $0x1,%al
  8005a7:	74 11                	je     8005ba <dup+0x78>
  8005a9:	89 d8                	mov    %ebx,%eax
  8005ab:	c1 e8 0c             	shr    $0xc,%eax
  8005ae:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b5:	f6 c2 01             	test   $0x1,%dl
  8005b8:	75 39                	jne    8005f3 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005ba:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005bd:	89 d0                	mov    %edx,%eax
  8005bf:	c1 e8 0c             	shr    $0xc,%eax
  8005c2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c9:	83 ec 0c             	sub    $0xc,%esp
  8005cc:	25 07 0e 00 00       	and    $0xe07,%eax
  8005d1:	50                   	push   %eax
  8005d2:	56                   	push   %esi
  8005d3:	6a 00                	push   $0x0
  8005d5:	52                   	push   %edx
  8005d6:	6a 00                	push   $0x0
  8005d8:	e8 34 fc ff ff       	call   800211 <sys_page_map>
  8005dd:	89 c3                	mov    %eax,%ebx
  8005df:	83 c4 20             	add    $0x20,%esp
  8005e2:	85 c0                	test   %eax,%eax
  8005e4:	78 31                	js     800617 <dup+0xd5>
		goto err;

	return newfdnum;
  8005e6:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005e9:	89 d8                	mov    %ebx,%eax
  8005eb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005ee:	5b                   	pop    %ebx
  8005ef:	5e                   	pop    %esi
  8005f0:	5f                   	pop    %edi
  8005f1:	5d                   	pop    %ebp
  8005f2:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005f3:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005fa:	83 ec 0c             	sub    $0xc,%esp
  8005fd:	25 07 0e 00 00       	and    $0xe07,%eax
  800602:	50                   	push   %eax
  800603:	57                   	push   %edi
  800604:	6a 00                	push   $0x0
  800606:	53                   	push   %ebx
  800607:	6a 00                	push   $0x0
  800609:	e8 03 fc ff ff       	call   800211 <sys_page_map>
  80060e:	89 c3                	mov    %eax,%ebx
  800610:	83 c4 20             	add    $0x20,%esp
  800613:	85 c0                	test   %eax,%eax
  800615:	79 a3                	jns    8005ba <dup+0x78>
	sys_page_unmap(0, newfd);
  800617:	83 ec 08             	sub    $0x8,%esp
  80061a:	56                   	push   %esi
  80061b:	6a 00                	push   $0x0
  80061d:	e8 19 fc ff ff       	call   80023b <sys_page_unmap>
	sys_page_unmap(0, nva);
  800622:	83 c4 08             	add    $0x8,%esp
  800625:	57                   	push   %edi
  800626:	6a 00                	push   $0x0
  800628:	e8 0e fc ff ff       	call   80023b <sys_page_unmap>
	return r;
  80062d:	83 c4 10             	add    $0x10,%esp
  800630:	eb b7                	jmp    8005e9 <dup+0xa7>

00800632 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800632:	f3 0f 1e fb          	endbr32 
  800636:	55                   	push   %ebp
  800637:	89 e5                	mov    %esp,%ebp
  800639:	53                   	push   %ebx
  80063a:	83 ec 1c             	sub    $0x1c,%esp
  80063d:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800640:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800643:	50                   	push   %eax
  800644:	53                   	push   %ebx
  800645:	e8 65 fd ff ff       	call   8003af <fd_lookup>
  80064a:	83 c4 10             	add    $0x10,%esp
  80064d:	85 c0                	test   %eax,%eax
  80064f:	78 3f                	js     800690 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800651:	83 ec 08             	sub    $0x8,%esp
  800654:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800657:	50                   	push   %eax
  800658:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065b:	ff 30                	pushl  (%eax)
  80065d:	e8 a1 fd ff ff       	call   800403 <dev_lookup>
  800662:	83 c4 10             	add    $0x10,%esp
  800665:	85 c0                	test   %eax,%eax
  800667:	78 27                	js     800690 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800669:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80066c:	8b 42 08             	mov    0x8(%edx),%eax
  80066f:	83 e0 03             	and    $0x3,%eax
  800672:	83 f8 01             	cmp    $0x1,%eax
  800675:	74 1e                	je     800695 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800677:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80067a:	8b 40 08             	mov    0x8(%eax),%eax
  80067d:	85 c0                	test   %eax,%eax
  80067f:	74 35                	je     8006b6 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800681:	83 ec 04             	sub    $0x4,%esp
  800684:	ff 75 10             	pushl  0x10(%ebp)
  800687:	ff 75 0c             	pushl  0xc(%ebp)
  80068a:	52                   	push   %edx
  80068b:	ff d0                	call   *%eax
  80068d:	83 c4 10             	add    $0x10,%esp
}
  800690:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800693:	c9                   	leave  
  800694:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800695:	a1 04 40 80 00       	mov    0x804004,%eax
  80069a:	8b 40 48             	mov    0x48(%eax),%eax
  80069d:	83 ec 04             	sub    $0x4,%esp
  8006a0:	53                   	push   %ebx
  8006a1:	50                   	push   %eax
  8006a2:	68 79 1e 80 00       	push   $0x801e79
  8006a7:	e8 aa 0a 00 00       	call   801156 <cprintf>
		return -E_INVAL;
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8006b4:	eb da                	jmp    800690 <read+0x5e>
		return -E_NOT_SUPP;
  8006b6:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8006bb:	eb d3                	jmp    800690 <read+0x5e>

008006bd <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006bd:	f3 0f 1e fb          	endbr32 
  8006c1:	55                   	push   %ebp
  8006c2:	89 e5                	mov    %esp,%ebp
  8006c4:	57                   	push   %edi
  8006c5:	56                   	push   %esi
  8006c6:	53                   	push   %ebx
  8006c7:	83 ec 0c             	sub    $0xc,%esp
  8006ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d5:	eb 02                	jmp    8006d9 <readn+0x1c>
  8006d7:	01 c3                	add    %eax,%ebx
  8006d9:	39 f3                	cmp    %esi,%ebx
  8006db:	73 21                	jae    8006fe <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006dd:	83 ec 04             	sub    $0x4,%esp
  8006e0:	89 f0                	mov    %esi,%eax
  8006e2:	29 d8                	sub    %ebx,%eax
  8006e4:	50                   	push   %eax
  8006e5:	89 d8                	mov    %ebx,%eax
  8006e7:	03 45 0c             	add    0xc(%ebp),%eax
  8006ea:	50                   	push   %eax
  8006eb:	57                   	push   %edi
  8006ec:	e8 41 ff ff ff       	call   800632 <read>
		if (m < 0)
  8006f1:	83 c4 10             	add    $0x10,%esp
  8006f4:	85 c0                	test   %eax,%eax
  8006f6:	78 04                	js     8006fc <readn+0x3f>
			return m;
		if (m == 0)
  8006f8:	75 dd                	jne    8006d7 <readn+0x1a>
  8006fa:	eb 02                	jmp    8006fe <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006fc:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006fe:	89 d8                	mov    %ebx,%eax
  800700:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800703:	5b                   	pop    %ebx
  800704:	5e                   	pop    %esi
  800705:	5f                   	pop    %edi
  800706:	5d                   	pop    %ebp
  800707:	c3                   	ret    

00800708 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800708:	f3 0f 1e fb          	endbr32 
  80070c:	55                   	push   %ebp
  80070d:	89 e5                	mov    %esp,%ebp
  80070f:	53                   	push   %ebx
  800710:	83 ec 1c             	sub    $0x1c,%esp
  800713:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800716:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800719:	50                   	push   %eax
  80071a:	53                   	push   %ebx
  80071b:	e8 8f fc ff ff       	call   8003af <fd_lookup>
  800720:	83 c4 10             	add    $0x10,%esp
  800723:	85 c0                	test   %eax,%eax
  800725:	78 3a                	js     800761 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80072d:	50                   	push   %eax
  80072e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800731:	ff 30                	pushl  (%eax)
  800733:	e8 cb fc ff ff       	call   800403 <dev_lookup>
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	85 c0                	test   %eax,%eax
  80073d:	78 22                	js     800761 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800742:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800746:	74 1e                	je     800766 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800748:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80074b:	8b 52 0c             	mov    0xc(%edx),%edx
  80074e:	85 d2                	test   %edx,%edx
  800750:	74 35                	je     800787 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800752:	83 ec 04             	sub    $0x4,%esp
  800755:	ff 75 10             	pushl  0x10(%ebp)
  800758:	ff 75 0c             	pushl  0xc(%ebp)
  80075b:	50                   	push   %eax
  80075c:	ff d2                	call   *%edx
  80075e:	83 c4 10             	add    $0x10,%esp
}
  800761:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800764:	c9                   	leave  
  800765:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800766:	a1 04 40 80 00       	mov    0x804004,%eax
  80076b:	8b 40 48             	mov    0x48(%eax),%eax
  80076e:	83 ec 04             	sub    $0x4,%esp
  800771:	53                   	push   %ebx
  800772:	50                   	push   %eax
  800773:	68 95 1e 80 00       	push   $0x801e95
  800778:	e8 d9 09 00 00       	call   801156 <cprintf>
		return -E_INVAL;
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800785:	eb da                	jmp    800761 <write+0x59>
		return -E_NOT_SUPP;
  800787:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80078c:	eb d3                	jmp    800761 <write+0x59>

0080078e <seek>:

int
seek(int fdnum, off_t offset)
{
  80078e:	f3 0f 1e fb          	endbr32 
  800792:	55                   	push   %ebp
  800793:	89 e5                	mov    %esp,%ebp
  800795:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800798:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80079b:	50                   	push   %eax
  80079c:	ff 75 08             	pushl  0x8(%ebp)
  80079f:	e8 0b fc ff ff       	call   8003af <fd_lookup>
  8007a4:	83 c4 10             	add    $0x10,%esp
  8007a7:	85 c0                	test   %eax,%eax
  8007a9:	78 0e                	js     8007b9 <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  8007ab:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8007b1:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b9:	c9                   	leave  
  8007ba:	c3                   	ret    

008007bb <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007bb:	f3 0f 1e fb          	endbr32 
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	53                   	push   %ebx
  8007c3:	83 ec 1c             	sub    $0x1c,%esp
  8007c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cc:	50                   	push   %eax
  8007cd:	53                   	push   %ebx
  8007ce:	e8 dc fb ff ff       	call   8003af <fd_lookup>
  8007d3:	83 c4 10             	add    $0x10,%esp
  8007d6:	85 c0                	test   %eax,%eax
  8007d8:	78 37                	js     800811 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007da:	83 ec 08             	sub    $0x8,%esp
  8007dd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e0:	50                   	push   %eax
  8007e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e4:	ff 30                	pushl  (%eax)
  8007e6:	e8 18 fc ff ff       	call   800403 <dev_lookup>
  8007eb:	83 c4 10             	add    $0x10,%esp
  8007ee:	85 c0                	test   %eax,%eax
  8007f0:	78 1f                	js     800811 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f2:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f5:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f9:	74 1b                	je     800816 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007fb:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007fe:	8b 52 18             	mov    0x18(%edx),%edx
  800801:	85 d2                	test   %edx,%edx
  800803:	74 32                	je     800837 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800805:	83 ec 08             	sub    $0x8,%esp
  800808:	ff 75 0c             	pushl  0xc(%ebp)
  80080b:	50                   	push   %eax
  80080c:	ff d2                	call   *%edx
  80080e:	83 c4 10             	add    $0x10,%esp
}
  800811:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800814:	c9                   	leave  
  800815:	c3                   	ret    
			thisenv->env_id, fdnum);
  800816:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  80081b:	8b 40 48             	mov    0x48(%eax),%eax
  80081e:	83 ec 04             	sub    $0x4,%esp
  800821:	53                   	push   %ebx
  800822:	50                   	push   %eax
  800823:	68 58 1e 80 00       	push   $0x801e58
  800828:	e8 29 09 00 00       	call   801156 <cprintf>
		return -E_INVAL;
  80082d:	83 c4 10             	add    $0x10,%esp
  800830:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800835:	eb da                	jmp    800811 <ftruncate+0x56>
		return -E_NOT_SUPP;
  800837:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80083c:	eb d3                	jmp    800811 <ftruncate+0x56>

0080083e <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083e:	f3 0f 1e fb          	endbr32 
  800842:	55                   	push   %ebp
  800843:	89 e5                	mov    %esp,%ebp
  800845:	53                   	push   %ebx
  800846:	83 ec 1c             	sub    $0x1c,%esp
  800849:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80084c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80084f:	50                   	push   %eax
  800850:	ff 75 08             	pushl  0x8(%ebp)
  800853:	e8 57 fb ff ff       	call   8003af <fd_lookup>
  800858:	83 c4 10             	add    $0x10,%esp
  80085b:	85 c0                	test   %eax,%eax
  80085d:	78 4b                	js     8008aa <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085f:	83 ec 08             	sub    $0x8,%esp
  800862:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800865:	50                   	push   %eax
  800866:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800869:	ff 30                	pushl  (%eax)
  80086b:	e8 93 fb ff ff       	call   800403 <dev_lookup>
  800870:	83 c4 10             	add    $0x10,%esp
  800873:	85 c0                	test   %eax,%eax
  800875:	78 33                	js     8008aa <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  800877:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087a:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80087e:	74 2f                	je     8008af <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800880:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800883:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80088a:	00 00 00 
	stat->st_isdir = 0;
  80088d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800894:	00 00 00 
	stat->st_dev = dev;
  800897:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80089d:	83 ec 08             	sub    $0x8,%esp
  8008a0:	53                   	push   %ebx
  8008a1:	ff 75 f0             	pushl  -0x10(%ebp)
  8008a4:	ff 50 14             	call   *0x14(%eax)
  8008a7:	83 c4 10             	add    $0x10,%esp
}
  8008aa:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008ad:	c9                   	leave  
  8008ae:	c3                   	ret    
		return -E_NOT_SUPP;
  8008af:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  8008b4:	eb f4                	jmp    8008aa <fstat+0x6c>

008008b6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008b6:	f3 0f 1e fb          	endbr32 
  8008ba:	55                   	push   %ebp
  8008bb:	89 e5                	mov    %esp,%ebp
  8008bd:	56                   	push   %esi
  8008be:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008bf:	83 ec 08             	sub    $0x8,%esp
  8008c2:	6a 00                	push   $0x0
  8008c4:	ff 75 08             	pushl  0x8(%ebp)
  8008c7:	e8 fb 01 00 00       	call   800ac7 <open>
  8008cc:	89 c3                	mov    %eax,%ebx
  8008ce:	83 c4 10             	add    $0x10,%esp
  8008d1:	85 c0                	test   %eax,%eax
  8008d3:	78 1b                	js     8008f0 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8008d5:	83 ec 08             	sub    $0x8,%esp
  8008d8:	ff 75 0c             	pushl  0xc(%ebp)
  8008db:	50                   	push   %eax
  8008dc:	e8 5d ff ff ff       	call   80083e <fstat>
  8008e1:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e3:	89 1c 24             	mov    %ebx,(%esp)
  8008e6:	e8 fd fb ff ff       	call   8004e8 <close>
	return r;
  8008eb:	83 c4 10             	add    $0x10,%esp
  8008ee:	89 f3                	mov    %esi,%ebx
}
  8008f0:	89 d8                	mov    %ebx,%eax
  8008f2:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f5:	5b                   	pop    %ebx
  8008f6:	5e                   	pop    %esi
  8008f7:	5d                   	pop    %ebp
  8008f8:	c3                   	ret    

008008f9 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008f9:	55                   	push   %ebp
  8008fa:	89 e5                	mov    %esp,%ebp
  8008fc:	56                   	push   %esi
  8008fd:	53                   	push   %ebx
  8008fe:	89 c6                	mov    %eax,%esi
  800900:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800902:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800909:	74 27                	je     800932 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80090b:	6a 07                	push   $0x7
  80090d:	68 00 50 80 00       	push   $0x805000
  800912:	56                   	push   %esi
  800913:	ff 35 00 40 80 00    	pushl  0x804000
  800919:	e8 84 11 00 00       	call   801aa2 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  80091e:	83 c4 0c             	add    $0xc,%esp
  800921:	6a 00                	push   $0x0
  800923:	53                   	push   %ebx
  800924:	6a 00                	push   $0x0
  800926:	e8 09 11 00 00       	call   801a34 <ipc_recv>
}
  80092b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80092e:	5b                   	pop    %ebx
  80092f:	5e                   	pop    %esi
  800930:	5d                   	pop    %ebp
  800931:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800932:	83 ec 0c             	sub    $0xc,%esp
  800935:	6a 01                	push   $0x1
  800937:	e8 cb 11 00 00       	call   801b07 <ipc_find_env>
  80093c:	a3 00 40 80 00       	mov    %eax,0x804000
  800941:	83 c4 10             	add    $0x10,%esp
  800944:	eb c5                	jmp    80090b <fsipc+0x12>

00800946 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800946:	f3 0f 1e fb          	endbr32 
  80094a:	55                   	push   %ebp
  80094b:	89 e5                	mov    %esp,%ebp
  80094d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800950:	8b 45 08             	mov    0x8(%ebp),%eax
  800953:	8b 40 0c             	mov    0xc(%eax),%eax
  800956:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80095b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095e:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800963:	ba 00 00 00 00       	mov    $0x0,%edx
  800968:	b8 02 00 00 00       	mov    $0x2,%eax
  80096d:	e8 87 ff ff ff       	call   8008f9 <fsipc>
}
  800972:	c9                   	leave  
  800973:	c3                   	ret    

00800974 <devfile_flush>:
{
  800974:	f3 0f 1e fb          	endbr32 
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 40 0c             	mov    0xc(%eax),%eax
  800984:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800989:	ba 00 00 00 00       	mov    $0x0,%edx
  80098e:	b8 06 00 00 00       	mov    $0x6,%eax
  800993:	e8 61 ff ff ff       	call   8008f9 <fsipc>
}
  800998:	c9                   	leave  
  800999:	c3                   	ret    

0080099a <devfile_stat>:
{
  80099a:	f3 0f 1e fb          	endbr32 
  80099e:	55                   	push   %ebp
  80099f:	89 e5                	mov    %esp,%ebp
  8009a1:	53                   	push   %ebx
  8009a2:	83 ec 04             	sub    $0x4,%esp
  8009a5:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a8:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ab:	8b 40 0c             	mov    0xc(%eax),%eax
  8009ae:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b3:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b8:	b8 05 00 00 00       	mov    $0x5,%eax
  8009bd:	e8 37 ff ff ff       	call   8008f9 <fsipc>
  8009c2:	85 c0                	test   %eax,%eax
  8009c4:	78 2c                	js     8009f2 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c6:	83 ec 08             	sub    $0x8,%esp
  8009c9:	68 00 50 80 00       	push   $0x805000
  8009ce:	53                   	push   %ebx
  8009cf:	e8 ec 0c 00 00       	call   8016c0 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d4:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d9:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009df:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e4:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009ea:	83 c4 10             	add    $0x10,%esp
  8009ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f5:	c9                   	leave  
  8009f6:	c3                   	ret    

008009f7 <devfile_write>:
{
  8009f7:	f3 0f 1e fb          	endbr32 
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	83 ec 0c             	sub    $0xc,%esp
  800a01:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a04:	8b 55 08             	mov    0x8(%ebp),%edx
  800a07:	8b 52 0c             	mov    0xc(%edx),%edx
  800a0a:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a10:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  800a15:	ba f8 0f 00 00       	mov    $0xff8,%edx
  800a1a:	0f 47 c2             	cmova  %edx,%eax
  800a1d:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800a22:	50                   	push   %eax
  800a23:	ff 75 0c             	pushl  0xc(%ebp)
  800a26:	68 08 50 80 00       	push   $0x805008
  800a2b:	e8 48 0e 00 00       	call   801878 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a30:	ba 00 00 00 00       	mov    $0x0,%edx
  800a35:	b8 04 00 00 00       	mov    $0x4,%eax
  800a3a:	e8 ba fe ff ff       	call   8008f9 <fsipc>
}
  800a3f:	c9                   	leave  
  800a40:	c3                   	ret    

00800a41 <devfile_read>:
{
  800a41:	f3 0f 1e fb          	endbr32 
  800a45:	55                   	push   %ebp
  800a46:	89 e5                	mov    %esp,%ebp
  800a48:	56                   	push   %esi
  800a49:	53                   	push   %ebx
  800a4a:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a4d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a50:	8b 40 0c             	mov    0xc(%eax),%eax
  800a53:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a58:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a5e:	ba 00 00 00 00       	mov    $0x0,%edx
  800a63:	b8 03 00 00 00       	mov    $0x3,%eax
  800a68:	e8 8c fe ff ff       	call   8008f9 <fsipc>
  800a6d:	89 c3                	mov    %eax,%ebx
  800a6f:	85 c0                	test   %eax,%eax
  800a71:	78 1f                	js     800a92 <devfile_read+0x51>
	assert(r <= n);
  800a73:	39 f0                	cmp    %esi,%eax
  800a75:	77 24                	ja     800a9b <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800a77:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a7c:	7f 33                	jg     800ab1 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a7e:	83 ec 04             	sub    $0x4,%esp
  800a81:	50                   	push   %eax
  800a82:	68 00 50 80 00       	push   $0x805000
  800a87:	ff 75 0c             	pushl  0xc(%ebp)
  800a8a:	e8 e9 0d 00 00       	call   801878 <memmove>
	return r;
  800a8f:	83 c4 10             	add    $0x10,%esp
}
  800a92:	89 d8                	mov    %ebx,%eax
  800a94:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a97:	5b                   	pop    %ebx
  800a98:	5e                   	pop    %esi
  800a99:	5d                   	pop    %ebp
  800a9a:	c3                   	ret    
	assert(r <= n);
  800a9b:	68 c4 1e 80 00       	push   $0x801ec4
  800aa0:	68 cb 1e 80 00       	push   $0x801ecb
  800aa5:	6a 7c                	push   $0x7c
  800aa7:	68 e0 1e 80 00       	push   $0x801ee0
  800aac:	e8 be 05 00 00       	call   80106f <_panic>
	assert(r <= PGSIZE);
  800ab1:	68 eb 1e 80 00       	push   $0x801eeb
  800ab6:	68 cb 1e 80 00       	push   $0x801ecb
  800abb:	6a 7d                	push   $0x7d
  800abd:	68 e0 1e 80 00       	push   $0x801ee0
  800ac2:	e8 a8 05 00 00       	call   80106f <_panic>

00800ac7 <open>:
{
  800ac7:	f3 0f 1e fb          	endbr32 
  800acb:	55                   	push   %ebp
  800acc:	89 e5                	mov    %esp,%ebp
  800ace:	56                   	push   %esi
  800acf:	53                   	push   %ebx
  800ad0:	83 ec 1c             	sub    $0x1c,%esp
  800ad3:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800ad6:	56                   	push   %esi
  800ad7:	e8 a1 0b 00 00       	call   80167d <strlen>
  800adc:	83 c4 10             	add    $0x10,%esp
  800adf:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ae4:	7f 6c                	jg     800b52 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800ae6:	83 ec 0c             	sub    $0xc,%esp
  800ae9:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800aec:	50                   	push   %eax
  800aed:	e8 67 f8 ff ff       	call   800359 <fd_alloc>
  800af2:	89 c3                	mov    %eax,%ebx
  800af4:	83 c4 10             	add    $0x10,%esp
  800af7:	85 c0                	test   %eax,%eax
  800af9:	78 3c                	js     800b37 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800afb:	83 ec 08             	sub    $0x8,%esp
  800afe:	56                   	push   %esi
  800aff:	68 00 50 80 00       	push   $0x805000
  800b04:	e8 b7 0b 00 00       	call   8016c0 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b09:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b0c:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b11:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b14:	b8 01 00 00 00       	mov    $0x1,%eax
  800b19:	e8 db fd ff ff       	call   8008f9 <fsipc>
  800b1e:	89 c3                	mov    %eax,%ebx
  800b20:	83 c4 10             	add    $0x10,%esp
  800b23:	85 c0                	test   %eax,%eax
  800b25:	78 19                	js     800b40 <open+0x79>
	return fd2num(fd);
  800b27:	83 ec 0c             	sub    $0xc,%esp
  800b2a:	ff 75 f4             	pushl  -0xc(%ebp)
  800b2d:	e8 f4 f7 ff ff       	call   800326 <fd2num>
  800b32:	89 c3                	mov    %eax,%ebx
  800b34:	83 c4 10             	add    $0x10,%esp
}
  800b37:	89 d8                	mov    %ebx,%eax
  800b39:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b3c:	5b                   	pop    %ebx
  800b3d:	5e                   	pop    %esi
  800b3e:	5d                   	pop    %ebp
  800b3f:	c3                   	ret    
		fd_close(fd, 0);
  800b40:	83 ec 08             	sub    $0x8,%esp
  800b43:	6a 00                	push   $0x0
  800b45:	ff 75 f4             	pushl  -0xc(%ebp)
  800b48:	e8 10 f9 ff ff       	call   80045d <fd_close>
		return r;
  800b4d:	83 c4 10             	add    $0x10,%esp
  800b50:	eb e5                	jmp    800b37 <open+0x70>
		return -E_BAD_PATH;
  800b52:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b57:	eb de                	jmp    800b37 <open+0x70>

00800b59 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b59:	f3 0f 1e fb          	endbr32 
  800b5d:	55                   	push   %ebp
  800b5e:	89 e5                	mov    %esp,%ebp
  800b60:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b63:	ba 00 00 00 00       	mov    $0x0,%edx
  800b68:	b8 08 00 00 00       	mov    $0x8,%eax
  800b6d:	e8 87 fd ff ff       	call   8008f9 <fsipc>
}
  800b72:	c9                   	leave  
  800b73:	c3                   	ret    

00800b74 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b74:	f3 0f 1e fb          	endbr32 
  800b78:	55                   	push   %ebp
  800b79:	89 e5                	mov    %esp,%ebp
  800b7b:	56                   	push   %esi
  800b7c:	53                   	push   %ebx
  800b7d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b80:	83 ec 0c             	sub    $0xc,%esp
  800b83:	ff 75 08             	pushl  0x8(%ebp)
  800b86:	e8 af f7 ff ff       	call   80033a <fd2data>
  800b8b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b8d:	83 c4 08             	add    $0x8,%esp
  800b90:	68 f7 1e 80 00       	push   $0x801ef7
  800b95:	53                   	push   %ebx
  800b96:	e8 25 0b 00 00       	call   8016c0 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b9b:	8b 46 04             	mov    0x4(%esi),%eax
  800b9e:	2b 06                	sub    (%esi),%eax
  800ba0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800ba6:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bad:	00 00 00 
	stat->st_dev = &devpipe;
  800bb0:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bb7:	30 80 00 
	return 0;
}
  800bba:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbf:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bc2:	5b                   	pop    %ebx
  800bc3:	5e                   	pop    %esi
  800bc4:	5d                   	pop    %ebp
  800bc5:	c3                   	ret    

00800bc6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bc6:	f3 0f 1e fb          	endbr32 
  800bca:	55                   	push   %ebp
  800bcb:	89 e5                	mov    %esp,%ebp
  800bcd:	53                   	push   %ebx
  800bce:	83 ec 0c             	sub    $0xc,%esp
  800bd1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bd4:	53                   	push   %ebx
  800bd5:	6a 00                	push   $0x0
  800bd7:	e8 5f f6 ff ff       	call   80023b <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bdc:	89 1c 24             	mov    %ebx,(%esp)
  800bdf:	e8 56 f7 ff ff       	call   80033a <fd2data>
  800be4:	83 c4 08             	add    $0x8,%esp
  800be7:	50                   	push   %eax
  800be8:	6a 00                	push   $0x0
  800bea:	e8 4c f6 ff ff       	call   80023b <sys_page_unmap>
}
  800bef:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bf2:	c9                   	leave  
  800bf3:	c3                   	ret    

00800bf4 <_pipeisclosed>:
{
  800bf4:	55                   	push   %ebp
  800bf5:	89 e5                	mov    %esp,%ebp
  800bf7:	57                   	push   %edi
  800bf8:	56                   	push   %esi
  800bf9:	53                   	push   %ebx
  800bfa:	83 ec 1c             	sub    $0x1c,%esp
  800bfd:	89 c7                	mov    %eax,%edi
  800bff:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800c01:	a1 04 40 80 00       	mov    0x804004,%eax
  800c06:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800c09:	83 ec 0c             	sub    $0xc,%esp
  800c0c:	57                   	push   %edi
  800c0d:	e8 32 0f 00 00       	call   801b44 <pageref>
  800c12:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800c15:	89 34 24             	mov    %esi,(%esp)
  800c18:	e8 27 0f 00 00       	call   801b44 <pageref>
		nn = thisenv->env_runs;
  800c1d:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c23:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c26:	83 c4 10             	add    $0x10,%esp
  800c29:	39 cb                	cmp    %ecx,%ebx
  800c2b:	74 1b                	je     800c48 <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c2d:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c30:	75 cf                	jne    800c01 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c32:	8b 42 58             	mov    0x58(%edx),%eax
  800c35:	6a 01                	push   $0x1
  800c37:	50                   	push   %eax
  800c38:	53                   	push   %ebx
  800c39:	68 fe 1e 80 00       	push   $0x801efe
  800c3e:	e8 13 05 00 00       	call   801156 <cprintf>
  800c43:	83 c4 10             	add    $0x10,%esp
  800c46:	eb b9                	jmp    800c01 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c48:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c4b:	0f 94 c0             	sete   %al
  800c4e:	0f b6 c0             	movzbl %al,%eax
}
  800c51:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c54:	5b                   	pop    %ebx
  800c55:	5e                   	pop    %esi
  800c56:	5f                   	pop    %edi
  800c57:	5d                   	pop    %ebp
  800c58:	c3                   	ret    

00800c59 <devpipe_write>:
{
  800c59:	f3 0f 1e fb          	endbr32 
  800c5d:	55                   	push   %ebp
  800c5e:	89 e5                	mov    %esp,%ebp
  800c60:	57                   	push   %edi
  800c61:	56                   	push   %esi
  800c62:	53                   	push   %ebx
  800c63:	83 ec 28             	sub    $0x28,%esp
  800c66:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c69:	56                   	push   %esi
  800c6a:	e8 cb f6 ff ff       	call   80033a <fd2data>
  800c6f:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c71:	83 c4 10             	add    $0x10,%esp
  800c74:	bf 00 00 00 00       	mov    $0x0,%edi
  800c79:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c7c:	74 4f                	je     800ccd <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c7e:	8b 43 04             	mov    0x4(%ebx),%eax
  800c81:	8b 0b                	mov    (%ebx),%ecx
  800c83:	8d 51 20             	lea    0x20(%ecx),%edx
  800c86:	39 d0                	cmp    %edx,%eax
  800c88:	72 14                	jb     800c9e <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800c8a:	89 da                	mov    %ebx,%edx
  800c8c:	89 f0                	mov    %esi,%eax
  800c8e:	e8 61 ff ff ff       	call   800bf4 <_pipeisclosed>
  800c93:	85 c0                	test   %eax,%eax
  800c95:	75 3b                	jne    800cd2 <devpipe_write+0x79>
			sys_yield();
  800c97:	e8 22 f5 ff ff       	call   8001be <sys_yield>
  800c9c:	eb e0                	jmp    800c7e <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c9e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800ca1:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800ca5:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ca8:	89 c2                	mov    %eax,%edx
  800caa:	c1 fa 1f             	sar    $0x1f,%edx
  800cad:	89 d1                	mov    %edx,%ecx
  800caf:	c1 e9 1b             	shr    $0x1b,%ecx
  800cb2:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cb5:	83 e2 1f             	and    $0x1f,%edx
  800cb8:	29 ca                	sub    %ecx,%edx
  800cba:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cbe:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cc2:	83 c0 01             	add    $0x1,%eax
  800cc5:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800cc8:	83 c7 01             	add    $0x1,%edi
  800ccb:	eb ac                	jmp    800c79 <devpipe_write+0x20>
	return i;
  800ccd:	8b 45 10             	mov    0x10(%ebp),%eax
  800cd0:	eb 05                	jmp    800cd7 <devpipe_write+0x7e>
				return 0;
  800cd2:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cd7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cda:	5b                   	pop    %ebx
  800cdb:	5e                   	pop    %esi
  800cdc:	5f                   	pop    %edi
  800cdd:	5d                   	pop    %ebp
  800cde:	c3                   	ret    

00800cdf <devpipe_read>:
{
  800cdf:	f3 0f 1e fb          	endbr32 
  800ce3:	55                   	push   %ebp
  800ce4:	89 e5                	mov    %esp,%ebp
  800ce6:	57                   	push   %edi
  800ce7:	56                   	push   %esi
  800ce8:	53                   	push   %ebx
  800ce9:	83 ec 18             	sub    $0x18,%esp
  800cec:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800cef:	57                   	push   %edi
  800cf0:	e8 45 f6 ff ff       	call   80033a <fd2data>
  800cf5:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cf7:	83 c4 10             	add    $0x10,%esp
  800cfa:	be 00 00 00 00       	mov    $0x0,%esi
  800cff:	3b 75 10             	cmp    0x10(%ebp),%esi
  800d02:	75 14                	jne    800d18 <devpipe_read+0x39>
	return i;
  800d04:	8b 45 10             	mov    0x10(%ebp),%eax
  800d07:	eb 02                	jmp    800d0b <devpipe_read+0x2c>
				return i;
  800d09:	89 f0                	mov    %esi,%eax
}
  800d0b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d0e:	5b                   	pop    %ebx
  800d0f:	5e                   	pop    %esi
  800d10:	5f                   	pop    %edi
  800d11:	5d                   	pop    %ebp
  800d12:	c3                   	ret    
			sys_yield();
  800d13:	e8 a6 f4 ff ff       	call   8001be <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800d18:	8b 03                	mov    (%ebx),%eax
  800d1a:	3b 43 04             	cmp    0x4(%ebx),%eax
  800d1d:	75 18                	jne    800d37 <devpipe_read+0x58>
			if (i > 0)
  800d1f:	85 f6                	test   %esi,%esi
  800d21:	75 e6                	jne    800d09 <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d23:	89 da                	mov    %ebx,%edx
  800d25:	89 f8                	mov    %edi,%eax
  800d27:	e8 c8 fe ff ff       	call   800bf4 <_pipeisclosed>
  800d2c:	85 c0                	test   %eax,%eax
  800d2e:	74 e3                	je     800d13 <devpipe_read+0x34>
				return 0;
  800d30:	b8 00 00 00 00       	mov    $0x0,%eax
  800d35:	eb d4                	jmp    800d0b <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d37:	99                   	cltd   
  800d38:	c1 ea 1b             	shr    $0x1b,%edx
  800d3b:	01 d0                	add    %edx,%eax
  800d3d:	83 e0 1f             	and    $0x1f,%eax
  800d40:	29 d0                	sub    %edx,%eax
  800d42:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d47:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d4a:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d4d:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d50:	83 c6 01             	add    $0x1,%esi
  800d53:	eb aa                	jmp    800cff <devpipe_read+0x20>

00800d55 <pipe>:
{
  800d55:	f3 0f 1e fb          	endbr32 
  800d59:	55                   	push   %ebp
  800d5a:	89 e5                	mov    %esp,%ebp
  800d5c:	56                   	push   %esi
  800d5d:	53                   	push   %ebx
  800d5e:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d61:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d64:	50                   	push   %eax
  800d65:	e8 ef f5 ff ff       	call   800359 <fd_alloc>
  800d6a:	89 c3                	mov    %eax,%ebx
  800d6c:	83 c4 10             	add    $0x10,%esp
  800d6f:	85 c0                	test   %eax,%eax
  800d71:	0f 88 23 01 00 00    	js     800e9a <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d77:	83 ec 04             	sub    $0x4,%esp
  800d7a:	68 07 04 00 00       	push   $0x407
  800d7f:	ff 75 f4             	pushl  -0xc(%ebp)
  800d82:	6a 00                	push   $0x0
  800d84:	e8 60 f4 ff ff       	call   8001e9 <sys_page_alloc>
  800d89:	89 c3                	mov    %eax,%ebx
  800d8b:	83 c4 10             	add    $0x10,%esp
  800d8e:	85 c0                	test   %eax,%eax
  800d90:	0f 88 04 01 00 00    	js     800e9a <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800d96:	83 ec 0c             	sub    $0xc,%esp
  800d99:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d9c:	50                   	push   %eax
  800d9d:	e8 b7 f5 ff ff       	call   800359 <fd_alloc>
  800da2:	89 c3                	mov    %eax,%ebx
  800da4:	83 c4 10             	add    $0x10,%esp
  800da7:	85 c0                	test   %eax,%eax
  800da9:	0f 88 db 00 00 00    	js     800e8a <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800daf:	83 ec 04             	sub    $0x4,%esp
  800db2:	68 07 04 00 00       	push   $0x407
  800db7:	ff 75 f0             	pushl  -0x10(%ebp)
  800dba:	6a 00                	push   $0x0
  800dbc:	e8 28 f4 ff ff       	call   8001e9 <sys_page_alloc>
  800dc1:	89 c3                	mov    %eax,%ebx
  800dc3:	83 c4 10             	add    $0x10,%esp
  800dc6:	85 c0                	test   %eax,%eax
  800dc8:	0f 88 bc 00 00 00    	js     800e8a <pipe+0x135>
	va = fd2data(fd0);
  800dce:	83 ec 0c             	sub    $0xc,%esp
  800dd1:	ff 75 f4             	pushl  -0xc(%ebp)
  800dd4:	e8 61 f5 ff ff       	call   80033a <fd2data>
  800dd9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800ddb:	83 c4 0c             	add    $0xc,%esp
  800dde:	68 07 04 00 00       	push   $0x407
  800de3:	50                   	push   %eax
  800de4:	6a 00                	push   $0x0
  800de6:	e8 fe f3 ff ff       	call   8001e9 <sys_page_alloc>
  800deb:	89 c3                	mov    %eax,%ebx
  800ded:	83 c4 10             	add    $0x10,%esp
  800df0:	85 c0                	test   %eax,%eax
  800df2:	0f 88 82 00 00 00    	js     800e7a <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800df8:	83 ec 0c             	sub    $0xc,%esp
  800dfb:	ff 75 f0             	pushl  -0x10(%ebp)
  800dfe:	e8 37 f5 ff ff       	call   80033a <fd2data>
  800e03:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800e0a:	50                   	push   %eax
  800e0b:	6a 00                	push   $0x0
  800e0d:	56                   	push   %esi
  800e0e:	6a 00                	push   $0x0
  800e10:	e8 fc f3 ff ff       	call   800211 <sys_page_map>
  800e15:	89 c3                	mov    %eax,%ebx
  800e17:	83 c4 20             	add    $0x20,%esp
  800e1a:	85 c0                	test   %eax,%eax
  800e1c:	78 4e                	js     800e6c <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e1e:	a1 20 30 80 00       	mov    0x803020,%eax
  800e23:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e26:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e28:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e2b:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e32:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e35:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e37:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e3a:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e41:	83 ec 0c             	sub    $0xc,%esp
  800e44:	ff 75 f4             	pushl  -0xc(%ebp)
  800e47:	e8 da f4 ff ff       	call   800326 <fd2num>
  800e4c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e4f:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e51:	83 c4 04             	add    $0x4,%esp
  800e54:	ff 75 f0             	pushl  -0x10(%ebp)
  800e57:	e8 ca f4 ff ff       	call   800326 <fd2num>
  800e5c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e5f:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e62:	83 c4 10             	add    $0x10,%esp
  800e65:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e6a:	eb 2e                	jmp    800e9a <pipe+0x145>
	sys_page_unmap(0, va);
  800e6c:	83 ec 08             	sub    $0x8,%esp
  800e6f:	56                   	push   %esi
  800e70:	6a 00                	push   $0x0
  800e72:	e8 c4 f3 ff ff       	call   80023b <sys_page_unmap>
  800e77:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e7a:	83 ec 08             	sub    $0x8,%esp
  800e7d:	ff 75 f0             	pushl  -0x10(%ebp)
  800e80:	6a 00                	push   $0x0
  800e82:	e8 b4 f3 ff ff       	call   80023b <sys_page_unmap>
  800e87:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800e8a:	83 ec 08             	sub    $0x8,%esp
  800e8d:	ff 75 f4             	pushl  -0xc(%ebp)
  800e90:	6a 00                	push   $0x0
  800e92:	e8 a4 f3 ff ff       	call   80023b <sys_page_unmap>
  800e97:	83 c4 10             	add    $0x10,%esp
}
  800e9a:	89 d8                	mov    %ebx,%eax
  800e9c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e9f:	5b                   	pop    %ebx
  800ea0:	5e                   	pop    %esi
  800ea1:	5d                   	pop    %ebp
  800ea2:	c3                   	ret    

00800ea3 <pipeisclosed>:
{
  800ea3:	f3 0f 1e fb          	endbr32 
  800ea7:	55                   	push   %ebp
  800ea8:	89 e5                	mov    %esp,%ebp
  800eaa:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ead:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800eb0:	50                   	push   %eax
  800eb1:	ff 75 08             	pushl  0x8(%ebp)
  800eb4:	e8 f6 f4 ff ff       	call   8003af <fd_lookup>
  800eb9:	83 c4 10             	add    $0x10,%esp
  800ebc:	85 c0                	test   %eax,%eax
  800ebe:	78 18                	js     800ed8 <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800ec0:	83 ec 0c             	sub    $0xc,%esp
  800ec3:	ff 75 f4             	pushl  -0xc(%ebp)
  800ec6:	e8 6f f4 ff ff       	call   80033a <fd2data>
  800ecb:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800ecd:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ed0:	e8 1f fd ff ff       	call   800bf4 <_pipeisclosed>
  800ed5:	83 c4 10             	add    $0x10,%esp
}
  800ed8:	c9                   	leave  
  800ed9:	c3                   	ret    

00800eda <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eda:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800ede:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee3:	c3                   	ret    

00800ee4 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ee4:	f3 0f 1e fb          	endbr32 
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800eee:	68 16 1f 80 00       	push   $0x801f16
  800ef3:	ff 75 0c             	pushl  0xc(%ebp)
  800ef6:	e8 c5 07 00 00       	call   8016c0 <strcpy>
	return 0;
}
  800efb:	b8 00 00 00 00       	mov    $0x0,%eax
  800f00:	c9                   	leave  
  800f01:	c3                   	ret    

00800f02 <devcons_write>:
{
  800f02:	f3 0f 1e fb          	endbr32 
  800f06:	55                   	push   %ebp
  800f07:	89 e5                	mov    %esp,%ebp
  800f09:	57                   	push   %edi
  800f0a:	56                   	push   %esi
  800f0b:	53                   	push   %ebx
  800f0c:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800f12:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800f17:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800f1d:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f20:	73 31                	jae    800f53 <devcons_write+0x51>
		m = n - tot;
  800f22:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f25:	29 f3                	sub    %esi,%ebx
  800f27:	83 fb 7f             	cmp    $0x7f,%ebx
  800f2a:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f2f:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f32:	83 ec 04             	sub    $0x4,%esp
  800f35:	53                   	push   %ebx
  800f36:	89 f0                	mov    %esi,%eax
  800f38:	03 45 0c             	add    0xc(%ebp),%eax
  800f3b:	50                   	push   %eax
  800f3c:	57                   	push   %edi
  800f3d:	e8 36 09 00 00       	call   801878 <memmove>
		sys_cputs(buf, m);
  800f42:	83 c4 08             	add    $0x8,%esp
  800f45:	53                   	push   %ebx
  800f46:	57                   	push   %edi
  800f47:	e8 d2 f1 ff ff       	call   80011e <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f4c:	01 de                	add    %ebx,%esi
  800f4e:	83 c4 10             	add    $0x10,%esp
  800f51:	eb ca                	jmp    800f1d <devcons_write+0x1b>
}
  800f53:	89 f0                	mov    %esi,%eax
  800f55:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f58:	5b                   	pop    %ebx
  800f59:	5e                   	pop    %esi
  800f5a:	5f                   	pop    %edi
  800f5b:	5d                   	pop    %ebp
  800f5c:	c3                   	ret    

00800f5d <devcons_read>:
{
  800f5d:	f3 0f 1e fb          	endbr32 
  800f61:	55                   	push   %ebp
  800f62:	89 e5                	mov    %esp,%ebp
  800f64:	83 ec 08             	sub    $0x8,%esp
  800f67:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f6c:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f70:	74 21                	je     800f93 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800f72:	e8 d1 f1 ff ff       	call   800148 <sys_cgetc>
  800f77:	85 c0                	test   %eax,%eax
  800f79:	75 07                	jne    800f82 <devcons_read+0x25>
		sys_yield();
  800f7b:	e8 3e f2 ff ff       	call   8001be <sys_yield>
  800f80:	eb f0                	jmp    800f72 <devcons_read+0x15>
	if (c < 0)
  800f82:	78 0f                	js     800f93 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800f84:	83 f8 04             	cmp    $0x4,%eax
  800f87:	74 0c                	je     800f95 <devcons_read+0x38>
	*(char*)vbuf = c;
  800f89:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f8c:	88 02                	mov    %al,(%edx)
	return 1;
  800f8e:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800f93:	c9                   	leave  
  800f94:	c3                   	ret    
		return 0;
  800f95:	b8 00 00 00 00       	mov    $0x0,%eax
  800f9a:	eb f7                	jmp    800f93 <devcons_read+0x36>

00800f9c <cputchar>:
{
  800f9c:	f3 0f 1e fb          	endbr32 
  800fa0:	55                   	push   %ebp
  800fa1:	89 e5                	mov    %esp,%ebp
  800fa3:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800fa6:	8b 45 08             	mov    0x8(%ebp),%eax
  800fa9:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800fac:	6a 01                	push   $0x1
  800fae:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fb1:	50                   	push   %eax
  800fb2:	e8 67 f1 ff ff       	call   80011e <sys_cputs>
}
  800fb7:	83 c4 10             	add    $0x10,%esp
  800fba:	c9                   	leave  
  800fbb:	c3                   	ret    

00800fbc <getchar>:
{
  800fbc:	f3 0f 1e fb          	endbr32 
  800fc0:	55                   	push   %ebp
  800fc1:	89 e5                	mov    %esp,%ebp
  800fc3:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800fc6:	6a 01                	push   $0x1
  800fc8:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fcb:	50                   	push   %eax
  800fcc:	6a 00                	push   $0x0
  800fce:	e8 5f f6 ff ff       	call   800632 <read>
	if (r < 0)
  800fd3:	83 c4 10             	add    $0x10,%esp
  800fd6:	85 c0                	test   %eax,%eax
  800fd8:	78 06                	js     800fe0 <getchar+0x24>
	if (r < 1)
  800fda:	74 06                	je     800fe2 <getchar+0x26>
	return c;
  800fdc:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800fe0:	c9                   	leave  
  800fe1:	c3                   	ret    
		return -E_EOF;
  800fe2:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800fe7:	eb f7                	jmp    800fe0 <getchar+0x24>

00800fe9 <iscons>:
{
  800fe9:	f3 0f 1e fb          	endbr32 
  800fed:	55                   	push   %ebp
  800fee:	89 e5                	mov    %esp,%ebp
  800ff0:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ff3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ff6:	50                   	push   %eax
  800ff7:	ff 75 08             	pushl  0x8(%ebp)
  800ffa:	e8 b0 f3 ff ff       	call   8003af <fd_lookup>
  800fff:	83 c4 10             	add    $0x10,%esp
  801002:	85 c0                	test   %eax,%eax
  801004:	78 11                	js     801017 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  801006:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801009:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80100f:	39 10                	cmp    %edx,(%eax)
  801011:	0f 94 c0             	sete   %al
  801014:	0f b6 c0             	movzbl %al,%eax
}
  801017:	c9                   	leave  
  801018:	c3                   	ret    

00801019 <opencons>:
{
  801019:	f3 0f 1e fb          	endbr32 
  80101d:	55                   	push   %ebp
  80101e:	89 e5                	mov    %esp,%ebp
  801020:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801023:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801026:	50                   	push   %eax
  801027:	e8 2d f3 ff ff       	call   800359 <fd_alloc>
  80102c:	83 c4 10             	add    $0x10,%esp
  80102f:	85 c0                	test   %eax,%eax
  801031:	78 3a                	js     80106d <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801033:	83 ec 04             	sub    $0x4,%esp
  801036:	68 07 04 00 00       	push   $0x407
  80103b:	ff 75 f4             	pushl  -0xc(%ebp)
  80103e:	6a 00                	push   $0x0
  801040:	e8 a4 f1 ff ff       	call   8001e9 <sys_page_alloc>
  801045:	83 c4 10             	add    $0x10,%esp
  801048:	85 c0                	test   %eax,%eax
  80104a:	78 21                	js     80106d <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80104c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80104f:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801055:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801057:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80105a:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801061:	83 ec 0c             	sub    $0xc,%esp
  801064:	50                   	push   %eax
  801065:	e8 bc f2 ff ff       	call   800326 <fd2num>
  80106a:	83 c4 10             	add    $0x10,%esp
}
  80106d:	c9                   	leave  
  80106e:	c3                   	ret    

0080106f <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80106f:	f3 0f 1e fb          	endbr32 
  801073:	55                   	push   %ebp
  801074:	89 e5                	mov    %esp,%ebp
  801076:	56                   	push   %esi
  801077:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801078:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80107b:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801081:	e8 10 f1 ff ff       	call   800196 <sys_getenvid>
  801086:	83 ec 0c             	sub    $0xc,%esp
  801089:	ff 75 0c             	pushl  0xc(%ebp)
  80108c:	ff 75 08             	pushl  0x8(%ebp)
  80108f:	56                   	push   %esi
  801090:	50                   	push   %eax
  801091:	68 24 1f 80 00       	push   $0x801f24
  801096:	e8 bb 00 00 00       	call   801156 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80109b:	83 c4 18             	add    $0x18,%esp
  80109e:	53                   	push   %ebx
  80109f:	ff 75 10             	pushl  0x10(%ebp)
  8010a2:	e8 5a 00 00 00       	call   801101 <vcprintf>
	cprintf("\n");
  8010a7:	c7 04 24 0f 1f 80 00 	movl   $0x801f0f,(%esp)
  8010ae:	e8 a3 00 00 00       	call   801156 <cprintf>
  8010b3:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  8010b6:	cc                   	int3   
  8010b7:	eb fd                	jmp    8010b6 <_panic+0x47>

008010b9 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  8010b9:	f3 0f 1e fb          	endbr32 
  8010bd:	55                   	push   %ebp
  8010be:	89 e5                	mov    %esp,%ebp
  8010c0:	53                   	push   %ebx
  8010c1:	83 ec 04             	sub    $0x4,%esp
  8010c4:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010c7:	8b 13                	mov    (%ebx),%edx
  8010c9:	8d 42 01             	lea    0x1(%edx),%eax
  8010cc:	89 03                	mov    %eax,(%ebx)
  8010ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010d1:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010d5:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010da:	74 09                	je     8010e5 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8010dc:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010e0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010e3:	c9                   	leave  
  8010e4:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8010e5:	83 ec 08             	sub    $0x8,%esp
  8010e8:	68 ff 00 00 00       	push   $0xff
  8010ed:	8d 43 08             	lea    0x8(%ebx),%eax
  8010f0:	50                   	push   %eax
  8010f1:	e8 28 f0 ff ff       	call   80011e <sys_cputs>
		b->idx = 0;
  8010f6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010fc:	83 c4 10             	add    $0x10,%esp
  8010ff:	eb db                	jmp    8010dc <putch+0x23>

00801101 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  801101:	f3 0f 1e fb          	endbr32 
  801105:	55                   	push   %ebp
  801106:	89 e5                	mov    %esp,%ebp
  801108:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  80110e:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  801115:	00 00 00 
	b.cnt = 0;
  801118:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  80111f:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801122:	ff 75 0c             	pushl  0xc(%ebp)
  801125:	ff 75 08             	pushl  0x8(%ebp)
  801128:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  80112e:	50                   	push   %eax
  80112f:	68 b9 10 80 00       	push   $0x8010b9
  801134:	e8 80 01 00 00       	call   8012b9 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801139:	83 c4 08             	add    $0x8,%esp
  80113c:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801142:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801148:	50                   	push   %eax
  801149:	e8 d0 ef ff ff       	call   80011e <sys_cputs>

	return b.cnt;
}
  80114e:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801154:	c9                   	leave  
  801155:	c3                   	ret    

00801156 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801156:	f3 0f 1e fb          	endbr32 
  80115a:	55                   	push   %ebp
  80115b:	89 e5                	mov    %esp,%ebp
  80115d:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801160:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801163:	50                   	push   %eax
  801164:	ff 75 08             	pushl  0x8(%ebp)
  801167:	e8 95 ff ff ff       	call   801101 <vcprintf>
	va_end(ap);

	return cnt;
}
  80116c:	c9                   	leave  
  80116d:	c3                   	ret    

0080116e <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80116e:	55                   	push   %ebp
  80116f:	89 e5                	mov    %esp,%ebp
  801171:	57                   	push   %edi
  801172:	56                   	push   %esi
  801173:	53                   	push   %ebx
  801174:	83 ec 1c             	sub    $0x1c,%esp
  801177:	89 c7                	mov    %eax,%edi
  801179:	89 d6                	mov    %edx,%esi
  80117b:	8b 45 08             	mov    0x8(%ebp),%eax
  80117e:	8b 55 0c             	mov    0xc(%ebp),%edx
  801181:	89 d1                	mov    %edx,%ecx
  801183:	89 c2                	mov    %eax,%edx
  801185:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801188:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80118b:	8b 45 10             	mov    0x10(%ebp),%eax
  80118e:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801191:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801194:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80119b:	39 c2                	cmp    %eax,%edx
  80119d:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  8011a0:	72 3e                	jb     8011e0 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  8011a2:	83 ec 0c             	sub    $0xc,%esp
  8011a5:	ff 75 18             	pushl  0x18(%ebp)
  8011a8:	83 eb 01             	sub    $0x1,%ebx
  8011ab:	53                   	push   %ebx
  8011ac:	50                   	push   %eax
  8011ad:	83 ec 08             	sub    $0x8,%esp
  8011b0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b3:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b6:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b9:	ff 75 d8             	pushl  -0x28(%ebp)
  8011bc:	e8 cf 09 00 00       	call   801b90 <__udivdi3>
  8011c1:	83 c4 18             	add    $0x18,%esp
  8011c4:	52                   	push   %edx
  8011c5:	50                   	push   %eax
  8011c6:	89 f2                	mov    %esi,%edx
  8011c8:	89 f8                	mov    %edi,%eax
  8011ca:	e8 9f ff ff ff       	call   80116e <printnum>
  8011cf:	83 c4 20             	add    $0x20,%esp
  8011d2:	eb 13                	jmp    8011e7 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011d4:	83 ec 08             	sub    $0x8,%esp
  8011d7:	56                   	push   %esi
  8011d8:	ff 75 18             	pushl  0x18(%ebp)
  8011db:	ff d7                	call   *%edi
  8011dd:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8011e0:	83 eb 01             	sub    $0x1,%ebx
  8011e3:	85 db                	test   %ebx,%ebx
  8011e5:	7f ed                	jg     8011d4 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011e7:	83 ec 08             	sub    $0x8,%esp
  8011ea:	56                   	push   %esi
  8011eb:	83 ec 04             	sub    $0x4,%esp
  8011ee:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011f1:	ff 75 e0             	pushl  -0x20(%ebp)
  8011f4:	ff 75 dc             	pushl  -0x24(%ebp)
  8011f7:	ff 75 d8             	pushl  -0x28(%ebp)
  8011fa:	e8 a1 0a 00 00       	call   801ca0 <__umoddi3>
  8011ff:	83 c4 14             	add    $0x14,%esp
  801202:	0f be 80 47 1f 80 00 	movsbl 0x801f47(%eax),%eax
  801209:	50                   	push   %eax
  80120a:	ff d7                	call   *%edi
}
  80120c:	83 c4 10             	add    $0x10,%esp
  80120f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801212:	5b                   	pop    %ebx
  801213:	5e                   	pop    %esi
  801214:	5f                   	pop    %edi
  801215:	5d                   	pop    %ebp
  801216:	c3                   	ret    

00801217 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  801217:	83 fa 01             	cmp    $0x1,%edx
  80121a:	7f 13                	jg     80122f <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  80121c:	85 d2                	test   %edx,%edx
  80121e:	74 1c                	je     80123c <getuint+0x25>
		return va_arg(*ap, unsigned long);
  801220:	8b 10                	mov    (%eax),%edx
  801222:	8d 4a 04             	lea    0x4(%edx),%ecx
  801225:	89 08                	mov    %ecx,(%eax)
  801227:	8b 02                	mov    (%edx),%eax
  801229:	ba 00 00 00 00       	mov    $0x0,%edx
  80122e:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  80122f:	8b 10                	mov    (%eax),%edx
  801231:	8d 4a 08             	lea    0x8(%edx),%ecx
  801234:	89 08                	mov    %ecx,(%eax)
  801236:	8b 02                	mov    (%edx),%eax
  801238:	8b 52 04             	mov    0x4(%edx),%edx
  80123b:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  80123c:	8b 10                	mov    (%eax),%edx
  80123e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801241:	89 08                	mov    %ecx,(%eax)
  801243:	8b 02                	mov    (%edx),%eax
  801245:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80124a:	c3                   	ret    

0080124b <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80124b:	83 fa 01             	cmp    $0x1,%edx
  80124e:	7f 0f                	jg     80125f <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  801250:	85 d2                	test   %edx,%edx
  801252:	74 18                	je     80126c <getint+0x21>
		return va_arg(*ap, long);
  801254:	8b 10                	mov    (%eax),%edx
  801256:	8d 4a 04             	lea    0x4(%edx),%ecx
  801259:	89 08                	mov    %ecx,(%eax)
  80125b:	8b 02                	mov    (%edx),%eax
  80125d:	99                   	cltd   
  80125e:	c3                   	ret    
		return va_arg(*ap, long long);
  80125f:	8b 10                	mov    (%eax),%edx
  801261:	8d 4a 08             	lea    0x8(%edx),%ecx
  801264:	89 08                	mov    %ecx,(%eax)
  801266:	8b 02                	mov    (%edx),%eax
  801268:	8b 52 04             	mov    0x4(%edx),%edx
  80126b:	c3                   	ret    
	else
		return va_arg(*ap, int);
  80126c:	8b 10                	mov    (%eax),%edx
  80126e:	8d 4a 04             	lea    0x4(%edx),%ecx
  801271:	89 08                	mov    %ecx,(%eax)
  801273:	8b 02                	mov    (%edx),%eax
  801275:	99                   	cltd   
}
  801276:	c3                   	ret    

00801277 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801277:	f3 0f 1e fb          	endbr32 
  80127b:	55                   	push   %ebp
  80127c:	89 e5                	mov    %esp,%ebp
  80127e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801281:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801285:	8b 10                	mov    (%eax),%edx
  801287:	3b 50 04             	cmp    0x4(%eax),%edx
  80128a:	73 0a                	jae    801296 <sprintputch+0x1f>
		*b->buf++ = ch;
  80128c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80128f:	89 08                	mov    %ecx,(%eax)
  801291:	8b 45 08             	mov    0x8(%ebp),%eax
  801294:	88 02                	mov    %al,(%edx)
}
  801296:	5d                   	pop    %ebp
  801297:	c3                   	ret    

00801298 <printfmt>:
{
  801298:	f3 0f 1e fb          	endbr32 
  80129c:	55                   	push   %ebp
  80129d:	89 e5                	mov    %esp,%ebp
  80129f:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  8012a2:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8012a5:	50                   	push   %eax
  8012a6:	ff 75 10             	pushl  0x10(%ebp)
  8012a9:	ff 75 0c             	pushl  0xc(%ebp)
  8012ac:	ff 75 08             	pushl  0x8(%ebp)
  8012af:	e8 05 00 00 00       	call   8012b9 <vprintfmt>
}
  8012b4:	83 c4 10             	add    $0x10,%esp
  8012b7:	c9                   	leave  
  8012b8:	c3                   	ret    

008012b9 <vprintfmt>:
{
  8012b9:	f3 0f 1e fb          	endbr32 
  8012bd:	55                   	push   %ebp
  8012be:	89 e5                	mov    %esp,%ebp
  8012c0:	57                   	push   %edi
  8012c1:	56                   	push   %esi
  8012c2:	53                   	push   %ebx
  8012c3:	83 ec 2c             	sub    $0x2c,%esp
  8012c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012c9:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012cc:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012cf:	e9 86 02 00 00       	jmp    80155a <vprintfmt+0x2a1>
		padc = ' ';
  8012d4:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012d8:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012df:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012e6:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012ed:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012f2:	8d 47 01             	lea    0x1(%edi),%eax
  8012f5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012f8:	0f b6 17             	movzbl (%edi),%edx
  8012fb:	8d 42 dd             	lea    -0x23(%edx),%eax
  8012fe:	3c 55                	cmp    $0x55,%al
  801300:	0f 87 df 02 00 00    	ja     8015e5 <vprintfmt+0x32c>
  801306:	0f b6 c0             	movzbl %al,%eax
  801309:	3e ff 24 85 80 20 80 	notrack jmp *0x802080(,%eax,4)
  801310:	00 
  801311:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  801314:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  801318:	eb d8                	jmp    8012f2 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  80131a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80131d:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801321:	eb cf                	jmp    8012f2 <vprintfmt+0x39>
  801323:	0f b6 d2             	movzbl %dl,%edx
  801326:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  801329:	b8 00 00 00 00       	mov    $0x0,%eax
  80132e:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801331:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801334:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  801338:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80133b:	8d 4a d0             	lea    -0x30(%edx),%ecx
  80133e:	83 f9 09             	cmp    $0x9,%ecx
  801341:	77 52                	ja     801395 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  801343:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801346:	eb e9                	jmp    801331 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  801348:	8b 45 14             	mov    0x14(%ebp),%eax
  80134b:	8d 50 04             	lea    0x4(%eax),%edx
  80134e:	89 55 14             	mov    %edx,0x14(%ebp)
  801351:	8b 00                	mov    (%eax),%eax
  801353:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801356:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  801359:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80135d:	79 93                	jns    8012f2 <vprintfmt+0x39>
				width = precision, precision = -1;
  80135f:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801362:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801365:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80136c:	eb 84                	jmp    8012f2 <vprintfmt+0x39>
  80136e:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801371:	85 c0                	test   %eax,%eax
  801373:	ba 00 00 00 00       	mov    $0x0,%edx
  801378:	0f 49 d0             	cmovns %eax,%edx
  80137b:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  80137e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801381:	e9 6c ff ff ff       	jmp    8012f2 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801386:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  801389:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801390:	e9 5d ff ff ff       	jmp    8012f2 <vprintfmt+0x39>
  801395:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801398:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80139b:	eb bc                	jmp    801359 <vprintfmt+0xa0>
			lflag++;
  80139d:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8013a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  8013a3:	e9 4a ff ff ff       	jmp    8012f2 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  8013a8:	8b 45 14             	mov    0x14(%ebp),%eax
  8013ab:	8d 50 04             	lea    0x4(%eax),%edx
  8013ae:	89 55 14             	mov    %edx,0x14(%ebp)
  8013b1:	83 ec 08             	sub    $0x8,%esp
  8013b4:	56                   	push   %esi
  8013b5:	ff 30                	pushl  (%eax)
  8013b7:	ff d3                	call   *%ebx
			break;
  8013b9:	83 c4 10             	add    $0x10,%esp
  8013bc:	e9 96 01 00 00       	jmp    801557 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8013c1:	8b 45 14             	mov    0x14(%ebp),%eax
  8013c4:	8d 50 04             	lea    0x4(%eax),%edx
  8013c7:	89 55 14             	mov    %edx,0x14(%ebp)
  8013ca:	8b 00                	mov    (%eax),%eax
  8013cc:	99                   	cltd   
  8013cd:	31 d0                	xor    %edx,%eax
  8013cf:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013d1:	83 f8 0f             	cmp    $0xf,%eax
  8013d4:	7f 20                	jg     8013f6 <vprintfmt+0x13d>
  8013d6:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  8013dd:	85 d2                	test   %edx,%edx
  8013df:	74 15                	je     8013f6 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8013e1:	52                   	push   %edx
  8013e2:	68 dd 1e 80 00       	push   $0x801edd
  8013e7:	56                   	push   %esi
  8013e8:	53                   	push   %ebx
  8013e9:	e8 aa fe ff ff       	call   801298 <printfmt>
  8013ee:	83 c4 10             	add    $0x10,%esp
  8013f1:	e9 61 01 00 00       	jmp    801557 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8013f6:	50                   	push   %eax
  8013f7:	68 5f 1f 80 00       	push   $0x801f5f
  8013fc:	56                   	push   %esi
  8013fd:	53                   	push   %ebx
  8013fe:	e8 95 fe ff ff       	call   801298 <printfmt>
  801403:	83 c4 10             	add    $0x10,%esp
  801406:	e9 4c 01 00 00       	jmp    801557 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  80140b:	8b 45 14             	mov    0x14(%ebp),%eax
  80140e:	8d 50 04             	lea    0x4(%eax),%edx
  801411:	89 55 14             	mov    %edx,0x14(%ebp)
  801414:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  801416:	85 c9                	test   %ecx,%ecx
  801418:	b8 58 1f 80 00       	mov    $0x801f58,%eax
  80141d:	0f 45 c1             	cmovne %ecx,%eax
  801420:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801423:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801427:	7e 06                	jle    80142f <vprintfmt+0x176>
  801429:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80142d:	75 0d                	jne    80143c <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  80142f:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801432:	89 c7                	mov    %eax,%edi
  801434:	03 45 e0             	add    -0x20(%ebp),%eax
  801437:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80143a:	eb 57                	jmp    801493 <vprintfmt+0x1da>
  80143c:	83 ec 08             	sub    $0x8,%esp
  80143f:	ff 75 d8             	pushl  -0x28(%ebp)
  801442:	ff 75 cc             	pushl  -0x34(%ebp)
  801445:	e8 4f 02 00 00       	call   801699 <strnlen>
  80144a:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80144d:	29 c2                	sub    %eax,%edx
  80144f:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801452:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801455:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801459:	89 5d 08             	mov    %ebx,0x8(%ebp)
  80145c:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  80145e:	85 db                	test   %ebx,%ebx
  801460:	7e 10                	jle    801472 <vprintfmt+0x1b9>
					putch(padc, putdat);
  801462:	83 ec 08             	sub    $0x8,%esp
  801465:	56                   	push   %esi
  801466:	57                   	push   %edi
  801467:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80146a:	83 eb 01             	sub    $0x1,%ebx
  80146d:	83 c4 10             	add    $0x10,%esp
  801470:	eb ec                	jmp    80145e <vprintfmt+0x1a5>
  801472:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801475:	8b 55 e0             	mov    -0x20(%ebp),%edx
  801478:	85 d2                	test   %edx,%edx
  80147a:	b8 00 00 00 00       	mov    $0x0,%eax
  80147f:	0f 49 c2             	cmovns %edx,%eax
  801482:	29 c2                	sub    %eax,%edx
  801484:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801487:	eb a6                	jmp    80142f <vprintfmt+0x176>
					putch(ch, putdat);
  801489:	83 ec 08             	sub    $0x8,%esp
  80148c:	56                   	push   %esi
  80148d:	52                   	push   %edx
  80148e:	ff d3                	call   *%ebx
  801490:	83 c4 10             	add    $0x10,%esp
  801493:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801496:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801498:	83 c7 01             	add    $0x1,%edi
  80149b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80149f:	0f be d0             	movsbl %al,%edx
  8014a2:	85 d2                	test   %edx,%edx
  8014a4:	74 42                	je     8014e8 <vprintfmt+0x22f>
  8014a6:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  8014aa:	78 06                	js     8014b2 <vprintfmt+0x1f9>
  8014ac:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  8014b0:	78 1e                	js     8014d0 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  8014b2:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  8014b6:	74 d1                	je     801489 <vprintfmt+0x1d0>
  8014b8:	0f be c0             	movsbl %al,%eax
  8014bb:	83 e8 20             	sub    $0x20,%eax
  8014be:	83 f8 5e             	cmp    $0x5e,%eax
  8014c1:	76 c6                	jbe    801489 <vprintfmt+0x1d0>
					putch('?', putdat);
  8014c3:	83 ec 08             	sub    $0x8,%esp
  8014c6:	56                   	push   %esi
  8014c7:	6a 3f                	push   $0x3f
  8014c9:	ff d3                	call   *%ebx
  8014cb:	83 c4 10             	add    $0x10,%esp
  8014ce:	eb c3                	jmp    801493 <vprintfmt+0x1da>
  8014d0:	89 cf                	mov    %ecx,%edi
  8014d2:	eb 0e                	jmp    8014e2 <vprintfmt+0x229>
				putch(' ', putdat);
  8014d4:	83 ec 08             	sub    $0x8,%esp
  8014d7:	56                   	push   %esi
  8014d8:	6a 20                	push   $0x20
  8014da:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8014dc:	83 ef 01             	sub    $0x1,%edi
  8014df:	83 c4 10             	add    $0x10,%esp
  8014e2:	85 ff                	test   %edi,%edi
  8014e4:	7f ee                	jg     8014d4 <vprintfmt+0x21b>
  8014e6:	eb 6f                	jmp    801557 <vprintfmt+0x29e>
  8014e8:	89 cf                	mov    %ecx,%edi
  8014ea:	eb f6                	jmp    8014e2 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8014ec:	89 ca                	mov    %ecx,%edx
  8014ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8014f1:	e8 55 fd ff ff       	call   80124b <getint>
  8014f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014f9:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8014fc:	85 d2                	test   %edx,%edx
  8014fe:	78 0b                	js     80150b <vprintfmt+0x252>
			num = getint(&ap, lflag);
  801500:	89 d1                	mov    %edx,%ecx
  801502:	89 c2                	mov    %eax,%edx
			base = 10;
  801504:	b8 0a 00 00 00       	mov    $0xa,%eax
  801509:	eb 32                	jmp    80153d <vprintfmt+0x284>
				putch('-', putdat);
  80150b:	83 ec 08             	sub    $0x8,%esp
  80150e:	56                   	push   %esi
  80150f:	6a 2d                	push   $0x2d
  801511:	ff d3                	call   *%ebx
				num = -(long long) num;
  801513:	8b 55 d8             	mov    -0x28(%ebp),%edx
  801516:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  801519:	f7 da                	neg    %edx
  80151b:	83 d1 00             	adc    $0x0,%ecx
  80151e:	f7 d9                	neg    %ecx
  801520:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801523:	b8 0a 00 00 00       	mov    $0xa,%eax
  801528:	eb 13                	jmp    80153d <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  80152a:	89 ca                	mov    %ecx,%edx
  80152c:	8d 45 14             	lea    0x14(%ebp),%eax
  80152f:	e8 e3 fc ff ff       	call   801217 <getuint>
  801534:	89 d1                	mov    %edx,%ecx
  801536:	89 c2                	mov    %eax,%edx
			base = 10;
  801538:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  80153d:	83 ec 0c             	sub    $0xc,%esp
  801540:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801544:	57                   	push   %edi
  801545:	ff 75 e0             	pushl  -0x20(%ebp)
  801548:	50                   	push   %eax
  801549:	51                   	push   %ecx
  80154a:	52                   	push   %edx
  80154b:	89 f2                	mov    %esi,%edx
  80154d:	89 d8                	mov    %ebx,%eax
  80154f:	e8 1a fc ff ff       	call   80116e <printnum>
			break;
  801554:	83 c4 20             	add    $0x20,%esp
{
  801557:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80155a:	83 c7 01             	add    $0x1,%edi
  80155d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801561:	83 f8 25             	cmp    $0x25,%eax
  801564:	0f 84 6a fd ff ff    	je     8012d4 <vprintfmt+0x1b>
			if (ch == '\0')
  80156a:	85 c0                	test   %eax,%eax
  80156c:	0f 84 93 00 00 00    	je     801605 <vprintfmt+0x34c>
			putch(ch, putdat);
  801572:	83 ec 08             	sub    $0x8,%esp
  801575:	56                   	push   %esi
  801576:	50                   	push   %eax
  801577:	ff d3                	call   *%ebx
  801579:	83 c4 10             	add    $0x10,%esp
  80157c:	eb dc                	jmp    80155a <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  80157e:	89 ca                	mov    %ecx,%edx
  801580:	8d 45 14             	lea    0x14(%ebp),%eax
  801583:	e8 8f fc ff ff       	call   801217 <getuint>
  801588:	89 d1                	mov    %edx,%ecx
  80158a:	89 c2                	mov    %eax,%edx
			base = 8;
  80158c:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  801591:	eb aa                	jmp    80153d <vprintfmt+0x284>
			putch('0', putdat);
  801593:	83 ec 08             	sub    $0x8,%esp
  801596:	56                   	push   %esi
  801597:	6a 30                	push   $0x30
  801599:	ff d3                	call   *%ebx
			putch('x', putdat);
  80159b:	83 c4 08             	add    $0x8,%esp
  80159e:	56                   	push   %esi
  80159f:	6a 78                	push   $0x78
  8015a1:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  8015a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8015a6:	8d 50 04             	lea    0x4(%eax),%edx
  8015a9:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  8015ac:	8b 10                	mov    (%eax),%edx
  8015ae:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  8015b3:	83 c4 10             	add    $0x10,%esp
			base = 16;
  8015b6:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015bb:	eb 80                	jmp    80153d <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  8015bd:	89 ca                	mov    %ecx,%edx
  8015bf:	8d 45 14             	lea    0x14(%ebp),%eax
  8015c2:	e8 50 fc ff ff       	call   801217 <getuint>
  8015c7:	89 d1                	mov    %edx,%ecx
  8015c9:	89 c2                	mov    %eax,%edx
			base = 16;
  8015cb:	b8 10 00 00 00       	mov    $0x10,%eax
  8015d0:	e9 68 ff ff ff       	jmp    80153d <vprintfmt+0x284>
			putch(ch, putdat);
  8015d5:	83 ec 08             	sub    $0x8,%esp
  8015d8:	56                   	push   %esi
  8015d9:	6a 25                	push   $0x25
  8015db:	ff d3                	call   *%ebx
			break;
  8015dd:	83 c4 10             	add    $0x10,%esp
  8015e0:	e9 72 ff ff ff       	jmp    801557 <vprintfmt+0x29e>
			putch('%', putdat);
  8015e5:	83 ec 08             	sub    $0x8,%esp
  8015e8:	56                   	push   %esi
  8015e9:	6a 25                	push   $0x25
  8015eb:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015ed:	83 c4 10             	add    $0x10,%esp
  8015f0:	89 f8                	mov    %edi,%eax
  8015f2:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8015f6:	74 05                	je     8015fd <vprintfmt+0x344>
  8015f8:	83 e8 01             	sub    $0x1,%eax
  8015fb:	eb f5                	jmp    8015f2 <vprintfmt+0x339>
  8015fd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  801600:	e9 52 ff ff ff       	jmp    801557 <vprintfmt+0x29e>
}
  801605:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801608:	5b                   	pop    %ebx
  801609:	5e                   	pop    %esi
  80160a:	5f                   	pop    %edi
  80160b:	5d                   	pop    %ebp
  80160c:	c3                   	ret    

0080160d <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80160d:	f3 0f 1e fb          	endbr32 
  801611:	55                   	push   %ebp
  801612:	89 e5                	mov    %esp,%ebp
  801614:	83 ec 18             	sub    $0x18,%esp
  801617:	8b 45 08             	mov    0x8(%ebp),%eax
  80161a:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80161d:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801620:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801624:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801627:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80162e:	85 c0                	test   %eax,%eax
  801630:	74 26                	je     801658 <vsnprintf+0x4b>
  801632:	85 d2                	test   %edx,%edx
  801634:	7e 22                	jle    801658 <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801636:	ff 75 14             	pushl  0x14(%ebp)
  801639:	ff 75 10             	pushl  0x10(%ebp)
  80163c:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80163f:	50                   	push   %eax
  801640:	68 77 12 80 00       	push   $0x801277
  801645:	e8 6f fc ff ff       	call   8012b9 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80164a:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80164d:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801650:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801653:	83 c4 10             	add    $0x10,%esp
}
  801656:	c9                   	leave  
  801657:	c3                   	ret    
		return -E_INVAL;
  801658:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80165d:	eb f7                	jmp    801656 <vsnprintf+0x49>

0080165f <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80165f:	f3 0f 1e fb          	endbr32 
  801663:	55                   	push   %ebp
  801664:	89 e5                	mov    %esp,%ebp
  801666:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801669:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80166c:	50                   	push   %eax
  80166d:	ff 75 10             	pushl  0x10(%ebp)
  801670:	ff 75 0c             	pushl  0xc(%ebp)
  801673:	ff 75 08             	pushl  0x8(%ebp)
  801676:	e8 92 ff ff ff       	call   80160d <vsnprintf>
	va_end(ap);

	return rc;
}
  80167b:	c9                   	leave  
  80167c:	c3                   	ret    

0080167d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80167d:	f3 0f 1e fb          	endbr32 
  801681:	55                   	push   %ebp
  801682:	89 e5                	mov    %esp,%ebp
  801684:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801687:	b8 00 00 00 00       	mov    $0x0,%eax
  80168c:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801690:	74 05                	je     801697 <strlen+0x1a>
		n++;
  801692:	83 c0 01             	add    $0x1,%eax
  801695:	eb f5                	jmp    80168c <strlen+0xf>
	return n;
}
  801697:	5d                   	pop    %ebp
  801698:	c3                   	ret    

00801699 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  801699:	f3 0f 1e fb          	endbr32 
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
  8016a0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016a3:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016a6:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ab:	39 d0                	cmp    %edx,%eax
  8016ad:	74 0d                	je     8016bc <strnlen+0x23>
  8016af:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  8016b3:	74 05                	je     8016ba <strnlen+0x21>
		n++;
  8016b5:	83 c0 01             	add    $0x1,%eax
  8016b8:	eb f1                	jmp    8016ab <strnlen+0x12>
  8016ba:	89 c2                	mov    %eax,%edx
	return n;
}
  8016bc:	89 d0                	mov    %edx,%eax
  8016be:	5d                   	pop    %ebp
  8016bf:	c3                   	ret    

008016c0 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016c0:	f3 0f 1e fb          	endbr32 
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	53                   	push   %ebx
  8016c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016ce:	b8 00 00 00 00       	mov    $0x0,%eax
  8016d3:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8016d7:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8016da:	83 c0 01             	add    $0x1,%eax
  8016dd:	84 d2                	test   %dl,%dl
  8016df:	75 f2                	jne    8016d3 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8016e1:	89 c8                	mov    %ecx,%eax
  8016e3:	5b                   	pop    %ebx
  8016e4:	5d                   	pop    %ebp
  8016e5:	c3                   	ret    

008016e6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016e6:	f3 0f 1e fb          	endbr32 
  8016ea:	55                   	push   %ebp
  8016eb:	89 e5                	mov    %esp,%ebp
  8016ed:	53                   	push   %ebx
  8016ee:	83 ec 10             	sub    $0x10,%esp
  8016f1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016f4:	53                   	push   %ebx
  8016f5:	e8 83 ff ff ff       	call   80167d <strlen>
  8016fa:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8016fd:	ff 75 0c             	pushl  0xc(%ebp)
  801700:	01 d8                	add    %ebx,%eax
  801702:	50                   	push   %eax
  801703:	e8 b8 ff ff ff       	call   8016c0 <strcpy>
	return dst;
}
  801708:	89 d8                	mov    %ebx,%eax
  80170a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80170d:	c9                   	leave  
  80170e:	c3                   	ret    

0080170f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80170f:	f3 0f 1e fb          	endbr32 
  801713:	55                   	push   %ebp
  801714:	89 e5                	mov    %esp,%ebp
  801716:	56                   	push   %esi
  801717:	53                   	push   %ebx
  801718:	8b 75 08             	mov    0x8(%ebp),%esi
  80171b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80171e:	89 f3                	mov    %esi,%ebx
  801720:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801723:	89 f0                	mov    %esi,%eax
  801725:	39 d8                	cmp    %ebx,%eax
  801727:	74 11                	je     80173a <strncpy+0x2b>
		*dst++ = *src;
  801729:	83 c0 01             	add    $0x1,%eax
  80172c:	0f b6 0a             	movzbl (%edx),%ecx
  80172f:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801732:	80 f9 01             	cmp    $0x1,%cl
  801735:	83 da ff             	sbb    $0xffffffff,%edx
  801738:	eb eb                	jmp    801725 <strncpy+0x16>
	}
	return ret;
}
  80173a:	89 f0                	mov    %esi,%eax
  80173c:	5b                   	pop    %ebx
  80173d:	5e                   	pop    %esi
  80173e:	5d                   	pop    %ebp
  80173f:	c3                   	ret    

00801740 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801740:	f3 0f 1e fb          	endbr32 
  801744:	55                   	push   %ebp
  801745:	89 e5                	mov    %esp,%ebp
  801747:	56                   	push   %esi
  801748:	53                   	push   %ebx
  801749:	8b 75 08             	mov    0x8(%ebp),%esi
  80174c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80174f:	8b 55 10             	mov    0x10(%ebp),%edx
  801752:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801754:	85 d2                	test   %edx,%edx
  801756:	74 21                	je     801779 <strlcpy+0x39>
  801758:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80175c:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  80175e:	39 c2                	cmp    %eax,%edx
  801760:	74 14                	je     801776 <strlcpy+0x36>
  801762:	0f b6 19             	movzbl (%ecx),%ebx
  801765:	84 db                	test   %bl,%bl
  801767:	74 0b                	je     801774 <strlcpy+0x34>
			*dst++ = *src++;
  801769:	83 c1 01             	add    $0x1,%ecx
  80176c:	83 c2 01             	add    $0x1,%edx
  80176f:	88 5a ff             	mov    %bl,-0x1(%edx)
  801772:	eb ea                	jmp    80175e <strlcpy+0x1e>
  801774:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801776:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801779:	29 f0                	sub    %esi,%eax
}
  80177b:	5b                   	pop    %ebx
  80177c:	5e                   	pop    %esi
  80177d:	5d                   	pop    %ebp
  80177e:	c3                   	ret    

0080177f <strcmp>:

int
strcmp(const char *p, const char *q)
{
  80177f:	f3 0f 1e fb          	endbr32 
  801783:	55                   	push   %ebp
  801784:	89 e5                	mov    %esp,%ebp
  801786:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801789:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80178c:	0f b6 01             	movzbl (%ecx),%eax
  80178f:	84 c0                	test   %al,%al
  801791:	74 0c                	je     80179f <strcmp+0x20>
  801793:	3a 02                	cmp    (%edx),%al
  801795:	75 08                	jne    80179f <strcmp+0x20>
		p++, q++;
  801797:	83 c1 01             	add    $0x1,%ecx
  80179a:	83 c2 01             	add    $0x1,%edx
  80179d:	eb ed                	jmp    80178c <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80179f:	0f b6 c0             	movzbl %al,%eax
  8017a2:	0f b6 12             	movzbl (%edx),%edx
  8017a5:	29 d0                	sub    %edx,%eax
}
  8017a7:	5d                   	pop    %ebp
  8017a8:	c3                   	ret    

008017a9 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017a9:	f3 0f 1e fb          	endbr32 
  8017ad:	55                   	push   %ebp
  8017ae:	89 e5                	mov    %esp,%ebp
  8017b0:	53                   	push   %ebx
  8017b1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b7:	89 c3                	mov    %eax,%ebx
  8017b9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017bc:	eb 06                	jmp    8017c4 <strncmp+0x1b>
		n--, p++, q++;
  8017be:	83 c0 01             	add    $0x1,%eax
  8017c1:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017c4:	39 d8                	cmp    %ebx,%eax
  8017c6:	74 16                	je     8017de <strncmp+0x35>
  8017c8:	0f b6 08             	movzbl (%eax),%ecx
  8017cb:	84 c9                	test   %cl,%cl
  8017cd:	74 04                	je     8017d3 <strncmp+0x2a>
  8017cf:	3a 0a                	cmp    (%edx),%cl
  8017d1:	74 eb                	je     8017be <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017d3:	0f b6 00             	movzbl (%eax),%eax
  8017d6:	0f b6 12             	movzbl (%edx),%edx
  8017d9:	29 d0                	sub    %edx,%eax
}
  8017db:	5b                   	pop    %ebx
  8017dc:	5d                   	pop    %ebp
  8017dd:	c3                   	ret    
		return 0;
  8017de:	b8 00 00 00 00       	mov    $0x0,%eax
  8017e3:	eb f6                	jmp    8017db <strncmp+0x32>

008017e5 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017e5:	f3 0f 1e fb          	endbr32 
  8017e9:	55                   	push   %ebp
  8017ea:	89 e5                	mov    %esp,%ebp
  8017ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ef:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017f3:	0f b6 10             	movzbl (%eax),%edx
  8017f6:	84 d2                	test   %dl,%dl
  8017f8:	74 09                	je     801803 <strchr+0x1e>
		if (*s == c)
  8017fa:	38 ca                	cmp    %cl,%dl
  8017fc:	74 0a                	je     801808 <strchr+0x23>
	for (; *s; s++)
  8017fe:	83 c0 01             	add    $0x1,%eax
  801801:	eb f0                	jmp    8017f3 <strchr+0xe>
			return (char *) s;
	return 0;
  801803:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801808:	5d                   	pop    %ebp
  801809:	c3                   	ret    

0080180a <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80180a:	f3 0f 1e fb          	endbr32 
  80180e:	55                   	push   %ebp
  80180f:	89 e5                	mov    %esp,%ebp
  801811:	8b 45 08             	mov    0x8(%ebp),%eax
  801814:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801818:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80181b:	38 ca                	cmp    %cl,%dl
  80181d:	74 09                	je     801828 <strfind+0x1e>
  80181f:	84 d2                	test   %dl,%dl
  801821:	74 05                	je     801828 <strfind+0x1e>
	for (; *s; s++)
  801823:	83 c0 01             	add    $0x1,%eax
  801826:	eb f0                	jmp    801818 <strfind+0xe>
			break;
	return (char *) s;
}
  801828:	5d                   	pop    %ebp
  801829:	c3                   	ret    

0080182a <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80182a:	f3 0f 1e fb          	endbr32 
  80182e:	55                   	push   %ebp
  80182f:	89 e5                	mov    %esp,%ebp
  801831:	57                   	push   %edi
  801832:	56                   	push   %esi
  801833:	53                   	push   %ebx
  801834:	8b 55 08             	mov    0x8(%ebp),%edx
  801837:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  80183a:	85 c9                	test   %ecx,%ecx
  80183c:	74 33                	je     801871 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80183e:	89 d0                	mov    %edx,%eax
  801840:	09 c8                	or     %ecx,%eax
  801842:	a8 03                	test   $0x3,%al
  801844:	75 23                	jne    801869 <memset+0x3f>
		c &= 0xFF;
  801846:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80184a:	89 d8                	mov    %ebx,%eax
  80184c:	c1 e0 08             	shl    $0x8,%eax
  80184f:	89 df                	mov    %ebx,%edi
  801851:	c1 e7 18             	shl    $0x18,%edi
  801854:	89 de                	mov    %ebx,%esi
  801856:	c1 e6 10             	shl    $0x10,%esi
  801859:	09 f7                	or     %esi,%edi
  80185b:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  80185d:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801860:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  801862:	89 d7                	mov    %edx,%edi
  801864:	fc                   	cld    
  801865:	f3 ab                	rep stos %eax,%es:(%edi)
  801867:	eb 08                	jmp    801871 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801869:	89 d7                	mov    %edx,%edi
  80186b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186e:	fc                   	cld    
  80186f:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  801871:	89 d0                	mov    %edx,%eax
  801873:	5b                   	pop    %ebx
  801874:	5e                   	pop    %esi
  801875:	5f                   	pop    %edi
  801876:	5d                   	pop    %ebp
  801877:	c3                   	ret    

00801878 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801878:	f3 0f 1e fb          	endbr32 
  80187c:	55                   	push   %ebp
  80187d:	89 e5                	mov    %esp,%ebp
  80187f:	57                   	push   %edi
  801880:	56                   	push   %esi
  801881:	8b 45 08             	mov    0x8(%ebp),%eax
  801884:	8b 75 0c             	mov    0xc(%ebp),%esi
  801887:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80188a:	39 c6                	cmp    %eax,%esi
  80188c:	73 32                	jae    8018c0 <memmove+0x48>
  80188e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801891:	39 c2                	cmp    %eax,%edx
  801893:	76 2b                	jbe    8018c0 <memmove+0x48>
		s += n;
		d += n;
  801895:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801898:	89 fe                	mov    %edi,%esi
  80189a:	09 ce                	or     %ecx,%esi
  80189c:	09 d6                	or     %edx,%esi
  80189e:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018a4:	75 0e                	jne    8018b4 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  8018a6:	83 ef 04             	sub    $0x4,%edi
  8018a9:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018ac:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  8018af:	fd                   	std    
  8018b0:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018b2:	eb 09                	jmp    8018bd <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  8018b4:	83 ef 01             	sub    $0x1,%edi
  8018b7:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  8018ba:	fd                   	std    
  8018bb:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018bd:	fc                   	cld    
  8018be:	eb 1a                	jmp    8018da <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018c0:	89 c2                	mov    %eax,%edx
  8018c2:	09 ca                	or     %ecx,%edx
  8018c4:	09 f2                	or     %esi,%edx
  8018c6:	f6 c2 03             	test   $0x3,%dl
  8018c9:	75 0a                	jne    8018d5 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018cb:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018ce:	89 c7                	mov    %eax,%edi
  8018d0:	fc                   	cld    
  8018d1:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018d3:	eb 05                	jmp    8018da <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8018d5:	89 c7                	mov    %eax,%edi
  8018d7:	fc                   	cld    
  8018d8:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018da:	5e                   	pop    %esi
  8018db:	5f                   	pop    %edi
  8018dc:	5d                   	pop    %ebp
  8018dd:	c3                   	ret    

008018de <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018de:	f3 0f 1e fb          	endbr32 
  8018e2:	55                   	push   %ebp
  8018e3:	89 e5                	mov    %esp,%ebp
  8018e5:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8018e8:	ff 75 10             	pushl  0x10(%ebp)
  8018eb:	ff 75 0c             	pushl  0xc(%ebp)
  8018ee:	ff 75 08             	pushl  0x8(%ebp)
  8018f1:	e8 82 ff ff ff       	call   801878 <memmove>
}
  8018f6:	c9                   	leave  
  8018f7:	c3                   	ret    

008018f8 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018f8:	f3 0f 1e fb          	endbr32 
  8018fc:	55                   	push   %ebp
  8018fd:	89 e5                	mov    %esp,%ebp
  8018ff:	56                   	push   %esi
  801900:	53                   	push   %ebx
  801901:	8b 45 08             	mov    0x8(%ebp),%eax
  801904:	8b 55 0c             	mov    0xc(%ebp),%edx
  801907:	89 c6                	mov    %eax,%esi
  801909:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80190c:	39 f0                	cmp    %esi,%eax
  80190e:	74 1c                	je     80192c <memcmp+0x34>
		if (*s1 != *s2)
  801910:	0f b6 08             	movzbl (%eax),%ecx
  801913:	0f b6 1a             	movzbl (%edx),%ebx
  801916:	38 d9                	cmp    %bl,%cl
  801918:	75 08                	jne    801922 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  80191a:	83 c0 01             	add    $0x1,%eax
  80191d:	83 c2 01             	add    $0x1,%edx
  801920:	eb ea                	jmp    80190c <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801922:	0f b6 c1             	movzbl %cl,%eax
  801925:	0f b6 db             	movzbl %bl,%ebx
  801928:	29 d8                	sub    %ebx,%eax
  80192a:	eb 05                	jmp    801931 <memcmp+0x39>
	}

	return 0;
  80192c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801931:	5b                   	pop    %ebx
  801932:	5e                   	pop    %esi
  801933:	5d                   	pop    %ebp
  801934:	c3                   	ret    

00801935 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801935:	f3 0f 1e fb          	endbr32 
  801939:	55                   	push   %ebp
  80193a:	89 e5                	mov    %esp,%ebp
  80193c:	8b 45 08             	mov    0x8(%ebp),%eax
  80193f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801942:	89 c2                	mov    %eax,%edx
  801944:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801947:	39 d0                	cmp    %edx,%eax
  801949:	73 09                	jae    801954 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  80194b:	38 08                	cmp    %cl,(%eax)
  80194d:	74 05                	je     801954 <memfind+0x1f>
	for (; s < ends; s++)
  80194f:	83 c0 01             	add    $0x1,%eax
  801952:	eb f3                	jmp    801947 <memfind+0x12>
			break;
	return (void *) s;
}
  801954:	5d                   	pop    %ebp
  801955:	c3                   	ret    

00801956 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801956:	f3 0f 1e fb          	endbr32 
  80195a:	55                   	push   %ebp
  80195b:	89 e5                	mov    %esp,%ebp
  80195d:	57                   	push   %edi
  80195e:	56                   	push   %esi
  80195f:	53                   	push   %ebx
  801960:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801963:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801966:	eb 03                	jmp    80196b <strtol+0x15>
		s++;
  801968:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  80196b:	0f b6 01             	movzbl (%ecx),%eax
  80196e:	3c 20                	cmp    $0x20,%al
  801970:	74 f6                	je     801968 <strtol+0x12>
  801972:	3c 09                	cmp    $0x9,%al
  801974:	74 f2                	je     801968 <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801976:	3c 2b                	cmp    $0x2b,%al
  801978:	74 2a                	je     8019a4 <strtol+0x4e>
	int neg = 0;
  80197a:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  80197f:	3c 2d                	cmp    $0x2d,%al
  801981:	74 2b                	je     8019ae <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801983:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801989:	75 0f                	jne    80199a <strtol+0x44>
  80198b:	80 39 30             	cmpb   $0x30,(%ecx)
  80198e:	74 28                	je     8019b8 <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801990:	85 db                	test   %ebx,%ebx
  801992:	b8 0a 00 00 00       	mov    $0xa,%eax
  801997:	0f 44 d8             	cmove  %eax,%ebx
  80199a:	b8 00 00 00 00       	mov    $0x0,%eax
  80199f:	89 5d 10             	mov    %ebx,0x10(%ebp)
  8019a2:	eb 46                	jmp    8019ea <strtol+0x94>
		s++;
  8019a4:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  8019a7:	bf 00 00 00 00       	mov    $0x0,%edi
  8019ac:	eb d5                	jmp    801983 <strtol+0x2d>
		s++, neg = 1;
  8019ae:	83 c1 01             	add    $0x1,%ecx
  8019b1:	bf 01 00 00 00       	mov    $0x1,%edi
  8019b6:	eb cb                	jmp    801983 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019b8:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019bc:	74 0e                	je     8019cc <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019be:	85 db                	test   %ebx,%ebx
  8019c0:	75 d8                	jne    80199a <strtol+0x44>
		s++, base = 8;
  8019c2:	83 c1 01             	add    $0x1,%ecx
  8019c5:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019ca:	eb ce                	jmp    80199a <strtol+0x44>
		s += 2, base = 16;
  8019cc:	83 c1 02             	add    $0x2,%ecx
  8019cf:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019d4:	eb c4                	jmp    80199a <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8019d6:	0f be d2             	movsbl %dl,%edx
  8019d9:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019dc:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019df:	7d 3a                	jge    801a1b <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8019e1:	83 c1 01             	add    $0x1,%ecx
  8019e4:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019e8:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8019ea:	0f b6 11             	movzbl (%ecx),%edx
  8019ed:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019f0:	89 f3                	mov    %esi,%ebx
  8019f2:	80 fb 09             	cmp    $0x9,%bl
  8019f5:	76 df                	jbe    8019d6 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  8019f7:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019fa:	89 f3                	mov    %esi,%ebx
  8019fc:	80 fb 19             	cmp    $0x19,%bl
  8019ff:	77 08                	ja     801a09 <strtol+0xb3>
			dig = *s - 'a' + 10;
  801a01:	0f be d2             	movsbl %dl,%edx
  801a04:	83 ea 57             	sub    $0x57,%edx
  801a07:	eb d3                	jmp    8019dc <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  801a09:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a0c:	89 f3                	mov    %esi,%ebx
  801a0e:	80 fb 19             	cmp    $0x19,%bl
  801a11:	77 08                	ja     801a1b <strtol+0xc5>
			dig = *s - 'A' + 10;
  801a13:	0f be d2             	movsbl %dl,%edx
  801a16:	83 ea 37             	sub    $0x37,%edx
  801a19:	eb c1                	jmp    8019dc <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  801a1b:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a1f:	74 05                	je     801a26 <strtol+0xd0>
		*endptr = (char *) s;
  801a21:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a24:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a26:	89 c2                	mov    %eax,%edx
  801a28:	f7 da                	neg    %edx
  801a2a:	85 ff                	test   %edi,%edi
  801a2c:	0f 45 c2             	cmovne %edx,%eax
}
  801a2f:	5b                   	pop    %ebx
  801a30:	5e                   	pop    %esi
  801a31:	5f                   	pop    %edi
  801a32:	5d                   	pop    %ebp
  801a33:	c3                   	ret    

00801a34 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a34:	f3 0f 1e fb          	endbr32 
  801a38:	55                   	push   %ebp
  801a39:	89 e5                	mov    %esp,%ebp
  801a3b:	56                   	push   %esi
  801a3c:	53                   	push   %ebx
  801a3d:	8b 75 08             	mov    0x8(%ebp),%esi
  801a40:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a43:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  801a46:	85 c0                	test   %eax,%eax
  801a48:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a4d:	0f 44 c2             	cmove  %edx,%eax
  801a50:	83 ec 0c             	sub    $0xc,%esp
  801a53:	50                   	push   %eax
  801a54:	e8 a7 e8 ff ff       	call   800300 <sys_ipc_recv>

	if (from_env_store != NULL)
  801a59:	83 c4 10             	add    $0x10,%esp
  801a5c:	85 f6                	test   %esi,%esi
  801a5e:	74 15                	je     801a75 <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  801a60:	ba 00 00 00 00       	mov    $0x0,%edx
  801a65:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a68:	74 09                	je     801a73 <ipc_recv+0x3f>
  801a6a:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a70:	8b 52 74             	mov    0x74(%edx),%edx
  801a73:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  801a75:	85 db                	test   %ebx,%ebx
  801a77:	74 15                	je     801a8e <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  801a79:	ba 00 00 00 00       	mov    $0x0,%edx
  801a7e:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a81:	74 09                	je     801a8c <ipc_recv+0x58>
  801a83:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a89:	8b 52 78             	mov    0x78(%edx),%edx
  801a8c:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  801a8e:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a91:	74 08                	je     801a9b <ipc_recv+0x67>
  801a93:	a1 04 40 80 00       	mov    0x804004,%eax
  801a98:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a9b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a9e:	5b                   	pop    %ebx
  801a9f:	5e                   	pop    %esi
  801aa0:	5d                   	pop    %ebp
  801aa1:	c3                   	ret    

00801aa2 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aa2:	f3 0f 1e fb          	endbr32 
  801aa6:	55                   	push   %ebp
  801aa7:	89 e5                	mov    %esp,%ebp
  801aa9:	57                   	push   %edi
  801aaa:	56                   	push   %esi
  801aab:	53                   	push   %ebx
  801aac:	83 ec 0c             	sub    $0xc,%esp
  801aaf:	8b 7d 08             	mov    0x8(%ebp),%edi
  801ab2:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ab5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801ab8:	eb 1f                	jmp    801ad9 <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  801aba:	6a 00                	push   $0x0
  801abc:	68 00 00 c0 ee       	push   $0xeec00000
  801ac1:	56                   	push   %esi
  801ac2:	57                   	push   %edi
  801ac3:	e8 0f e8 ff ff       	call   8002d7 <sys_ipc_try_send>
  801ac8:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  801acb:	85 c0                	test   %eax,%eax
  801acd:	74 30                	je     801aff <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  801acf:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ad2:	75 19                	jne    801aed <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  801ad4:	e8 e5 e6 ff ff       	call   8001be <sys_yield>
		if (pg != NULL) {
  801ad9:	85 db                	test   %ebx,%ebx
  801adb:	74 dd                	je     801aba <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  801add:	ff 75 14             	pushl  0x14(%ebp)
  801ae0:	53                   	push   %ebx
  801ae1:	56                   	push   %esi
  801ae2:	57                   	push   %edi
  801ae3:	e8 ef e7 ff ff       	call   8002d7 <sys_ipc_try_send>
  801ae8:	83 c4 10             	add    $0x10,%esp
  801aeb:	eb de                	jmp    801acb <ipc_send+0x29>
			panic("ipc_send: %d", res);
  801aed:	50                   	push   %eax
  801aee:	68 3f 22 80 00       	push   $0x80223f
  801af3:	6a 3e                	push   $0x3e
  801af5:	68 4c 22 80 00       	push   $0x80224c
  801afa:	e8 70 f5 ff ff       	call   80106f <_panic>
	}
}
  801aff:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801b02:	5b                   	pop    %ebx
  801b03:	5e                   	pop    %esi
  801b04:	5f                   	pop    %edi
  801b05:	5d                   	pop    %ebp
  801b06:	c3                   	ret    

00801b07 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801b07:	f3 0f 1e fb          	endbr32 
  801b0b:	55                   	push   %ebp
  801b0c:	89 e5                	mov    %esp,%ebp
  801b0e:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801b11:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801b16:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801b19:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b1f:	8b 52 50             	mov    0x50(%edx),%edx
  801b22:	39 ca                	cmp    %ecx,%edx
  801b24:	74 11                	je     801b37 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801b26:	83 c0 01             	add    $0x1,%eax
  801b29:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b2e:	75 e6                	jne    801b16 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801b30:	b8 00 00 00 00       	mov    $0x0,%eax
  801b35:	eb 0b                	jmp    801b42 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801b37:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b3a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b3f:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b42:	5d                   	pop    %ebp
  801b43:	c3                   	ret    

00801b44 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b44:	f3 0f 1e fb          	endbr32 
  801b48:	55                   	push   %ebp
  801b49:	89 e5                	mov    %esp,%ebp
  801b4b:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b4e:	89 c2                	mov    %eax,%edx
  801b50:	c1 ea 16             	shr    $0x16,%edx
  801b53:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b5a:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b5f:	f6 c1 01             	test   $0x1,%cl
  801b62:	74 1c                	je     801b80 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801b64:	c1 e8 0c             	shr    $0xc,%eax
  801b67:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b6e:	a8 01                	test   $0x1,%al
  801b70:	74 0e                	je     801b80 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b72:	c1 e8 0c             	shr    $0xc,%eax
  801b75:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b7c:	ef 
  801b7d:	0f b7 d2             	movzwl %dx,%edx
}
  801b80:	89 d0                	mov    %edx,%eax
  801b82:	5d                   	pop    %ebp
  801b83:	c3                   	ret    
  801b84:	66 90                	xchg   %ax,%ax
  801b86:	66 90                	xchg   %ax,%ax
  801b88:	66 90                	xchg   %ax,%ax
  801b8a:	66 90                	xchg   %ax,%ax
  801b8c:	66 90                	xchg   %ax,%ax
  801b8e:	66 90                	xchg   %ax,%ax

00801b90 <__udivdi3>:
  801b90:	f3 0f 1e fb          	endbr32 
  801b94:	55                   	push   %ebp
  801b95:	57                   	push   %edi
  801b96:	56                   	push   %esi
  801b97:	53                   	push   %ebx
  801b98:	83 ec 1c             	sub    $0x1c,%esp
  801b9b:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801b9f:	8b 6c 24 30          	mov    0x30(%esp),%ebp
  801ba3:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ba7:	8b 5c 24 38          	mov    0x38(%esp),%ebx
  801bab:	85 d2                	test   %edx,%edx
  801bad:	75 19                	jne    801bc8 <__udivdi3+0x38>
  801baf:	39 f3                	cmp    %esi,%ebx
  801bb1:	76 4d                	jbe    801c00 <__udivdi3+0x70>
  801bb3:	31 ff                	xor    %edi,%edi
  801bb5:	89 e8                	mov    %ebp,%eax
  801bb7:	89 f2                	mov    %esi,%edx
  801bb9:	f7 f3                	div    %ebx
  801bbb:	89 fa                	mov    %edi,%edx
  801bbd:	83 c4 1c             	add    $0x1c,%esp
  801bc0:	5b                   	pop    %ebx
  801bc1:	5e                   	pop    %esi
  801bc2:	5f                   	pop    %edi
  801bc3:	5d                   	pop    %ebp
  801bc4:	c3                   	ret    
  801bc5:	8d 76 00             	lea    0x0(%esi),%esi
  801bc8:	39 f2                	cmp    %esi,%edx
  801bca:	76 14                	jbe    801be0 <__udivdi3+0x50>
  801bcc:	31 ff                	xor    %edi,%edi
  801bce:	31 c0                	xor    %eax,%eax
  801bd0:	89 fa                	mov    %edi,%edx
  801bd2:	83 c4 1c             	add    $0x1c,%esp
  801bd5:	5b                   	pop    %ebx
  801bd6:	5e                   	pop    %esi
  801bd7:	5f                   	pop    %edi
  801bd8:	5d                   	pop    %ebp
  801bd9:	c3                   	ret    
  801bda:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801be0:	0f bd fa             	bsr    %edx,%edi
  801be3:	83 f7 1f             	xor    $0x1f,%edi
  801be6:	75 48                	jne    801c30 <__udivdi3+0xa0>
  801be8:	39 f2                	cmp    %esi,%edx
  801bea:	72 06                	jb     801bf2 <__udivdi3+0x62>
  801bec:	31 c0                	xor    %eax,%eax
  801bee:	39 eb                	cmp    %ebp,%ebx
  801bf0:	77 de                	ja     801bd0 <__udivdi3+0x40>
  801bf2:	b8 01 00 00 00       	mov    $0x1,%eax
  801bf7:	eb d7                	jmp    801bd0 <__udivdi3+0x40>
  801bf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c00:	89 d9                	mov    %ebx,%ecx
  801c02:	85 db                	test   %ebx,%ebx
  801c04:	75 0b                	jne    801c11 <__udivdi3+0x81>
  801c06:	b8 01 00 00 00       	mov    $0x1,%eax
  801c0b:	31 d2                	xor    %edx,%edx
  801c0d:	f7 f3                	div    %ebx
  801c0f:	89 c1                	mov    %eax,%ecx
  801c11:	31 d2                	xor    %edx,%edx
  801c13:	89 f0                	mov    %esi,%eax
  801c15:	f7 f1                	div    %ecx
  801c17:	89 c6                	mov    %eax,%esi
  801c19:	89 e8                	mov    %ebp,%eax
  801c1b:	89 f7                	mov    %esi,%edi
  801c1d:	f7 f1                	div    %ecx
  801c1f:	89 fa                	mov    %edi,%edx
  801c21:	83 c4 1c             	add    $0x1c,%esp
  801c24:	5b                   	pop    %ebx
  801c25:	5e                   	pop    %esi
  801c26:	5f                   	pop    %edi
  801c27:	5d                   	pop    %ebp
  801c28:	c3                   	ret    
  801c29:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c30:	89 f9                	mov    %edi,%ecx
  801c32:	b8 20 00 00 00       	mov    $0x20,%eax
  801c37:	29 f8                	sub    %edi,%eax
  801c39:	d3 e2                	shl    %cl,%edx
  801c3b:	89 54 24 08          	mov    %edx,0x8(%esp)
  801c3f:	89 c1                	mov    %eax,%ecx
  801c41:	89 da                	mov    %ebx,%edx
  801c43:	d3 ea                	shr    %cl,%edx
  801c45:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801c49:	09 d1                	or     %edx,%ecx
  801c4b:	89 f2                	mov    %esi,%edx
  801c4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801c51:	89 f9                	mov    %edi,%ecx
  801c53:	d3 e3                	shl    %cl,%ebx
  801c55:	89 c1                	mov    %eax,%ecx
  801c57:	d3 ea                	shr    %cl,%edx
  801c59:	89 f9                	mov    %edi,%ecx
  801c5b:	89 5c 24 0c          	mov    %ebx,0xc(%esp)
  801c5f:	89 eb                	mov    %ebp,%ebx
  801c61:	d3 e6                	shl    %cl,%esi
  801c63:	89 c1                	mov    %eax,%ecx
  801c65:	d3 eb                	shr    %cl,%ebx
  801c67:	09 de                	or     %ebx,%esi
  801c69:	89 f0                	mov    %esi,%eax
  801c6b:	f7 74 24 08          	divl   0x8(%esp)
  801c6f:	89 d6                	mov    %edx,%esi
  801c71:	89 c3                	mov    %eax,%ebx
  801c73:	f7 64 24 0c          	mull   0xc(%esp)
  801c77:	39 d6                	cmp    %edx,%esi
  801c79:	72 15                	jb     801c90 <__udivdi3+0x100>
  801c7b:	89 f9                	mov    %edi,%ecx
  801c7d:	d3 e5                	shl    %cl,%ebp
  801c7f:	39 c5                	cmp    %eax,%ebp
  801c81:	73 04                	jae    801c87 <__udivdi3+0xf7>
  801c83:	39 d6                	cmp    %edx,%esi
  801c85:	74 09                	je     801c90 <__udivdi3+0x100>
  801c87:	89 d8                	mov    %ebx,%eax
  801c89:	31 ff                	xor    %edi,%edi
  801c8b:	e9 40 ff ff ff       	jmp    801bd0 <__udivdi3+0x40>
  801c90:	8d 43 ff             	lea    -0x1(%ebx),%eax
  801c93:	31 ff                	xor    %edi,%edi
  801c95:	e9 36 ff ff ff       	jmp    801bd0 <__udivdi3+0x40>
  801c9a:	66 90                	xchg   %ax,%ax
  801c9c:	66 90                	xchg   %ax,%ax
  801c9e:	66 90                	xchg   %ax,%ax

00801ca0 <__umoddi3>:
  801ca0:	f3 0f 1e fb          	endbr32 
  801ca4:	55                   	push   %ebp
  801ca5:	57                   	push   %edi
  801ca6:	56                   	push   %esi
  801ca7:	53                   	push   %ebx
  801ca8:	83 ec 1c             	sub    $0x1c,%esp
  801cab:	8b 44 24 3c          	mov    0x3c(%esp),%eax
  801caf:	8b 74 24 30          	mov    0x30(%esp),%esi
  801cb3:	8b 5c 24 34          	mov    0x34(%esp),%ebx
  801cb7:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801cbb:	85 c0                	test   %eax,%eax
  801cbd:	75 19                	jne    801cd8 <__umoddi3+0x38>
  801cbf:	39 df                	cmp    %ebx,%edi
  801cc1:	76 5d                	jbe    801d20 <__umoddi3+0x80>
  801cc3:	89 f0                	mov    %esi,%eax
  801cc5:	89 da                	mov    %ebx,%edx
  801cc7:	f7 f7                	div    %edi
  801cc9:	89 d0                	mov    %edx,%eax
  801ccb:	31 d2                	xor    %edx,%edx
  801ccd:	83 c4 1c             	add    $0x1c,%esp
  801cd0:	5b                   	pop    %ebx
  801cd1:	5e                   	pop    %esi
  801cd2:	5f                   	pop    %edi
  801cd3:	5d                   	pop    %ebp
  801cd4:	c3                   	ret    
  801cd5:	8d 76 00             	lea    0x0(%esi),%esi
  801cd8:	89 f2                	mov    %esi,%edx
  801cda:	39 d8                	cmp    %ebx,%eax
  801cdc:	76 12                	jbe    801cf0 <__umoddi3+0x50>
  801cde:	89 f0                	mov    %esi,%eax
  801ce0:	89 da                	mov    %ebx,%edx
  801ce2:	83 c4 1c             	add    $0x1c,%esp
  801ce5:	5b                   	pop    %ebx
  801ce6:	5e                   	pop    %esi
  801ce7:	5f                   	pop    %edi
  801ce8:	5d                   	pop    %ebp
  801ce9:	c3                   	ret    
  801cea:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cf0:	0f bd e8             	bsr    %eax,%ebp
  801cf3:	83 f5 1f             	xor    $0x1f,%ebp
  801cf6:	75 50                	jne    801d48 <__umoddi3+0xa8>
  801cf8:	39 d8                	cmp    %ebx,%eax
  801cfa:	0f 82 e0 00 00 00    	jb     801de0 <__umoddi3+0x140>
  801d00:	89 d9                	mov    %ebx,%ecx
  801d02:	39 f7                	cmp    %esi,%edi
  801d04:	0f 86 d6 00 00 00    	jbe    801de0 <__umoddi3+0x140>
  801d0a:	89 d0                	mov    %edx,%eax
  801d0c:	89 ca                	mov    %ecx,%edx
  801d0e:	83 c4 1c             	add    $0x1c,%esp
  801d11:	5b                   	pop    %ebx
  801d12:	5e                   	pop    %esi
  801d13:	5f                   	pop    %edi
  801d14:	5d                   	pop    %ebp
  801d15:	c3                   	ret    
  801d16:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d1d:	8d 76 00             	lea    0x0(%esi),%esi
  801d20:	89 fd                	mov    %edi,%ebp
  801d22:	85 ff                	test   %edi,%edi
  801d24:	75 0b                	jne    801d31 <__umoddi3+0x91>
  801d26:	b8 01 00 00 00       	mov    $0x1,%eax
  801d2b:	31 d2                	xor    %edx,%edx
  801d2d:	f7 f7                	div    %edi
  801d2f:	89 c5                	mov    %eax,%ebp
  801d31:	89 d8                	mov    %ebx,%eax
  801d33:	31 d2                	xor    %edx,%edx
  801d35:	f7 f5                	div    %ebp
  801d37:	89 f0                	mov    %esi,%eax
  801d39:	f7 f5                	div    %ebp
  801d3b:	89 d0                	mov    %edx,%eax
  801d3d:	31 d2                	xor    %edx,%edx
  801d3f:	eb 8c                	jmp    801ccd <__umoddi3+0x2d>
  801d41:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d48:	89 e9                	mov    %ebp,%ecx
  801d4a:	ba 20 00 00 00       	mov    $0x20,%edx
  801d4f:	29 ea                	sub    %ebp,%edx
  801d51:	d3 e0                	shl    %cl,%eax
  801d53:	89 44 24 08          	mov    %eax,0x8(%esp)
  801d57:	89 d1                	mov    %edx,%ecx
  801d59:	89 f8                	mov    %edi,%eax
  801d5b:	d3 e8                	shr    %cl,%eax
  801d5d:	8b 4c 24 08          	mov    0x8(%esp),%ecx
  801d61:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d65:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d69:	09 c1                	or     %eax,%ecx
  801d6b:	89 d8                	mov    %ebx,%eax
  801d6d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801d71:	89 e9                	mov    %ebp,%ecx
  801d73:	d3 e7                	shl    %cl,%edi
  801d75:	89 d1                	mov    %edx,%ecx
  801d77:	d3 e8                	shr    %cl,%eax
  801d79:	89 e9                	mov    %ebp,%ecx
  801d7b:	89 7c 24 0c          	mov    %edi,0xc(%esp)
  801d7f:	d3 e3                	shl    %cl,%ebx
  801d81:	89 c7                	mov    %eax,%edi
  801d83:	89 d1                	mov    %edx,%ecx
  801d85:	89 f0                	mov    %esi,%eax
  801d87:	d3 e8                	shr    %cl,%eax
  801d89:	89 e9                	mov    %ebp,%ecx
  801d8b:	89 fa                	mov    %edi,%edx
  801d8d:	d3 e6                	shl    %cl,%esi
  801d8f:	09 d8                	or     %ebx,%eax
  801d91:	f7 74 24 08          	divl   0x8(%esp)
  801d95:	89 d1                	mov    %edx,%ecx
  801d97:	89 f3                	mov    %esi,%ebx
  801d99:	f7 64 24 0c          	mull   0xc(%esp)
  801d9d:	89 c6                	mov    %eax,%esi
  801d9f:	89 d7                	mov    %edx,%edi
  801da1:	39 d1                	cmp    %edx,%ecx
  801da3:	72 06                	jb     801dab <__umoddi3+0x10b>
  801da5:	75 10                	jne    801db7 <__umoddi3+0x117>
  801da7:	39 c3                	cmp    %eax,%ebx
  801da9:	73 0c                	jae    801db7 <__umoddi3+0x117>
  801dab:	2b 44 24 0c          	sub    0xc(%esp),%eax
  801daf:	1b 54 24 08          	sbb    0x8(%esp),%edx
  801db3:	89 d7                	mov    %edx,%edi
  801db5:	89 c6                	mov    %eax,%esi
  801db7:	89 ca                	mov    %ecx,%edx
  801db9:	0f b6 4c 24 04       	movzbl 0x4(%esp),%ecx
  801dbe:	29 f3                	sub    %esi,%ebx
  801dc0:	19 fa                	sbb    %edi,%edx
  801dc2:	89 d0                	mov    %edx,%eax
  801dc4:	d3 e0                	shl    %cl,%eax
  801dc6:	89 e9                	mov    %ebp,%ecx
  801dc8:	d3 eb                	shr    %cl,%ebx
  801dca:	d3 ea                	shr    %cl,%edx
  801dcc:	09 d8                	or     %ebx,%eax
  801dce:	83 c4 1c             	add    $0x1c,%esp
  801dd1:	5b                   	pop    %ebx
  801dd2:	5e                   	pop    %esi
  801dd3:	5f                   	pop    %edi
  801dd4:	5d                   	pop    %ebp
  801dd5:	c3                   	ret    
  801dd6:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801ddd:	8d 76 00             	lea    0x0(%esi),%esi
  801de0:	29 fe                	sub    %edi,%esi
  801de2:	19 c3                	sbb    %eax,%ebx
  801de4:	89 f2                	mov    %esi,%edx
  801de6:	89 d9                	mov    %ebx,%ecx
  801de8:	e9 1d ff ff ff       	jmp    801d0a <__umoddi3+0x6a>
