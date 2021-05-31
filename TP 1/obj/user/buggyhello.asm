
obj/user/buggyhello.debug:     formato del fichero elf32-i386


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
  80002c:	e8 1a 00 00 00       	call   80004b <libmain>
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
  80003a:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  80003d:	6a 01                	push   $0x1
  80003f:	6a 01                	push   $0x1
  800041:	e8 ba 00 00 00       	call   800100 <sys_cputs>
}
  800046:	83 c4 10             	add    $0x10,%esp
  800049:	c9                   	leave  
  80004a:	c3                   	ret    

0080004b <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004b:	f3 0f 1e fb          	endbr32 
  80004f:	55                   	push   %ebp
  800050:	89 e5                	mov    %esp,%ebp
  800052:	56                   	push   %esi
  800053:	53                   	push   %ebx
  800054:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800057:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	envid_t id = sys_getenvid();
  80005a:	e8 19 01 00 00       	call   800178 <sys_getenvid>
	if (id >= 0)
  80005f:	85 c0                	test   %eax,%eax
  800061:	78 12                	js     800075 <libmain+0x2a>
		thisenv = &envs[ENVX(id)];
  800063:	25 ff 03 00 00       	and    $0x3ff,%eax
  800068:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80006b:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800070:	a3 04 40 80 00       	mov    %eax,0x804004

	// save the name of the program so that panic() can use it
	if (argc > 0)
  800075:	85 db                	test   %ebx,%ebx
  800077:	7e 07                	jle    800080 <libmain+0x35>
		binaryname = argv[0];
  800079:	8b 06                	mov    (%esi),%eax
  80007b:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800080:	83 ec 08             	sub    $0x8,%esp
  800083:	56                   	push   %esi
  800084:	53                   	push   %ebx
  800085:	e8 a9 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80008a:	e8 0a 00 00 00       	call   800099 <exit>
}
  80008f:	83 c4 10             	add    $0x10,%esp
  800092:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800095:	5b                   	pop    %ebx
  800096:	5e                   	pop    %esi
  800097:	5d                   	pop    %ebp
  800098:	c3                   	ret    

00800099 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800099:	f3 0f 1e fb          	endbr32 
  80009d:	55                   	push   %ebp
  80009e:	89 e5                	mov    %esp,%ebp
  8000a0:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000a3:	e8 53 04 00 00       	call   8004fb <close_all>
	sys_env_destroy(0);
  8000a8:	83 ec 0c             	sub    $0xc,%esp
  8000ab:	6a 00                	push   $0x0
  8000ad:	e8 a0 00 00 00       	call   800152 <sys_env_destroy>
}
  8000b2:	83 c4 10             	add    $0x10,%esp
  8000b5:	c9                   	leave  
  8000b6:	c3                   	ret    

008000b7 <syscall>:
#include <inc/syscall.h>
#include <inc/lib.h>

static inline int32_t
syscall(int num, int check, uint32_t a1, uint32_t a2, uint32_t a3, uint32_t a4, uint32_t a5)
{
  8000b7:	55                   	push   %ebp
  8000b8:	89 e5                	mov    %esp,%ebp
  8000ba:	57                   	push   %edi
  8000bb:	56                   	push   %esi
  8000bc:	53                   	push   %ebx
  8000bd:	83 ec 1c             	sub    $0x1c,%esp
  8000c0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8000c3:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  8000c6:	89 ca                	mov    %ecx,%edx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.

	asm volatile("int %1\n"
  8000c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8000cb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8000ce:	8b 7d 10             	mov    0x10(%ebp),%edi
  8000d1:	8b 75 14             	mov    0x14(%ebp),%esi
  8000d4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000d6:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
  8000da:	74 04                	je     8000e0 <syscall+0x29>
  8000dc:	85 c0                	test   %eax,%eax
  8000de:	7f 08                	jg     8000e8 <syscall+0x31>
		panic("syscall %d returned %d (> 0)", num, ret);

	return ret;
}
  8000e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8000e3:	5b                   	pop    %ebx
  8000e4:	5e                   	pop    %esi
  8000e5:	5f                   	pop    %edi
  8000e6:	5d                   	pop    %ebp
  8000e7:	c3                   	ret    
		panic("syscall %d returned %d (> 0)", num, ret);
  8000e8:	83 ec 0c             	sub    $0xc,%esp
  8000eb:	50                   	push   %eax
  8000ec:	ff 75 e0             	pushl  -0x20(%ebp)
  8000ef:	68 ea 1d 80 00       	push   $0x801dea
  8000f4:	6a 23                	push   $0x23
  8000f6:	68 07 1e 80 00       	push   $0x801e07
  8000fb:	e8 51 0f 00 00       	call   801051 <_panic>

00800100 <sys_cputs>:

void
sys_cputs(const char *s, size_t len)
{
  800100:	f3 0f 1e fb          	endbr32 
  800104:	55                   	push   %ebp
  800105:	89 e5                	mov    %esp,%ebp
  800107:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
  80010a:	6a 00                	push   $0x0
  80010c:	6a 00                	push   $0x0
  80010e:	6a 00                	push   $0x0
  800110:	ff 75 0c             	pushl  0xc(%ebp)
  800113:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800116:	ba 00 00 00 00       	mov    $0x0,%edx
  80011b:	b8 00 00 00 00       	mov    $0x0,%eax
  800120:	e8 92 ff ff ff       	call   8000b7 <syscall>
}
  800125:	83 c4 10             	add    $0x10,%esp
  800128:	c9                   	leave  
  800129:	c3                   	ret    

0080012a <sys_cgetc>:

int
sys_cgetc(void)
{
  80012a:	f3 0f 1e fb          	endbr32 
  80012e:	55                   	push   %ebp
  80012f:	89 e5                	mov    %esp,%ebp
  800131:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
  800134:	6a 00                	push   $0x0
  800136:	6a 00                	push   $0x0
  800138:	6a 00                	push   $0x0
  80013a:	6a 00                	push   $0x0
  80013c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800141:	ba 00 00 00 00       	mov    $0x0,%edx
  800146:	b8 01 00 00 00       	mov    $0x1,%eax
  80014b:	e8 67 ff ff ff       	call   8000b7 <syscall>
}
  800150:	c9                   	leave  
  800151:	c3                   	ret    

00800152 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800152:	f3 0f 1e fb          	endbr32 
  800156:	55                   	push   %ebp
  800157:	89 e5                	mov    %esp,%ebp
  800159:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
  80015c:	6a 00                	push   $0x0
  80015e:	6a 00                	push   $0x0
  800160:	6a 00                	push   $0x0
  800162:	6a 00                	push   $0x0
  800164:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800167:	ba 01 00 00 00       	mov    $0x1,%edx
  80016c:	b8 03 00 00 00       	mov    $0x3,%eax
  800171:	e8 41 ff ff ff       	call   8000b7 <syscall>
}
  800176:	c9                   	leave  
  800177:	c3                   	ret    

00800178 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800178:	f3 0f 1e fb          	endbr32 
  80017c:	55                   	push   %ebp
  80017d:	89 e5                	mov    %esp,%ebp
  80017f:	83 ec 08             	sub    $0x8,%esp
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
  800182:	6a 00                	push   $0x0
  800184:	6a 00                	push   $0x0
  800186:	6a 00                	push   $0x0
  800188:	6a 00                	push   $0x0
  80018a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80018f:	ba 00 00 00 00       	mov    $0x0,%edx
  800194:	b8 02 00 00 00       	mov    $0x2,%eax
  800199:	e8 19 ff ff ff       	call   8000b7 <syscall>
}
  80019e:	c9                   	leave  
  80019f:	c3                   	ret    

008001a0 <sys_yield>:

void
sys_yield(void)
{
  8001a0:	f3 0f 1e fb          	endbr32 
  8001a4:	55                   	push   %ebp
  8001a5:	89 e5                	mov    %esp,%ebp
  8001a7:	83 ec 08             	sub    $0x8,%esp
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
  8001aa:	6a 00                	push   $0x0
  8001ac:	6a 00                	push   $0x0
  8001ae:	6a 00                	push   $0x0
  8001b0:	6a 00                	push   $0x0
  8001b2:	b9 00 00 00 00       	mov    $0x0,%ecx
  8001b7:	ba 00 00 00 00       	mov    $0x0,%edx
  8001bc:	b8 0b 00 00 00       	mov    $0xb,%eax
  8001c1:	e8 f1 fe ff ff       	call   8000b7 <syscall>
}
  8001c6:	83 c4 10             	add    $0x10,%esp
  8001c9:	c9                   	leave  
  8001ca:	c3                   	ret    

008001cb <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  8001cb:	f3 0f 1e fb          	endbr32 
  8001cf:	55                   	push   %ebp
  8001d0:	89 e5                	mov    %esp,%ebp
  8001d2:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
  8001d5:	6a 00                	push   $0x0
  8001d7:	6a 00                	push   $0x0
  8001d9:	ff 75 10             	pushl  0x10(%ebp)
  8001dc:	ff 75 0c             	pushl  0xc(%ebp)
  8001df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8001e2:	ba 01 00 00 00       	mov    $0x1,%edx
  8001e7:	b8 04 00 00 00       	mov    $0x4,%eax
  8001ec:	e8 c6 fe ff ff       	call   8000b7 <syscall>
}
  8001f1:	c9                   	leave  
  8001f2:	c3                   	ret    

008001f3 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001f3:	f3 0f 1e fb          	endbr32 
  8001f7:	55                   	push   %ebp
  8001f8:	89 e5                	mov    %esp,%ebp
  8001fa:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
  8001fd:	ff 75 18             	pushl  0x18(%ebp)
  800200:	ff 75 14             	pushl  0x14(%ebp)
  800203:	ff 75 10             	pushl  0x10(%ebp)
  800206:	ff 75 0c             	pushl  0xc(%ebp)
  800209:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80020c:	ba 01 00 00 00       	mov    $0x1,%edx
  800211:	b8 05 00 00 00       	mov    $0x5,%eax
  800216:	e8 9c fe ff ff       	call   8000b7 <syscall>
}
  80021b:	c9                   	leave  
  80021c:	c3                   	ret    

0080021d <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  80021d:	f3 0f 1e fb          	endbr32 
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
  800227:	6a 00                	push   $0x0
  800229:	6a 00                	push   $0x0
  80022b:	6a 00                	push   $0x0
  80022d:	ff 75 0c             	pushl  0xc(%ebp)
  800230:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800233:	ba 01 00 00 00       	mov    $0x1,%edx
  800238:	b8 06 00 00 00       	mov    $0x6,%eax
  80023d:	e8 75 fe ff ff       	call   8000b7 <syscall>
}
  800242:	c9                   	leave  
  800243:	c3                   	ret    

00800244 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800244:	f3 0f 1e fb          	endbr32 
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
  80024e:	6a 00                	push   $0x0
  800250:	6a 00                	push   $0x0
  800252:	6a 00                	push   $0x0
  800254:	ff 75 0c             	pushl  0xc(%ebp)
  800257:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80025a:	ba 01 00 00 00       	mov    $0x1,%edx
  80025f:	b8 08 00 00 00       	mov    $0x8,%eax
  800264:	e8 4e fe ff ff       	call   8000b7 <syscall>
}
  800269:	c9                   	leave  
  80026a:	c3                   	ret    

0080026b <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026b:	f3 0f 1e fb          	endbr32 
  80026f:	55                   	push   %ebp
  800270:	89 e5                	mov    %esp,%ebp
  800272:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
  800275:	6a 00                	push   $0x0
  800277:	6a 00                	push   $0x0
  800279:	6a 00                	push   $0x0
  80027b:	ff 75 0c             	pushl  0xc(%ebp)
  80027e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800281:	ba 01 00 00 00       	mov    $0x1,%edx
  800286:	b8 09 00 00 00       	mov    $0x9,%eax
  80028b:	e8 27 fe ff ff       	call   8000b7 <syscall>
}
  800290:	c9                   	leave  
  800291:	c3                   	ret    

00800292 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  800292:	f3 0f 1e fb          	endbr32 
  800296:	55                   	push   %ebp
  800297:	89 e5                	mov    %esp,%ebp
  800299:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
  80029c:	6a 00                	push   $0x0
  80029e:	6a 00                	push   $0x0
  8002a0:	6a 00                	push   $0x0
  8002a2:	ff 75 0c             	pushl  0xc(%ebp)
  8002a5:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002a8:	ba 01 00 00 00       	mov    $0x1,%edx
  8002ad:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b2:	e8 00 fe ff ff       	call   8000b7 <syscall>
}
  8002b7:	c9                   	leave  
  8002b8:	c3                   	ret    

008002b9 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002b9:	f3 0f 1e fb          	endbr32 
  8002bd:	55                   	push   %ebp
  8002be:	89 e5                	mov    %esp,%ebp
  8002c0:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
  8002c3:	6a 00                	push   $0x0
  8002c5:	ff 75 14             	pushl  0x14(%ebp)
  8002c8:	ff 75 10             	pushl  0x10(%ebp)
  8002cb:	ff 75 0c             	pushl  0xc(%ebp)
  8002ce:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002d1:	ba 00 00 00 00       	mov    $0x0,%edx
  8002d6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002db:	e8 d7 fd ff ff       	call   8000b7 <syscall>
}
  8002e0:	c9                   	leave  
  8002e1:	c3                   	ret    

008002e2 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002e2:	f3 0f 1e fb          	endbr32 
  8002e6:	55                   	push   %ebp
  8002e7:	89 e5                	mov    %esp,%ebp
  8002e9:	83 ec 08             	sub    $0x8,%esp
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
  8002ec:	6a 00                	push   $0x0
  8002ee:	6a 00                	push   $0x0
  8002f0:	6a 00                	push   $0x0
  8002f2:	6a 00                	push   $0x0
  8002f4:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8002f7:	ba 01 00 00 00       	mov    $0x1,%edx
  8002fc:	b8 0d 00 00 00       	mov    $0xd,%eax
  800301:	e8 b1 fd ff ff       	call   8000b7 <syscall>
}
  800306:	c9                   	leave  
  800307:	c3                   	ret    

00800308 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800308:	f3 0f 1e fb          	endbr32 
  80030c:	55                   	push   %ebp
  80030d:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80030f:	8b 45 08             	mov    0x8(%ebp),%eax
  800312:	05 00 00 00 30       	add    $0x30000000,%eax
  800317:	c1 e8 0c             	shr    $0xc,%eax
}
  80031a:	5d                   	pop    %ebp
  80031b:	c3                   	ret    

0080031c <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80031c:	f3 0f 1e fb          	endbr32 
  800320:	55                   	push   %ebp
  800321:	89 e5                	mov    %esp,%ebp
  800323:	83 ec 14             	sub    $0x14,%esp
	return INDEX2DATA(fd2num(fd));
  800326:	ff 75 08             	pushl  0x8(%ebp)
  800329:	e8 da ff ff ff       	call   800308 <fd2num>
  80032e:	83 c4 10             	add    $0x10,%esp
  800331:	c1 e0 0c             	shl    $0xc,%eax
  800334:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800339:	c9                   	leave  
  80033a:	c3                   	ret    

0080033b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80033b:	f3 0f 1e fb          	endbr32 
  80033f:	55                   	push   %ebp
  800340:	89 e5                	mov    %esp,%ebp
  800342:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800347:	89 c2                	mov    %eax,%edx
  800349:	c1 ea 16             	shr    $0x16,%edx
  80034c:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800353:	f6 c2 01             	test   $0x1,%dl
  800356:	74 2d                	je     800385 <fd_alloc+0x4a>
  800358:	89 c2                	mov    %eax,%edx
  80035a:	c1 ea 0c             	shr    $0xc,%edx
  80035d:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800364:	f6 c2 01             	test   $0x1,%dl
  800367:	74 1c                	je     800385 <fd_alloc+0x4a>
  800369:	05 00 10 00 00       	add    $0x1000,%eax
	for (i = 0; i < MAXFD; i++) {
  80036e:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  800373:	75 d2                	jne    800347 <fd_alloc+0xc>
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  800375:	8b 45 08             	mov    0x8(%ebp),%eax
  800378:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_MAX_OPEN;
  80037e:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
  800383:	eb 0a                	jmp    80038f <fd_alloc+0x54>
			*fd_store = fd;
  800385:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800388:	89 01                	mov    %eax,(%ecx)
			return 0;
  80038a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80038f:	5d                   	pop    %ebp
  800390:	c3                   	ret    

00800391 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  800391:	f3 0f 1e fb          	endbr32 
  800395:	55                   	push   %ebp
  800396:	89 e5                	mov    %esp,%ebp
  800398:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  80039b:	83 f8 1f             	cmp    $0x1f,%eax
  80039e:	77 30                	ja     8003d0 <fd_lookup+0x3f>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003a0:	c1 e0 0c             	shl    $0xc,%eax
  8003a3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003a8:	8b 15 00 dd 7b ef    	mov    0xef7bdd00,%edx
  8003ae:	f6 c2 01             	test   $0x1,%dl
  8003b1:	74 24                	je     8003d7 <fd_lookup+0x46>
  8003b3:	89 c2                	mov    %eax,%edx
  8003b5:	c1 ea 0c             	shr    $0xc,%edx
  8003b8:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003bf:	f6 c2 01             	test   $0x1,%dl
  8003c2:	74 1a                	je     8003de <fd_lookup+0x4d>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003c4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003c7:	89 02                	mov    %eax,(%edx)
	return 0;
  8003c9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8003ce:	5d                   	pop    %ebp
  8003cf:	c3                   	ret    
		return -E_INVAL;
  8003d0:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003d5:	eb f7                	jmp    8003ce <fd_lookup+0x3d>
		return -E_INVAL;
  8003d7:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003dc:	eb f0                	jmp    8003ce <fd_lookup+0x3d>
  8003de:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  8003e3:	eb e9                	jmp    8003ce <fd_lookup+0x3d>

008003e5 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  8003e5:	f3 0f 1e fb          	endbr32 
  8003e9:	55                   	push   %ebp
  8003ea:	89 e5                	mov    %esp,%ebp
  8003ec:	83 ec 08             	sub    $0x8,%esp
  8003ef:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8003f2:	ba 94 1e 80 00       	mov    $0x801e94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  8003f7:	b8 04 30 80 00       	mov    $0x803004,%eax
		if (devtab[i]->dev_id == dev_id) {
  8003fc:	39 08                	cmp    %ecx,(%eax)
  8003fe:	74 33                	je     800433 <dev_lookup+0x4e>
  800400:	83 c2 04             	add    $0x4,%edx
	for (i = 0; devtab[i]; i++)
  800403:	8b 02                	mov    (%edx),%eax
  800405:	85 c0                	test   %eax,%eax
  800407:	75 f3                	jne    8003fc <dev_lookup+0x17>
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800409:	a1 04 40 80 00       	mov    0x804004,%eax
  80040e:	8b 40 48             	mov    0x48(%eax),%eax
  800411:	83 ec 04             	sub    $0x4,%esp
  800414:	51                   	push   %ecx
  800415:	50                   	push   %eax
  800416:	68 18 1e 80 00       	push   $0x801e18
  80041b:	e8 18 0d 00 00       	call   801138 <cprintf>
	*dev = 0;
  800420:	8b 45 0c             	mov    0xc(%ebp),%eax
  800423:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800429:	83 c4 10             	add    $0x10,%esp
  80042c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800431:	c9                   	leave  
  800432:	c3                   	ret    
			*dev = devtab[i];
  800433:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800436:	89 01                	mov    %eax,(%ecx)
			return 0;
  800438:	b8 00 00 00 00       	mov    $0x0,%eax
  80043d:	eb f2                	jmp    800431 <dev_lookup+0x4c>

0080043f <fd_close>:
{
  80043f:	f3 0f 1e fb          	endbr32 
  800443:	55                   	push   %ebp
  800444:	89 e5                	mov    %esp,%ebp
  800446:	57                   	push   %edi
  800447:	56                   	push   %esi
  800448:	53                   	push   %ebx
  800449:	83 ec 28             	sub    $0x28,%esp
  80044c:	8b 75 08             	mov    0x8(%ebp),%esi
  80044f:	8b 7d 0c             	mov    0xc(%ebp),%edi
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800452:	56                   	push   %esi
  800453:	e8 b0 fe ff ff       	call   800308 <fd2num>
  800458:	83 c4 08             	add    $0x8,%esp
  80045b:	8d 55 e4             	lea    -0x1c(%ebp),%edx
  80045e:	52                   	push   %edx
  80045f:	50                   	push   %eax
  800460:	e8 2c ff ff ff       	call   800391 <fd_lookup>
  800465:	89 c3                	mov    %eax,%ebx
  800467:	83 c4 10             	add    $0x10,%esp
  80046a:	85 c0                	test   %eax,%eax
  80046c:	78 05                	js     800473 <fd_close+0x34>
	    || fd != fd2)
  80046e:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
  800471:	74 16                	je     800489 <fd_close+0x4a>
		return (must_exist ? r : 0);
  800473:	89 f8                	mov    %edi,%eax
  800475:	84 c0                	test   %al,%al
  800477:	b8 00 00 00 00       	mov    $0x0,%eax
  80047c:	0f 44 d8             	cmove  %eax,%ebx
}
  80047f:	89 d8                	mov    %ebx,%eax
  800481:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800484:	5b                   	pop    %ebx
  800485:	5e                   	pop    %esi
  800486:	5f                   	pop    %edi
  800487:	5d                   	pop    %ebp
  800488:	c3                   	ret    
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  800489:	83 ec 08             	sub    $0x8,%esp
  80048c:	8d 45 e0             	lea    -0x20(%ebp),%eax
  80048f:	50                   	push   %eax
  800490:	ff 36                	pushl  (%esi)
  800492:	e8 4e ff ff ff       	call   8003e5 <dev_lookup>
  800497:	89 c3                	mov    %eax,%ebx
  800499:	83 c4 10             	add    $0x10,%esp
  80049c:	85 c0                	test   %eax,%eax
  80049e:	78 1a                	js     8004ba <fd_close+0x7b>
		if (dev->dev_close)
  8004a0:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8004a3:	8b 40 10             	mov    0x10(%eax),%eax
			r = 0;
  8004a6:	bb 00 00 00 00       	mov    $0x0,%ebx
		if (dev->dev_close)
  8004ab:	85 c0                	test   %eax,%eax
  8004ad:	74 0b                	je     8004ba <fd_close+0x7b>
			r = (*dev->dev_close)(fd);
  8004af:	83 ec 0c             	sub    $0xc,%esp
  8004b2:	56                   	push   %esi
  8004b3:	ff d0                	call   *%eax
  8004b5:	89 c3                	mov    %eax,%ebx
  8004b7:	83 c4 10             	add    $0x10,%esp
	(void) sys_page_unmap(0, fd);
  8004ba:	83 ec 08             	sub    $0x8,%esp
  8004bd:	56                   	push   %esi
  8004be:	6a 00                	push   $0x0
  8004c0:	e8 58 fd ff ff       	call   80021d <sys_page_unmap>
	return r;
  8004c5:	83 c4 10             	add    $0x10,%esp
  8004c8:	eb b5                	jmp    80047f <fd_close+0x40>

008004ca <close>:

int
close(int fdnum)
{
  8004ca:	f3 0f 1e fb          	endbr32 
  8004ce:	55                   	push   %ebp
  8004cf:	89 e5                	mov    %esp,%ebp
  8004d1:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004d4:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004d7:	50                   	push   %eax
  8004d8:	ff 75 08             	pushl  0x8(%ebp)
  8004db:	e8 b1 fe ff ff       	call   800391 <fd_lookup>
  8004e0:	83 c4 10             	add    $0x10,%esp
  8004e3:	85 c0                	test   %eax,%eax
  8004e5:	79 02                	jns    8004e9 <close+0x1f>
		return r;
	else
		return fd_close(fd, 1);
}
  8004e7:	c9                   	leave  
  8004e8:	c3                   	ret    
		return fd_close(fd, 1);
  8004e9:	83 ec 08             	sub    $0x8,%esp
  8004ec:	6a 01                	push   $0x1
  8004ee:	ff 75 f4             	pushl  -0xc(%ebp)
  8004f1:	e8 49 ff ff ff       	call   80043f <fd_close>
  8004f6:	83 c4 10             	add    $0x10,%esp
  8004f9:	eb ec                	jmp    8004e7 <close+0x1d>

008004fb <close_all>:

void
close_all(void)
{
  8004fb:	f3 0f 1e fb          	endbr32 
  8004ff:	55                   	push   %ebp
  800500:	89 e5                	mov    %esp,%ebp
  800502:	53                   	push   %ebx
  800503:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800506:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80050b:	83 ec 0c             	sub    $0xc,%esp
  80050e:	53                   	push   %ebx
  80050f:	e8 b6 ff ff ff       	call   8004ca <close>
	for (i = 0; i < MAXFD; i++)
  800514:	83 c3 01             	add    $0x1,%ebx
  800517:	83 c4 10             	add    $0x10,%esp
  80051a:	83 fb 20             	cmp    $0x20,%ebx
  80051d:	75 ec                	jne    80050b <close_all+0x10>
}
  80051f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800522:	c9                   	leave  
  800523:	c3                   	ret    

00800524 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800524:	f3 0f 1e fb          	endbr32 
  800528:	55                   	push   %ebp
  800529:	89 e5                	mov    %esp,%ebp
  80052b:	57                   	push   %edi
  80052c:	56                   	push   %esi
  80052d:	53                   	push   %ebx
  80052e:	83 ec 24             	sub    $0x24,%esp
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800531:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800534:	50                   	push   %eax
  800535:	ff 75 08             	pushl  0x8(%ebp)
  800538:	e8 54 fe ff ff       	call   800391 <fd_lookup>
  80053d:	89 c3                	mov    %eax,%ebx
  80053f:	83 c4 10             	add    $0x10,%esp
  800542:	85 c0                	test   %eax,%eax
  800544:	0f 88 81 00 00 00    	js     8005cb <dup+0xa7>
		return r;
	close(newfdnum);
  80054a:	83 ec 0c             	sub    $0xc,%esp
  80054d:	ff 75 0c             	pushl  0xc(%ebp)
  800550:	e8 75 ff ff ff       	call   8004ca <close>

	newfd = INDEX2FD(newfdnum);
  800555:	8b 75 0c             	mov    0xc(%ebp),%esi
  800558:	c1 e6 0c             	shl    $0xc,%esi
  80055b:	81 ee 00 00 00 30    	sub    $0x30000000,%esi
	ova = fd2data(oldfd);
  800561:	83 c4 04             	add    $0x4,%esp
  800564:	ff 75 e4             	pushl  -0x1c(%ebp)
  800567:	e8 b0 fd ff ff       	call   80031c <fd2data>
  80056c:	89 c3                	mov    %eax,%ebx
	nva = fd2data(newfd);
  80056e:	89 34 24             	mov    %esi,(%esp)
  800571:	e8 a6 fd ff ff       	call   80031c <fd2data>
  800576:	83 c4 10             	add    $0x10,%esp
  800579:	89 c7                	mov    %eax,%edi

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80057b:	89 d8                	mov    %ebx,%eax
  80057d:	c1 e8 16             	shr    $0x16,%eax
  800580:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800587:	a8 01                	test   $0x1,%al
  800589:	74 11                	je     80059c <dup+0x78>
  80058b:	89 d8                	mov    %ebx,%eax
  80058d:	c1 e8 0c             	shr    $0xc,%eax
  800590:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  800597:	f6 c2 01             	test   $0x1,%dl
  80059a:	75 39                	jne    8005d5 <dup+0xb1>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80059c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80059f:	89 d0                	mov    %edx,%eax
  8005a1:	c1 e8 0c             	shr    $0xc,%eax
  8005a4:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ab:	83 ec 0c             	sub    $0xc,%esp
  8005ae:	25 07 0e 00 00       	and    $0xe07,%eax
  8005b3:	50                   	push   %eax
  8005b4:	56                   	push   %esi
  8005b5:	6a 00                	push   $0x0
  8005b7:	52                   	push   %edx
  8005b8:	6a 00                	push   $0x0
  8005ba:	e8 34 fc ff ff       	call   8001f3 <sys_page_map>
  8005bf:	89 c3                	mov    %eax,%ebx
  8005c1:	83 c4 20             	add    $0x20,%esp
  8005c4:	85 c0                	test   %eax,%eax
  8005c6:	78 31                	js     8005f9 <dup+0xd5>
		goto err;

	return newfdnum;
  8005c8:	8b 5d 0c             	mov    0xc(%ebp),%ebx

err:
	sys_page_unmap(0, newfd);
	sys_page_unmap(0, nva);
	return r;
}
  8005cb:	89 d8                	mov    %ebx,%eax
  8005cd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8005d0:	5b                   	pop    %ebx
  8005d1:	5e                   	pop    %esi
  8005d2:	5f                   	pop    %edi
  8005d3:	5d                   	pop    %ebp
  8005d4:	c3                   	ret    
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005dc:	83 ec 0c             	sub    $0xc,%esp
  8005df:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e4:	50                   	push   %eax
  8005e5:	57                   	push   %edi
  8005e6:	6a 00                	push   $0x0
  8005e8:	53                   	push   %ebx
  8005e9:	6a 00                	push   $0x0
  8005eb:	e8 03 fc ff ff       	call   8001f3 <sys_page_map>
  8005f0:	89 c3                	mov    %eax,%ebx
  8005f2:	83 c4 20             	add    $0x20,%esp
  8005f5:	85 c0                	test   %eax,%eax
  8005f7:	79 a3                	jns    80059c <dup+0x78>
	sys_page_unmap(0, newfd);
  8005f9:	83 ec 08             	sub    $0x8,%esp
  8005fc:	56                   	push   %esi
  8005fd:	6a 00                	push   $0x0
  8005ff:	e8 19 fc ff ff       	call   80021d <sys_page_unmap>
	sys_page_unmap(0, nva);
  800604:	83 c4 08             	add    $0x8,%esp
  800607:	57                   	push   %edi
  800608:	6a 00                	push   $0x0
  80060a:	e8 0e fc ff ff       	call   80021d <sys_page_unmap>
	return r;
  80060f:	83 c4 10             	add    $0x10,%esp
  800612:	eb b7                	jmp    8005cb <dup+0xa7>

00800614 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800614:	f3 0f 1e fb          	endbr32 
  800618:	55                   	push   %ebp
  800619:	89 e5                	mov    %esp,%ebp
  80061b:	53                   	push   %ebx
  80061c:	83 ec 1c             	sub    $0x1c,%esp
  80061f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800622:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800625:	50                   	push   %eax
  800626:	53                   	push   %ebx
  800627:	e8 65 fd ff ff       	call   800391 <fd_lookup>
  80062c:	83 c4 10             	add    $0x10,%esp
  80062f:	85 c0                	test   %eax,%eax
  800631:	78 3f                	js     800672 <read+0x5e>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800633:	83 ec 08             	sub    $0x8,%esp
  800636:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800639:	50                   	push   %eax
  80063a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80063d:	ff 30                	pushl  (%eax)
  80063f:	e8 a1 fd ff ff       	call   8003e5 <dev_lookup>
  800644:	83 c4 10             	add    $0x10,%esp
  800647:	85 c0                	test   %eax,%eax
  800649:	78 27                	js     800672 <read+0x5e>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80064b:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80064e:	8b 42 08             	mov    0x8(%edx),%eax
  800651:	83 e0 03             	and    $0x3,%eax
  800654:	83 f8 01             	cmp    $0x1,%eax
  800657:	74 1e                	je     800677 <read+0x63>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
  800659:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80065c:	8b 40 08             	mov    0x8(%eax),%eax
  80065f:	85 c0                	test   %eax,%eax
  800661:	74 35                	je     800698 <read+0x84>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800663:	83 ec 04             	sub    $0x4,%esp
  800666:	ff 75 10             	pushl  0x10(%ebp)
  800669:	ff 75 0c             	pushl  0xc(%ebp)
  80066c:	52                   	push   %edx
  80066d:	ff d0                	call   *%eax
  80066f:	83 c4 10             	add    $0x10,%esp
}
  800672:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800675:	c9                   	leave  
  800676:	c3                   	ret    
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800677:	a1 04 40 80 00       	mov    0x804004,%eax
  80067c:	8b 40 48             	mov    0x48(%eax),%eax
  80067f:	83 ec 04             	sub    $0x4,%esp
  800682:	53                   	push   %ebx
  800683:	50                   	push   %eax
  800684:	68 59 1e 80 00       	push   $0x801e59
  800689:	e8 aa 0a 00 00       	call   801138 <cprintf>
		return -E_INVAL;
  80068e:	83 c4 10             	add    $0x10,%esp
  800691:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800696:	eb da                	jmp    800672 <read+0x5e>
		return -E_NOT_SUPP;
  800698:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80069d:	eb d3                	jmp    800672 <read+0x5e>

0080069f <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  80069f:	f3 0f 1e fb          	endbr32 
  8006a3:	55                   	push   %ebp
  8006a4:	89 e5                	mov    %esp,%ebp
  8006a6:	57                   	push   %edi
  8006a7:	56                   	push   %esi
  8006a8:	53                   	push   %ebx
  8006a9:	83 ec 0c             	sub    $0xc,%esp
  8006ac:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006af:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006b7:	eb 02                	jmp    8006bb <readn+0x1c>
  8006b9:	01 c3                	add    %eax,%ebx
  8006bb:	39 f3                	cmp    %esi,%ebx
  8006bd:	73 21                	jae    8006e0 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006bf:	83 ec 04             	sub    $0x4,%esp
  8006c2:	89 f0                	mov    %esi,%eax
  8006c4:	29 d8                	sub    %ebx,%eax
  8006c6:	50                   	push   %eax
  8006c7:	89 d8                	mov    %ebx,%eax
  8006c9:	03 45 0c             	add    0xc(%ebp),%eax
  8006cc:	50                   	push   %eax
  8006cd:	57                   	push   %edi
  8006ce:	e8 41 ff ff ff       	call   800614 <read>
		if (m < 0)
  8006d3:	83 c4 10             	add    $0x10,%esp
  8006d6:	85 c0                	test   %eax,%eax
  8006d8:	78 04                	js     8006de <readn+0x3f>
			return m;
		if (m == 0)
  8006da:	75 dd                	jne    8006b9 <readn+0x1a>
  8006dc:	eb 02                	jmp    8006e0 <readn+0x41>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006de:	89 c3                	mov    %eax,%ebx
			break;
	}
	return tot;
}
  8006e0:	89 d8                	mov    %ebx,%eax
  8006e2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006e5:	5b                   	pop    %ebx
  8006e6:	5e                   	pop    %esi
  8006e7:	5f                   	pop    %edi
  8006e8:	5d                   	pop    %ebp
  8006e9:	c3                   	ret    

008006ea <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  8006ea:	f3 0f 1e fb          	endbr32 
  8006ee:	55                   	push   %ebp
  8006ef:	89 e5                	mov    %esp,%ebp
  8006f1:	53                   	push   %ebx
  8006f2:	83 ec 1c             	sub    $0x1c,%esp
  8006f5:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  8006f8:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8006fb:	50                   	push   %eax
  8006fc:	53                   	push   %ebx
  8006fd:	e8 8f fc ff ff       	call   800391 <fd_lookup>
  800702:	83 c4 10             	add    $0x10,%esp
  800705:	85 c0                	test   %eax,%eax
  800707:	78 3a                	js     800743 <write+0x59>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800709:	83 ec 08             	sub    $0x8,%esp
  80070c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80070f:	50                   	push   %eax
  800710:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800713:	ff 30                	pushl  (%eax)
  800715:	e8 cb fc ff ff       	call   8003e5 <dev_lookup>
  80071a:	83 c4 10             	add    $0x10,%esp
  80071d:	85 c0                	test   %eax,%eax
  80071f:	78 22                	js     800743 <write+0x59>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800721:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800724:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800728:	74 1e                	je     800748 <write+0x5e>
		return -E_INVAL;
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  80072a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80072d:	8b 52 0c             	mov    0xc(%edx),%edx
  800730:	85 d2                	test   %edx,%edx
  800732:	74 35                	je     800769 <write+0x7f>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800734:	83 ec 04             	sub    $0x4,%esp
  800737:	ff 75 10             	pushl  0x10(%ebp)
  80073a:	ff 75 0c             	pushl  0xc(%ebp)
  80073d:	50                   	push   %eax
  80073e:	ff d2                	call   *%edx
  800740:	83 c4 10             	add    $0x10,%esp
}
  800743:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800746:	c9                   	leave  
  800747:	c3                   	ret    
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800748:	a1 04 40 80 00       	mov    0x804004,%eax
  80074d:	8b 40 48             	mov    0x48(%eax),%eax
  800750:	83 ec 04             	sub    $0x4,%esp
  800753:	53                   	push   %ebx
  800754:	50                   	push   %eax
  800755:	68 75 1e 80 00       	push   $0x801e75
  80075a:	e8 d9 09 00 00       	call   801138 <cprintf>
		return -E_INVAL;
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800767:	eb da                	jmp    800743 <write+0x59>
		return -E_NOT_SUPP;
  800769:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80076e:	eb d3                	jmp    800743 <write+0x59>

00800770 <seek>:

int
seek(int fdnum, off_t offset)
{
  800770:	f3 0f 1e fb          	endbr32 
  800774:	55                   	push   %ebp
  800775:	89 e5                	mov    %esp,%ebp
  800777:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80077a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80077d:	50                   	push   %eax
  80077e:	ff 75 08             	pushl  0x8(%ebp)
  800781:	e8 0b fc ff ff       	call   800391 <fd_lookup>
  800786:	83 c4 10             	add    $0x10,%esp
  800789:	85 c0                	test   %eax,%eax
  80078b:	78 0e                	js     80079b <seek+0x2b>
		return r;
	fd->fd_offset = offset;
  80078d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800790:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800793:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  800796:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    

0080079d <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  80079d:	f3 0f 1e fb          	endbr32 
  8007a1:	55                   	push   %ebp
  8007a2:	89 e5                	mov    %esp,%ebp
  8007a4:	53                   	push   %ebx
  8007a5:	83 ec 1c             	sub    $0x1c,%esp
  8007a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007ab:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ae:	50                   	push   %eax
  8007af:	53                   	push   %ebx
  8007b0:	e8 dc fb ff ff       	call   800391 <fd_lookup>
  8007b5:	83 c4 10             	add    $0x10,%esp
  8007b8:	85 c0                	test   %eax,%eax
  8007ba:	78 37                	js     8007f3 <ftruncate+0x56>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007bc:	83 ec 08             	sub    $0x8,%esp
  8007bf:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007c2:	50                   	push   %eax
  8007c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007c6:	ff 30                	pushl  (%eax)
  8007c8:	e8 18 fc ff ff       	call   8003e5 <dev_lookup>
  8007cd:	83 c4 10             	add    $0x10,%esp
  8007d0:	85 c0                	test   %eax,%eax
  8007d2:	78 1f                	js     8007f3 <ftruncate+0x56>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007d4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007d7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007db:	74 1b                	je     8007f8 <ftruncate+0x5b>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
  8007dd:	8b 55 f4             	mov    -0xc(%ebp),%edx
  8007e0:	8b 52 18             	mov    0x18(%edx),%edx
  8007e3:	85 d2                	test   %edx,%edx
  8007e5:	74 32                	je     800819 <ftruncate+0x7c>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  8007e7:	83 ec 08             	sub    $0x8,%esp
  8007ea:	ff 75 0c             	pushl  0xc(%ebp)
  8007ed:	50                   	push   %eax
  8007ee:	ff d2                	call   *%edx
  8007f0:	83 c4 10             	add    $0x10,%esp
}
  8007f3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007f6:	c9                   	leave  
  8007f7:	c3                   	ret    
			thisenv->env_id, fdnum);
  8007f8:	a1 04 40 80 00       	mov    0x804004,%eax
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007fd:	8b 40 48             	mov    0x48(%eax),%eax
  800800:	83 ec 04             	sub    $0x4,%esp
  800803:	53                   	push   %ebx
  800804:	50                   	push   %eax
  800805:	68 38 1e 80 00       	push   $0x801e38
  80080a:	e8 29 09 00 00       	call   801138 <cprintf>
		return -E_INVAL;
  80080f:	83 c4 10             	add    $0x10,%esp
  800812:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800817:	eb da                	jmp    8007f3 <ftruncate+0x56>
		return -E_NOT_SUPP;
  800819:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  80081e:	eb d3                	jmp    8007f3 <ftruncate+0x56>

00800820 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800820:	f3 0f 1e fb          	endbr32 
  800824:	55                   	push   %ebp
  800825:	89 e5                	mov    %esp,%ebp
  800827:	53                   	push   %ebx
  800828:	83 ec 1c             	sub    $0x1c,%esp
  80082b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80082e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800831:	50                   	push   %eax
  800832:	ff 75 08             	pushl  0x8(%ebp)
  800835:	e8 57 fb ff ff       	call   800391 <fd_lookup>
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	85 c0                	test   %eax,%eax
  80083f:	78 4b                	js     80088c <fstat+0x6c>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800841:	83 ec 08             	sub    $0x8,%esp
  800844:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800847:	50                   	push   %eax
  800848:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80084b:	ff 30                	pushl  (%eax)
  80084d:	e8 93 fb ff ff       	call   8003e5 <dev_lookup>
  800852:	83 c4 10             	add    $0x10,%esp
  800855:	85 c0                	test   %eax,%eax
  800857:	78 33                	js     80088c <fstat+0x6c>
		return r;
	if (!dev->dev_stat)
  800859:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80085c:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800860:	74 2f                	je     800891 <fstat+0x71>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800862:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800865:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80086c:	00 00 00 
	stat->st_isdir = 0;
  80086f:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800876:	00 00 00 
	stat->st_dev = dev;
  800879:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80087f:	83 ec 08             	sub    $0x8,%esp
  800882:	53                   	push   %ebx
  800883:	ff 75 f0             	pushl  -0x10(%ebp)
  800886:	ff 50 14             	call   *0x14(%eax)
  800889:	83 c4 10             	add    $0x10,%esp
}
  80088c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80088f:	c9                   	leave  
  800890:	c3                   	ret    
		return -E_NOT_SUPP;
  800891:	b8 f1 ff ff ff       	mov    $0xfffffff1,%eax
  800896:	eb f4                	jmp    80088c <fstat+0x6c>

00800898 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  800898:	f3 0f 1e fb          	endbr32 
  80089c:	55                   	push   %ebp
  80089d:	89 e5                	mov    %esp,%ebp
  80089f:	56                   	push   %esi
  8008a0:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008a1:	83 ec 08             	sub    $0x8,%esp
  8008a4:	6a 00                	push   $0x0
  8008a6:	ff 75 08             	pushl  0x8(%ebp)
  8008a9:	e8 fb 01 00 00       	call   800aa9 <open>
  8008ae:	89 c3                	mov    %eax,%ebx
  8008b0:	83 c4 10             	add    $0x10,%esp
  8008b3:	85 c0                	test   %eax,%eax
  8008b5:	78 1b                	js     8008d2 <stat+0x3a>
		return fd;
	r = fstat(fd, stat);
  8008b7:	83 ec 08             	sub    $0x8,%esp
  8008ba:	ff 75 0c             	pushl  0xc(%ebp)
  8008bd:	50                   	push   %eax
  8008be:	e8 5d ff ff ff       	call   800820 <fstat>
  8008c3:	89 c6                	mov    %eax,%esi
	close(fd);
  8008c5:	89 1c 24             	mov    %ebx,(%esp)
  8008c8:	e8 fd fb ff ff       	call   8004ca <close>
	return r;
  8008cd:	83 c4 10             	add    $0x10,%esp
  8008d0:	89 f3                	mov    %esi,%ebx
}
  8008d2:	89 d8                	mov    %ebx,%eax
  8008d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008d7:	5b                   	pop    %ebx
  8008d8:	5e                   	pop    %esi
  8008d9:	5d                   	pop    %ebp
  8008da:	c3                   	ret    

008008db <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008db:	55                   	push   %ebp
  8008dc:	89 e5                	mov    %esp,%ebp
  8008de:	56                   	push   %esi
  8008df:	53                   	push   %ebx
  8008e0:	89 c6                	mov    %eax,%esi
  8008e2:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  8008e4:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  8008eb:	74 27                	je     800914 <fsipc+0x39>
		cprintf("[%08x] fsipc %d %08x\n",
		        thisenv->env_id,
		        type,
		        *(uint32_t *) &fsipcbuf);

	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  8008ed:	6a 07                	push   $0x7
  8008ef:	68 00 50 80 00       	push   $0x805000
  8008f4:	56                   	push   %esi
  8008f5:	ff 35 00 40 80 00    	pushl  0x804000
  8008fb:	e8 84 11 00 00       	call   801a84 <ipc_send>
	return ipc_recv(NULL, dstva, NULL);
  800900:	83 c4 0c             	add    $0xc,%esp
  800903:	6a 00                	push   $0x0
  800905:	53                   	push   %ebx
  800906:	6a 00                	push   $0x0
  800908:	e8 09 11 00 00       	call   801a16 <ipc_recv>
}
  80090d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800910:	5b                   	pop    %ebx
  800911:	5e                   	pop    %esi
  800912:	5d                   	pop    %ebp
  800913:	c3                   	ret    
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800914:	83 ec 0c             	sub    $0xc,%esp
  800917:	6a 01                	push   $0x1
  800919:	e8 cb 11 00 00       	call   801ae9 <ipc_find_env>
  80091e:	a3 00 40 80 00       	mov    %eax,0x804000
  800923:	83 c4 10             	add    $0x10,%esp
  800926:	eb c5                	jmp    8008ed <fsipc+0x12>

00800928 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800928:	f3 0f 1e fb          	endbr32 
  80092c:	55                   	push   %ebp
  80092d:	89 e5                	mov    %esp,%ebp
  80092f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800932:	8b 45 08             	mov    0x8(%ebp),%eax
  800935:	8b 40 0c             	mov    0xc(%eax),%eax
  800938:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80093d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800940:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800945:	ba 00 00 00 00       	mov    $0x0,%edx
  80094a:	b8 02 00 00 00       	mov    $0x2,%eax
  80094f:	e8 87 ff ff ff       	call   8008db <fsipc>
}
  800954:	c9                   	leave  
  800955:	c3                   	ret    

00800956 <devfile_flush>:
{
  800956:	f3 0f 1e fb          	endbr32 
  80095a:	55                   	push   %ebp
  80095b:	89 e5                	mov    %esp,%ebp
  80095d:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800960:	8b 45 08             	mov    0x8(%ebp),%eax
  800963:	8b 40 0c             	mov    0xc(%eax),%eax
  800966:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  80096b:	ba 00 00 00 00       	mov    $0x0,%edx
  800970:	b8 06 00 00 00       	mov    $0x6,%eax
  800975:	e8 61 ff ff ff       	call   8008db <fsipc>
}
  80097a:	c9                   	leave  
  80097b:	c3                   	ret    

0080097c <devfile_stat>:
{
  80097c:	f3 0f 1e fb          	endbr32 
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	53                   	push   %ebx
  800984:	83 ec 04             	sub    $0x4,%esp
  800987:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80098a:	8b 45 08             	mov    0x8(%ebp),%eax
  80098d:	8b 40 0c             	mov    0xc(%eax),%eax
  800990:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  800995:	ba 00 00 00 00       	mov    $0x0,%edx
  80099a:	b8 05 00 00 00       	mov    $0x5,%eax
  80099f:	e8 37 ff ff ff       	call   8008db <fsipc>
  8009a4:	85 c0                	test   %eax,%eax
  8009a6:	78 2c                	js     8009d4 <devfile_stat+0x58>
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009a8:	83 ec 08             	sub    $0x8,%esp
  8009ab:	68 00 50 80 00       	push   $0x805000
  8009b0:	53                   	push   %ebx
  8009b1:	e8 ec 0c 00 00       	call   8016a2 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009b6:	a1 80 50 80 00       	mov    0x805080,%eax
  8009bb:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009c1:	a1 84 50 80 00       	mov    0x805084,%eax
  8009c6:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009cc:	83 c4 10             	add    $0x10,%esp
  8009cf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009d4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009d7:	c9                   	leave  
  8009d8:	c3                   	ret    

008009d9 <devfile_write>:
{
  8009d9:	f3 0f 1e fb          	endbr32 
  8009dd:	55                   	push   %ebp
  8009de:	89 e5                	mov    %esp,%ebp
  8009e0:	83 ec 0c             	sub    $0xc,%esp
  8009e3:	8b 45 10             	mov    0x10(%ebp),%eax
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8009e9:	8b 52 0c             	mov    0xc(%edx),%edx
  8009ec:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009f2:	3d f8 0f 00 00       	cmp    $0xff8,%eax
  8009f7:	ba f8 0f 00 00       	mov    $0xff8,%edx
  8009fc:	0f 47 c2             	cmova  %edx,%eax
  8009ff:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, fsipcbuf.write.req_n);
  800a04:	50                   	push   %eax
  800a05:	ff 75 0c             	pushl  0xc(%ebp)
  800a08:	68 08 50 80 00       	push   $0x805008
  800a0d:	e8 48 0e 00 00       	call   80185a <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a12:	ba 00 00 00 00       	mov    $0x0,%edx
  800a17:	b8 04 00 00 00       	mov    $0x4,%eax
  800a1c:	e8 ba fe ff ff       	call   8008db <fsipc>
}
  800a21:	c9                   	leave  
  800a22:	c3                   	ret    

00800a23 <devfile_read>:
{
  800a23:	f3 0f 1e fb          	endbr32 
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	56                   	push   %esi
  800a2b:	53                   	push   %ebx
  800a2c:	8b 75 10             	mov    0x10(%ebp),%esi
	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a32:	8b 40 0c             	mov    0xc(%eax),%eax
  800a35:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a3a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a40:	ba 00 00 00 00       	mov    $0x0,%edx
  800a45:	b8 03 00 00 00       	mov    $0x3,%eax
  800a4a:	e8 8c fe ff ff       	call   8008db <fsipc>
  800a4f:	89 c3                	mov    %eax,%ebx
  800a51:	85 c0                	test   %eax,%eax
  800a53:	78 1f                	js     800a74 <devfile_read+0x51>
	assert(r <= n);
  800a55:	39 f0                	cmp    %esi,%eax
  800a57:	77 24                	ja     800a7d <devfile_read+0x5a>
	assert(r <= PGSIZE);
  800a59:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a5e:	7f 33                	jg     800a93 <devfile_read+0x70>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a60:	83 ec 04             	sub    $0x4,%esp
  800a63:	50                   	push   %eax
  800a64:	68 00 50 80 00       	push   $0x805000
  800a69:	ff 75 0c             	pushl  0xc(%ebp)
  800a6c:	e8 e9 0d 00 00       	call   80185a <memmove>
	return r;
  800a71:	83 c4 10             	add    $0x10,%esp
}
  800a74:	89 d8                	mov    %ebx,%eax
  800a76:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800a79:	5b                   	pop    %ebx
  800a7a:	5e                   	pop    %esi
  800a7b:	5d                   	pop    %ebp
  800a7c:	c3                   	ret    
	assert(r <= n);
  800a7d:	68 a4 1e 80 00       	push   $0x801ea4
  800a82:	68 ab 1e 80 00       	push   $0x801eab
  800a87:	6a 7c                	push   $0x7c
  800a89:	68 c0 1e 80 00       	push   $0x801ec0
  800a8e:	e8 be 05 00 00       	call   801051 <_panic>
	assert(r <= PGSIZE);
  800a93:	68 cb 1e 80 00       	push   $0x801ecb
  800a98:	68 ab 1e 80 00       	push   $0x801eab
  800a9d:	6a 7d                	push   $0x7d
  800a9f:	68 c0 1e 80 00       	push   $0x801ec0
  800aa4:	e8 a8 05 00 00       	call   801051 <_panic>

00800aa9 <open>:
{
  800aa9:	f3 0f 1e fb          	endbr32 
  800aad:	55                   	push   %ebp
  800aae:	89 e5                	mov    %esp,%ebp
  800ab0:	56                   	push   %esi
  800ab1:	53                   	push   %ebx
  800ab2:	83 ec 1c             	sub    $0x1c,%esp
  800ab5:	8b 75 08             	mov    0x8(%ebp),%esi
	if (strlen(path) >= MAXPATHLEN)
  800ab8:	56                   	push   %esi
  800ab9:	e8 a1 0b 00 00       	call   80165f <strlen>
  800abe:	83 c4 10             	add    $0x10,%esp
  800ac1:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ac6:	7f 6c                	jg     800b34 <open+0x8b>
	if ((r = fd_alloc(&fd)) < 0)
  800ac8:	83 ec 0c             	sub    $0xc,%esp
  800acb:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ace:	50                   	push   %eax
  800acf:	e8 67 f8 ff ff       	call   80033b <fd_alloc>
  800ad4:	89 c3                	mov    %eax,%ebx
  800ad6:	83 c4 10             	add    $0x10,%esp
  800ad9:	85 c0                	test   %eax,%eax
  800adb:	78 3c                	js     800b19 <open+0x70>
	strcpy(fsipcbuf.open.req_path, path);
  800add:	83 ec 08             	sub    $0x8,%esp
  800ae0:	56                   	push   %esi
  800ae1:	68 00 50 80 00       	push   $0x805000
  800ae6:	e8 b7 0b 00 00       	call   8016a2 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800aeb:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aee:	a3 00 54 80 00       	mov    %eax,0x805400
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800af3:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800af6:	b8 01 00 00 00       	mov    $0x1,%eax
  800afb:	e8 db fd ff ff       	call   8008db <fsipc>
  800b00:	89 c3                	mov    %eax,%ebx
  800b02:	83 c4 10             	add    $0x10,%esp
  800b05:	85 c0                	test   %eax,%eax
  800b07:	78 19                	js     800b22 <open+0x79>
	return fd2num(fd);
  800b09:	83 ec 0c             	sub    $0xc,%esp
  800b0c:	ff 75 f4             	pushl  -0xc(%ebp)
  800b0f:	e8 f4 f7 ff ff       	call   800308 <fd2num>
  800b14:	89 c3                	mov    %eax,%ebx
  800b16:	83 c4 10             	add    $0x10,%esp
}
  800b19:	89 d8                	mov    %ebx,%eax
  800b1b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b1e:	5b                   	pop    %ebx
  800b1f:	5e                   	pop    %esi
  800b20:	5d                   	pop    %ebp
  800b21:	c3                   	ret    
		fd_close(fd, 0);
  800b22:	83 ec 08             	sub    $0x8,%esp
  800b25:	6a 00                	push   $0x0
  800b27:	ff 75 f4             	pushl  -0xc(%ebp)
  800b2a:	e8 10 f9 ff ff       	call   80043f <fd_close>
		return r;
  800b2f:	83 c4 10             	add    $0x10,%esp
  800b32:	eb e5                	jmp    800b19 <open+0x70>
		return -E_BAD_PATH;
  800b34:	bb f4 ff ff ff       	mov    $0xfffffff4,%ebx
  800b39:	eb de                	jmp    800b19 <open+0x70>

00800b3b <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b3b:	f3 0f 1e fb          	endbr32 
  800b3f:	55                   	push   %ebp
  800b40:	89 e5                	mov    %esp,%ebp
  800b42:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b45:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4a:	b8 08 00 00 00       	mov    $0x8,%eax
  800b4f:	e8 87 fd ff ff       	call   8008db <fsipc>
}
  800b54:	c9                   	leave  
  800b55:	c3                   	ret    

00800b56 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b56:	f3 0f 1e fb          	endbr32 
  800b5a:	55                   	push   %ebp
  800b5b:	89 e5                	mov    %esp,%ebp
  800b5d:	56                   	push   %esi
  800b5e:	53                   	push   %ebx
  800b5f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b62:	83 ec 0c             	sub    $0xc,%esp
  800b65:	ff 75 08             	pushl  0x8(%ebp)
  800b68:	e8 af f7 ff ff       	call   80031c <fd2data>
  800b6d:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b6f:	83 c4 08             	add    $0x8,%esp
  800b72:	68 d7 1e 80 00       	push   $0x801ed7
  800b77:	53                   	push   %ebx
  800b78:	e8 25 0b 00 00       	call   8016a2 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b7d:	8b 46 04             	mov    0x4(%esi),%eax
  800b80:	2b 06                	sub    (%esi),%eax
  800b82:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b88:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b8f:	00 00 00 
	stat->st_dev = &devpipe;
  800b92:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b99:	30 80 00 
	return 0;
}
  800b9c:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba1:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ba4:	5b                   	pop    %ebx
  800ba5:	5e                   	pop    %esi
  800ba6:	5d                   	pop    %ebp
  800ba7:	c3                   	ret    

00800ba8 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800ba8:	f3 0f 1e fb          	endbr32 
  800bac:	55                   	push   %ebp
  800bad:	89 e5                	mov    %esp,%ebp
  800baf:	53                   	push   %ebx
  800bb0:	83 ec 0c             	sub    $0xc,%esp
  800bb3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bb6:	53                   	push   %ebx
  800bb7:	6a 00                	push   $0x0
  800bb9:	e8 5f f6 ff ff       	call   80021d <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bbe:	89 1c 24             	mov    %ebx,(%esp)
  800bc1:	e8 56 f7 ff ff       	call   80031c <fd2data>
  800bc6:	83 c4 08             	add    $0x8,%esp
  800bc9:	50                   	push   %eax
  800bca:	6a 00                	push   $0x0
  800bcc:	e8 4c f6 ff ff       	call   80021d <sys_page_unmap>
}
  800bd1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bd4:	c9                   	leave  
  800bd5:	c3                   	ret    

00800bd6 <_pipeisclosed>:
{
  800bd6:	55                   	push   %ebp
  800bd7:	89 e5                	mov    %esp,%ebp
  800bd9:	57                   	push   %edi
  800bda:	56                   	push   %esi
  800bdb:	53                   	push   %ebx
  800bdc:	83 ec 1c             	sub    $0x1c,%esp
  800bdf:	89 c7                	mov    %eax,%edi
  800be1:	89 d6                	mov    %edx,%esi
		n = thisenv->env_runs;
  800be3:	a1 04 40 80 00       	mov    0x804004,%eax
  800be8:	8b 58 58             	mov    0x58(%eax),%ebx
		ret = pageref(fd) == pageref(p);
  800beb:	83 ec 0c             	sub    $0xc,%esp
  800bee:	57                   	push   %edi
  800bef:	e8 32 0f 00 00       	call   801b26 <pageref>
  800bf4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800bf7:	89 34 24             	mov    %esi,(%esp)
  800bfa:	e8 27 0f 00 00       	call   801b26 <pageref>
		nn = thisenv->env_runs;
  800bff:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c05:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c08:	83 c4 10             	add    $0x10,%esp
  800c0b:	39 cb                	cmp    %ecx,%ebx
  800c0d:	74 1b                	je     800c2a <_pipeisclosed+0x54>
		if (n != nn && ret == 1)
  800c0f:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c12:	75 cf                	jne    800be3 <_pipeisclosed+0xd>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c14:	8b 42 58             	mov    0x58(%edx),%eax
  800c17:	6a 01                	push   $0x1
  800c19:	50                   	push   %eax
  800c1a:	53                   	push   %ebx
  800c1b:	68 de 1e 80 00       	push   $0x801ede
  800c20:	e8 13 05 00 00       	call   801138 <cprintf>
  800c25:	83 c4 10             	add    $0x10,%esp
  800c28:	eb b9                	jmp    800be3 <_pipeisclosed+0xd>
		ret = pageref(fd) == pageref(p);
  800c2a:	39 45 e4             	cmp    %eax,-0x1c(%ebp)
  800c2d:	0f 94 c0             	sete   %al
  800c30:	0f b6 c0             	movzbl %al,%eax
}
  800c33:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c36:	5b                   	pop    %ebx
  800c37:	5e                   	pop    %esi
  800c38:	5f                   	pop    %edi
  800c39:	5d                   	pop    %ebp
  800c3a:	c3                   	ret    

00800c3b <devpipe_write>:
{
  800c3b:	f3 0f 1e fb          	endbr32 
  800c3f:	55                   	push   %ebp
  800c40:	89 e5                	mov    %esp,%ebp
  800c42:	57                   	push   %edi
  800c43:	56                   	push   %esi
  800c44:	53                   	push   %ebx
  800c45:	83 ec 28             	sub    $0x28,%esp
  800c48:	8b 75 08             	mov    0x8(%ebp),%esi
	p = (struct Pipe*) fd2data(fd);
  800c4b:	56                   	push   %esi
  800c4c:	e8 cb f6 ff ff       	call   80031c <fd2data>
  800c51:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800c53:	83 c4 10             	add    $0x10,%esp
  800c56:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5b:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c5e:	74 4f                	je     800caf <devpipe_write+0x74>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c60:	8b 43 04             	mov    0x4(%ebx),%eax
  800c63:	8b 0b                	mov    (%ebx),%ecx
  800c65:	8d 51 20             	lea    0x20(%ecx),%edx
  800c68:	39 d0                	cmp    %edx,%eax
  800c6a:	72 14                	jb     800c80 <devpipe_write+0x45>
			if (_pipeisclosed(fd, p))
  800c6c:	89 da                	mov    %ebx,%edx
  800c6e:	89 f0                	mov    %esi,%eax
  800c70:	e8 61 ff ff ff       	call   800bd6 <_pipeisclosed>
  800c75:	85 c0                	test   %eax,%eax
  800c77:	75 3b                	jne    800cb4 <devpipe_write+0x79>
			sys_yield();
  800c79:	e8 22 f5 ff ff       	call   8001a0 <sys_yield>
  800c7e:	eb e0                	jmp    800c60 <devpipe_write+0x25>
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c80:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c83:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c87:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c8a:	89 c2                	mov    %eax,%edx
  800c8c:	c1 fa 1f             	sar    $0x1f,%edx
  800c8f:	89 d1                	mov    %edx,%ecx
  800c91:	c1 e9 1b             	shr    $0x1b,%ecx
  800c94:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c97:	83 e2 1f             	and    $0x1f,%edx
  800c9a:	29 ca                	sub    %ecx,%edx
  800c9c:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800ca0:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ca4:	83 c0 01             	add    $0x1,%eax
  800ca7:	89 43 04             	mov    %eax,0x4(%ebx)
	for (i = 0; i < n; i++) {
  800caa:	83 c7 01             	add    $0x1,%edi
  800cad:	eb ac                	jmp    800c5b <devpipe_write+0x20>
	return i;
  800caf:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb2:	eb 05                	jmp    800cb9 <devpipe_write+0x7e>
				return 0;
  800cb4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800cb9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbc:	5b                   	pop    %ebx
  800cbd:	5e                   	pop    %esi
  800cbe:	5f                   	pop    %edi
  800cbf:	5d                   	pop    %ebp
  800cc0:	c3                   	ret    

00800cc1 <devpipe_read>:
{
  800cc1:	f3 0f 1e fb          	endbr32 
  800cc5:	55                   	push   %ebp
  800cc6:	89 e5                	mov    %esp,%ebp
  800cc8:	57                   	push   %edi
  800cc9:	56                   	push   %esi
  800cca:	53                   	push   %ebx
  800ccb:	83 ec 18             	sub    $0x18,%esp
  800cce:	8b 7d 08             	mov    0x8(%ebp),%edi
	p = (struct Pipe*)fd2data(fd);
  800cd1:	57                   	push   %edi
  800cd2:	e8 45 f6 ff ff       	call   80031c <fd2data>
  800cd7:	89 c3                	mov    %eax,%ebx
	for (i = 0; i < n; i++) {
  800cd9:	83 c4 10             	add    $0x10,%esp
  800cdc:	be 00 00 00 00       	mov    $0x0,%esi
  800ce1:	3b 75 10             	cmp    0x10(%ebp),%esi
  800ce4:	75 14                	jne    800cfa <devpipe_read+0x39>
	return i;
  800ce6:	8b 45 10             	mov    0x10(%ebp),%eax
  800ce9:	eb 02                	jmp    800ced <devpipe_read+0x2c>
				return i;
  800ceb:	89 f0                	mov    %esi,%eax
}
  800ced:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cf0:	5b                   	pop    %ebx
  800cf1:	5e                   	pop    %esi
  800cf2:	5f                   	pop    %edi
  800cf3:	5d                   	pop    %ebp
  800cf4:	c3                   	ret    
			sys_yield();
  800cf5:	e8 a6 f4 ff ff       	call   8001a0 <sys_yield>
		while (p->p_rpos == p->p_wpos) {
  800cfa:	8b 03                	mov    (%ebx),%eax
  800cfc:	3b 43 04             	cmp    0x4(%ebx),%eax
  800cff:	75 18                	jne    800d19 <devpipe_read+0x58>
			if (i > 0)
  800d01:	85 f6                	test   %esi,%esi
  800d03:	75 e6                	jne    800ceb <devpipe_read+0x2a>
			if (_pipeisclosed(fd, p))
  800d05:	89 da                	mov    %ebx,%edx
  800d07:	89 f8                	mov    %edi,%eax
  800d09:	e8 c8 fe ff ff       	call   800bd6 <_pipeisclosed>
  800d0e:	85 c0                	test   %eax,%eax
  800d10:	74 e3                	je     800cf5 <devpipe_read+0x34>
				return 0;
  800d12:	b8 00 00 00 00       	mov    $0x0,%eax
  800d17:	eb d4                	jmp    800ced <devpipe_read+0x2c>
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d19:	99                   	cltd   
  800d1a:	c1 ea 1b             	shr    $0x1b,%edx
  800d1d:	01 d0                	add    %edx,%eax
  800d1f:	83 e0 1f             	and    $0x1f,%eax
  800d22:	29 d0                	sub    %edx,%eax
  800d24:	0f b6 44 03 08       	movzbl 0x8(%ebx,%eax,1),%eax
  800d29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2c:	88 04 31             	mov    %al,(%ecx,%esi,1)
		p->p_rpos++;
  800d2f:	83 03 01             	addl   $0x1,(%ebx)
	for (i = 0; i < n; i++) {
  800d32:	83 c6 01             	add    $0x1,%esi
  800d35:	eb aa                	jmp    800ce1 <devpipe_read+0x20>

00800d37 <pipe>:
{
  800d37:	f3 0f 1e fb          	endbr32 
  800d3b:	55                   	push   %ebp
  800d3c:	89 e5                	mov    %esp,%ebp
  800d3e:	56                   	push   %esi
  800d3f:	53                   	push   %ebx
  800d40:	83 ec 1c             	sub    $0x1c,%esp
	if ((r = fd_alloc(&fd0)) < 0
  800d43:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d46:	50                   	push   %eax
  800d47:	e8 ef f5 ff ff       	call   80033b <fd_alloc>
  800d4c:	89 c3                	mov    %eax,%ebx
  800d4e:	83 c4 10             	add    $0x10,%esp
  800d51:	85 c0                	test   %eax,%eax
  800d53:	0f 88 23 01 00 00    	js     800e7c <pipe+0x145>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d59:	83 ec 04             	sub    $0x4,%esp
  800d5c:	68 07 04 00 00       	push   $0x407
  800d61:	ff 75 f4             	pushl  -0xc(%ebp)
  800d64:	6a 00                	push   $0x0
  800d66:	e8 60 f4 ff ff       	call   8001cb <sys_page_alloc>
  800d6b:	89 c3                	mov    %eax,%ebx
  800d6d:	83 c4 10             	add    $0x10,%esp
  800d70:	85 c0                	test   %eax,%eax
  800d72:	0f 88 04 01 00 00    	js     800e7c <pipe+0x145>
	if ((r = fd_alloc(&fd1)) < 0
  800d78:	83 ec 0c             	sub    $0xc,%esp
  800d7b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d7e:	50                   	push   %eax
  800d7f:	e8 b7 f5 ff ff       	call   80033b <fd_alloc>
  800d84:	89 c3                	mov    %eax,%ebx
  800d86:	83 c4 10             	add    $0x10,%esp
  800d89:	85 c0                	test   %eax,%eax
  800d8b:	0f 88 db 00 00 00    	js     800e6c <pipe+0x135>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d91:	83 ec 04             	sub    $0x4,%esp
  800d94:	68 07 04 00 00       	push   $0x407
  800d99:	ff 75 f0             	pushl  -0x10(%ebp)
  800d9c:	6a 00                	push   $0x0
  800d9e:	e8 28 f4 ff ff       	call   8001cb <sys_page_alloc>
  800da3:	89 c3                	mov    %eax,%ebx
  800da5:	83 c4 10             	add    $0x10,%esp
  800da8:	85 c0                	test   %eax,%eax
  800daa:	0f 88 bc 00 00 00    	js     800e6c <pipe+0x135>
	va = fd2data(fd0);
  800db0:	83 ec 0c             	sub    $0xc,%esp
  800db3:	ff 75 f4             	pushl  -0xc(%ebp)
  800db6:	e8 61 f5 ff ff       	call   80031c <fd2data>
  800dbb:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dbd:	83 c4 0c             	add    $0xc,%esp
  800dc0:	68 07 04 00 00       	push   $0x407
  800dc5:	50                   	push   %eax
  800dc6:	6a 00                	push   $0x0
  800dc8:	e8 fe f3 ff ff       	call   8001cb <sys_page_alloc>
  800dcd:	89 c3                	mov    %eax,%ebx
  800dcf:	83 c4 10             	add    $0x10,%esp
  800dd2:	85 c0                	test   %eax,%eax
  800dd4:	0f 88 82 00 00 00    	js     800e5c <pipe+0x125>
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dda:	83 ec 0c             	sub    $0xc,%esp
  800ddd:	ff 75 f0             	pushl  -0x10(%ebp)
  800de0:	e8 37 f5 ff ff       	call   80031c <fd2data>
  800de5:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dec:	50                   	push   %eax
  800ded:	6a 00                	push   $0x0
  800def:	56                   	push   %esi
  800df0:	6a 00                	push   $0x0
  800df2:	e8 fc f3 ff ff       	call   8001f3 <sys_page_map>
  800df7:	89 c3                	mov    %eax,%ebx
  800df9:	83 c4 20             	add    $0x20,%esp
  800dfc:	85 c0                	test   %eax,%eax
  800dfe:	78 4e                	js     800e4e <pipe+0x117>
	fd0->fd_dev_id = devpipe.dev_id;
  800e00:	a1 20 30 80 00       	mov    0x803020,%eax
  800e05:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e08:	89 02                	mov    %eax,(%edx)
	fd0->fd_omode = O_RDONLY;
  800e0a:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800e0d:	c7 42 08 00 00 00 00 	movl   $0x0,0x8(%edx)
	fd1->fd_dev_id = devpipe.dev_id;
  800e14:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800e17:	89 02                	mov    %eax,(%edx)
	fd1->fd_omode = O_WRONLY;
  800e19:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e1c:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
	pfd[0] = fd2num(fd0);
  800e23:	83 ec 0c             	sub    $0xc,%esp
  800e26:	ff 75 f4             	pushl  -0xc(%ebp)
  800e29:	e8 da f4 ff ff       	call   800308 <fd2num>
  800e2e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e31:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e33:	83 c4 04             	add    $0x4,%esp
  800e36:	ff 75 f0             	pushl  -0x10(%ebp)
  800e39:	e8 ca f4 ff ff       	call   800308 <fd2num>
  800e3e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e41:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e44:	83 c4 10             	add    $0x10,%esp
  800e47:	bb 00 00 00 00       	mov    $0x0,%ebx
  800e4c:	eb 2e                	jmp    800e7c <pipe+0x145>
	sys_page_unmap(0, va);
  800e4e:	83 ec 08             	sub    $0x8,%esp
  800e51:	56                   	push   %esi
  800e52:	6a 00                	push   $0x0
  800e54:	e8 c4 f3 ff ff       	call   80021d <sys_page_unmap>
  800e59:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd1);
  800e5c:	83 ec 08             	sub    $0x8,%esp
  800e5f:	ff 75 f0             	pushl  -0x10(%ebp)
  800e62:	6a 00                	push   $0x0
  800e64:	e8 b4 f3 ff ff       	call   80021d <sys_page_unmap>
  800e69:	83 c4 10             	add    $0x10,%esp
	sys_page_unmap(0, fd0);
  800e6c:	83 ec 08             	sub    $0x8,%esp
  800e6f:	ff 75 f4             	pushl  -0xc(%ebp)
  800e72:	6a 00                	push   $0x0
  800e74:	e8 a4 f3 ff ff       	call   80021d <sys_page_unmap>
  800e79:	83 c4 10             	add    $0x10,%esp
}
  800e7c:	89 d8                	mov    %ebx,%eax
  800e7e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e81:	5b                   	pop    %ebx
  800e82:	5e                   	pop    %esi
  800e83:	5d                   	pop    %ebp
  800e84:	c3                   	ret    

00800e85 <pipeisclosed>:
{
  800e85:	f3 0f 1e fb          	endbr32 
  800e89:	55                   	push   %ebp
  800e8a:	89 e5                	mov    %esp,%ebp
  800e8c:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e8f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e92:	50                   	push   %eax
  800e93:	ff 75 08             	pushl  0x8(%ebp)
  800e96:	e8 f6 f4 ff ff       	call   800391 <fd_lookup>
  800e9b:	83 c4 10             	add    $0x10,%esp
  800e9e:	85 c0                	test   %eax,%eax
  800ea0:	78 18                	js     800eba <pipeisclosed+0x35>
	p = (struct Pipe*) fd2data(fd);
  800ea2:	83 ec 0c             	sub    $0xc,%esp
  800ea5:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea8:	e8 6f f4 ff ff       	call   80031c <fd2data>
  800ead:	89 c2                	mov    %eax,%edx
	return _pipeisclosed(fd, p);
  800eaf:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb2:	e8 1f fd ff ff       	call   800bd6 <_pipeisclosed>
  800eb7:	83 c4 10             	add    $0x10,%esp
}
  800eba:	c9                   	leave  
  800ebb:	c3                   	ret    

00800ebc <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ebc:	f3 0f 1e fb          	endbr32 
	USED(fd);

	return 0;
}
  800ec0:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec5:	c3                   	ret    

00800ec6 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ec6:	f3 0f 1e fb          	endbr32 
  800eca:	55                   	push   %ebp
  800ecb:	89 e5                	mov    %esp,%ebp
  800ecd:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ed0:	68 f6 1e 80 00       	push   $0x801ef6
  800ed5:	ff 75 0c             	pushl  0xc(%ebp)
  800ed8:	e8 c5 07 00 00       	call   8016a2 <strcpy>
	return 0;
}
  800edd:	b8 00 00 00 00       	mov    $0x0,%eax
  800ee2:	c9                   	leave  
  800ee3:	c3                   	ret    

00800ee4 <devcons_write>:
{
  800ee4:	f3 0f 1e fb          	endbr32 
  800ee8:	55                   	push   %ebp
  800ee9:	89 e5                	mov    %esp,%ebp
  800eeb:	57                   	push   %edi
  800eec:	56                   	push   %esi
  800eed:	53                   	push   %ebx
  800eee:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	for (tot = 0; tot < n; tot += m) {
  800ef4:	be 00 00 00 00       	mov    $0x0,%esi
		memmove(buf, (char*)vbuf + tot, m);
  800ef9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	for (tot = 0; tot < n; tot += m) {
  800eff:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f02:	73 31                	jae    800f35 <devcons_write+0x51>
		m = n - tot;
  800f04:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f07:	29 f3                	sub    %esi,%ebx
  800f09:	83 fb 7f             	cmp    $0x7f,%ebx
  800f0c:	b8 7f 00 00 00       	mov    $0x7f,%eax
  800f11:	0f 47 d8             	cmova  %eax,%ebx
		memmove(buf, (char*)vbuf + tot, m);
  800f14:	83 ec 04             	sub    $0x4,%esp
  800f17:	53                   	push   %ebx
  800f18:	89 f0                	mov    %esi,%eax
  800f1a:	03 45 0c             	add    0xc(%ebp),%eax
  800f1d:	50                   	push   %eax
  800f1e:	57                   	push   %edi
  800f1f:	e8 36 09 00 00       	call   80185a <memmove>
		sys_cputs(buf, m);
  800f24:	83 c4 08             	add    $0x8,%esp
  800f27:	53                   	push   %ebx
  800f28:	57                   	push   %edi
  800f29:	e8 d2 f1 ff ff       	call   800100 <sys_cputs>
	for (tot = 0; tot < n; tot += m) {
  800f2e:	01 de                	add    %ebx,%esi
  800f30:	83 c4 10             	add    $0x10,%esp
  800f33:	eb ca                	jmp    800eff <devcons_write+0x1b>
}
  800f35:	89 f0                	mov    %esi,%eax
  800f37:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f3a:	5b                   	pop    %ebx
  800f3b:	5e                   	pop    %esi
  800f3c:	5f                   	pop    %edi
  800f3d:	5d                   	pop    %ebp
  800f3e:	c3                   	ret    

00800f3f <devcons_read>:
{
  800f3f:	f3 0f 1e fb          	endbr32 
  800f43:	55                   	push   %ebp
  800f44:	89 e5                	mov    %esp,%ebp
  800f46:	83 ec 08             	sub    $0x8,%esp
  800f49:	b8 00 00 00 00       	mov    $0x0,%eax
	if (n == 0)
  800f4e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f52:	74 21                	je     800f75 <devcons_read+0x36>
	while ((c = sys_cgetc()) == 0)
  800f54:	e8 d1 f1 ff ff       	call   80012a <sys_cgetc>
  800f59:	85 c0                	test   %eax,%eax
  800f5b:	75 07                	jne    800f64 <devcons_read+0x25>
		sys_yield();
  800f5d:	e8 3e f2 ff ff       	call   8001a0 <sys_yield>
  800f62:	eb f0                	jmp    800f54 <devcons_read+0x15>
	if (c < 0)
  800f64:	78 0f                	js     800f75 <devcons_read+0x36>
	if (c == 0x04)	// ctl-d is eof
  800f66:	83 f8 04             	cmp    $0x4,%eax
  800f69:	74 0c                	je     800f77 <devcons_read+0x38>
	*(char*)vbuf = c;
  800f6b:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f6e:	88 02                	mov    %al,(%edx)
	return 1;
  800f70:	b8 01 00 00 00       	mov    $0x1,%eax
}
  800f75:	c9                   	leave  
  800f76:	c3                   	ret    
		return 0;
  800f77:	b8 00 00 00 00       	mov    $0x0,%eax
  800f7c:	eb f7                	jmp    800f75 <devcons_read+0x36>

00800f7e <cputchar>:
{
  800f7e:	f3 0f 1e fb          	endbr32 
  800f82:	55                   	push   %ebp
  800f83:	89 e5                	mov    %esp,%ebp
  800f85:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f88:	8b 45 08             	mov    0x8(%ebp),%eax
  800f8b:	88 45 f7             	mov    %al,-0x9(%ebp)
	sys_cputs(&c, 1);
  800f8e:	6a 01                	push   $0x1
  800f90:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f93:	50                   	push   %eax
  800f94:	e8 67 f1 ff ff       	call   800100 <sys_cputs>
}
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	c9                   	leave  
  800f9d:	c3                   	ret    

00800f9e <getchar>:
{
  800f9e:	f3 0f 1e fb          	endbr32 
  800fa2:	55                   	push   %ebp
  800fa3:	89 e5                	mov    %esp,%ebp
  800fa5:	83 ec 1c             	sub    $0x1c,%esp
	r = read(0, &c, 1);
  800fa8:	6a 01                	push   $0x1
  800faa:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800fad:	50                   	push   %eax
  800fae:	6a 00                	push   $0x0
  800fb0:	e8 5f f6 ff ff       	call   800614 <read>
	if (r < 0)
  800fb5:	83 c4 10             	add    $0x10,%esp
  800fb8:	85 c0                	test   %eax,%eax
  800fba:	78 06                	js     800fc2 <getchar+0x24>
	if (r < 1)
  800fbc:	74 06                	je     800fc4 <getchar+0x26>
	return c;
  800fbe:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
}
  800fc2:	c9                   	leave  
  800fc3:	c3                   	ret    
		return -E_EOF;
  800fc4:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
  800fc9:	eb f7                	jmp    800fc2 <getchar+0x24>

00800fcb <iscons>:
{
  800fcb:	f3 0f 1e fb          	endbr32 
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	83 ec 20             	sub    $0x20,%esp
	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd8:	50                   	push   %eax
  800fd9:	ff 75 08             	pushl  0x8(%ebp)
  800fdc:	e8 b0 f3 ff ff       	call   800391 <fd_lookup>
  800fe1:	83 c4 10             	add    $0x10,%esp
  800fe4:	85 c0                	test   %eax,%eax
  800fe6:	78 11                	js     800ff9 <iscons+0x2e>
	return fd->fd_dev_id == devcons.dev_id;
  800fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800feb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ff1:	39 10                	cmp    %edx,(%eax)
  800ff3:	0f 94 c0             	sete   %al
  800ff6:	0f b6 c0             	movzbl %al,%eax
}
  800ff9:	c9                   	leave  
  800ffa:	c3                   	ret    

00800ffb <opencons>:
{
  800ffb:	f3 0f 1e fb          	endbr32 
  800fff:	55                   	push   %ebp
  801000:	89 e5                	mov    %esp,%ebp
  801002:	83 ec 24             	sub    $0x24,%esp
	if ((r = fd_alloc(&fd)) < 0)
  801005:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801008:	50                   	push   %eax
  801009:	e8 2d f3 ff ff       	call   80033b <fd_alloc>
  80100e:	83 c4 10             	add    $0x10,%esp
  801011:	85 c0                	test   %eax,%eax
  801013:	78 3a                	js     80104f <opencons+0x54>
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801015:	83 ec 04             	sub    $0x4,%esp
  801018:	68 07 04 00 00       	push   $0x407
  80101d:	ff 75 f4             	pushl  -0xc(%ebp)
  801020:	6a 00                	push   $0x0
  801022:	e8 a4 f1 ff ff       	call   8001cb <sys_page_alloc>
  801027:	83 c4 10             	add    $0x10,%esp
  80102a:	85 c0                	test   %eax,%eax
  80102c:	78 21                	js     80104f <opencons+0x54>
	fd->fd_dev_id = devcons.dev_id;
  80102e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801031:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801037:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801039:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80103c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801043:	83 ec 0c             	sub    $0xc,%esp
  801046:	50                   	push   %eax
  801047:	e8 bc f2 ff ff       	call   800308 <fd2num>
  80104c:	83 c4 10             	add    $0x10,%esp
}
  80104f:	c9                   	leave  
  801050:	c3                   	ret    

00801051 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801051:	f3 0f 1e fb          	endbr32 
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
  801058:	56                   	push   %esi
  801059:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80105a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80105d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801063:	e8 10 f1 ff ff       	call   800178 <sys_getenvid>
  801068:	83 ec 0c             	sub    $0xc,%esp
  80106b:	ff 75 0c             	pushl  0xc(%ebp)
  80106e:	ff 75 08             	pushl  0x8(%ebp)
  801071:	56                   	push   %esi
  801072:	50                   	push   %eax
  801073:	68 04 1f 80 00       	push   $0x801f04
  801078:	e8 bb 00 00 00       	call   801138 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80107d:	83 c4 18             	add    $0x18,%esp
  801080:	53                   	push   %ebx
  801081:	ff 75 10             	pushl  0x10(%ebp)
  801084:	e8 5a 00 00 00       	call   8010e3 <vcprintf>
	cprintf("\n");
  801089:	c7 04 24 ef 1e 80 00 	movl   $0x801eef,(%esp)
  801090:	e8 a3 00 00 00       	call   801138 <cprintf>
  801095:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801098:	cc                   	int3   
  801099:	eb fd                	jmp    801098 <_panic+0x47>

0080109b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80109b:	f3 0f 1e fb          	endbr32 
  80109f:	55                   	push   %ebp
  8010a0:	89 e5                	mov    %esp,%ebp
  8010a2:	53                   	push   %ebx
  8010a3:	83 ec 04             	sub    $0x4,%esp
  8010a6:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010a9:	8b 13                	mov    (%ebx),%edx
  8010ab:	8d 42 01             	lea    0x1(%edx),%eax
  8010ae:	89 03                	mov    %eax,(%ebx)
  8010b0:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010b3:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010b7:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010bc:	74 09                	je     8010c7 <putch+0x2c>
		sys_cputs(b->buf, b->idx);
		b->idx = 0;
	}
	b->cnt++;
  8010be:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c5:	c9                   	leave  
  8010c6:	c3                   	ret    
		sys_cputs(b->buf, b->idx);
  8010c7:	83 ec 08             	sub    $0x8,%esp
  8010ca:	68 ff 00 00 00       	push   $0xff
  8010cf:	8d 43 08             	lea    0x8(%ebx),%eax
  8010d2:	50                   	push   %eax
  8010d3:	e8 28 f0 ff ff       	call   800100 <sys_cputs>
		b->idx = 0;
  8010d8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010de:	83 c4 10             	add    $0x10,%esp
  8010e1:	eb db                	jmp    8010be <putch+0x23>

008010e3 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010e3:	f3 0f 1e fb          	endbr32 
  8010e7:	55                   	push   %ebp
  8010e8:	89 e5                	mov    %esp,%ebp
  8010ea:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	b.idx = 0;
  8010f0:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010f7:	00 00 00 
	b.cnt = 0;
  8010fa:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  801101:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  801104:	ff 75 0c             	pushl  0xc(%ebp)
  801107:	ff 75 08             	pushl  0x8(%ebp)
  80110a:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801110:	50                   	push   %eax
  801111:	68 9b 10 80 00       	push   $0x80109b
  801116:	e8 80 01 00 00       	call   80129b <vprintfmt>
	sys_cputs(b.buf, b.idx);
  80111b:	83 c4 08             	add    $0x8,%esp
  80111e:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801124:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  80112a:	50                   	push   %eax
  80112b:	e8 d0 ef ff ff       	call   800100 <sys_cputs>

	return b.cnt;
}
  801130:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801136:	c9                   	leave  
  801137:	c3                   	ret    

00801138 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801138:	f3 0f 1e fb          	endbr32 
  80113c:	55                   	push   %ebp
  80113d:	89 e5                	mov    %esp,%ebp
  80113f:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801142:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801145:	50                   	push   %eax
  801146:	ff 75 08             	pushl  0x8(%ebp)
  801149:	e8 95 ff ff ff       	call   8010e3 <vcprintf>
	va_end(ap);

	return cnt;
}
  80114e:	c9                   	leave  
  80114f:	c3                   	ret    

00801150 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801150:	55                   	push   %ebp
  801151:	89 e5                	mov    %esp,%ebp
  801153:	57                   	push   %edi
  801154:	56                   	push   %esi
  801155:	53                   	push   %ebx
  801156:	83 ec 1c             	sub    $0x1c,%esp
  801159:	89 c7                	mov    %eax,%edi
  80115b:	89 d6                	mov    %edx,%esi
  80115d:	8b 45 08             	mov    0x8(%ebp),%eax
  801160:	8b 55 0c             	mov    0xc(%ebp),%edx
  801163:	89 d1                	mov    %edx,%ecx
  801165:	89 c2                	mov    %eax,%edx
  801167:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80116a:	89 4d dc             	mov    %ecx,-0x24(%ebp)
  80116d:	8b 45 10             	mov    0x10(%ebp),%eax
  801170:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801173:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801176:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
  80117d:	39 c2                	cmp    %eax,%edx
  80117f:	1b 4d e4             	sbb    -0x1c(%ebp),%ecx
  801182:	72 3e                	jb     8011c2 <printnum+0x72>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801184:	83 ec 0c             	sub    $0xc,%esp
  801187:	ff 75 18             	pushl  0x18(%ebp)
  80118a:	83 eb 01             	sub    $0x1,%ebx
  80118d:	53                   	push   %ebx
  80118e:	50                   	push   %eax
  80118f:	83 ec 08             	sub    $0x8,%esp
  801192:	ff 75 e4             	pushl  -0x1c(%ebp)
  801195:	ff 75 e0             	pushl  -0x20(%ebp)
  801198:	ff 75 dc             	pushl  -0x24(%ebp)
  80119b:	ff 75 d8             	pushl  -0x28(%ebp)
  80119e:	e8 cd 09 00 00       	call   801b70 <__udivdi3>
  8011a3:	83 c4 18             	add    $0x18,%esp
  8011a6:	52                   	push   %edx
  8011a7:	50                   	push   %eax
  8011a8:	89 f2                	mov    %esi,%edx
  8011aa:	89 f8                	mov    %edi,%eax
  8011ac:	e8 9f ff ff ff       	call   801150 <printnum>
  8011b1:	83 c4 20             	add    $0x20,%esp
  8011b4:	eb 13                	jmp    8011c9 <printnum+0x79>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011b6:	83 ec 08             	sub    $0x8,%esp
  8011b9:	56                   	push   %esi
  8011ba:	ff 75 18             	pushl  0x18(%ebp)
  8011bd:	ff d7                	call   *%edi
  8011bf:	83 c4 10             	add    $0x10,%esp
		while (--width > 0)
  8011c2:	83 eb 01             	sub    $0x1,%ebx
  8011c5:	85 db                	test   %ebx,%ebx
  8011c7:	7f ed                	jg     8011b6 <printnum+0x66>
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011c9:	83 ec 08             	sub    $0x8,%esp
  8011cc:	56                   	push   %esi
  8011cd:	83 ec 04             	sub    $0x4,%esp
  8011d0:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011d3:	ff 75 e0             	pushl  -0x20(%ebp)
  8011d6:	ff 75 dc             	pushl  -0x24(%ebp)
  8011d9:	ff 75 d8             	pushl  -0x28(%ebp)
  8011dc:	e8 9f 0a 00 00       	call   801c80 <__umoddi3>
  8011e1:	83 c4 14             	add    $0x14,%esp
  8011e4:	0f be 80 27 1f 80 00 	movsbl 0x801f27(%eax),%eax
  8011eb:	50                   	push   %eax
  8011ec:	ff d7                	call   *%edi
}
  8011ee:	83 c4 10             	add    $0x10,%esp
  8011f1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011f4:	5b                   	pop    %ebx
  8011f5:	5e                   	pop    %esi
  8011f6:	5f                   	pop    %edi
  8011f7:	5d                   	pop    %ebp
  8011f8:	c3                   	ret    

008011f9 <getuint>:
// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8011f9:	83 fa 01             	cmp    $0x1,%edx
  8011fc:	7f 13                	jg     801211 <getuint+0x18>
		return va_arg(*ap, unsigned long long);
	else if (lflag)
  8011fe:	85 d2                	test   %edx,%edx
  801200:	74 1c                	je     80121e <getuint+0x25>
		return va_arg(*ap, unsigned long);
  801202:	8b 10                	mov    (%eax),%edx
  801204:	8d 4a 04             	lea    0x4(%edx),%ecx
  801207:	89 08                	mov    %ecx,(%eax)
  801209:	8b 02                	mov    (%edx),%eax
  80120b:	ba 00 00 00 00       	mov    $0x0,%edx
  801210:	c3                   	ret    
		return va_arg(*ap, unsigned long long);
  801211:	8b 10                	mov    (%eax),%edx
  801213:	8d 4a 08             	lea    0x8(%edx),%ecx
  801216:	89 08                	mov    %ecx,(%eax)
  801218:	8b 02                	mov    (%edx),%eax
  80121a:	8b 52 04             	mov    0x4(%edx),%edx
  80121d:	c3                   	ret    
	else
		return va_arg(*ap, unsigned int);
  80121e:	8b 10                	mov    (%eax),%edx
  801220:	8d 4a 04             	lea    0x4(%edx),%ecx
  801223:	89 08                	mov    %ecx,(%eax)
  801225:	8b 02                	mov    (%edx),%eax
  801227:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80122c:	c3                   	ret    

0080122d <getint>:
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  80122d:	83 fa 01             	cmp    $0x1,%edx
  801230:	7f 0f                	jg     801241 <getint+0x14>
		return va_arg(*ap, long long);
	else if (lflag)
  801232:	85 d2                	test   %edx,%edx
  801234:	74 18                	je     80124e <getint+0x21>
		return va_arg(*ap, long);
  801236:	8b 10                	mov    (%eax),%edx
  801238:	8d 4a 04             	lea    0x4(%edx),%ecx
  80123b:	89 08                	mov    %ecx,(%eax)
  80123d:	8b 02                	mov    (%edx),%eax
  80123f:	99                   	cltd   
  801240:	c3                   	ret    
		return va_arg(*ap, long long);
  801241:	8b 10                	mov    (%eax),%edx
  801243:	8d 4a 08             	lea    0x8(%edx),%ecx
  801246:	89 08                	mov    %ecx,(%eax)
  801248:	8b 02                	mov    (%edx),%eax
  80124a:	8b 52 04             	mov    0x4(%edx),%edx
  80124d:	c3                   	ret    
	else
		return va_arg(*ap, int);
  80124e:	8b 10                	mov    (%eax),%edx
  801250:	8d 4a 04             	lea    0x4(%edx),%ecx
  801253:	89 08                	mov    %ecx,(%eax)
  801255:	8b 02                	mov    (%edx),%eax
  801257:	99                   	cltd   
}
  801258:	c3                   	ret    

00801259 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801259:	f3 0f 1e fb          	endbr32 
  80125d:	55                   	push   %ebp
  80125e:	89 e5                	mov    %esp,%ebp
  801260:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801263:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801267:	8b 10                	mov    (%eax),%edx
  801269:	3b 50 04             	cmp    0x4(%eax),%edx
  80126c:	73 0a                	jae    801278 <sprintputch+0x1f>
		*b->buf++ = ch;
  80126e:	8d 4a 01             	lea    0x1(%edx),%ecx
  801271:	89 08                	mov    %ecx,(%eax)
  801273:	8b 45 08             	mov    0x8(%ebp),%eax
  801276:	88 02                	mov    %al,(%edx)
}
  801278:	5d                   	pop    %ebp
  801279:	c3                   	ret    

0080127a <printfmt>:
{
  80127a:	f3 0f 1e fb          	endbr32 
  80127e:	55                   	push   %ebp
  80127f:	89 e5                	mov    %esp,%ebp
  801281:	83 ec 08             	sub    $0x8,%esp
	va_start(ap, fmt);
  801284:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801287:	50                   	push   %eax
  801288:	ff 75 10             	pushl  0x10(%ebp)
  80128b:	ff 75 0c             	pushl  0xc(%ebp)
  80128e:	ff 75 08             	pushl  0x8(%ebp)
  801291:	e8 05 00 00 00       	call   80129b <vprintfmt>
}
  801296:	83 c4 10             	add    $0x10,%esp
  801299:	c9                   	leave  
  80129a:	c3                   	ret    

0080129b <vprintfmt>:
{
  80129b:	f3 0f 1e fb          	endbr32 
  80129f:	55                   	push   %ebp
  8012a0:	89 e5                	mov    %esp,%ebp
  8012a2:	57                   	push   %edi
  8012a3:	56                   	push   %esi
  8012a4:	53                   	push   %ebx
  8012a5:	83 ec 2c             	sub    $0x2c,%esp
  8012a8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  8012ab:	8b 75 0c             	mov    0xc(%ebp),%esi
  8012ae:	8b 7d 10             	mov    0x10(%ebp),%edi
  8012b1:	e9 86 02 00 00       	jmp    80153c <vprintfmt+0x2a1>
		padc = ' ';
  8012b6:	c6 45 d3 20          	movb   $0x20,-0x2d(%ebp)
		altflag = 0;
  8012ba:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
		precision = -1;
  8012c1:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
		width = -1;
  8012c8:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
		lflag = 0;
  8012cf:	b9 00 00 00 00       	mov    $0x0,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  8012d4:	8d 47 01             	lea    0x1(%edi),%eax
  8012d7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012da:	0f b6 17             	movzbl (%edi),%edx
  8012dd:	8d 42 dd             	lea    -0x23(%edx),%eax
  8012e0:	3c 55                	cmp    $0x55,%al
  8012e2:	0f 87 df 02 00 00    	ja     8015c7 <vprintfmt+0x32c>
  8012e8:	0f b6 c0             	movzbl %al,%eax
  8012eb:	3e ff 24 85 60 20 80 	notrack jmp *0x802060(,%eax,4)
  8012f2:	00 
  8012f3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
  8012f6:	c6 45 d3 2d          	movb   $0x2d,-0x2d(%ebp)
  8012fa:	eb d8                	jmp    8012d4 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  8012fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012ff:	c6 45 d3 30          	movb   $0x30,-0x2d(%ebp)
  801303:	eb cf                	jmp    8012d4 <vprintfmt+0x39>
  801305:	0f b6 d2             	movzbl %dl,%edx
  801308:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			for (precision = 0; ; ++fmt) {
  80130b:	b8 00 00 00 00       	mov    $0x0,%eax
  801310:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
				precision = precision * 10 + ch - '0';
  801313:	8d 04 80             	lea    (%eax,%eax,4),%eax
  801316:	8d 44 42 d0          	lea    -0x30(%edx,%eax,2),%eax
				ch = *fmt;
  80131a:	0f be 17             	movsbl (%edi),%edx
				if (ch < '0' || ch > '9')
  80131d:	8d 4a d0             	lea    -0x30(%edx),%ecx
  801320:	83 f9 09             	cmp    $0x9,%ecx
  801323:	77 52                	ja     801377 <vprintfmt+0xdc>
			for (precision = 0; ; ++fmt) {
  801325:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
  801328:	eb e9                	jmp    801313 <vprintfmt+0x78>
			precision = va_arg(ap, int);
  80132a:	8b 45 14             	mov    0x14(%ebp),%eax
  80132d:	8d 50 04             	lea    0x4(%eax),%edx
  801330:	89 55 14             	mov    %edx,0x14(%ebp)
  801333:	8b 00                	mov    (%eax),%eax
  801335:	89 45 d8             	mov    %eax,-0x28(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801338:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
  80133b:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80133f:	79 93                	jns    8012d4 <vprintfmt+0x39>
				width = precision, precision = -1;
  801341:	8b 45 d8             	mov    -0x28(%ebp),%eax
  801344:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801347:	c7 45 d8 ff ff ff ff 	movl   $0xffffffff,-0x28(%ebp)
  80134e:	eb 84                	jmp    8012d4 <vprintfmt+0x39>
  801350:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801353:	85 c0                	test   %eax,%eax
  801355:	ba 00 00 00 00       	mov    $0x0,%edx
  80135a:	0f 49 d0             	cmovns %eax,%edx
  80135d:	89 55 e0             	mov    %edx,-0x20(%ebp)
		switch (ch = *(unsigned char *) fmt++) {
  801360:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801363:	e9 6c ff ff ff       	jmp    8012d4 <vprintfmt+0x39>
		switch (ch = *(unsigned char *) fmt++) {
  801368:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			altflag = 1;
  80136b:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
			goto reswitch;
  801372:	e9 5d ff ff ff       	jmp    8012d4 <vprintfmt+0x39>
  801377:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80137a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
  80137d:	eb bc                	jmp    80133b <vprintfmt+0xa0>
			lflag++;
  80137f:	83 c1 01             	add    $0x1,%ecx
		switch (ch = *(unsigned char *) fmt++) {
  801382:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;
  801385:	e9 4a ff ff ff       	jmp    8012d4 <vprintfmt+0x39>
			putch(va_arg(ap, int), putdat);
  80138a:	8b 45 14             	mov    0x14(%ebp),%eax
  80138d:	8d 50 04             	lea    0x4(%eax),%edx
  801390:	89 55 14             	mov    %edx,0x14(%ebp)
  801393:	83 ec 08             	sub    $0x8,%esp
  801396:	56                   	push   %esi
  801397:	ff 30                	pushl  (%eax)
  801399:	ff d3                	call   *%ebx
			break;
  80139b:	83 c4 10             	add    $0x10,%esp
  80139e:	e9 96 01 00 00       	jmp    801539 <vprintfmt+0x29e>
			err = va_arg(ap, int);
  8013a3:	8b 45 14             	mov    0x14(%ebp),%eax
  8013a6:	8d 50 04             	lea    0x4(%eax),%edx
  8013a9:	89 55 14             	mov    %edx,0x14(%ebp)
  8013ac:	8b 00                	mov    (%eax),%eax
  8013ae:	99                   	cltd   
  8013af:	31 d0                	xor    %edx,%eax
  8013b1:	29 d0                	sub    %edx,%eax
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  8013b3:	83 f8 0f             	cmp    $0xf,%eax
  8013b6:	7f 20                	jg     8013d8 <vprintfmt+0x13d>
  8013b8:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  8013bf:	85 d2                	test   %edx,%edx
  8013c1:	74 15                	je     8013d8 <vprintfmt+0x13d>
				printfmt(putch, putdat, "%s", p);
  8013c3:	52                   	push   %edx
  8013c4:	68 bd 1e 80 00       	push   $0x801ebd
  8013c9:	56                   	push   %esi
  8013ca:	53                   	push   %ebx
  8013cb:	e8 aa fe ff ff       	call   80127a <printfmt>
  8013d0:	83 c4 10             	add    $0x10,%esp
  8013d3:	e9 61 01 00 00       	jmp    801539 <vprintfmt+0x29e>
				printfmt(putch, putdat, "error %d", err);
  8013d8:	50                   	push   %eax
  8013d9:	68 3f 1f 80 00       	push   $0x801f3f
  8013de:	56                   	push   %esi
  8013df:	53                   	push   %ebx
  8013e0:	e8 95 fe ff ff       	call   80127a <printfmt>
  8013e5:	83 c4 10             	add    $0x10,%esp
  8013e8:	e9 4c 01 00 00       	jmp    801539 <vprintfmt+0x29e>
			if ((p = va_arg(ap, char *)) == NULL)
  8013ed:	8b 45 14             	mov    0x14(%ebp),%eax
  8013f0:	8d 50 04             	lea    0x4(%eax),%edx
  8013f3:	89 55 14             	mov    %edx,0x14(%ebp)
  8013f6:	8b 08                	mov    (%eax),%ecx
				p = "(null)";
  8013f8:	85 c9                	test   %ecx,%ecx
  8013fa:	b8 38 1f 80 00       	mov    $0x801f38,%eax
  8013ff:	0f 45 c1             	cmovne %ecx,%eax
  801402:	89 45 cc             	mov    %eax,-0x34(%ebp)
			if (width > 0 && padc != '-')
  801405:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801409:	7e 06                	jle    801411 <vprintfmt+0x176>
  80140b:	80 7d d3 2d          	cmpb   $0x2d,-0x2d(%ebp)
  80140f:	75 0d                	jne    80141e <vprintfmt+0x183>
				for (width -= strnlen(p, precision); width > 0; width--)
  801411:	8b 45 cc             	mov    -0x34(%ebp),%eax
  801414:	89 c7                	mov    %eax,%edi
  801416:	03 45 e0             	add    -0x20(%ebp),%eax
  801419:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80141c:	eb 57                	jmp    801475 <vprintfmt+0x1da>
  80141e:	83 ec 08             	sub    $0x8,%esp
  801421:	ff 75 d8             	pushl  -0x28(%ebp)
  801424:	ff 75 cc             	pushl  -0x34(%ebp)
  801427:	e8 4f 02 00 00       	call   80167b <strnlen>
  80142c:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80142f:	29 c2                	sub    %eax,%edx
  801431:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801434:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801437:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  80143b:	89 5d 08             	mov    %ebx,0x8(%ebp)
  80143e:	89 d3                	mov    %edx,%ebx
				for (width -= strnlen(p, precision); width > 0; width--)
  801440:	85 db                	test   %ebx,%ebx
  801442:	7e 10                	jle    801454 <vprintfmt+0x1b9>
					putch(padc, putdat);
  801444:	83 ec 08             	sub    $0x8,%esp
  801447:	56                   	push   %esi
  801448:	57                   	push   %edi
  801449:	ff 55 08             	call   *0x8(%ebp)
				for (width -= strnlen(p, precision); width > 0; width--)
  80144c:	83 eb 01             	sub    $0x1,%ebx
  80144f:	83 c4 10             	add    $0x10,%esp
  801452:	eb ec                	jmp    801440 <vprintfmt+0x1a5>
  801454:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801457:	8b 55 e0             	mov    -0x20(%ebp),%edx
  80145a:	85 d2                	test   %edx,%edx
  80145c:	b8 00 00 00 00       	mov    $0x0,%eax
  801461:	0f 49 c2             	cmovns %edx,%eax
  801464:	29 c2                	sub    %eax,%edx
  801466:	89 55 e0             	mov    %edx,-0x20(%ebp)
  801469:	eb a6                	jmp    801411 <vprintfmt+0x176>
					putch(ch, putdat);
  80146b:	83 ec 08             	sub    $0x8,%esp
  80146e:	56                   	push   %esi
  80146f:	52                   	push   %edx
  801470:	ff d3                	call   *%ebx
  801472:	83 c4 10             	add    $0x10,%esp
  801475:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  801478:	29 f9                	sub    %edi,%ecx
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80147a:	83 c7 01             	add    $0x1,%edi
  80147d:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801481:	0f be d0             	movsbl %al,%edx
  801484:	85 d2                	test   %edx,%edx
  801486:	74 42                	je     8014ca <vprintfmt+0x22f>
  801488:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80148c:	78 06                	js     801494 <vprintfmt+0x1f9>
  80148e:	83 6d d8 01          	subl   $0x1,-0x28(%ebp)
  801492:	78 1e                	js     8014b2 <vprintfmt+0x217>
				if (altflag && (ch < ' ' || ch > '~'))
  801494:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
  801498:	74 d1                	je     80146b <vprintfmt+0x1d0>
  80149a:	0f be c0             	movsbl %al,%eax
  80149d:	83 e8 20             	sub    $0x20,%eax
  8014a0:	83 f8 5e             	cmp    $0x5e,%eax
  8014a3:	76 c6                	jbe    80146b <vprintfmt+0x1d0>
					putch('?', putdat);
  8014a5:	83 ec 08             	sub    $0x8,%esp
  8014a8:	56                   	push   %esi
  8014a9:	6a 3f                	push   $0x3f
  8014ab:	ff d3                	call   *%ebx
  8014ad:	83 c4 10             	add    $0x10,%esp
  8014b0:	eb c3                	jmp    801475 <vprintfmt+0x1da>
  8014b2:	89 cf                	mov    %ecx,%edi
  8014b4:	eb 0e                	jmp    8014c4 <vprintfmt+0x229>
				putch(' ', putdat);
  8014b6:	83 ec 08             	sub    $0x8,%esp
  8014b9:	56                   	push   %esi
  8014ba:	6a 20                	push   $0x20
  8014bc:	ff d3                	call   *%ebx
			for (; width > 0; width--)
  8014be:	83 ef 01             	sub    $0x1,%edi
  8014c1:	83 c4 10             	add    $0x10,%esp
  8014c4:	85 ff                	test   %edi,%edi
  8014c6:	7f ee                	jg     8014b6 <vprintfmt+0x21b>
  8014c8:	eb 6f                	jmp    801539 <vprintfmt+0x29e>
  8014ca:	89 cf                	mov    %ecx,%edi
  8014cc:	eb f6                	jmp    8014c4 <vprintfmt+0x229>
			num = getint(&ap, lflag);
  8014ce:	89 ca                	mov    %ecx,%edx
  8014d0:	8d 45 14             	lea    0x14(%ebp),%eax
  8014d3:	e8 55 fd ff ff       	call   80122d <getint>
  8014d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8014db:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
  8014de:	85 d2                	test   %edx,%edx
  8014e0:	78 0b                	js     8014ed <vprintfmt+0x252>
			num = getint(&ap, lflag);
  8014e2:	89 d1                	mov    %edx,%ecx
  8014e4:	89 c2                	mov    %eax,%edx
			base = 10;
  8014e6:	b8 0a 00 00 00       	mov    $0xa,%eax
  8014eb:	eb 32                	jmp    80151f <vprintfmt+0x284>
				putch('-', putdat);
  8014ed:	83 ec 08             	sub    $0x8,%esp
  8014f0:	56                   	push   %esi
  8014f1:	6a 2d                	push   $0x2d
  8014f3:	ff d3                	call   *%ebx
				num = -(long long) num;
  8014f5:	8b 55 d8             	mov    -0x28(%ebp),%edx
  8014f8:	8b 4d dc             	mov    -0x24(%ebp),%ecx
  8014fb:	f7 da                	neg    %edx
  8014fd:	83 d1 00             	adc    $0x0,%ecx
  801500:	f7 d9                	neg    %ecx
  801502:	83 c4 10             	add    $0x10,%esp
			base = 10;
  801505:	b8 0a 00 00 00       	mov    $0xa,%eax
  80150a:	eb 13                	jmp    80151f <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  80150c:	89 ca                	mov    %ecx,%edx
  80150e:	8d 45 14             	lea    0x14(%ebp),%eax
  801511:	e8 e3 fc ff ff       	call   8011f9 <getuint>
  801516:	89 d1                	mov    %edx,%ecx
  801518:	89 c2                	mov    %eax,%edx
			base = 10;
  80151a:	b8 0a 00 00 00       	mov    $0xa,%eax
			printnum(putch, putdat, num, base, width, padc);
  80151f:	83 ec 0c             	sub    $0xc,%esp
  801522:	0f be 7d d3          	movsbl -0x2d(%ebp),%edi
  801526:	57                   	push   %edi
  801527:	ff 75 e0             	pushl  -0x20(%ebp)
  80152a:	50                   	push   %eax
  80152b:	51                   	push   %ecx
  80152c:	52                   	push   %edx
  80152d:	89 f2                	mov    %esi,%edx
  80152f:	89 d8                	mov    %ebx,%eax
  801531:	e8 1a fc ff ff       	call   801150 <printnum>
			break;
  801536:	83 c4 20             	add    $0x20,%esp
{
  801539:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80153c:	83 c7 01             	add    $0x1,%edi
  80153f:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801543:	83 f8 25             	cmp    $0x25,%eax
  801546:	0f 84 6a fd ff ff    	je     8012b6 <vprintfmt+0x1b>
			if (ch == '\0')
  80154c:	85 c0                	test   %eax,%eax
  80154e:	0f 84 93 00 00 00    	je     8015e7 <vprintfmt+0x34c>
			putch(ch, putdat);
  801554:	83 ec 08             	sub    $0x8,%esp
  801557:	56                   	push   %esi
  801558:	50                   	push   %eax
  801559:	ff d3                	call   *%ebx
  80155b:	83 c4 10             	add    $0x10,%esp
  80155e:	eb dc                	jmp    80153c <vprintfmt+0x2a1>
			num = getuint(&ap, lflag);
  801560:	89 ca                	mov    %ecx,%edx
  801562:	8d 45 14             	lea    0x14(%ebp),%eax
  801565:	e8 8f fc ff ff       	call   8011f9 <getuint>
  80156a:	89 d1                	mov    %edx,%ecx
  80156c:	89 c2                	mov    %eax,%edx
			base = 8;
  80156e:	b8 08 00 00 00       	mov    $0x8,%eax
			goto number;
  801573:	eb aa                	jmp    80151f <vprintfmt+0x284>
			putch('0', putdat);
  801575:	83 ec 08             	sub    $0x8,%esp
  801578:	56                   	push   %esi
  801579:	6a 30                	push   $0x30
  80157b:	ff d3                	call   *%ebx
			putch('x', putdat);
  80157d:	83 c4 08             	add    $0x8,%esp
  801580:	56                   	push   %esi
  801581:	6a 78                	push   $0x78
  801583:	ff d3                	call   *%ebx
				(uintptr_t) va_arg(ap, void *);
  801585:	8b 45 14             	mov    0x14(%ebp),%eax
  801588:	8d 50 04             	lea    0x4(%eax),%edx
  80158b:	89 55 14             	mov    %edx,0x14(%ebp)
			num = (unsigned long long)
  80158e:	8b 10                	mov    (%eax),%edx
  801590:	b9 00 00 00 00       	mov    $0x0,%ecx
			goto number;
  801595:	83 c4 10             	add    $0x10,%esp
			base = 16;
  801598:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  80159d:	eb 80                	jmp    80151f <vprintfmt+0x284>
			num = getuint(&ap, lflag);
  80159f:	89 ca                	mov    %ecx,%edx
  8015a1:	8d 45 14             	lea    0x14(%ebp),%eax
  8015a4:	e8 50 fc ff ff       	call   8011f9 <getuint>
  8015a9:	89 d1                	mov    %edx,%ecx
  8015ab:	89 c2                	mov    %eax,%edx
			base = 16;
  8015ad:	b8 10 00 00 00       	mov    $0x10,%eax
  8015b2:	e9 68 ff ff ff       	jmp    80151f <vprintfmt+0x284>
			putch(ch, putdat);
  8015b7:	83 ec 08             	sub    $0x8,%esp
  8015ba:	56                   	push   %esi
  8015bb:	6a 25                	push   $0x25
  8015bd:	ff d3                	call   *%ebx
			break;
  8015bf:	83 c4 10             	add    $0x10,%esp
  8015c2:	e9 72 ff ff ff       	jmp    801539 <vprintfmt+0x29e>
			putch('%', putdat);
  8015c7:	83 ec 08             	sub    $0x8,%esp
  8015ca:	56                   	push   %esi
  8015cb:	6a 25                	push   $0x25
  8015cd:	ff d3                	call   *%ebx
			for (fmt--; fmt[-1] != '%'; fmt--)
  8015cf:	83 c4 10             	add    $0x10,%esp
  8015d2:	89 f8                	mov    %edi,%eax
  8015d4:	80 78 ff 25          	cmpb   $0x25,-0x1(%eax)
  8015d8:	74 05                	je     8015df <vprintfmt+0x344>
  8015da:	83 e8 01             	sub    $0x1,%eax
  8015dd:	eb f5                	jmp    8015d4 <vprintfmt+0x339>
  8015df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8015e2:	e9 52 ff ff ff       	jmp    801539 <vprintfmt+0x29e>
}
  8015e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8015ea:	5b                   	pop    %ebx
  8015eb:	5e                   	pop    %esi
  8015ec:	5f                   	pop    %edi
  8015ed:	5d                   	pop    %ebp
  8015ee:	c3                   	ret    

008015ef <vsnprintf>:

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  8015ef:	f3 0f 1e fb          	endbr32 
  8015f3:	55                   	push   %ebp
  8015f4:	89 e5                	mov    %esp,%ebp
  8015f6:	83 ec 18             	sub    $0x18,%esp
  8015f9:	8b 45 08             	mov    0x8(%ebp),%eax
  8015fc:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  8015ff:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801602:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801606:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801609:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801610:	85 c0                	test   %eax,%eax
  801612:	74 26                	je     80163a <vsnprintf+0x4b>
  801614:	85 d2                	test   %edx,%edx
  801616:	7e 22                	jle    80163a <vsnprintf+0x4b>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801618:	ff 75 14             	pushl  0x14(%ebp)
  80161b:	ff 75 10             	pushl  0x10(%ebp)
  80161e:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801621:	50                   	push   %eax
  801622:	68 59 12 80 00       	push   $0x801259
  801627:	e8 6f fc ff ff       	call   80129b <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80162c:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80162f:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801632:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801635:	83 c4 10             	add    $0x10,%esp
}
  801638:	c9                   	leave  
  801639:	c3                   	ret    
		return -E_INVAL;
  80163a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80163f:	eb f7                	jmp    801638 <vsnprintf+0x49>

00801641 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801641:	f3 0f 1e fb          	endbr32 
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80164b:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80164e:	50                   	push   %eax
  80164f:	ff 75 10             	pushl  0x10(%ebp)
  801652:	ff 75 0c             	pushl  0xc(%ebp)
  801655:	ff 75 08             	pushl  0x8(%ebp)
  801658:	e8 92 ff ff ff       	call   8015ef <vsnprintf>
	va_end(ap);

	return rc;
}
  80165d:	c9                   	leave  
  80165e:	c3                   	ret    

0080165f <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80165f:	f3 0f 1e fb          	endbr32 
  801663:	55                   	push   %ebp
  801664:	89 e5                	mov    %esp,%ebp
  801666:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  801669:	b8 00 00 00 00       	mov    $0x0,%eax
  80166e:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  801672:	74 05                	je     801679 <strlen+0x1a>
		n++;
  801674:	83 c0 01             	add    $0x1,%eax
  801677:	eb f5                	jmp    80166e <strlen+0xf>
	return n;
}
  801679:	5d                   	pop    %ebp
  80167a:	c3                   	ret    

0080167b <strnlen>:

int
strnlen(const char *s, size_t size)
{
  80167b:	f3 0f 1e fb          	endbr32 
  80167f:	55                   	push   %ebp
  801680:	89 e5                	mov    %esp,%ebp
  801682:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801685:	8b 55 0c             	mov    0xc(%ebp),%edx
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  801688:	b8 00 00 00 00       	mov    $0x0,%eax
  80168d:	39 d0                	cmp    %edx,%eax
  80168f:	74 0d                	je     80169e <strnlen+0x23>
  801691:	80 3c 01 00          	cmpb   $0x0,(%ecx,%eax,1)
  801695:	74 05                	je     80169c <strnlen+0x21>
		n++;
  801697:	83 c0 01             	add    $0x1,%eax
  80169a:	eb f1                	jmp    80168d <strnlen+0x12>
  80169c:	89 c2                	mov    %eax,%edx
	return n;
}
  80169e:	89 d0                	mov    %edx,%eax
  8016a0:	5d                   	pop    %ebp
  8016a1:	c3                   	ret    

008016a2 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016a2:	f3 0f 1e fb          	endbr32 
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	53                   	push   %ebx
  8016aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016ad:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016b0:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b5:	0f b6 14 03          	movzbl (%ebx,%eax,1),%edx
  8016b9:	88 14 01             	mov    %dl,(%ecx,%eax,1)
  8016bc:	83 c0 01             	add    $0x1,%eax
  8016bf:	84 d2                	test   %dl,%dl
  8016c1:	75 f2                	jne    8016b5 <strcpy+0x13>
		/* do nothing */;
	return ret;
}
  8016c3:	89 c8                	mov    %ecx,%eax
  8016c5:	5b                   	pop    %ebx
  8016c6:	5d                   	pop    %ebp
  8016c7:	c3                   	ret    

008016c8 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016c8:	f3 0f 1e fb          	endbr32 
  8016cc:	55                   	push   %ebp
  8016cd:	89 e5                	mov    %esp,%ebp
  8016cf:	53                   	push   %ebx
  8016d0:	83 ec 10             	sub    $0x10,%esp
  8016d3:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016d6:	53                   	push   %ebx
  8016d7:	e8 83 ff ff ff       	call   80165f <strlen>
  8016dc:	83 c4 08             	add    $0x8,%esp
	strcpy(dst + len, src);
  8016df:	ff 75 0c             	pushl  0xc(%ebp)
  8016e2:	01 d8                	add    %ebx,%eax
  8016e4:	50                   	push   %eax
  8016e5:	e8 b8 ff ff ff       	call   8016a2 <strcpy>
	return dst;
}
  8016ea:	89 d8                	mov    %ebx,%eax
  8016ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8016ef:	c9                   	leave  
  8016f0:	c3                   	ret    

008016f1 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8016f1:	f3 0f 1e fb          	endbr32 
  8016f5:	55                   	push   %ebp
  8016f6:	89 e5                	mov    %esp,%ebp
  8016f8:	56                   	push   %esi
  8016f9:	53                   	push   %ebx
  8016fa:	8b 75 08             	mov    0x8(%ebp),%esi
  8016fd:	8b 55 0c             	mov    0xc(%ebp),%edx
  801700:	89 f3                	mov    %esi,%ebx
  801702:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801705:	89 f0                	mov    %esi,%eax
  801707:	39 d8                	cmp    %ebx,%eax
  801709:	74 11                	je     80171c <strncpy+0x2b>
		*dst++ = *src;
  80170b:	83 c0 01             	add    $0x1,%eax
  80170e:	0f b6 0a             	movzbl (%edx),%ecx
  801711:	88 48 ff             	mov    %cl,-0x1(%eax)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801714:	80 f9 01             	cmp    $0x1,%cl
  801717:	83 da ff             	sbb    $0xffffffff,%edx
  80171a:	eb eb                	jmp    801707 <strncpy+0x16>
	}
	return ret;
}
  80171c:	89 f0                	mov    %esi,%eax
  80171e:	5b                   	pop    %ebx
  80171f:	5e                   	pop    %esi
  801720:	5d                   	pop    %ebp
  801721:	c3                   	ret    

00801722 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801722:	f3 0f 1e fb          	endbr32 
  801726:	55                   	push   %ebp
  801727:	89 e5                	mov    %esp,%ebp
  801729:	56                   	push   %esi
  80172a:	53                   	push   %ebx
  80172b:	8b 75 08             	mov    0x8(%ebp),%esi
  80172e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801731:	8b 55 10             	mov    0x10(%ebp),%edx
  801734:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801736:	85 d2                	test   %edx,%edx
  801738:	74 21                	je     80175b <strlcpy+0x39>
  80173a:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80173e:	89 f2                	mov    %esi,%edx
		while (--size > 0 && *src != '\0')
  801740:	39 c2                	cmp    %eax,%edx
  801742:	74 14                	je     801758 <strlcpy+0x36>
  801744:	0f b6 19             	movzbl (%ecx),%ebx
  801747:	84 db                	test   %bl,%bl
  801749:	74 0b                	je     801756 <strlcpy+0x34>
			*dst++ = *src++;
  80174b:	83 c1 01             	add    $0x1,%ecx
  80174e:	83 c2 01             	add    $0x1,%edx
  801751:	88 5a ff             	mov    %bl,-0x1(%edx)
  801754:	eb ea                	jmp    801740 <strlcpy+0x1e>
  801756:	89 d0                	mov    %edx,%eax
		*dst = '\0';
  801758:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80175b:	29 f0                	sub    %esi,%eax
}
  80175d:	5b                   	pop    %ebx
  80175e:	5e                   	pop    %esi
  80175f:	5d                   	pop    %ebp
  801760:	c3                   	ret    

00801761 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801761:	f3 0f 1e fb          	endbr32 
  801765:	55                   	push   %ebp
  801766:	89 e5                	mov    %esp,%ebp
  801768:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80176b:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80176e:	0f b6 01             	movzbl (%ecx),%eax
  801771:	84 c0                	test   %al,%al
  801773:	74 0c                	je     801781 <strcmp+0x20>
  801775:	3a 02                	cmp    (%edx),%al
  801777:	75 08                	jne    801781 <strcmp+0x20>
		p++, q++;
  801779:	83 c1 01             	add    $0x1,%ecx
  80177c:	83 c2 01             	add    $0x1,%edx
  80177f:	eb ed                	jmp    80176e <strcmp+0xd>
	return (int) ((unsigned char) *p - (unsigned char) *q);
  801781:	0f b6 c0             	movzbl %al,%eax
  801784:	0f b6 12             	movzbl (%edx),%edx
  801787:	29 d0                	sub    %edx,%eax
}
  801789:	5d                   	pop    %ebp
  80178a:	c3                   	ret    

0080178b <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  80178b:	f3 0f 1e fb          	endbr32 
  80178f:	55                   	push   %ebp
  801790:	89 e5                	mov    %esp,%ebp
  801792:	53                   	push   %ebx
  801793:	8b 45 08             	mov    0x8(%ebp),%eax
  801796:	8b 55 0c             	mov    0xc(%ebp),%edx
  801799:	89 c3                	mov    %eax,%ebx
  80179b:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  80179e:	eb 06                	jmp    8017a6 <strncmp+0x1b>
		n--, p++, q++;
  8017a0:	83 c0 01             	add    $0x1,%eax
  8017a3:	83 c2 01             	add    $0x1,%edx
	while (n > 0 && *p && *p == *q)
  8017a6:	39 d8                	cmp    %ebx,%eax
  8017a8:	74 16                	je     8017c0 <strncmp+0x35>
  8017aa:	0f b6 08             	movzbl (%eax),%ecx
  8017ad:	84 c9                	test   %cl,%cl
  8017af:	74 04                	je     8017b5 <strncmp+0x2a>
  8017b1:	3a 0a                	cmp    (%edx),%cl
  8017b3:	74 eb                	je     8017a0 <strncmp+0x15>
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017b5:	0f b6 00             	movzbl (%eax),%eax
  8017b8:	0f b6 12             	movzbl (%edx),%edx
  8017bb:	29 d0                	sub    %edx,%eax
}
  8017bd:	5b                   	pop    %ebx
  8017be:	5d                   	pop    %ebp
  8017bf:	c3                   	ret    
		return 0;
  8017c0:	b8 00 00 00 00       	mov    $0x0,%eax
  8017c5:	eb f6                	jmp    8017bd <strncmp+0x32>

008017c7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017c7:	f3 0f 1e fb          	endbr32 
  8017cb:	55                   	push   %ebp
  8017cc:	89 e5                	mov    %esp,%ebp
  8017ce:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d1:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017d5:	0f b6 10             	movzbl (%eax),%edx
  8017d8:	84 d2                	test   %dl,%dl
  8017da:	74 09                	je     8017e5 <strchr+0x1e>
		if (*s == c)
  8017dc:	38 ca                	cmp    %cl,%dl
  8017de:	74 0a                	je     8017ea <strchr+0x23>
	for (; *s; s++)
  8017e0:	83 c0 01             	add    $0x1,%eax
  8017e3:	eb f0                	jmp    8017d5 <strchr+0xe>
			return (char *) s;
	return 0;
  8017e5:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017ea:	5d                   	pop    %ebp
  8017eb:	c3                   	ret    

008017ec <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017ec:	f3 0f 1e fb          	endbr32 
  8017f0:	55                   	push   %ebp
  8017f1:	89 e5                	mov    %esp,%ebp
  8017f3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f6:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017fa:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  8017fd:	38 ca                	cmp    %cl,%dl
  8017ff:	74 09                	je     80180a <strfind+0x1e>
  801801:	84 d2                	test   %dl,%dl
  801803:	74 05                	je     80180a <strfind+0x1e>
	for (; *s; s++)
  801805:	83 c0 01             	add    $0x1,%eax
  801808:	eb f0                	jmp    8017fa <strfind+0xe>
			break;
	return (char *) s;
}
  80180a:	5d                   	pop    %ebp
  80180b:	c3                   	ret    

0080180c <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80180c:	f3 0f 1e fb          	endbr32 
  801810:	55                   	push   %ebp
  801811:	89 e5                	mov    %esp,%ebp
  801813:	57                   	push   %edi
  801814:	56                   	push   %esi
  801815:	53                   	push   %ebx
  801816:	8b 55 08             	mov    0x8(%ebp),%edx
  801819:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p = v;

	if (n == 0)
  80181c:	85 c9                	test   %ecx,%ecx
  80181e:	74 33                	je     801853 <memset+0x47>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801820:	89 d0                	mov    %edx,%eax
  801822:	09 c8                	or     %ecx,%eax
  801824:	a8 03                	test   $0x3,%al
  801826:	75 23                	jne    80184b <memset+0x3f>
		c &= 0xFF;
  801828:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80182c:	89 d8                	mov    %ebx,%eax
  80182e:	c1 e0 08             	shl    $0x8,%eax
  801831:	89 df                	mov    %ebx,%edi
  801833:	c1 e7 18             	shl    $0x18,%edi
  801836:	89 de                	mov    %ebx,%esi
  801838:	c1 e6 10             	shl    $0x10,%esi
  80183b:	09 f7                	or     %esi,%edi
  80183d:	09 fb                	or     %edi,%ebx
		asm volatile("cld; rep stosl\n"
			: "=D" (p), "=c" (n)
			: "D" (p), "a" (c), "c" (n/4)
  80183f:	c1 e9 02             	shr    $0x2,%ecx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801842:	09 d8                	or     %ebx,%eax
		asm volatile("cld; rep stosl\n"
  801844:	89 d7                	mov    %edx,%edi
  801846:	fc                   	cld    
  801847:	f3 ab                	rep stos %eax,%es:(%edi)
  801849:	eb 08                	jmp    801853 <memset+0x47>
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80184b:	89 d7                	mov    %edx,%edi
  80184d:	8b 45 0c             	mov    0xc(%ebp),%eax
  801850:	fc                   	cld    
  801851:	f3 aa                	rep stos %al,%es:(%edi)
			: "=D" (p), "=c" (n)
			: "0" (p), "a" (c), "1" (n)
			: "cc", "memory");
	return v;
}
  801853:	89 d0                	mov    %edx,%eax
  801855:	5b                   	pop    %ebx
  801856:	5e                   	pop    %esi
  801857:	5f                   	pop    %edi
  801858:	5d                   	pop    %ebp
  801859:	c3                   	ret    

0080185a <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80185a:	f3 0f 1e fb          	endbr32 
  80185e:	55                   	push   %ebp
  80185f:	89 e5                	mov    %esp,%ebp
  801861:	57                   	push   %edi
  801862:	56                   	push   %esi
  801863:	8b 45 08             	mov    0x8(%ebp),%eax
  801866:	8b 75 0c             	mov    0xc(%ebp),%esi
  801869:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80186c:	39 c6                	cmp    %eax,%esi
  80186e:	73 32                	jae    8018a2 <memmove+0x48>
  801870:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801873:	39 c2                	cmp    %eax,%edx
  801875:	76 2b                	jbe    8018a2 <memmove+0x48>
		s += n;
		d += n;
  801877:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80187a:	89 fe                	mov    %edi,%esi
  80187c:	09 ce                	or     %ecx,%esi
  80187e:	09 d6                	or     %edx,%esi
  801880:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801886:	75 0e                	jne    801896 <memmove+0x3c>
			asm volatile("std; rep movsl\n"
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
  801888:	83 ef 04             	sub    $0x4,%edi
  80188b:	8d 72 fc             	lea    -0x4(%edx),%esi
  80188e:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("std; rep movsl\n"
  801891:	fd                   	std    
  801892:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  801894:	eb 09                	jmp    80189f <memmove+0x45>
		else
			asm volatile("std; rep movsb\n"
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
  801896:	83 ef 01             	sub    $0x1,%edi
  801899:	8d 72 ff             	lea    -0x1(%edx),%esi
			asm volatile("std; rep movsb\n"
  80189c:	fd                   	std    
  80189d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  80189f:	fc                   	cld    
  8018a0:	eb 1a                	jmp    8018bc <memmove+0x62>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018a2:	89 c2                	mov    %eax,%edx
  8018a4:	09 ca                	or     %ecx,%edx
  8018a6:	09 f2                	or     %esi,%edx
  8018a8:	f6 c2 03             	test   $0x3,%dl
  8018ab:	75 0a                	jne    8018b7 <memmove+0x5d>
			asm volatile("cld; rep movsl\n"
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
  8018ad:	c1 e9 02             	shr    $0x2,%ecx
			asm volatile("cld; rep movsl\n"
  8018b0:	89 c7                	mov    %eax,%edi
  8018b2:	fc                   	cld    
  8018b3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018b5:	eb 05                	jmp    8018bc <memmove+0x62>
		else
			asm volatile("cld; rep movsb\n"
  8018b7:	89 c7                	mov    %eax,%edi
  8018b9:	fc                   	cld    
  8018ba:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018bc:	5e                   	pop    %esi
  8018bd:	5f                   	pop    %edi
  8018be:	5d                   	pop    %ebp
  8018bf:	c3                   	ret    

008018c0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018c0:	f3 0f 1e fb          	endbr32 
  8018c4:	55                   	push   %ebp
  8018c5:	89 e5                	mov    %esp,%ebp
  8018c7:	83 ec 0c             	sub    $0xc,%esp
	return memmove(dst, src, n);
  8018ca:	ff 75 10             	pushl  0x10(%ebp)
  8018cd:	ff 75 0c             	pushl  0xc(%ebp)
  8018d0:	ff 75 08             	pushl  0x8(%ebp)
  8018d3:	e8 82 ff ff ff       	call   80185a <memmove>
}
  8018d8:	c9                   	leave  
  8018d9:	c3                   	ret    

008018da <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018da:	f3 0f 1e fb          	endbr32 
  8018de:	55                   	push   %ebp
  8018df:	89 e5                	mov    %esp,%ebp
  8018e1:	56                   	push   %esi
  8018e2:	53                   	push   %ebx
  8018e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8018e6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018e9:	89 c6                	mov    %eax,%esi
  8018eb:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018ee:	39 f0                	cmp    %esi,%eax
  8018f0:	74 1c                	je     80190e <memcmp+0x34>
		if (*s1 != *s2)
  8018f2:	0f b6 08             	movzbl (%eax),%ecx
  8018f5:	0f b6 1a             	movzbl (%edx),%ebx
  8018f8:	38 d9                	cmp    %bl,%cl
  8018fa:	75 08                	jne    801904 <memcmp+0x2a>
			return (int) *s1 - (int) *s2;
		s1++, s2++;
  8018fc:	83 c0 01             	add    $0x1,%eax
  8018ff:	83 c2 01             	add    $0x1,%edx
  801902:	eb ea                	jmp    8018ee <memcmp+0x14>
			return (int) *s1 - (int) *s2;
  801904:	0f b6 c1             	movzbl %cl,%eax
  801907:	0f b6 db             	movzbl %bl,%ebx
  80190a:	29 d8                	sub    %ebx,%eax
  80190c:	eb 05                	jmp    801913 <memcmp+0x39>
	}

	return 0;
  80190e:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801913:	5b                   	pop    %ebx
  801914:	5e                   	pop    %esi
  801915:	5d                   	pop    %ebp
  801916:	c3                   	ret    

00801917 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801917:	f3 0f 1e fb          	endbr32 
  80191b:	55                   	push   %ebp
  80191c:	89 e5                	mov    %esp,%ebp
  80191e:	8b 45 08             	mov    0x8(%ebp),%eax
  801921:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	const void *ends = (const char *) s + n;
  801924:	89 c2                	mov    %eax,%edx
  801926:	03 55 10             	add    0x10(%ebp),%edx
	for (; s < ends; s++)
  801929:	39 d0                	cmp    %edx,%eax
  80192b:	73 09                	jae    801936 <memfind+0x1f>
		if (*(const unsigned char *) s == (unsigned char) c)
  80192d:	38 08                	cmp    %cl,(%eax)
  80192f:	74 05                	je     801936 <memfind+0x1f>
	for (; s < ends; s++)
  801931:	83 c0 01             	add    $0x1,%eax
  801934:	eb f3                	jmp    801929 <memfind+0x12>
			break;
	return (void *) s;
}
  801936:	5d                   	pop    %ebp
  801937:	c3                   	ret    

00801938 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801938:	f3 0f 1e fb          	endbr32 
  80193c:	55                   	push   %ebp
  80193d:	89 e5                	mov    %esp,%ebp
  80193f:	57                   	push   %edi
  801940:	56                   	push   %esi
  801941:	53                   	push   %ebx
  801942:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801945:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801948:	eb 03                	jmp    80194d <strtol+0x15>
		s++;
  80194a:	83 c1 01             	add    $0x1,%ecx
	while (*s == ' ' || *s == '\t')
  80194d:	0f b6 01             	movzbl (%ecx),%eax
  801950:	3c 20                	cmp    $0x20,%al
  801952:	74 f6                	je     80194a <strtol+0x12>
  801954:	3c 09                	cmp    $0x9,%al
  801956:	74 f2                	je     80194a <strtol+0x12>

	// plus/minus sign
	if (*s == '+')
  801958:	3c 2b                	cmp    $0x2b,%al
  80195a:	74 2a                	je     801986 <strtol+0x4e>
	int neg = 0;
  80195c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;
	else if (*s == '-')
  801961:	3c 2d                	cmp    $0x2d,%al
  801963:	74 2b                	je     801990 <strtol+0x58>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801965:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  80196b:	75 0f                	jne    80197c <strtol+0x44>
  80196d:	80 39 30             	cmpb   $0x30,(%ecx)
  801970:	74 28                	je     80199a <strtol+0x62>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
		s++, base = 8;
	else if (base == 0)
		base = 10;
  801972:	85 db                	test   %ebx,%ebx
  801974:	b8 0a 00 00 00       	mov    $0xa,%eax
  801979:	0f 44 d8             	cmove  %eax,%ebx
  80197c:	b8 00 00 00 00       	mov    $0x0,%eax
  801981:	89 5d 10             	mov    %ebx,0x10(%ebp)
  801984:	eb 46                	jmp    8019cc <strtol+0x94>
		s++;
  801986:	83 c1 01             	add    $0x1,%ecx
	int neg = 0;
  801989:	bf 00 00 00 00       	mov    $0x0,%edi
  80198e:	eb d5                	jmp    801965 <strtol+0x2d>
		s++, neg = 1;
  801990:	83 c1 01             	add    $0x1,%ecx
  801993:	bf 01 00 00 00       	mov    $0x1,%edi
  801998:	eb cb                	jmp    801965 <strtol+0x2d>
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80199a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80199e:	74 0e                	je     8019ae <strtol+0x76>
	else if (base == 0 && s[0] == '0')
  8019a0:	85 db                	test   %ebx,%ebx
  8019a2:	75 d8                	jne    80197c <strtol+0x44>
		s++, base = 8;
  8019a4:	83 c1 01             	add    $0x1,%ecx
  8019a7:	bb 08 00 00 00       	mov    $0x8,%ebx
  8019ac:	eb ce                	jmp    80197c <strtol+0x44>
		s += 2, base = 16;
  8019ae:	83 c1 02             	add    $0x2,%ecx
  8019b1:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019b6:	eb c4                	jmp    80197c <strtol+0x44>
	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
  8019b8:	0f be d2             	movsbl %dl,%edx
  8019bb:	83 ea 30             	sub    $0x30,%edx
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
			dig = *s - 'A' + 10;
		else
			break;
		if (dig >= base)
  8019be:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019c1:	7d 3a                	jge    8019fd <strtol+0xc5>
			break;
		s++, val = (val * base) + dig;
  8019c3:	83 c1 01             	add    $0x1,%ecx
  8019c6:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019ca:	01 d0                	add    %edx,%eax
		if (*s >= '0' && *s <= '9')
  8019cc:	0f b6 11             	movzbl (%ecx),%edx
  8019cf:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019d2:	89 f3                	mov    %esi,%ebx
  8019d4:	80 fb 09             	cmp    $0x9,%bl
  8019d7:	76 df                	jbe    8019b8 <strtol+0x80>
		else if (*s >= 'a' && *s <= 'z')
  8019d9:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019dc:	89 f3                	mov    %esi,%ebx
  8019de:	80 fb 19             	cmp    $0x19,%bl
  8019e1:	77 08                	ja     8019eb <strtol+0xb3>
			dig = *s - 'a' + 10;
  8019e3:	0f be d2             	movsbl %dl,%edx
  8019e6:	83 ea 57             	sub    $0x57,%edx
  8019e9:	eb d3                	jmp    8019be <strtol+0x86>
		else if (*s >= 'A' && *s <= 'Z')
  8019eb:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019ee:	89 f3                	mov    %esi,%ebx
  8019f0:	80 fb 19             	cmp    $0x19,%bl
  8019f3:	77 08                	ja     8019fd <strtol+0xc5>
			dig = *s - 'A' + 10;
  8019f5:	0f be d2             	movsbl %dl,%edx
  8019f8:	83 ea 37             	sub    $0x37,%edx
  8019fb:	eb c1                	jmp    8019be <strtol+0x86>
		// we don't properly detect overflow!
	}

	if (endptr)
  8019fd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a01:	74 05                	je     801a08 <strtol+0xd0>
		*endptr = (char *) s;
  801a03:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a06:	89 0e                	mov    %ecx,(%esi)
	return (neg ? -val : val);
  801a08:	89 c2                	mov    %eax,%edx
  801a0a:	f7 da                	neg    %edx
  801a0c:	85 ff                	test   %edi,%edi
  801a0e:	0f 45 c2             	cmovne %edx,%eax
}
  801a11:	5b                   	pop    %ebx
  801a12:	5e                   	pop    %esi
  801a13:	5f                   	pop    %edi
  801a14:	5d                   	pop    %ebp
  801a15:	c3                   	ret    

00801a16 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a16:	f3 0f 1e fb          	endbr32 
  801a1a:	55                   	push   %ebp
  801a1b:	89 e5                	mov    %esp,%ebp
  801a1d:	56                   	push   %esi
  801a1e:	53                   	push   %ebx
  801a1f:	8b 75 08             	mov    0x8(%ebp),%esi
  801a22:	8b 45 0c             	mov    0xc(%ebp),%eax
  801a25:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	// If 'pg' is null, we pass sys_ipc_recv a value that it will understand
	//   as meaning "no page"
	bool err = sys_ipc_recv(pg == NULL ? (void *) UTOP : pg) == -E_INVAL;
  801a28:	85 c0                	test   %eax,%eax
  801a2a:	ba 00 00 c0 ee       	mov    $0xeec00000,%edx
  801a2f:	0f 44 c2             	cmove  %edx,%eax
  801a32:	83 ec 0c             	sub    $0xc,%esp
  801a35:	50                   	push   %eax
  801a36:	e8 a7 e8 ff ff       	call   8002e2 <sys_ipc_recv>

	if (from_env_store != NULL)
  801a3b:	83 c4 10             	add    $0x10,%esp
  801a3e:	85 f6                	test   %esi,%esi
  801a40:	74 15                	je     801a57 <ipc_recv+0x41>
		*from_env_store = err ? 0 : thisenv->env_ipc_from;
  801a42:	ba 00 00 00 00       	mov    $0x0,%edx
  801a47:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a4a:	74 09                	je     801a55 <ipc_recv+0x3f>
  801a4c:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a52:	8b 52 74             	mov    0x74(%edx),%edx
  801a55:	89 16                	mov    %edx,(%esi)

	if (perm_store != NULL)
  801a57:	85 db                	test   %ebx,%ebx
  801a59:	74 15                	je     801a70 <ipc_recv+0x5a>
		*perm_store = err ? 0 : thisenv->env_ipc_perm;
  801a5b:	ba 00 00 00 00       	mov    $0x0,%edx
  801a60:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a63:	74 09                	je     801a6e <ipc_recv+0x58>
  801a65:	8b 15 04 40 80 00    	mov    0x804004,%edx
  801a6b:	8b 52 78             	mov    0x78(%edx),%edx
  801a6e:	89 13                	mov    %edx,(%ebx)

	return err ? -E_INVAL : thisenv->env_ipc_value;
  801a70:	83 f8 fd             	cmp    $0xfffffffd,%eax
  801a73:	74 08                	je     801a7d <ipc_recv+0x67>
  801a75:	a1 04 40 80 00       	mov    0x804004,%eax
  801a7a:	8b 40 70             	mov    0x70(%eax),%eax
}
  801a7d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a80:	5b                   	pop    %ebx
  801a81:	5e                   	pop    %esi
  801a82:	5d                   	pop    %ebp
  801a83:	c3                   	ret    

00801a84 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a84:	f3 0f 1e fb          	endbr32 
  801a88:	55                   	push   %ebp
  801a89:	89 e5                	mov    %esp,%ebp
  801a8b:	57                   	push   %edi
  801a8c:	56                   	push   %esi
  801a8d:	53                   	push   %ebx
  801a8e:	83 ec 0c             	sub    $0xc,%esp
  801a91:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a94:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a97:	8b 5d 10             	mov    0x10(%ebp),%ebx
  801a9a:	eb 1f                	jmp    801abb <ipc_send+0x37>
	int res;
	while (true) {
		if (pg != NULL) {
			res = sys_ipc_try_send(to_env, val, pg, perm);
		} else {
			res = sys_ipc_try_send(to_env, val, (void *) UTOP, 0);
  801a9c:	6a 00                	push   $0x0
  801a9e:	68 00 00 c0 ee       	push   $0xeec00000
  801aa3:	56                   	push   %esi
  801aa4:	57                   	push   %edi
  801aa5:	e8 0f e8 ff ff       	call   8002b9 <sys_ipc_try_send>
  801aaa:	83 c4 10             	add    $0x10,%esp
		}

		if (res == 0)
  801aad:	85 c0                	test   %eax,%eax
  801aaf:	74 30                	je     801ae1 <ipc_send+0x5d>
			return;
		if (res != -E_IPC_NOT_RECV)
  801ab1:	83 f8 f9             	cmp    $0xfffffff9,%eax
  801ab4:	75 19                	jne    801acf <ipc_send+0x4b>
			panic("ipc_send: %d", res);
		sys_yield();
  801ab6:	e8 e5 e6 ff ff       	call   8001a0 <sys_yield>
		if (pg != NULL) {
  801abb:	85 db                	test   %ebx,%ebx
  801abd:	74 dd                	je     801a9c <ipc_send+0x18>
			res = sys_ipc_try_send(to_env, val, pg, perm);
  801abf:	ff 75 14             	pushl  0x14(%ebp)
  801ac2:	53                   	push   %ebx
  801ac3:	56                   	push   %esi
  801ac4:	57                   	push   %edi
  801ac5:	e8 ef e7 ff ff       	call   8002b9 <sys_ipc_try_send>
  801aca:	83 c4 10             	add    $0x10,%esp
  801acd:	eb de                	jmp    801aad <ipc_send+0x29>
			panic("ipc_send: %d", res);
  801acf:	50                   	push   %eax
  801ad0:	68 1f 22 80 00       	push   $0x80221f
  801ad5:	6a 3e                	push   $0x3e
  801ad7:	68 2c 22 80 00       	push   $0x80222c
  801adc:	e8 70 f5 ff ff       	call   801051 <_panic>
	}
}
  801ae1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ae4:	5b                   	pop    %ebx
  801ae5:	5e                   	pop    %esi
  801ae6:	5f                   	pop    %edi
  801ae7:	5d                   	pop    %ebp
  801ae8:	c3                   	ret    

00801ae9 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ae9:	f3 0f 1e fb          	endbr32 
  801aed:	55                   	push   %ebp
  801aee:	89 e5                	mov    %esp,%ebp
  801af0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801af3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801af8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801afb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801b01:	8b 52 50             	mov    0x50(%edx),%edx
  801b04:	39 ca                	cmp    %ecx,%edx
  801b06:	74 11                	je     801b19 <ipc_find_env+0x30>
	for (i = 0; i < NENV; i++)
  801b08:	83 c0 01             	add    $0x1,%eax
  801b0b:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b10:	75 e6                	jne    801af8 <ipc_find_env+0xf>
			return envs[i].env_id;
	return 0;
  801b12:	b8 00 00 00 00       	mov    $0x0,%eax
  801b17:	eb 0b                	jmp    801b24 <ipc_find_env+0x3b>
			return envs[i].env_id;
  801b19:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b1c:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b21:	8b 40 48             	mov    0x48(%eax),%eax
}
  801b24:	5d                   	pop    %ebp
  801b25:	c3                   	ret    

00801b26 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b26:	f3 0f 1e fb          	endbr32 
  801b2a:	55                   	push   %ebp
  801b2b:	89 e5                	mov    %esp,%ebp
  801b2d:	8b 45 08             	mov    0x8(%ebp),%eax
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b30:	89 c2                	mov    %eax,%edx
  801b32:	c1 ea 16             	shr    $0x16,%edx
  801b35:	8b 0c 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%ecx
		return 0;
  801b3c:	ba 00 00 00 00       	mov    $0x0,%edx
	if (!(uvpd[PDX(v)] & PTE_P))
  801b41:	f6 c1 01             	test   $0x1,%cl
  801b44:	74 1c                	je     801b62 <pageref+0x3c>
	pte = uvpt[PGNUM(v)];
  801b46:	c1 e8 0c             	shr    $0xc,%eax
  801b49:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
	if (!(pte & PTE_P))
  801b50:	a8 01                	test   $0x1,%al
  801b52:	74 0e                	je     801b62 <pageref+0x3c>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b54:	c1 e8 0c             	shr    $0xc,%eax
  801b57:	0f b7 14 c5 04 00 00 	movzwl -0x10fffffc(,%eax,8),%edx
  801b5e:	ef 
  801b5f:	0f b7 d2             	movzwl %dx,%edx
}
  801b62:	89 d0                	mov    %edx,%eax
  801b64:	5d                   	pop    %ebp
  801b65:	c3                   	ret    
  801b66:	66 90                	xchg   %ax,%ax
  801b68:	66 90                	xchg   %ax,%ax
  801b6a:	66 90                	xchg   %ax,%ax
  801b6c:	66 90                	xchg   %ax,%ax
  801b6e:	66 90                	xchg   %ax,%ax

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
